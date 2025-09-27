import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

/// Script to set up test users with proper roles
/// Run with: dart run scripts/setup_test_users.dart
Future<void> main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Setting up test users...');

    // Create test users
    await _createTestUser(
      email: 'math@gmail.com',
      password: 'math123',
      name: 'Dr. Math Therapist',
      role: 'therapist',
    );

    await _createTestUser(
      email: 'muni@gmail.com',
      password: 'muni123',
      name: 'Muni Parent',
      role: 'parent',
    );

    await _createTestUser(
      email: 'student@example.com',
      password: 'student123',
      name: 'Test Student',
      role: 'student',
    );

    print('All test users created successfully!');
  } catch (e) {
    print('Error setting up test users: $e');
  }
}

Future<void> _createTestUser({
  required String email,
  required String password,
  required String name,
  required String role,
}) async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    print('Creating user: $email ($role)');

    // Check if user already exists
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      print('User $email already exists, updating profile...');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // Create new user
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Created new user: $email');
      } else {
        throw e;
      }
    }

    final user = auth.currentUser;
    if (user != null) {
      // Update display name
      await user.updateDisplayName(name);

      // Create/update user profile in Firestore
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'role': role,
        'displayName': name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✓ User profile created/updated for $email');

      // Sign out after creating
      await auth.signOut();
    }
  } catch (e) {
    print('✗ Error creating user $email: $e');
  }
}