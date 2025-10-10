# Product Requirements Document (PRD)

## ThrivePath - Collaborative ASD Therapy Management Platform

**Version:** 1.0.0  
**Last Updated:** October 9, 2025  
**Document Owner:** Development Team  
**Project Repository:** autism_therapy (saran2006psg)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Product Vision](#product-vision)
3. [User Personas](#user-personas)
4. [Feature Requirements](#feature-requirements)
5. [Technical Architecture](#technical-architecture)
6. [Data Models](#data-models)
7. [User Flows](#user-flows)
8. [Security & Compliance](#security--compliance)
9. [Platform Support](#platform-support)
10. [Success Metrics](#success-metrics)

---

## Executive Summary

**ThrivePath** (branded as ThrivEers) is a comprehensive, multi-platform therapy management application designed specifically for Autism Spectrum Disorder (ASD) interventions. The platform facilitates seamless collaboration between therapists, parents, and students through real-time progress tracking, session planning, and secure communication.

### Key Highlights

- **Multi-Role Architecture**: Distinct interfaces for Therapists, Parents, Students, and Admins
- **Real-Time Collaboration**: Firebase-powered live data synchronization
- **Offline-First Design**: Works seamlessly without internet connectivity
- **Evidence-Based Approach**: Structured goal tracking and progress measurement
- **Cross-Platform**: Android, iOS, and Web support

### Target Market

- Autism therapy clinics and private practices
- Special education centers
- Families managing at-home ASD interventions
- School-based therapy programs

---

## Product Vision

### Mission Statement

"Empowering autism therapy through collaborative technology that connects therapists, families, and students in a unified platform for measurable progress and meaningful outcomes."

### Core Values

1. **Collaboration**: Breaking down silos between therapy stakeholders
2. **Transparency**: Real-time visibility into progress and interventions
3. **Accessibility**: Intuitive interfaces for all technical skill levels
4. **Evidence-Based**: Data-driven decision making for therapy planning
5. **Privacy-First**: HIPAA-compliant data handling and security

### Strategic Goals

- Reduce administrative burden on therapists by 40%
- Improve parent engagement in therapy programs by 60%
- Increase therapy outcome measurement accuracy
- Enable scalable therapy practice management

---

## User Personas

### 1. **Dr. Sarah Chen - Lead Therapist**

**Demographics:**

- Age: 35, Licensed BCBA with 10 years experience
- Manages 15-20 active students
- Works at clinic and provides home-based services

**Goals:**

- Efficiently plan and document therapy sessions
- Track student progress against IEP goals
- Collaborate with parents and school teams
- Generate progress reports for insurance/schools

**Pain Points:**

- Time-consuming paper documentation
- Difficulty sharing updates with parents
- Lack of data visualization for progress trends
- Manual calculation of goal completion rates

**How ThrivePath Helps:**

- Session planning with activity library (60+ pre-built activities)
- Automated progress tracking with visual charts
- One-click session completion and summary generation
- Real-time parent notifications for achievements

---

### 2. **Maria Johnson - Parent/Guardian**

**Demographics:**

- Age: 38, Parent of 7-year-old with ASD
- Works full-time, manages therapy schedule
- Coordinates between school, clinic, and home therapies

**Goals:**

- Stay informed about child's therapy progress
- Complete homework activities correctly
- Communicate concerns to therapy team
- Celebrate achievements and milestones

**Pain Points:**

- Unclear homework instructions
- Delayed progress updates from therapist
- Difficulty tracking multiple therapy goals
- Lack of visibility into session activities

**How ThrivePath Helps:**

- Real-time session summaries with activity notes
- Clear homework cards with step-by-step instructions
- Progress charts showing goal completion trends
- Secure messaging with therapy team

---

### 3. **Alex - Student (Age 8)**

**Demographics:**

- Diagnosed with Level 2 ASD
- Verbal, enjoys visual rewards
- Participates in school and clinic-based therapy

**Goals:**

- Understand what activities come next
- See progress and earn achievements
- Communicate preferences to therapist

**Pain Points:**

- Difficulty with transitions
- Unclear expectations
- Limited engagement with abstract goals

**How ThrivePath Helps:**

- Visual activity schedules
- Achievement badges and progress indicators
- Child-friendly interface (future enhancement)
- Predictable session structures

---

### 4. **Michael Torres - Admin/Practice Manager**

**Demographics:**

- Age: 45, Manages therapy clinic
- Oversees 5 therapists and 60+ students
- Handles billing, compliance, and staffing

**Goals:**

- Monitor therapist productivity
- Ensure documentation compliance
- Generate billing reports
- Manage user accounts and permissions

**Pain Points:**

- Inconsistent documentation quality
- Difficulty tracking billable hours
- Manual user account management

**How ThrivePath Helps:**

- Admin dashboard with user management
- Test user creation for demonstrations
- System-wide analytics (future enhancement)
- Centralized data access

---

## Feature Requirements

### 4.1 Authentication & User Management

#### 4.1.1 Login System

**Priority:** P0 (Critical)

**Functional Requirements:**

- Email/password authentication via Firebase Auth
- Role-based access control (Therapist, Parent, Student, Admin)
- Automatic dashboard routing based on user role
- Remember me / session persistence
- Secure password reset via email

**User Flow:**

1. User opens app → Login screen displays
2. Role selection screen (Therapist/Parent) with feature highlights
3. User selects role → Login form appears
4. Credentials validated → Navigate to role-specific dashboard
5. Invalid credentials → Error message with retry option

**Test Credentials:**

- Therapist: `math@gmail.com` / `math123`
- Parent: `muni@gmail.com` / `muni123`
- Admin: Access via Admin Panel button

**Technical Specs:**

- Firebase Authentication integration
- Firestore user profile validation
- Role stored in `users` collection under `role` field
- Session timeout: 30 days
- Password requirements: Minimum 6 characters

**UI/UX Notes:**

- Role selection screen with icon-based cards
- "How each role helps" educational dialog
- Quick login shortcuts in dev builds
- Loading indicators during authentication
- Role badge indicator after successful login

---

#### 4.1.2 User Profile Management

**Priority:** P1 (High)

**Functional Requirements:**

- View/edit user profile information
- Avatar upload with image cropping
- Role-specific profile fields:
  - **Therapist**: Specialization, License Number, Years of Experience
  - **Parent**: Children IDs, Emergency Contact
  - **Student**: Age, Diagnosis, Communication Level
- Account deactivation (soft delete)

**Technical Specs:**

- Firebase Storage for avatar images
- Image compression before upload (max 500KB)
- Avatar URLs stored in Firestore user document
- Profile update triggers `updatedAt` timestamp

---

### 4.2 Therapist Features

#### 4.2.1 Therapist Dashboard

**Priority:** P0 (Critical)

**Functional Requirements:**

**Key Metrics Cards:**

- Today's Sessions (count + completed count)
- Active Students (total count)
- Completion Rate (percentage this week)
- Average Progress (across all students)

**Progress Visualization:**

- Line chart showing aggregate student progress over time
- Selectable time periods (Week/Month/Quarter)
- FL Chart library for rendering

**Upcoming Sessions:**

- List view with student name, session type, time, status
- Swipe-to-reschedule functionality
- Tap to view session details
- Status indicators (Scheduled/In Progress/Completed)

**Completed Sessions:**

- Recent 5 sessions displayed
- View session reports
- Session summary with achievements

**Student Progress Section:**

- Horizontal scrollable cards for each student
- Progress bar (0-100%)
- Recent achievements list
- Tap to navigate to student profile

**Activity Monitoring:**

- Recently completed activities (5 most recent)
- In-progress activities (3 showing)
- Activity status badges
- Student notes display

**Quick Actions:**

- Floating Action Button with expandable menu
- "Schedule Session" → Session Planning Screen
- "View Reports" → Reports interface
- "Settings" → Settings screen

**Technical Specs:**

- Real-time Firestore streams for students and sessions
- DataService integration for data management
- Refresh indicator for manual sync
- Connectivity status indicator
- Last sync timestamp display

**UI Components:**

- `MetricCardWidget` - Stat cards with tap/long-press actions
- `SessionOverviewCardWidget` - Session list with actions
- `StudentProgressCardWidget` - Student info cards
- `QuickActionSheetWidget` - Bottom sheet action menu
- `ConnectivityStatusWidget` - Online/offline indicator

---

#### 4.2.2 Session Planning Screen

**Priority:** P0 (Critical)

**Functional Requirements:**

**Session Configuration:**

- Select student from dropdown
- Choose session date (date picker)
- Select session time (time picker)
- Set session duration (30/45/60/90 minutes)
- Visual duration indicator vs. planned activities

**Student Management:**

- View list of assigned students
- Quick "Add Student" button if no students exist
- Student search/filter capabilities
- Student status indicators

**Activity Library:**

- 60+ pre-built activities categorized by:
  - Communication
  - Social Skills
  - Behavioral
  - Academic
  - Sensory
  - Motor Skills
- Search activities by name/description
- Filter by category
- Activity details: title, description, duration, difficulty

**Activity Planning:**

- Drag-to-reorder activities
- Add activities to session plan
- Remove activities from plan
- Set activity duration for each
- View total planned time vs. session duration

**Session Timeline:**

- Visual timeline showing activity sequence
- Color-coded by category
- Time allocation per activity
- Warning if over/under planned duration

**Multi-Student Support:**

- Plan sessions for multiple students
- Switch between students without losing changes
- Per-student activity lists maintained

**Session Saving:**

- Save session to Firestore
- Validation checks (student selected, activities added)
- Success confirmation with option to plan another
- "Unsaved changes" warning on navigation

**Technical Specs:**

- `SessionPlanningScreen` StatefulWidget
- DataService integration for students/activities
- Stream subscriptions for real-time student updates
- Local state management for unsaved plans
- Animation controllers for FAB and transitions

**UI Components:**

- `SessionHeaderWidget` - Date/time/duration selector
- `SessionTimelineWidget` - Visual activity timeline
- `ActivityCardWidget` - Activity library items
- `StudentSelectorWidget` - Student dropdown

**Validation Rules:**

- Student must be selected
- At least 1 activity required
- Session date cannot be in the past
- Total planned duration warning if >120% of session duration

---

#### 4.2.3 Student Management

**Priority:** P1 (High)

**Functional Requirements:**

**Student List View:**

- View all assigned students
- Search by name
- Filter by status (Active/Inactive)
- Sort by name, age, or recent session

**Add Student Form:**

- Personal Information:
  - First Name, Last Name (required)
  - Date of Birth / Age (required)
  - Gender
  - Avatar upload
- Clinical Information:
  - Diagnosis (required)
  - Communication Level (Verbal/Non-verbal/Limited)
  - Sensory Needs (text area)
  - Triggers (comma-separated list)
  - Severity (Level 1/2/3)
- Parent/Guardian:
  - Parent email(s) for linking
  - Emergency contacts (name, phone, relationship)
- Student Login (Optional):
  - Create Firebase Auth account for student
  - Auto-generated password or custom
  - Student role assignment

**Student Profile:**

- View complete student information
- Edit student details
- Deactivate student (soft delete)
- View session history
- View goal progress
- View parent information

**Technical Specs:**

- Form validation with GlobalKey<FormState>
- Firebase Auth account creation for students
- Firestore student document creation
- Parent linking via email lookup
- Avatar upload to Firebase Storage

**Data Model:**

```dart
StudentModel {
  id, firstName, lastName, age, dateOfBirth,
  gender, avatarUrl, diagnosis, communicationLevel,
  sensoryNeeds, triggers[], severity, therapistId,
  parentIds[], goalIds[], emergencyContacts{},
  preferences{}, isActive, createdAt, updatedAt
}
```

---

#### 4.2.4 Goal Management

**Priority:** P1 (High)

**Functional Requirements:**

**Create Goal:**

- SMART goal components:
  - Title (specific goal statement)
  - Description (detailed explanation)
  - Category (Communication/Social/Behavioral/Academic)
  - Priority (High/Medium/Low)
  - Target Date
  - Measurement Criteria
  - Strategies (list of intervention strategies)
- Milestone tracking:
  - Add multiple milestones
  - Each with description and target date
  - Milestone completion tracking

**Goal Tracking:**

- Progress percentage (0-100%)
- Visual progress bar
- Status (Active/Completed/Paused/Cancelled)
- Automatic status change to Completed at 100%

**Goal Association:**

- Link goals to specific students
- Associate goals with session activities
- View goal progress in student profile

**Technical Specs:**

- `GoalModel` with comprehensive fields
- Firestore `goals` collection
- Goal IDs stored in student document
- Progress calculation based on milestones or manual entry

---

### 4.3 Parent Features

#### 4.3.1 Parent Dashboard

**Priority:** P0 (Critical)

**Functional Requirements:**

**Child Selection:**

- Multi-child support
- Swipe-able child selector if multiple children
- Child profile card with photo, name, age, diagnosis

**Progress Visualization:**

- Weekly/Monthly progress charts (FL Chart)
- Goal completion trends
- Session attendance visualization
- Activity completion rates

**Activity Management:**

- **Completed Activities Section:**
  - List of completed homework/activities
  - Completion date and student notes
  - Therapist feedback display
  - Photo evidence of completion
- **Not Completed Activities Section:**
  - Pending homework assignments
  - Due dates with color-coded urgency
  - Activity instructions with step numbers
  - Mark as complete button
  - Add notes/photos option
  - Progress indicator (X/Y activities completed)

**Session History:**

- Recent session summaries
- Session date, therapist name, duration
- Activity list with completion status
- Session achievements
- Homework assigned

**Communication:**

- Unread message counter badge
- Quick message button
- Secure messaging with therapist (future)

**Profile Tab:**

- Parent profile information
- Linked children list
- Account settings
- Help & Support
- About ThrivePath
- Logout

**Technical Specs:**

- Mock data implementation (currently disconnected from live database)
- `MockChild`, `MockSession`, `MockGoal` classes
- Tab-based navigation (Activities/Messages/Profile)
- RefreshIndicator for pull-to-refresh
- Bottom navigation bar

**UI Components:**

- `ChildHeaderWidget` - Child info card
- `ProgressChartWidget` - Chart visualization
- `HomeworkCardWidget` - Activity cards with completion

**Known Limitations:**

- Not connected to real-time Firebase (intentional for demo)
- Mock data hardcoded in `parent_dashboard.dart`
- Features marked as "coming soon" in UI

---

#### 4.3.2 Homework & Activity Completion

**Priority:** P0 (Critical)

**Functional Requirements:**

**Activity Display:**

- Session title and scheduled date
- Activity list with:
  - Activity name
  - Description/instructions
  - Status (Not Started/In Progress/Completed)
  - Due date indicator
  - Student notes from therapist

**Completion Actions:**

- Mark activity as complete
- Add parent notes/observations
- Upload photo evidence (camera or gallery)
- Submit to therapist for review

**Progress Tracking:**

- Activity-level completion status
- Session-level completion percentage
- Visual progress bars
- Completion date timestamps

**Notifications (Future):**

- Homework due reminders
- New homework assigned alerts
- Therapist feedback received

**Technical Specs:**

- Image picker integration for photo uploads
- Firebase Storage for activity photos
- Activity status updates to Firestore
- Parent notes stored with activity record

---

### 4.4 Admin Features

#### 4.4.1 Admin Panel

**Priority:** P2 (Medium)

**Functional Requirements:**

**User Management:**

- Create test users (Parent/Therapist)
- Predefined credentials:
  - `math@gmail.com` / `math123` (Therapist)
  - `muni@gmail.com` / `muni123` (Parent)
- View all users in system
- Deactivate/reactivate user accounts

**Data Management:**

- Reset all data (demo reset function)
- View database statistics
- Export data (future)

**System Status:**

- Firebase connection status
- Active user count
- Session count
- Student count

**Technical Specs:**

- AuthService integration for user creation
- Firestore batch operations for data reset
- Admin-only route protection
- Hidden from production builds

---

### 4.5 Session Execution (Real-Time)

#### 4.5.1 Live Session Interface

**Priority:** P1 (High)

**Functional Requirements:**

**Session Start:**

- Start session from session plan
- Auto-record start time
- Status changes to "In Progress"

**Activity Execution:**

- Display current activity
- Timer for activity duration
- Behavioral observations entry
- Data collection forms (frequency, duration, etc.)
- Quick notes field
- Photo/video capture

**Session Navigation:**

- Move to next activity
- Go back to previous activity
- Skip activity (with reason)
- Add unplanned activity

**Session Summary:**

- Review all completed activities
- Add session summary notes
- List achievements/milestones
- Assign homework
- Plan next session focus
- Complete session button

**Technical Specs:**

- SessionModel with `sessionData[]` array
- Real-time status updates to Firestore
- Timer integration with pause/resume
- Media file uploads to Firebase Storage

---

### 4.6 Progress Tracking & Reporting

#### 4.6.1 Progress Entry

**Priority:** P1 (High)

**Functional Requirements:**

**Progress Types:**

- Session-based progress (automatic from session completion)
- Goal-based progress (manual milestone updates)
- Behavioral data (ABC data, frequency counts)
- Skill acquisition data (trial-by-trial)

**Data Collection:**

- Quantitative metrics (numbers, percentages)
- Qualitative observations (text notes)
- Media evidence (photos, recordings)
- Timestamps for all entries

**Technical Specs:**

- `ProgressModel` for all progress entries
- Flexible `metrics{}` map for different data types
- Link to `goalId` and `sessionId`
- `type` field for categorization

---

#### 4.6.2 Reports & Analytics

**Priority:** P2 (Medium)

**Functional Requirements:**

**Progress Reports:**

- Goal progress summary
- Session attendance rates
- Activity completion trends
- Behavioral trend analysis

**Visualizations:**

- Line charts for progress over time
- Bar charts for goal completion
- Pie charts for time allocation
- Heat maps for session frequency

**Export Options:**

- PDF report generation
- CSV data export
- Email report to parents/schools
- Print-friendly format

**Technical Specs:**

- Report generation using PDF library
- Chart rendering with FL Chart
- Data aggregation queries in Firestore
- Email integration for sharing

---

## Technical Architecture

### 5.1 Technology Stack

**Frontend Framework:**

- Flutter 3.x (Dart SDK 3.8.1)
- Material Design 3 theming
- Responsive design with Sizer package (2.0.15)

**Backend Services:**

- Firebase Authentication 6.0.0
- Cloud Firestore 6.0.0 (NoSQL database)
- Firebase Storage 13.0.0 (file storage)
- Firebase Realtime Database 12.0.0

**State Management:**

- Provider 6.1.2
- StatefulWidget with ChangeNotifier
- DataService singleton pattern

**UI Libraries:**

- FL Chart 0.69.2 (data visualization)
- Cached Network Image 3.4.1
- Google Fonts (Poppins, Inter)
- Image Picker 1.1.2

**Development Tools:**

- Android Studio / VS Code
- Flutter DevTools
- Firebase Console
- Git version control

---

### 5.2 Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── models/                   # Data models
│   │   ├── student_model.dart    # Student profile model
│   │   ├── session_model.dart    # Therapy session model
│   │   ├── goal_model.dart       # Therapeutic goals model
│   │   ├── progress_model.dart   # Progress tracking model
│   │   └── activity_model.dart   # Activity definitions
│   ├── services/                 # Business logic services
│   │   ├── auth_service.dart     # Authentication service
│   │   ├── firestore_service.dart# Database operations
│   │   ├── data_service.dart     # Centralized data management
│   │   ├── test_data_service.dart# Development data utilities
│   │   └── image_upload_service.dart # Media handling
│   ├── utils/                    # Utility classes
│   │   ├── app_logger.dart       # Centralized logging
│   │   ├── color_utils.dart      # Color migration helpers
│   │   └── async_utils.dart      # Safe async state management
│   └── app_export.dart           # Barrel export file
├── presentation/                  # UI layers
│   ├── login_screen/             # Authentication UI
│   │   └── widgets/              # Login-specific widgets
│   ├── therapist_dashboard/      # Therapist interface
│   │   └── widgets/              # Dashboard-specific widgets
│   ├── parent_dashboard/         # Parent interface
│   │   └── widgets/              # Dashboard-specific widgets (3 widgets)
│   │       ├── child_header_widget.dart
│   │       ├── homework_card_widget.dart
│   │       └── progress_chart_widget.dart
│   ├── session_planning_screen/  # Session planning tools
│   │   └── widgets/              # Planning widgets
│   ├── session_execution_screen/ # Real-time session tracking (P2 feature)
│   │   └── widgets/              # Session execution widgets
│   ├── student_profile_management_screen/ # Profile management
│   │   └── widgets/              # Profile widgets
│   ├── profile_buddy_screen/     # Student profile viewer
│   ├── students_list_screen/     # Student list view
│   ├── therapist_profile_screen/ # Therapist profile
│   ├── admin_screen/             # Administrative interface
│   ├── forms/                    # Form screens
│   │   └── add_student_form.dart # Student creation form
│   └── settings_screen/          # App settings
├── routes/                       # Navigation management
│   └── app_routes.dart           # Route definitions
├── theme/                        # App theming and styling
│   └── app_theme.dart            # Theme configuration
├── widgets/                      # Reusable UI components
│   ├── navigation/               # Navigation widgets
│   ├── custom_icon_widget.dart   # Icon wrapper
│   ├── custom_image_widget.dart  # Image wrapper
│   ├── theme_toggle_widget.dart  # Dark mode toggle
│   └── auth_wrapper.dart         # Auth state wrapper
├── firebase_options.dart         # Firebase configuration
└── main.dart                     # App entry point

android/                          # Android platform code
ios/                             # iOS platform code
web/                             # Web platform code
```

---

### 5.3 Data Flow Architecture

**Pattern: Service Layer + State Management**

```
User Action → Widget Event Handler
    ↓
DataService Method
    ↓
FirestoreService CRUD Operation
    ↓
Firebase Cloud Firestore
    ↓
Stream/Future Response
    ↓
DataService State Update (notifyListeners)
    ↓
Widget Rebuild (Provider/StreamBuilder)
```

**Key Components:**

1. **AuthService** - Handles all authentication logic

   - Sign in/Sign up
   - User profile creation
   - Role-based routing

2. **FirestoreService** - Static methods for Firestore operations

   - CRUD operations for all collections
   - Stream subscriptions for real-time data
   - Query optimization

3. **DataService** - Singleton ChangeNotifier

   - Centralized data cache
   - Role-based data loading
   - State management
   - Loading states
   - Error handling

4. **TestDataService** - Development utilities
   - Sample data generation
   - Data reset functionality
   - User account creation

---

### 5.4 Firebase Configuration

**Project ID:** `ablnew-9f930`  
**Package Name:** `com.example.thriveers`  
**Bundle ID:** `com.example.thriveers`

**Firestore Collections:**

```
users/              # User profiles (therapist, parent, student, admin)
students/           # Student profiles
sessions/           # Therapy sessions
goals/              # Therapeutic goals
progress/           # Progress entries
activities/         # Activity library (pre-built activities)
```

**Firestore Security Rules:**

- Role-based read/write access
- Users can only access their own data
- Therapists access their students' data
- Parents access their children's data
- Students access their own data only

**Firebase Storage Structure:**

```
avatars/            # User profile pictures
  ├── users/{userId}/
  └── students/{studentId}/
session_media/      # Session photos/recordings
  └── {sessionId}/
activity_photos/    # Homework completion photos
  └── {activityId}/
```

---

### 5.5 Offline Support

**Strategy: Offline-First with Firebase Persistence**

**Implementation:**

- Firestore offline persistence enabled
- Local caching of frequently accessed data
- Sync queue for pending operations
- Connectivity status monitoring

**Code Example:**

```dart
await FirebaseFirestore.instance
    .settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
```

**User Experience:**

- Visual connectivity indicator on dashboards
- "Last synced" timestamp display
- Automatic sync on reconnection
- Queued operations processed in order

---

## Data Models

### 6.1 StudentModel

**Purpose:** Comprehensive student profile with clinical and administrative information

**Schema:**

```dart
class StudentModel {
  String? id;                     // Firebase Auth UID (if student login enabled)
  String firstName;               // Required
  String lastName;                // Required
  int age;                        // Calculated from DOB
  DateTime dateOfBirth;           // Required
  String gender;                  // Male/Female/Non-binary/Prefer not to say
  String? avatarUrl;              // Firebase Storage URL
  String diagnosis;               // ASD Level 1/2/3, other diagnoses
  String communicationLevel;      // Verbal/Non-verbal/Limited verbal
  String sensoryNeeds;            // Text description
  List<String> triggers;          // Environmental/sensory triggers
  String severity;                // Level 1/2/3
  String therapistId;             // Assigned primary therapist
  List<String> parentIds;         // Linked parent accounts
  List<String> goalIds;           // Associated therapy goals
  Map<String, dynamic> emergencyContacts;  // Contact information
  Map<String, dynamic> preferences;        // Session preferences
  bool isActive;                  // Soft delete flag
  DateTime createdAt;
  DateTime updatedAt;
}
```

**Firestore Path:** `students/{studentId}`

**Indexes:**

- `therapistId` (for therapist queries)
- `parentIds` (array-contains for parent queries)
- `isActive` (filter inactive students)

---

### 6.2 SessionModel

**Purpose:** Therapy session planning and execution data

**Schema:**

```dart
class SessionModel {
  String? id;
  String studentId;               // Reference to student
  String therapistId;             // Reference to therapist
  String type;                    // "Therapy Session", "Assessment", "Consultation"
  String title;                   // Session title
  String? description;            // Session notes
  DateTime scheduledDate;         // Planned session date/time
  DateTime? startTime;            // Actual start (null until started)
  DateTime? endTime;              // Actual end (null until completed)
  int estimatedDuration;          // In minutes (30/45/60/90)
  int? actualDuration;            // Calculated on completion
  String status;                  // "scheduled", "in_progress", "completed", "cancelled"
  List<String> goalIds;           // Goals addressed in session
  List<Map<String, dynamic>> activities;  // Planned/executed activities
  List<Map<String, dynamic>> sessionData; // Behavioral observations
  List<String> mediaFiles;        // Photo/video URLs
  String? summary;                // Post-session summary
  List<String> achievements;      // Milestones reached
  String? homeworkAssigned;       // Homework for parents
  String? nextSessionFocus;       // Notes for next session
  Map<String, dynamic> progress;  // Session progress metrics
  DateTime createdAt;
  DateTime updatedAt;
}
```

**Firestore Path:** `sessions/{sessionId}`

**Activity Structure:**

```dart
{
  'id': 'activity_123',
  'title': 'Visual Schedule Practice',
  'description': 'Practice using visual schedule for transitions',
  'category': 'Communication',
  'estimatedDuration': 15,        // minutes
  'status': 'not_started',        // in_progress, completed
  'startTime': DateTime?,
  'endTime': DateTime?,
  'studentNotes': 'Required 2 verbal prompts',
  'observations': 'Improved from last session',
  'data': {                       // Custom data collection
    'trials': 10,
    'correct': 8,
    'prompts': 2
  }
}
```

---

### 6.3 GoalModel

**Purpose:** SMART therapeutic goals with milestone tracking

**Schema:**

```dart
class GoalModel {
  String? id;
  String studentId;
  String therapistId;
  String title;                   // Goal statement
  String description;             // Detailed description
  String category;                // "communication", "social", "behavioral", "academic"
  String priority;                // "high", "medium", "low"
  String status;                  // "active", "completed", "paused", "cancelled"
  DateTime targetDate;            // Goal completion target
  double progressPercentage;      // 0.0 to 100.0
  List<Map<String, dynamic>> milestones;  // Intermediate milestones
  List<String> strategies;        // Intervention strategies
  Map<String, dynamic> measurementCriteria;  // How to measure success
  String? notes;                  // Additional notes
  DateTime createdAt;
  DateTime updatedAt;
}
```

**Milestone Structure:**

```dart
{
  'description': 'Use 2-word phrases 5 times per session',
  'targetDate': DateTime,
  'completed': false,
  'completedDate': DateTime?
}
```

**Measurement Criteria Example:**

```dart
{
  'frequency': 'daily',
  'duration': '5 minutes',
  'success_criteria': '80% completion rate over 3 sessions',
  'baseline': '20% correct responses',
  'target': '80% correct responses'
}
```

---

### 6.4 ProgressModel

**Purpose:** Record discrete progress entries linked to sessions or goals

**Schema:**

```dart
class ProgressModel {
  String? id;
  String studentId;
  String? goalId;                 // Optional goal reference
  String? sessionId;              // Optional session reference
  String type;                    // "session", "goal", "behavioral", "skill"
  DateTime date;                  // Progress date
  Map<String, dynamic> metrics;   // Flexible metrics
  String? notes;                  // Therapist notes
  List<String> mediaFiles;        // Supporting media
  String therapistId;
  DateTime createdAt;
}
```

**Metrics Examples:**

```dart
// Behavioral progress
{
  'behavior': 'hand_flapping',
  'frequency': 3,
  'duration_seconds': 45,
  'antecedent': 'transition',
  'consequence': 'sensory_break'
}

// Skill acquisition
{
  'skill': 'two_word_phrases',
  'trials': 10,
  'correct': 7,
  'prompted': 2,
  'independent': 5
}

// Goal progress
{
  'goal_milestone': 'milestone_2',
  'percentage': 65,
  'notes': 'Showing consistent improvement'
}
```

---

### 6.5 ActivityModel (Library)

**Purpose:** Pre-built activity templates for session planning

**Schema:**

```dart
class ActivityModel {
  String? id;
  String name;                    // Activity name
  String description;             // Detailed instructions
  String category;                // "communication", "social", "behavioral", etc.
  String type;                    // "structured", "play-based", "sensory"
  int estimatedDuration;          // Minutes
  String? iconName;               // UI icon identifier
  List<String> materials;         // Required materials
  List<String> instructions;      // Step-by-step instructions
  Map<String, dynamic> goals;     // Typical goals addressed
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isCustom;                 // User-created vs. pre-built
  String? createdBy;              // Therapist ID if custom
}
```

**Firestore Path:** `activities/{activityId}`

**Example Pre-built Activities:**

- Visual Schedule Practice (Communication, 15 min)
- Turn-Taking Game (Social Skills, 20 min)
- Deep Pressure Routine (Sensory, 10 min)
- Emotion Flashcards (Social Skills, 15 min)
- Token Economy System (Behavioral, 30 min)
- Articulation Practice (Communication, 20 min)

---

### 6.6 User Model (Authentication)

**Purpose:** User accounts for all platform roles

**Schema:**

```dart
// Stored in Firestore 'users' collection
{
  'uid': String,                  // Firebase Auth UID
  'email': String,
  'name': String,
  'role': String,                 // "Therapist", "Parent", "Student", "Admin"
  'avatarUrl': String?,
  'phoneNumber': String?,
  'createdAt': Timestamp,
  'updatedAt': Timestamp,
  'lastLoginAt': Timestamp,
  'isActive': bool,

  // Role-specific fields (conditionally present)

  // Therapist fields:
  'specialization': String?,
  'licenseNumber': String?,
  'yearsOfExperience': int?,
  'studentIds': List<String>,
  'certifications': List<String>,

  // Parent fields:
  'childrenIds': List<String>,
  'primaryContact': bool,
  'emergencyContact': String?,

  // Student fields: (usually not needed as StudentModel is separate)
}
```

---

## User Flows

### 7.1 Therapist Session Planning Flow

```
START: Therapist Dashboard
  ↓
Tap "Schedule Session" (FAB or Quick Actions)
  ↓
Navigate to Session Planning Screen
  ↓
Select Student (dropdown or "Add Student" if none)
  ↓
Set Session Date (date picker)
  ↓
Set Session Time (time picker)
  ↓
Set Session Duration (slider: 30/45/60/90 min)
  ↓
Browse Activity Library
  ↓
Search/Filter activities by category
  ↓
Tap activity to add to session plan
  ↓
View Session Timeline (visual verification)
  ↓
Reorder activities (drag handles)
  ↓
Adjust individual activity durations
  ↓
Review: Total planned time vs. session duration
  ↓
Tap "Save Session" button
  ↓
Validation:
  - Student selected? ✓
  - At least 1 activity? ✓
  - Session date valid? ✓
  ↓
Save to Firestore (SessionModel created)
  ↓
Success message displayed
  ↓
Options:
  1. "Plan Another Session" → Reset form
  2. "Back to Dashboard" → Navigate back
  ↓
END
```

**Error Handling:**

- No student selected → Show error snackbar
- No activities added → Show warning dialog
- Network error → Save to queue, sync later

---

### 7.2 Parent Homework Completion Flow

```
START: Parent Dashboard (Activities Tab)
  ↓
View list of assigned activities
  ↓
Sections visible:
  - Completed Activities (green, read-only)
  - Not Completed Activities (yellow/red, actionable)
  ↓
Select activity from "Not Completed" section
  ↓
View Activity Card:
  - Session title
  - Activity name
  - Description/instructions
  - Therapist notes
  - Due date
  ↓
Read instructions carefully
  ↓
Perform activity with child
  ↓
Tap "Mark as Complete" button
  ↓
Optional: Add Parent Notes
  ↓
Optional: Upload Photo (camera or gallery)
  ↓
Tap "Submit" button
  ↓
Update Firestore:
  - status: "completed"
  - completedAt: DateTime.now()
  - studentNotes: parent notes
  - photoUrl: uploaded image URL
  ↓
Success confirmation
  ↓
Activity moves to "Completed" section
  ↓
Progress percentage updates
  ↓
Notification sent to therapist (future)
  ↓
END
```

**Alternative Paths:**

- Photo upload fails → Save without photo, allow retry
- Network offline → Queue for sync, show pending indicator
- Cancel before submit → Discard changes, return to list

---

### 7.3 User Authentication Flow

```
START: App Launch
  ↓
Check Firebase Auth state
  ↓
User authenticated?
  ├─ NO → Show Login Screen
  │    ↓
  │  Display Role Selection Screen
  │    ↓
  │  User selects role (Therapist/Parent)
  │    ↓
  │  Show role-specific login form
  │    ↓
  │  User enters email/password
  │    ↓
  │  Submit credentials
  │    ↓
  │  Firebase Auth validation
  │    ↓
  │  Success?
  │    ├─ NO → Show error message, retry
  │    └─ YES → Continue to role check
  │
  └─ YES → Continue to role check
       ↓
Fetch user profile from Firestore
  ↓
Extract 'role' field
  ↓
Role-based routing:
  - "Therapist" → TherapistDashboard
  - "Parent" → ParentDashboard
  - "Student" → StudentDashboard (future)
  - "Admin" → AdminScreen
  ↓
Initialize DataService
  ↓
Load role-specific data:
  - Therapist: Load students, sessions, goals
  - Parent: Load children, sessions, activities
  ↓
Render dashboard with real-time streams
  ↓
END
```

**Special Cases:**

- User profile not found → Create default profile, assign role
- Multiple roles → Prompt user to select active role
- Session expired → Redirect to login, preserve navigation intent

---

### 7.4 Session Execution Flow (Real-Time)

```
START: Therapist Dashboard
  ↓
View "Upcoming Sessions" card
  ↓
Tap session to start
  ↓
Navigate to Session Execution Screen
  ↓
Display session details:
  - Student name
  - Planned activities
  - Session duration
  ↓
Tap "Start Session" button
  ↓
Update Firestore:
  - status: "in_progress"
  - startTime: DateTime.now()
  ↓
Display first activity:
  - Activity name
  - Instructions
  - Materials list
  - Timer
  ↓
Start activity timer
  ↓
Therapist performs activity with student
  ↓
Record data during activity:
  - Behavioral observations
  - Trial-by-trial data
  - Photos/videos
  - Quick notes
  ↓
Activity completed?
  ↓
Tap "Next Activity" button
  ↓
Update activity status: "completed"
  ↓
Move to next activity
  ↓
Repeat for all activities
  ↓
All activities completed?
  ↓
Tap "Complete Session" button
  ↓
Display Session Summary Form:
  - Overall session notes
  - Achievements/milestones reached
  - Homework to assign
  - Next session focus
  ↓
Fill out summary
  ↓
Tap "Submit" button
  ↓
Update Firestore:
  - status: "completed"
  - endTime: DateTime.now()
  - actualDuration: calculated
  - summary: notes
  - achievements: list
  - homeworkAssigned: text
  ↓
Generate automatic progress entries
  ↓
Send notification to parent
  ↓
Navigate back to dashboard
  ↓
END
```

**Mid-Session Options:**

- Pause session → Save state, allow resume later
- Skip activity → Record reason, mark as skipped
- Add unplanned activity → Create ad-hoc activity
- Emergency stop → Save partial data, mark as interrupted

---

## Security & Compliance

### 8.1 Data Privacy

**HIPAA Compliance Considerations:**

- **Encryption:** All data encrypted in transit (TLS) and at rest (Firebase default)
- **Access Controls:** Role-based permissions enforced via Firestore rules
- **Audit Logging:** Firebase Authentication logs all access
- **Data Minimization:** Only collect necessary clinical data
- **User Consent:** Terms of Service and Privacy Policy acceptance required

**Firebase Security Rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }

    function isTherapist() {
      return getUserRole() == 'Therapist';
    }

    function isParent() {
      return getUserRole() == 'Parent';
    }

    function isStudent() {
      return getUserRole() == 'Student';
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated() && request.auth.uid == userId;
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }

    // Students collection
    match /students/{studentId} {
      allow read: if isAuthenticated() && (
        isTherapist() ||
        (isParent() && request.auth.uid in resource.data.parentIds) ||
        (isStudent() && request.auth.uid == studentId)
      );
      allow create: if isAuthenticated() && isTherapist();
      allow update: if isAuthenticated() && (
        isTherapist() ||
        (isParent() && request.auth.uid in resource.data.parentIds)
      );
    }

    // Sessions collection
    match /sessions/{sessionId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && isTherapist();
      allow update: if isAuthenticated() && (
        isTherapist() ||
        isParent()  // Parents can update homework activities
      );
    }

    // Goals collection
    match /goals/{goalId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && isTherapist();
    }

    // Progress collection
    match /progress/{progressId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && isTherapist();
    }

    // Activities library (read-only for most users)
    match /activities/{activityId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && isTherapist();
    }
  }
}
```

---

### 8.2 Authentication Security

**Password Policy:**

- Minimum 6 characters (Firebase Auth default)
- Recommendation: 8+ characters with mixed case and symbols
- Password reset via verified email only

**Session Management:**

- Auto-logout after 30 days of inactivity
- Secure token storage (Firebase handles)
- No credentials stored locally

**Account Protection:**

- Email verification for new accounts (future)
- Two-factor authentication option (future)
- Account lockout after 5 failed attempts (Firebase default)

---

### 8.3 Data Backup & Recovery

**Firebase Automatic Backup:**

- Daily automated Firestore backups
- Point-in-time recovery available
- 7-day retention for standard plan

**Manual Backup:**

- Export data via Firebase Console
- JSON format for all collections
- Storage bucket backups via gsutil

**Disaster Recovery:**

- Multi-region replication (Firebase default)
- 99.999% uptime SLA
- Automatic failover

---

## Platform Support

### 9.1 Android

**Minimum SDK:** 23 (Android 6.0 Marshmallow)  
**Target SDK:** 34 (Android 14)  
**Build Configuration:** `build.gradle.kts`

**Platform-Specific Features:**

- Google Sign-In (future)
- Push notifications via FCM
- Background sync for offline data
- Android-specific permissions (camera, storage, notifications)

**Testing:**

- Tested on Android 6.0 through Android 14
- Physical device testing required for camera/sensors
- Emulator testing for screen sizes

---

### 9.2 iOS

**Minimum Version:** iOS 12.0  
**Target Version:** iOS 17.0  
**Build Configuration:** Xcode project

**Platform-Specific Features:**

- Apple Sign-In (future, required for App Store)
- Push notifications via APNs
- iOS-specific permissions (camera, photo library, notifications)

**Considerations:**

- CocoaPods dependency management
- Requires macOS and Xcode for builds
- TestFlight for beta distribution

---

### 9.3 Web

**Browsers Supported:**

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

**Platform-Specific Features:**

- Responsive design (mobile, tablet, desktop)
- PWA capabilities (future)
- Web camera access for photo upload

**Limitations:**

- No offline file storage (browser limitations)
- Reduced performance vs. native mobile
- Limited sensor access

**Deployment:**

- Firebase Hosting
- Custom domain support
- SSL/TLS certificates auto-managed

---

### 9.4 Desktop (Removed)

**Status:** Desktop support (Windows, macOS, Linux) was removed from project scope.

**Reason:** Focus on mobile and web platforms for therapy context.

---

## Success Metrics

### 10.1 User Engagement Metrics

**Therapist KPIs:**

- Daily Active Therapists (DAU)
- Average sessions planned per therapist per week
- Average session completion time
- Goal creation rate
- Student-to-therapist ratio

**Target:** 80% of therapists use app daily, 10+ sessions/week

**Parent KPIs:**

- Daily Active Parents (DAU)
- Homework completion rate
- Average time to complete homework after assignment
- Message response rate (future)

**Target:** 70% homework completion within 48 hours

---

### 10.2 Clinical Outcome Metrics

**Goal Achievement:**

- Percentage of goals achieved on time
- Average goal completion time vs. target
- Goal progress velocity (% per week)

**Target:** 70% of goals achieved within target timeline

**Session Effectiveness:**

- Activity completion rate per session
- Student engagement scores (therapist-reported)
- Session cancellation rate

**Target:** <10% session cancellation rate

---

### 10.3 Technical Performance Metrics

**App Performance:**

- App crash rate
- Average app launch time
- Screen load times
- API response times

**Target:** <1% crash rate, <2s screen load

**Data Sync:**

- Offline data sync success rate
- Average sync time
- Network error rate

**Target:** >98% sync success rate

---

### 10.4 Business Metrics

**User Acquisition:**

- New user sign-ups per month
- Therapist vs. parent ratio (should be 1:3 to 1:5)
- User activation rate (complete first session)

**User Retention:**

- 7-day retention rate
- 30-day retention rate
- Monthly churn rate

**Target:** 60% 7-day retention, 40% 30-day retention

---

## Roadmap & Future Enhancements

### Phase 1: MVP (Current)

- ✅ Role-based authentication
- ✅ Therapist dashboard with metrics
- ✅ Session planning with activity library
- ✅ Parent dashboard with homework
- ✅ Basic progress tracking
- ✅ Offline support

### Phase 2: Enhanced Collaboration (Q1 2026)

- 🔲 In-app secure messaging
- 🔲 Push notifications
- 🔲 Real-time session execution interface
- 🔲 Enhanced reporting with PDF export
- 🔲 Video call integration (future)

### Phase 3: Analytics & Intelligence (Q2 2026)

- 🔲 Advanced analytics dashboard
- 🔲 Predictive insights (ML-based)
- 🔲 Automated progress report generation
- 🔲 Trend analysis for behavioral patterns

### Phase 4: Scale & Enterprise (Q3 2026)

- 🔲 Multi-clinic support
- 🔲 Billing integration
- 🔲 Insurance claim generation
- 🔲 School district integrations
- 🔲 API for third-party integrations

---

## Appendix

### A. Glossary

- **ASD:** Autism Spectrum Disorder
- **BCBA:** Board Certified Behavior Analyst
- **IEP:** Individualized Education Program
- **SMART Goals:** Specific, Measurable, Achievable, Relevant, Time-bound
- **ABC Data:** Antecedent-Behavior-Consequence data collection
- **Prompt:** Support given to help student complete task

### B. Test Accounts

**Therapist:**

- Email: `math@gmail.com`
- Password: `math123`

**Parent:**

- Email: `muni@gmail.com`
- Password: `muni123`

**Admin:**

- Access via "Admin Panel" button on login screen

### C. Firebase Project Details

**Project ID:** ablnew-9f930  
**Region:** us-central1  
**Authentication:** Email/Password enabled  
**Firestore:** Production mode  
**Storage:** Public read, authenticated write

### D. Contact & Support

**Development Team:** ThrivePath Development Team  
**Repository:** https://github.com/saran2006psg/autism_therapy  
**Issue Tracker:** GitHub Issues

---

**Document Version:** 1.0.0  
**Last Updated:** October 9, 2025  
**Next Review:** January 2026
