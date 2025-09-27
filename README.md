# 🌟 ThrivePath - Collaborative ASD Therapy Management Platform

**Empowering Autism Therapy Through Technology and Collaboration**

ThrivePath is a comprehensive Flutter-based platform designed to revolutionize Autism Spectrum Disorder (ASD) therapy management by creating a unified digital ecosystem that connects therapists, parents, and students in meaningful collaboration.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.8.1+-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-orange.svg)](https://firebase.google.com/)
[![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-green.svg)](#)
[![License](https://img.shields.io/badge/License-Private-red.svg)](#)

---

## � Table of Contents

- [🎯 Project Overview](#-project-overview)
- [✨ Key Features](#-key-features)
- [🏗️ Architecture](#️-architecture)
- [👥 User Roles & Features](#-user-roles--features)
- [📊 Data Models](#-data-models)
- [🚀 Getting Started](#-getting-started)
- [🔧 Configuration](#-configuration)
- [📱 Platform Support](#-platform-support)
- [🧪 Testing](#-testing)
- [📦 Building & Deployment](#-building--deployment)
- [📚 Documentation](#-documentation)
- [🤝 Contributing](#-contributing)

---

## 🎯 Project Overview

### Mission Statement

To bridge the gap between clinical therapy sessions and daily life by providing a collaborative platform that empowers therapists, engages parents, and motivates students in their autism therapy journey.

### Core Values

- **Collaboration**: Connecting all stakeholders in the therapy process
- **Evidence-Based**: Data-driven therapy decisions and progress tracking
- **Accessibility**: User-friendly interfaces for all ability levels
- **Privacy**: Secure handling of sensitive therapeutic data
- **Empowerment**: Tools that enable success for all users

---

## ✨ Key Features

### 🔄 Multi-Role System

- **Therapist Portal**: Professional-grade therapy management tools
- **Parent Dashboard**: Family engagement and progress monitoring
- **Student Interface**: Interactive, gamified learning experience
- **Admin Panel**: System administration and user management

### 📈 Advanced Analytics

- **Progress Visualization**: Comprehensive charts and graphs
- **Goal Tracking**: SMART therapeutic goals with milestone monitoring
- **Behavioral Assessment**: Standardized ASD assessment tools
- **Custom Reports**: Detailed progress reports for all stakeholders

### 🌐 Real-time Collaboration

- **Live Session Updates**: Real-time progress sharing during sessions
- **Instant Notifications**: Immediate updates on student achievements
- **Cross-Platform Sync**: Seamless data synchronization across devices
- **Communication Hub**: Direct messaging between therapists and parents

### 🎮 Student Engagement

- **Gamified Interface**: Achievement-based progress display
- **Interactive Activities**: Engaging therapeutic exercises
- **Visual Progress**: Child-friendly progress indicators
- **Reward System**: Motivation through visual achievements

---

## 🏗️ Architecture

### Technical Stack

```
Frontend:    Flutter 3.8.1+ (Dart 3.8.1+)
Backend:     Firebase Suite
Database:    Cloud Firestore
Auth:        Firebase Authentication
Storage:     Firebase Cloud Storage
State Mgmt:  Provider Pattern
UI Design:   Material Design 3
Charts:      FL Chart
Responsive:  Sizer Package
```

### Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── models/                   # Data models
│   │   ├── student_model.dart    # Student profile model
│   │   ├── session_model.dart    # Therapy session model
│   │   ├── goal_model.dart       # Therapeutic goals model
│   │   └── progress_model.dart   # Progress tracking model
│   ├── services/                 # Business logic services
│   │   ├── auth_service.dart     # Authentication service
│   │   ├── firestore_service.dart# Database operations
│   │   ├── data_service.dart     # Centralized data management
│   │   └── test_data_service.dart# Development data utilities
│   └── utils/                    # Utility classes
├── presentation/                  # UI layers
│   ├── therapist_dashboard/      # Therapist interface
│   ├── parent_dashboard/         # Parent interface
│   ├── student_dashboard/        # Student interface
│   ├── session_planning_screen/  # Session planning tools
│   ├── session_execution_screen/ # Real-time session tracking
│   ├── student_profile_management_screen/ # Profile management
│   ├── login_screen/            # Authentication screens
│   └── admin_screen/            # Administrative interface
├── routes/                       # Navigation management
├── theme/                        # App theming and styling
└── widgets/                      # Reusable UI components
└── main.dart               # App entry point
```

### Core Technologies

- **Flutter 3.8.1+**: Cross-platform UI framework
- **Firebase**: Backend services (Auth, Firestore, Storage, Database)
- **Provider**: State management solution
- **Material Design 3**: Modern UI components and theming

### Key Dependencies

- `firebase_core` & Firebase services - Backend infrastructure
- `provider` - State management
- `sizer` - Responsive design
- `fl_chart` - Data visualization
- `google_fonts` - Typography
- `image_picker` & `camera` - Media handling

## 🛠️ Development Setup

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.0.0 or higher
- Firebase project configured
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd thriveers
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**

   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication, Firestore, and Storage
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
   - Update `firebase_options.dart` with your project configuration

4. **Run the app**

   ```bash
   # For mobile development
   flutter run

   # For web development
   flutter run -d chrome
   ```

## 📱 Supported Platforms

- ✅ **Android** (Mobile & Tablet)
- ✅ **iOS** (iPhone & iPad)
- ✅ **Web** (Progressive Web App)
- ❌ Desktop (Linux, macOS, Windows) - _Removed for mobile/web focus_

## 🔧 Configuration

### Environment Variables

Configure the following in your Firebase project:

- Firestore database rules
- Authentication providers (Email/Password)
- Storage bucket permissions

### App Configuration

- **Theme**: Supports light/dark mode with Material Design 3
- **Responsive**: Automatically adapts to different screen sizes
- **Offline**: Basic offline support with Firestore caching

## 📊 Data Models

### Core Models

- **StudentModel**: Student profiles and information
- **SessionModel**: Therapy session details and activities
- **GoalModel**: Therapeutic goals and progress tracking
- **ProgressModel**: Progress entries and metrics
- **ActivityModel**: Therapy activities and exercises

### Services

- **AuthService**: User authentication and authorization
- **FirestoreService**: Database operations and data management
- **DataService**: Centralized data management with caching
- **TestDataService**: Development and testing data utilities

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Analyze code quality
flutter analyze
```

## 📦 Building

### Mobile Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

### Web Build

```bash
# Web build
flutter build web --release
```

## 🔒 Security & Privacy

- **Data Encryption**: All data is encrypted in transit and at rest
- **Authentication**: Secure Firebase Authentication
- **Privacy**: COPPA and FERPA compliant data handling
- **Access Control**: Role-based permissions for different user types

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards

- Follow Dart/Flutter style guidelines
- Use meaningful variable and function names
- Add documentation for public APIs
- Write tests for new features
- Ensure responsive design for all screen sizes

## 📝 License

This project is proprietary software. All rights reserved.

## 📞 Support

For technical support or questions:

- Create an issue in this repository
- Contact the development team
- Review the documentation in `/docs`

## 🚀 Roadmap

### Current Version (v1.0.0)

- ✅ Core therapy management features
- ✅ Multi-role user system
- ✅ Firebase integration
- ✅ Mobile and web support

### Future Enhancements

- 🔄 Real-time collaboration features
- 🔄 Advanced analytics and reporting
- 🔄 AI-powered therapy recommendations
- 🔄 Multi-language support
- 🔄 Video calling integration

---

**Built with ❤️ for the autism therapy community**
