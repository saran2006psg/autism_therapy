import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session_model.dart';
import '../models/progress_model.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

/// Session Execution Service
/// Handles real-time session data collection and Firestore integration
class SessionExecutionService {
  static SessionModel? _currentSession;
  static StreamController<List<Map<String, dynamic>>>? _sessionDataController;
  static Timer? _autoSaveTimer;

  /// Get current session
  static SessionModel? get currentSession => _currentSession;

  /// Session data stream
  static Stream<List<Map<String, dynamic>>> get sessionDataStream =>
      _sessionDataController?.stream ?? const Stream.empty();

  /// Start a new session
  static Future<void> startSession(SessionModel session) async {
    try {
      // Create session in Firestore
      final sessionId = await FirestoreService.createSession(session);
      
      // Update session with ID and start time
      _currentSession = session.copyWith(
        id: sessionId,
        status: 'in_progress',
        startTime: DateTime.now(),
      );

      // Start the session in Firestore
      await FirestoreService.startSession(sessionId);

      // Initialize session data stream
      _sessionDataController = StreamController<List<Map<String, dynamic>>>.broadcast();

      // Start auto-save timer (save every 30 seconds)
      _startAutoSave();

      developer.log('Session started: ${_currentSession!.id}', name: 'SessionExecutionService');
    } catch (e) {
      throw Exception('Failed to start session: $e');
    }
  }

  /// Add data point during session
  static Future<void> addSessionData({
    required String type,
    required dynamic value,
    String? notes,
    String? activityId,
  }) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }

    final dataEntry = {
      'timestamp': FieldValue.serverTimestamp(),
      'activity_id': activityId ?? _getCurrentActivityId(),
      'type': type,
      'value': value,
      'notes': notes,
      'recorded_by': AuthService.currentUser?.uid,
    };

    try {
      // Add to Firestore
      await FirestoreService.addSessionData(_currentSession!.id!, dataEntry);

      // Update local session data and notify listeners
      final currentSessionData = List<Map<String, dynamic>>.from(_currentSession!.sessionData);
      currentSessionData.add(dataEntry);
      
      _currentSession = _currentSession!.copyWith(sessionData: currentSessionData);
      _sessionDataController?.add(currentSessionData);

      developer.log('Session data added: $type = $value', name: 'SessionExecutionService');
    } catch (e) {
      developer.log('Error adding session data: $e', name: 'SessionExecutionService');
      // Store locally for later sync if Firestore fails
      _storeDataLocally(dataEntry);
    }
  }

  /// Add behavioral observation
  static Future<void> addBehavioralObservation(String behavior, {String? notes}) async {
    await addSessionData(
      type: 'behavior',
      value: behavior,
      notes: notes,
    );
  }

  /// Add communication attempt
  static Future<void> addCommunicationAttempt({
    required String method,
    required bool successful,
    String? details,
  }) async {
    await addSessionData(
      type: 'communication',
      value: {
        'method': method,
        'successful': successful,
        'details': details,
      },
    );
  }

  /// Add activity completion
  static Future<void> addActivityCompletion({
    required String activityId,
    required double completionPercentage,
    required int duration,
    String? notes,
  }) async {
    await addSessionData(
      type: 'activity_completion',
      value: {
        'activity_id': activityId,
        'completion_percentage': completionPercentage,
        'duration_minutes': duration,
      },
      notes: notes,
      activityId: activityId,
    );
  }

  /// Add mood/emotional state
  static Future<void> addMoodObservation(String mood, {int? intensity, String? triggers}) async {
    await addSessionData(
      type: 'mood',
      value: {
        'mood': mood,
        'intensity': intensity, // 1-10 scale
        'triggers': triggers,
      },
    );
  }

  /// Add sensory response
  static Future<void> addSensoryResponse({
    required String stimulus,
    required String response,
    String? intensity,
  }) async {
    await addSessionData(
      type: 'sensory',
      value: {
        'stimulus': stimulus,
        'response': response,
        'intensity': intensity,
      },
    );
  }

  /// Add media file (photo/audio)
  static Future<void> addMediaFile(String filePath, String type) async {
    if (_currentSession == null) return;

    try {
      // In a real app, you would upload to Firebase Storage first
      // For now, we'll store the file path
      await FirestoreService.updateSession(
        _currentSession!.id!,
        _currentSession!.copyWith(
          mediaFiles: [..._currentSession!.mediaFiles, filePath],
        ),
      );

      await addSessionData(
        type: 'media',
        value: {
          'file_path': filePath,
          'media_type': type,
        },
      );
    } catch (e) {
      developer.log('Error adding media file: $e', name: 'SessionExecutionService');
    }
  }

  /// Pause session
  static Future<void> pauseSession() async {
    if (_currentSession == null) return;

    try {
      _currentSession = _currentSession!.copyWith(status: 'paused');
      await FirestoreService.updateSession(_currentSession!.id!, _currentSession!);
      _stopAutoSave();
      developer.log('Session paused', name: 'SessionExecutionService');
    } catch (e) {
      developer.log('Error pausing session: $e', name: 'SessionExecutionService');
    }
  }

  /// Resume session
  static Future<void> resumeSession() async {
    if (_currentSession == null) return;

    try {
      _currentSession = _currentSession!.copyWith(status: 'in_progress');
      await FirestoreService.updateSession(_currentSession!.id!, _currentSession!);
      _startAutoSave();
      developer.log('Session resumed', name: 'SessionExecutionService');
    } catch (e) {
      developer.log('Error resuming session: $e', name: 'SessionExecutionService');
    }
  }

  /// Complete session
  static Future<void> completeSession({
    String? summary,
    List<String>? achievements,
    String? homeworkAssigned,
    String? nextSessionFocus,
  }) async {
    if (_currentSession == null) {
      throw Exception('No active session to complete');
    }

    try {
      _stopAutoSave();

      // Calculate session duration
      final startTime = _currentSession!.startTime!;
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMinutes;

      // Update session with actual duration
      _currentSession = _currentSession!.copyWith(
        actualDuration: duration,
        endTime: endTime,
      );

      // Calculate progress metrics
      final progress = _calculateSessionProgress();

      // Complete session in Firestore
      await FirestoreService.completeSession(
        _currentSession!.id!,
        summary: summary,
        achievements: achievements,
        homeworkAssigned: homeworkAssigned,
        nextSessionFocus: nextSessionFocus,
        progress: progress,
      );

      // Record progress entry
      await _recordProgressEntries();

      // Update goals progress if applicable
      await _updateGoalsProgress(progress);

      developer.log('Session completed: ${_currentSession!.id}', name: 'SessionExecutionService');
      
      // Clean up
      await _cleanup();
    } catch (e) {
      throw Exception('Failed to complete session: $e');
    }
  }

  /// Cancel session
  static Future<void> cancelSession({String? reason}) async {
    if (_currentSession == null) return;

    try {
      _stopAutoSave();

      await FirestoreService.updateSession(
        _currentSession!.id!,
        _currentSession!.copyWith(
          status: 'cancelled',
          endTime: DateTime.now(),
          summary: reason != null ? 'Session cancelled: $reason' : 'Session cancelled',
        ),
      );

      await _cleanup();
      developer.log('Session cancelled', name: 'SessionExecutionService');
    } catch (e) {
      developer.log('Error cancelling session: $e', name: 'SessionExecutionService');
    }
  }

  /// Get session statistics
  static Map<String, dynamic> getSessionStatistics() {
    if (_currentSession == null) return {};

    final sessionData = _currentSession!.sessionData;
    final stats = <String, dynamic>{
      'total_data_points': sessionData.length,
      'behavioral_observations': 0,
      'communication_attempts': 0,
      'activities_completed': 0,
      'media_files': _currentSession!.mediaFiles.length,
    };

    for (final data in sessionData) {
      final type = data['type'] as String;
      switch (type) {
        case 'behavior':
          stats['behavioral_observations']++;
          break;
        case 'communication':
          stats['communication_attempts']++;
          break;
        case 'activity_completion':
          stats['activities_completed']++;
          break;
      }
    }

    return stats;
  }

  /// Private helper methods
  
  static void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _saveSession();
    });
  }

  static void _stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  static Future<void> _saveSession() async {
    if (_currentSession?.id != null) {
      try {
        await FirestoreService.updateSession(_currentSession!.id!, _currentSession!);
      } catch (e) {
        developer.log('Auto-save failed: $e', name: 'SessionExecutionService');
      }
    }
  }

  static String? _getCurrentActivityId() {
    // This would be set based on current activity in the session
    // For now, return null or implement activity tracking
    return null;
  }

  static void _storeDataLocally(Map<String, dynamic> dataEntry) {
    // Store data locally for offline sync
    // Implementation would depend on local storage solution
    developer.log('Storing data locally: $dataEntry', name: 'SessionExecutionService');
  }

  static Map<String, dynamic> _calculateSessionProgress() {
    final sessionData = _currentSession!.sessionData;
    final progress = <String, dynamic>{
      'total_interactions': sessionData.length,
      'positive_behaviors': 0,
      'completion_rate': 0.0,
      'engagement_level': 'medium',
    };

    // Calculate specific metrics based on session data
    int positiveCount = 0;
    int totalBehaviors = 0;

    for (final data in sessionData) {
      if (data['type'] == 'behavior') {
        totalBehaviors++;
        if (data['value'] == 'positive' || data['value'] == 'completed') {
          positiveCount++;
        }
      }
    }

    if (totalBehaviors > 0) {
      progress['positive_behaviors'] = positiveCount;
      progress['completion_rate'] = (positiveCount / totalBehaviors) * 100;
    }

    return progress;
  }

  static Future<void> _recordProgressEntries() async {
    if (_currentSession == null) return;

    try {
      final progress = ProgressModel(
        studentId: _currentSession!.studentId,
        sessionId: _currentSession!.id,
        type: 'session',
        date: DateTime.now(),
        metrics: _calculateSessionProgress(),
        notes: _currentSession!.summary,
        therapistId: _currentSession!.therapistId,
        createdAt: DateTime.now(),
      );

      await FirestoreService.recordProgress(progress);
    } catch (e) {
      developer.log('Error recording progress: $e', name: 'SessionExecutionService');
    }
  }

  static Future<void> _updateGoalsProgress(Map<String, dynamic> sessionProgress) async {
    // Update goal progress based on session outcomes
    // This would involve analyzing session data and updating relevant goals
    try {
      for (final goalId in _currentSession!.goalIds) {
        // Get current goal and update progress
        final goal = await FirestoreService.getGoal(goalId);
        if (goal != null) {
          // Calculate new progress based on session outcomes
          final currentProgress = goal.progressPercentage;
          final improvement = _calculateGoalImprovement(goal, sessionProgress);
          final newProgress = (currentProgress + improvement).clamp(0.0, 100.0);

          await FirestoreService.updateGoalProgress(goalId, newProgress);
        }
      }
    } catch (e) {
      developer.log('Error updating goals progress: $e', name: 'SessionExecutionService');
    }
  }

  static double _calculateGoalImprovement(dynamic goal, Map<String, dynamic> sessionProgress) {
    // Calculate goal improvement based on session data
    // This is a simplified calculation - in reality, this would be more sophisticated
    final completionRate = sessionProgress['completion_rate'] ?? 0.0;
    return completionRate > 70 ? 5.0 : 2.0; // Increase by 5% or 2% based on performance
  }

  static Future<void> _cleanup() async {
    _currentSession = null;
    await _sessionDataController?.close();
    _sessionDataController = null;
    _stopAutoSave();
  }
}
