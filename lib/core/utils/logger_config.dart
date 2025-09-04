import 'package:logger/logger.dart';

/// Global logger instance for the application
/// 
/// Usage:
/// ```dart
/// import 'package:thriveers/core/utils/app_logger.dart';
/// 
/// AppLogger.i('Info message');
/// AppLogger.d('Debug message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message');
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Include timestamp
    ),
  );

  /// Log an info message
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a debug message
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a verbose message
  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log a what a terrible failure message
  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
