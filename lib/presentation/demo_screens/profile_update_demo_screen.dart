import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thriveers/core/app_export.dart';
import 'package:thriveers/widgets/user_profile_widget.dart';

/// Demo screen showing reactive profile updates across multiple widgets
class ProfileUpdateDemoScreen extends StatelessWidget {
  const ProfileUpdateDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Update Demo'),
        actions: const [
          // Profile widget in app bar that auto-updates
          UserProfileWidget(radius: 16),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Multiple Profile Widgets - All Auto-Update:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Card with profile info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Profile Card', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    UserProfileWidget(
                      radius: 30,
                      showName: true,
                      showEmail: true,
                      nameStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Horizontal profile widget
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Horizontal Layout', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    UserProfileRowWidget(
                      avatarRadius: 20,
                      showEmail: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Multiple small avatars
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Multiple Avatars', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const UserProfileWidget(radius: 25),
                            const SizedBox(height: 8),
                            Text('Small', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        Column(
                          children: [
                            const UserProfileWidget(radius: 35),
                            const SizedBox(height: 8),
                            Text('Medium', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        Column(
                          children: [
                            const UserProfileWidget(radius: 45),
                            const SizedBox(height: 8),
                            Text('Large', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Update button
            Consumer<DataService>(
              builder: (context, dataService, child) {
                return Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Demo profile update - all widgets above will update automatically
                          try {
                            await dataService.updateMyProfile({
                              'displayName': 'Updated User ${DateTime.now().millisecond}',
                            });
                            
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated! All widgets auto-refreshed!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Update failed: $e')),
                            );
                          }
                        },
                        child: const Text('Test Profile Name Update'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Current: ${dataService.currentUserProfile?['displayName'] ?? 'No name'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}