import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectivityStatusWidget extends StatelessWidget {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  const ConnectivityStatusWidget({
    super.key,
    required this.isOnline,
    required this.isSyncing,
    this.lastSyncTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSyncing
              ? SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_getStatusColor()),
                  ),
                )
              : CustomIconWidget(
                  iconName: _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 16,
                ),
          SizedBox(width: 2.w),
          Text(
            _getStatusText(),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (isSyncing) {
      return AppTheme.lightTheme.colorScheme.secondary;
    }
    return isOnline
        ? AppTheme.lightTheme.colorScheme.tertiary
        : AppTheme.lightTheme.colorScheme.error;
  }

  String _getStatusIcon() {
    if (isSyncing) {
      return 'sync';
    }
    return isOnline ? 'cloud_done' : 'cloud_off';
  }

  String _getStatusText() {
    if (isSyncing) {
      return 'Syncing...';
    }
    if (isOnline) {
      if (lastSyncTime != null) {
        final now = DateTime.now();
        final difference = now.difference(lastSyncTime!);
        if (difference.inMinutes < 1) {
          return 'Just synced';
        } else if (difference.inHours < 1) {
          return '${difference.inMinutes}m ago';
        } else if (difference.inDays < 1) {
          return '${difference.inHours}h ago';
        } else {
          return '${difference.inDays}d ago';
        }
      }
      return 'Online';
    }
    return 'Offline';
  }
}
