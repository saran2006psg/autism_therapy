import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class AddStudentForm extends StatefulWidget {
  const AddStudentForm({super.key});

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _communicationController = TextEditingController();
  final _sensoryNeedsController = TextEditingController();
  
  String _selectedGender = 'Male';
  String _selectedSeverity = 'mild';
  DateTime? _selectedDateOfBirth;
  final List<String> _triggers = [];
  final _triggerController = TextEditingController();
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _severityOptions = ['mild', 'moderate', 'severe'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _diagnosisController.dispose();
    _communicationController.dispose();
    _sensoryNeedsController.dispose();
    _triggerController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        // Calculate age
        final age = DateTime.now().difference(picked).inDays ~/ 365;
        _ageController.text = age.toString();
      });
    }
  }

  void _addTrigger() {
    if (_triggerController.text.trim().isNotEmpty) {
      setState(() {
        _triggers.add(_triggerController.text.trim());
        _triggerController.clear();
      });
    }
  }

  void _removeTrigger(int index) {
    setState(() {
      _triggers.removeAt(index);
    });
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current therapist ID
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      AppLogger.info('Creating student for therapist: ${currentUser.uid}', name: 'AddStudentForm');

      final student = StudentModel(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text),
        dateOfBirth: _selectedDateOfBirth!,
        gender: _selectedGender,
        diagnosis: _diagnosisController.text.trim(),
        communicationLevel: _communicationController.text.trim(),
        sensoryNeeds: _sensoryNeedsController.text.trim(),
        severity: _selectedSeverity,
        triggers: _triggers,
        therapistId: currentUser.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AppLogger.debug('Student data: ${student.toFirestore()}', name: 'AddStudentForm');

      // Save to Firestore
      final studentId = await FirestoreService.createStudent(student);
      AppLogger.info('Student created with ID: $studentId', name: 'AddStudentForm');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${student.fullName} added successfully!'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding student: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Student',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (_isLoading)
            Container(
              margin: EdgeInsets.only(right: 4.w),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveStudent,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionTitle('Basic Information'),
              SizedBox(height: 2.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 3.h),
              
              // Date of Birth and Age
              InkWell(
                onTap: _selectDateOfBirth,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .transparent30,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        _selectedDateOfBirth == null
                            ? 'Select Date of Birth'
                            : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: _selectedDateOfBirth == null
                              ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              : AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      keyboardType: TextInputType.number,
                      enabled: false, // Auto-calculated from date of birth
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Gender',
                      value: _selectedGender,
                      items: _genderOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Medical Information
              _buildSectionTitle('Medical Information'),
              SizedBox(height: 2.h),

              _buildTextField(
                controller: _diagnosisController,
                label: 'Diagnosis',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter diagnosis';
                  }
                  return null;
                },
              ),

              SizedBox(height: 3.h),

              _buildDropdown(
                label: 'Severity',
                value: _selectedSeverity,
                items: _severityOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedSeverity = value!;
                  });
                },
              ),

              SizedBox(height: 3.h),

              _buildTextField(
                controller: _communicationController,
                label: 'Communication Level',
                maxLines: 2,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter communication level';
                  }
                  return null;
                },
              ),

              SizedBox(height: 3.h),

              _buildTextField(
                controller: _sensoryNeedsController,
                label: 'Sensory Needs',
                maxLines: 2,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter sensory needs';
                  }
                  return null;
                },
              ),

              SizedBox(height: 4.h),

              // Triggers
              _buildSectionTitle('Triggers'),
              SizedBox(height: 2.h),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _triggerController,
                      decoration: InputDecoration(
                        labelText: 'Add Trigger',
                        hintText: 'e.g., loud noises, being rushed',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .transparent30,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _addTrigger(),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  IconButton(
                    onPressed: _addTrigger,
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary
                          .transparent10,
                    ),
                  ),
                ],
              ),

              if (_triggers.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: _triggers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final trigger = entry.value;
                    return Chip(
                      label: Text(trigger),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeTrigger(index),
                      backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                      ),
                    );
                  }).toList(),
                ),
              ],

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline
                .transparent30,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline
                .transparent30,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.error,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline
                .transparent10,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline
                .transparent30,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline
                .transparent30,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
