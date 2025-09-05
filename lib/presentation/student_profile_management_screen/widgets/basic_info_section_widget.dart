import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BasicInfoSectionWidget extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController ageController;
  final TextEditingController dateOfBirthController;
  final String? selectedGender;
  final Function(String?) onGenderChanged;
  final VoidCallback onDateOfBirthTap;

  const BasicInfoSectionWidget({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.ageController,
    required this.dateOfBirthController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onDateOfBirthTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'person',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      hintText: 'Enter first name',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      hintText: 'Enter last name',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age *',
                      hintText: 'Enter age',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Age is required';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 1 || age > 100) {
                        return 'Enter valid age (1-100)';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender *',
                      hintText: 'Select gender',
                    ),
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: onGenderChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Gender is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: dateOfBirthController,
              decoration: InputDecoration(
                labelText: 'Date of Birth *',
                hintText: 'Select date of birth',
                suffixIcon: CustomIconWidget(
                  iconName: 'calendar_today',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              readOnly: true,
              onTap: onDateOfBirthTap,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Date of birth is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}


