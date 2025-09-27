import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Web-compatible image upload service
class ImageUploadService {
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedTypes = ['jpg', 'jpeg', 'png', 'webp'];

  /// Upload image with web compatibility
  static Future<String> uploadUserAvatar({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      // Validate file size and type
      final fileSize = await imageFile.length();
      if (fileSize > maxFileSize) {
        throw Exception('File size too large. Maximum 5MB allowed.');
      }

      final fileName = imageFile.name.toLowerCase();
      final isValidType = allowedTypes.any((type) => fileName.endsWith('.$type'));
      if (!isValidType) {
        throw Exception('Invalid file type. Only JPG, PNG, and WebP are allowed.');
      }

      // Create reference with user ID and timestamp for uniqueness
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('${userId}_$timestamp.jpg');

      // Upload based on platform
      UploadTask uploadTask;
      
      if (kIsWeb) {
        // Web upload using bytes
        final bytes = await imageFile.readAsBytes();
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(
            contentType: _getContentType(fileName),
            cacheControl: 'public, max-age=31536000',
            customMetadata: {
              'userId': userId,
              'uploadedAt': DateTime.now().toIso8601String(),
              'platform': 'web',
            },
          ),
        );
      } else {
        // Mobile upload using file
        uploadTask = storageRef.putFile(
          File(imageFile.path),
          SettableMetadata(
            contentType: _getContentType(fileName),
            cacheControl: 'public, max-age=31536000',
            customMetadata: {
              'userId': userId,
              'uploadedAt': DateTime.now().toIso8601String(),
              'platform': 'mobile',
            },
          ),
        );
      }

      // Wait for upload completion with progress tracking
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw _handleFirebaseStorageError(e);
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Delete old user avatar
  static Future<void> deleteUserAvatar(String avatarUrl) async {
    try {
      if (avatarUrl.isEmpty) return;
      
      final ref = FirebaseStorage.instance.refFromURL(avatarUrl);
      await ref.delete();
    } catch (e) {
      // Ignore delete errors - old file might not exist
      print('Warning: Could not delete old avatar: $e');
    }
  }

  /// Get content type based on file extension
  static String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Handle Firebase Storage specific errors
  static Exception _handleFirebaseStorageError(FirebaseException e) {
    switch (e.code) {
      case 'storage/object-not-found':
        return Exception('File not found');
      case 'storage/unauthorized':
        return Exception('Unauthorized access. Please check your permissions.');
      case 'storage/canceled':
        return Exception('Upload was canceled');
      case 'storage/unknown':
        return Exception('Unknown error occurred during upload');
      case 'storage/invalid-format':
        return Exception('Invalid file format');
      case 'storage/invalid-argument':
        return Exception('Invalid upload parameters');
      case 'storage/retry-limit-exceeded':
        return Exception('Upload retry limit exceeded. Please try again.');
      case 'storage/quota-exceeded':
        return Exception('Storage quota exceeded');
      default:
        return Exception('Upload failed: ${e.message ?? e.code}');
    }
  }

  /// Compress image for web (optional enhancement)
  static Future<Uint8List> compressImageForWeb(Uint8List imageBytes) async {
    // For now, return original bytes
    // You can implement image compression here if needed
    return imageBytes;
  }
}