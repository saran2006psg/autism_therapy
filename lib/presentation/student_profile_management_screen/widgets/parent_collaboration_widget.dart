import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';

class ParentCollaborationWidget extends StatefulWidget {
  final List<Map<String, dynamic>> parentAccess;
  final Map<String, bool> communicationPreferences;
  final void Function(Map<String, dynamic>) onParentAdded;
  final void Function(String, bool) onPreferenceChanged;

  const ParentCollaborationWidget({
    super.key,
    required this.parentAccess,
    required this.communicationPreferences,
    required this.onParentAdded,
    required this.onPreferenceChanged,
  });

  @override
  State<ParentCollaborationWidget> createState() =>
      _ParentCollaborationWidgetState();
}

class _ParentCollaborationWidgetState extends State<ParentCollaborationWidget> {
  bool _isExpanded = false;

  void _showAddParentDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRelation = 'Parent';
    final List<String> selectedPermissions = ['View Progress', 'View Session Notes'];

    showModalBottomSheet<void>(
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
                    'Add Parent/Guardian Access',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 3.h),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter parent/guardian name',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address *',
                      hintText: 'Enter email address',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter phone number',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedRelation,
                          decoration: const InputDecoration(
                            labelText: 'Relationship',
                          ),
                          items: ['Parent', 'Guardian', 'Caregiver', 'Other']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedRelation = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Access Permissions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 1.h),
                  ...[
                    'View Progress',
                    'View Session Notes',
                    'View Goals',
                    'Receive Notifications',
                    'Download Reports'
                  ].map((permission) {
                    final isSelected = selectedPermissions.contains(permission);
                    return CheckboxListTile(
                      title: Text(
                        permission,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      value: isSelected,
                      onChanged: (value) {
                        setModalState(() {
                          if (value == true) {
                            selectedPermissions.add(permission);
                          } else {
                            selectedPermissions.remove(permission);
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
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
                            if (nameController.text.trim().isNotEmpty &&
                                emailController.text.trim().isNotEmpty) {
                              final newParent = {
                                'id': DateTime.now().millisecondsSinceEpoch,
                                'name': nameController.text.trim(),
                                'email': emailController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'relationship': selectedRelation,
                                'permissions': selectedPermissions,
                                'status': 'Pending Invitation',
                                'addedDate': DateTime.now(),
                              };
                              widget.onParentAdded(newParent);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Send Invitation'),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Theme.of(context).colorScheme.tertiary;
      case 'pending invitation':
        return Theme.of(context).colorScheme.secondary;
      case 'inactive':
        return Theme.of(context).colorScheme.onSurfaceVariant;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
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
            iconName: 'family_restroom',
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'Parent Collaboration',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _showAddParentDialog,
                icon: CustomIconWidget(
                  iconName: 'person_add',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Communication Preferences
                  Text(
                    'Communication Preferences',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            'Email Notifications',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            'Send progress updates via email',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          value: widget.communicationPreferences[
                                  'emailNotifications'] ??
                              true,
                          onChanged: (value) => widget.onPreferenceChanged(
                              'emailNotifications', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: Text(
                            'Weekly Reports',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            'Automatic weekly progress reports',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          value: widget
                                  .communicationPreferences['weeklyReports'] ??
                              true,
                          onChanged: (value) => widget.onPreferenceChanged(
                              'weeklyReports', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: Text(
                            'Session Reminders',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            'Remind parents about upcoming sessions',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          value: widget.communicationPreferences[
                                  'sessionReminders'] ??
                              false,
                          onChanged: (value) => widget.onPreferenceChanged(
                              'sessionReminders', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Parent Access List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shared Access (${widget.parentAccess.length})',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  widget.parentAccess.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            children: [
                              CustomIconWidget(
                                iconName: 'family_restroom_outlined',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 48,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'No parent access granted yet',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Tap the + button to invite parents/guardians',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.parentAccess.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 2.h),
                          itemBuilder: (context, index) {
                            final parent = widget.parentAccess[index];

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
                                      CircleAvatar(
                                        radius: 6.w,
                                        backgroundColor: AppTheme
                                            .lightTheme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        child: CustomIconWidget(
                                          iconName: 'person',
                                          color: AppTheme
                                              .lightTheme.colorScheme.primary,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (parent['name'] ?? '').toString(),
                                              style: AppTheme.lightTheme
                                                  .textTheme.titleMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              (parent['relationship'] as String?) ?? '',
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                color: AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.w, vertical: 0.5.h),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                                  (parent['status'] as String?) ?? '')
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          (parent['status'] as String?) ?? '',
                                          style: AppTheme
                                              .lightTheme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: _getStatusColor(
                                                (parent['status'] as String?) ?? ''),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),
                                  Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'email',
                                        color: Theme.of(context).colorScheme
                                            .onSurfaceVariant,
                                        size: 16,
                                      ),
                                      SizedBox(width: 1.w),
                                      Expanded(
                                        child: Text(
                                          (parent['email'] as String?) ?? '',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (parent['phone']?.toString().isNotEmpty ?? false) ...[
                                    SizedBox(height: 0.5.h),
                                    Row(
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'phone',
                                          color: Theme.of(context).colorScheme
                                              .onSurfaceVariant,
                                          size: 16,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          (parent['phone'] as String?) ?? '',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (parent['permissions'] != null &&
                                      (parent['permissions'] as List)
                                          .isNotEmpty) ...[
                                    SizedBox(height: 1.h),
                                    Wrap(
                                      spacing: 1.w,
                                      runSpacing: 0.5.h,
                                      children: (parent['permissions'] as List)
                                          .map<Widget>((permission) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.5.w,
                                              vertical: 0.3.h),
                                          decoration: BoxDecoration(
                                            color: AppTheme
                                                .lightTheme.colorScheme.tertiary
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            permission.toString(),
                                            style: AppTheme
                                                .lightTheme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: AppTheme.lightTheme
                                                  .colorScheme.tertiary,
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


