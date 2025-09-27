import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Command line utility to reset all app data
/// Run with: dart run lib/scripts/reset_app_data.dart
void main() async {
  if (kDebugMode) {
    print('🔄 Starting app data reset...');
  }
  
  try {
    // Initialize Firebase (if needed - commented out for now)
    // print('📱 Initializing Firebase...');
    // await Firebase.initializeApp();
    
    // Sign out from Firebase Auth
    if (kDebugMode) {
      print('🚪 Signing out from Firebase Auth...');
    }
    try {
      await FirebaseAuth.instance.signOut();
      if (kDebugMode) {
        print('✅ Firebase Auth sign out completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️  Firebase Auth sign out error (might be already signed out): $e');
      }
    }
    
    // Clear SharedPreferences
    if (kDebugMode) {
      print('🗂️  Clearing SharedPreferences...');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save theme setting to preserve it
      final savedTheme = prefs.getString('app_theme_mode');
      
      // Clear all preferences
      await prefs.clear();
      
      // Restore theme setting
      if (savedTheme != null) {
        await prefs.setString('app_theme_mode', savedTheme);
        if (kDebugMode) {
          print('🎨 Theme preference preserved: $savedTheme');
        }
      }
      
      if (kDebugMode) {
        print('✅ SharedPreferences cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing SharedPreferences: $e');
      }
    }
    
    // Clear any cached files (optional)
    if (kDebugMode) {
      print('📁 Clearing additional cache...');
    }
    // Add any additional cleanup here if needed
    
    if (kDebugMode) {
      print('');
    }
    if (kDebugMode) {
      print('🎉 App data reset completed successfully!');
    }
    if (kDebugMode) {
      print('');
    }
    if (kDebugMode) {
      print('Next steps:');
    }
    

    
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error during reset: $e');
    }
    exit(1);
  }
}
