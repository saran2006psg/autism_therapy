import 'package:flutter/material.dart';

/// Utility extension for migrating from Color.withOpacity() to Color.withValues()
/// This provides a seamless transition for the new Flutter color API
extension ColorMigration on Color {
  /// Modern replacement for withOpacity() using withValues()
  /// 
  /// Usage:
  /// ```dart
  /// // Old way (deprecated)
  /// color.withValues(alpha: 0.5)
  /// 
  /// // New way
  /// color.withAlpha(0.5)
  /// ```
  Color withAlpha(double alpha) {
    assert(alpha >= 0.0 && alpha <= 1.0, 'Alpha value must be between 0.0 and 1.0');
    return withValues(alpha: alpha);
  }
  
  /// Helper method for creating transparent versions of colors
  /// with common opacity values
  Color get transparent05 => withAlpha(0.05);
  Color get transparent10 => withAlpha(0.1);
  Color get transparent20 => withAlpha(0.2);
  Color get transparent30 => withAlpha(0.3);
  Color get transparent40 => withAlpha(0.4);
  Color get transparent50 => withAlpha(0.5);
  Color get transparent60 => withAlpha(0.6);
  Color get transparent70 => withAlpha(0.7);
  Color get transparent80 => withAlpha(0.8);
  Color get transparent90 => withAlpha(0.9);
}

/// Utility class for creating common color variants
class ColorUtils {
  /// Create a color with specified opacity using the new API
  static Color withOpacity(Color color, double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'Opacity value must be between 0.0 and 1.0');
    return color.withValues(alpha: opacity);
  }
  
  /// Create a lighter version of a color
  static Color lighten(Color color, double amount) {
    assert(amount >= 0.0 && amount <= 1.0, 'Amount must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Create a darker version of a color
  static Color darken(Color color, double amount) {
    assert(amount >= 0.0 && amount <= 1.0, 'Amount must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
