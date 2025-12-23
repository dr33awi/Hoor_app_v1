// lib/core/services/base_service.dart
// الخدمة القاعدية

abstract class BaseService {
  /// معالجة الأخطاء
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

/// نتيجة العملية
class ServiceResult<T> {
  final bool success;
  final T? data;
  final String? error;

  ServiceResult._({
    required this.success,
    this.data,
    this.error,
  });

  factory ServiceResult.success([T? data]) {
    return ServiceResult._(success: true, data: data);
  }

  factory ServiceResult.failure(String error) {
    return ServiceResult._(success: false, error: error);
  }

  /// تحويل النتيجة
  ServiceResult<R> map<R>(R Function(T data) mapper) {
    if (success && data != null) {
      return ServiceResult.success(mapper(data as T));
    }
    return ServiceResult.failure(error ?? 'Unknown error');
  }
}
