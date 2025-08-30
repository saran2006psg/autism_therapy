import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// Firebase Authentication Service
/// Handles user authentication and profile management
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Get authentication state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  static Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Get user profile from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          await updateLastLogin();
          return AuthResult(
            success: true,
            user: credential.user,
            userRole: userData['role'] as String?,
            userName: userData['name'] as String?,
          );
        } else {
          // Create user profile if doesn't exist
          await _createUserProfile(credential.user!);
          return AuthResult(
            success: true,
            user: credential.user,
            userRole: 'Therapist', // Default role
            userName: credential.user!.displayName,
          );
        }
      }

      return AuthResult(
        success: false,
        errorMessage: 'Authentication failed',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Create new account with email and password
  static Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String role = 'Therapist',
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);
        
        // Create user profile in Firestore
        await _createUserProfile(credential.user!, name: name, role: role);
        
        return AuthResult(
          success: true,
          user: credential.user,
          userRole: role,
          userName: name,
        );
      }

      return AuthResult(
        success: false,
        errorMessage: 'Account creation failed',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Create user profile in Firestore
  static Future<void> _createUserProfile(User user, {String? name, String? role}) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'name': name ?? user.displayName ?? user.email?.split('@').first ?? 'User',
        'role': role ?? 'Therapist', // Default role
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Add role-specific fields
      if (role?.toLowerCase() == 'therapist') {
        userData.addAll({
          'specialization': '',
          'licenseNumber': '',
          'yearsOfExperience': 0,
          'studentIds': <String>[],
          'certifications': <String>[],
        });
      } else if (role?.toLowerCase() == 'parent') {
        userData.addAll({
          'childrenIds': <String>[],
          'primaryContact': true,
          'emergencyContact': '',
        });
      }

      await _firestore.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));
    } catch (e) {
      developer.log('Error creating user profile: $e', name: 'AuthService');
    }
  }

  /// Update last login time
  static Future<void> updateLastLogin() async {
    final user = currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        developer.log('Error updating last login: $e', name: 'AuthService');
      }
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      developer.log('Error signing out: $e', name: 'AuthService');
    }
  }

  /// Get user-friendly error messages
  static String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
      case 'invalid-email':
        return 'Invalid email address format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'weak-password':
        return 'Password should be at least 6 characters long';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final User? user;
  final String? userRole;
  final String? userName;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.user,
    this.userRole,
    this.userName,
    this.errorMessage,
  });
}
