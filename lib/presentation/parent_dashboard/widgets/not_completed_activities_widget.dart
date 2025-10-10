import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class NotCompletedActivitiesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final Widget Function(Map<String, dynamic>) buildActivityCard;
  final VoidCallback onViewAll;

  const NotCompletedActivitiesWidget({
    super.key,
    required this.activities,
    required this.buildActivityCard,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Filter not completed activities
    final List<Map<String, dynamic>> notStartedActivities = [];
    final List<Map<String, dynamic>> inProgressActivities = [];
    
    for (final activity in activities) {
      final status = activity['status'] as String? ?? 'not_started';
      final completedAt = activity['completedAt'];
      
      if (status == 'completed' && completedAt != null) continue;
      
      final activityCopy = Map<String, dynamic>.from(activity);
      
      if (status == 'in_progress') {
        inProgressActivities.add(activityCopy);
      } else if (status == 'not_started') {
        notStartedActivities.add(activityCopy);
      }
    }
    
    final notCompletedActivities = [...inProgressActivities, ...notStartedActivities];

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
                'To-Do Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${notCompletedActivities.length} of ${activities.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          if (notCompletedActivities.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'All activities completed!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ...notCompletedActivities.take(3).map(buildActivityCard),
            
          if (notCompletedActivities.length > 3)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Center(
                child: TextButton(
                  onPressed: onViewAll,
                  child: Text('View All ${notCompletedActivities.length} To-Do Activities'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
