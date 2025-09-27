import 'package:thriveers/core/models/student_model.dart';
import 'package:thriveers/core/models/goal_model.dart';
import 'package:thriveers/core/models/session_model.dart';
import 'package:thriveers/core/models/progress_model.dart';
import 'package:thriveers/core/services/firestore_service.dart';
import 'package:thriveers/core/services/auth_service.dart';
import 'package:thriveers/core/utils/app_logger.dart';

/// Test Data Initialization Service
/// Creates sample data for testing and demonstration purposes
class TestDataService {
  
  /// Initialize test data for a therapist account
  static Future<void> initializeTherapistTestData() async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        AppLogger.warning('No authenticated user found', name: 'TestDataService');
        return;
      }

      AppLogger.info('Initializing test data for therapist: ${currentUser.email}', name: 'TestDataService');

      // Create sample students
      final students = await _createSampleStudents(currentUser.uid);
      
      // Create sample goals for each student
      for (final student in students) {
        await _createSampleGoals(student.id!, currentUser.uid);
      }

      // Create sample sessions
      for (final student in students) {
        await _createSampleSessions(student.id!, currentUser.uid);
      }

      // Create sample progress entries
      for (final student in students) {
        await _createSampleProgress(student.id!, currentUser.uid);
      }

      AppLogger.info('Test data initialization completed successfully', name: 'TestDataService');
    } catch (e) {
      AppLogger.error('Error initializing test data: $e', name: 'TestDataService', error: e);
    }
  }

  /// Create sample students
  static Future<List<StudentModel>> _createSampleStudents(String therapistId) async {
    final students = <StudentModel>[];
    
    final sampleData = [
      {
        'firstName': 'Emma',
        'lastName': 'Johnson',
        'age': 7,
        'dateOfBirth': DateTime(2018, 3, 15),
        'gender': 'Female',
        'diagnosis': 'Autism Spectrum Disorder',
        'communicationLevel': 'Developing verbal communication with AAC support',
        'sensoryNeeds': 'Sensitive to loud noises, seeks deep pressure, prefers dim lighting',
        'severity': 'moderate',
        'triggers': ['loud noises', 'sudden changes', 'bright lights', 'crowded spaces'],
        'avatarUrl': 'https://i.pravatar.cc/150?img=1',
      },
      {
        'firstName': 'Michael',
        'lastName': 'Chen',
        'age': 9,
        'dateOfBirth': DateTime(2016, 8, 22),
        'gender': 'Male',
        'diagnosis': 'ADHD with Learning Disability',
        'communicationLevel': 'Strong verbal skills, difficulty with sustained attention',
        'sensoryNeeds': 'Requires movement breaks, fidget tools, standing desk options',
        'severity': 'mild',
        'triggers': ['long sitting periods', 'complex multi-step instructions', 'transitions without warning'],
        'avatarUrl': 'https://i.pravatar.cc/150?img=2',
      },
      {
        'firstName': 'Sarah',
        'lastName': 'Williams',
        'age': 6,
        'dateOfBirth': DateTime(2019, 11, 8),
        'gender': 'Female',
        'diagnosis': 'Speech and Language Delay',
        'communicationLevel': 'Limited verbal communication, uses gestures and picture cards',
        'sensoryNeeds': 'Enjoys tactile activities, visual learner, needs routine',
        'severity': 'moderate',
        'triggers': ['being rushed', 'too many choices', 'unfamiliar people', 'time pressure'],
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
      },
      {
        'firstName': 'Aiden',
        'lastName': 'Rodriguez',
        'age': 8,
        'dateOfBirth': DateTime(2017, 5, 12),
        'gender': 'Male',
        'diagnosis': 'Sensory Processing Disorder',
        'communicationLevel': 'Good verbal skills, struggles with emotional regulation',
        'sensoryNeeds': 'Seeks vestibular input, avoids certain textures, needs calming space',
        'severity': 'mild',
        'triggers': ['unexpected touch', 'food textures', 'clothing tags', 'time limits'],
        'avatarUrl': 'https://i.pravatar.cc/150?img=4',
      },
      {
        'firstName': 'Zoe',
        'lastName': 'Patel',
        'age': 10,
        'dateOfBirth': DateTime(2015, 2, 28),
        'gender': 'Female',
        'diagnosis': 'Intellectual Disability with Autism',
        'communicationLevel': 'Simple verbal communication, benefits from visual supports',
        'sensoryNeeds': 'Prefers quiet environments, needs predictable routines',
        'severity': 'moderate',
        'triggers': ['schedule changes', 'new environments', 'loud sounds', 'being corrected'],
        'avatarUrl': 'https://i.pravatar.cc/150?img=5',
      },
      {
        'firstName': 'Jacob',
        'lastName': 'Thompson',
        'age': 5,
        'dateOfBirth': DateTime(2020, 9, 14),
        'gender': 'Male',
        'diagnosis': 'Developmental Delay',
        'communicationLevel': 'Emerging language skills, uses single words and gestures',
        'sensoryNeeds': 'Enjoys music and movement, needs hands-on learning',
        'severity': 'mild',
        'triggers': ['sitting still too long', 'complex tasks', 'waiting without activity'],
        'avatarUrl': 'https://i.pravatar.cc/150?img=6',
      },
    ];

    for (final data in sampleData) {
      final student = StudentModel(
        firstName: data['firstName'] as String,
        lastName: data['lastName'] as String,
        age: data['age'] as int,
        dateOfBirth: data['dateOfBirth'] as DateTime,
        gender: data['gender'] as String,
        diagnosis: data['diagnosis'] as String,
        communicationLevel: data['communicationLevel'] as String,
        sensoryNeeds: data['sensoryNeeds'] as String,
        severity: data['severity'] as String,
        triggers: List<String>.from(data['triggers'] as List),
        avatarUrl: data['avatarUrl'] as String?,
        therapistId: therapistId,
        emergencyContacts: {
          'primary': {
            'name': 'Parent/Guardian',
            'phone': '+1-555-0123',
            'relationship': 'Parent',
          }
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final studentId = await FirestoreService.createStudent(student);
      students.add(student.copyWith(id: studentId));
      AppLogger.debug('Created student: ${student.firstName} ${student.lastName}', name: 'TestDataService');
    }

    return students;
  }

  /// Create sample goals
  static Future<void> _createSampleGoals(String studentId, String therapistId) async {
    final goals = [
      {
        'title': 'Improve Eye Contact',
        'description': 'Increase duration and frequency of eye contact during social interactions',
        'category': 'social',
        'priority': 'high',
        'targetDate': DateTime.now().add(const Duration(days: 90)),
        'progressPercentage': 25.0,
        'strategies': ['Visual cues', 'Reward system', 'Gradual increase'],
      },
      {
        'title': 'Expand Vocabulary',
        'description': 'Learn 20 new functional words for daily communication',
        'category': 'communication',
        'priority': 'high',
        'targetDate': DateTime.now().add(const Duration(days: 120)),
        'progressPercentage': 45.0,
        'strategies': ['Picture cards', 'Repetition', 'Context-based learning'],
      },
      {
        'title': 'Self-Regulation Skills',
        'description': 'Develop coping strategies for sensory overload situations',
        'category': 'behavioral',
        'priority': 'medium',
        'targetDate': DateTime.now().add(const Duration(days: 150)),
        'progressPercentage': 15.0,
        'strategies': ['Deep breathing', 'Sensory breaks', 'Visual schedule'],
      },
    ];

    for (final goalData in goals) {
      final goal = GoalModel(
        studentId: studentId,
        therapistId: therapistId,
        title: goalData['title'] as String,
        description: goalData['description'] as String,
        category: goalData['category'] as String,
        priority: goalData['priority'] as String,
        targetDate: goalData['targetDate'] as DateTime,
        progressPercentage: goalData['progressPercentage'] as double,
        strategies: List<String>.from(goalData['strategies'] as List),
        measurementCriteria: {
          'frequency': 'daily',
          'duration': '5 minutes',
          'success_criteria': '80% completion rate',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService.createGoal(goal);
      AppLogger.debug('Created goal: ${goal.title}', name: 'TestDataService');
    }
  }

  /// Create sample sessions
  static Future<void> _createSampleSessions(String studentId, String therapistId) async {
    final sessions = [
      {
        'type': 'Individual Therapy',
        'title': 'Communication and Social Skills',
        'description': 'Focus on verbal communication and peer interaction',
        'scheduledDate': DateTime.now().add(const Duration(days: 1)),
        'estimatedDuration': 60,
        'status': 'scheduled',
      },
      {
        'type': 'Speech Therapy',
        'title': 'Articulation Practice',
        'description': 'Working on sound production and clarity',
        'scheduledDate': DateTime.now().subtract(const Duration(days: 3)),
        'estimatedDuration': 45,
        'status': 'completed',
        'summary': 'Great progress on /s/ sounds. Student engaged well with picture cards.',
        'achievements': ['Correctly produced /s/ in 8/10 words', 'Maintained attention for full session'],
      },
      {
        'type': 'Behavioral Therapy',
        'title': 'Self-Regulation Training',
        'description': 'Teaching coping strategies for overwhelming situations',
        'scheduledDate': DateTime.now().subtract(const Duration(days: 7)),
        'estimatedDuration': 50,
        'status': 'completed',
        'summary': 'Practiced deep breathing techniques. Used sensory break successfully.',
        'achievements': ['Used breathing technique independently', 'Asked for sensory break when needed'],
      },
    ];

    for (final sessionData in sessions) {
      final session = SessionModel(
        studentId: studentId,
        therapistId: therapistId,
        type: sessionData['type'] as String,
        title: sessionData['title'] as String,
        description: sessionData['description'] as String?,
        scheduledDate: sessionData['scheduledDate'] as DateTime,
        estimatedDuration: sessionData['estimatedDuration'] as int,
        status: sessionData['status'] as String,
        summary: sessionData['summary'] as String?,
        achievements: sessionData['achievements'] != null
            ? List<String>.from(sessionData['achievements'] as List)
            : [],
        activities: [
          {
            'id': '1',
            'name': 'Picture Exchange Communication',
            'description': 'Practice using picture cards to communicate needs and wants',
            'duration': 15,
            'difficulty': 'medium',
            'status': 'completed',
            'completedAt': DateTime.now().subtract(const Duration(days: 3)),
            'studentNotes': 'I liked using the pictures to ask for snacks!',
          },
          {
            'id': '2',
            'name': 'Social Story Reading',
            'description': 'Read and discuss social situations and appropriate responses',
            'duration': 20,
            'difficulty': 'easy',
            'status': 'not_started',
            'studentNotes': '',
          },
          {
            'id': '3',
            'name': 'Deep Breathing Exercise',
            'description': 'Practice calming techniques for when feeling overwhelmed',
            'duration': 10,
            'difficulty': 'easy',
            'status': 'in_progress',
            'studentNotes': 'This helps me feel calm',
          },
        ],
        sessionData: sessionData['status'] == 'completed' ? [
          {
            'timestamp': DateTime.now().subtract(const Duration(days: 3)),
            'type': 'behavior',
            'value': 'positive',
            'notes': 'Great eye contact during activity',
          },
          {
            'timestamp': DateTime.now().subtract(const Duration(days: 3)),
            'type': 'communication',
            'value': {'method': 'verbal', 'successful': true},
            'notes': 'Requested break appropriately',
          },
        ] : [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService.createSession(session);
      AppLogger.debug('Created session: ${session.title}', name: 'TestDataService');
    }
  }

  /// Create sample progress entries
  static Future<void> _createSampleProgress(String studentId, String therapistId) async {
    final now = DateTime.now();
    final progressEntries = [
      {
        'type': 'weekly',
        'date': now.subtract(const Duration(days: 7)),
        'metrics': {
          'communication_attempts': 25,
          'successful_interactions': 18,
          'goal_progress': 15.0,
          'engagement_score': 8.5,
        },
        'notes': 'Good progress this week. More spontaneous communication.',
      },
      {
        'type': 'weekly',
        'date': now.subtract(const Duration(days: 14)),
        'metrics': {
          'communication_attempts': 20,
          'successful_interactions': 14,
          'goal_progress': 10.0,
          'engagement_score': 7.5,
        },
        'notes': 'Steady improvement. Working on consistency.',
      },
      {
        'type': 'monthly',
        'date': now.subtract(const Duration(days: 30)),
        'metrics': {
          'total_sessions': 8,
          'average_engagement': 8.0,
          'goals_addressed': 3,
          'skill_improvements': ['eye contact', 'verbal requests', 'turn-taking'],
        },
        'notes': 'Monthly summary showing consistent progress across all goals.',
      },
    ];

    for (final entry in progressEntries) {
      final progress = ProgressModel(
        studentId: studentId,
        type: entry['type'] as String,
        date: entry['date'] as DateTime,
        metrics: entry['metrics'] as Map<String, dynamic>,
        notes: entry['notes'] as String?,
        therapistId: therapistId,
        createdAt: DateTime.now(),
      );

      await FirestoreService.recordProgress(progress);
      AppLogger.debug('Created progress entry: ${progress.type} for ${progress.date}', name: 'TestDataService');
    }
  }
}
