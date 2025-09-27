import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';

class TherapyDetailsSectionWidget extends StatefulWidget {
  final TextEditingController diagnosisController;
  final TextEditingController triggersController;
  final TextEditingController communicationController;
  final TextEditingController sensoryController;
  final String? selectedSeverity;
  final Function(String?) onSeverityChanged;

  const TherapyDetailsSectionWidget({
    super.key,
    required this.diagnosisController,
    required this.triggersController,
    required this.communicationController,
    required this.sensoryController,
    required this.selectedSeverity,
    required this.onSeverityChanged,
  });

  @override
  State<TherapyDetailsSectionWidget> createState() =>
      _TherapyDetailsSectionWidgetState();
}

class _TherapyDetailsSectionWidgetState
    extends State<TherapyDetailsSectionWidget> {
  bool _isExpanded = true;

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
            iconName: 'psychology',
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'Therapy-Specific Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: widget.diagnosisController,
                    decoration: const InputDecoration(
                      labelText: 'Diagnosis Details *',
                      hintText: 'Enter detailed diagnosis information',
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Diagnosis details are required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  DropdownButtonFormField<String>(
                    value: widget.selectedSeverity,
                    decoration: const InputDecoration(
                      labelText: 'Severity Level *',
                      hintText: 'Select severity level',
                    ),
                    items: [
                      'Level 1 - Requiring Support',
                      'Level 2 - Requiring Substantial Support',
                      'Level 3 - Requiring Very Substantial Support'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: widget.onSeverityChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Severity level is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: widget.triggersController,
                    decoration: const InputDecoration(
                      labelText: 'Behavioral Triggers',
                      hintText: 'List known behavioral triggers',
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: widget.communicationController,
                    decoration: const InputDecoration(
                      labelText: 'Communication Preferences',
                      hintText: 'Describe communication style and preferences',
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: widget.sensoryController,
                    decoration: const InputDecoration(
                      labelText: 'Sensory Considerations',
                      hintText: 'Note sensory sensitivities and preferences',
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
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


