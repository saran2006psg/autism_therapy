import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SessionHeaderWidget extends StatelessWidget {
  final String studentName;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int sessionDuration;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final Function(int) onDurationChanged;

  const SessionHeaderWidget({
    super.key,
    required this.studentName,
    required this.selectedDate,
    required this.selectedTime,
    required this.sessionDuration,
    required this.onDateTap,
    required this.onTimeTap,
    required this.onDurationChanged,
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
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session for',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      studentName,
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: 'calendar_today',
                  label: 'Date',
                  value: _formatDate(selectedDate),
                  onTap: onDateTap,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildInfoCard(
                  icon: 'access_time',
                  label: 'Time',
                  value: _formatTime(selectedTime),
                  onTap: onTimeTap,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildDurationSelector(),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: icon,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    label,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    final durations = [30, 45, 60, 90, 120];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'timer',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Session Duration',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: durations.map((duration) {
            final isSelected = sessionDuration == duration;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onDurationChanged(duration),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '$duration min',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
