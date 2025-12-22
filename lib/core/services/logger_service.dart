// lib/core/services/logger_service.dart
// خدمة تسجيل الأحداث والأخطاء - محسنة

import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// مستويات السجل
enum LogLevel { trace, debug, info, warning, error, fatal }

/// خدمة Logger موحدة للمشروع
class AppLogger {
  AppLogger._();

  static LogLevel _minLevel = kDebugMode ? LogLevel.trace : LogLevel.warning;
  static bool _enableEmoji = true;
  static bool _enableTimestamp = true;
  static final List<LogEntry> _logHistory = [];
  static const int _maxHistorySize = 1000;

  /// تعيين الحد الأدنى لمستوى السجل
  static void setMinLevel(LogLevel level) => _minLevel = level;

  /// تفعيل/تعطيل الإيموجي
  static void setEnableEmoji(bool enable) => _enableEmoji = enable;

  /// الحصول على سجل الأحداث
  static List<LogEntry> get logHistory => List.unmodifiable(_logHistory);

  /// مسح السجل
  static void clearHistory() => _logHistory.clear();

  /// رسالة تتبع (Trace)
  static void t(String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.trace, message, error: error, stackTrace: stackTrace);
  }

  /// رسالة تصحيح (Debug)
  static void d(String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  /// معلومات (Info)
  static void i(String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  /// تحذير (Warning)
  static void w(String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  /// خطأ (Error)
  static void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  /// خطأ فادح (Fatal)
  static void f(String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, error: error, stackTrace: stackTrace);
  }

  /// تسجيل بداية عملية
  static void startOperation(String operation) {
    i('▶️ بدء: $operation');
  }

  /// تسجيل نهاية عملية
  static void endOperation(String operation, {bool success = true}) {
    if (success) {
      i('✅ اكتمل: $operation');
    } else {
      w('❌ فشل: $operation');
    }
  }

  /// تسجيل أداء
  static Stopwatch startPerformance(String operation) {
    d('⏱️ بدء قياس: $operation');
    return Stopwatch()..start();
  }

  static void endPerformance(String operation, Stopwatch stopwatch) {
    stopwatch.stop();
    d('⏱️ انتهى $operation في ${stopwatch.elapsedMilliseconds}ms');
  }

  /// تسجيل طلب HTTP
  static void httpRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    d('🌐 $method: $url', error: {'headers': headers, 'body': body});
  }

  /// تسجيل استجابة HTTP
  static void httpResponse(String url, int statusCode, {dynamic data}) {
    if (statusCode >= 200 && statusCode < 300) {
      d('✅ Response [$statusCode]: $url');
    } else if (statusCode >= 400 && statusCode < 500) {
      w('⚠️ Client Error [$statusCode]: $url', error: data);
    } else {
      e('❌ Server Error [$statusCode]: $url', error: data);
    }
  }

  /// تسجيل أخطاء Firebase
  static void firebaseError(
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    e('🔥 Firebase Error - $operation', error: error, stackTrace: stackTrace);
  }

  /// تسجيل أحداث المستخدم
  static void userAction(String action, {Map<String, dynamic>? details}) {
    i('👤 User: $action', error: details);
  }

  /// تسجيل أحداث التنقل
  static void navigation(String from, String to) {
    d('🧭 Navigation: $from → $to');
  }

  /// تسجيل أحداث قاعدة البيانات
  static void database(String operation, String collection, {String? docId}) {
    d('💾 DB $operation: $collection${docId != null ? '/$docId' : ''}');
  }

  /// التسجيل الداخلي
  static void _log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLevel.index) return;

    final entry = LogEntry(
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    // حفظ في السجل
    _addToHistory(entry);

    // طباعة السجل
    _printLog(entry);
  }

  static void _addToHistory(LogEntry entry) {
    _logHistory.add(entry);
    if (_logHistory.length > _maxHistorySize) {
      _logHistory.removeAt(0);
    }
  }

  static void _printLog(LogEntry entry) {
    final emoji = _enableEmoji ? _getEmoji(entry.level) : '';
    final timestamp = _enableTimestamp
        ? '[${_formatTime(entry.timestamp)}] '
        : '';
    final levelName = _getLevelName(entry.level);

    final buffer = StringBuffer();
    buffer.write('$timestamp$emoji $levelName: ${entry.message}');

    if (entry.error != null) {
      buffer.write('\n  Error: ${entry.error}');
    }

    if (entry.stackTrace != null && entry.level.index >= LogLevel.error.index) {
      buffer.write('\n  StackTrace: ${entry.stackTrace}');
    }

    // استخدام developer.log للتسجيل
    developer.log(
      buffer.toString(),
      name: 'HoorManager',
      level: _getDeveloperLogLevel(entry.level),
      error: entry.error,
      stackTrace: entry.stackTrace,
    );

    // طباعة أيضاً في وضع التطوير
    if (kDebugMode) {
      // ignore: avoid_print
      print(buffer.toString());
    }
  }

  static String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return '🔍';
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '💀';
    }
  }

  static String _getLevelName(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return 'TRACE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  static int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return 300;
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }
}

/// إدخال سجل واحد
class LogEntry {
  final LogLevel level;
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'message': message,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
