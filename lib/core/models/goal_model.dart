import 'package:cloud_firestore/cloud_firestore.dart';

/// Goal data model for Firestore integration
class GoalModel {
  final String? id;
  final String studentId;
  final String therapistId;
  final String title;
  final String description;
  final String category; // 'communication', 'social', 'behavioral', 'academic', etc.
  final String priority; // 'high', 'medium', 'low'
  final String status; // 'active', 'completed', 'paused', 'cancelled'
  final DateTime targetDate;
  final double progressPercentage;
  final List<Map<String, dynamic>> milestones;
  final List<String> strategies;
  final Map<String, dynamic> measurementCriteria;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalModel({
    this.id,
    required this.studentId,
    required this.therapistId,
    required this.title,
    required this.description,
    required this.category,
    this.priority = 'medium',
    this.status = 'active',
    required this.targetDate,
    this.progressPercentage = 0.0,
    this.milestones = const [],
    this.strategies = const [],
    this.measurementCriteria = const {},
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'therapistId': therapistId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'targetDate': Timestamp.fromDate(targetDate),
      'progressPercentage': progressPercentage,
      'milestones': milestones,
      'strategies': strategies,
      'measurementCriteria': measurementCriteria,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      studentId: (data['studentId'] as String?) ?? '',
      therapistId: (data['therapistId'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      priority: (data['priority'] as String?) ?? 'medium',
      status: (data['status'] as String?) ?? 'active',
      targetDate: (data['targetDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      progressPercentage: (data['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      milestones: _convertToMapList(data['milestones']),
      strategies: _convertToStringList(data['strategies']),
      measurementCriteria: _convertToMap(data['measurementCriteria']),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  GoalModel copyWith({
    String? id,
    String? studentId,
    String? therapistId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    DateTime? targetDate,
    double? progressPercentage,
    List<Map<String, dynamic>>? milestones,
    List<String>? strategies,
    Map<String, dynamic>? measurementCriteria,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      therapistId: therapistId ?? this.therapistId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      targetDate: targetDate ?? this.targetDate,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      milestones: milestones ?? this.milestones,
      strategies: strategies ?? this.strategies,
      measurementCriteria: measurementCriteria ?? this.measurementCriteria,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper method to safely convert data to List&lt;String&gt;
  static List<String> _convertToStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }

  /// Helper method to safely convert data to List&lt;Map&lt;String, dynamic&gt;&gt;
  static List<Map<String, dynamic>> _convertToMapList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  /// Helper method to safely convert data to Map&lt;String, dynamic&gt;
  static Map<String, dynamic> _convertToMap(dynamic data) {
    if (data == null) return {};
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }
}
