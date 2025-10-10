import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CompletedActivitiesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final Widget Function(Map<String, dynamic>) buildActivityCard;
  final VoidCallback onViewAll;

  const CompletedActivitiesWidget({
    super.key,
    required this.activities,
    required this.buildActivityCard,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Filter completed activities
    final List<Map<String, dynamic>> completedActivities = [];
    
    for (final activity in activities) {
      final status = activity['status'] as String? ?? '';
      final completedAt = activity['completedAt'];
      
      if (status == 'completed' && completedAt != null) {
        completedActivities.add(Map<String, dynamic>.from(activity));
      }
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completed Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${completedActivities.length} of ${activities.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          if (completedActivities.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'No completed activities yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ...completedActivities.take(3).map(buildActivityCard),
            
          if (completedActivities.length > 3)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Center(
                child: TextButton(
                  onPressed: onViewAll,
                  child: Text('View All ${completedActivities.length} Completed Activities'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
