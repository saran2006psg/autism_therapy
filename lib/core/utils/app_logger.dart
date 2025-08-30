import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Log levels for different types of messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Centralized logging utility for the Thriveers application
/// Provides consistent logging across the entire application
class AppLogger {
  static const String _defaultLoggerName = 'Thriveers';

  /// Log a debug message
  static void debug(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, name: name, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  static void info(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, name: name, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  static void warning(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, name: name, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  static void error(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, name: name, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final loggerName = name ?? _defaultLoggerName;
    
    // In debug mode, use developer log for better debugging experience
    if (kDebugMode) {
      dev.log(
        message,
        name: loggerName,
        level: _getLogLevel(level),
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      // In production, you might want to send logs to a crash reporting service
      // For now, we'll use developer log but you can replace this with your preferred service
      dev.log(
        message,
        name: loggerName,
        level: _getLogLevel(level),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Convert AppLogger LogLevel to developer log level
  static int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  /// Log authentication events
  static void auth(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, name: 'Auth', error: error, stackTrace: stackTrace);
  }

  /// Log database operations
  static void database(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, name: 'Database', error: error, stackTrace: stackTrace);
  }

  /// Log UI events
  static void ui(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, name: 'UI', error: error, stackTrace: stackTrace);
  }

  /// Log session execution events
  static void session(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, name: 'Session', error: error, stackTrace: stackTrace);
  }

  /// Log network events
  static void network(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, name: 'Network', error: error, stackTrace: stackTrace);
  }
}
