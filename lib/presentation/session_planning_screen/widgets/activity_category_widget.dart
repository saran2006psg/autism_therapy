import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './activity_card_widget.dart';

class ActivityCategoryWidget extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> activities;
  final Function(Map<String, dynamic>) onActivityTap;

  const ActivityCategoryWidget({
    super.key,
    required this.categoryName,
    required this.activities,
    required this.onActivityTap,
  });

  @override
  State<ActivityCategoryWidget> createState() => _ActivityCategoryWidgetState();
}

class _ActivityCategoryWidgetState extends State<ActivityCategoryWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: _getCategoryIcon(),
                          color: _getCategoryColor(),
                          size: 5.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.categoryName,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${widget.activities.length} activities available',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 6.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Column(
                    children: [
                      Divider(
                        height: 1,
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                      ...widget.activities.map((activity) {
                        return ActivityCardWidget(
                          activity: activity,
                          onTap: () => widget.onActivityTap(activity),
                        );
                      }),
                      SizedBox(height: 2.h),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.categoryName.toLowerCase()) {
      case 'communication skills':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'social interaction':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'behavioral training':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'sensory integration':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getCategoryIcon() {
    switch (widget.categoryName.toLowerCase()) {
      case 'communication skills':
        return 'chat_bubble_outline';
      case 'social interaction':
        return 'groups';
      case 'behavioral training':
        return 'psychology';
      case 'sensory integration':
        return 'touch_app';
      default:
        return 'category';
    }
  }
}
