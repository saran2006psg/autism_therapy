import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import 'dart:ui';

import 'package:thriveers/core/app_export.dart';
import 'package:thriveers/widgets/theme_toggle_widget.dart';
import 'package:thriveers/presentation/session_planning_screen/session_planning_screen.dart';
import 'package:thriveers/presentation/therapist_dashboard/widgets/connectivity_status_widget.dart';
import 'package:thriveers/presentation/therapist_dashboard/widgets/metric_card_widget.dart';
import 'package:thriveers/presentation/therapist_dashboard/widgets/quick_action_sheet_widget.dart';
import 'package:thriveers/presentation/therapist_dashboard/widgets/session_overview_card_widget.dart';
import 'package:thriveers/presentation/therapist_dashboard/widgets/student_progress_card_widget.dart';

class TherapistDashboard extends StatefulWidget {
  const TherapistDashboard({super.key});

  @override
  State<TherapistDashboard> createState() => _TherapistDashboardState();
}

class _TherapistDashboardState extends State<TherapistDashboard>
  with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  final bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  late TabController _tabController;
  
  // DataService instance for real Firestore data
  late DataService _dataService;
  List<StudentModel> _students = [];
  List<SessionModel> _upcomingSessions = [];
  List<SessionModel> _completedSessions = [];
  List<SessionModel> _allSessions = []; // Keep track of all sessions before filtering
  bool _isLoading = true;
  
  // Stream subscriptions for real-time updates
  StreamSubscription<List<StudentModel>>? _studentsSubscription;
  StreamSubscription<List<SessionModel>>? _sessionsSubscription;

  final List<FlSpot> _progressData = [
    const FlSpot(0, 65),
    const FlSpot(1, 70),
    const FlSpot(2, 68),
    const FlSpot(3, 75),
    const FlSpot(4, 78),
    const FlSpot(5, 82),
    const FlSpot(6, 85),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
    _dataService = DataService();
    _loadDashboardData();
    _simulateConnectivity();
  }

  // Convert SessionModel to Map for widgets that expect Map format
  Map<String, dynamic> _sessionToMap(SessionModel session) {
    final student = _students.firstWhere(
      (s) => s.id == session.studentId,
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
    
    return {
      'id': session.id,
      'studentName': student.fullName,
      'sessionType': session.type,
      'time': _formatSessionTime(session),
      'status': session.status,
      'date': _getDateDescription(session.scheduledDate),
    };
  }

  String _formatSessionTime(SessionModel session) {
    if (session.startTime != null && session.endTime != null) {
      final start = session.startTime!;
      final end = session.endTime!;
      return "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
    } else {
      // Use scheduled date + estimated duration
      final start = session.scheduledDate;
      final end = session.scheduledDate.add(Duration(minutes: session.estimatedDuration));
      return "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
    }
  }

  // Convert StudentModel to Map for widgets that expect Map format
  Map<String, dynamic> _studentToMap(StudentModel student) {
    return {
      'id': student.id,
      'name': student.fullName,
      'age': student.age,
      'diagnosis': student.diagnosis,
      'avatar': student.avatarUrl ?? 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400',
      'progress': _calculateStudentProgress(student),
      'goals': student.goalIds, // We would need to fetch actual goals, using IDs for now
      'recentAchievements': _getRecentAchievements(student),
    };
  }

  String _getDateDescription(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);
    
    if (sessionDate == today) {
      return 'Today';
    } else if (sessionDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (sessionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${sessionDate.day}/${sessionDate.month}';
    }
  }

  double _calculateStudentProgress(StudentModel student) {
    // This would normally calculate based on completed goals, session progress, etc.
    // For now, return a default value - you can enhance this based on real progress data
    return 0.75; // 75% progress as default
  }

  List<String> _getRecentAchievements(StudentModel student) {
    // This would normally fetch recent achievements from progress entries
    // For now, return placeholder achievements
    return [
      'Completed recent session',
      'Showing improvement',
    ];
  }

  int _getTodaySessionsCount() {
    final today = DateTime.now();
    return _upcomingSessions.where((session) {
      final sessionDate = session.scheduledDate;
      return sessionDate.year == today.year &&
             sessionDate.month == today.month &&
             sessionDate.day == today.day;
    }).length;
  }

  int _getCompletedTodaySessionsCount() {
    final today = DateTime.now();
    return _upcomingSessions.where((session) {
      final sessionDate = session.scheduledDate;
      return sessionDate.year == today.year &&
             sessionDate.month == today.month &&
             sessionDate.day == today.day &&
             session.status == 'completed';
    }).length;
  }

  String _getCompletionRate() {
    if (_upcomingSessions.isEmpty) return '0%';
    final completed = _upcomingSessions.where((s) => s.status == 'completed').length;
    final rate = (completed / _upcomingSessions.length * 100).round();
    return '$rate%';
  }

  String _getAverageProgress() {
    if (_students.isEmpty) return '0%';
    final totalProgress = _students.map(_calculateStudentProgress).reduce((a, b) => a + b);
    final avgProgress = (totalProgress / _students.length * 100).round();
    return '$avgProgress%';
  }

  /// Filter sessions to only include those with existing students
  void _filterValidSessions(List<SessionModel> sessions) {
    final validSessions = sessions.where((s) => 
      _students.any((student) => student.id == s.studentId)).toList();
    
    _upcomingSessions = validSessions.where((s) => 
      (s.status == 'scheduled' || s.status == 'in_progress') &&
      s.scheduledDate.isAfter(DateTime.now())).toList();
    _completedSessions = validSessions.where((s) => 
      s.status == 'completed').toList();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize data service first
      await _dataService.initialize();
      
      // Get current user ID
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
            _isLoading = false;
          });
          // Filter sessions whenever students are updated
          if (_allSessions.isNotEmpty) {
            setState(() {
              _filterValidSessions(_allSessions);
            });
          }
        },
        onError: (Object error) {
          AppLogger.error('Error streaming students: $error', name: 'TherapistDashboard', error: error);
          // Fallback to DataService if streams fail
          setState(() {
            _students = _dataService.getMyStudents();
            _isLoading = false;
          });
          // Filter sessions with fallback data
          if (_allSessions.isNotEmpty) {
            setState(() {
              _filterValidSessions(_allSessions);
            });
          }
        },
      );
      
      // Set up real-time streams for sessions
      _sessionsSubscription = FirestoreService.streamSessionsForTherapist(userId).listen(
        (sessions) {
          _allSessions = sessions;
          setState(() {
            _filterValidSessions(_allSessions);
          });
        },
        onError: (Object error) {
          AppLogger.error('Error streaming sessions: $error', name: 'TherapistDashboard', error: error);
          // Fallback to DataService if streams fail
          _allSessions = _dataService.getUpcomingSessions() + _dataService.getCompletedSessions();
          setState(() {
            _filterValidSessions(_allSessions);
          });
        },
      );
      
    } catch (e) {
      AppLogger.error('Error loading dashboard data: $e', name: 'TherapistDashboard', error: e);
      // Fallback to DataService if real-time fails
      _students = _dataService.getMyStudents();
      
      // Filter sessions to only include those with existing students
      _allSessions = _dataService.getUpcomingSessions() + _dataService.getCompletedSessions();
      _filterValidSessions(_allSessions);
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentsSubscription?.cancel();
    _sessionsSubscription?.cancel();
    super.dispose();
  }

  void _simulateConnectivity() {
    // Simulate periodic sync
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSyncing = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isSyncing = false;
              _lastSyncTime = DateTime.now();
            });
          }
        });
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _loadDashboardData();
    } catch (e) {
      AppLogger.error('Error refreshing data: $e', name: 'TherapistDashboard', error: e);
    }

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _lastSyncTime = DateTime.now();
      });
    }
  }

  void _showQuickActionSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionSheetWidget(
        onCreateSession: () async {
          final result = await Navigator.push<bool?>(
            context,
            MaterialPageRoute<bool>(
              builder: (context) => const SessionPlanningScreen(),
            ),
          );
          // Refresh data if session was created successfully
          if (result == true) {
            // Data will be updated automatically via streams
          }
        },
        onViewReports: () {
          // Navigate to reports screen
        },
        onSettings: () {
          // Navigate to settings screen
        },
      ),
    );
  }

  void _showMetricContextMenu(String metricType) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to detailed view
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_download',
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Export Data'),
              onTap: () {
                Navigator.pop(context);
                // Export functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Share Progress'),
              onTap: () {
                Navigator.pop(context);
                // Share functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Loading dashboard data...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshData,
                color: Theme.of(context).colorScheme.primary,
                child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _lastSyncTime != null 
                        ? 'Last sync: ${_lastSyncTime!.hour}:${_lastSyncTime!.minute.toString().padLeft(2, '0')}'
                        : 'Never synced',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                actions: [
                  const ThemeToggleWidget(),
                  Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: ConnectivityStatusWidget(
                      isOnline: _isOnline,
                      isSyncing: _isSyncing,
                      lastSyncTime: _lastSyncTime,
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 3.h),
                    // Key Metrics Cards
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: MetricCardWidget(
                                  title: "Today's Sessions",
                                  value: '${_getTodaySessionsCount()}',
                                  subtitle: '${_getCompletedTodaySessionsCount()} completed',
                                  color: Theme.of(context).colorScheme.primary,
                                  onTap: () => Navigator.pushNamed(
                                      context, '/session-planning-screen'),
                                  onLongPress: () =>
                                      _showMetricContextMenu('sessions'),
                                ),
                              ),
                              Expanded(
                                child: MetricCardWidget(
                                  title: 'Active Students',
                                  value: '${_students.length}',
                                  subtitle: 'All progressing',
                                  color: Theme.of(context).colorScheme.secondary,
                                  onTap: () => Navigator.pushNamed(context,
                                      '/students-list'),
                                  onLongPress: () =>
                                      _showMetricContextMenu('students'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Expanded(
                                child: MetricCardWidget(
                                  title: 'Completion Rate',
                                  value: _getCompletionRate(),
                                  subtitle: 'This week',
                                  color: Theme.of(context).colorScheme.tertiary,
                                  onLongPress: () =>
                                      _showMetricContextMenu('completion'),
                                ),
                              ),
                              Expanded(
                                child: MetricCardWidget(
                                  title: 'Avg Progress',
                                  value: _getAverageProgress(),
                                  subtitle: 'All students',
                                  color: Colors.deepPurple,
                                  onLongPress: () =>
                                      _showMetricContextMenu('progress'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Progress Chart
                    Container(
                      width: double.infinity,
                      height: 32.h,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Weekly Progress Trend',
                                        style: AppTheme
                                            .lightTheme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme
                                              .lightTheme.colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        'Student performance overview',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.tertiary,
                                          Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const CustomIconWidget(
                                      iconName: 'trending_up',
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    drawVerticalLine: false,
                                    horizontalInterval: 10,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: AppTheme
                                            .lightTheme.colorScheme.outline
                                            .withValues(alpha: 0.2),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    rightTitles: const AxisTitles(
                                        ),
                                    topTitles: const AxisTitles(
                                        ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 1,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                          const style = TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          );
                                          Widget text;
                                          switch (value.toInt()) {
                                            case 0:
                                              text = const Text('Mon',
                                                  style: style);
                                              break;
                                            case 1:
                                              text = const Text('Tue',
                                                  style: style);
                                              break;
                                            case 2:
                                              text = const Text('Wed',
                                                  style: style);
                                              break;
                                            case 3:
                                              text = const Text('Thu',
                                                  style: style);
                                              break;
                                            case 4:
                                              text = const Text('Fri',
                                                  style: style);
                                              break;
                                            case 5:
                                              text = const Text('Sat',
                                                  style: style);
                                              break;
                                            case 6:
                                              text = const Text('Sun',
                                                  style: style);
                                              break;
                                            default:
                                              text =
                                                  const Text('', style: style);
                                              break;
                                          }
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            child: text,
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 20,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                          return Text(
                                            '${value.toInt()}%',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          );
                                        },
                                        reservedSize: 42,
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: 6,
                                  minY: 50,
                                  maxY: 100,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _progressData,
                                      isCurved: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme
                                              .lightTheme.colorScheme.primary,
                                          AppTheme
                                              .lightTheme.colorScheme.secondary,
                                        ],
                                      ),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        getDotPainter:
                                            (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary,
                                            strokeWidth: 2,
                                            strokeColor: AppTheme
                                                .lightTheme.colorScheme.surface,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme
                                                .lightTheme.colorScheme.primary
                                                .withValues(alpha: 0.3),
                                            AppTheme
                                                .lightTheme.colorScheme.primary
                                                .withValues(alpha: 0.1),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipItems:
                                          (List<LineBarSpot> touchedBarSpots) {
                                        return touchedBarSpots.map((barSpot) {
                                          return LineTooltipItem(
                                            '${barSpot.y.toInt()}%',
                                            TextStyle(
                                              color: AppTheme.lightTheme
                                                  .colorScheme.onSurface,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Upcoming Sessions Section
                    SessionOverviewCardWidget(
                      title: 'Upcoming Sessions',
                      upcomingSessions: _upcomingSessions.map(_sessionToMap).toList(),
                      onSessionTap: (session) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Only parents can run tests. Ask the parent to use their app.'),
                          ),
                        );
                      },
                      onReschedule: (session) {
                        // Handle reschedule
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Session with ${session['studentName']} marked for rescheduling'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Completed Sessions Section
                    SessionOverviewCardWidget(
                      title: 'Completed Sessions',
                      upcomingSessions: _completedSessions.map(_sessionToMap).toList(),
                      onSessionTap: (session) {
                        // Navigate to session details/history
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Viewing details for ${session['studentName']}\'s session'),
                          ),
                        );
                      },
                      onReschedule: (session) {
                        // For completed sessions, this could be "View Report"
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Viewing report for ${session['studentName']}\'s session'),
                          ),
                        );
                      },
                      isCompletedSection: true,
                    ),
                    SizedBox(height: 3.h),

                    // Student Progress Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Student Progress',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, '/profile-buddy'),
                            child: Text(
                              'View All',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(
                      height: 35.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          return StudentProgressCardWidget(
                            student: _studentToMap(_students[index]),
                            onTap: () => Navigator.pushNamed(
                                context, '/profile-buddy'),
                          );
                        },
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Activity Monitoring Section
                    _buildActivityMonitoringSection(),
                    
                    SizedBox(height: 10.h), // Extra space for FAB
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(3.2.w, 0, 3.2.w, MediaQuery.of(context).padding.bottom + 1.2.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                currentIndex: _currentTabIndex,
                onTap: _handleNavigation,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
                selectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                unselectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                items: [
                  _buildNavigationItem(
                    label: 'Dashboard',
                    iconName: 'dashboard',
                    index: 0,
                  ),
                  _buildNavigationItem(
                    label: 'Sessions',
                    iconName: 'calendar_month',
                    index: 1,
                  ),
                  _buildNavigationItem(
                    label: 'Students',
                    iconName: 'groups',
                    index: 2,
                  ),
                  _buildNavigationItem(
                    label: 'Profile',
                    iconName: 'account_circle',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActionSheet,
        child: CustomIconWidget(
          iconName: 'add',
          color: Theme.of(context).colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }
  
  BottomNavigationBarItem _buildNavigationItem({
    required String label,
    required String iconName,
    required int index,
  }) {
    final bool isSelected = _currentTabIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
      label: label,
    );
  }

  Future<void> _handleNavigation(int index) async {
    if (!mounted) return;

    if (index == 0) {
      setState(() {
        _currentTabIndex = 0;
      });
      return;
    }

    setState(() {
      _currentTabIndex = index;
    });

    String? routeName;
    switch (index) {
      case 1:
        routeName = AppRoutes.sessionPlanning;
        break;
      case 2:
        routeName = AppRoutes.studentsList;
        break;
      case 3:
        routeName = AppRoutes.therapistProfile;
        break;
    }

    if (routeName == null) {
      return;
    }

    await Navigator.pushNamed(context, routeName);

    if (!mounted) return;
    setState(() {
      _currentTabIndex = 0;
    });
  }

  Widget _buildActivityMonitoringSection() {
    // Get all activities from all students' sessions
    final allActivities = <Map<String, dynamic>>[];
    for (final student in _students) {
      final allSessions = [..._upcomingSessions, ..._completedSessions];
      final studentSessions = allSessions.where((s) => s.studentId == student.id).toList();
      for (final session in studentSessions) {
        for (final activity in session.activities) {
          allActivities.add({
            'id': '${session.id}_${activity['id']}',
            'sessionId': session.id,
            'studentId': student.id,
            'studentName': student.fullName,
            'sessionTitle': session.title,
            'sessionDate': session.scheduledDate,
            'status': activity['status'] ?? 'not_started',
            'completedAt': activity['completedAt'],
            'studentNotes': activity['studentNotes'] ?? '',
            ...activity,
          });
        }
      }
    }

    // Sort by most recently updated/completed
    allActivities.sort((a, b) {
      final aTime = a['completedAt'] ?? a['sessionDate'] ?? DateTime.now();
      final bTime = b['completedAt'] ?? b['sessionDate'] ?? DateTime.now();
      return (bTime as DateTime).compareTo(aTime as DateTime);
    });

    final completedActivities = allActivities.where((a) => a['status'] == 'completed').take(5).toList();
    final inProgressActivities = allActivities.where((a) => a['status'] == 'in_progress').take(3).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
            children: [
              Icon(
                Icons.monitor_heart,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Activity Monitoring',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          
          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildActivityStatTile(
                  'Total',
                  allActivities.length.toString(),
                  Icons.assignment,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildActivityStatTile(
                  'Completed Today',
                  allActivities.where((a) => 
                    a['status'] == 'completed' && 
                    a['completedAt'] != null &&
                    _isToday(a['completedAt'] as DateTime?)
                  ).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildActivityStatTile(
                  'In Progress',
                  inProgressActivities.length.toString(),
                  Icons.play_circle_filled,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          if (completedActivities.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              'Recently Completed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            
            ...completedActivities.take(3).map((activity) => 
              _buildActivityMonitoringCard(activity, allowEdit: true)
            ),
          ],
          
          if (inProgressActivities.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              'Activities in Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            
            ...inProgressActivities.map((activity) => 
              _buildActivityMonitoringCard(activity, allowEdit: true)
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityStatTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _refreshActivityStatus(Map<String, dynamic> activity) async {
    try {
      final studentId = activity['studentId']?.toString();
      if (studentId == null) {
        throw Exception('Student ID not found in activity data');
      }
      
      // Refresh sessions for this student to get the latest activity status
      await _dataService.refreshSessionsForStudent(studentId);
      
      // Trigger a UI update
      if (mounted) {
        setState(() {});
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Activity status refreshed'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh activity: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildActivityMonitoringCard(Map<String, dynamic> activity, {bool allowEdit = false}) {
    final status = activity['status'] as String;
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        statusIcon = Icons.play_circle_filled;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.outline;
        statusIcon = Icons.radio_button_unchecked;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 16),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['name'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${activity['studentName']} • ${activity['sessionTitle']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (activity['studentNotes']?.isNotEmpty == true) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    'Note: ${activity['studentNotes']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (activity['completedAt'] != null)
            Text(
              _formatShortDate(activity['completedAt'] as DateTime),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          if (allowEdit)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Refresh activity status',
              onPressed: () => _refreshActivityStatus(activity),
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatShortDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}


