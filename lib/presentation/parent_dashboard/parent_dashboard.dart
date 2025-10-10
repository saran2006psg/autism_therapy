import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'dart:developer' as developer;

// Import only what we need - no database services
import 'package:thriveers/widgets/custom_icon_widget.dart';
import 'package:thriveers/widgets/theme_toggle_widget.dart';
import 'package:thriveers/presentation/parent_dashboard/widgets/progress_chart_widget.dart';
import 'package:thriveers/presentation/parent_dashboard/widgets/completed_activities_widget.dart';
import 'package:thriveers/presentation/parent_dashboard/widgets/not_completed_activities_widget.dart';
import 'package:thriveers/presentation/parent_dashboard/widgets/parent_empty_state_widget.dart';
import 'package:thriveers/core/services/auth_service.dart';
import 'package:thriveers/routes/app_routes.dart';

// Mock data models
class MockChild {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final String diagnosis;
  
  MockChild({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.diagnosis,
  });
}

class MockSession {
  final String id;
  final String studentId;
  final String title;
  final DateTime scheduledDate;
  final List<Map<String, dynamic>> activities;
  
  MockSession({
    required this.id,
    required this.studentId,
    required this.title,
    required this.scheduledDate,
    required this.activities,
  });
}

class MockGoal {
  final String id;
  final String studentId;
  final String title;
  
  MockGoal({
    required this.id,
    required this.studentId,
    required this.title,
  });
}

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final int _unreadMessages = 3;
  int _selectedChildIndex = 0; // Track which child is selected
  
  // Mock data - no database connection
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserAvatarUrl;
  Map<String, dynamic>? _currentUserProfile = {
    'displayName': 'Sarah Johnson',
    'email': 'muni@gmail.com',
    'role': 'Parent',
  };
  
  // Mock children data
  final List<MockChild> _mockChildren = [
    MockChild(
      id: '1',
      firstName: 'Emma',
      lastName: 'Johnson',
      age: 8,
      diagnosis: 'Autism Spectrum Disorder',
    ),
    MockChild(
      id: '2',
      firstName: 'Liam',
      lastName: 'Johnson',
      age: 6,
      diagnosis: 'Speech Delay',
    ),
  ];
  
  // Mock sessions data
  final List<MockSession> _mockSessions = [];
  final List<MockGoal> _mockGoals = [];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  Future<void> _initializeMockData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final now = DateTime.now();

      final generatedSessions = <MockSession>[
        MockSession(
          id: 'session_1',
          studentId: '1',
          title: 'Social Skills Coaching',
          scheduledDate: now.subtract(const Duration(days: 2)),
          activities: [
            {
              'id': 'activity_1',
              'title': 'Emotion Matching Game',
              'description': 'Practice identifying emotions with flashcards and role play.',
              'status': 'completed',
              'completedAt': now.subtract(const Duration(days: 1)),
              'studentNotes': 'Loved the interactive cards.',
              'therapistNotes': 'Continue reinforcing emotion vocabulary at home.',
            },
            {
              'id': 'activity_2',
              'title': 'Conversation Turn Taking',
              'description': 'Use a talking stick to practice conversational turns with peers.',
              'status': 'in_progress',
              'studentNotes': 'Needed prompts for eye contact.',
            },
          ],
        ),
        MockSession(
          id: 'session_2',
          studentId: '1',
          title: 'Sensory Integration Play',
          scheduledDate: now.add(const Duration(days: 1)),
          activities: [
            {
              'id': 'activity_3',
              'title': 'Balance Board Practice',
              'description': 'Build core strength with guided balance board exercises.',
              'status': 'not_started',
              'studentNotes': '',
            },
            {
              'id': 'activity_4',
              'title': 'Deep Pressure Routine',
              'description': 'Follow the nightly compression blanket routine together.',
              'status': 'not_started',
              'studentNotes': 'Parent to track comfort level before bedtime.',
            },
          ],
        ),
        MockSession(
          id: 'session_3',
          studentId: '2',
          title: 'Speech Sound Practice',
          scheduledDate: now.subtract(const Duration(days: 3)),
          activities: [
            {
              'id': 'activity_5',
              'title': 'Articulation Flashcards',
              'description': 'Practice target sounds using picture cards for 10 minutes daily.',
              'status': 'completed',
              'completedAt': now.subtract(const Duration(days: 2)),
              'studentNotes': 'Responded well with positive reinforcement.',
            },
            {
              'id': 'activity_6',
              'title': 'Story Retell',
              'description': 'Read a short story and retell using target vocabulary.',
              'status': 'in_progress',
              'studentNotes': 'Needs reminders to slow down.',
            },
          ],
        ),
      ];

      final generatedGoals = <MockGoal>[
        MockGoal(id: 'goal_1', studentId: '1', title: 'Improve emotion identification'),
        MockGoal(id: 'goal_2', studentId: '1', title: 'Increase independent play for 15 min'),
        MockGoal(id: 'goal_3', studentId: '2', title: 'Produce L and R sounds accurately'),
        MockGoal(id: 'goal_4', studentId: '2', title: 'Retell stories with clear sentences'),
      ];

      if (!mounted) {
        return;
      }

      setState(() {
        _mockSessions
          ..clear()
          ..addAll(generatedSessions);
        _mockGoals
          ..clear()
          ..addAll(generatedGoals);
  _isLoading = false;
        if (_mockChildren.isNotEmpty && _selectedChildIndex >= _mockChildren.length) {
          _selectedChildIndex = 0;
        }
      });
    } catch (e, stackTrace) {
      developer.log(
        'Failed to initialize mock data',
        error: e,
        stackTrace: stackTrace,
        name: 'ParentDashboard',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load dashboard data.';
      });
    }
  }

  Future<void> _refreshData() async {
    await _initializeMockData();
    if (!mounted) {
      return;
    }

    Fluttertoast.showToast(
      msg: 'Dashboard refreshed',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _handleMessageTap() {
    Fluttertoast.showToast(
      msg: 'Opening secure messaging…',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _handleCalendarIntegration() {
    Fluttertoast.showToast(
      msg: 'Adding session to calendar…',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _handleSessionShare(String sessionId) {
    Fluttertoast.showToast(
      msg: 'Sharing session summary…',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'ThrivePath',
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
          SizedBox(width: 4.w),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
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
              onPressed: _initializeMockData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final students = _mockChildren;
    final sessions = _mockSessions;

    if (students.isEmpty) {
      return _buildEmptyState();
    }

    // Ensure selected index is valid
    if (_selectedChildIndex >= students.length) {
      _selectedChildIndex = 0;
    }

    // Use the selected child's data
    final currentChild = students[_selectedChildIndex];
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
          'compositeId': '${session.id}_$originalActivityId',
          'sessionId': session.id,
          'sessionTitle': session.title,
          'sessionDate': session.scheduledDate,
          'studentId': currentChild.id, // Add studentId to the activity
          // Mirror important fields with safe defaults
          'status': activity['status'] ?? 'not_started',
          'completedAt': activity['completedAt'],
          'studentNotes': activity['studentNotes'] ?? '',
          'title': activity['title'] ?? 'Activity', // Ensure title is never null
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
            // Removed child selector and header per updated design
            _buildProgressChart(currentChild),
            SizedBox(height: 3.h),
            CompletedActivitiesWidget(
              activities: childActivities,
              buildActivityCard: _buildActivityCard,
              onViewAll: () {
                final completedActivities = childActivities
                    .where((a) => a['status'] == 'completed' && a['completedAt'] != null)
                    .toList();
                _showAllActivitiesDialog(completedActivities, 'Completed Activities');
              },
            ),
            SizedBox(height: 3.h),
            NotCompletedActivitiesWidget(
              activities: childActivities,
              buildActivityCard: _buildActivityCard,
              onViewAll: () {
                final notCompleted = childActivities
                    .where((a) => a['status'] != 'completed' || a['completedAt'] == null)
                    .toList();
                _showAllActivitiesDialog(notCompleted, 'To-Do Activities');
              },
            ),
            SizedBox(height: 10.h), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ParentEmptyStateWidget(onRefresh: _refreshData);
  }


  Widget _buildProgressChart(MockChild child) {
    final goals = _mockGoals.where((g) => g.studentId == child.id).toList();
    
    if (goals.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Progress Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Detailed progress tracking will appear here as ${child.firstName} completes therapy activities and goals.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Charts will update after first session',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
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
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final status = _activityStatus(activity);
    final isCompleted = status == 'completed';

    final activityName = _activityName(activity);
    final sessionTitle = _activitySessionTitle(activity);
    final description = _activityDescription(activity);
    final studentNotes = _activityNotes(activity);

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

    return Card(
      elevation: status == 'in_progress' ? 3 : 1,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: status == 'in_progress' 
              ? statusColor.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: status == 'in_progress' ? 1.5 : 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: status == 'in_progress' 
              ? statusColor.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(4.w),
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
                      activityName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      sessionTitle,
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
                    ? Border.all(color: statusColor) 
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
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (_activityHasNotes(activity)) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                      studentNotes,
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
          if ((_currentUserProfile?['role'] ?? '').toLowerCase() == 'parent')
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
                                'activityTitle': activityName,
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
                        icon: const Icon(Icons.quiz, size: 18),
                        label: const Text('Take Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    )
                  else if (status == 'in_progress')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showCompletionDialog(activity),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Complete Activity'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  SizedBox(width: 2.w),
                  OutlinedButton.icon(
                    onPressed: () => _showNotesDialog(activity),
                    icon: const Icon(Icons.note_add, size: 18),
                    label: const Text('Add Notes'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showNotesDialog(activity),
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('Edit Notes'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  OutlinedButton.icon(
                    onPressed: () => _updateActivityStatus(activity, 'not_started'),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ],
              ],
            ),
        ],
        ),
      ),
    );
  }

  DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      // For Firestore Timestamp or similar types with toDate()
      final dynamic converted = value.toDate();
      if (converted is DateTime) return converted;
    } catch (_) {}
    return null;
  }

  String _formatDate(dynamic date) {
    final dt = _asDateTime(date);
    if (dt == null) return 'Unknown date';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _activityStatus(Map<String, dynamic> activity) {
    final dynamic rawStatus = activity['status'];
    if (rawStatus is String && rawStatus.isNotEmpty) {
      return rawStatus;
    }
    if (rawStatus != null) {
      return rawStatus.toString();
    }
    return 'not_started';
  }

  String _activityName(Map<String, dynamic> activity) {
    final dynamic rawTitle = activity['title'] ?? activity['name'];
    if (rawTitle is String && rawTitle.trim().isNotEmpty) {
      return rawTitle.trim();
    }
    return 'Activity';
  }

  String _activitySessionTitle(Map<String, dynamic> activity) {
    final dynamic sessionTitle = activity['sessionTitle'] ?? activity['session']?['title'];
    if (sessionTitle is String && sessionTitle.trim().isNotEmpty) {
      return sessionTitle.trim();
    }
    return 'Therapy Session';
  }

  String _activityDescription(Map<String, dynamic> activity) {
    final dynamic description = activity['description'] ?? activity['details'];
    if (description is String && description.trim().isNotEmpty) {
      return description.trim();
    }
    return 'Description coming soon.';
  }

  String _activityNotes(Map<String, dynamic> activity) {
    final dynamic notes = activity['studentNotes'] ?? activity['notes'];
    if (notes is String && notes.trim().isNotEmpty) {
      return notes.trim();
    }
    return 'No notes yet.';
  }

  bool _activityHasNotes(Map<String, dynamic> activity) {
    final dynamic notes = activity['studentNotes'] ?? activity['notes'];
    return notes is String && notes.trim().isNotEmpty;
  }

  Future<void> _updateActivityStatus(Map<String, dynamic> activity, String newStatus) async {
    try {
      final String? sessionId = activity['sessionId']?.toString();
      // Prefer explicit activityId, else derive from composite id, else fallback to id
      String? activityId = activity['activityId']?.toString();
      final String? compositeId = activity['compositeId']?.toString() ?? activity['id']?.toString();
      if ((activityId == null || activityId.isEmpty) && compositeId != null) {
        activityId = compositeId.contains('_') ? compositeId.split('_').last : compositeId;
      }
      
      if (sessionId != null && activityId != null) {
        // Mock update - no actual database call
        await Future<void>.delayed(const Duration(milliseconds: 300));
        
        // Refresh mock data
        final studentId = activity['studentId']?.toString();
        if (studentId != null) {
          // Mock refresh - update local state (no-op for mock data)
        }
        
        // Update completion date in mock data
        if (newStatus != 'completed') {
          // For non-completed status, clear completedAt
          activity['completedAt'] = null;
        } else {
          // For completed status, set current timestamp
          final completionTime = DateTime.now();
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
    final String currentNotes = (activity['studentNotes'] as String?) ?? '';
    notesController.text = currentNotes;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (activity['title'] as String?) ?? 'Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              const Text('Add completion notes (optional):'),
              SizedBox(height: 1.h),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter any notes about the activity completion...',
                  border: OutlineInputBorder(),
                ),
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
                Navigator.of(context).pop();
                await _updateActivityStatusWithNotes(
                  activity, 
                  'completed', 
                  notesController.text.trim().isEmpty ? null : notesController.text.trim()
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
  }

  void _showNotesDialog(Map<String, dynamic> activity) {
    final TextEditingController notesController = TextEditingController();
    final String currentNotes = (activity['studentNotes'] as String?) ?? '';
    notesController.text = currentNotes;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Activity Notes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (activity['title'] as String?) ?? 'Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              const Text('Add or edit notes:'),
              SizedBox(height: 1.h),
              TextField(
                controller: notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter notes about this activity...',
                  border: OutlineInputBorder(),
                ),
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
                Navigator.of(context).pop();
                await _updateActivityStatusWithNotes(
                  activity, 
                  activity['status']?.toString() ?? 'not_started', 
                  notesController.text.trim().isEmpty ? null : notesController.text.trim()
                );
              },
              child: const Text('Save Notes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateActivityStatusWithNotes(Map<String, dynamic> activity, String newStatus, String? notes) async {
    try {
      final String? sessionId = activity['sessionId']?.toString();
      // Prefer explicit activityId, else derive from composite id, else fallback to id
      String? activityId = activity['activityId']?.toString();
      final String? compositeId = activity['compositeId']?.toString() ?? activity['id']?.toString();
      if ((activityId == null || activityId.isEmpty) && compositeId != null) {
        activityId = compositeId.contains('_') ? compositeId.split('_').last : compositeId;
      }
      
      if (sessionId != null && activityId != null) {
        // Mock update - no actual database call
        await Future<void>.delayed(const Duration(milliseconds: 300));
        
        // Refresh mock data
        final studentId = activity['studentId']?.toString();
        if (studentId != null) {
          // Mock refresh - nothing additional required for local data
        }
        
        // Manually update the activity status in the UI to ensure consistency
        activity['status'] = newStatus;
        activity['studentNotes'] = notes;
        
        // Update completion date in mock data
        if (newStatus == 'completed') {
          final completionTime = DateTime.now();
          activity['completedAt'] = completionTime;
        } else if (newStatus == 'not_started' || newStatus == 'in_progress') {
          // For non-completed status, clear the completion date
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
              'Communication Features',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildFeatureCard(
              'Secure Messaging',
              'Direct communication with therapy team',
              'chat',
              Theme.of(context).colorScheme.primary,
              _handleMessageTap,
            ),
            SizedBox(height: 2.h),
            _buildFeatureCard(
              'Progress Sharing',
              'Share session summaries with family',
              'share',
              Theme.of(context).colorScheme.secondary,
              () => _handleSessionShare('general'),
            ),
            SizedBox(height: 2.h),
            _buildFeatureCard(
              'Appointment Scheduling',
              'Request or reschedule therapy sessions',
              'schedule',
              Theme.of(context).colorScheme.tertiary,
              _handleCalendarIntegration,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(4.w),
              child: Builder(
                builder: (context) {
                  final parentProfile = _currentUserProfile;
                  final displayName = (parentProfile?['displayName'] as String?) ?? 'Parent';
                  final email = (parentProfile?['email'] as String?) ?? '';
                  final role = (parentProfile?['role'] as String?) ?? 'Parent';
                  
                  // Get parent's initial from display name or email
                  String initial = 'P';
                  if (displayName.isNotEmpty && displayName != 'Parent') {
                    initial = displayName[0].toUpperCase();
                  } else if (email.isNotEmpty) {
                    initial = email[0].toUpperCase();
                  }
                  
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: _onChangeAvatarTapped,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              backgroundImage: (_currentUserAvatarUrl != null && _currentUserAvatarUrl!.isNotEmpty)
                                  ? NetworkImage(_currentUserAvatarUrl!)
                                  : null,
                              child: (_currentUserAvatarUrl == null || _currentUserAvatarUrl!.isEmpty)
                                  ? Text(
                                      initial,
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(1.5.w),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              email,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
              ),
            ),
            SizedBox(height: 4.h),
            
            // Classical Menu Section
            _buildClassicalMenu(),
            SizedBox(height: 4.h),
          ],
        ),
      ),
      ),
    );
  }

  // Quick Stats Section with modern cards
  // Classical Menu Section - Clean and Traditional Design
  Widget _buildClassicalMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Menu
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.2,
              ),
              width: 1,
            ),
          ),
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _buildClassicalMenuItem(
                Icons.calendar_today_outlined,
                'Activities',
                'View and manage activities',
                () {
                  setState(() {
                    _currentIndex = 0; // Switch to Activities tab
                  });
                },
              ),
              _buildMenuDivider(),
              _buildClassicalMenuItem(
                Icons.message_outlined,
                'Messages',
                'Communication and updates',
                () {
                  setState(() {
                    _currentIndex = 1; // Switch to Messages tab
                  });
                },
              ),
              _buildMenuDivider(),
              _buildClassicalMenuItem(
                Icons.analytics_outlined,
                'Progress Reports',
                'View detailed progress',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Progress Reports coming soon'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              _buildMenuDivider(),
              _buildClassicalMenuItem(
                Icons.settings_outlined,
                'Settings',
                'Account and preferences',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Settings coming soon'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        SizedBox(height: 3.h),
        
        // Account Summary - Clean and Simple
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.2,
              ),
              width: 1,
            ),
          ),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              _buildSimpleInfoRow('Member Since', 'January 2024'),
              SizedBox(height: 1.h),
              _buildSimpleInfoRow('Account Type', 'Premium'),
              SizedBox(height: 1.h),
              _buildSimpleInfoRow('Status', 'Active'),
            ],
            ),
          ),
        ),
        
        SizedBox(height: 3.h),
        
        // Help Section
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.2,
              ),
              width: 1,
            ),
          ),
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _buildClassicalMenuItem(
                Icons.help_outline,
                'Help & Support',
                'Get assistance and documentation',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Help & Support coming soon'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              _buildMenuDivider(),
              _buildClassicalMenuItem(
                Icons.info_outline,
                'About',
                'App information and version',
                () {
                  _showAboutDialog();
                },
              ),
            ],
          ),
        ),
        
        SizedBox(height: 3.h),
        
        // Logout Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        
        SizedBox(height: 3.h),
      ],
    );
  }

  // Classical Menu Item - Traditional List Style
  Widget _buildClassicalMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  // Simple Divider for Menu Items
  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
          : Theme.of(context).colorScheme.outline.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }

  // Simple Info Row for Account Information
  Widget _buildSimpleInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // About Dialog
  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About ThrivePath'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ThrivePath'),
              const Text('Version 1.0.0'),
              SizedBox(height: 2.h),
              const Text(
                'A comprehensive therapy management platform designed to support parents and therapists in tracking progress and managing activities.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Handle Logout
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        // Sign out using AuthService
        await AuthService.signOut();
        
        // Navigate to login screen and remove all previous routes
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        }
        
        // Show success message
        Fluttertoast.showToast(
          msg: 'Logged out successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } catch (e) {
        // Show error message
        Fluttertoast.showToast(
          msg: 'Error logging out: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
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


  Future<void> _onChangeAvatarTapped() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      // Show uploading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading photo...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Mock upload delay
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // Mock avatar URL - in real app, this would be uploaded to storage
      const mockAvatarUrl = 'https://via.placeholder.com/150';
      
      // Update local state
      setState(() {
        _currentUserAvatarUrl = mockAvatarUrl;
      });
      
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update photo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showAllActivitiesDialog(List<Map<String, dynamic>> activities, String title) {
    showDialog<void>(
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
                  title: Text(_activityName(activity)),
                  subtitle: Text(_activitySessionTitle(activity)),
                  leading: _getActivityStatusIcon(_activityStatus(activity)),
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
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _getActivityStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'in_progress':
        return const Icon(Icons.play_circle_filled, color: Colors.orange);
      default:
        return const Icon(Icons.radio_button_unchecked, color: Colors.grey);
    }
  }

  void _showActivityDetailsDialog(Map<String, dynamic> activity) {
    final String status = _activityStatus(activity);
    final bool isCompleted = status == 'completed';
    
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_activityName(activity)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Session: ${_activitySessionTitle(activity)}') ,
              SizedBox(height: 1.h),
              Text('Status: ${_getStatusText(status)}'),
              if (isCompleted && activity['completedAt'] != null)
                Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: Text('Completed on: ${_formatDate(activity['completedAt'])}'),
                ),
              if (_activityHasNotes(activity))
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Text('Notes: ${_activityNotes(activity)}'),
                ),
              SizedBox(height: 1.h),
              Text(_activityDescription(activity)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (!isCompleted)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _completeActivity(activity);
                },
                child: const Text('Mark Complete'),
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
    notesController.text = (activity['studentNotes'] as String?) ?? '';
    
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete Activity'),
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
                decoration: const InputDecoration(
                  hintText: 'Enter notes (optional)',
                  border: OutlineInputBorder(),
                ),
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
                Navigator.of(context).pop();
                await _updateActivityStatusWithNotes(
                  activity,
                  'completed',
                  notesController.text.trim().isEmpty ? null : notesController.text.trim()
                );
              },
              child: const Text('Complete'),
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
      
      // Mock refresh - no actual database calls
  await Future<void>.delayed(const Duration(milliseconds: 500));
      
  // Reinitialize mock data
  await _initializeMockData();
      
      // Force rebuild UI
      if (mounted) {
        setState(() {
          // Force rebuild to ensure updated data shows correctly
          _isLoading = false;
        });
        
        // Show a subtle confirmation toast
        Fluttertoast.showToast(
          msg: 'Data refreshed',
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



