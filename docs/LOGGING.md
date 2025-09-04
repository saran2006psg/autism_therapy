# Logging Guide for ThrivePath Project

## Overview

This project uses the `logger` package for proper logging instead of `print()` statements. This provides better debugging capabilities, log levels, and formatted output.

## Setup

The logger dependency is already added to `pubspec.yaml`:

```yaml
dev_dependencies:
  logger: ^2.4.0
```

## Usage

### 1. For Utility Scripts (like fix_deprecated_apis.dart)

```dart
import 'package:logger/logger.dart';

// Create a logger instance for the script
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

void main() async {
  logger.i('Starting script...');
  logger.d('Debug information');
  logger.w('Warning message');
  logger.e('Error occurred');
}
```

### 2. For Main Flutter App (Recommended)

Use Flutter's built-in `debugPrint()` for debug messages:

```dart
import 'package:flutter/foundation.dart';

void someFunction() {
  debugPrint('Debug message - only shows in debug mode');
  
  // For production logging, use the AppLogger class
  if (kDebugMode) {
    debugPrint('This only prints in debug builds');
  }
}
```

### 3. For Advanced Logging in Flutter App

Use the custom `AppLogger` class from `lib/core/utils/logger_config.dart`:

```dart
import 'package:thriveers/core/utils/logger_config.dart';

class MyWidget extends StatelessWidget {
  void handleError() {
    try {
      // Some operation
    } catch (e, stackTrace) {
      AppLogger.e('Operation failed', e, stackTrace);
    }
  }
  
  void logInfo() {
    AppLogger.i('User action completed successfully');
    AppLogger.d('Debug information');
    AppLogger.w('Warning: Something might be wrong');
  }
}
```

## Log Levels

- `logger.t()` / `AppLogger.v()` - Trace/Verbose (very detailed)
- `logger.d()` / `AppLogger.d()` - Debug (development info)
- `logger.i()` / `AppLogger.i()` - Info (general information)
- `logger.w()` / `AppLogger.w()` - Warning (potential issues)
- `logger.e()` / `AppLogger.e()` - Error (actual errors)
- `logger.f()` / `AppLogger.wtf()` - Fatal (critical errors)

## Output Examples

With proper logging, you'll see formatted output like:

```
💡 [INFO] 14:32:15.123 (+0ms): Starting to fix deprecated APIs...
🐛 [DEBUG] 14:32:15.124 (+1ms): Processing: file.dart
💡 [INFO] 14:32:15.125 (+2ms): → Fixed 3 withOpacity occurrences
✅ [INFO] 14:32:15.126 (+3ms): Completed! Fixed 77 issues across 72 files
```

## Benefits

1. **Colored Output**: Easy to distinguish log levels
2. **Timestamps**: Track when events occurred
3. **Stack Traces**: Automatic for errors
4. **Production Control**: Logs can be disabled in release builds
5. **Structured**: Consistent formatting across the project
6. **Performance**: Better than print() statements

## Migration from print()

Replace all instances of:

```dart
// ❌ Old way
print('Debug message');
print('Error: $error');

// ✅ New way
logger.d('Debug message');
logger.e('Error: $error');

// Or for Flutter widgets
debugPrint('Debug message');
AppLogger.e('Error: $error');
```

## Configuration

You can customize the logger behavior by modifying the `PrettyPrinter` settings:

- `methodCount`: Number of method calls to show in stack trace
- `errorMethodCount`: Stack trace depth for errors
- `lineLength`: Maximum width of log lines
- `colors`: Enable/disable colored output
- `printEmojis`: Show emojis for different log levels
- `dateTimeFormat`: Timestamp format options
