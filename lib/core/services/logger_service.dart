// lib/core/services/logger_service.dart
// خدمة تسجيل الأحداث والأخطاء

import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// خدمة Logger موحدة للمشروع
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // عدد استدعاءات الـ stack trace
      errorMethodCount: 8, // عدد الاستدعاءات عند الأخطاء
      lineLength: 120, // طول السطر
      colors: true, // تفعيل الألوان
      printEmojis: true, // تفعيل الرموز التعبيرية
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // عرض الوقت
    ),
    filter: _AppLogFilter(),
  );

  // Logger بسيط للرسائل القصيرة
  static final Logger _simpleLogger = Logger(
    printer: SimplePrinter(colors: true),
    filter: _AppLogFilter(),
  );

  /// رسالة تصحيح (Debug)
  static void d(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// معلومات (Info)
  static void i(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// تحذير (Warning)
  static void w(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// خطأ (Error)
  static void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// خطأ فادح (Fatal)
  static void f(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// رسالة بسيطة (للتتبع السريع)
  static void t(String message) {
    _simpleLogger.t(message);
  }

  /// تسجيل بداية عملية
  static void startOperation(String operation) {
    _logger.i('▶️ بدء: $operation');
  }

  /// تسجيل نهاية عملية
  static void endOperation(String operation, {bool success = true}) {
    if (success) {
      _logger.i('✅ اكتمل: $operation');
    } else {
      _logger.w('❌ فشل: $operation');
    }
  }

  /// تسجيل طلب HTTP
  static void httpRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) {
    _logger.d('🌐 $method: $url', error: body);
  }

  /// تسجيل استجابة HTTP
  static void httpResponse(String url, int statusCode, {dynamic data}) {
    if (statusCode >= 200 && statusCode < 300) {
      _logger.d('✅ Response [$statusCode]: $url');
    } else {
      _logger.w('⚠️ Response [$statusCode]: $url', error: data);
    }
  }

  /// تسجيل أخطاء Firebase
  static void firebaseError(
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    _logger.e(
      '🔥 Firebase Error - $operation',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// تسجيل أحداث المستخدم
  static void userAction(String action, {Map<String, dynamic>? details}) {
    _logger.i('👤 User: $action', error: details);
  }
}

/// فلتر مخصص - يعرض الـ logs فقط في وضع التطوير
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // عرض كل الـ logs في وضع التطوير
    if (kDebugMode) {
      return true;
    }
    // في الإنتاج: فقط التحذيرات والأخطاء
    return event.level.index >= Level.warning.index;
  }
}
