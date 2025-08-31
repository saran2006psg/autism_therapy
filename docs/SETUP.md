# ThrivePath Development Setup Guide

## Prerequisites

### System Requirements
- **Operating System**: Windows 10+, macOS 10.14+, or Linux
- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: 10GB+ free space
- **Internet**: Stable connection for package downloads

### Required Software

1. **Flutter SDK**
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Version 3.0.0 or higher
   - Add to system PATH

2. **Dart SDK**
   - Included with Flutter
   - Verify with `dart --version`

3. **IDE Options**
   - **VS Code** (Recommended)
     - Flutter extension
     - Dart extension
   - **Android Studio**
     - Flutter plugin
     - Dart plugin

4. **Mobile Development**
   - **Android**: Android Studio + Android SDK
   - **iOS**: Xcode (macOS only)

## Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: "thrivepath-app"
4. Enable Google Analytics (optional)

### 2. Configure Authentication
1. Navigate to Authentication > Sign-in method
2. Enable Email/Password authentication
3. Add authorized domains if needed

### 3. Setup Firestore Database
1. Go to Firestore Database
2. Create database in production mode
3. Set up security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Students collection
    match /students/{studentId} {
      allow read, write: if request.auth != null;
    }
    
    // Sessions collection
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Add Firebase to Flutter

#### Android Configuration
1. Download `google-services.json`
2. Place in `android/app/`
3. Update `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

4. Update `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.firebase:firebase-analytics'
}
```

#### iOS Configuration
1. Download `GoogleService-Info.plist`
2. Add to `ios/Runner/` in Xcode
3. Update `ios/Runner/Info.plist` if needed

## Development Environment

### 1. Clone Repository
```bash
git clone https://github.com/saran2006psg/autism_therapy.git
cd thriveers
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Verify Setup
```bash
flutter doctor
```
Ensure all checks pass or have clear instructions for fixes.

### 4. Configure IDE

#### VS Code
1. Install extensions:
   - Flutter
   - Dart
   - Bracket Pair Colorizer
   - GitLens

2. Create `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter",
            "type": "dart",
            "request": "launch",
            "program": "lib/main.dart"
        }
    ]
}
```

#### Android Studio
1. Install plugins: Flutter, Dart
2. Import project
3. Trust Gradle wrapper
4. Sync project

## Running the Application

### Development Mode
```bash
# Run on connected device/emulator
flutter run

# Run with specific flavor
flutter run --flavor development

# Enable hot reload (automatic)
# Press 'r' to hot reload
# Press 'R' to hot restart
```

### Device Setup

#### Android Emulator
1. Open Android Studio
2. Tools > AVD Manager
3. Create new virtual device
4. Choose API level 21+ (Android 5.0+)
5. Start emulator

#### iOS Simulator (macOS only)
1. Install Xcode
2. Open Simulator app
3. Choose device (iPhone 12+)

#### Physical Device
1. Enable developer options
2. Enable USB debugging (Android)
3. Trust computer (iOS)
4. Run `flutter devices` to verify

## Debugging

### Flutter Inspector
- VS Code: View > Command Palette > "Flutter: Open Flutter Inspector"
- Android Studio: Flutter Inspector tab

### Debug Console
- View console output during development
- Add print statements for debugging
- Use debugger breakpoints

### Common Issues

#### 1. Gradle Build Errors
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 2. iOS Build Errors
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

#### 3. Firebase Connection Issues
- Verify `google-services.json` placement
- Check Firebase project configuration
- Ensure internet connectivity

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/
```

## Building for Production

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

## Code Quality

### Formatting
```bash
flutter format lib/
```

### Analysis
```bash
flutter analyze
```

### Linting
Configure `analysis_options.yaml` for consistent code style.

## Environment Variables

Create `.env` file for sensitive data:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

Note: Add `.env` to `.gitignore`

## Continuous Integration

### GitHub Actions
Example workflow file (`.github/workflows/flutter.yml`):

```yaml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    - run: flutter pub get
    - run: flutter analyze
    - run: flutter test
```

## Troubleshooting

### Common Commands
```bash
# Clean build files
flutter clean

# Upgrade Flutter
flutter upgrade

# Check for issues
flutter doctor -v

# Reset to stable channel
flutter channel stable
flutter upgrade
```

### Getting Help
1. Check Flutter documentation
2. Search GitHub issues
3. Ask on Stack Overflow with 'flutter' tag
4. Flutter Discord community

## Next Steps

1. Familiarize yourself with the codebase structure
2. Read the API documentation
3. Try making small changes
4. Run tests to ensure everything works
5. Start contributing!

Happy coding! 🚀
