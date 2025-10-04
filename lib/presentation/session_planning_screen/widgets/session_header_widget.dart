import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';

class SessionHeaderWidget extends StatelessWidget {
  final String studentName;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int sessionDuration;
  final int plannedActivities;
  final int plannedMinutes;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final ValueChanged<int> onDurationChanged;

  const SessionHeaderWidget({
    super.key,
    required this.studentName,
    required this.selectedDate,
    required this.selectedTime,
    required this.sessionDuration,
    required this.onDateTap,
    required this.onTimeTap,
    required this.onDurationChanged,
    this.plannedActivities = 0,
    this.plannedMinutes = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final plannedRatio =
        sessionDuration == 0 ? 0.0 : plannedMinutes / sessionDuration;
    final isOverbooked = plannedMinutes > sessionDuration;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.5.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.45),
                    colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -32,
              top: -48,
              child: _buildAccentCircle(colorScheme.primary),
            ),
            Positioned(
              left: -40,
              bottom: -62,
              child: _buildAccentCircle(colorScheme.secondary),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.5.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
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
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.32),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'person',
                            color: colorScheme.onPrimary,
                            size: 6.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Session for',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 0.6.h),
                            Text(
                              studentName,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 3.w),
                      _buildActivityBadge(context),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context: context,
                          icon: 'calendar_today',
                          label: 'Date',
                          value: _formatDate(selectedDate),
                          onTap: onDateTap,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildInfoCard(
                          context: context,
                          icon: 'access_time',
                          label: 'Time',
                          value: _formatTime(selectedTime),
                          onTap: onTimeTap,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.5.h),
                  _buildDurationSelector(context),
                  _buildPlanningSummary(
                    context: context,
                    utilization: plannedRatio,
                    isOverbooked: isOverbooked,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'playlist_add_check',
            color: colorScheme.primary,
            size: 4.2.w,
          ),
          SizedBox(width: 1.5.w),
          Text(
            '$plannedActivities activities',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: EdgeInsets.all(3.5.w),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(1.8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: icon,
                      color: colorScheme.primary,
                      size: 4.w,
                    ),
                  ),
                  SizedBox(width: 2.2.w),
                  Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.3.h),
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final durations = [30, 45, 60, 90, 120];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'timer',
              color: colorScheme.primary,
              size: 4.5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Session duration',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.5.w,
          runSpacing: 1.2.h,
          children: durations.map((duration) {
            final isSelected = sessionDuration == duration;
            return GestureDetector(
              onTap: () => onDurationChanged(duration),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.symmetric(
                  horizontal: 4.5.w,
                  vertical: 1.3.h,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.78),
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : colorScheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : colorScheme.outline.withValues(alpha: 0.22),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  '$duration min',
                  style: textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlanningSummary({
    required BuildContext context,
    required double utilization,
    required bool isOverbooked,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final clampedUtilization = utilization.clamp(0.0, 1.0);
    final remainingMinutes =
        (sessionDuration - plannedMinutes).clamp(0, sessionDuration);
    final utilizationPercent = (clampedUtilization * 100).round();

    return Container(
      margin: EdgeInsets.only(top: 3.h),
      padding: EdgeInsets.all(3.8.w),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 2.w,
            runSpacing: 1.4.h,
            children: [
              _buildSummaryPill(
                context: context,
                label: 'Activities',
                value: '$plannedActivities',
              ),
              _buildSummaryPill(
                context: context,
                label: 'Planned minutes',
                value: '$plannedMinutes',
              ),
              _buildSummaryPill(
                context: context,
                label: isOverbooked ? 'Overbooked' : 'Time remaining',
                value: isOverbooked
                    ? '+${plannedMinutes - sessionDuration} min'
                    : '$remainingMinutes min',
                highlight: isOverbooked,
              ),
            ],
          ),
          SizedBox(height: 2.2.h),
          Text(
            'Session utilization',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: clampedUtilization,
              minHeight: 0.9.h,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.08),
              semanticsLabel: 'Session utilization',
              semanticsValue: '$utilizationPercent% scheduled',
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverbooked ? colorScheme.error : colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            isOverbooked
                ? 'Over by ${plannedMinutes - sessionDuration} min • consider trimming the agenda.'
                : '$plannedMinutes of $sessionDuration min scheduled • $remainingMinutes min free.',
            style: textTheme.labelSmall?.copyWith(
              color: isOverbooked
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill({
    required BuildContext context,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.1.h),
      decoration: BoxDecoration(
        color: highlight
            ? colorScheme.error.withValues(alpha: 0.15)
            : colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: highlight
              ? colorScheme.error.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: highlight
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            value,
            style: textTheme.labelLarge?.copyWith(
              color: highlight
                  ? colorScheme.error
                  : colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccentCircle(Color color) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
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
