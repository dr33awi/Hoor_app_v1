// lib/core/services/base_service.dart
// الخدمة الأساسية - واجهة موحدة لجميع الخدمات

import 'package:cloud_firestore/cloud_firestore.dart';

/// نتيجة العملية - تستخدم لإرجاع نتائج موحدة من جميع الخدمات
class ServiceResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? errorCode;

  ServiceResult._({
    required this.success,
    this.data,
    this.error,
    this.errorCode,
  });

  /// نتيجة ناجحة
  factory ServiceResult.success([T? data]) {
    return ServiceResult._(success: true, data: data);
  }

  /// نتيجة فاشلة
  factory ServiceResult.failure(String error, [String? errorCode]) {
    return ServiceResult._(success: false, error: error, errorCode: errorCode);
  }
}

/// واجهة الخدمة الأساسية - جميع الخدمات ترث منها
abstract class BaseService {
  /// معالجة الأخطاء الموحدة
  String handleError(dynamic error) {
    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    }
    return error.toString();
  }

  /// معالجة أخطاء Firebase
  String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'ليس لديك صلاحية لهذه العملية';
      case 'unavailable':
        return 'الخدمة غير متاحة حالياً، حاول مرة أخرى';
      case 'not-found':
        return 'البيانات المطلوبة غير موجودة';
      case 'already-exists':
        return 'البيانات موجودة بالفعل';
      case 'cancelled':
        return 'تم إلغاء العملية';
      case 'deadline-exceeded':
        return 'انتهت مهلة الاتصال، حاول مرة أخرى';
      default:
        return error.message ?? 'حدث خطأ غير متوقع';
    }
  }
}

/// واجهة CRUD الموحدة
abstract class CrudService<T> extends BaseService {
  /// إنشاء عنصر جديد
  Future<ServiceResult<String>> create(T item);

  /// قراءة عنصر واحد
  Future<ServiceResult<T>> read(String id);

  /// تحديث عنصر
  Future<ServiceResult<void>> update(String id, T item);

  /// حذف عنصر
  Future<ServiceResult<void>> delete(String id);

  /// قراءة جميع العناصر
  Future<ServiceResult<List<T>>> readAll();

  /// Stream للعناصر
  Stream<List<T>> stream();
}
