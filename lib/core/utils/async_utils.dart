import 'package:flutter/material.dart';

/// Utility mixin for handling async operations with proper mounted checks
/// This helps prevent memory leaks and ensures UI updates only happen when appropriate
mixin AsyncStateMixin<T extends StatefulWidget> on State<T> {
  
  /// Execute an async operation safely with automatic mounted checks
  /// 
  /// Usage:
  /// ```dart
  /// await safeAsyncOperation(() async {
  ///   final data = await someAsyncOperation();
  ///   setState(() {
  ///     _data = data;
  ///   });
  /// });
  /// ```
  Future<void> safeAsyncOperation(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (e) {
      if (mounted) {
        // Handle error only if widget is still mounted
        _handleAsyncError(e);
      }
    }
  }
  
  /// Execute setState only if the widget is still mounted
  /// 
  /// Usage:
  /// ```dart
  /// safeSetState(() {
  ///   _loading = false;
  /// });
  /// ```
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
  
  /// Show a snackbar only if the widget is still mounted
  /// 
  /// Usage:
  /// ```dart
  /// safeShowSnackBar('Operation completed successfully');
  /// ```
  void safeShowSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
  
  /// Navigate only if the widget is still mounted
  /// 
  /// Usage:
  /// ```dart
  /// safeNavigate(() => Navigator.of(context).push(...));
  /// ```
  void safeNavigate(VoidCallback navigation) {
    if (mounted) {
      navigation();
    }
  }
  
  /// Override this method to handle async errors in your widget
  void _handleAsyncError(Object error) {
    // Default implementation - can be overridden
    debugPrint('Async operation error: $error');
  }
}

/// Utility class for common async patterns
class AsyncUtils {
  
  /// Execute an async operation with a timeout
  static Future<T?> withTimeout<T>(
    Future<T> future,
    Duration timeout, {
    T? fallbackValue,
  }) async {
    try {
      return await future.timeout(timeout);
    } catch (e) {
      return fallbackValue;
    }
  }
  
  /// Execute multiple async operations in parallel with error handling
  static Future<List<T?>> executeInParallel<T>(
    List<Future<T> Function()> operations, {
    bool continueOnError = true,
  }) async {
    final futures = operations.map((op) async {
      try {
        return await op();
      } catch (e) {
        if (!continueOnError) rethrow;
        return null;
      }
    });
    
    return await Future.wait(futures);
  }
  
  /// Retry an async operation with exponential backoff
  static Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
    double backoffFactor = 2.0,
  }) async {
    var delay = initialDelay;
    var lastError;
    
    for (int i = 0; i <= maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        lastError = e;
        if (i == maxRetries) break;
        
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffFactor).round());
      }
    }
    
    throw lastError;
  }
}
