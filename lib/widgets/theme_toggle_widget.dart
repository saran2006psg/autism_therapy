import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_export.dart';

/// A widget that provides theme switching functionality
/// Can be used as an icon button in app bars or as a list tile in settings
class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final bool isListTile;
  
  const ThemeToggleWidget({
    super.key,
    this.showLabel = false,
    this.isListTile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        if (isListTile) {
          return _buildListTile(context, themeManager);
        } else {
          return _buildIconButton(context, themeManager);
        }
      },
    );
  }

  Widget _buildIconButton(BuildContext context, ThemeManager themeManager) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: child,
          );
        },
        child: Icon(
          themeManager.themeIcon,
          key: ValueKey(themeManager.themeMode),
        ),
      ),
      onPressed: () => themeManager.toggleTheme(),
      tooltip: 'Switch to ${themeManager.isDarkMode ? 'Light' : 'Dark'} mode',
    );
  }

  Widget _buildListTile(BuildContext context, ThemeManager themeManager) {
    return ListTile(
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          themeManager.themeIcon,
          key: ValueKey(themeManager.themeMode),
        ),
      ),
      title: Text(themeManager.themeDescription),
      subtitle: Text(
        themeManager.isDarkMode 
          ? 'Better for low-light environments'
          : 'Better for bright environments',
      ),
      trailing: Switch(
        value: themeManager.isDarkMode,
        onChanged: (_) => themeManager.toggleTheme(),
      ),
      onTap: () => themeManager.toggleTheme(),
    );
  }
}

/// A more advanced theme selector with three options (Light, Dark, System)
class ThemeOptionsDialog extends StatelessWidget {
  const ThemeOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context: context,
                themeManager: themeManager,
                mode: ThemeMode.light,
                icon: Icons.light_mode_outlined,
                title: 'Light Mode',
                subtitle: 'Best for bright environments',
              ),
              _buildThemeOption(
                context: context,
                themeManager: themeManager,
                mode: ThemeMode.dark,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Better for low-light environments',
              ),
              _buildThemeOption(
                context: context,
                themeManager: themeManager,
                mode: ThemeMode.system,
                icon: Icons.brightness_auto_outlined,
                title: 'System Default',
                subtitle: 'Follow device settings',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeManager themeManager,
    required ThemeMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = themeManager.themeMode == mode;
    
    return Card(
      color: isSelected 
        ? Theme.of(context).colorScheme.primaryContainer
        : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
            ? Theme.of(context).colorScheme.primary
            : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected 
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
        onTap: () async {
          switch (mode) {
            case ThemeMode.light:
              await themeManager.setLightTheme();
              break;
            case ThemeMode.dark:
              await themeManager.setDarkTheme();
              break;
            case ThemeMode.system:
              await themeManager.setSystemTheme();
              break;
          }
        },
      ),
    );
  }

  /// Show the theme options dialog
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const ThemeOptionsDialog(),
    );
  }
}
