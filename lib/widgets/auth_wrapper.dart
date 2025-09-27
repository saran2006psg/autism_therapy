import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:thriveers/core/app_export.dart';
import 'package:thriveers/presentation/login_screen/login_screen.dart';
import 'package:thriveers/presentation/parent_dashboard/parent_dashboard.dart';
import 'package:thriveers/presentation/therapist_dashboard/therapist_dashboard.dart';

/// Authentication wrapper that determines which screen to show based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // If user is not authenticated, show login screen
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // User is authenticated, determine which dashboard to show
        return FutureBuilder<String?>(
          future: _getUserRole(snapshot.data!.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading user profile...'),
                    ],
                  ),
                ),
              );
            }

            final userRole = roleSnapshot.data?.toLowerCase() ?? 'parent';
            
            // Route based on user role
            if (userRole == 'therapist') {
              return const TherapistDashboard();
            } else {
              return const ParentDashboard();
            }
          },
        );
      },
    );
  }

  /// Get user role from Firestore
  Future<String?> _getUserRole(String userId) async {
    try {
      final userDoc = await FirestoreService.getUserProfile(userId);
      return userDoc?['role'] as String?;
    } catch (e) {
      // If we can't get the role, default to parent
      return 'parent';
    }
  }
}