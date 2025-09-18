import 'package:cloud_firestore/cloud_firestore.dart';

/// Student data model for Firestore integration
class StudentModel {
  final String? id;
  final String firstName;
  final String lastName;
  final int age;
  final DateTime dateOfBirth;
  final String gender;
  final String? avatarUrl;
  final String diagnosis;
  final String communicationLevel;
  final String sensoryNeeds;
  final List<String> triggers;
  final String severity;
  final String therapistId;
  final List<String> parentIds;
  final List<String> goalIds;
  final Map<String, dynamic> emergencyContacts;
  final Map<String, dynamic> preferences;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.dateOfBirth,
    required this.gender,
    this.avatarUrl,
    required this.diagnosis,
    required this.communicationLevel,
    required this.sensoryNeeds,
    this.triggers = const [],
    required this.severity,
    required this.therapistId,
    this.parentIds = const [],
    this.goalIds = const [],
    this.emergencyContacts = const {},
    this.preferences = const {},
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'avatarUrl': avatarUrl,
      'diagnosis': diagnosis,
      'communicationLevel': communicationLevel,
      'sensoryNeeds': sensoryNeeds,
      'triggers': triggers,
      'severity': severity,
      'therapistId': therapistId,
      'parentIds': parentIds,
      'goalIds': goalIds,
      'emergencyContacts': emergencyContacts,
      'preferences': preferences,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      age: data['age'] ?? 0,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gender: data['gender'] ?? '',
      avatarUrl: data['avatarUrl'],
      diagnosis: data['diagnosis'] ?? '',
      communicationLevel: data['communicationLevel'] ?? '',
      sensoryNeeds: data['sensoryNeeds'] ?? '',
      triggers: _convertToStringList(data['triggers']),
      severity: data['severity'] ?? '',
      therapistId: data['therapistId'] ?? '',
      parentIds: _convertToStringList(data['parentIds']),
      goalIds: _convertToStringList(data['goalIds']),
      emergencyContacts: _convertToMap(data['emergencyContacts']),
      preferences: _convertToMap(data['preferences']),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  StudentModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    int? age,
    DateTime? dateOfBirth,
    String? gender,
    String? avatarUrl,
    String? diagnosis,
    String? communicationLevel,
    String? sensoryNeeds,
    List<String>? triggers,
    String? severity,
    String? therapistId,
    List<String>? parentIds,
    List<String>? goalIds,
    Map<String, dynamic>? emergencyContacts,
    Map<String, dynamic>? preferences,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      diagnosis: diagnosis ?? this.diagnosis,
      communicationLevel: communicationLevel ?? this.communicationLevel,
      sensoryNeeds: sensoryNeeds ?? this.sensoryNeeds,
      triggers: triggers ?? this.triggers,
      severity: severity ?? this.severity,
      therapistId: therapistId ?? this.therapistId,
      parentIds: parentIds ?? this.parentIds,
      goalIds: goalIds ?? this.goalIds,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      preferences: preferences ?? this.preferences,
      isActive: isActive ?? this.isActive,
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
