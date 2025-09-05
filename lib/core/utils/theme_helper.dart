import 'package:flutter/material.dart';

/// Helper class to easily access current theme colors and text styles
/// This ensures proper dark/light mode support throughout the app
class ThemeHelper {
  /// Get the current theme from context
  static ThemeData theme(BuildContext context) => Theme.of(context);
  
  /// Get the current color scheme
  static ColorScheme colorScheme(BuildContext context) => Theme.of(context).colorScheme;
  
  /// Get the current text theme
  static TextTheme textTheme(BuildContext context) => Theme.of(context).textTheme;
  
  /// Check if current theme is dark mode
  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  
  /// Get scaffold background color that adapts to theme
  static Color scaffoldBackground(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  
  /// Get card color that adapts to theme
  static Color cardColor(BuildContext context) => Theme.of(context).cardColor;
  
  /// Get divider color that adapts to theme
  static Color dividerColor(BuildContext context) => Theme.of(context).dividerColor;
  
  /// Get app bar theme that adapts to current theme
  static AppBarTheme appBarTheme(BuildContext context) => Theme.of(context).appBarTheme;
  
  /// Get elevated button theme that adapts to current theme
  static ElevatedButtonThemeData elevatedButtonTheme(BuildContext context) => Theme.of(context).elevatedButtonTheme;
}
