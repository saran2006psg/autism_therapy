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
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        title: Text(
          'My Students',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
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
              color: AppTheme.lightTheme.colorScheme.primary,
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
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Loading students...',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshStudents,
              color: AppTheme.lightTheme.colorScheme.primary,
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    margin: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline.transparent20,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterStudents,
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: CustomIconWidget(
                          iconName: 'search',
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
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
                              color: AppTheme.lightTheme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Filtered',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
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
                                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                  size: 64,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'No students found'
                                      : 'No students yet',
                                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'Try adjusting your search'
                                      : 'Add your first student to get started',
                                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
                                      AppTheme.lightTheme.colorScheme.surface,
                                      AppTheme.lightTheme.colorScheme.surface.transparent80,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.lightTheme.colorScheme.outline.transparent10,
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
                                    backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                                    backgroundImage: student.avatarUrl != null
                                        ? NetworkImage(student.avatarUrl!)
                                        : null,
                                    child: student.avatarUrl == null
                                        ? Text(
                                            student.firstName.isNotEmpty
                                                ? student.firstName[0].toUpperCase()
                                                : 'S',
                                            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                              color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    student.fullName,
                                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.lightTheme.colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        'Age: ${student.age} • ${student.diagnosis}',
                                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.w,
                                          vertical: 0.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.lightTheme.colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          student.severity,
                                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                            color: AppTheme.lightTheme.colorScheme.onSecondaryContainer,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: CustomIconWidget(
                                    iconName: 'arrow_forward_ios',
                                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
