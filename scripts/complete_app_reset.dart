#!/usr/bin/env dart

/// Complete app data reset utility
/// This script helps you clear all test data and start fresh with real authentication
/// 
/// Usage: dart scripts/complete_app_reset.dart

import 'dart:io';

Future<void> main() async {
  print('🔥 ThrivEers Complete App Reset Utility\n');
  print('This will help you clear all test data and start fresh.\n');

  // Step 1: App Reset Instructions
  print('📋 STEP 1: Clear App Data');
  print('Run the app reset utility to clear authentication:');
  print('   1. Open the app in your browser');
  print('   2. Look for the "DEV RESET" button (if available)');
  print('   3. Or manually logout all users\n');

  // Step 2: Firebase Console Instructions
  print('🔥 STEP 2: Clear Firebase Data');
  print('Go to Firebase Console and clear collections:');
  print('   1. Open Firebase Console > Firestore Database');
  print('   2. Delete documents from these collections:');
  print('      - students (all test student documents)');
  print('      - sessions (sessions linked to test students)');
  print('      - goals (goals linked to test students)');
  print('      - users (if you want to clear test user accounts)');
  print('   3. Keep the collections but delete the documents\n');

  // Step 3: Browser Cache
  print('🌐 STEP 3: Clear Browser Data');
  print('Clear browser cache and data:');
  print('   1. Open Chrome DevTools (F12)');
  print('   2. Go to Application tab > Storage');
  print('   3. Click "Clear site data"');
  print('   4. Or use Incognito/Private browsing mode\n');

  // Step 4: Authentication Reset
  print('🔐 STEP 4: Reset Authentication');
  print('Clear Firebase Auth data:');
  print('   1. Firebase Console > Authentication');
  print('   2. Delete test user accounts if needed');
  print('   3. Or use different email addresses for testing\n');

  // Step 5: Verification Steps
  print('✅ STEP 5: Verification');
  print('After clearing data, verify the clean state:');
  print('   1. Restart the app (flutter run)');
  print('   2. Login as therapist - should see "No students yet"');
  print('   3. Add a real student through the + button');
  print('   4. Login as parent - should see only linked children\n');

  // Create automated cleanup script
  await createAutomatedCleanupScript();
  
  print('🎯 Quick Reset Commands:');
  print('   dart scripts/automated_firebase_cleanup.dart  # Requires Firebase setup');
  print('   dart scripts/reset_app_data.ps1              # Browser cache cleanup\n');

  print('📝 Next Steps:');
  print('   1. Follow the steps above in order');
  print('   2. Create fresh therapist account: therapist@example.com');
  print('   3. Create fresh parent account: parent@example.com');
  print('   4. Add student with parent email link');
  print('   5. Verify parent can see their children\n');

  print('✨ The app will then show only real, registered students!');
}

Future<void> createAutomatedCleanupScript() async {
  final script = '''
#!/usr/bin/env dart

/// Automated Firebase cleanup script
/// Run this after setting up Firebase Admin SDK

import 'dart:io';

// This is a template script - requires Firebase Admin SDK setup
Future<void> main() async {
  print('🔥 Automated Firebase Cleanup');
  print('⚠️  This script requires Firebase Admin SDK setup');
  print('📋 To enable this script:');
  print('   1. Add Firebase Admin SDK to pubspec.yaml');
  print('   2. Download service account key from Firebase Console');
  print('   3. Set GOOGLE_APPLICATION_CREDENTIALS environment variable');
  print('   4. Uncomment the cleanup code below\\n');

  /*
  // Uncomment this section after Firebase Admin setup:
  
  import 'package:firebase_admin/firebase_admin.dart';
  
  final admin = FirebaseAdmin.instance;
  final firestore = admin.firestore();
  
  print('🗑️  Deleting test students...');
  
  // Delete students with test names
  final testNames = ['Jacob Thompson', 'Michael Chen', 'Sarah Williams', 'Zoe Patel', 
                     'Aiden Rodriguez', 'Emma Johnson'];
  
  for (final name in testNames) {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      final query = firestore.collection('students')
          .where('firstName', isEqualTo: nameParts[0])
          .where('lastName', isEqualTo: nameParts[1]);
          
      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        print('Deleting student: \${doc.data()['firstName']} \${doc.data()['lastName']}');
        await doc.reference.delete();
      }
    }
  }
  
  print('✅ Cleanup complete!');
  */
  
  print('\\n🎯 Manual cleanup recommended for now.');
}
''';

  await File('scripts/automated_firebase_cleanup.dart').writeAsString(script);
  print('📄 Created: scripts/automated_firebase_cleanup.dart');
}
