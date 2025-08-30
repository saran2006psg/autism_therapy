import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SessionControlsOverlayWidget extends StatelessWidget {
  final bool isSessionPaused;
  final VoidCallback? onPauseResume;
  final VoidCallback? onEmergencyStop;
  final VoidCallback? onQuickNotes;
  final VoidCallback? onEmergencyContact;

  const SessionControlsOverlayWidget({
    super.key,
    required this.isSessionPaused,
    this.onPauseResume,
    this.onEmergencyStop,
    this.onQuickNotes,
    this.onEmergencyContact,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12.h,
      right: 4.w,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "pause_resume",
            onPressed: onPauseResume,
            backgroundColor: isSessionPaused
                ? AppTheme.lightTheme.colorScheme.tertiary
                : AppTheme.lightTheme.colorScheme.secondary,
            child: CustomIconWidget(
              iconName: isSessionPaused ? 'play_arrow' : 'pause',
              color: AppTheme.lightTheme.colorScheme.onSecondary,
              size: 24,
            ),
          ),
          SizedBox(height: 2.h),
          FloatingActionButton(
            heroTag: "quick_notes",
            onPressed: onQuickNotes,
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            child: CustomIconWidget(
              iconName: 'note_add',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          SizedBox(height: 2.h),
          FloatingActionButton(
            heroTag: "emergency_stop",
            onPressed: onEmergencyStop,
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            child: CustomIconWidget(
              iconName: 'stop',
              color: AppTheme.lightTheme.colorScheme.onError,
              size: 24,
            ),
          ),
          SizedBox(height: 2.h),
          FloatingActionButton(
            heroTag: "emergency_contact",
            onPressed: onEmergencyContact,
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            child: CustomIconWidget(
              iconName: 'phone',
              color: AppTheme.lightTheme.colorScheme.onError,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
