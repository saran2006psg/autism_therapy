import 'package:cloud_firestore/cloud_firestore.dart';

/// Progress data model for Firestore integration
class ProgressModel {
  final String? id;
  final String studentId;
  final String? goalId;
  final String? sessionId;
  final String type;
  final DateTime date;
  final Map<String, dynamic> metrics;
  final String? notes;
  final List<String> mediaFiles;
  final String therapistId;
  final DateTime createdAt;

  ProgressModel({
    this.id,
    required this.studentId,
    this.goalId,
    this.sessionId,
    required this.type,
    required this.date,
    this.metrics = const {},
    this.notes,
    this.mediaFiles = const [],
    required this.therapistId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return ProgressModel(
      id: doc.id,
      studentId: (data['studentId'] as String?) ?? '',
      goalId: data['goalId'] as String?,
      sessionId: data['sessionId'] as String?,
      type: (data['type'] as String?) ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metrics: _convertToMap(data['metrics']) ?? {},
      notes: data['notes'] as String?,
      mediaFiles: _convertToStringList(data['mediaFiles']) ?? [],
      therapistId: (data['therapistId'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'goalId': goalId,
      'sessionId': sessionId,
      'type': type,
      'date': Timestamp.fromDate(date),
      'metrics': metrics,
      'notes': notes,
      'mediaFiles': mediaFiles,
      'therapistId': therapistId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static List<String>? _convertToStringList(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return null;
  }

  static Map<String, dynamic>? _convertToMap(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  @override
  String toString() {
    return 'ProgressModel(id: $id, studentId: $studentId, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgressModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Create a copy with updated fields
  ProgressModel copyWith({
    String? id,
    String? studentId,
    String? goalId,
    String? sessionId,
    String? type,
    DateTime? date,
    Map<String, dynamic>? metrics,
    String? notes,
    List<String>? mediaFiles,
    String? therapistId,
    DateTime? createdAt,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      goalId: goalId ?? this.goalId,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      date: date ?? this.date,
      metrics: metrics ?? this.metrics,
      notes: notes ?? this.notes,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      therapistId: therapistId ?? this.therapistId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ActivityModel {
  final String? id;
  final String sessionId;
  final String goalId;
  final String activityName;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final String? difficulty;
  final int? score;
  final String? materials;
  final List<String> instructions;
  final Map<String, dynamic> goals;
  final String? observations;
  // Additional fields required by the service
  final String? name;
  final String? description;
  final String? category;
  final String? type;
  final int? estimatedDuration;
  final String? iconName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isCustom;
  final String? createdBy;

  ActivityModel({
    this.id,
    required this.sessionId,
    required this.goalId,
    required this.activityName,
    required this.status,
    required this.startTime,
    this.endTime,
    this.difficulty,
    this.score,
    this.materials,
    this.instructions = const [],
    this.goals = const {},
    this.observations,
    // Additional parameters
    this.name,
    this.description,
    this.category,
    this.type,
    this.estimatedDuration,
    this.iconName,
    this.createdAt,
    this.updatedAt,
    this.isCustom,
    this.createdBy,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return ActivityModel(
      id: doc.id,
      sessionId: (data['sessionId'] as String?) ?? '',
      goalId: (data['goalId'] as String?) ?? '',
      activityName: (data['activityName'] as String?) ?? '',
      status: (data['status'] as String?) ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      difficulty: data['difficulty'] as String?,
      score: data['score'] as int?,
      materials: data['materials'] as String?,
      instructions: _convertToStringList(data['instructions']) ?? [],
      goals: _convertToMap(data['goals']) ?? {},
      observations: data['observations'] as String?,
      // Additional fields
      name: data['name'] as String?,
      description: data['description'] as String?,
      category: data['category'] as String?,
      type: data['type'] as String?,
      estimatedDuration: data['estimatedDuration'] as int?,
      iconName: data['iconName'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isCustom: data['isCustom'] as bool?,
      createdBy: data['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'goalId': goalId,
      'activityName': activityName,
      'status': status,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'difficulty': difficulty,
      'score': score,
      'materials': materials,
      'instructions': instructions,
      'goals': goals,
      'observations': observations,
      // Additional fields
      'name': name,
      'description': description,
      'category': category,
      'type': type,
      'estimatedDuration': estimatedDuration,
      'iconName': iconName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isCustom': isCustom,
      'createdBy': createdBy,
    };
  }

  static List<String>? _convertToStringList(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return null;
  }

  static Map<String, dynamic>? _convertToMap(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  @override
  String toString() {
    return 'ActivityModel(id: $id, activityName: $activityName, status: $status)';
  }

  /// Create a copy with updated fields
  ActivityModel copyWith({
    String? id,
    String? sessionId,
    String? goalId,
    String? activityName,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    String? difficulty,
    int? score,
    String? materials,
    List<String>? instructions,
    Map<String, dynamic>? goals,
    String? observations,
    String? name,
    String? description,
    String? category,
    String? type,
    int? estimatedDuration,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCustom,
    String? createdBy,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      goalId: goalId ?? this.goalId,
      activityName: activityName ?? this.activityName,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      difficulty: difficulty ?? this.difficulty,
      score: score ?? this.score,
      materials: materials ?? this.materials,
      instructions: instructions ?? this.instructions,
      goals: goals ?? this.goals,
      observations: observations ?? this.observations,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCustom: isCustom ?? this.isCustom,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}