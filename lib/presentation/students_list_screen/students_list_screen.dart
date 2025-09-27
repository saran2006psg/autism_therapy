import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  late DataService _dataService;
  List<StudentModel> _students = [];
  bool _isLoading = true;
  StreamSubscription<List<StudentModel>>? _studentsSubscription;
  final TextEditingController _searchController = TextEditingController();
  List<StudentModel> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _dataService = DataService();
    _loadStudents();
  }

  @override
  void dispose() {
    _studentsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _dataService.initialize();
      
      final currentUser = AuthService.currentUser;
      if (currentUser?.uid == null) {
        throw Exception('No authenticated user found');
      }
      
      final userId = currentUser!.uid;
      
      // Set up real-time streams for students
      _studentsSubscription = FirestoreService.streamStudentsForTherapist(userId).listen(
        (students) {
          setState(() {
            _students = students;
            _filteredStudents = students;
            _isLoading = false;
          });
        },
        onError: (error) {
          AppLogger.error('Error streaming students: $error', name: 'StudentsListScreen', error: error);
          // Fallback to DataService if streams fail
          setState(() {
            _students = _dataService.getMyStudents();
            _filteredStudents = _students;
            _isLoading = false;
          });
        },
      );
      
    } catch (e) {
      AppLogger.error('Error loading students: $e', name: 'StudentsListScreen', error: e);
      // Fallback to DataService if real-time fails
      _students = _dataService.getMyStudents();
      _filteredStudents = _students;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents = _students.where((student) {
          final name = '${student.firstName} ${student.lastName}'.toLowerCase();
          final diagnosis = student.diagnosis.toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || diagnosis.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _refreshStudents() async {
    await _loadStudents();
  }

  Future<void> _deleteAllTestData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete All Students',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              '• All students assigned to you',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            Text(
              '• All related sessions and goals',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            Text(
              '• All progress data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'This action cannot be undone!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performDataDeletion();
    }
  }

  Future<void> _performDataDeletion() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Deleting student data...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );

      final currentUser = AuthService.currentUser;
      if (currentUser?.uid == null) {
        throw Exception('No authenticated user found');
      }

      // Get all students for current therapist
      final students = _dataService.getMyStudents();
      
      for (final student in students) {
        AppLogger.info('Deleting student: ${student.fullName}', name: 'StudentsListScreen');
        
        // Delete student and all related data
        await _dataService.deleteStudent(student.id!);
      }

      // Close loading dialog
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
              SizedBox(width: 2.w),
              Text(
                'All student data deleted successfully',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          duration: const Duration(seconds: 3),
        ),
      );

      // Refresh the list
      await _refreshStudents();

    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();
      
      AppLogger.error('Error deleting student data: $e', name: 'StudentsListScreen', error: e);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting data: ${e.toString()}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _deleteIndividualStudent(StudentModel student) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Student',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              student.fullName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'This will also delete:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 0.5.h),
            Text(
              '• All sessions and goals',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            Text(
              '• All progress data',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'This action cannot be undone!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performIndividualDeletion(student);
    }
  }

  Future<void> _performIndividualDeletion(StudentModel student) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Deleting ${student.firstName}...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );

      AppLogger.info('Deleting student: ${student.fullName}', name: 'StudentsListScreen');
      
      // Delete student and all related data
      await _dataService.deleteStudent(student.id!);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
              SizedBox(width: 2.w),
              Text(
                '${student.firstName} deleted successfully',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          duration: const Duration(seconds: 3),
        ),
      );

      // Refresh the list
      await _refreshStudents();

    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();
      
      AppLogger.error('Error deleting student: $e', name: 'StudentsListScreen', error: e);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting ${student.firstName}: ${e.toString()}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'My Students',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          // Delete All Data Button (only show if there are students)
          if (_students.isNotEmpty)
            IconButton(
              onPressed: _deleteAllTestData,
              icon: CustomIconWidget(
                iconName: 'delete_sweep',
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: 'Delete All Students',
            ),
          IconButton(
            onPressed: () async {
              // Navigate to add student and wait for result
              final result = await Navigator.pushNamed(context, '/add-student-form');
              // If a student was added successfully, refresh the list
              if (result == true) {
                await _refreshStudents();
              }
            },
            icon: CustomIconWidget(
              iconName: 'person_add',
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Add Student',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Loading students...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshStudents,
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    margin: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.transparent20,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterStudents,
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: CustomIconWidget(
                          iconName: 'search',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                      ),
                    ),
                  ),
                  
                  // Students Count
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      children: [
                        Text(
                          '${_filteredStudents.length} Students',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        if (_filteredStudents.length != _students.length)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Filtered',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Students List
                  Expanded(
                    child: _filteredStudents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'people',
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 64,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'No students found'
                                      : 'No students yet',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'Try adjusting your search'
                                      : 'Add your first student to get started',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            itemCount: _filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = _filteredStudents[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 2.h),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.surface,
                                      Theme.of(context).colorScheme.surface.transparent80,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline.transparent10,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(20),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(4.w),
                                  leading: CircleAvatar(
                                    radius: 6.w,
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    backgroundImage: student.avatarUrl != null
                                        ? NetworkImage(student.avatarUrl!)
                                        : null,
                                    child: student.avatarUrl == null
                                        ? Text(
                                            student.firstName.isNotEmpty
                                                ? student.firstName[0].toUpperCase()
                                                : 'S',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    student.fullName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        'Age: ${student.age} • ${student.diagnosis}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.w,
                                          vertical: 0.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          student.severity,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => _editStudent(student),
                                        icon: CustomIconWidget(
                                          iconName: 'edit',
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 20,
                                        ),
                                        tooltip: 'Edit Student',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteIndividualStudent(student),
                                        icon: CustomIconWidget(
                                          iconName: 'delete',
                                          color: Theme.of(context).colorScheme.error,
                                          size: 20,
                                        ),
                                        tooltip: 'Delete Student',
                                      ),
                                      CustomIconWidget(
                                        iconName: 'arrow_forward_ios',
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Navigate to Profile Buddy with student ID
                                    Navigator.pushNamed(
                                      context,
                                      '/profile-buddy',
                                      arguments: {'studentId': student.id},
                                    );
                                  },
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

extension on _StudentsListScreenState {
  Future<void> _editStudent(StudentModel student) async {
    final firstController = TextEditingController(text: student.firstName);
    final lastController = TextEditingController(text: student.lastName);
    final ageController = TextEditingController(text: student.age.toString());
    final diagnosisController = TextEditingController(text: student.diagnosis);
    final communicationController = TextEditingController(text: student.communicationLevel);
    final sensoryController = TextEditingController(text: student.sensoryNeeds);
    String severity = student.severity;
    String gender = student.gender;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: diagnosisController,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
              ),
              TextField(
                controller: communicationController,
                decoration: const InputDecoration(labelText: 'Communication Level'),
              ),
              TextField(
                controller: sensoryController,
                decoration: const InputDecoration(labelText: 'Sensory Needs'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: gender.isNotEmpty ? gender : 'Male',
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (val) { if (val != null) gender = val; },
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              DropdownButtonFormField<String>(
                value: severity.isNotEmpty ? severity : 'mild',
                items: const [
                  DropdownMenuItem(value: 'mild', child: Text('Mild')),
                  DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                  DropdownMenuItem(value: 'severe', child: Text('Severe')),
                ],
                onChanged: (val) { if (val != null) severity = val; },
                decoration: const InputDecoration(labelText: 'Severity'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final updated = student.copyWith(
          firstName: firstController.text.trim(),
          lastName: lastController.text.trim(),
          age: int.tryParse(ageController.text.trim()) ?? student.age,
          diagnosis: diagnosisController.text.trim(),
          communicationLevel: communicationController.text.trim(),
          sensoryNeeds: sensoryController.text.trim(),
          gender: gender,
          severity: severity,
          updatedAt: DateTime.now(),
        );
        await _dataService.updateStudent(student.id!, updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: $e')),
          );
        }
      }
    }
  }
}



