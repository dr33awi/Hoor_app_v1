// lib/core/services/base/base_service.dart
// الخدمة القاعدية - الأساس لجميع الخدمات

/// الخدمة القاعدية المجردة
abstract class BaseService {
  /// معالجة الأخطاء وتحويلها لرسائل مفهومة
  String handleError(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('network')) {
        return 'خطأ في الاتصال بالشبكة';
      }
      if (message.contains('permission')) {
        return 'ليس لديك صلاحية لهذا الإجراء';
      }
      if (message.contains('not-found')) {
        return 'العنصر غير موجود';
      }
      return message.replaceAll('Exception: ', '');
    }
    return 'حدث خطأ غير متوقع';
  }
}

/// نتيجة العملية - تغليف نتائج الخدمات
class ServiceResult<T> {
  final bool success;
  final T? data;
  final String? error;

  ServiceResult._({required this.success, this.data, this.error});

  /// إنشاء نتيجة ناجحة
  factory ServiceResult.success([T? data]) {
    return ServiceResult._(success: true, data: data);
  }

  /// إنشاء نتيجة فاشلة
  factory ServiceResult.failure(String error) {
    return ServiceResult._(success: false, error: error);
  }

  /// تحويل النتيجة إلى نوع آخر
  ServiceResult<R> map<R>(R Function(T data) mapper) {
    if (success && data != null) {
      return ServiceResult.success(mapper(data as T));
    }
    return ServiceResult.failure(error ?? 'Unknown error');
  }

  /// تنفيذ دالة إذا كانت النتيجة ناجحة
  void whenSuccess(void Function(T data) action) {
    if (success && data != null) {
      action(data as T);
    }
  }

  /// تنفيذ دالة إذا كانت النتيجة فاشلة
  void whenFailure(void Function(String error) action) {
    if (!success && error != null) {
      action(error!);
    }
  }
}
