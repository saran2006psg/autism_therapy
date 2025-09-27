import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:thriveers/core/models/student_model.dart';
import 'package:thriveers/core/models/session_model.dart';
import 'package:thriveers/core/models/goal_model.dart';
import 'package:thriveers/core/models/progress_model.dart';
import 'package:thriveers/core/utils/app_logger.dart';

/// Comprehensive Firestore Database Service
/// Handles all data operations for the Thriveers app
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // COLLECTION REFERENCES
  static CollectionReference get _usersCollection => _firestore.collection('users');
  static CollectionReference get _studentsCollection => _firestore.collection('students');
  static CollectionReference get _sessionsCollection => _firestore.collection('sessions');
  static CollectionReference get _goalsCollection => _firestore.collection('goals');
  static CollectionReference get _progressCollection => _firestore.collection('progress');
  static CollectionReference get _activitiesCollection => _firestore.collection('activities');

  // ================== STUDENT OPERATIONS ==================

  /// Create a new student profile
  static Future<String> createStudent(StudentModel student) async {
    try {
      final now = DateTime.now();
      final studentData = student.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _studentsCollection.add(studentData.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  /// Get student by ID
  static Future<StudentModel?> getStudent(String studentId) async {
    try {
      final doc = await _studentsCollection.doc(studentId).get();
      if (doc.exists) {
        return StudentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get student: $e');
    }
  }

  /// Get all students for a therapist
  static Future<List<StudentModel>> getStudentsForTherapist(String therapistId) async {
    try {
      // Simplified query to avoid composite index requirement
      final query = await _studentsCollection
          .where('therapistId', isEqualTo: therapistId)
          .get();

      // Filter and sort in memory to avoid index requirement
      final students = query.docs
          .map(StudentModel.fromFirestore)
          .where((student) => student.isActive)
          .toList();
      
      // Sort by firstName in memory
      students.sort((a, b) => a.firstName.compareTo(b.firstName));
      
      return students;
    } catch (e) {
      throw Exception('Failed to get students for therapist: $e');
    }
  }

  /// Stream all students for a therapist (real-time updates)
  static Stream<List<StudentModel>> streamStudentsForTherapist(String therapistId) {
    return _studentsCollection
        .where('therapistId', isEqualTo: therapistId)
        .snapshots()
        .map((snapshot) {
      // Filter and sort in memory to avoid index requirement
      final students = snapshot.docs
          .map(StudentModel.fromFirestore)
          .where((student) => student.isActive)
          .toList();
      
      // Sort by firstName in memory
      students.sort((a, b) => a.firstName.compareTo(b.firstName));
      
      return students;
    });
  }

  /// Get students for a parent
  static Future<List<StudentModel>> getStudentsForParent(String parentId) async {
    try {
      // Simplified query to avoid composite index requirement
      final query = await _studentsCollection
          .where('parentIds', arrayContains: parentId)
          .get();

      // Filter and sort in memory to avoid index requirement
      final students = query.docs
          .map(StudentModel.fromFirestore)
          .where((student) => student.isActive)
          .toList();
      
      // Sort by firstName in memory
      students.sort((a, b) => a.firstName.compareTo(b.firstName));
      
      return students;
    } catch (e) {
      throw Exception('Failed to get students for parent: $e');
    }
  }

  /// Update student profile
  static Future<void> updateStudent(String studentId, StudentModel student) async {
    try {
      final updatedStudent = student.copyWith(updatedAt: DateTime.now());
      await _studentsCollection.doc(studentId).update(updatedStudent.toFirestore());
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  /// Delete student (soft delete)
  static Future<void> deleteStudent(String studentId) async {
    try {
      await _studentsCollection.doc(studentId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  // ================== SESSION OPERATIONS ==================

  /// Create a new session
  static Future<String> createSession(SessionModel session) async {
    try {
      final now = DateTime.now();
      final sessionData = session.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _sessionsCollection.add(sessionData.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  /// Get session by ID
  static Future<SessionModel?> getSession(String sessionId) async {
    try {
      final doc = await _sessionsCollection.doc(sessionId).get();
      if (doc.exists) {
        return SessionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  
  static Future<List<SessionModel>> getSessionsForStudent(String studentId) async {
    try {
      final query = await _sessionsCollection
          .where('studentId', isEqualTo: studentId)
          .get();

      // Sort in-memory to avoid composite index requirement
      final sessions = query.docs.map(SessionModel.fromFirestore).toList();
      sessions.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
      return sessions;
    } catch (e) {
      throw Exception('Failed to get sessions for student: $e');
    }
  }

  /// Stream sessions for a student (real-time updates)
  static Stream<List<SessionModel>> streamSessionsForStudent(String studentId) {
    return _sessionsCollection
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      // Sort in-memory to avoid composite index requirement
      final sessions = snapshot.docs.map(SessionModel.fromFirestore).toList();
      sessions.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
      return sessions;
    });
  }

  /// Get upcoming sessions for a therapist
  static Future<List<SessionModel>> getUpcomingSessionsForTherapist(String therapistId) async {
    try {
      final now = DateTime.now();
      final query = await _sessionsCollection
          .where('therapistId', isEqualTo: therapistId)
          .get();

      // Filter and sort in-memory to avoid composite index requirement
      final sessions = query.docs.map(SessionModel.fromFirestore).toList();
      final filteredSessions = sessions.where((session) => 
        session.scheduledDate.isAfter(now) && 
        (session.status == 'scheduled' || session.status == 'in_progress')
      ).toList();
      
      filteredSessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      return filteredSessions.take(10).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming sessions: $e');
    }
  }

  /// Stream upcoming sessions for a therapist (real-time updates)
  static Stream<List<SessionModel>> streamUpcomingSessionsForTherapist(String therapistId) {
    return _sessionsCollection
        .where('therapistId', isEqualTo: therapistId)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      // Filter and sort in-memory to avoid composite index requirement
      final sessions = snapshot.docs.map(SessionModel.fromFirestore).toList();
      final filteredSessions = sessions.where((session) => 
        session.scheduledDate.isAfter(now) && 
        (session.status == 'scheduled' || session.status == 'in_progress')
      ).toList();
      
      filteredSessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      return filteredSessions.take(10).toList();
    });
  }

  /// Stream all sessions for a therapist (real-time updates)
  static Stream<List<SessionModel>> streamSessionsForTherapist(String therapistId) {
    return _sessionsCollection
        .where('therapistId', isEqualTo: therapistId)
        .snapshots()
        .map((snapshot) {
      final sessions = snapshot.docs.map(SessionModel.fromFirestore).toList();
      sessions.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate)); // Most recent first
      return sessions;
    });
  }

  /// Update session
  static Future<void> updateSession(String sessionId, SessionModel session) async {
    try {
      final updatedSession = session.copyWith(updatedAt: DateTime.now());
      await _sessionsCollection.doc(sessionId).update(updatedSession.toFirestore());
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  /// Start session (update status and start time)
  static Future<void> startSession(String sessionId) async {
    try {
      await _sessionsCollection.doc(sessionId).update({
        'status': 'in_progress',
        'startTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to start session: $e');
    }
  }

  /// Complete session
  static Future<void> completeSession(String sessionId, {
    String? summary,
    List<String>? achievements,
    String? homeworkAssigned,
    String? nextSessionFocus,
    Map<String, dynamic>? progress,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (summary != null) updateData['summary'] = summary;
      if (achievements != null) updateData['achievements'] = achievements;
      if (homeworkAssigned != null) updateData['homeworkAssigned'] = homeworkAssigned;
      if (nextSessionFocus != null) updateData['nextSessionFocus'] = nextSessionFocus;
      if (progress != null) updateData['progress'] = progress;

      await _sessionsCollection.doc(sessionId).update(updateData);
    } catch (e) {
      throw Exception('Failed to complete session: $e');
    }
  }

  /// Add session data during execution
  static Future<void> addSessionData(String sessionId, Map<String, dynamic> dataEntry) async {
    try {
      await _sessionsCollection.doc(sessionId).update({
        'sessionData': FieldValue.arrayUnion([dataEntry]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add session data: $e');
    }
  }

  // ================== GOAL OPERATIONS ==================

  /// Create a new goal
  static Future<String> createGoal(GoalModel goal) async {
    try {
      final now = DateTime.now();
      final goalData = goal.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _goalsCollection.add(goalData.toFirestore());
      
      // Add goal ID to student's goalIds
      await _studentsCollection.doc(goal.studentId).update({
        'goalIds': FieldValue.arrayUnion([docRef.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  /// Get goal by ID
  static Future<GoalModel?> getGoal(String goalId) async {
    try {
      final doc = await _goalsCollection.doc(goalId).get();
      if (doc.exists) {
        return GoalModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get goal: $e');
    }
  }

  /// Get goals for a student
  static Future<List<GoalModel>> getGoalsForStudent(String studentId) async {
    try {
      final query = await _goalsCollection
          .where('studentId', isEqualTo: studentId)
          .get();

      // Filter and sort in-memory to avoid composite index requirement
      final goals = query.docs.map(GoalModel.fromFirestore).toList();
      final filteredGoals = goals.where((goal) => goal.status != 'cancelled').toList();
      
      // Sort by status first, then by priority
      filteredGoals.sort((a, b) {
        final int statusComparison = a.status.compareTo(b.status);
        if (statusComparison != 0) return statusComparison;
        return a.priority.compareTo(b.priority);
      });

      return filteredGoals;
    } catch (e) {
      throw Exception('Failed to get goals for student: $e');
    }
  }

  /// Update goal
  static Future<void> updateGoal(String goalId, GoalModel goal) async {
    try {
      final updatedGoal = goal.copyWith(updatedAt: DateTime.now());
      await _goalsCollection.doc(goalId).update(updatedGoal.toFirestore());
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  /// Update goal progress
  static Future<void> updateGoalProgress(String goalId, double progressPercentage, {String? notes}) async {
    try {
      final updateData = <String, dynamic>{
        'progressPercentage': progressPercentage,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (progressPercentage >= 100.0) {
        updateData['status'] = 'completed';
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await _goalsCollection.doc(goalId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update goal progress: $e');
    }
  }

  // ================== PROGRESS OPERATIONS ==================

  /// Record progress entry
  static Future<String> recordProgress(ProgressModel progress) async {
    try {
      final progressData = progress.copyWith(createdAt: DateTime.now());
      final docRef = await _progressCollection.add(progressData.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to record progress: $e');
    }
  }

  /// Get progress for a student
  static Future<List<ProgressModel>> getProgressForStudent(String studentId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _progressCollection.where('studentId', isEqualTo: studentId);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      final progressList = querySnapshot.docs.map(ProgressModel.fromFirestore).toList();
      
      // Sort in-memory to avoid composite index requirement
      progressList.sort((a, b) => b.date.compareTo(a.date));
      
      return progressList;
    } catch (e) {
      throw Exception('Failed to get progress for student: $e');
    }
  }

  // ================== ACTIVITY OPERATIONS ==================

  /// Get all available activities
  static Future<List<ActivityModel>> getAllActivities() async {
    try {
      final query = await _activitiesCollection.get();
      
      // Sort in-memory to avoid composite index requirement
      final activities = query.docs.map(ActivityModel.fromFirestore).toList();
      activities.sort((a, b) {
        final int categoryComparison = (a.category ?? '').compareTo(b.category ?? '');
        if (categoryComparison != 0) return categoryComparison;
        return (a.name ?? '').compareTo(b.name ?? '');
      });
      
      return activities;
    } catch (e) {
      throw Exception('Failed to get activities: $e');
    }
  }

  /// Create custom activity
  static Future<String> createActivity(ActivityModel activity) async {
    try {
      final now = DateTime.now();
      final activityData = activity.copyWith(
        isCustom: true,
        createdBy: currentUserId,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _activitiesCollection.add(activityData.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create activity: $e');
    }
  }

  /// Update activity completion date
  static Future<void> updateActivityCompletionDate(String sessionId, String activityId, DateTime? completionDate) async {
    try {
      // Find the session document first
      final sessionRef = _sessionsCollection.doc(sessionId);
      final sessionSnapshot = await sessionRef.get();
      
      if (!sessionSnapshot.exists) {
        throw Exception('Session not found: $sessionId');
      }
      
      // Update the specific activity within the session
      final updateData = {
        'activities.$activityId.completedAt': completionDate,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // If setting to null (resetting completion), explicitly use null
      if (completionDate == null) {
        await sessionRef.update({
          'activities.$activityId.completedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await sessionRef.update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update activity completion date: $e');
    }
  }

  // ================== UTILITY METHODS ==================

  /// Get user profile data
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile fields (e.g., displayName, avatarUrl)
  static Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Get user ID by email address
  static Future<String?> getUserIdByEmail(String email) async {
    try {
      final querySnapshot = await _usersCollection
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get user ID by email: $e', name: 'FirestoreService', error: e);
      return null;
    }
  }

  /// Real-time session updates stream
  static Stream<SessionModel> sessionStream(String sessionId) {
    return _sessionsCollection.doc(sessionId).snapshots().map(
      SessionModel.fromFirestore,
    );
  }

  /// Real-time students list stream for therapist
  static Stream<List<StudentModel>> studentsStreamForTherapist(String therapistId) {
    return _studentsCollection
        .where('therapistId', isEqualTo: therapistId)
        .snapshots()
        .map((query) {
          // Filter and sort in memory to avoid index requirement
          final students = query.docs
              .map(StudentModel.fromFirestore)
              .where((student) => student.isActive)
              .toList();
          
          // Sort by firstName in memory
          students.sort((a, b) => a.firstName.compareTo(b.firstName));
          
          return students;
        });
  }

  /// Initialize default activities (call once during app setup)
  static Future<void> initializeDefaultActivities() async {
    try {
      // Check if activities already exist
      final existing = await _activitiesCollection.limit(1).get();
      if (existing.docs.isNotEmpty) {
        return; // Activities already initialized
      }

      // Add default activities
      final defaultActivities = _getDefaultActivities();
      final batch = _firestore.batch();

      for (final activity in defaultActivities) {
        final docRef = _activitiesCollection.doc();
        batch.set(docRef, activity.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      AppLogger.error('Failed to initialize default activities: $e', name: 'FirestoreService', error: e);
    }
  }

  /// Get default activities data
  static List<ActivityModel> _getDefaultActivities() {
    final now = DateTime.now();
    return [
      ActivityModel(
        sessionId: '',
        goalId: '',
        activityName: 'Picture Exchange Communication',
        status: 'available',
        startTime: now,
        name: 'Picture Exchange Communication',
        description: 'Using visual cards to communicate basic needs and wants effectively',
        category: 'Communication Skills',
        type: 'communication',
        difficulty: 'easy',
        estimatedDuration: 15,
        iconName: 'chat_bubble_outline',
        materials: ['Picture cards', 'Communication board', 'Velcro strips'].join(', '),
        instructions: [
          'Show picture card to student',
          'Guide student to point to desired item',
          'Practice exchange sequence',
          'Reward successful communication'
        ],
        goals: {'communication': 80, 'independence': 60},
        createdAt: now,
        updatedAt: now,
      ),
      ActivityModel(
        sessionId: '',
        goalId: '',
        activityName: 'Social Story Reading',
        status: 'available',
        startTime: now,
        name: 'Social Story Reading',
        description: 'Interactive storytelling to teach social situations and appropriate responses',
        category: 'Social Skills',
        type: 'social',
        difficulty: 'medium',
        estimatedDuration: 20,
        iconName: 'book',
        materials: ['Social story books', 'Visual aids', 'Discussion cards'].join(', '),
        instructions: [
          'Read story together',
          'Discuss characters and situations',
          'Practice appropriate responses',
          'Role-play scenarios'
        ],
        goals: {'social': 90, 'communication': 70},
        createdAt: now,
        updatedAt: now,
      ),
      ActivityModel(
        sessionId: '',
        goalId: '',
        activityName: 'Sensory Integration Play',
        status: 'available',
        startTime: now,
        name: 'Sensory Integration Play',
        description: 'Activities to help with sensory processing and regulation',
        category: 'Sensory',
        type: 'sensory',
        difficulty: 'medium',
        estimatedDuration: 25,
        iconName: 'touch_app',
        materials: ['Therapy balls', 'Textured materials', 'Weighted blankets'].join(', '),
        instructions: [
          'Assess sensory needs',
          'Introduce materials gradually',
          'Monitor comfort level',
          'Provide calming alternatives'
        ],
        goals: {'sensory': 85, 'self_regulation': 75},
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
