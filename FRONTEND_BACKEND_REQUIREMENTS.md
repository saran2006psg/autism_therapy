# ThrivEers Frontend Architecture & Backend Requirements

**Version:** 1.0  
**Date:** October 10, 2025  
**Repository:** autism_therapy (saran2006psg)

---

## 📋 Table of Contents

1. [Frontend Architecture Overview](#frontend-architecture-overview)
2. [Screens & Page Structure](#screens--page-structure)
3. [Widget Component Library](#widget-component-library)
4. [Navigation & Routing](#navigation--routing)
5. [State Management](#state-management)
6. [Theme & Styling System](#theme--styling-system)
7. [Backend Requirements](#backend-requirements)
8. [API Endpoints Needed](#api-endpoints-needed)
9. [Database Schema Requirements](#database-schema-requirements)
10. [Real-time Features](#real-time-features)
11. [Authentication & Authorization](#authentication--authorization)
12. [File Storage Requirements](#file-storage-requirements)

---

## 🏗️ Frontend Architecture Overview

### Technology Stack

- **Framework:** Flutter 3.x with Dart SDK 3.8.1+
- **UI Library:** Material Design 3
- **State Management:** Provider 6.1.2
- **Responsive Design:** Sizer 2.0.15
- **Charts:** FL Chart 0.69.2
- **Fonts:** Google Fonts (Poppins, Inter)
- **Media Handling:** Image Picker, Camera, Record
- **Network:** Connectivity Plus
- **Permissions:** Permission Handler

### Project Structure

```
lib/
├── core/                          # Core business logic
│   ├── models/                    # Data models
│   ├── services/                  # Business services
│   ├── utils/                     # Utility classes
│   └── app_export.dart            # Barrel exports
├── presentation/                  # UI Screens
│   ├── admin_screen/              # Admin interface
│   ├── forms/                     # Form screens
│   ├── login_screen/              # Authentication
│   ├── parent_dashboard/          # Parent interface
│   ├── profile_buddy_screen/      # Student profiles
│   ├── session_execution_screen/  # Real-time sessions
│   ├── session_planning_screen/   # Session planning
│   ├── settings_screen/           # App settings
│   ├── student_profile_management_screen/ # Profile management
│   ├── students_list_screen/      # Student listing
│   ├── therapist_dashboard/       # Therapist interface
│   └── therapist_profile_screen/  # Therapist profile
├── routes/                        # Navigation management
├── theme/                         # Design system
├── widgets/                       # Reusable components
├── firebase_options.dart          # Firebase config
└── main.dart                      # App entry point
```

---

## 📱 Screens & Page Structure

### 1. Authentication Flow

#### Login Screen (`lib/presentation/login_screen/`)

- **Purpose:** Multi-role authentication (Therapist, Parent, Admin)
- **Features:**
  - Role selection interface
  - Login and registration forms
  - Role-based routing after authentication
  - Form validation and error handling
- **Widgets:**
  - `app_logo_widget.dart` - Animated logo
  - `login_form_widget.dart` - Login form
  - `signup_form_widget.dart` - Registration form
  - `role_indicator_widget.dart` - Role selection
  - `register_link_widget.dart` - Account creation link

### 2. Therapist Interface

#### Therapist Dashboard (`lib/presentation/therapist_dashboard/`)

- **Purpose:** Central hub for therapists
- **Features:**
  - Today's sessions overview
  - Active students metrics
  - Session management
  - Quick actions menu
  - Progress visualization
- **Widgets:**
  - `connectivity_status_widget.dart` - Network status
  - `metric_card_widget.dart` - Key metrics display
  - `quick_action_sheet_widget.dart` - Action shortcuts
  - `session_overview_card_widget.dart` - Session summaries
  - `student_progress_card_widget.dart` - Student progress

#### Session Planning Screen (`lib/presentation/session_planning_screen/`)

- **Purpose:** Create and schedule therapy sessions
- **Features:**
  - Student selection
  - Activity library (60+ activities)
  - Session timeline management
  - Custom activity creation
  - Session scheduling
- **Widgets:**
  - `activity_card_widget.dart` - Activity display
  - `activity_category_widget.dart` - Category filters
  - `custom_activity_bottom_sheet.dart` - Custom activities
  - `session_header_widget.dart` - Session info
  - `session_timeline_widget.dart` - Timeline view

#### Students List Screen (`lib/presentation/students_list_screen/`)

- **Purpose:** View and manage all assigned students
- **Features:**
  - Student roster
  - Quick student actions
  - Student profile access
  - Add new student functionality

#### Therapist Profile Screen (`lib/presentation/therapist_profile_screen/`)

- **Purpose:** Therapist account management
- **Features:**
  - Profile information
  - Statistics dashboard
  - Settings and preferences
  - About app information

### 3. Parent Interface

#### Parent Dashboard (`lib/presentation/parent_dashboard/`)

- **Purpose:** Parent portal for child's therapy progress
- **Features:**
  - Child's activity tracking
  - Progress visualization
  - Communication with therapist
  - Homework completion
  - Profile management with logout
- **Widgets:**
  - `child_header_widget.dart` - Child information
  - `completed_activities_widget.dart` - Completed tasks
  - `not_completed_activities_widget.dart` - Pending tasks
  - `parent_empty_state_widget.dart` - No children state
  - `progress_chart_widget.dart` - Progress visualization
  - `homework_card_widget.dart` - Activity cards
  - `empty_state_widget.dart` - Generic empty state

### 4. Session Management

#### Session Execution Screen (`lib/presentation/session_execution_screen/`)

- **Purpose:** Real-time session data collection
- **Features:**
  - Live session tracking
  - Activity progression
  - Photo/audio capture
  - Behavioral observations
  - Data collection tools
- **Widgets:**
  - `activity_card_widget.dart` - Current activity
  - `activity_progress_indicator_widget.dart` - Progress tracking
  - `data_collection_widget.dart` - Data entry tools
  - `session_controls_overlay_widget.dart` - Session controls
  - `session_navigation_widget.dart` - Activity navigation
  - `session_timer_widget.dart` - Session timing

### 5. Profile Management

#### Student Profile Management (`lib/presentation/student_profile_management_screen/`)

- **Purpose:** Comprehensive student profile editing
- **Features:**
  - Personal information management
  - Photo upload
  - Clinical information
  - Goal setting
  - Progress tracking
- **Widgets:**
  - `basic_info_section_widget.dart` - Personal details
  - `student_photo_widget.dart` - Profile picture management

#### Profile Buddy Screen (`lib/presentation/profile_buddy_screen/`)

- **Purpose:** Student profile viewer for therapists
- **Features:**
  - Read-only profile view
  - Quick access to student information
  - Session history
  - Goal progress

### 6. Administrative Interface

#### Admin Screen (`lib/presentation/admin_screen/`)

- **Purpose:** System administration
- **Features:**
  - User management
  - System configuration
  - Data management tools
  - Analytics and reporting

#### Add Student Form (`lib/presentation/forms/`)

- **Purpose:** Student registration
- **Features:**
  - Student information capture
  - Parent linking
  - Initial assessment setup

#### Settings Screen (`lib/presentation/settings_screen/`)

- **Purpose:** App configuration
- **Features:**
  - Theme preferences
  - Notification settings
  - Account management
  - Help and support

---

## 🧩 Widget Component Library

### Core Reusable Widgets

#### 1. Custom Icon Widget (`lib/widgets/custom_icon_widget.dart`)

- **Purpose:** Centralized icon management
- **Features:**
  - 2000+ Material Icons mapped by string names
  - Consistent sizing and theming
  - Type-safe icon rendering
  - Support for custom colors and sizes

#### 2. Navigation Components (`lib/widgets/navigation/`)

- **TherapistBottomNavigation:**
  - 4-tab navigation (Dashboard, Sessions, Students, Profile)
  - Animated transitions
  - Blur effect background
  - Responsive design

#### 3. Theme Components

- **ThemeToggleWidget:** Dark/light mode switching
- **Theme Helper Utilities:** Consistent theme access

#### 4. Empty State Components

- **EmptyStateWidget:** Generic empty state
- **ParentEmptyStateWidget:** Parent-specific empty state

### Screen-Specific Widget Collections

#### Therapist Dashboard Widgets (5 widgets)

1. **ConnectivityStatusWidget** - Network status indicator
2. **MetricCardWidget** - Key performance metrics
3. **QuickActionSheetWidget** - Action shortcuts
4. **SessionOverviewCardWidget** - Session summaries
5. **StudentProgressCardWidget** - Student progress display

#### Parent Dashboard Widgets (6 widgets)

1. **ChildHeaderWidget** - Child information display
2. **CompletedActivitiesWidget** - Completed task list
3. **NotCompletedActivitiesWidget** - Pending task list
4. **ParentEmptyStateWidget** - No children linked state
5. **ProgressChartWidget** - Visual progress tracking
6. **HomeworkCardWidget** - Activity card display

#### Session Planning Widgets (5 widgets)

1. **ActivityCardWidget** - Activity display cards
2. **ActivityCategoryWidget** - Category filters
3. **CustomActivityBottomSheet** - Custom activity creation
4. **SessionHeaderWidget** - Session information
5. **SessionTimelineWidget** - Timeline visualization

#### Session Execution Widgets (6 widgets)

1. **ActivityCardWidget** - Current activity display
2. **ActivityProgressIndicatorWidget** - Progress tracking
3. **DataCollectionWidget** - Real-time data entry
4. **SessionControlsOverlayWidget** - Session controls
5. **SessionNavigationWidget** - Activity navigation
6. **SessionTimerWidget** - Session timing

#### Login Screen Widgets (5 widgets)

1. **AppLogoWidget** - Animated application logo
2. **LoginFormWidget** - Authentication form
3. **SignupFormWidget** - Registration form
4. **RoleIndicatorWidget** - Role selection interface
5. **RegisterLinkWidget** - Account creation navigation

#### Profile Management Widgets (2 widgets)

1. **BasicInfoSectionWidget** - Personal information form
2. **StudentPhotoWidget** - Profile picture management

---

## 🧭 Navigation & Routing

### Route Configuration (`lib/routes/app_routes.dart`)

#### Route Constants

```dart
- '/' → LoginScreen (initial)
- '/login-screen' → LoginScreen
- '/therapist-dashboard' → TherapistDashboard
- '/parent-dashboard' → ParentDashboard
- '/session-planning-screen' → SessionPlanningScreen
- '/session-execution-screen' → SessionExecutionScreen
- '/students-list' → StudentsListScreen
- '/student-profile-management-screen' → StudentProfileManagementScreen
- '/profile-buddy' → ProfileBuddyScreen
- '/therapist-profile' → TherapistProfileScreen
- '/add-student-form' → AddStudentForm
- '/settings' → SettingsScreen
- '/admin' → AdminScreen
```

#### Navigation Flow

1. **App Launch** → AuthWrapper checks authentication
2. **Authenticated** → Role-based routing (Therapist/Parent dashboard)
3. **Not Authenticated** → Login screen
4. **Role-Based Navigation:**
   - **Therapist:** Dashboard → Sessions → Students → Profile
   - **Parent:** Activities → Messages → Profile
   - **Admin:** Administrative interface

---

## 🔄 State Management

### Provider Architecture

- **DataService:** Singleton ChangeNotifier for app-wide state
- **ThemeManager:** Theme switching and persistence
- **AuthService:** Authentication state management

### Data Flow Pattern

```
UI Widget → DataService → FirestoreService → Firebase Backend
    ↑                                              ↓
    ← State Update (notifyListeners) ← Stream Response
```

---

## 🎨 Theme & Styling System

### Design System (`lib/theme/app_theme.dart`)

- **Design Philosophy:** Contemporary Healthcare Minimalism
- **Color Palette:** Therapeutic Trust Palette
  - Primary: Deep Purple (#7E57C2) - Professional competence
  - Secondary: Warm Orange (#FFA726) - Progress indicators
  - Success: Green (#4CAF50) - Completed tasks
  - Error: Red (#F44336) - Validation errors

### Typography

- **Font Family:** Google Fonts (Poppins, Inter)
- **Text Hierarchy:** 6 levels (Display, Headline, Title, Body, Label)
- **Accessibility:** WCAG 2.1 AA compliance

### Component Theming

- **Cards:** 12px radius, soft shadows
- **Buttons:** Rounded corners, elevation
- **Navigation:** Glassmorphism effects
- **Form Elements:** Outlined style, validation states

---

## 🔧 Backend Requirements

### 1. Authentication Service

**Requirements:**

- Multi-role user authentication (Therapist, Parent, Student, Admin)
- Email/password authentication
- Role-based access control (RBAC)
- Session management
- Password reset functionality
- User profile creation and management

**Endpoints Needed:**

```
POST /auth/login
POST /auth/register
POST /auth/logout
POST /auth/refresh-token
POST /auth/forgot-password
POST /auth/reset-password
GET  /auth/profile
PUT  /auth/profile
```

### 2. User Management Service

**Requirements:**

- User profile CRUD operations
- Role assignment and management
- User activation/deactivation
- Profile picture upload/management

**Endpoints Needed:**

```
GET    /users
GET    /users/{userId}
POST   /users
PUT    /users/{userId}
DELETE /users/{userId}
POST   /users/{userId}/avatar
DELETE /users/{userId}/avatar
```

### 3. Student Management Service

**Requirements:**

- Student profile management
- Parent-student linking
- Therapist assignment
- Clinical information tracking
- Progress monitoring

**Endpoints Needed:**

```
GET    /students
GET    /students/{studentId}
POST   /students
PUT    /students/{studentId}
DELETE /students/{studentId}
POST   /students/{studentId}/link-parent
DELETE /students/{studentId}/unlink-parent/{parentId}
GET    /students/by-therapist/{therapistId}
GET    /students/by-parent/{parentId}
```

### 4. Session Management Service

**Requirements:**

- Session scheduling and planning
- Real-time session execution
- Session data collection
- Activity library management
- Progress tracking

**Endpoints Needed:**

```
GET    /sessions
GET    /sessions/{sessionId}
POST   /sessions
PUT    /sessions/{sessionId}
DELETE /sessions/{sessionId}
POST   /sessions/{sessionId}/start
POST   /sessions/{sessionId}/end
POST   /sessions/{sessionId}/pause
POST   /sessions/{sessionId}/resume
POST   /sessions/{sessionId}/data
GET    /sessions/by-student/{studentId}
GET    /sessions/by-therapist/{therapistId}
```

### 5. Activity Library Service

**Requirements:**

- Pre-built activity catalog (60+ activities)
- Custom activity creation
- Activity categorization
- Difficulty levels
- Duration tracking

**Endpoints Needed:**

```
GET    /activities
GET    /activities/{activityId}
POST   /activities
PUT    /activities/{activityId}
DELETE /activities/{activityId}
GET    /activities/by-category/{category}
GET    /activities/search?q={query}
```

### 6. Progress Tracking Service

**Requirements:**

- Goal setting and tracking
- Progress metrics collection
- Achievement recording
- Report generation
- Analytics and insights

**Endpoints Needed:**

```
GET    /goals
GET    /goals/{goalId}
POST   /goals
PUT    /goals/{goalId}
DELETE /goals/{goalId}
GET    /progress/student/{studentId}
POST   /progress
GET    /reports/student/{studentId}
GET    /analytics/therapist/{therapistId}
```

### 7. Communication Service

**Requirements:**

- Secure messaging between therapist and parent
- Notification system
- Session summaries and updates
- Achievement alerts

**Endpoints Needed:**

```
GET    /messages
POST   /messages
PUT    /messages/{messageId}/read
GET    /notifications
POST   /notifications
PUT    /notifications/{notificationId}/read
```

### 8. File Storage Service

**Requirements:**

- Profile picture storage
- Session media (photos, audio)
- Document uploads
- Secure file access

**Endpoints Needed:**

```
POST   /files/upload
GET    /files/{fileId}
DELETE /files/{fileId}
POST   /files/session/{sessionId}
GET    /files/session/{sessionId}
```

---

## 📊 Database Schema Requirements

### User Tables

```sql
-- Users (therapists, parents, admins)
users (
  id UUID PRIMARY KEY,
  email VARCHAR UNIQUE NOT NULL,
  password_hash VARCHAR NOT NULL,
  role VARCHAR NOT NULL CHECK (role IN ('therapist', 'parent', 'admin')),
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  avatar_url VARCHAR,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
)

-- Students
students (
  id UUID PRIMARY KEY,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  date_of_birth DATE NOT NULL,
  gender VARCHAR,
  diagnosis VARCHAR,
  communication_level TEXT,
  sensory_needs TEXT,
  triggers TEXT[],
  severity VARCHAR,
  therapist_id UUID REFERENCES users(id),
  avatar_url VARCHAR,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
)

-- Parent-Student relationships
parent_student_links (
  parent_id UUID REFERENCES users(id),
  student_id UUID REFERENCES students(id),
  relationship VARCHAR,
  PRIMARY KEY (parent_id, student_id)
)
```

### Session Tables

```sql
-- Sessions
sessions (
  id UUID PRIMARY KEY,
  student_id UUID REFERENCES students(id),
  therapist_id UUID REFERENCES users(id),
  title VARCHAR NOT NULL,
  description TEXT,
  scheduled_date TIMESTAMP NOT NULL,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  estimated_duration INTEGER, -- minutes
  actual_duration INTEGER, -- minutes
  status VARCHAR DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
  summary TEXT,
  achievements TEXT[],
  homework_assigned TEXT,
  next_session_focus TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
)

-- Session Activities
session_activities (
  id UUID PRIMARY KEY,
  session_id UUID REFERENCES sessions(id),
  activity_id UUID REFERENCES activities(id),
  order_index INTEGER,
  status VARCHAR DEFAULT 'not_started',
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  notes TEXT,
  completion_percentage DECIMAL(5,2)
)

-- Real-time session data
session_data (
  id UUID PRIMARY KEY,
  session_id UUID REFERENCES sessions(id),
  activity_id UUID,
  timestamp TIMESTAMP DEFAULT NOW(),
  data_type VARCHAR NOT NULL,
  data_value JSONB,
  notes TEXT,
  recorded_by UUID REFERENCES users(id)
)
```

### Progress Tables

```sql
-- Goals
goals (
  id UUID PRIMARY KEY,
  student_id UUID REFERENCES students(id),
  therapist_id UUID REFERENCES users(id),
  title VARCHAR NOT NULL,
  description TEXT,
  category VARCHAR,
  priority VARCHAR,
  target_date DATE,
  progress_percentage DECIMAL(5,2) DEFAULT 0,
  strategies TEXT[],
  measurement_criteria JSONB,
  status VARCHAR DEFAULT 'active',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
)

-- Progress entries
progress_entries (
  id UUID PRIMARY KEY,
  student_id UUID REFERENCES students(id),
  goal_id UUID REFERENCES goals(id),
  session_id UUID REFERENCES sessions(id),
  entry_date DATE NOT NULL,
  progress_type VARCHAR,
  metrics JSONB,
  notes TEXT,
  created_by UUID REFERENCES users(id)
)
```

### Activity Tables

```sql
-- Activity library
activities (
  id UUID PRIMARY KEY,
  name VARCHAR NOT NULL,
  description TEXT,
  category VARCHAR,
  difficulty_level VARCHAR,
  estimated_duration INTEGER, -- minutes
  instructions TEXT,
  materials TEXT[],
  icon_name VARCHAR,
  is_custom BOOLEAN DEFAULT false,
  created_by UUID REFERENCES users(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
)
```

### Communication Tables

```sql
-- Messages
messages (
  id UUID PRIMARY KEY,
  sender_id UUID REFERENCES users(id),
  recipient_id UUID REFERENCES users(id),
  student_id UUID REFERENCES students(id),
  subject VARCHAR,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  sent_at TIMESTAMP DEFAULT NOW()
)

-- Notifications
notifications (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  type VARCHAR NOT NULL,
  title VARCHAR NOT NULL,
  content TEXT,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
)
```

### File Storage Tables

```sql
-- Files
files (
  id UUID PRIMARY KEY,
  filename VARCHAR NOT NULL,
  original_filename VARCHAR,
  file_size BIGINT,
  mime_type VARCHAR,
  file_path VARCHAR NOT NULL,
  uploaded_by UUID REFERENCES users(id),
  session_id UUID REFERENCES sessions(id),
  student_id UUID REFERENCES students(id),
  created_at TIMESTAMP DEFAULT NOW()
)
```

---

## ⚡ Real-time Features

### WebSocket Requirements

1. **Session Execution Updates**

   - Real-time session progress
   - Activity transitions
   - Data collection events

2. **Notifications**

   - Achievement alerts
   - Session reminders
   - Message notifications

3. **Progress Updates**
   - Goal completion
   - Milestone achievements
   - Report generation status

### Implementation Needs

- WebSocket connection management
- Event-driven architecture
- Message queuing system
- Offline synchronization

---

## 🔐 Authentication & Authorization

### Security Requirements

1. **JWT Token-based Authentication**

   - Access tokens (short-lived)
   - Refresh tokens (long-lived)
   - Token refresh mechanism

2. **Role-Based Access Control (RBAC)**

   - Therapist: Full access to assigned students
   - Parent: Access to linked children only
   - Student: Limited access to own data
   - Admin: System-wide access

3. **Data Privacy Compliance**
   - HIPAA compliance for health data
   - COPPA compliance for child data
   - GDPR compliance for EU users

### Permission Matrix

```
Resource         | Therapist | Parent | Student | Admin
-----------------|-----------|--------|---------|-------
Own Profile      | RWD       | RWD    | R       | RWD
Student Profiles | RW*       | R*     | R**     | RWD
Sessions         | RWD*      | R*     | R**     | RWD
Goals            | RWD*      | R*     | R**     | RWD
Activities       | RW        | R      | R       | RWD
Messages         | RWD***    | RWD*** | -       | RWD
Files            | RWD*      | R*     | R**     | RWD

* Only for assigned/linked students
** Own data only
*** Between therapist and parent only
R=Read, W=Write, D=Delete
```

---

## 📁 File Storage Requirements

### Storage Categories

1. **User Avatars**

   - Profile pictures for users and students
   - Image optimization and resizing
   - Multiple format support

2. **Session Media**

   - Photos captured during sessions
   - Audio recordings
   - Video files (future)

3. **Documents**
   - Assessment reports
   - Progress documents
   - Care plans

### Technical Requirements

- **CDN Integration** for fast global access
- **Image Processing** for optimization
- **Access Control** with signed URLs
- **Backup and Redundancy**
- **Compliance** with health data regulations

### File Management Features

- Upload progress tracking
- File type validation
- Size limitations
- Automatic cleanup of orphaned files
- Secure file sharing with expiring links

---

## 🚀 Deployment Considerations

### Backend Infrastructure

- **Containerized Deployment** (Docker/Kubernetes)
- **Microservices Architecture** for scalability
- **Database Clustering** for high availability
- **Load Balancing** for traffic distribution
- **Monitoring and Logging** for observability

### Performance Requirements

- **Response Time:** < 200ms for API calls
- **Real-time Updates:** < 100ms latency
- **File Upload:** Support for 10MB+ files
- **Concurrent Users:** 1000+ simultaneous users
- **Database Performance:** Optimized queries with indexing

### Security Infrastructure

- **SSL/TLS Encryption** for all connections
- **VPN Access** for administrative functions
- **Regular Security Audits**
- **Penetration Testing**
- **Compliance Monitoring**

---

This comprehensive documentation provides the complete overview of the ThrivEers frontend architecture and detailed backend requirements needed to support the application's functionality. The frontend is designed with a modular, component-based architecture that requires a robust, scalable backend to handle real-time therapy session management, secure communication, and comprehensive progress tracking.
