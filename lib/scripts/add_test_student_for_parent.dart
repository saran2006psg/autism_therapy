// Quick script to add test student data for parent account
// Run this from Flutter console or add as admin function

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thriveers/core/models/student_model.dart';

Future<void> addTestStudentForParent() async {
  try {
    // Get the parent user ID for muni@gmail.com
    final parentUser = FirebaseAuth.instance.currentUser;
    if (parentUser == null || parentUser.email != 'muni@gmail.com') {
      print('Please login as muni@gmail.com first');
      return;
    }

    final parentId = parentUser.uid;
    print('Creating test student for parent ID: $parentId');

    // Create a test student
    final testStudent = {
      'firstName': 'Emma',
      'lastName': 'Johnson',
      'age': 8,
      'dateOfBirth': Timestamp.fromDate(DateTime(2015, 5, 15)),
      'grade': '3rd Grade',
      'diagnosis': 'Autism Spectrum Disorder',
      'parentIds': [parentId], // Link to parent
      'therapistId': '', // Will be assigned by therapist
      'communicationLevel': 'Verbal with support',
      'socialSkills': 'Developing',
      'cognitiveAbilities': 'Age-appropriate',
      'sensoryNeeds': 'Sensitivity to loud sounds',
      'severity': 'Moderate',
      'triggers': ['Sudden changes', 'Loud noises'],
      'emergencyContacts': [
        {
          'name': 'Muni Johnson',
          'relationship': 'Parent',
          'phone': '(555) 123-4567'
        }
      ],
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Add to Firestore
    final docRef = await FirebaseFirestore.instance
        .collection('students')
        .add(testStudent);

    print('Test student created with ID: ${docRef.id}');
    print('Student Emma Johnson added for parent muni@gmail.com');
    
  } catch (e) {
    print('Error creating test student: $e');
  }
}