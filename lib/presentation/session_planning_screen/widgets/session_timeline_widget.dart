import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SessionTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> plannedActivities;
  final int totalDuration;

  const SessionTimelineWidget({
    super.key,
    required this.plannedActivities,
    required this.totalDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'timeline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Session Timeline',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalDuration min',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (plannedActivities.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withOpacity(0.5),
                    size: 8.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No activities planned yet',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Drag activities from above to build your session',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            Container(
              height: 2.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.2),
              ),
              child: Row(
                children: _buildTimelineSegments(),
              ),
            ),
            SizedBox(height: 2.h),
            ...plannedActivities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              return _buildTimelineItem(activity, index);
            }),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildTimelineSegments() {
    if (plannedActivities.isEmpty || totalDuration == 0) return [];

    return plannedActivities.map((activity) {
      final duration = activity['duration'] as int? ?? 15;
      final percentage = duration / totalDuration;
      final color =
          _getActivityTypeColor(activity['type'] as String? ?? 'general');

      return Expanded(
        flex: (percentage * 100).round(),
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTimelineItem(Map<String, dynamic> activity, int index) {
    final duration = activity['duration'] as int? ?? 15;
    final name = activity['name'] as String? ?? 'Unknown Activity';
    final type = activity['type'] as String? ?? 'general';

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Container(
            width: 1.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: _getActivityTypeColor(type),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${index + 1}. $name',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$duration min',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _getActivityTypeLabel(type),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getActivityTypeColor(type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'communication':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'social':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'behavioral':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'sensory':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getActivityTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'communication':
        return 'Communication Skills';
      case 'social':
        return 'Social Interaction';
      case 'behavioral':
        return 'Behavioral Training';
      case 'sensory':
        return 'Sensory Integration';
      default:
        return 'General Activity';
    }
  }
}
