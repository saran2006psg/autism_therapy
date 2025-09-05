import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

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
              size: 24,
            ),
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
                                  trailing: CustomIconWidget(
                                    iconName: 'arrow_forward_ios',
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    size: 20,
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



