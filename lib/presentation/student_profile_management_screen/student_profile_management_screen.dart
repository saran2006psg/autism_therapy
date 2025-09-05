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
    _loadMockData();
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

  void _loadMockData() {
    // Load existing student data
    _firstNameController.text = 'Emma';
    _lastNameController.text = 'Johnson';
    _ageController.text = '8';
    _dateOfBirthController.text = '03/15/2015';
    _selectedGender = 'Female';
    _selectedImagePath =
        'https://images.pexels.com/photos/1462637/pexels-photo-1462637.jpeg?auto=compress&cs=tinysrgb&w=400';

    // Therapy details
    _diagnosisController.text =
        'Autism Spectrum Disorder Level 2 - Requiring substantial support. Diagnosed at age 4 with significant challenges in social communication and restricted, repetitive behaviors.';
    _selectedSeverity = 'Level 2 - Requiring Substantial Support';
    _triggersController.text =
        'Loud noises, sudden changes in routine, crowded spaces, unexpected physical contact, bright fluorescent lights.';
    _communicationController.text =
        'Uses picture exchange communication system (PECS), responds well to visual schedules, prefers written instructions over verbal.';
    _sensoryController.text =
        'Hypersensitive to sound and touch, seeks deep pressure input, enjoys weighted blankets, dislikes tags in clothing.';

    // Emergency contacts
    _primaryNameController.text = 'Sarah Johnson';
    _primaryPhoneController.text = '(555) 123-4567';
    _primaryRelationController.text = 'Mother';
    _secondaryNameController.text = 'Michael Johnson';
    _secondaryPhoneController.text = '(555) 987-6543';
    _secondaryRelationController.text = 'Father';
    _medicalAlertsController.text =
        'Allergic to peanuts and shellfish. Takes melatonin for sleep. Has emergency inhaler for mild asthma.';

    // Mock goals
    _goals = [
      {
        'id': 1,
        'title': 'Improve Eye Contact During Conversations',
        'description':
            'Maintain eye contact for 3-5 seconds during structured conversations with familiar adults.',
        'category': 'Social Skills',
        'priority': 'High',
        'progress': 0.65,
        'status': 'Active',
        'createdDate': DateTime.now().subtract(const Duration(days: 30)),
        'targetDate': DateTime.now().add(const Duration(days: 60)),
      },
      {
        'id': 2,
        'title': 'Use PECS to Request Preferred Items',
        'description':
            'Independently use picture cards to request 10 different preferred items or activities.',
        'category': 'Communication',
        'priority': 'High',
        'progress': 0.80,
        'status': 'Active',
        'createdDate': DateTime.now().subtract(const Duration(days: 45)),
        'targetDate': DateTime.now().add(const Duration(days: 30)),
      },
      {
        'id': 3,
        'title': 'Complete Self-Care Routine',
        'description':
            'Follow visual schedule to complete morning self-care routine with minimal prompting.',
        'category': 'Self-Care',
        'priority': 'Medium',
        'progress': 0.45,
        'status': 'Active',
        'createdDate': DateTime.now().subtract(const Duration(days: 20)),
        'targetDate': DateTime.now().add(const Duration(days: 90)),
      },
    ];

    // Mock session history
    _sessionHistory = [
      {
        'id': 1,
        'title': 'Individual Communication Session',
        'type': 'Individual',
        'date': '08/10/2025',
        'duration': 60,
        'therapist': 'Dr. Sarah Johnson',
        'goals': 'Eye contact, PECS communication',
        'activities':
            'Picture card matching, role-playing exercises, social story reading',
        'notes':
            'Emma showed significant improvement in maintaining eye contact during structured activities. She successfully used PECS to request her preferred snack and responded well to the new social story about playground interactions.',
        'homework':
            'Practice greeting phrases with family members, complete emotion identification worksheet',
        'nextFocus':
            'Continue working on conversation starters and maintaining dialogue',
        'summary': 'Great progress with eye contact and PECS usage',
      },
      {
        'id': 2,
        'title': 'Group Social Skills Session',
        'type': 'Group',
        'date': '08/08/2025',
        'duration': 45,
        'therapist': 'Dr. Sarah Johnson',
        'goals': 'Turn-taking, peer interaction',
        'activities': 'Group games, sharing activities, cooperative puzzles',
        'notes':
            'Emma participated in group activities with 2 other children. She demonstrated improved turn-taking skills during board games and showed interest in peer interactions, though still required prompting for initiating conversations.',
        'homework':
            'Practice sharing toys with siblings, use visual timer for turn-taking',
        'nextFocus':
            'Work on initiating peer interactions and maintaining group participation',
        'summary':
            'Good participation in group activities, needs work on peer initiation',
      },
      {
        'id': 3,
        'title': 'Behavioral Assessment Session',
        'type': 'Assessment',
        'date': '08/05/2025',
        'duration': 90,
        'therapist': 'Dr. Sarah Johnson',
        'goals': 'Comprehensive behavioral evaluation',
        'activities':
            'Structured observations, behavioral rating scales, parent interview',
        'notes':
            'Comprehensive assessment revealed continued progress in communication goals with some regression in sensory regulation. Emma showed increased sensitivity to environmental changes and may benefit from additional sensory breaks.',
        'homework':
            'Implement sensory diet recommendations, track behavioral patterns',
        'nextFocus':
            'Address sensory regulation strategies and environmental modifications',
        'summary':
            'Assessment shows progress in communication, needs sensory support',
      },
    ];

    // Mock notes
    _notes = [
      {
        'id': 1,
        'title': 'Breakthrough in Communication',
        'content':
            'Today Emma spontaneously used her PECS book to ask for help when she couldn\'t open her water bottle. This is the first time she has independently initiated communication for assistance rather than becoming frustrated. This represents a significant milestone in her communication development and shows she is beginning to understand the functional use of her communication system.',
        'tags': ['Communication', 'Progress', 'Achievements'],
        'createdDate': DateTime.now().subtract(const Duration(days: 2)),
        'author': 'Dr. Sarah Johnson',
      },
      {
        'id': 2,
        'title': 'Sensory Sensitivity Observations',
        'content':
            'Emma had a difficult session today due to construction noise from the adjacent building. She covered her ears, became agitated, and was unable to focus on activities. We moved to the quiet room and used noise-canceling headphones, which helped her regulate. Need to consider environmental modifications for future sessions and discuss sensory accommodations with parents.',
        'tags': ['Sensory', 'Behavioral', 'Concerns'],
        'createdDate': DateTime.now().subtract(const Duration(days: 5)),
        'author': 'Dr. Sarah Johnson',
      },
      {
        'id': 3,
        'title': 'Parent Collaboration Success',
        'content':
            'Had an excellent meeting with Emma\'s parents today. They reported successful implementation of the visual schedule at home, and Emma is now completing her morning routine with 75% independence. Parents are feeling more confident in supporting her communication goals and have requested additional resources for sibling interactions.',
        'tags': ['Family', 'Progress', 'Collaboration'],
        'createdDate': DateTime.now().subtract(const Duration(days: 7)),
        'author': 'Dr. Sarah Johnson',
      },
    ];

    // Mock parent access
    _parentAccess = [
      {
        'id': 1,
        'name': 'Sarah Johnson',
        'email': 'sarah.johnson@email.com',
        'phone': '(555) 123-4567',
        'relationship': 'Mother',
        'permissions': [
          'View Progress',
          'View Session Notes',
          'View Goals',
          'Receive Notifications'
        ],
        'status': 'Active',
        'addedDate': DateTime.now().subtract(const Duration(days: 60)),
      },
      {
        'id': 2,
        'name': 'Michael Johnson',
        'email': 'michael.johnson@email.com',
        'phone': '(555) 987-6543',
        'relationship': 'Father',
        'permissions': ['View Progress', 'View Goals', 'Receive Notifications'],
        'status': 'Active',
        'addedDate': DateTime.now().subtract(const Duration(days: 60)),
      },
    ];
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



