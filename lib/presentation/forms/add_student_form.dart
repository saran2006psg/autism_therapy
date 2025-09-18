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
  final _parentEmailController = TextEditingController();
  final _studentEmailController = TextEditingController();
  final _studentPasswordController = TextEditingController();
  
  String _selectedGender = 'Male';
  String _selectedSeverity = 'mild';
  DateTime? _selectedDateOfBirth;
  final List<String> _triggers = [];
  final _triggerController = TextEditingController();
  bool _isLoading = false;
  bool _createStudentAccount = false;

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
    _parentEmailController.dispose();
    _studentEmailController.dispose();
    _studentPasswordController.dispose();
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

      // Find parent user ID by email if provided
      List<String> parentIds = [];
      if (_parentEmailController.text.trim().isNotEmpty) {
        try {
          final parentEmail = _parentEmailController.text.trim().toLowerCase();
          final parentUserId = await FirestoreService.getUserIdByEmail(parentEmail);
          if (parentUserId != null) {
            parentIds.add(parentUserId);
            AppLogger.info('Found parent user: $parentEmail -> $parentUserId', name: 'AddStudentForm');
          } else {
            AppLogger.warning('Parent user not found for email: $parentEmail', name: 'AddStudentForm');
            // Show warning but continue with student creation
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Warning: Parent account not found for $parentEmail. Student will be created without parent link.'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        } catch (e) {
          AppLogger.error('Error finding parent user: $e', name: 'AddStudentForm', error: e);
          // Continue with student creation even if parent lookup fails
        }
      }

      // Create student Firebase Auth account if requested
      String? studentUserId;
      if (_createStudentAccount) {
        try {
          final studentEmail = _studentEmailController.text.trim();
          final studentPassword = _studentPasswordController.text.trim();
          
          AppLogger.info('Creating Firebase Auth account for student: $studentEmail', name: 'AddStudentForm');
          
          final authResult = await AuthService.createUserWithEmailAndPassword(
            email: studentEmail,
            password: studentPassword,
            name: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
            role: 'Student',
          );
          
          if (authResult.success && authResult.user != null) {
            studentUserId = authResult.user!.uid;
            AppLogger.info('Student Firebase Auth account created: $studentUserId', name: 'AddStudentForm');
          } else {
            throw Exception('Failed to create student authentication account: ${authResult.errorMessage}');
          }
        } catch (e) {
          AppLogger.error('Error creating student auth account: $e', name: 'AddStudentForm', error: e);
          throw Exception('Failed to create student login account: $e');
        }
      }

      final student = StudentModel(
        id: studentUserId, // Use the Firebase Auth UID if account was created
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
        parentIds: parentIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AppLogger.debug('Student data: ${student.toFirestore()}', name: 'AddStudentForm');

      // Save to Firestore
      final studentId = await FirestoreService.createStudent(student);
      AppLogger.info('Student created with ID: $studentId', name: 'AddStudentForm');

      if (mounted) {
        String successMessage = '${student.fullName} added successfully!';
        if (parentIds.isNotEmpty) {
          successMessage += ' Parent account linked.';
        } else if (_parentEmailController.text.trim().isNotEmpty) {
          successMessage += ' (Parent account not found - will need to register)';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding student: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Student',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.outline
                          .transparent30,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        _selectedDateOfBirth == null
                            ? 'Select Date of Birth'
                            : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _selectedDateOfBirth == null
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface,
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

              SizedBox(height: 3.h),

              // Parent Email Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.transparent30,
                  ),
                ),
                child: TextFormField(
                  controller: _parentEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Parent Email (Optional)',
                    hintText: 'Enter parent\'s email to link accounts',
                    prefixIcon: CustomIconWidget(
                      iconName: 'email',
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                  ),
                  validator: (value) {
                    if (value?.trim().isNotEmpty ?? false) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value!.trim())) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null; // Optional field, so null is valid
                  },
                ),
              ),

              SizedBox(height: 4.h),

              // Student Account Creation Section
              _buildSectionTitle('Student Account (Optional)'),
              SizedBox(height: 2.h),
              
              // Checkbox to enable student account creation
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.transparent30,
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(
                    'Create student login account',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    'Allow student to log in and access their activities',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _createStudentAccount,
                  onChanged: (value) {
                    setState(() {
                      _createStudentAccount = value ?? false;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              if (_createStudentAccount) ...[
                SizedBox(height: 3.h),
                _buildTextField(
                  controller: _studentEmailController,
                  label: 'Student Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (_createStudentAccount && (value?.trim().isEmpty ?? true)) {
                      return 'Please enter student email';
                    }
                    if (value?.trim().isNotEmpty ?? false) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value!.trim())) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 3.h),
                _buildTextField(
                  controller: _studentPasswordController,
                  label: 'Student Password',
                  validator: (value) {
                    if (_createStudentAccount && (value?.trim().isEmpty ?? true)) {
                      return 'Please enter student password';
                    }
                    if (_createStudentAccount && (value?.length ?? 0) < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ],

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
                            color: Theme.of(context).colorScheme.outline
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary
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
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
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
            color: Theme.of(context).colorScheme.outline
                .transparent30,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline
                .transparent30,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline
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
            color: Theme.of(context).colorScheme.outline
                .transparent30,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline
                .transparent30,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
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



