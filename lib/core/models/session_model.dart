import 'package:cloud_firestore/cloud_firestore.dart';

/// Session data model for Firestore integration
class SessionModel {
  final String? id;
  final String studentId;
  final String therapistId;
  final String type;
  final String title;
  final String? description;
  final DateTime scheduledDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final int estimatedDuration; // in minutes
  final int? actualDuration; // in minutes
  final String status; // 'scheduled', 'in_progress', 'completed', 'cancelled'
  final List<String> goalIds;
  final List<Map<String, dynamic>> activities;
  final List<Map<String, dynamic>> sessionData; // behavioral observations, notes, etc.
  final List<String> mediaFiles; // photos, audio recordings
  final String? summary;
  final List<String> achievements;
  final String? homeworkAssigned;
  final String? nextSessionFocus;
  final Map<String, dynamic> progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  SessionModel({
    this.id,
    required this.studentId,
    required this.therapistId,
    required this.type,
    required this.title,
    this.description,
    required this.scheduledDate,
    this.startTime,
    this.endTime,
    required this.estimatedDuration,
    this.actualDuration,
    this.status = 'scheduled',
    this.goalIds = const [],
    this.activities = const [],
    this.sessionData = const [],
    this.mediaFiles = const [],
    this.summary,
    this.achievements = const [],
    this.homeworkAssigned,
    this.nextSessionFocus,
    this.progress = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'therapistId': therapistId,
      'type': type,
      'title': title,
      'description': description,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'estimatedDuration': estimatedDuration,
      'actualDuration': actualDuration,
      'status': status,
      'goalIds': goalIds,
      'activities': activities,
      'sessionData': sessionData,
      'mediaFiles': mediaFiles,
      'summary': summary,
      'achievements': achievements,
      'homeworkAssigned': homeworkAssigned,
      'nextSessionFocus': nextSessionFocus,
      'progress': progress,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      therapistId: data['therapistId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      scheduledDate: (data['scheduledDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: (data['startTime'] as Timestamp?)?.toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      estimatedDuration: data['estimatedDuration'] ?? 60,
      actualDuration: data['actualDuration'],
      status: data['status'] ?? 'scheduled',
      goalIds: List<String>.from(data['goalIds'] ?? []),
      activities: List<Map<String, dynamic>>.from(data['activities'] ?? []),
      sessionData: List<Map<String, dynamic>>.from(data['sessionData'] ?? []),
      mediaFiles: List<String>.from(data['mediaFiles'] ?? []),
      summary: data['summary'],
      achievements: List<String>.from(data['achievements'] ?? []),
      homeworkAssigned: data['homeworkAssigned'],
      nextSessionFocus: data['nextSessionFocus'],
      progress: Map<String, dynamic>.from(data['progress'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  SessionModel copyWith({
    String? id,
    String? studentId,
    String? therapistId,
    String? type,
    String? title,
    String? description,
    DateTime? scheduledDate,
    DateTime? startTime,
    DateTime? endTime,
    int? estimatedDuration,
    int? actualDuration,
    String? status,
    List<String>? goalIds,
    List<Map<String, dynamic>>? activities,
    List<Map<String, dynamic>>? sessionData,
    List<String>? mediaFiles,
    String? summary,
    List<String>? achievements,
    String? homeworkAssigned,
    String? nextSessionFocus,
    Map<String, dynamic>? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      therapistId: therapistId ?? this.therapistId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      status: status ?? this.status,
      goalIds: goalIds ?? this.goalIds,
      activities: activities ?? this.activities,
      sessionData: sessionData ?? this.sessionData,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      summary: summary ?? this.summary,
      achievements: achievements ?? this.achievements,
      homeworkAssigned: homeworkAssigned ?? this.homeworkAssigned,
      nextSessionFocus: nextSessionFocus ?? this.nextSessionFocus,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
