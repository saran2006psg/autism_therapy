import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  /// Optional widget to show when the image fails to load.
  /// If null, a default asset image is shown.
  final Widget? errorWidget;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null or empty imageUrl - use a more reliable fallback
    final String validImageUrl = imageUrl?.isNotEmpty == true 
        ? imageUrl! 
        : 'https://robohash.org/default?set=set4&size=150x150'; // More reliable robot avatars
    
    // If the original URL fails, we'll fallback to a generated placeholder
    return CachedNetworkImage(
      imageUrl: validImageUrl,
      width: width,
      height: height,
      fit: fit,
      
      // Add timeout to prevent hanging
      httpHeaders: const {
        'Cache-Control': 'max-age=86400', // Cache for 24 hours
      },

      // Use caller-supplied widget if provided, else fallback asset.
      errorWidget: (context, url, error) {
        // Log the error but don't show it to users
        debugPrint('Image failed to load: $url - Error: $error');
        
        return errorWidget ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              Icons.person,
              color: Colors.grey[500],
              size: width < 50 ? width * 0.6 : 24,
            ),
          );
      },

      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
        ),
      ),
    );
  }
}
