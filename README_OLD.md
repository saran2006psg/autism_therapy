# ThrivePath - Autism Therapy Management App

A comprehensive Flutter application designed to streamline autism therapy management for therapists, parents, and students. ThrivePath provides tools for session planning, progress tracking, communication, and homework management.

## 🌟 Features

### For Therapists
- **Dashboard**: Overview of daily sessions, student progress, and metrics
- **Session Planning**: Create and customize therapy sessions with pre-built activities
- **Student Management**: Maintain detailed student profiles with goals and progress
- **Progress Tracking**: Visual charts and analytics for student development
- **Communication**: Secure messaging with parents and colleagues

### For Parents
- **Progress Monitoring**: Real-time updates on child's therapy progress
- **Homework Tracking**: View and complete assigned activities
- **Communication**: Direct messaging with therapy team
- **Session History**: Access to past session summaries and achievements
- **Calendar Integration**: Upcoming session reminders and scheduling

### For Students
- **Interactive Activities**: Engaging therapy exercises and games
- **Progress Visualization**: Achievement badges and progress indicators
- **Goal Tracking**: Visual representation of therapy goals and milestones

## 🏗️ Project Structure

```
lib/
├── core/                    # Core functionality and utilities
│   ├── app_export.dart     # Main exports and common imports
│   └── services/           # Data services and API integrations
├── presentation/           # UI screens and widgets
│   ├── login_screen/       # Authentication screens
│   ├── therapist_dashboard/ # Therapist main dashboard
│   ├── parent_dashboard/   # Parent main dashboard
│   ├── session_planning_screen/ # Session creation and planning
│   ├── session_execution_screen/ # Live session management
│   └── student_profile_management_screen/ # Student profile management
├── routes/                 # Navigation and routing
├── theme/                  # App theming and styles
├── widgets/                # Reusable UI components
├── firebase_options.dart   # Firebase configuration
└── main.dart              # Application entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Firebase account for backend services

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/saran2006psg/autism_therapy.git
   cd thriveers
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication, Firestore, and Storage
   - Download and place configuration files:
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)

4. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Demo Credentials

### Therapist Account
- **Email**: `dr.sarah.johnson@therapycenter.com`
- **Password**: `therapist123`

### Parent Account
- **Email**: `michael.parent@email.com`
- **Password**: `parent123`

## 🎨 Design System

The app follows Material Design 3 principles with a custom color scheme optimized for accessibility:

- **Primary Color**: Purple (#6B46C1) - Used for main actions and navigation
- **Secondary Color**: Orange (#F59E0B) - Used for accents and highlights
- **Surface Colors**: Light backgrounds with subtle gradients
- **Typography**: Inter font family with consistent sizing scale

## 🛠️ Technologies Used

- **Framework**: Flutter 3.x
- **State Management**: StatefulWidget with StreamBuilder
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Charts**: FL Chart for progress visualization
- **Responsive Design**: Sizer package for screen adaptation
- **Icons**: Material Icons with custom icon widget
- **Image Handling**: Cached Network Image

## 📊 Key Packages

```yaml
dependencies:
  flutter: sdk
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  sizer: ^2.0.15
  fl_chart: ^0.66.0
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4
  fluttertoast: ^8.2.4
```

## 🔧 Development Setup

### Code Organization
- Follow clean architecture principles
- Use consistent naming conventions
- Implement proper error handling
- Add comprehensive documentation

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Build for Production
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Coding Standards
- Use consistent formatting (flutter format)
- Follow Dart style guidelines
- Add meaningful comments and documentation
- Ensure responsive design across devices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Developer**: Saran
- **Project Type**: Academic/Educational
- **Institution**: ADL Final Project

## 🐛 Known Issues

- Minor UI overflow on very small screens (being addressed)
- Offline mode limitations (planned for future release)

## 🚧 Roadmap

- [ ] Offline data synchronization
- [ ] Multi-language support
- [ ] Advanced analytics dashboard
- [ ] Video call integration
- [ ] AI-powered activity recommendations
- [ ] Export functionality for reports

## 📞 Support

For support, email saran2006psg@gmail.com or create an issue in the GitHub repository.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design team for design guidelines
- Autism therapy professionals for domain expertise

---

**Built with ❤️ for the autism therapy community**
