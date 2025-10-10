import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';

/// Admin screen for system administration and user management
/// Used for creating test users and managing system data
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isCreatingUsers = false;

  /// Create test users for development/demo purposes
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
        role: 'Therapist',
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
      if (mounted) {
        setState(() {
          _isCreatingUsers = false;
        });
      }
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 20.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 3.h),
              Text(
                'Admin Panel',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Create test users for development and testing',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Parent Test User'),
                        subtitle: const Text('muni@gmail.com / muni123'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.medical_services),
                        title: const Text('Therapist Test User'),
                        subtitle: const Text('math@gmail.com / math123'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: _isCreatingUsers ? null : _createTestUsers,
                icon: _isCreatingUsers
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(_isCreatingUsers ? 'Creating Users...' : 'Create Test Users'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
