import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RoleIndicatorWidget extends StatelessWidget {
  final String? userRole;
  final bool isVisible;

  const RoleIndicatorWidget({
    super.key,
    this.userRole,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || userRole == null) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(top: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _getRoleColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRoleColor(context),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: _getRoleIcon(),
            color: _getRoleColor(context),
            size: 18,
          ),
          SizedBox(width: 2.w),
          Text(
            'Logged in as $userRole',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _getRoleColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(BuildContext context) {
    switch (userRole?.toLowerCase()) {
      case 'therapist':
        return Theme.of(context).colorScheme.primary;
      case 'parent':
        return Theme.of(context).colorScheme.secondary;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  String _getRoleIcon() {
    switch (userRole?.toLowerCase()) {
      case 'therapist':
        return 'medical_services';
      case 'parent':
        return 'family_restroom';
      default:
        return 'person';
    }
  }
}
