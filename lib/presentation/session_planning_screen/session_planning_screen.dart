import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/activity_card_widget.dart';
import './widgets/activity_category_widget.dart';
import './widgets/custom_activity_bottom_sheet.dart';
import './widgets/session_header_widget.dart';
import './widgets/session_timeline_widget.dart';

class SessionPlanningScreen extends StatefulWidget {
  const SessionPlanningScreen({super.key});

  @override
  State<SessionPlanningScreen> createState() => _SessionPlanningScreenState();
}

class _SessionPlanningScreenState extends State<SessionPlanningScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Data service instance
  late DataService _dataService;

  // Session data
  StudentModel? _selectedStudent;
  List<StudentModel> _availableStudents = [];
  final Map<String, List<SessionModel>> _studentSessionsMap = {};
  final Map<String, List<Map<String, dynamic>>> _studentActivitiesMap = {};
  StreamSubscription<List<StudentModel>>? _studentsSubscription;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  int _sessionDuration = 60;

  // Activity data
  List<Map<String, dynamic>> _filteredActivities = [];
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Student creation form controllers
  final GlobalKey<FormState> _createStudentFormKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedGender;
  bool _isCreatingStudent = false;

  // Mock activity data
  final List<Map<String, dynamic>> _allActivities = [
    {
      'id': 1,
      'name': 'Picture Exchange Communication',
      'description':
          'Using visual cards to communicate basic needs and wants effectively',
      'type': 'communication',
      'difficulty': 'easy',
      'duration': 15,
      'icon': 'chat_bubble_outline',
      'category': 'Communication Skills',
    },
    {
      'id': 2,
      'name': 'Social Story Reading',
      'description':
          'Interactive storytelling to teach social situations and appropriate responses',
      'type': 'social',
      'difficulty': 'medium',
      'duration': 20,
      'icon': 'book',
      'category': 'Social Interaction',
    },
    {
      'id': 3,
      'name': 'Sensory Integration Play',
      'description':
          'Tactile activities using different textures to improve sensory processing',
      'type': 'sensory',
      'difficulty': 'easy',
      'duration': 25,
      'icon': 'touch_app',
      'category': 'Sensory Integration',
    },
    {
      'id': 4,
      'name': 'Turn-Taking Games',
      'description':
          'Board games and activities that teach patience and social interaction skills',
      'type': 'social',
      'difficulty': 'medium',
      'duration': 30,
      'icon': 'groups',
      'category': 'Social Interaction',
    },
    {
      'id': 5,
      'name': 'Emotional Recognition Cards',
      'description':
          'Learning to identify and express different emotions through visual aids',
      'type': 'behavioral',
      'difficulty': 'medium',
      'duration': 20,
      'icon': 'emoji_emotions',
      'category': 'Behavioral Training',
    },
    {
      'id': 6,
      'name': 'Deep Pressure Therapy',
      'description':
          'Calming activities using weighted blankets and compression techniques',
      'type': 'sensory',
      'difficulty': 'easy',
      'duration': 15,
      'icon': 'spa',
      'category': 'Sensory Integration',
    },
    {
      'id': 7,
      'name': 'Verbal Imitation Practice',
      'description':
          'Structured activities to improve speech and language development',
      'type': 'communication',
      'difficulty': 'hard',
      'duration': 25,
      'icon': 'record_voice_over',
      'category': 'Communication Skills',
    },
    {
      'id': 8,
      'name': 'Routine Building Exercise',
      'description':
          'Step-by-step activities to establish and maintain daily routines',
      'type': 'behavioral',
      'difficulty': 'medium',
      'duration': 35,
      'icon': 'schedule',
      'category': 'Behavioral Training',
    },
  ];

  @override
  void initState() {
    super.initState();
    _dataService = DataService();
    _filteredActivities = List.from(_allActivities);
    _searchController.addListener(_onSearchChanged);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
    
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _dataService.initialize();
      
      // Cancel existing subscription if any
      await _studentsSubscription?.cancel();
      
      // Set up real-time stream for students
      if (_dataService.currentUserId != null) {
        AppLogger.info('Setting up student stream for therapist: ${_dataService.currentUserId}', name: 'SessionPlanning');
        _studentsSubscription = FirestoreService.streamStudentsForTherapist(_dataService.currentUserId!)
            .listen(
          (students) {
            AppLogger.debug('Received ${students.length} students from stream', name: 'SessionPlanning');
            for (var student in students) {
              AppLogger.debug('Student: ${student.firstName} ${student.lastName} (ID: ${student.id})', name: 'SessionPlanning');
            }
            if (mounted) {
              setState(() {
                _availableStudents = students;
                _isLoading = false;
              });
            }
          },
          onError: (error) {
            AppLogger.error('Error in student stream: $error', name: 'SessionPlanning', error: error);
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading students: $error'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                ),
              );
            }
          },
        );
      } else {
        AppLogger.warning('No current user ID found', name: 'SessionPlanning');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  void _onStudentSelected(StudentModel student) {
    setState(() {
      _selectedStudent = student;
      if (student.id != null && student.id!.isNotEmpty) {
        // Load sessions for the selected student if not already loaded
        if (!_studentSessionsMap.containsKey(student.id!)) {
          _studentSessionsMap[student.id!] = _dataService.getSessionsForStudent(student.id!);
        }
        // Initialize activities map for the student if not already done
        if (!_studentActivitiesMap.containsKey(student.id!)) {
          _studentActivitiesMap[student.id!] = [];
        }
      } else {
        AppLogger.warning('Warning: Student has no ID: ${student.firstName}', name: 'SessionPlanning');
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _studentsSubscription?.cancel();
    
    // Dispose student creation form controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterActivities();
    });
  }

  void _filterActivities() {
    _filteredActivities = _allActivities.where((activity) {
      final matchesSearch = _searchQuery.isEmpty ||
          (activity['name'] as String).toLowerCase().contains(_searchQuery) ||
          (activity['description'] as String)
              .toLowerCase()
              .contains(_searchQuery);

      final matchesFilter =
          _selectedFilter == 'all' || activity['type'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _onActivityTapped(Map<String, dynamic> activity) {
    if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a student first'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      final studentId = _selectedStudent!.id!;
      if (!_studentActivitiesMap.containsKey(studentId)) {
        _studentActivitiesMap[studentId] = [];
      }
      _studentActivitiesMap[studentId]!.add(Map.from(activity));
      _hasUnsavedChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${activity['name']}" to ${_selectedStudent!.firstName}\'s session plan'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              final studentId = _selectedStudent!.id!;
              if (_studentActivitiesMap.containsKey(studentId) && 
                  _studentActivitiesMap[studentId]!.isNotEmpty) {
                _studentActivitiesMap[studentId]!.removeLast();
                _hasUnsavedChanges = _getTotalActivitiesCount() > 0;
              }
            });
          },
        ),
      ),
    );
  }

  void _onActivityReorder(int oldIndex, int newIndex) {
    if (_selectedStudent == null) return;

    HapticFeedback.mediumImpact();
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final studentId = _selectedStudent!.id!;
      final activities = _studentActivitiesMap[studentId] ?? [];
      if (oldIndex < activities.length && newIndex < activities.length) {
        final activity = activities.removeAt(oldIndex);
        activities.insert(newIndex, activity);
        _hasUnsavedChanges = true;
      }
    });
  }

  void _removeActivity(int index) {
    if (_selectedStudent == null) return;

    final studentId = _selectedStudent!.id!;
    final activities = _studentActivitiesMap[studentId] ?? [];
    if (index >= activities.length) return;

    HapticFeedback.lightImpact();
    final removedActivity = activities[index];
    setState(() {
      activities.removeAt(index);
      _hasUnsavedChanges = _getTotalActivitiesCount() > 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${removedActivity['name']}" from ${_selectedStudent!.firstName}\'s session plan'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              activities.insert(index, removedActivity);
              _hasUnsavedChanges = true;
            });
          },
        ),
      ),
    );
  }

  // Helper methods for the new data structure
  List<Map<String, dynamic>> _getCurrentStudentActivities() {
    if (_selectedStudent?.id == null) return [];
    return _studentActivitiesMap[_selectedStudent!.id!] ?? [];
  }

  List<SessionModel> _getCurrentStudentSessions() {
    if (_selectedStudent?.id == null) return [];
    return _studentSessionsMap[_selectedStudent!.id!] ?? [];
  }

  int _getTotalActivitiesCount() {
    return _studentActivitiesMap.values.fold(0, (sum, activities) => sum + activities.length);
  }

  List<Map<String, dynamic>> _getAllActivitiesForSummary() {
    final allActivities = <Map<String, dynamic>>[];
    _studentActivitiesMap.forEach((studentId, activities) {
      final student = _availableStudents.firstWhere(
        (s) => s.id == studentId,
        orElse: () => StudentModel(
          firstName: 'Unknown',
          lastName: 'Student',
          age: 0,
          dateOfBirth: DateTime.now(),
          gender: 'Unknown',
          diagnosis: '',
          communicationLevel: '',
          sensoryNeeds: '',
          severity: '',
          therapistId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      for (final activity in activities) {
        allActivities.add({
          ...activity,
          'studentName': student.fullName,
          'studentId': studentId,
        });
      }
    });
    return allActivities;
  }

  void _showCustomActivityBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomActivityBottomSheet(
        onActivityCreated: (activity) {
          setState(() {
            _allActivities.add(activity);
            _filterActivities();
            _hasUnsavedChanges = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Created custom activity "${activity['name']}"'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _onDurationChanged(int duration) {
    setState(() {
      _sessionDuration = duration;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _saveSession() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Check if student is selected
    if (_selectedStudent == null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Please select a student for this session'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    if (_getCurrentStudentActivities().isEmpty) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Please add at least one activity to the session plan'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    // Validate required data
    if (_selectedStudent!.id == null || _selectedStudent!.id!.isEmpty) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Invalid student data. Please refresh and try again.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    if (_dataService.currentUserId == null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('User not authenticated. Please log in again.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    try {
      // Create session object
      final sessionDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Save session using DataService
      final currentActivities = _getCurrentStudentActivities();
      await _dataService.createSession(
        studentId: _selectedStudent!.id!,
        type: 'Therapy Session',
        title: 'Session with ${_selectedStudent!.firstName}',
        scheduledDate: sessionDate,
        estimatedDuration: _sessionDuration,
        description: 'Session planned with ${currentActivities.length} activities',
        activities: currentActivities,
      );

      setState(() {
        _hasUnsavedChanges = false;
        // Clear current student's activities after successful save
        if (_selectedStudent?.id != null) {
          _studentActivitiesMap[_selectedStudent!.id!] = [];
        }
      });

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text
          ('Session planned for ${_selectedStudent!.firstName} successfully!'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to session details
            },
          ),
        ),
      );

      // Refresh student sessions
      if (_selectedStudent?.id != null) {
        _studentSessionsMap[_selectedStudent!.id!] = _dataService.getSessionsForStudent(_selectedStudent!.id!);
      }

    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error saving session: $e'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }

    // Navigate back to dashboard
    navigator.pushReplacementNamed('/therapist-dashboard');
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final context = this.context;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'You have unsaved changes. Do you want to save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              _saveSession();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  int get _totalPlannedDuration {
    final currentActivities = _getCurrentStudentActivities();
    return currentActivities.fold(
        0, (sum, activity) => sum + (activity['duration'] as int? ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final categories = _groupActivitiesByCategory();

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
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Session Planning'),
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: _hasUnsavedChanges ? _saveSession : null,
              icon: CustomIconWidget(
                iconName: 'save',
                color: _hasUnsavedChanges
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                size: 5.w,
              ),
              label: Text(
                'Save',
                style: TextStyle(
                  color: _hasUnsavedChanges
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                ),
              ),
            ),
            SizedBox(width: 2.w),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              _filterActivities();
            });
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: SessionHeaderWidget(
                  studentName: _selectedStudent?.fullName ?? 'Select Student',
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  sessionDuration: _sessionDuration,
                  onDateTap: _selectDate,
                  onTimeTap: _selectTime,
                  onDurationChanged: _onDurationChanged,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildStudentSelector(),
              ),
              SliverToBoxAdapter(
                child: _buildQuickActions(),
              ),
              if (_getTotalActivitiesCount() > 0) ...[
                SliverToBoxAdapter(
                  child: _buildSummaryView(),
                ),
              ],
              SliverToBoxAdapter(
                child: SessionTimelineWidget(
                  plannedActivities: _getCurrentStudentActivities(),
                  totalDuration: _totalPlannedDuration,
                ),
              ),
              if (_getCurrentStudentActivities().isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Text(
                      'Planned Activities',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverReorderableList(
                  itemCount: _getCurrentStudentActivities().length,
                  onReorder: _onActivityReorder,
                  itemBuilder: (context, index) {
                    final activity = _getCurrentStudentActivities()[index];
                    return ReorderableDragStartListener(
                      key: ValueKey(activity['id']),
                      index: index,
                      child: Dismissible(
                        key: ValueKey('dismissible_${activity['id']}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removeActivity(index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 4.w),
                          margin: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomIconWidget(
                            iconName: 'delete',
                            color: AppTheme.lightTheme.colorScheme.onError,
                            size: 6.w,
                          ),
                        ),
                        child: ActivityCardWidget(
                          activity: activity,
                          onTap: () {
                            // Show activity details or edit options
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Library',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildSearchAndFilter(),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final categoryName = categories.keys.elementAt(index);
                    final categoryActivities = categories[categoryName]!;

                    return ActivityCategoryWidget(
                      categoryName: categoryName,
                      activities: categoryActivities,
                      onActivityTap: _onActivityTapped,
                    );
                  },
                  childCount: categories.length,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
            ],
          ),
        ),
        floatingActionButton: ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            onPressed: _showCustomActivityBottomSheet,
            icon: CustomIconWidget(
              iconName: 'add',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 5.w,
            ),
            label: const Text('Custom Activity'),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search activities...',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'search',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  )
                : null,
          ),
        ),
        SizedBox(height: 2.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', 'all'),
              SizedBox(width: 2.w),
              _buildFilterChip('Communication', 'communication'),
              SizedBox(width: 2.w),
              _buildFilterChip('Social', 'social'),
              SizedBox(width: 2.w),
              _buildFilterChip('Behavioral', 'behavioral'),
              SizedBox(width: 2.w),
              _buildFilterChip('Sensory', 'sensory'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
          _filterActivities();
        });
      },
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      selectedColor:
          AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: isSelected
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupActivitiesByCategory() {
    final Map<String, List<Map<String, dynamic>>> categories = {};

    for (final activity in _filteredActivities) {
      final category = activity['category'] as String;
      if (!categories.containsKey(category)) {
        categories[category] = [];
      }
      categories[category]!.add(activity);
    }

    return categories;
  }

  Widget _buildStudentSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.surface,
            AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary,
                      AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CustomIconWidget(
                  iconName: 'person',
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Select Student',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            )
          else if (_availableStudents.isEmpty)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: 'group_add',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 48,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No Students Available',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Add students to your account to start planning sessions',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-student');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 22.h, // Increased height to accommodate content
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two rows
                      mainAxisSpacing: 2.w,
                      crossAxisSpacing: 1.h,
                      childAspectRatio: 0.9, // Increased to give more space
                    ),
                    itemCount: _availableStudents.length,
                    itemBuilder: (context, index) {
                      final student = _availableStudents[index];
                      final isSelected = _selectedStudent?.id == student.id;
                      final hasActivities = _studentActivitiesMap.containsKey(student.id) && 
                                          _studentActivitiesMap[student.id]!.isNotEmpty;
                      
                      return GestureDetector(
                        onTap: () => _onStudentSelected(student),
                        child: Container(
                          padding: EdgeInsets.all(1.5.w), // Reduced padding
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.15),
                                      AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.08),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : AppTheme.lightTheme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : hasActivities
                                      ? AppTheme.lightTheme.colorScheme.secondary
                                      : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
                              width: isSelected ? 2 : hasActivities ? 1.5 : 1,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 8.w, // Reduced size
                                    height: 8.w, // Reduced size
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                AppTheme.lightTheme.colorScheme.primary,
                                                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
                                              ],
                                            )
                                          : null,
                                      color: isSelected ? null : AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'S',
                                        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                                          color: isSelected ? Colors.white : AppTheme.lightTheme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (hasActivities)
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: Container(
                                        width: 3.5.w, // Reduced size
                                        height: 3.5.w, // Reduced size
                                        decoration: BoxDecoration(
                                          color: AppTheme.lightTheme.colorScheme.secondary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${_studentActivitiesMap[student.id]?.length ?? 0}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7.sp, // Reduced font size
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 0.8.h), // Reduced spacing
                              Flexible( // Wrap text in Flexible
                                child: Text(
                                  student.firstName.isNotEmpty ? student.firstName : 'Student',
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? AppTheme.lightTheme.colorScheme.primary
                                        : AppTheme.lightTheme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10, // Reduced font size
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_selectedStudent != null) ...[
                  SizedBox(height: 3.h),
                  _buildStudentSchedule(),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showCreateStudentSheet,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('New Student & Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _selectedStudent != null ? () {
                // Schedule session for existing student
                _saveSession();
              } : null,
              icon: const Icon(Icons.schedule, size: 20),
              label: const Text('Schedule Session'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                side: BorderSide(color: AppTheme.lightTheme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSchedule() {
    if (_selectedStudent == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                '${_selectedStudent!.firstName}\'s Schedule',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (_getCurrentStudentSessions().isEmpty)
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'event_available',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'No upcoming sessions scheduled',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _getCurrentStudentSessions().take(3).map((session) {
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: _getSessionStatusColor(session.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: CustomIconWidget(
                          iconName: 'event',
                          color: _getSessionStatusColor(session.status),
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.type,
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '${_formatDate(session.scheduledDate)} at ${_formatTime(session.scheduledDate)}',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _getSessionStatusColor(session.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          session.status.toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                            color: _getSessionStatusColor(session.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          if (_getCurrentStudentSessions().length > 3)
            TextButton(
              onPressed: () {
                // Navigate to full schedule view
              },
              child: Text(
                'View All Sessions (${_getCurrentStudentSessions().length})',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getSessionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'in_progress':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'completed':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'cancelled':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildSummaryView() {
    final allActivities = _getAllActivitiesForSummary();
    if (allActivities.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            AppTheme.lightTheme.colorScheme.secondaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.secondary,
                      AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CustomIconWidget(
                  iconName: 'summarize',
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Session Summary',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${allActivities.length} Activities',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ...allActivities.take(5).map((activity) {
            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: activity['icon'] ?? 'task',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['name'] ?? 'Unknown Activity',
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'For ${activity['studentName'] ?? 'Unknown Student'} • ${activity['duration'] ?? 0} min',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      activity['category'] ?? 'General',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (allActivities.length > 5)
            Center(
              child: TextButton(
                onPressed: () {
                  // Show all activities dialog or navigate to full view
                },
                child: Text(
                  'View All ${allActivities.length} Activities',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCreateStudentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _buildCreateStudentSheet(scrollController),
        ),
      ),
    );
  }

  Widget _buildCreateStudentSheet(ScrollController scrollController) {
    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          SizedBox(height: 2.h),
          
          // Title
          Text(
            'Create New Student',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 3.h),
          
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Form(
                key: _createStudentFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSectionHeader('Basic Information'),
                    SizedBox(height: 2.h),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    
                    TextFormField(
                      controller: _dateOfBirthController,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Date of birth is required';
                        }
                        return null;
                      },
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                          firstDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          _dateOfBirthController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                        }
                      },
                    ),
                    SizedBox(height: 2.h),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['Male', 'Female', 'Other'].map((gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender))
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Gender is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    
                    // Clinical Information Section
                    _buildSectionHeader('Clinical Information'),
                    SizedBox(height: 2.h),
                    
                    TextFormField(
                      controller: _diagnosisController,
                      decoration: InputDecoration(
                        labelText: 'Primary Diagnosis',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 2.h),
                    
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 3.h),
                    
                    // Session Scheduling Section
                    _buildSectionHeader('Session Scheduling'),
                    SizedBox(height: 2.h),
                    
                    Text(
                      'Schedule the first session for this student:',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: AppTheme.lightTheme.colorScheme.primary),
                                  SizedBox(width: 2.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date',
                                        style: AppTheme.lightTheme.textTheme.bodySmall,
                                      ),
                                      Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: InkWell(
                            onTap: _selectTime,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, color: AppTheme.lightTheme.colorScheme.primary),
                                  SizedBox(width: 2.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Time',
                                        style: AppTheme.lightTheme.textTheme.bodySmall,
                                      ),
                                      Text(
                                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    
                    // Duration Selection
                    Text(
                      'Session Duration',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: [30, 45, 60, 90, 120].map((duration) {
                        final isSelected = _sessionDuration == duration;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _sessionDuration = duration;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              '$duration min',
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 4.h),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              side: BorderSide(color: AppTheme.lightTheme.colorScheme.primary),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isCreatingStudent ? null : _createStudentAndContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                            ),
                            child: _isCreatingStudent
                                ? SizedBox(
                                    height: 2.h,
                                    width: 2.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Create Student & Schedule Session',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.transparent10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(width: 2.w),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createStudentAndContinue() async {
    if (!_createStudentFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreatingStudent = true;
    });

    try {
      // Parse date of birth
      DateTime? dateOfBirth;
      if (_dateOfBirthController.text.isNotEmpty) {
        // Parse dd/MM/yyyy format
        final parts = _dateOfBirthController.text.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            dateOfBirth = DateTime(year, month, day);
          }
        }
      }

      // Calculate age from date of birth
      int age = 0;
      if (dateOfBirth != null) {
        final now = DateTime.now();
        age = now.year - dateOfBirth.year;
        if (now.month < dateOfBirth.month || 
            (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
          age--;
        }
      }

      // Create student using DataService method
      final studentId = await _dataService.createStudent(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: age,
        dateOfBirth: dateOfBirth ?? DateTime.now(),
        gender: _selectedGender ?? '',
        diagnosis: _diagnosisController.text.trim().isNotEmpty 
            ? _diagnosisController.text.trim() 
            : 'To be determined',
        communicationLevel: 'To be assessed',
        sensoryNeeds: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : 'To be assessed',
        severity: 'moderate',
        triggers: [],
      );

      // Find the created student in the cache
      final createdStudent = _availableStudents.firstWhere((s) => s.id == studentId);

      // Automatically create a session for the new student
      final sessionDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Create initial session
      await _dataService.createSession(
        studentId: studentId,
        type: 'Initial Assessment',
        title: 'Initial Session with ${_firstNameController.text.trim()}',
        scheduledDate: sessionDate,
        estimatedDuration: _sessionDuration,
        description: 'Initial assessment and therapy planning session',
        activities: [], // Start with empty activities - can be added later
      );

      // Clear form
      _clearCreateStudentForm();

      // Close the sheet
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // Set as selected student and refresh data
      setState(() {
        _selectedStudent = createdStudent;
        _isCreatingStudent = false;
      });

      // Initialize data for the new student
      _studentSessionsMap[studentId] = [];
      _studentActivitiesMap[studentId] = [];

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student created and session scheduled for ${_getDateTimeString(sessionDate)}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View Dashboard',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/therapist-dashboard');
            },
          ),
        ),
      );

    } catch (e) {
      setState(() {
        _isCreatingStudent = false;
      });
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating student: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getDateTimeString(DateTime dateTime) {
    final time = TimeOfDay.fromDateTime(dateTime);
    final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    return '$date at $formattedTime';
  }

  void _clearCreateStudentForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _dateOfBirthController.clear();
    _diagnosisController.clear();
    _notesController.clear();
    _selectedGender = null;
  }
}
