import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';

import '../../core/app_export.dart';
import '../../widgets/theme_toggle_widget.dart';
import '../session_planning_screen/session_planning_screen.dart';
import './widgets/connectivity_status_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/quick_action_sheet_widget.dart';
import './widgets/session_overview_card_widget.dart';
import './widgets/student_progress_card_widget.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
      "id": session.id,
      "studentName": student.fullName,
      "sessionType": session.type,
      "time": _formatSessionTime(session),
      "status": session.status,
      "date": _getDateDescription(session.scheduledDate),
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
      "id": student.id,
      "name": student.fullName,
      "age": student.age,
      "diagnosis": student.diagnosis,
      "avatar": student.avatarUrl ?? "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
      "progress": _calculateStudentProgress(student),
      "goals": student.goalIds, // We would need to fetch actual goals, using IDs for now
      "recentAchievements": _getRecentAchievements(student),
    };
  }

  String _getDateDescription(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);
    
    if (sessionDate == today) {
      return "Today";
    } else if (sessionDate == today.add(const Duration(days: 1))) {
      return "Tomorrow";
    } else if (sessionDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    } else {
      return "${sessionDate.day}/${sessionDate.month}";
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
      "Completed recent session",
      "Showing improvement",
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
    if (_upcomingSessions.isEmpty) return "0%";
    final completed = _upcomingSessions.where((s) => s.status == 'completed').length;
    final rate = (completed / _upcomingSessions.length * 100).round();
    return "$rate%";
  }

  String _getAverageProgress() {
    if (_students.isEmpty) return "0%";
    final totalProgress = _students.map(_calculateStudentProgress).reduce((a, b) => a + b);
    final avgProgress = (totalProgress / _students.length * 100).round();
    return "$avgProgress%";
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
        },
        onError: (error) {
          AppLogger.error('Error streaming students: $error', name: 'TherapistDashboard', error: error);
          // Fallback to DataService if streams fail
          setState(() {
            _students = _dataService.getMyStudents();
            _isLoading = false;
          });
        },
      );
      
      // Set up real-time streams for sessions
      _sessionsSubscription = FirestoreService.streamSessionsForTherapist(userId).listen(
        (sessions) {
          setState(() {
            _upcomingSessions = sessions.where((s) => 
              (s.status == 'scheduled' || s.status == 'in_progress') &&
              s.scheduledDate.isAfter(DateTime.now())).toList();
            _completedSessions = sessions.where((s) => 
              s.status == 'completed').toList();
          });
        },
        onError: (error) {
          AppLogger.error('Error streaming sessions: $error', name: 'TherapistDashboard', error: error);
          // Fallback to DataService if streams fail
          setState(() {
            _upcomingSessions = _dataService.getUpcomingSessions();
            _completedSessions = _dataService.getCompletedSessions();
          });
        },
      );
      
    } catch (e) {
      AppLogger.error('Error loading dashboard data: $e', name: 'TherapistDashboard', error: e);
      // Fallback to DataService if real-time fails
      _students = _dataService.getMyStudents();
      _upcomingSessions = _dataService.getUpcomingSessions();
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionSheetWidget(
        onCreateSession: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SessionPlanningScreen()),
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
    showModalBottomSheet(
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
                size: 24,
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
                size: 24,
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
                size: 24,
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
                                  value: "${_getTodaySessionsCount()}",
                                  subtitle: "${_getCompletedTodaySessionsCount()} completed",
                                  color: Theme.of(context).colorScheme.primary,
                                  onTap: () => Navigator.pushNamed(
                                      context, '/session-planning-screen'),
                                  onLongPress: () =>
                                      _showMetricContextMenu('sessions'),
                                ),
                              ),
                              Expanded(
                                child: MetricCardWidget(
                                  title: "Active Students",
                                  value: "${_students.length}",
                                  subtitle: "All progressing",
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
                                  title: "Completion Rate",
                                  value: _getCompletionRate(),
                                  subtitle: "This week",
                                  color: Theme.of(context).colorScheme.tertiary,
                                  onLongPress: () =>
                                      _showMetricContextMenu('completion'),
                                ),
                              ),
                              Expanded(
                                child: MetricCardWidget(
                                  title: "Avg Progress",
                                  value: _getAverageProgress(),
                                  subtitle: "All students",
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
                          width: 1,
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
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
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
                                    show: true,
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
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
                                        show: true,
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
                                    enabled: true,
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
                      onSessionTap: (session) => Navigator.pushNamed(
                          context, '/session-execution-screen'),
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
                    SizedBox(height: 10.h), // Extra space for FAB
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Navigator.pushNamed(context, '/session-planning-screen');
              break;
            case 2:
              Navigator.pushNamed(context, '/students-list');
              break;
            case 3:
              Navigator.pushNamed(context, '/therapist-profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: _currentTabIndex == 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'event',
              color: _currentTabIndex == 1
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'people',
              color: _currentTabIndex == 2
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentTabIndex == 3
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
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
}


