# Contributing to ThrivePath

Thank you for your interest in contributing to ThrivePath! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Development Environment Setup

1. **Install Flutter**
   - Download Flutter SDK from [flutter.dev](https://flutter.dev)
   - Add Flutter to your PATH
   - Run `flutter doctor` to verify installation

2. **IDE Setup**
   - **VS Code**: Install Flutter and Dart extensions
   - **Android Studio**: Install Flutter and Dart plugins

3. **Clone and Setup**
   ```bash
   git clone https://github.com/saran2006psg/autism_therapy.git
   cd thriveers
   flutter pub get
   ```

## 📋 Code Style Guidelines

### Dart/Flutter Conventions
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Format code using `flutter format`

### Project Structure
```
lib/
├── core/                 # Shared utilities and services
├── presentation/         # UI screens and widgets
│   ├── screen_name/
│   │   ├── screen_name.dart
│   │   └── widgets/      # Screen-specific widgets
├── routes/              # Navigation logic
├── theme/               # App theming
└── widgets/             # Reusable components
```

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Widgets**: End with `Widget` (e.g., `MetricCardWidget`)

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
- Test widget rendering and interactions
- Use `testWidgets()` for widget tests
- Mock external dependencies

### Integration Tests
```bash
flutter test integration_test/
```

## 📝 Commit Guidelines

### Commit Message Format
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```
feat(auth): add biometric authentication
fix(dashboard): resolve overflow in metric cards
docs(readme): update installation instructions
```

## 🔀 Pull Request Process

1. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Follow coding standards
   - Add tests for new functionality
   - Update documentation if needed

3. **Test Your Changes**
   ```bash
   flutter test
   flutter analyze
   flutter format lib/
   ```

4. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat(feature): add new functionality"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

### PR Requirements
- [ ] All tests pass
- [ ] Code is properly formatted
- [ ] Documentation is updated
- [ ] Screenshots for UI changes
- [ ] Responsive design verified

## 🐛 Bug Reports

When reporting bugs, please include:

- **Device Information**: OS, version, screen size
- **Flutter Version**: Output of `flutter --version`
- **Steps to Reproduce**: Clear, numbered steps
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Screenshots**: If applicable
- **Error Logs**: Console output or stack traces

## 💡 Feature Requests

For feature requests, please include:

- **Problem Statement**: What problem does this solve?
- **Proposed Solution**: How should it work?
- **User Stories**: Who benefits and how?
- **Mockups/Wireframes**: Visual representation if applicable
- **Implementation Notes**: Technical considerations

## 🎨 UI/UX Guidelines

### Design System
- Follow Material Design 3 principles
- Use app's color scheme and typography
- Ensure accessibility compliance
- Support both light and dark themes

### Responsive Design
- Test on multiple screen sizes
- Use `Sizer` package for responsive dimensions
- Ensure proper layout on tablets and phones
- Handle orientation changes gracefully

### Accessibility
- Add semantic labels for screen readers
- Ensure sufficient color contrast
- Support keyboard navigation
- Test with accessibility tools

## 🔧 Development Tips

### Performance
- Use `const` constructors where possible
- Avoid rebuilding widgets unnecessarily
- Use lazy loading for large lists
- Optimize images and assets

### State Management
- Use StatefulWidget for local state
- Consider Provider/Bloc for complex state
- Keep state as close to where it's used as possible

### Error Handling
- Use try-catch blocks for async operations
- Provide meaningful error messages
- Log errors for debugging
- Show user-friendly error dialogs

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://material.io/design)
- [Firebase Documentation](https://firebase.google.com/docs)

## ❓ Questions?

If you have questions about contributing:

- Check existing issues and discussions
- Email: saran2006psg@gmail.com
- Create a new issue with the `question` label

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- Special thanks in documentation

Thank you for helping make ThrivePath better! 🎉
