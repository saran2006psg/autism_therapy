# Product Requirements Document (PRD) - ThrivEers

**Version:** 1.1.0  
**Last Updated:** October 10, 2025  
**Document Owner:** GitHub Copilot

---

## 1. Executive Summary

**ThrivEers** (internally known as ThrivePath) is a comprehensive, multi-platform therapy management application designed for Autism Spectrum Disorder (ASD) interventions. It connects therapists, parents, and students on a unified platform, enabling real-time progress tracking, collaborative session planning, and secure communication.

### 1.1. Mission & Vision

- **Mission**: To empower autism therapy through collaborative technology, fostering a unified ecosystem for therapists, families, and students to achieve measurable progress and meaningful outcomes.
- **Vision**: To be the leading digital platform for ASD therapy management, known for its user-centric design, data-driven insights, and unwavering commitment to privacy and collaboration.

### 1.2. Core Features

- **Multi-Role Architecture**: Tailored interfaces and logic for Therapists, Parents, Students, and Admins.
- **Real-Time Collaboration**: Firebase-powered live data synchronization for sessions, progress, and communication.
- **Data-Driven Insights**: Visual progress tracking, automated reporting, and performance metrics.
- **Cross-Platform Support**: Fully functional on Android, iOS, and Web.

---

## 2. Technical Architecture

### 2.1. Technology Stack

| Category             | Technology                                          |
| -------------------- | --------------------------------------------------- |
| **Frontend**         | Flutter 3.x with Dart SDK 3.8.1+                    |
| **Backend**          | Firebase (Authentication, Firestore, Storage, RTDB) |
| **State Management** | Provider 6.1.2                                      |
| **UI Libraries**     | Material Design 3, Sizer, FL Chart, Google Fonts    |
| **Media**            | Image Picker, Camera, Record                        |
| **Utilities**        | Connectivity Plus, Permission Handler, Logger       |

### 2.2. Project Structure

The project follows a feature-driven, layered architecture to separate concerns and improve maintainability.

```
lib/
├── core/
│   ├── models/         # Data structures (Student, Session, Goal, etc.)
│   ├── services/       # Business logic (Auth, Firestore, Data, Session Execution)
│   └── utils/          # Helper classes (Logging, Theming, etc.)
├── presentation/
│   ├── admin_screen/
│   ├── login_screen/
│   ├── parent_dashboard/
│   ├── therapist_dashboard/
│   ├── session_planning_screen/
│   ├── session_execution_screen/
│   └── ... (other UI screens)
├── routes/
│   └── app_routes.dart # Named routes and navigation logic
├── theme/
│   └── app_theme.dart  # Theming and styling configuration
├── widgets/
│   ├── navigation/     # Reusable navigation components
│   └── ... (other reusable widgets)
├── firebase_options.dart # Firebase project configuration
└── main.dart             # Application entry point
```

### 2.3. Data Flow & State Management

The application employs a **Service Layer pattern with Provider** for state management.

1.  **UI Layer (`presentation/`)**: Widgets trigger actions (e.g., button press).
2.  **Data Service (`DataService`)**: A singleton `ChangeNotifier` that acts as a central hub for data operations. It caches data, manages loading states, and orchestrates calls to other services.
3.  **Firestore Service (`FirestoreService`)**: Contains static methods for all raw CRUD (Create, Read, Update, Delete) operations with the Cloud Firestore database.
4.  **Firebase**: The backend that persists data and streams updates back to the application.
5.  **State Update**: `DataService` listens to streams from `FirestoreService`, updates its cached data, and calls `notifyListeners()` to rebuild the UI.

```
UI Widget -> DataService -> FirestoreService -> Firebase
                                     ^                |
                                     | (Stream Update) |
                                     +-----------------+
```

### 2.4. Firebase Backend

- **Project ID**: `ablnew-9f930`
- **Collections**:
  - `users`: Stores profiles for all roles (Therapist, Parent, Admin).
  - `students`: Detailed student profiles.
  - `sessions`: Therapy session data.
  - `goals`: Individual therapeutic goals.
  - `progress`: Time-series progress data.
  - `activities`: A library of therapy activities.
- **Storage**:
  - `avatars/`: User and student profile pictures.
  - `session_media/`: Photos and audio recorded during sessions.
- **Security Rules**: Firestore rules are configured to be role-based, ensuring users can only access data they are authorized to see (e.g., a parent can only see their own child's data).

---

## 3. Data Models (Schemas)

### 3.1. StudentModel (`lib/core/models/student_model.dart`)

Stores all information related to a student.

| Field                   | Type           | Description                                            |
| ----------------------- | -------------- | ------------------------------------------------------ |
| `id`                    | `String?`      | Firebase document ID.                                  |
| `firstName`, `lastName` | `String`       | Student's name.                                        |
| `age`                   | `int`          | Calculated from `dateOfBirth`.                         |
| `dateOfBirth`           | `DateTime`     | Student's date of birth.                               |
| `diagnosis`             | `String`       | Clinical diagnosis (e.g., 'Autism Spectrum Disorder'). |
| `therapistId`           | `String`       | ID of the assigned primary therapist.                  |
| `parentIds`             | `List<String>` | IDs of linked parent accounts.                         |
| `avatarUrl`             | `String?`      | URL for profile picture in Firebase Storage.           |
| `...`                   | `...`          | Other fields like `gender`, `sensoryNeeds`, etc.       |

### 3.2. SessionModel (`lib/core/models/session_model.dart`)

Represents a single therapy session.

| Field           | Type                         | Description                                                       |
| --------------- | ---------------------------- | ----------------------------------------------------------------- |
| `id`            | `String?`                    | Firebase document ID.                                             |
| `studentId`     | `String`                     | The student participating in the session.                         |
| `therapistId`   | `String`                     | The therapist conducting the session.                             |
| `scheduledDate` | `DateTime`                   | The planned date and time of the session.                         |
| `status`        | `String`                     | 'scheduled', 'in_progress', 'completed', 'cancelled'.             |
| `activities`    | `List<Map<String, dynamic>>` | List of activities planned for the session.                       |
| `sessionData`   | `List<Map<String, dynamic>>` | Real-time data collected during the session (e.g., observations). |
| `mediaFiles`    | `List<String>`               | URLs of photos/audio from Firebase Storage.                       |
| `summary`       | `String?`                    | Post-session summary written by the therapist.                    |

### 3.3. UserModel (Implicit in `users` collection)

Stores user-specific information.

| Field       | Type      | Description                        |
| ----------- | --------- | ---------------------------------- |
| `uid`       | `String`  | Firebase Authentication User ID.   |
| `email`     | `String`  | User's login email.                |
| `role`      | `String`  | 'Therapist', 'Parent', or 'Admin'. |
| `firstName` | `String`  | User's first name.                 |
| `lastName`  | `String`  | User's last name.                  |
| `avatarUrl` | `String?` | URL for profile picture.           |

---

## 4. Core Services (Business Logic)

### 4.1. AuthService (`lib/core/services/auth_service.dart`)

- **Purpose**: Manages all user authentication and role-based access.
- **Key Logic**:
  - `signInWithEmailAndPassword`: Authenticates the user with Firebase Auth.
  - `createUserWithEmailAndPassword`: Registers a new user and creates a corresponding profile in the `users` collection with a specified role.
  - `signOut`: Logs the user out and clears session data.
  - `getRoleFromFirestore`: Fetches the user's role from their profile to direct navigation.

### 4.2. FirestoreService (`lib/core/services/firestore_service.dart`)

- **Purpose**: Provides a direct, low-level API for all Firestore database operations.
- **Key Logic**:
  - Implements static methods for `create`, `read`, `update`, and `delete` for all data models (e.g., `createStudent`, `getSessionStream`).
  - Constructs and executes complex queries (e.g., fetching all students for a specific therapist).

### 4.3. DataService (`lib/core/services/data_service.dart`)

- **Purpose**: Acts as the central nervous system for the app's data. It decouples UI from the raw database services.
- **Key Logic**:
  - **Caching**: Holds lists of students, sessions, etc., in memory to reduce database reads.
  - **State Management**: Uses `ChangeNotifier` to inform the UI of data changes (e.g., when a new session is added).
  - **Role-Based Data Fetching**: On login, it determines the user's role and fetches the appropriate data (e.g., a therapist's students vs. a parent's children).
  - **Loading/Error States**: Manages `isLoading` and `error` flags that the UI can use to show loading spinners or error messages.

### 4.4. SessionExecutionService (`lib/core/services/session_execution_service.dart`)

- **Purpose**: Manages the state and data collection for a real-time therapy session.
- **Key Logic**:
  - `startSession`: Creates a session document in Firestore and sets its status to `in_progress`.
  - `addSessionData`: Adds real-time data points (like behavioral observations, communication attempts, or media files) to the active session document.
  - `endSession`: Finalizes the session, calculates the duration, and sets the status to `completed`.
  - Handles session pause/resume functionality.

---

## 5. Presentation Layer (UI)

### 5.1. Key Screens

- **Login Screen (`lib/presentation/login_screen/login_screen.dart`)**:

  - Allows users to select a role (Therapist/Parent).
  - Handles both login and registration.
  - Directs users to the correct dashboard upon successful authentication.

- **Therapist Dashboard (`lib/presentation/therapist_dashboard/therapist_dashboard.dart`)**:

  - The central hub for therapists.
  - Displays key metrics (e.g., today's sessions, active students).
  - Shows lists of upcoming and completed sessions.
  - Provides a view of student progress at a glance.
  - Entry point for session planning and viewing student profiles.

- **Parent Dashboard (`lib/presentation/parent_dashboard/parent_dashboard.dart`)**:

  - The main interface for parents.
  - Displays assigned activities/homework.
  - Shows child's progress via charts and summaries.
  - Allows parents to view completed activities and communicate with the therapist.
  - Features a logout function and a profile management tab.

- **Session Execution Screen (`lib/presentation/session_execution_screen/session_execution_screen.dart`)**:
  - A real-time interface used during a therapy session.
  - Displays the current activity, instructions, and a timer.
  - Provides controls for data collection (e.g., capturing photos, recording audio, logging observations).

### 5.2. Reusable Widgets

- **`CustomIconWidget`**: A centralized widget to manage and display all icons from a predefined map, ensuring consistency.
- **`EmptyStateWidget` / `ParentEmptyStateWidget`**: Reusable components to show when no data is available (e.g., a parent with no linked children).
- **Navigation Widgets (`TherapistBottomNavigation`)**: Provides consistent navigation patterns across the app.
- **Activity/Metric Cards**: Standardized cards used across dashboards to display information consistently.

---

## 6. Navigation (`lib/routes/app_routes.dart`)

- **Strategy**: The app uses named routes for clear and decoupled navigation. The `AppRoutes` class defines all route constants and maps them to their respective screen widgets.
- **Initial Route**: The app's entry point is the `AuthWrapper` widget, which checks the user's authentication state.
  - If logged in, it fetches the user's role and navigates to the appropriate dashboard (`TherapistDashboard` or `ParentDashboard`).
  - If not logged in, it shows the `LoginScreen`.
- **Role-Based Routing**: After login, the `AuthService` and `DataService` work together to identify the user's role and direct them to the correct dashboard using `Navigator.pushNamedAndRemoveUntil` to clear the navigation stack.

### Key Routes:

| Route Name                    | Screen                           | Purpose                               |
| ----------------------------- | -------------------------------- | ------------------------------------- |
| `/login-screen`               | `LoginScreen`                    | User authentication.                  |
| `/therapist-dashboard`        | `TherapistDashboard`             | Home screen for therapists.           |
| `/parent-dashboard`           | `ParentDashboard`                | Home screen for parents.              |
| `/session-planning-screen`    | `SessionPlanningScreen`          | Creating and scheduling new sessions. |
| `/students-list`              | `StudentsListScreen`             | Viewing all students for a therapist. |
| `/student-profile-management` | `StudentProfileManagementScreen` | Editing a student's profile.          |
| `/admin`                      | `AdminScreen`                    | Administrative functions.             |
