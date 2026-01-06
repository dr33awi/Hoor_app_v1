// ═══════════════════════════════════════════════════════════════════════════
// App Logger Service - Centralized Logging with Beautiful Output
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Global logger instance for easy access throughout the app
final AppLogger appLogger = AppLogger();

/// Custom Logger Service with beautiful formatted output
class AppLogger {
  late final Logger _logger;

  AppLogger() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: kDebugMode ? Level.trace : Level.warning,
    );
  }

  /// 🔵 Trace - Detailed information, typically of interest only when diagnosing problems
  void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// 🐛 Debug - Debug information
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// ℹ️ Info - General information
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// ⚠️ Warning - Something unexpected, but not an error
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// ❌ Error - Something went wrong
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 💀 Fatal - Critical error, app might crash
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Convenience Methods for Common Scenarios
  // ═══════════════════════════════════════════════════════════════════════════

  /// Log Firebase operations
  void firebase(String operation, {String? collection, dynamic data}) {
    _logger.i(
        '🔥 Firebase: $operation${collection != null ? ' [$collection]' : ''}',
        error: data != null ? 'Data: $data' : null);
  }

  /// Log network requests
  void network(String method, String url, {int? statusCode, dynamic response}) {
    final status = statusCode != null ? ' → $statusCode' : '';
    _logger.d('🌐 $method $url$status', error: response);
  }

  /// Log navigation events
  void navigation(String route, {Map<String, dynamic>? params}) {
    _logger.d('🧭 Navigation: $route', error: params);
  }

  /// Log user actions
  void userAction(String action, {Map<String, dynamic>? details}) {
    _logger.i('👤 User: $action', error: details);
  }

  /// Log performance metrics
  void performance(String operation, Duration duration) {
    final ms = duration.inMilliseconds;
    final emoji = ms < 100
        ? '⚡'
        : ms < 500
            ? '🚀'
            : '🐢';
    _logger.d('$emoji Performance: $operation took ${ms}ms');
  }

  /// Log database operations
  void database(String operation, {String? table, int? rowsAffected}) {
    final rows = rowsAffected != null ? ' ($rowsAffected rows)' : '';
    _logger.d('💾 DB: $operation${table != null ? ' [$table]' : ''}$rows');
  }

  /// Log sync operations
  void sync(String message, {bool success = true}) {
    final emoji = success ? '🔄' : '❌';
    _logger.i('$emoji Sync: $message');
  }
}
