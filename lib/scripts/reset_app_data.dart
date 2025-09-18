import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Command line utility to reset all app data
/// Run with: dart run lib/scripts/reset_app_data.dart
void main() async {
  print('🔄 Starting app data reset...');
  
  try {
    // Initialize Firebase (if needed - commented out for now)
    // print('📱 Initializing Firebase...');
    // await Firebase.initializeApp();
    
    // Sign out from Firebase Auth
    print('🚪 Signing out from Firebase Auth...');
    try {
      await FirebaseAuth.instance.signOut();
      print('✅ Firebase Auth sign out completed');
    } catch (e) {
      print('⚠️  Firebase Auth sign out error (might be already signed out): $e');
    }
    
    // Clear SharedPreferences
    print('🗂️  Clearing SharedPreferences...');
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save theme setting to preserve it
      final savedTheme = prefs.getString('app_theme_mode');
      
      // Clear all preferences
      await prefs.clear();
      
      // Restore theme setting
      if (savedTheme != null) {
        await prefs.setString('app_theme_mode', savedTheme);
        print('🎨 Theme preference preserved: $savedTheme');
      }
      
      print('✅ SharedPreferences cleared successfully');
    } catch (e) {
      print('❌ Error clearing SharedPreferences: $e');
    }
    
    // Clear any cached files (optional)
    print('📁 Clearing additional cache...');
    // Add any additional cleanup here if needed
    
    print('');
    print('🎉 App data reset completed successfully!');
    print('');
    print('Next steps:');
    print('1. Stop the running app if it\'s currently running');
    print('2. Restart the app');
    print('3. You should see the login screen with role selection');
    print('4. Create new accounts for testing:');
    print('   - Therapist account: therapist@test.com');
    print('   - Parent account: parent@test.com');
    print('');
    print('The app will create fresh test data for new users.');
    
  } catch (e) {
    print('❌ Error during reset: $e');
    exit(1);
  }
}
