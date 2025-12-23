// lib/core/services/base_service.dart

/// نتيجة الخدمة
class ServiceResult<T> {
  final bool success;
  final T? data;
  final String? error;

  ServiceResult._({required this.success, this.data, this.error});

  factory ServiceResult.success([T? data]) {
    return ServiceResult._(success: true, data: data);
  }

  factory ServiceResult.failure(String error) {
    return ServiceResult._(success: false, error: error);
  }
}

/// الخدمة الأساسية
abstract class BaseService {
  /// معالجة الأخطاء
  String handleError(dynamic error) {
    if (error is String) {
      return error;
    }

    final message = error.toString();

    // ترجمة رسائل Firebase
    if (message.contains('permission-denied')) {
      return 'ليس لديك صلاحية للقيام بهذا الإجراء';
    }
    if (message.contains('not-found')) {
      return 'العنصر غير موجود';
    }
    if (message.contains('already-exists')) {
      return 'العنصر موجود بالفعل';
    }
    if (message.contains('network')) {
      return 'خطأ في الاتصال بالإنترنت';
    }
    if (message.contains('unavailable')) {
      return 'الخدمة غير متاحة حالياً';
    }
    if (message.contains('failed-precondition')) {
      return 'الشروط المسبقة غير متوفرة';
    }

    return 'حدث خطأ غير متوقع';
  }
}
