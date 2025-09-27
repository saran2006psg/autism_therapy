import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';

class GoalsSectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> goals;
  final Function(Map<String, dynamic>) onGoalAdded;
  final Function(int, Map<String, dynamic>) onGoalUpdated;
  final Function(int) onGoalDeleted;

  const GoalsSectionWidget({
    super.key,
    required this.goals,
    required this.onGoalAdded,
    required this.onGoalUpdated,
    required this.onGoalDeleted,
  });

  @override
  State<GoalsSectionWidget> createState() => _GoalsSectionWidgetState();
}

class _GoalsSectionWidgetState extends State<GoalsSectionWidget> {
  bool _isExpanded = true;

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Communication';
    String selectedPriority = 'Medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 4.w,
                right: 4.w,
                top: 2.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 12.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Add New Goal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 3.h),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Title *',
                      hintText: 'Enter goal title',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter goal description',
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: [
                            'Communication',
                            'Social Skills',
                            'Behavioral',
                            'Academic',
                            'Motor Skills',
                            'Self-Care'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                          ),
                          items: ['High', 'Medium', 'Low'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedPriority = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.trim().isNotEmpty) {
                              final newGoal = {
                                'id': DateTime.now().millisecondsSinceEpoch,
                                'title': titleController.text.trim(),
                                'description':
                                    descriptionController.text.trim(),
                                'category': selectedCategory,
                                'priority': selectedPriority,
                                'progress': 0.0,
                                'status': 'Active',
                                'createdDate': DateTime.now(),
                                'targetDate':
                                    DateTime.now().add(const Duration(days: 30)),
                              };
                              widget.onGoalAdded(newGoal);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Add Goal'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Theme.of(context).colorScheme.error;
      case 'Medium':
        return Theme.of(context).colorScheme.secondary;
      case 'Low':
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          leading: CustomIconWidget(
            iconName: 'flag',
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'Therapy Goals (${widget.goals.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _showAddGoalDialog,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              CustomIconWidget(
                iconName: _isExpanded ? 'expand_less' : 'expand_more',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: widget.goals.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'flag_outlined',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 48,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No goals added yet',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Tap the + button to add therapy goals',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.goals.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 2.h),
                      itemBuilder: (context, index) {
                        final goal = widget.goals[index];
                        final progress = goal['progress'] as double? ?? 0.0;

                        return Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      (goal['title'] as String?) ?? '',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(
                                              (goal['priority'] as String?) ?? 'Medium')
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      (goal['priority'] as String?) ?? 'Medium',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: _getPriorityColor(
                                            (goal['priority'] as String?) ?? 'Medium'),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (goal['description'] != null &&
                                  (goal['description'] as String)
                                      .isNotEmpty) ...[
                                SizedBox(height: 1.h),
                                Text(
                                  (goal['description'] as String?) ?? '',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: Theme.of(context).colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Progress',
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall,
                                            ),
                                            Text(
                                              '${(progress * 100).toInt()}%',
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 0.5.h),
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: AppTheme
                                              .lightTheme.colorScheme.outline
                                              .withValues(alpha: 0.2),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppTheme
                                                .lightTheme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    (goal['category'] as String?) ?? '',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


