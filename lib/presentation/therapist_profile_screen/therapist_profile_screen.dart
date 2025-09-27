import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:thriveers/core/app_export.dart';
import 'package:thriveers/core/services/image_upload_service.dart';

class TherapistProfileScreen extends StatefulWidget {
  const TherapistProfileScreen({super.key});

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> {
  bool _isLoading = false;
  final DataService _dataService = DataService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDataService();
  }

  Future<void> _initializeDataService() async {
    try {
      if (!_dataService.isInitialized) {
        await _dataService.initialize();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if not initialized
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'My Profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final currentUserProfile = dataService.currentUserProfile;
        final displayName = currentUserProfile?['displayName'] as String? ?? 'Dr. Therapist';
        final avatarUrl = dataService.currentUserAvatarUrl;
        final email = currentUserProfile?['email'] as String? ?? 'therapist@example.com';
        
        return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _onEditMyProfile,
            icon: _isLoading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'edit',
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.transparent80,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.transparent30,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 12.w,
                    backgroundColor: Colors.white.transparent20,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : avatarUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12.w),
                                child: Image.network(
                                  avatarUrl,
                                  width: 24.w,
                                  height: 24.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const CustomIconWidget(
                                      iconName: 'person',
                                      color: Colors.white,
                                      size: 48,
                                    );
                                  },
                                ),
                              )
                            : const CustomIconWidget(
                                iconName: 'person',
                                color: Colors.white,
                                size: 48,
                              ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.transparent90,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.transparent20,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Autism Spectrum Therapist',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 4.h),
            
            // Profile Options
            _buildProfileOption(
              icon: 'person',
              title: 'Personal Information',
              subtitle: 'Update your profile details',
              onTap: () {
                // Navigate to personal info edit
              },
            ),
            
            _buildProfileOption(
              icon: 'security',
              title: 'Security & Privacy',
              subtitle: 'Manage password and privacy settings',
              onTap: () {
                // Navigate to security settings
              },
            ),
            
            _buildProfileOption(
              icon: 'notifications',
              title: 'Notifications',
              subtitle: 'Configure notification preferences',
              onTap: () {
                // Navigate to notification settings
              },
            ),
            
            _buildProfileOption(
              icon: 'help',
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {
                // Navigate to help
              },
            ),
            
            _buildProfileOption(
              icon: 'info',
              title: 'About',
              subtitle: 'App version and information',
              onTap: _showAboutDialog,
            ),
            
            SizedBox(height: 4.h),
            
            // Logout Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CustomIconWidget(
                            iconName: 'logout',
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Logout',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
      },
    );
  }

  Widget _buildProfileOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.transparent10,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(4.w),
        leading: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: CustomIconWidget(
          iconName: 'arrow_forward_ios',
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Thriveers'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Thriveers is designed to help therapists manage autism therapy sessions and track student progress.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onEditMyProfile() async {
    if (!_isInitialized || _dataService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile service not ready. Please try again.')),
      );
      return;
    }

    final currentName = _dataService.currentUserProfile?['displayName'] as String? ?? '';
    final controller = TextEditingController(text: currentName);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                ),
              ),
              SizedBox(height: 1.5.h),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _onChangeAvatarTapped,
                  icon: const CustomIconWidget(iconName: 'photo_camera'),
                  label: const Text('Change photo'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                Navigator.of(ctx).pop();
                if (newName.isEmpty) return;
                
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  // Update Firestore/profile store
                  await _dataService.updateMyProfile({'displayName': newName});
                  // Update Firebase Auth for immediate UI reflection
                  await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
                  await FirebaseAuth.instance.currentUser?.reload();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onChangeAvatarTapped() async {
    if (!_isInitialized || _dataService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile service not ready. Please try again.')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (picked == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final uid = _dataService.currentUserId!;
      
      // Show uploading message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uploading photo...'),
          duration: Duration(seconds: 3),
        ),
      );

      // Use the new web-compatible upload service
      final downloadUrl = await ImageUploadService.uploadUserAvatar(
        userId: uid,
        imageFile: picked,
      );

      // Update both Firestore and Firebase Auth
      await Future.wait([
        _dataService.updateMyProfile({'avatarUrl': downloadUrl}),
        FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl) ?? Future<void>.value(),
      ]);
      
      // Reload user to get updated data
      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update photo: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await AppResetUtility.resetAndNavigateToLogin(
        context,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}


