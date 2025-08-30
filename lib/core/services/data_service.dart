import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import '../models/student_model.dart';
import '../models/session_model.dart';
import '../models/goal_model.dart';
import '../models/progress_model.dart';
import 'firestore_service.dart';
import 'auth_service.dart';
import 'test_data_service.dart';

/// Comprehensive Data Management Service
/// Centralized service for all app data operations with Firestore integration
class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Current user data
  String? _currentUserId;
  String? _currentUserRole;
  Map<String, dynamic>? _currentUserProfile;

  // Data caches
  List<StudentModel> _students = [];
  final List<SessionModel> _sessions = [];
  final List<GoalModel> _goals = [];
  final List<ProgressModel> _progressEntries = [];
  List<ActivityModel> _activities = [];

  // Loading states
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  String? get currentUserId => _currentUserId;
  String? get currentUserRole => _currentUserRole;
  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;
  List<StudentModel> get students => List.unmodifiable(_students);
  List<SessionModel> get sessions => List.unmodifiable(_sessions);
  List<GoalModel> get goals => List.unmodifiable(_goals);
  List<ProgressModel> get progressEntries => List.unmodifiable(_progressEntries);
  List<ActivityModel> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Initialize the data service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);

      final user = AuthService.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      _currentUserId = user.uid;
      
      // Get user profile
      _currentUserProfile = await FirestoreService.getUserProfile(user.uid);
      _currentUserRole = _currentUserProfile?['role'] as String?;

      // Initialize default activities if needed
      await FirestoreService.initializeDefaultActivities();

      // Load initial data based on user role
      if (_currentUserRole?.toLowerCase() == 'therapist') {
        await _loadTherapistData();
        
        // Initialize test data if this is a new therapist with no students
        if (_students.isEmpty && kDebugMode) {
          developer.log('No students found. Initializing test data...', name: 'DataService');
          await TestDataService.initializeTherapistTestData();
          await _loadTherapistData(); // Reload after creating test data
        }
      } else if (_currentUserRole?.toLowerCase() == 'parent') {
        await _loadParentData();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      developer.log('Error initializing DataService: $e', name: 'DataService');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh all data
  Future<void> refreshData() async {
    if (!_isInitialized) return;

    try {
      _setLoading(true);

      if (_currentUserRole?.toLowerCase() == 'therapist') {
        await _loadTherapistData();
      } else if (_currentUserRole?.toLowerCase() == 'parent') {
        await _loadParentData();
      }

      notifyListeners();
    } catch (e) {
      developer.log('Error refreshing data: $e', name: 'DataService');
    } finally {
      _setLoading(false);
    }
  }

  // ================ STUDENT MANAGEMENT ================

  /// Get students for current user
  List<StudentModel> getMyStudents() {
    if (_currentUserRole?.toLowerCase() == 'therapist') {
      return _students.where((s) => s.therapistId == _currentUserId).toList();
    } else if (_currentUserRole?.toLowerCase() == 'parent') {
      return _students.where((s) => s.parentIds.contains(_currentUserId)).toList();
    }
    return [];
  }

  /// Get student by ID
  StudentModel? getStudent(String studentId) {
    try {
      return _students.firstWhere((s) => s.id == studentId);
    } catch (e) {
      return null;
    }
  }

  /// Create new student
  Future<String> createStudent({
    required String firstName,
    required String lastName,
    required int age,
    required DateTime dateOfBirth,
    required String gender,
    required String diagnosis,
    required String communicationLevel,
    required String sensoryNeeds,
    String severity = 'moderate',
    List<String> triggers = const [],
    Map<String, dynamic> emergencyContacts = const {},
    String? avatarUrl,
  }) async {
    try {
      _setLoading(true);

      final student = StudentModel(
        firstName: firstName,
        lastName: lastName,
        age: age,
        dateOfBirth: dateOfBirth,
        gender: gender,
        diagnosis: diagnosis,
        communicationLevel: communicationLevel,
        sensoryNeeds: sensoryNeeds,
        severity: severity,
        triggers: triggers,
        emergencyContacts: emergencyContacts,
        avatarUrl: avatarUrl,
        therapistId: _currentUserId!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final studentId = await FirestoreService.createStudent(student);
      
      // Add to local cache
      final newStudent = student.copyWith(id: studentId);
      _students.add(newStudent);
      
      notifyListeners();
      return studentId;
    } catch (e) {
      developer.log('Error creating student: $e', name: 'DataService');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update student
  Future<void> updateStudent(String studentId, StudentModel updatedStudent) async {
    try {
      _setLoading(true);

      await FirestoreService.updateStudent(studentId, updatedStudent);
      
      // Update local cache
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _students[index] = updatedStudent.copyWith(id: studentId);
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error updating student: $e', name: 'DataService');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================ SESSION MANAGEMENT ================

  /// Get sessions for a student
  List<SessionModel> getSessionsForStudent(String studentId) {
    return _sessions.where((s) => s.studentId == studentId).toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  /// Get upcoming sessions
  List<SessionModel> getUpcomingSessions() {
    final now = DateTime.now();
    return _sessions
        .where((s) => 
            s.scheduledDate.isAfter(now) && 
            (s.status == 'scheduled' || s.status == 'in_progress'))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Get completed sessions
  List<SessionModel> getCompletedSessions() {
    return _sessions
        .where((s) => s.status == 'completed')
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  /// Get completed sessions for a student
  List<SessionModel> getCompletedSessionsForStudent(String studentId) {
    return _sessions
        .where((s) => s.studentId == studentId && s.status == 'completed')
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  /// Get upcoming sessions for a student
  List<SessionModel> getUpcomingSessionsForStudent(String studentId) {
    final now = DateTime.now();
    return _sessions
        .where((s) => 
            s.studentId == studentId && 
            s.scheduledDate.isAfter(now) && 
            (s.status == 'scheduled' || s.status == 'in_progress'))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Create new session
  Future<String> createSession({
    required String studentId,
    required String type,
    required String title,
    required DateTime scheduledDate,
    required int estimatedDuration,
    String? description,
    List<String> goalIds = const [],
    List<Map<String, dynamic>> activities = const [],
  }) async {
    try {
      _setLoading(true);

      // Validate current user
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final session = SessionModel(
        studentId: studentId,
        therapistId: _currentUserId!,
        type: type,
        title: title,
        description: description,
        scheduledDate: scheduledDate,
        estimatedDuration: estimatedDuration,
        goalIds: goalIds,
        activities: activities,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final sessionId = await FirestoreService.createSession(session);
      
      // Add to local cache
      final newSession = session.copyWith(id: sessionId);
      _sessions.add(newSession);
      
      notifyListeners();
      return sessionId;
    } catch (e) {
      developer.log('Error creating session: $e', name: 'DataService');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================ GOAL MANAGEMENT ================

  /// Get goals for a student
  List<GoalModel> getGoalsForStudent(String studentId) {
    return _goals.where((g) => g.studentId == studentId && g.status != 'cancelled').toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get active goals for a student
  List<GoalModel> getActiveGoalsForStudent(String studentId) {
    return _goals
        .where((g) => g.studentId == studentId && g.status == 'active')
        .toList()
      ..sort((a, b) {
        // Sort by priority (high, medium, low) then by creation date
        const priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        final priorityCompare = (priorityOrder[a.priority] ?? 2)
            .compareTo(priorityOrder[b.priority] ?? 2);
        if (priorityCompare != 0) return priorityCompare;
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  /// Create new goal
  Future<String> createGoal({
    required String studentId,
    required String title,
    required String description,
    required String category,
    required DateTime targetDate,
    String priority = 'medium',
    List<String> strategies = const [],
    Map<String, dynamic> measurementCriteria = const {},
  }) async {
    try {
      _setLoading(true);

      final goal = GoalModel(
        studentId: studentId,
        therapistId: _currentUserId!,
        title: title,
        description: description,
        category: category,
        priority: priority,
        targetDate: targetDate,
        strategies: strategies,
        measurementCriteria: measurementCriteria,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final goalId = await FirestoreService.createGoal(goal);
      
      // Add to local cache
      final newGoal = goal.copyWith(id: goalId);
      _goals.add(newGoal);
      
      notifyListeners();
      return goalId;
    } catch (e) {
      developer.log('Error creating goal: $e', name: 'DataService');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String goalId, double progress, {String? notes}) async {
    try {
      await FirestoreService.updateGoalProgress(goalId, progress, notes: notes);
      
      // Update local cache
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        final updatedGoal = _goals[index].copyWith(
          progressPercentage: progress,
          status: progress >= 100.0 ? 'completed' : 'active',
          notes: notes,
          updatedAt: DateTime.now(),
        );
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error updating goal progress: $e', name: 'DataService');
      rethrow;
    }
  }

  // ================ PROGRESS TRACKING ================

  /// Get progress for a student
  List<ProgressModel> getProgressForStudent(String studentId, {String? type}) {
    var progress = _progressEntries.where((p) => p.studentId == studentId);
    if (type != null) {
      progress = progress.where((p) => p.type == type);
    }
    return progress.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Record progress
  Future<void> recordProgress({
    required String studentId,
    required String type,
    required Map<String, dynamic> metrics,
    String? goalId,
    String? sessionId,
    String? notes,
    List<String> mediaFiles = const [],
  }) async {
    try {
      final progress = ProgressModel(
        studentId: studentId,
        goalId: goalId,
        sessionId: sessionId,
        type: type,
        date: DateTime.now(),
        metrics: metrics,
        notes: notes,
        mediaFiles: mediaFiles,
        therapistId: _currentUserId!,
        createdAt: DateTime.now(),
      );

      final progressId = await FirestoreService.recordProgress(progress);
      
      // Add to local cache
      final newProgress = progress.copyWith(id: progressId);
      _progressEntries.add(newProgress);
      
      notifyListeners();
    } catch (e) {
      developer.log('Error recording progress: $e', name: 'DataService');
      rethrow;
    }
  }

  // ================ ACTIVITY MANAGEMENT ================

  /// Get all activities
  Future<void> loadActivities() async {
    try {
      _activities = await FirestoreService.getAllActivities();
      notifyListeners();
    } catch (e) {
      developer.log('Error loading activities: $e', name: 'DataService');
    }
  }

  /// Create custom activity
  Future<String> createActivity({
    required String name,
    required String description,
    required String category,
    required String type,
    String difficulty = 'medium',
    int estimatedDuration = 15,
    String iconName = 'activity',
    List<String> materials = const [],
    List<String> instructions = const [],
    Map<String, dynamic> goals = const {},
  }) async {
    try {
      final activity = ActivityModel(
        name: name,
        description: description,
        category: category,
        type: type,
        difficulty: difficulty,
        estimatedDuration: estimatedDuration,
        iconName: iconName,
        materials: materials,
        instructions: instructions,
        goals: goals,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final activityId = await FirestoreService.createActivity(activity);
      
      // Add to local cache
      final newActivity = activity.copyWith(id: activityId);
      _activities.add(newActivity);
      
      notifyListeners();
      return activityId;
    } catch (e) {
      developer.log('Error creating activity: $e', name: 'DataService');
      rethrow;
    }
  }

  // ================ ANALYTICS ================

  /// Get student progress summary
  Map<String, dynamic> getStudentProgressSummary(String studentId) {
    final student = getStudent(studentId);
    if (student == null) return {};

    final studentGoals = getGoalsForStudent(studentId);
    final studentSessions = getSessionsForStudent(studentId);
    final studentProgress = getProgressForStudent(studentId);

    final activeGoals = studentGoals.where((g) => g.status == 'active').length;
    final completedGoals = studentGoals.where((g) => g.status == 'completed').length;
    final completedSessions = studentSessions.where((s) => s.status == 'completed').length;

    final averageProgress = studentGoals.isNotEmpty
        ? studentGoals.map((g) => g.progressPercentage).reduce((a, b) => a + b) / studentGoals.length
        : 0.0;

    return {
      'student': student,
      'total_goals': studentGoals.length,
      'active_goals': activeGoals,
      'completed_goals': completedGoals,
      'total_sessions': studentSessions.length,
      'completed_sessions': completedSessions,
      'average_progress': averageProgress,
      'recent_progress': studentProgress.take(5).toList(),
      'engagement_trend': _calculateEngagementTrend(studentSessions),
    };
  }

  /// Get dashboard statistics
  Map<String, dynamic> getDashboardStats() {
    final myStudents = getMyStudents();
    final upcomingSessions = getUpcomingSessions();
    final totalGoals = myStudents.fold<int>(0, (sum, student) => 
        sum + getGoalsForStudent(student.id!).length);
    final completedGoals = myStudents.fold<int>(0, (sum, student) => 
        sum + getGoalsForStudent(student.id!).where((g) => g.status == 'completed').length);

    return {
      'total_students': myStudents.length,
      'upcoming_sessions': upcomingSessions.length,
      'total_goals': totalGoals,
      'completed_goals': completedGoals,
      'students_with_recent_progress': _getStudentsWithRecentProgress(),
      'this_week_sessions': _getThisWeekSessions(),
    };
  }

  // ================ PRIVATE METHODS ================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _loadTherapistData() async {
    try {
      // Load students
      _students = await FirestoreService.getStudentsForTherapist(_currentUserId!);
      
      // Load sessions for all students
      _sessions.clear();
      for (final student in _students) {
        final studentSessions = await FirestoreService.getSessionsForStudent(student.id!);
        _sessions.addAll(studentSessions);
      }

      // Load goals for all students
      _goals.clear();
      for (final student in _students) {
        final studentGoals = await FirestoreService.getGoalsForStudent(student.id!);
        _goals.addAll(studentGoals);
      }

      // Load progress for all students
      _progressEntries.clear();
      for (final student in _students) {
        final studentProgress = await FirestoreService.getProgressForStudent(student.id!);
        _progressEntries.addAll(studentProgress);
      }

      // Load activities
      await loadActivities();
    } catch (e) {
      developer.log('Error loading therapist data: $e', name: 'DataService');
      rethrow;
    }
  }

  Future<void> _loadParentData() async {
    try {
      // Load children
      _students = await FirestoreService.getStudentsForParent(_currentUserId!);
      
      // Load sessions for children
      _sessions.clear();
      for (final student in _students) {
        final studentSessions = await FirestoreService.getSessionsForStudent(student.id!);
        _sessions.addAll(studentSessions);
      }

      // Load goals for children
      _goals.clear();
      for (final student in _students) {
        final studentGoals = await FirestoreService.getGoalsForStudent(student.id!);
        _goals.addAll(studentGoals);
      }

      // Load progress for children
      _progressEntries.clear();
      for (final student in _students) {
        final studentProgress = await FirestoreService.getProgressForStudent(student.id!);
        _progressEntries.addAll(studentProgress);
      }
    } catch (e) {
      developer.log('Error loading parent data: $e', name: 'DataService');
      rethrow;
    }
  }

  List<String> _calculateEngagementTrend(List<SessionModel> sessions) {
    // Simplified engagement calculation
    final recentSessions = sessions
        .where((s) => s.status == 'completed')
        .take(5)
        .toList();

    return recentSessions.map((s) {
      final progress = s.progress['completion_rate'] ?? 0.0;
      if (progress > 80) return 'high';
      if (progress > 60) return 'medium';
      return 'low';
    }).toList();
  }

  int _getStudentsWithRecentProgress() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _students.where((student) {
      final recentProgress = _progressEntries
          .where((p) => p.studentId == student.id && p.date.isAfter(oneWeekAgo))
          .isNotEmpty;
      return recentProgress;
    }).length;
  }

  int _getThisWeekSessions() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return _sessions.where((s) => 
        s.scheduledDate.isAfter(startOfWeek) && 
        s.scheduledDate.isBefore(endOfWeek)).length;
  }

  /// Clear all data (for logout)
  void clearData() {
    _currentUserId = null;
    _currentUserRole = null;
    _currentUserProfile = null;
    _students.clear();
    _sessions.clear();
    _goals.clear();
    _progressEntries.clear();
    _activities.clear();
    _isInitialized = false;
    notifyListeners();
  }
}
