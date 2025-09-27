import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:thriveers/widgets/theme_toggle_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          _buildSectionHeader('Appearance'),
          _buildThemeSection(context),
          
          SizedBox(height: 4.h),
          _buildSectionHeader('Preferences'),
          _buildPreferencesSection(context),
          
          SizedBox(height: 4.h),
          _buildSectionHeader('About'),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ThemeToggleWidget(
            showLabel: true,
            isListTile: true,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme Options'),
            subtitle: const Text('Choose from light, dark, or system default'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => ThemeOptionsDialog.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Manage your notification preferences'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle notification toggle
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Handle language selection
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.accessibility_outlined),
            title: const Text('Accessibility'),
            subtitle: const Text('Font size, contrast, and more'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Handle accessibility settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.info_outlined),
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Handle privacy policy
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Handle terms of service
            },
          ),
        ],
      ),
    );
  }
}
