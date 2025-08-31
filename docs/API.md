# ThrivePath API Documentation

## Authentication Service

### AuthService
Handles user authentication and session management.

```dart
class AuthService {
  static User? get currentUser;
  
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}
```

## Data Models

### StudentModel
Represents a student in the therapy system.

```dart
class StudentModel {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String diagnosis;
  final String gender;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### SessionModel
Represents a therapy session.

```dart
class SessionModel {
  final String id;
  final String studentId;
  final String therapistId;
  final DateTime scheduledDate;
  final int duration;
  final String status;
  final List<String> activities;
  final String notes;
}
```

## Core Services

### DataService
Manages data operations with Firebase Firestore.

```dart
class DataService {
  Stream<List<StudentModel>> getStudents();
  Future<void> createStudent(StudentModel student);
  Future<void> updateStudent(StudentModel student);
  Future<void> deleteStudent(String studentId);
  
  Stream<List<SessionModel>> getSessions();
  Future<void> createSession(SessionModel session);
  Future<void> updateSession(SessionModel session);
}
```

## Navigation

### AppRoutes
Centralized route management.

```dart
class AppRoutes {
  static const String loginScreen = '/login';
  static const String therapistDashboard = '/therapist-dashboard';
  static const String parentDashboard = '/parent-dashboard';
  static const String sessionPlanning = '/session-planning';
  static const String sessionExecution = '/session-execution';
  static const String studentProfile = '/student-profile';
}
```

## Widget Architecture

### Screen Structure
Each screen follows this structure:
- Main screen file (e.g., `therapist_dashboard.dart`)
- Widgets subfolder containing reusable components
- Consistent naming convention ending with `Widget`

### Common Widgets
- `MetricCardWidget`: Displays key metrics
- `StudentCardWidget`: Shows student information
- `SessionCardWidget`: Displays session details
- `ProgressChartWidget`: Shows progress visualization
- `CustomIconWidget`: Standardized icon display
- `CustomImageWidget`: Optimized image loading

## State Management

### Local State
- Use StatefulWidget for component-level state
- Keep state close to where it's used
- Use setState() for simple state updates

### Global State
- AuthService for authentication state
- DataService for data stream management
- Theme management through AppTheme

## Error Handling

### Error Types
- `AuthException`: Authentication-related errors
- `DataException`: Data operation errors
- `ValidationException`: Form validation errors

### Error Display
- Toast messages for quick feedback
- Dialog boxes for critical errors
- Inline validation for forms

## Performance Considerations

### Image Optimization
- Use `CustomImageWidget` for network images
- Implement caching with `cached_network_image`
- Resize images appropriately

### List Performance
- Use `ListView.builder` for large lists
- Implement pagination for large datasets
- Use `const` constructors where possible

### Memory Management
- Dispose controllers in StatefulWidget
- Cancel subscriptions to prevent memory leaks
- Use weak references for callbacks

## Testing Guidelines

### Unit Tests
- Test business logic in services
- Mock external dependencies
- Verify edge cases and error conditions

### Widget Tests
- Test widget rendering
- Verify user interactions
- Test responsive behavior

### Integration Tests
- Test complete user flows
- Verify Firebase integration
- Test navigation between screens
