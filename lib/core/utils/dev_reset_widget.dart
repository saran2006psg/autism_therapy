import 'package:flutter/material.dart';
import '../utils/app_reset_utility.dart';

/// Development utility widget to quickly reset app data
/// This should only be used during development and testing
class DevResetWidget extends StatelessWidget {
  const DevResetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Development Reset',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clear all login data and reset the app for fresh authentication testing',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await AppResetUtility.performQuickLogout();
                  if (context.mounted) {
                    AppResetUtility.navigateToLoginScreen(context);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Quick Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  AppResetUtility.resetAndNavigateToLogin(
                    context,
                    preserveTheme: true,
                    showConfirmationDialog: false,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Full Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Floating action button for quick app reset (development only)
class DevResetFAB extends StatelessWidget {
  const DevResetFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Development Reset'),
            content: const DevResetWidget(),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.refresh),
      label: const Text('Reset'),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }
}
