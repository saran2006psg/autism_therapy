import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sizer/sizer.dart';
import 'dart:developer' as developer;

import '../../core/services/firestore_service.dart';

import '../../core/app_export.dart';
import '../../widgets/theme_toggle_widget.dart';
import './widgets/progress_chart_widget.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  String _lastSyncTime = "Just now";
  final int _unreadMessages = 3;
  
  // Real data from DataService
  late DataService _dataService;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dataService = DataService();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (!_dataService.isInitialized) {
        await _dataService.initialize();
      }
      
      setState(() {
        _isLoading = false;
        _lastSyncTime = "Just now";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $e';
      });
    }
  }

  Future<void> _refreshData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Deep refresh strategy - force a complete reset of all data
      
      // Step 1: Reset the DataService cache
      _dataService.clearData(); // This clears all cached data
      
      // Step 2: Re-initialize all data
      await _dataService.initialize();
      
      // Step 3: Ensure all sessions are freshly loaded
      final students = _dataService.getMyStudents();
      for (final student in students) {
        if (student.id != null) {
          await _dataService.refreshSessionsForStudent(student.id!);
        }
      }
      
      // Step 4: Full data refresh
      await _dataService.refreshData();
      
      // Force UI rebuild
      if (mounted) {
        setState(() {
          _isLoading = false;
          _lastSyncTime = "Just now";
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data refreshed successfully'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to refresh data: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleMessageTap() {
    Fluttertoast.showToast(
      msg: "Opening secure messaging...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _handleCalendarIntegration() {
    Fluttertoast.showToast(
      msg: "Adding to calendar...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Colors.white,
    );
  }

  void _handleSessionShare(String sessionId) {
    Fluttertoast.showToast(
      msg: "Sharing session summary...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "ThrivePath",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          const ThemeToggleWidget(),
          GestureDetector(
            onTap: _onEditProfile,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: (_dataService.currentUserAvatarUrl != null && _dataService.currentUserAvatarUrl!.isNotEmpty)
                    ? NetworkImage(_dataService.currentUserAvatarUrl!)
                    : null,
                child: (_dataService.currentUserAvatarUrl == null || _dataService.currentUserAvatarUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 2.w),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _handleMessageTap,
                    icon: CustomIconWidget(
                      iconName: 'notifications',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                if (_unreadMessages > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.error,
                            Theme.of(context).colorScheme.error.transparent80,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.error.transparent30,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(
                        minWidth: 5.w,
                        minHeight: 5.w,
                      ),
                      child: Text(
                        _unreadMessages.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
                  Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                AppResetUtility.resetAndNavigateToLogin(context);
              },
              icon: CustomIconWidget(
                iconName: 'logout',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.surface.withOpacity(0.3),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: _buildCurrentView(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          selectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'assignment',
                  color: _currentIndex == 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              label: 'Activities',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    CustomIconWidget(
                      iconName: 'chat_bubble',
                      color: _currentIndex == 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    if (_unreadMessages > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'account_circle',
                  color: _currentIndex == 2
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentIndex) {
      case 0:
        return _buildActivitiesTab();
      case 1:
        return _buildMessagesTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildActivitiesTab();
    }
  }

  Widget _buildActivitiesTab() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Loading your data...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _initializeData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final students = _dataService.students;
    final sessions = _dataService.sessions;

    if (students.isEmpty) {
      return _buildEmptyState();
    }

    // For now, show the first child's data (in a real app, you might let parent select)
    final currentChild = students.first;
    final childSessions = sessions.where((s) => s.studentId == currentChild.id).toList();
    
    // Collect all activities from child's sessions               
    final childActivities = <Map<String, dynamic>>[];
    for (final session in childSessions) {
      for (final activity in session.activities) {
        // Avoid overriding keys by keeping both original and composite IDs
        final String originalActivityId = activity['id']?.toString() ?? '';
        childActivities.add({
          // Keep a dedicated field for the original activity id inside the session
          'activityId': originalActivityId,
          // Use a separate composite id for UI uniqueness if needed
          'compositeId': '${session.id}_${originalActivityId}',
          'sessionId': session.id,
          'sessionTitle': session.title,
          'sessionDate': session.scheduledDate,
          // Mirror important fields with safe defaults
          'status': activity['status'] ?? 'not_started',
          'completedAt': activity['completedAt'],
          'studentNotes': activity['studentNotes'] ?? '',
          // Also include the rest of activity fields but WITHOUT overriding our keys
          ...Map<String, dynamic>.from(activity)
            ..remove('id'),
        });
      }
    }
    
    // Sort by session date (newest first)
    childActivities.sort((a, b) => 
        (b['sessionDate'] as DateTime).compareTo(a['sessionDate'] as DateTime));

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChildHeader(currentChild),
            SizedBox(height: 3.h),
            _buildProgressChart(currentChild),
            SizedBox(height: 3.h),
            _buildActivitiesOverview(childActivities),
            SizedBox(height: 3.h),
            _buildCompletedActivities(childActivities),
            SizedBox(height: 3.h),
            _buildNotCompletedActivities(childActivities),
            SizedBox(height: 3.h),
            _buildRecentActivities(childActivities),
            SizedBox(height: 10.h), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Children Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'It looks like no children are associated with your account yet. Please contact your therapist to set up the connection.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildHeader(StudentModel child) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.tertiaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              child.firstName[0].toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${child.firstName} ${child.lastName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Age ${child.age} • ${child.diagnosis}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Last sync: $_lastSyncTime',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(StudentModel child) {
    final goals = _dataService.goals.where((g) => g.studentId == child.id).toList();
    
    if (goals.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.trending_up,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 1.h),
            Text(
              'Progress Chart',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Progress data will appear here as your child completes therapy goals.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Create mock progress data from goals for now
    final progressData = goals.take(4).map((goal) => {
      'week': goal.title.split(' ').take(2).join(' '),
      'progress': 65 + (goals.indexOf(goal) * 5), // Simulated progress
    }).toList();

    return ProgressChartWidget(
      progressData: progressData,
      chartType: 'weekly',
    );
  }

  Widget _buildActivitiesOverview(List<Map<String, dynamic>> activities) {
    final totalActivities = activities.length;
    final completedActivities = activities.where((a) => a['status'] == 'completed').length;
    final inProgressActivities = activities.where((a) => a['status'] == 'in_progress').length;
    final notStartedActivities = activities.where((a) => a['status'] == 'not_started').length;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          
          Row(
            children: [
              Expanded(
                child: _buildActivityStatCard(
                  'Total',
                  totalActivities.toString(),
                  Icons.assignment,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildActivityStatCard(
                  'Completed',
                  completedActivities.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          Row(
            children: [
              Expanded(
                child: _buildActivityStatCard(
                  'In Progress',
                  inProgressActivities.toString(),
                  Icons.play_circle_filled,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildActivityStatCard(
                  'Not Started',
                  notStartedActivities.toString(),
                  Icons.radio_button_unchecked,
                  Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 1.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(List<Map<String, dynamic>> activities) {
    // Create a deep copy of the activities to ensure we don't share references
    final activitiesCopy = activities.map((activity) => Map<String, dynamic>.from(activity)).toList();
    
    // Sort by most recent based on completedAt or sessionDate
    activitiesCopy.sort((a, b) {
      final aDate = a['completedAt'] ?? a['sessionDate'] ?? DateTime.now();
      final bDate = b['completedAt'] ?? b['sessionDate'] ?? DateTime.now();
      return bDate.compareTo(aDate); // Most recent first
    });
    
    final recentActivities = activitiesCopy.take(5).toList();

    if (recentActivities.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Activities Yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Activities will appear here once they are assigned.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _refreshData,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          ...recentActivities.map((activity) => _buildActivityCard(activity)),
          
          if (activities.length > 5)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Show all activities
                    _showAllActivitiesDialog(activities, 'All Activities');
                  },
                  child: Text('View All ${activities.length} Activities'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final status = activity['status'] as String;
    final isCompleted = status == 'completed';
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        statusIcon = Icons.play_circle_filled;
        statusText = 'In Progress';
        break;
      default:
        statusColor = Theme.of(context).colorScheme.outline;
        statusIcon = Icons.radio_button_unchecked;
        statusText = 'Not Started';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: status == 'in_progress' 
            ? statusColor.withOpacity(0.05) // Light orange background for in_progress
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: status == 'in_progress' 
            ? Border.all(color: statusColor.withOpacity(0.3), width: 1.5) 
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      activity['sessionTitle'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: status == 'in_progress' 
                    ? Border.all(color: statusColor, width: 1) 
                    : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, 
                      size: status == 'in_progress' ? 18 : 16, 
                      color: statusColor
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: status == 'in_progress' ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            activity['description'] as String? ?? 'No description available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (activity['studentNotes']?.isNotEmpty == true) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      activity['studentNotes'],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (isCompleted && activity['completedAt'] != null) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Completed on ${_formatDate(activity['completedAt'])}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          
          // Activity Action Buttons (parents only)
          SizedBox(height: 2.h),
          if ((_dataService.currentUserRole ?? '').toLowerCase() == 'parent')
            Row(
              children: [
                if (!isCompleted) ...[
                  if (status == 'not_started')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _updateActivityStatus(activity, 'in_progress');

                          // Extract identifiers to pass into the session screen
                          final String? sessionId = activity['sessionId']?.toString();
                          String? activityId = activity['activityId']?.toString();
                          final String? compositeId = activity['compositeId']?.toString() ?? activity['id']?.toString();
                          if ((activityId == null || activityId.isEmpty) && compositeId != null) {
                            activityId = compositeId.contains('_') ? compositeId.split('_').last : compositeId;
                          }

                          if (sessionId != null && activityId != null) {
                            // Navigate to the parent-only session execution screen
                            Navigator.pushNamed(
                              context,
                              '/session-execution-screen',
                              arguments: {
                                'sessionId': sessionId.toString(),
                                'activityId': activityId.toString(),
                                'activityTitle': activity['title']?.toString(),
                              },
                            );
                          } else {
                            // Fallback if we couldn't determine identifiers
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Missing activity identifiers for test run.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(Icons.quiz, size: 18),
                        label: Text('Take Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    )
                  else if (status == 'in_progress')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showCompletionDialog(activity),
                        icon: Icon(Icons.check_circle, size: 18),
                        label: Text('Complete Activity'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  SizedBox(width: 2.w),
                  OutlinedButton.icon(
                    onPressed: () => _showNotesDialog(activity),
                    icon: Icon(Icons.note_add, size: 18),
                    label: Text('Add Notes'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showNotesDialog(activity),
                      icon: Icon(Icons.edit_note, size: 18),
                      label: Text('Edit Notes'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  OutlinedButton.icon(
                    onPressed: () => _updateActivityStatus(activity, 'not_started'),
                    icon: Icon(Icons.refresh, size: 18),
                    label: Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _updateActivityStatus(Map<String, dynamic> activity, String newStatus) async {
    try {
      String? sessionId = activity['sessionId']?.toString();
      String? currentNotes = activity['studentNotes']?.toString();
      // Prefer explicit activityId, else derive from composite id, else fallback to id
      String? activityId = activity['activityId']?.toString();
      final String? compositeId = activity['compositeId']?.toString() ?? activity['id']?.toString();
      if ((activityId == null || activityId.isEmpty) && compositeId != null) {
        activityId = compositeId.contains('_') ? compositeId.split('_').last : compositeId;
      }
      
      if (sessionId != null && activityId != null) {
        await _dataService.updateActivityStatus(
          sessionId, 
          activityId, 
          newStatus, 
          currentNotes
        );
        
        // Refresh session data to ensure parents have latest data
        final studentId = activity['studentId']?.toString();
        if (studentId != null) {
          await _dataService.refreshSessionsForStudent(studentId);
        }
        
        // Immediately clear completedAt for non-completed status
        // This ensures we don't have activities with mixed signals
        if (newStatus != 'completed') {
          // For Firestore update, explicitly set completedAt to null
          await FirestoreService.updateActivityCompletionDate(sessionId, activityId, null);
          activity['completedAt'] = null;
        } else {
          // For completed status, set current timestamp
          final completionTime = DateTime.now();
          await FirestoreService.updateActivityCompletionDate(sessionId, activityId, completionTime);
          activity['completedAt'] = completionTime;
        }
        
        // Update local activity status
        activity['status'] = newStatus;
        
        // Force complete rebuild of activities to avoid duplication issues
        await _resetActivitiesCache();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newStatus == 'in_progress' 
                  ? 'Activity started successfully!' 
                  : newStatus == 'completed'
                    ? 'Activity completed successfully!'
                    : 'Activity reset successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to identify activity. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCompletionDialog(Map<String, dynamic> activity) {
    final TextEditingController notesController = TextEditingController();
    String currentNotes = activity['studentNotes'] ?? '';
    notesController.text = currentNotes;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Complete Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity['title'] ?? 'Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text('Add completion notes (optional):'),
              SizedBox(height: 1.h),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter any notes about the activity completion...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateActivityStatusWithNotes(
                  activity, 
                  'completed', 
                  notesController.text.trim().isEmpty ? null : notesController.text.trim()
                );
              },
              child: Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNotesDialog(Map<String, dynamic> activity) {
    final TextEditingController notesController = TextEditingController();
    String currentNotes = activity['studentNotes'] ?? '';
    notesController.text = currentNotes;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Activity Notes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity['title'] ?? 'Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text('Add or edit notes:'),
              SizedBox(height: 1.h),
              TextField(
                controller: notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter notes about this activity...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateActivityStatusWithNotes(
                  activity, 
                  activity['status'] ?? 'not_started', 
                  notesController.text.trim().isEmpty ? null : notesController.text.trim()
                );
              },
              child: Text('Save Notes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateActivityStatusWithNotes(Map<String, dynamic> activity, String newStatus, String? notes) async {
    try {
      String? sessionId = activity['sessionId']?.toString();
      // Prefer explicit activityId, else derive from composite id, else fallback to id
      String? activityId = activity['activityId']?.toString();
      final String? compositeId = activity['compositeId']?.toString() ?? activity['id']?.toString();
      if ((activityId == null || activityId.isEmpty) && compositeId != null) {
        activityId = compositeId.contains('_') ? compositeId.split('_').last : compositeId;
      }
      
      if (sessionId != null && activityId != null) {
        await _dataService.updateActivityStatus(
          sessionId, 
          activityId, 
          newStatus, 
          notes
        );
        
        // Refresh session data to ensure parents have latest data
        final studentId = activity['studentId']?.toString();
        if (studentId != null) {
          await _dataService.refreshSessionsForStudent(studentId);
        }
        
        // Manually update the activity status in the UI to ensure consistency
        activity['status'] = newStatus;
        activity['studentNotes'] = notes;
        
        // Update completion date in Firestore and local state
        if (newStatus == 'completed') {
          final completionTime = DateTime.now();
          await FirestoreService.updateActivityCompletionDate(sessionId, activityId, completionTime);
          activity['completedAt'] = completionTime;
        } else if (newStatus == 'not_started' || newStatus == 'in_progress') {
          // For non-completed status, clear the completion date
          await FirestoreService.updateActivityCompletionDate(sessionId, activityId, null);
          activity['completedAt'] = null;
        }
        
        // Force complete rebuild of activities to avoid duplication issues
        await _resetActivitiesCache();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                notes != null 
                  ? 'Activity notes updated successfully!' 
                  : 'Activity status updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to identify activity to update.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMessagesTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Communication overview card
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.tertiaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.message,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Messages',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Stay connected with your therapy team',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_unreadMessages > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_unreadMessages',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onError,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Communication Features",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildFeatureCard(
              "Secure Messaging",
              "Direct communication with therapy team",
              "chat",
              Theme.of(context).colorScheme.primary,
              _handleMessageTap,
            ),
            SizedBox(height: 2.h),
            _buildFeatureCard(
              "Progress Sharing",
              "Share session summaries with family",
              "share",
              Theme.of(context).colorScheme.secondary,
              () => _handleSessionShare("general"),
            ),
            SizedBox(height: 2.h),
            _buildFeatureCard(
              "Appointment Scheduling",
              "Request or reschedule therapy sessions",
              "schedule",
              Theme.of(context).colorScheme.tertiary,
              _handleCalendarIntegration,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) {
                  final students = _dataService.students;
                  final currentChild = students.isNotEmpty ? students.first : null;
                  
                  if (currentChild != null) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: _onChangeAvatarTapped,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            backgroundImage: (_dataService.currentUserAvatarUrl != null && _dataService.currentUserAvatarUrl!.isNotEmpty)
                                ? NetworkImage(_dataService.currentUserAvatarUrl!)
                                : null,
                            child: (_dataService.currentUserAvatarUrl == null || _dataService.currentUserAvatarUrl!.isEmpty)
                                ? Text(
                                    currentChild.firstName[0].toUpperCase(),
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${currentChild.firstName} ${currentChild.lastName}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "Age ${currentChild.age} • ${currentChild.diagnosis}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No Child Profile',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "No children associated with this account",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Account Settings",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildSettingsItem("Edit Profile", "settings", _onEditProfile),
            _buildSettingsItem(
                "Notification Preferences", "notifications", () {}),
            _buildSettingsItem("Privacy Settings", "security", () {}),
            _buildSettingsItem("Data Export", "download", () {}),
            SizedBox(height: 3.h),
            Text(
              "Support",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildSettingsItem("Help Center", "help", () {}),
            _buildSettingsItem("Contact Support", "support", () {}),
            _buildSettingsItem("App Feedback", "feedback", () {}),
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: 'security',
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "HIPAA Compliant",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Your child's therapy data is protected with enterprise-grade security and healthcare compliance standards.",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, String iconName,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onEditProfile() async {
    final nameController = TextEditingController(
      text: (_dataService.currentUserProfile?['displayName'] as String?) ?? '',
    );
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _onChangeAvatarTapped,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Change Photo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                await _dataService.updateMyProfile({'displayName': newName});
                if (mounted) setState(() {});
              }
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _onChangeAvatarTapped() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
      if (picked == null) return;

      final uid = DataService().currentUserId;
      if (uid == null) return;

      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('user_avatars').child('$uid.jpg');
      await ref.putData(await picked.readAsBytes(), SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();

      await _dataService.updateMyProfile({'avatarUrl': url});
      if (mounted) setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo: $e')),
        );
      }
    }
  }

  Widget _buildSettingsItem(String title, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedActivities(List<Map<String, dynamic>> activities) {
    // Create deep copies of completed activities to avoid reference issues
    List<Map<String, dynamic>> completedActivities = [];
    
    // Process each activity
    for (var activity in activities) {
      final status = activity['status'] as String? ?? '';
      final completedAt = activity['completedAt'];
      
      // Only include activities that are truly completed
      if (status == 'completed' && completedAt != null) {
        // Create a deep copy to avoid reference issues
        completedActivities.add(Map<String, dynamic>.from(activity));
      }
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completed Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${completedActivities.length} of ${activities.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          if (completedActivities.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'No completed activities yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ...completedActivities.take(3).map((activity) => _buildActivityCard(activity)),
            
          if (completedActivities.length > 3)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Show all completed activities
                    _showAllActivitiesDialog(completedActivities, 'Completed Activities');
                  },
                  child: Text('View All ${completedActivities.length} Completed Activities'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotCompletedActivities(List<Map<String, dynamic>> activities) {
    // Create deep copies of activities to avoid reference issues
    List<Map<String, dynamic>> notStartedActivities = [];
    List<Map<String, dynamic>> inProgressActivities = [];
    
    // Process each activity and ensure it appears in only one category
    for (var activity in activities) {
      final status = activity['status'] as String? ?? 'not_started';
      final completedAt = activity['completedAt'];
      
      // If an activity is marked as completed and has a timestamp, don't include it here
      if (status == 'completed' && completedAt != null) continue;
      
      // Create a deep copy to avoid reference issues
      final activityCopy = Map<String, dynamic>.from(activity);
      
      // Sort into appropriate categories
      if (status == 'in_progress') {
        inProgressActivities.add(activityCopy);
      } else if (status == 'not_started') {
        notStartedActivities.add(activityCopy);
      }
    }
    
    // Combine the lists with in_progress activities first
    final notCompletedActivities = [...inProgressActivities, ...notStartedActivities];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To-Do Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${notCompletedActivities.length} of ${activities.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          if (notCompletedActivities.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'All activities completed!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ...notCompletedActivities.take(3).map((activity) => _buildActivityCard(activity)),
            
          if (notCompletedActivities.length > 3)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Show all not completed activities
                    _showAllActivitiesDialog(notCompletedActivities, 'To-Do Activities');
                  },
                  child: Text('View All ${notCompletedActivities.length} To-Do Activities'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAllActivitiesDialog(List<Map<String, dynamic>> activities, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  title: Text(activity['name'] as String),
                  subtitle: Text(activity['sessionTitle'] as String),
                  leading: _getActivityStatusIcon(activity['status'] as String),
                  trailing: activity['completedAt'] != null 
                      ? Text(_formatDate(activity['completedAt'])) 
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    _showActivityDetailsDialog(activity);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _getActivityStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'in_progress':
        return Icon(Icons.play_circle_filled, color: Colors.orange);
      default:
        return Icon(Icons.radio_button_unchecked, color: Colors.grey);
    }
  }

  void _showActivityDetailsDialog(Map<String, dynamic> activity) {
    final bool isCompleted = activity['status'] == 'completed';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(activity['name'] as String),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Session: ${activity['sessionTitle']}'),
              SizedBox(height: 1.h),
              Text('Status: ${_getStatusText(activity['status'] as String)}'),
              if (isCompleted && activity['completedAt'] != null)
                Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: Text('Completed on: ${_formatDate(activity['completedAt'])}'),
                ),
              if (activity['studentNotes']?.isNotEmpty == true)
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Text('Notes: ${activity['studentNotes']}'),
                ),
              SizedBox(height: 1.h),
              Text(activity['description'] ?? 'No description available'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            if (!isCompleted)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _completeActivity(activity);
                },
                child: Text('Mark Complete'),
              ),
          ],
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      default:
        return 'Not Started';
    }
  }
  
  void _completeActivity(Map<String, dynamic> activity) {
    final TextEditingController notesController = TextEditingController();
    notesController.text = activity['studentNotes'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Complete Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add any notes about the completion:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 1.h),
              TextField(
                controller: notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateActivityStatusWithNotes(
                  activity,
                  'completed',
                  notesController.text.trim().isEmpty ? null : notesController.text.trim()
                );
              },
              child: Text('Complete'),
            ),
          ],
        );
      },
    );
  }
  
  // Method to force resetting of activity lists after status changes
  // This ensures activities only appear in one section
  Future<void> _resetActivitiesCache() async {
    try {
      // Log before refresh for debugging
      developer.log('Resetting activities cache...', name: 'ParentDashboard');
      
      // Step 1: Clear all data
      _dataService.clearData();
      
      // Step 2: Reinitialize data
      await _dataService.initialize();
      
      // Step 3: Refresh sessions for all students
      final students = _dataService.getMyStudents();
      for (final student in students) {
        if (student.id != null) {
          await _dataService.refreshSessionsForStudent(student.id!);
        }
      }
      
      // Step 4: Force a complete rebuild of data from backend
      await Future.delayed(Duration(milliseconds: 500)); // Longer delay to ensure backend sync is complete
      await _dataService.refreshData();
      
      // Force rebuild UI
      if (mounted) {
        setState(() {
          // Force rebuild to ensure updated data shows correctly
          _lastSyncTime = "Just now";
          // Reset loading state
          _isLoading = false;
        });
        
        // Show a subtle confirmation toast
        Fluttertoast.showToast(
          msg: "Data refreshed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
        );
      }
      
      developer.log('Activities cache reset complete', name: 'ParentDashboard');
    } catch (e) {
      developer.log('Error resetting activities cache: $e', name: 'ParentDashboard');
    }
  }
}



