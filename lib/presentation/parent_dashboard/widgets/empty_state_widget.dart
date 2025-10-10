import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final String iconName;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    required this.iconName,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            constraints: const BoxConstraints(
              maxWidth: 140,
              maxHeight: 140,
              minWidth: 100,
              minHeight: 100,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.15),
                  colorScheme.secondary.withOpacity(0.15),
                  colorScheme.tertiary.withOpacity(0.10),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 22.w,
                height: 22.w,
                constraints: const BoxConstraints(
                  maxWidth: 80,
                  maxHeight: 80,
                  minWidth: 60,
                  minHeight: 60,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(iconName),
                  color: Colors.white,
                  size: 12.w.clamp(32.0, 40.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.4.h),
          Container(
            constraints: BoxConstraints(maxWidth: 80.w),
            child: Text(
              description,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.75),
                height: 1.5,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onAction != null && actionText != null) ...[
            SizedBox(height: 5.h),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.2.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                label: Text(
                  actionText!,
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'family_restroom': return Icons.family_restroom_rounded;
      case 'child_care': return Icons.child_care_rounded;
      case 'group': return Icons.group_rounded;
      case 'person': return Icons.person_rounded;
      case 'info': return Icons.info_outline_rounded;
      case 'warning': return Icons.warning_amber_rounded;
      case 'error': return Icons.error_outline_rounded;
      case 'check': return Icons.check_circle_outline_rounded;
      default: return Icons.info_outline_rounded;
    }
  }
}
