import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmergencyContactWidget extends StatefulWidget {
  final TextEditingController primaryNameController;
  final TextEditingController primaryPhoneController;
  final TextEditingController primaryRelationController;
  final TextEditingController secondaryNameController;
  final TextEditingController secondaryPhoneController;
  final TextEditingController secondaryRelationController;
  final TextEditingController medicalAlertsController;

  const EmergencyContactWidget({
    super.key,
    required this.primaryNameController,
    required this.primaryPhoneController,
    required this.primaryRelationController,
    required this.secondaryNameController,
    required this.secondaryPhoneController,
    required this.secondaryRelationController,
    required this.medicalAlertsController,
  });

  @override
  State<EmergencyContactWidget> createState() => _EmergencyContactWidgetState();
}

class _EmergencyContactWidgetState extends State<EmergencyContactWidget> {
  bool _isExpanded = true;

  void _makePhoneCall(String phoneNumber) {
    if (phoneNumber.trim().isNotEmpty) {
      // In a real app, this would use url_launcher to make a phone call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling $phoneNumber...'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
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
            iconName: 'emergency',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 24,
          ),
          title: Text(
            'Emergency Contacts',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medical Alerts Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.error
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'medical_services',
                              color: AppTheme.lightTheme.colorScheme.error,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Medical Alerts',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          controller: widget.medicalAlertsController,
                          decoration: InputDecoration(
                            labelText: 'Medical Alerts & Allergies',
                            hintText:
                                'List any medical conditions, allergies, or medications',
                            fillColor: AppTheme.lightTheme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.error
                                    .withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.error
                                    .withOpacity(0.3),
                              ),
                            ),
                          ),
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Primary Contact
                  Text(
                    'Primary Contact',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: widget.primaryNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter primary contact name',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Primary contact name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: widget.primaryPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            hintText: 'Enter phone number',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _makePhoneCall(
                              widget.primaryPhoneController.text),
                          icon: CustomIconWidget(
                            iconName: 'phone',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 20,
                          ),
                          tooltip: 'Call Primary Contact',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: widget.primaryRelationController,
                    decoration: const InputDecoration(
                      labelText: 'Relationship *',
                      hintText: 'e.g., Parent, Guardian, Caregiver',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Relationship is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 3.h),

                  // Secondary Contact
                  Text(
                    'Secondary Contact (Optional)',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: widget.secondaryNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter secondary contact name',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: widget.secondaryPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter phone number',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        decoration: BoxDecoration(
                          color: widget.secondaryPhoneController.text
                                  .trim()
                                  .isNotEmpty
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: widget.secondaryPhoneController.text
                                  .trim()
                                  .isNotEmpty
                              ? () => _makePhoneCall(
                                  widget.secondaryPhoneController.text)
                              : null,
                          icon: CustomIconWidget(
                            iconName: 'phone',
                            color: widget.secondaryPhoneController.text
                                    .trim()
                                    .isNotEmpty
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          tooltip: 'Call Secondary Contact',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: widget.secondaryRelationController,
                    decoration: const InputDecoration(
                      labelText: 'Relationship',
                      hintText: 'e.g., Parent, Guardian, Caregiver',
                    ),
                    textCapitalization: TextCapitalization.words,
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
