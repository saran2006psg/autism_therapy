import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:thriveers/core/app_export.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isCreatingUsers = false;

  Future<void> _createTestUsers() async {
    setState(() {
      _isCreatingUsers = true;
    });

    try {
      // Create parent user
      final parentResult = await AuthService.createUserWithEmailAndPassword(
        email: 'muni@gmail.com',
        password: 'muni123',
        name: 'Muni Parent',
        role: 'Parent',
      );

      if (parentResult.success) {
        AppLogger.info('Parent user created successfully', name: 'AdminScreen');
      } else {
        AppLogger.error('Failed to create parent user: ${parentResult.errorMessage}', name: 'AdminScreen');
      }

      // Create therapist user  
      final therapistResult = await AuthService.createUserWithEmailAndPassword(
        email: 'math@gmail.com',
        password: 'math123',
        name: 'Dr. Math Therapist',
      );

      if (therapistResult.success) {
        AppLogger.info('Therapist user created successfully', name: 'AdminScreen');
      } else {
        AppLogger.error('Failed to create therapist user: ${therapistResult.errorMessage}', name: 'AdminScreen');
      }

      // Sign out after creating users
      await AuthService.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test users created successfully! You can now log in.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error creating test users: $e', name: 'AdminScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating test users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCreatingUsers = false;
      });
    }
  }

  Future<void> _createTestStudentData() async {
    setState(() {
      _isCreatingUsers = true;
    });

    try {
      // First, get the parent user from Firestore
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: 'muni@gmail.com')
          .limit(1)
          .get();

      if (usersQuery.docs.isEmpty) {
        throw Exception('Parent user muni@gmail.com not found. Please create test users first.');
      }

      final parentId = usersQuery.docs.first.id;

      // Create a test student linked to this parent
      final testStudent = {
        'firstName': 'Emma',
        'lastName': 'Johnson',
        'age': 8,
        'dateOfBirth': Timestamp.fromDate(DateTime(2015, 5, 15)),
        'grade': '3rd Grade',
        'diagnosis': 'Autism Spectrum Disorder',
        'parentIds': [parentId], // Link to parent
        'therapistId': '', // Will be assigned by therapist later
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
        'avatarUrl': '',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('students')
          .add(testStudent);

      AppLogger.info('Test student created with ID: ${docRef.id}', name: 'AdminScreen');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test student Emma Johnson created for parent muni@gmail.com!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error creating test student: $e', name: 'AdminScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating test student: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCreatingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 4.h),
            Text(
              'Admin Functions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Use this panel to set up test users and perform admin tasks.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 6.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCreatingUsers ? null : _createTestUsers,
                icon: _isCreatingUsers 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.people),
                label: Text(_isCreatingUsers ? 'Creating Users...' : 'Create Test Users'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCreatingUsers ? null : _createTestStudentData,
                icon: _isCreatingUsers 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.child_care),
                label: Text(_isCreatingUsers ? 'Creating Student...' : 'Create Test Student for Parent'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Card(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Accounts Created:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    const Text('• Parent: muni@gmail.com / muni123'),
                    const Text('• Therapist: math@gmail.com / math123'),
                    SizedBox(height: 1.h),
                    Text(
                      'Note: After creating users, create test student data for the parent.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}