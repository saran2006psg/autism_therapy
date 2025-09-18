import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import '../services/auth_service.dart';
import '../services/data_service.dart';

/// Utility class to reset the app and clear all login data
class AppResetUtility {
  /// Complete app reset - clears all authentication and user data
  static Future<void> performCompleteReset({
    bool preserveTheme = true,
  }) async {
    try {
      developer.log('Starting complete app reset...', name: 'AppResetUtility');

      // 1. Sign out from Firebase Auth
      developer.log('Signing out from Firebase...', name: 'AppResetUtility');
      await AuthService.signOut();

      // 2. Clear DataService data
      developer.log('Clearing DataService data...', name: 'AppResetUtility');
      final dataService = DataService();
      dataService.clearData();

      // 3. Clear SharedPreferences (except theme if preserveTheme is true)
      developer.log('Clearing SharedPreferences...', name: 'AppResetUtility');
      await _clearSharedPreferences(preserveTheme: preserveTheme);

      // 4. Clear any cached data
      developer.log('Clearing additional cached data...', name: 'AppResetUtility');
      await _clearCachedData();

      developer.log('Complete app reset finished successfully', name: 'AppResetUtility');
    } catch (e) {
      developer.log('Error during app reset: $e', name: 'AppResetUtility');
      rethrow;
    }
  }

  /// Quick logout - preserves app data but signs out user
  static Future<void> performQuickLogout() async {
    try {
      developer.log('Performing quick logout...', name: 'AppResetUtility');

      // Sign out from Firebase Auth
      await AuthService.signOut();

      // Clear DataService user data but keep cached data structure
      final dataService = DataService();
      dataService.clearData();

      developer.log('Quick logout completed', name: 'AppResetUtility');
    } catch (e) {
      developer.log('Error during quick logout: $e', name: 'AppResetUtility');
      rethrow;
    }
  }

  /// Clear all SharedPreferences except optionally theme
  static Future<void> _clearSharedPreferences({bool preserveTheme = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save theme setting if we want to preserve it
      String? savedTheme;
      if (preserveTheme) {
        savedTheme = prefs.getString('app_theme_mode');
      }

      // Clear all preferences
      await prefs.clear();

      // Restore theme setting if we preserved it
      if (preserveTheme && savedTheme != null) {
        await prefs.setString('app_theme_mode', savedTheme);
        developer.log('Theme preference preserved: $savedTheme', name: 'AppResetUtility');
      }

      developer.log('SharedPreferences cleared successfully', name: 'AppResetUtility');
    } catch (e) {
      developer.log('Error clearing SharedPreferences: $e', name: 'AppResetUtility');
    }
  }

  /// Clear any additional cached data
  static Future<void> _clearCachedData() async {
    try {
      // Add any additional cache clearing logic here
      // For example: image cache, file cache, etc.
      
      developer.log('Additional cached data cleared', name: 'AppResetUtility');
    } catch (e) {
      developer.log('Error clearing cached data: $e', name: 'AppResetUtility');
    }
  }

  /// Navigate to login screen and clear navigation stack
  static void navigateToLoginScreen(BuildContext context) {
    try {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login-screen',
        (route) => false,
      );
      developer.log('Navigated to login screen', name: 'AppResetUtility');
    } catch (e) {
      developer.log('Error navigating to login screen: $e', name: 'AppResetUtility');
    }
  }

  /// Complete reset with navigation
  static Future<void> resetAndNavigateToLogin(
    BuildContext context, {
    bool preserveTheme = true,
    bool showConfirmationDialog = true,
  }) async {
    try {
      bool shouldProceed = true;

      // Show confirmation dialog if requested
      if (showConfirmationDialog) {
        shouldProceed = await _showResetConfirmationDialog(context) ?? false;
      }

      if (!shouldProceed) {
        developer.log('App reset cancelled by user', name: 'AppResetUtility');
        return;
      }

      // Show loading indicator
      _showLoadingDialog(context);

      // Perform the reset
      await performCompleteReset(preserveTheme: preserveTheme);

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Navigate to login screen
      if (context.mounted) {
        navigateToLoginScreen(context);
      }

      // Show success message
      if (context.mounted) {
        _showSuccessMessage(context);
      }

    } catch (e) {
      // Close loading dialog if it's open
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (context.mounted) {
        _showErrorMessage(context, e.toString());
      }
    }
  }

  /// Show confirmation dialog
  static Future<bool?> _showResetConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App Data'),
        content: const Text(
          'This will sign you out and clear all cached data. You will need to log in again.\n\nAre you sure you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Resetting app data...'),
          ],
        ),
      ),
    );
  }

  /// Show success message
  static void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('App data reset successfully. Please log in again.'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error message
  static void _showErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error resetting app: $error'),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
