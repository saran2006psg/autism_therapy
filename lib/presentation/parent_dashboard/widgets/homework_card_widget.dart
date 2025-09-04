import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HomeworkCardWidget extends StatefulWidget {
  final Map<String, dynamic> homeworkData;
  final Function(String, bool) onCompletionChanged;
  final Function(String) onPhotoUpload;

  const HomeworkCardWidget({
    super.key,
    required this.homeworkData,
    required this.onCompletionChanged,
    required this.onPhotoUpload,
  });

  @override
  State<HomeworkCardWidget> createState() => _HomeworkCardWidgetState();
}

class _HomeworkCardWidgetState extends State<HomeworkCardWidget> {
  @override
  Widget build(BuildContext context) {
    final activities = widget.homeworkData["activities"] as List;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Homework",
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "Due: ${widget.homeworkData["dueDate"] as String}",
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            widget.homeworkData["title"] as String,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            widget.homeworkData["description"] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            "Activities (${_getCompletedCount(activities)}/${activities.length} completed)",
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 1.h),
          ...activities.map((activity) {
            final activityData = activity as Map<String, dynamic>;
            return _buildActivityItem(activityData);
          }),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _getCompletionPercentage(activities),
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.secondary,
                  ),
                  minHeight: 6,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                "${(_getCompletionPercentage(activities) * 100).toInt()}%",
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                "Assigned by ${widget.homeworkData["assignedBy"] as String}",
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (widget.homeworkData["requiresEvidence"] as bool)
                TextButton.icon(
                  onPressed: () =>
                      widget.onPhotoUpload(widget.homeworkData["id"] as String),
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 16,
                  ),
                  label: Text(
                    "Add Photo",
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activityData) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: CheckboxListTile(
        value: activityData["completed"] as bool,
        onChanged: (bool? value) {
          if (value != null) {
            setState(() {
              activityData["completed"] = value;
            });
            widget.onCompletionChanged(activityData["id"] as String, value);
          }
        },
        title: Text(
          activityData["title"] as String,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            decoration: (activityData["completed"] as bool)
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: activityData["description"] != null
            ? Text(
                activityData["description"] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  decoration: (activityData["completed"] as bool)
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              )
            : null,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
        activeColor: AppTheme.lightTheme.colorScheme.secondary,
        checkColor: AppTheme.lightTheme.colorScheme.surface,
      ),
    );
  }

  int _getCompletedCount(List activities) {
    return activities
        .where((activity) =>
            (activity as Map<String, dynamic>)["completed"] as bool)
        .length;
  }

  double _getCompletionPercentage(List activities) {
    if (activities.isEmpty) return 0.0;
    return _getCompletedCount(activities) / activities.length;
  }
}
