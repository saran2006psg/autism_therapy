import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:thriveers/core/app_export.dart';

/// Reusable widget for displaying user profile information
/// Automatically updates when profile changes via DataService
class UserProfileWidget extends StatelessWidget {
  final double? radius;
  final bool showName;
  final bool showEmail;
  final TextStyle? nameStyle;
  final TextStyle? emailStyle;
  final Widget? fallbackWidget;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final MainAxisAlignment? alignment;
  
  const UserProfileWidget({
    super.key,
    this.radius,
    this.showName = false,
    this.showEmail = false,
    this.nameStyle,
    this.emailStyle,
    this.fallbackWidget,
    this.backgroundColor,
    this.padding,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final profile = dataService.currentUserProfile;
        final displayName = profile?['displayName'] as String? ?? 'User';
        final email = profile?['email'] as String? ?? '';
        final avatarUrl = dataService.currentUserAvatarUrl;

        if (!showName && !showEmail) {
          // Just show avatar
          return CircleAvatar(
            radius: radius ?? 20,
            backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(radius ?? 20),
                    child: Image.network(
                      avatarUrl,
                      width: (radius ?? 20) * 2,
                      height: (radius ?? 20) * 2,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return fallbackWidget ?? CustomIconWidget(
                          iconName: 'person',
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        );
                      },
                    ),
                  )
                : fallbackWidget ?? CustomIconWidget(
                    iconName: 'person',
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
          );
        }

        // Show avatar with text info
        return Container(
          padding: padding,
          child: Column(
            mainAxisAlignment: alignment ?? MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: radius ?? 20,
                backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(radius ?? 20),
                        child: Image.network(
                          avatarUrl,
                          width: (radius ?? 20) * 2,
                          height: (radius ?? 20) * 2,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return fallbackWidget ?? CustomIconWidget(
                              iconName: 'person',
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            );
                          },
                        ),
                      )
                    : fallbackWidget ?? CustomIconWidget(
                        iconName: 'person',
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
              ),
              if (showName) ...[
                SizedBox(height: 1.h),
                Text(
                  displayName,
                  style: nameStyle ?? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (showEmail) ...[
                SizedBox(height: 0.5.h),
                Text(
                  email,
                  style: emailStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Horizontal layout variant
class UserProfileRowWidget extends StatelessWidget {
  final double? avatarRadius;
  final bool showEmail;
  final TextStyle? nameStyle;
  final TextStyle? emailStyle;
  final Widget? fallbackWidget;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? spacing;
  
  const UserProfileRowWidget({
    super.key,
    this.avatarRadius,
    this.showEmail = false,
    this.nameStyle,
    this.emailStyle,
    this.fallbackWidget,
    this.backgroundColor,
    this.padding,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final profile = dataService.currentUserProfile;
        final displayName = profile?['displayName'] as String? ?? 'User';
        final email = profile?['email'] as String? ?? '';
        final avatarUrl = dataService.currentUserAvatarUrl;

        return Container(
          padding: padding,
          child: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius ?? 16,
                backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(avatarRadius ?? 16),
                        child: Image.network(
                          avatarUrl,
                          width: (avatarRadius ?? 16) * 2,
                          height: (avatarRadius ?? 16) * 2,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return fallbackWidget ?? CustomIconWidget(
                              iconName: 'person',
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              size: (avatarRadius ?? 16) * 0.8,
                            );
                          },
                        ),
                      )
                    : fallbackWidget ?? CustomIconWidget(
                        iconName: 'person',
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: (avatarRadius ?? 16) * 0.8,
                      ),
              ),
              SizedBox(width: spacing ?? 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: nameStyle ?? Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (showEmail) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        email,
                        style: emailStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}