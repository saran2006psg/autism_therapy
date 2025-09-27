import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late DataService _dataService;
  StudentModel? _currentStudent;
  List<SessionModel> _mySessions = [];
  final List<Map<String, dynamic>> _myActivities = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _dataService = DataService();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _dataService.initialize();
      
      final currentUser = AuthService.currentUser;
      if (currentUser?.uid == null) {
        throw Exception('No authenticated user found');
      }

      // Find the student record for current user
      final students = _dataService.students;
      
      // For testing: use the first available student record if current user is a student
      if (students.isNotEmpty) {
        _currentStudent = students.first; // Use first student for testing
      } else {
        throw Exception('No student records found');
      }

      // Load sessions for this student
      _mySessions = _dataService.sessions
          .where((session) => session.studentId == _currentStudent!.id)
          .toList();

      // Load activities from sessions
      _loadActivitiesFromSessions();

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      AppLogger.error('Error initializing student data: $e', name: 'StudentDashboard', error: e);
    }
  }

  void _loadActivitiesFromSessions() {
    _myActivities.clear();
    for (final session in _mySessions) {
      for (final activity in session.activities) {
        _myActivities.add({
          'id': '${session.id}_${activity['id']}',
          'sessionId': session.id,
          'sessionTitle': session.title,
          'sessionDate': session.scheduledDate,
          'status': activity['status'] ?? 'not_started', // not_started, in_progress, completed
          'completedAt': activity['completedAt'],
          'studentNotes': activity['studentNotes'] ?? '',
          ...activity,
        });
      }
    }
    
    // Sort by session date (newest first)
    _myActivities.sort((a, b) => 
        (b['sessionDate'] as DateTime).compareTo(a['sessionDate'] as DateTime));
  }

  Future<void> _refreshData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Refresh student's session data to get the latest activities
      if (_currentStudent?.id != null) {
        await _dataService.refreshSessionsForStudent(_currentStudent!.id!);
      }
      
      await _initializeData();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
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

  Future<void> _updateActivityStatus(String activityId, String newStatus, {String? notes}) async {
    try {
      final activity = _myActivities.firstWhere((a) => a['id'] == activityId);
      final sessionId = activity['sessionId'] as String;
      
      // Update in local data
      setState(() {
        activity['status'] = newStatus;
        activity['studentNotes'] = notes ?? activity['studentNotes'];
        if (newStatus == 'completed') {
          activity['completedAt'] = DateTime.now();
        }
      });

      // Update in Firebase
  await _dataService.updateActivityStatus(sessionId, activity['id'] as String, newStatus, notes);
      
      // Refresh the sessions to ensure parent and therapist have latest data
      if (_currentStudent?.id != null) {
        await _dataService.refreshSessionsForStudent(_currentStudent!.id!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Activity ${newStatus.replaceAll('_', ' ')}!'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating activity: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Loading your activities...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${_currentStudent?.firstName}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              'Ready for your activities?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildActivitiesTab();
      case 1:
        return _buildProgressTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildActivitiesTab();
    }
  }

  Widget _buildActivitiesTab() {
    if (_myActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Activities Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your therapist will assign activities for you soon!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _myActivities.length,
        itemBuilder: (context, index) {
          final activity = _myActivities[index];
          return _buildActivityCard(activity);
        },
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final status = activity['status'] as String;
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';
    
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
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with session info
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    (activity['sessionTitle'] as String?) ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      SizedBox(width: 1.w),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Activity content
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (activity['name'] as String?) ?? '',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  (activity['description'] as String?) ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),
                
                // Duration and difficulty
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.schedule,
                      label: '${activity['duration']} min',
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    SizedBox(width: 2.w),
                    _buildInfoChip(
                      icon: Icons.bar_chart,
                      label: (activity['difficulty'] as String?) ?? 'Unknown',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
                
                if (activity['studentNotes']?.isNotEmpty == true) ...[
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Notes:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          (activity['studentNotes'] as String?) ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: 3.h),
                
                // Action buttons
                Row(
                  children: [
                    if (!isCompleted) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showActivityDialog(activity),
                          icon: Icon(isInProgress ? Icons.edit : Icons.play_arrow),
                          label: Text(isInProgress ? 'Continue' : 'Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showActivityDialog(activity),
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                          ),
                        ),
                      ),
                    ],
                    if (isInProgress) ...[
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _completeActivity(activity),
                          icon: const Icon(Icons.check),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 1.w),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityDialog(Map<String, dynamic> activity) {
    showDialog<void>(
      context: context,
      builder: (context) => ActivityDetailDialog(
        activity: activity,
        onStatusUpdate: _updateActivityStatus,
      ),
    );
  }

  void _completeActivity(Map<String, dynamic> activity) {
    _showCompletionDialog(activity);
  }

  void _showCompletionDialog(Map<String, dynamic> activity) {
    final notesController = TextEditingController(text: (activity['studentNotes'] as String?) ?? '');
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Complete Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Great job! How did the activity go?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Add your notes (optional)',
                hintText: 'How did you feel? What did you learn?',
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
            onPressed: () {
              Navigator.of(context).pop();
              _updateActivityStatus(
                activity['id'] as String,
                'completed',
                notes: notesController.text.trim(),
              );
            },
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    final completedActivities = _myActivities.where((a) => a['status'] == 'completed').length;
    final totalActivities = _myActivities.length;
    final completionRate = totalActivities > 0 ? completedActivities / totalActivities : 0.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress overview
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.tertiaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                CircularProgressIndicator(
                  value: completionRate,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${(completionRate * 100).toInt()}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$completedActivities of $totalActivities activities completed',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Recent achievements
          Text(
            'Recent Achievements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          
          ...(_myActivities
              .where((a) => a['status'] == 'completed')
              .take(5)
              .map(_buildAchievementCard)),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (activity['name'] as String?) ?? '',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (activity['completedAt'] != null)
                  Text(
                    'Completed ${_formatDate(activity['completedAt'] as DateTime)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Student info
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _currentStudent?.firstName[0].toUpperCase() ?? 'S',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _currentStudent?.fullName ?? 'Student',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Age ${_currentStudent?.age}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Activities',
                  _myActivities.length.toString(),
                  Icons.assignment,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  _myActivities.where((a) => a['status'] == 'completed').length.toString(),
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 3.h),
          
          // Settings
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await AuthService.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Activity Detail Dialog
class ActivityDetailDialog extends StatefulWidget {
  final Map<String, dynamic> activity;
  final Function(String, String, {String? notes}) onStatusUpdate;

  const ActivityDetailDialog({
    super.key,
    required this.activity,
    required this.onStatusUpdate,
  });

  @override
  State<ActivityDetailDialog> createState() => _ActivityDetailDialogState();
}

class _ActivityDetailDialogState extends State<ActivityDetailDialog> {
  late TextEditingController _notesController;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: (widget.activity['studentNotes'] as String?) ?? '');
    _currentStatus = widget.activity['status'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        (widget.activity['name'] as String?) ?? 'Activity',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (widget.activity['description'] as String?) ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            
            // Status selector
            Text(
              'Status:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            DropdownButtonFormField<String>(
              value: _currentStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'not_started', child: Text('Not Started')),
                DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
              ],
              onChanged: (value) {
                setState(() {
                  _currentStatus = value!;
                });
              },
            ),
            
            SizedBox(height: 2.h),
            
            // Notes
            Text(
              'My Notes:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add your thoughts, questions, or progress...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onStatusUpdate(
              widget.activity['id'] as String,
              _currentStatus,
              notes: _notesController.text.trim(),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
