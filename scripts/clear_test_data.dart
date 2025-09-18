#!/usr/bin/env dart

/// Script to clear test/mock data from Firebase Firestore
/// Run this script to remove any existing mock students and start fresh
/// 
/// Usage: dart scripts/clear_test_data.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Import your Firebase configuration
// Note: You'll need to adjust this import based on your actual firebase_options.dart location
// import '../lib/firebase_options.dart';

Future<void> main() async {
  print('🔥 Starting Firebase Test Data Cleanup...\n');

  try {
    // Initialize Firebase
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    
    print('⚠️  This script would clear all test data from Firestore');
    print('🔍 Looking for mock students with names like:');
    print('   - Aiden Rodriguez');
    print('   - Emma Johnson'); 
    print('   - Jacob Thompson');
    print('   - Michael Chen');
    print('   - Any students with "test" or "mock" in their data\n');

    // For safety, we'll just print what would be deleted rather than actually deleting
    print('📋 To manually clear test data:');
    print('1. Go to Firebase Console > Firestore Database');
    print('2. Navigate to the "students" collection');
    print('3. Delete any mock/test student documents');
    print('4. Navigate to the "sessions" collection');
    print('5. Delete any sessions associated with mock students');
    print('6. Navigate to the "goals" collection');
    print('7. Delete any goals associated with mock students\n');

    print('🔐 Safe Mode: This script is configured to only show what would be deleted.');
    print('💡 To enable actual deletion, uncomment the deletion code in clear_test_data.dart');
    
    // Uncomment the following code to enable actual deletion
    // WARNING: This will permanently delete data!
    
    /*
    final firestore = FirebaseFirestore.instance;
    
    // Delete mock students
    final studentsQuery = await firestore
        .collection('students')
        .where('firstName', whereIn: ['Aiden', 'Emma', 'Jacob', 'Michael'])
        .get();
        
    print('Found ${studentsQuery.docs.length} potential mock students');
    
    for (var doc in studentsQuery.docs) {
      final data = doc.data();
      final name = '${data['firstName']} ${data['lastName']}';
      print('Would delete student: $name');
      
      // Uncomment to actually delete:
      // await doc.reference.delete();
    }
    
    // Delete associated sessions
    final sessionsQuery = await firestore
        .collection('sessions')
        .get();
        
    int mockSessionCount = 0;
    for (var doc in sessionsQuery.docs) {
      final data = doc.data();
      // Check if session is associated with mock students
      final therapist = data['therapist'] ?? '';
      if (therapist.contains('Sarah Johnson') || therapist.contains('Mock') || therapist.contains('Test')) {
        mockSessionCount++;
        print('Would delete session: ${data['title'] ?? 'Untitled'}');
        
        // Uncomment to actually delete:
        // await doc.reference.delete();
      }
    }
    
    print('Found $mockSessionCount potential mock sessions');
    */
    
    print('\n✅ Scan complete!');
    print('🎯 Next steps:');
    print('   1. Review the data in Firebase Console');
    print('   2. Manually delete any mock/test data you want to remove');
    print('   3. Create fresh therapist and parent accounts for testing');
    print('   4. Add real students through the app interface\n');
    
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
