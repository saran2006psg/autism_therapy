import 'package:cloud_firestore/cloud_firestore.dart';

/// Progress data model for Firestore integration
class ProgressModel {
  final String? id;
  final String studentId;
  final String? goalId;
  final String? sessionId;
  final String type; // 'weekly', 'monthly', 'session', 'goal_milestone'
  final DateTime date;
  final Map<String, dynamic> metrics; // scores, observations, measurements
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
    required this.createdAt,
  });

  /// Convert to Firestore document
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

  /// Create from Firestore document
  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      goalId: data['goalId'],
      sessionId: data['sessionId'],
      type: data['type'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metrics: _convertToMap(data['metrics']),
      notes: data['notes'],
      mediaFiles: _convertToStringList(data['mediaFiles']),
      therapistId: data['therapistId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

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

  /// Helper method to safely convert data to List<String>
  static List<String> _convertToStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }

  /// Helper method to safely convert data to Map<String, dynamic>
  static Map<String, dynamic> _convertToMap(dynamic data) {
    if (data == null) return {};
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }
}

/// Activity data model for therapy sessions
class ActivityModel {
  final String? id;
  final String name;
  final String description;
  final String category;
  final String type; // 'communication', 'social', 'behavioral', 'sensory', etc.
  final String difficulty; // 'easy', 'medium', 'hard'
  final int estimatedDuration; // in minutes
  final String iconName;
  final List<String> materials;
  final List<String> instructions;
  final Map<String, dynamic> goals;
  final bool isCustom; // user-created vs predefined
  final String? createdBy; // therapist id if custom
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityModel({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.type,
    this.difficulty = 'medium',
    required this.estimatedDuration,
    this.iconName = 'activity',
    this.materials = const [],
    this.instructions = const [],
    this.goals = const {},
    this.isCustom = false,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'type': type,
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'iconName': iconName,
      'materials': materials,
      'instructions': instructions,
      'goals': goals,
      'isCustom': isCustom,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      type: data['type'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      estimatedDuration: data['estimatedDuration'] ?? 15,
      iconName: data['iconName'] ?? 'activity',
      materials: _convertToStringList(data['materials']),
      instructions: _convertToStringList(data['instructions']),
      goals: _convertToMap(data['goals']),
      isCustom: data['isCustom'] ?? false,
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  ActivityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? type,
    String? difficulty,
    int? estimatedDuration,
    String? iconName,
    List<String>? materials,
    List<String>? instructions,
    Map<String, dynamic>? goals,
    bool? isCustom,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      iconName: iconName ?? this.iconName,
      materials: materials ?? this.materials,
      instructions: instructions ?? this.instructions,
      goals: goals ?? this.goals,
      isCustom: isCustom ?? this.isCustom,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper method to safely convert data to List<String>
  static List<String> _convertToStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }

  /// Helper method to safely convert data to Map<String, dynamic>
  static Map<String, dynamic> _convertToMap(dynamic data) {
    if (data == null) return {};
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }
}
