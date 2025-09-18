import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/basic_info_section_widget.dart';
import './widgets/emergency_contact_widget.dart';
import './widgets/goals_section_widget.dart';
import './widgets/notes_section_widget.dart';
import './widgets/parent_collaboration_widget.dart';
import './widgets/session_history_widget.dart';
import './widgets/student_photo_widget.dart';
import './widgets/therapy_details_section_widget.dart';

class StudentProfileManagementScreen extends StatefulWidget {
  const StudentProfileManagementScreen({super.key});

  @override
  State<StudentProfileManagementScreen> createState() =>
      _StudentProfileManagementScreenState();
}

class _StudentProfileManagementScreenState
    extends State<StudentProfileManagementScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hasUnsavedChanges = false;
  bool _isLoading = false;
  final bool _isOnline = true;

  // Basic Information Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  String? _selectedGender;
  String? _selectedImagePath;

  // Therapy Details Controllers
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _triggersController = TextEditingController();
  final TextEditingController _communicationController =
      TextEditingController();
  final TextEditingController _sensoryController = TextEditingController();
  String? _selectedSeverity;

  // Emergency Contact Controllers
  final TextEditingController _primaryNameController = TextEditingController();
  final TextEditingController _primaryPhoneController = TextEditingController();
  final TextEditingController _primaryRelationController =
      TextEditingController();
  final TextEditingController _secondaryNameController =
      TextEditingController();
  final TextEditingController _secondaryPhoneController =
      TextEditingController();
  final TextEditingController _secondaryRelationController =
      TextEditingController();
  final TextEditingController _medicalAlertsController =
      TextEditingController();

  // Dynamic Data Lists
  List<Map<String, dynamic>> _goals = [];
  List<Map<String, dynamic>> _sessionHistory = [];
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _parentAccess = [];
  final Map<String, bool> _communicationPreferences = {
    'emailNotifications': true,
    'weeklyReports': true,
    'sessionReminders': false,
  };

  @override
  void initState() {
    super.initState();
    _setupChangeListeners();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _dateOfBirthController.dispose();
    _diagnosisController.dispose();
    _triggersController.dispose();
    _communicationController.dispose();
    _sensoryController.dispose();
    _primaryNameController.dispose();
    _primaryPhoneController.dispose();
    _primaryRelationController.dispose();
    _secondaryNameController.dispose();
    _secondaryPhoneController.dispose();
    _secondaryRelationController.dispose();
    _medicalAlertsController.dispose();
  }

  void _setupChangeListeners() {
    final controllers = [
      _firstNameController,
      _lastNameController,
      _ageController,
      _dateOfBirthController,
      _diagnosisController,
      _triggersController,
      _communicationController,
      _sensoryController,
      _primaryNameController,
      _primaryPhoneController,
      _primaryRelationController,
      _secondaryNameController,
      _secondaryPhoneController,
      _secondaryRelationController,
      _medicalAlertsController,
    ];

    for (final controller in controllers) {
      controller.addListener(() {
        if (!_hasUnsavedChanges) {
          setState(() {
            _hasUnsavedChanges = true;
          });
        }
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015, 3, 15),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme,
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
        _hasUnsavedChanges = true;
      });
    }
  }

  void _onImageSelected(String? imagePath) {
    setState(() {
      _selectedImagePath = imagePath;
      _hasUnsavedChanges = true;
    });
  }

  void _onGenderChanged(String? gender) {
    setState(() {
      _selectedGender = gender;
      _hasUnsavedChanges = true;
    });
  }

  void _onSeverityChanged(String? severity) {
    setState(() {
      _selectedSeverity = severity;
      _hasUnsavedChanges = true;
    });
  }

  void _onGoalAdded(Map<String, dynamic> goal) {
    setState(() {
      _goals.add(goal);
      _hasUnsavedChanges = true;
    });
  }

  void _onGoalUpdated(int index, Map<String, dynamic> goal) {
    setState(() {
      _goals[index] = goal;
      _hasUnsavedChanges = true;
    });
  }

  void _onGoalDeleted(int index) {
    setState(() {
      _goals.removeAt(index);
      _hasUnsavedChanges = true;
    });
  }

  void _onNoteAdded(Map<String, dynamic> note) {
    setState(() {
      _notes.insert(0, note);
      _hasUnsavedChanges = true;
    });
  }

  void _onNoteUpdated(int index, Map<String, dynamic> note) {
    setState(() {
      _notes[index] = note;
      _hasUnsavedChanges = true;
    });
  }

  void _onNoteDeleted(int index) {
    setState(() {
      _notes.removeAt(index);
      _hasUnsavedChanges = true;
    });
  }

  void _onParentAdded(Map<String, dynamic> parent) {
    setState(() {
      _parentAccess.add(parent);
      _hasUnsavedChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to ${parent['name']}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _onPreferenceChanged(String key, bool value) {
    setState(() {
      _communicationPreferences[key] = value;
      _hasUnsavedChanges = true;
    });
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unsaved Changes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'You have unsaved changes. Do you want to save before leaving?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveProfile();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate saving to Hive local database
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _hasUnsavedChanges = false;
        _isLoading = false;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 2.w),
              const Expanded(
                child: Text('Profile saved successfully'),
              ),
              if (!_isOnline) ...[
                SizedBox(width: 2.w),
                const CustomIconWidget(
                  iconName: 'cloud_off',
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error saving profile. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Profile Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 3.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'edit',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Edit functionality is already available in the form
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                title: const Text('Share with Team'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sharing profile with therapy team...'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'download',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                title: const Text('Export Data'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Exporting profile data...'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) async {
        if (!didPop && _hasUnsavedChanges) {
          final result = await _onWillPop();
          if (result && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Student Profile'),
          actions: [
            if (!_isOnline)
              Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: CustomIconWidget(
                  iconName: 'cloud_off',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            IconButton(
              onPressed: _showContextMenu,
              icon: CustomIconWidget(
                iconName: 'more_vert',
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 2.h),

                // Student Photo
                StudentPhotoWidget(
                  currentImageUrl: _selectedImagePath,
                  onImageSelected: _onImageSelected,
                ),

                SizedBox(height: 3.h),

                // Basic Information
                BasicInfoSectionWidget(
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  ageController: _ageController,
                  dateOfBirthController: _dateOfBirthController,
                  selectedGender: _selectedGender,
                  onGenderChanged: _onGenderChanged,
                  onDateOfBirthTap: _selectDateOfBirth,
                ),

                // Therapy-Specific Details
                TherapyDetailsSectionWidget(
                  diagnosisController: _diagnosisController,
                  triggersController: _triggersController,
                  communicationController: _communicationController,
                  sensoryController: _sensoryController,
                  selectedSeverity: _selectedSeverity,
                  onSeverityChanged: _onSeverityChanged,
                ),

                // Goals Section
                GoalsSectionWidget(
                  goals: _goals,
                  onGoalAdded: _onGoalAdded,
                  onGoalUpdated: _onGoalUpdated,
                  onGoalDeleted: _onGoalDeleted,
                ),

                // Emergency Contacts
                EmergencyContactWidget(
                  primaryNameController: _primaryNameController,
                  primaryPhoneController: _primaryPhoneController,
                  primaryRelationController: _primaryRelationController,
                  secondaryNameController: _secondaryNameController,
                  secondaryPhoneController: _secondaryPhoneController,
                  secondaryRelationController: _secondaryRelationController,
                  medicalAlertsController: _medicalAlertsController,
                ),

                // Session History
                SessionHistoryWidget(
                  sessions: _sessionHistory,
                ),

                // Notes Section
                NotesSectionWidget(
                  notes: _notes,
                  onNoteAdded: _onNoteAdded,
                  onNoteUpdated: _onNoteUpdated,
                  onNoteDeleted: _onNoteDeleted,
                ),

                // Parent Collaboration
                ParentCollaborationWidget(
                  parentAccess: _parentAccess,
                  communicationPreferences: _communicationPreferences,
                  onParentAdded: _onParentAdded,
                  onPreferenceChanged: _onPreferenceChanged,
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
        floatingActionButton: _hasUnsavedChanges
            ? FloatingActionButton.extended(
                onPressed: _isLoading ? null : _saveProfile,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'save',
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                label: Text(_isLoading ? 'Saving...' : 'Save Profile'),
              )
            : null,
      ),
    );
  }
}



