// lib/core/services/base/logger_service.dart
// خدمة السجلات - تسجيل الأحداث والأخطاء

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// خدمة تسجيل الأحداث
class AppLogger {
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss.SSS');
  static final Map<String, DateTime> _operations = {};

  // ألوان للـ Console
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  /// Debug log
  static void d(String message, {dynamic data}) {
    if (kDebugMode) {
      _log('🐛 DEBUG', message, _cyan, data: data);
    }
  }

  /// Info log
  static void i(String message, {dynamic data}) {
    if (kDebugMode) {
      _log('ℹ️ INFO', message, _blue, data: data);
    }
  }

  /// Warning log
  static void w(String message, {dynamic data}) {
    if (kDebugMode) {
      _log('⚠️ WARNING', message, _yellow, data: data);
    }
  }

  /// Error log
  static void e(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _log('❌ ERROR', message, _red, data: error?.toString());
      if (stackTrace != null) {
        debugPrint('$_red$stackTrace$_reset');
      }
    }
  }

  /// Success log
  static void s(String message, {dynamic data}) {
    if (kDebugMode) {
      _log('✅ SUCCESS', message, _green, data: data);
    }
  }

  /// بدء عملية (لقياس الوقت)
  static void startOperation(String name) {
    _operations[name] = DateTime.now();
    if (kDebugMode) {
      _log('🚀 START', name, _magenta);
    }
  }

  /// إنهاء عملية
  static void endOperation(String name, {bool success = true}) {
    final startTime = _operations.remove(name);
    if (startTime != null && kDebugMode) {
      final duration = DateTime.now().difference(startTime);
      final icon = success ? '✅' : '❌';
      final color = success ? _green : _red;
      _log('$icon END', '$name (${duration.inMilliseconds}ms)', color);
    }
  }

  /// الدالة الرئيسية للـ logging
  static void _log(String level, String message, String color, {dynamic data}) {
    final time = _timeFormat.format(DateTime.now());
    debugPrint('$color[$time] $level: $message$_reset');
    if (data != null) {
      debugPrint('$color  Data: $data$_reset');
    }
  }
}
