// lib/core/services/base_service.dart
// الخدمة الأساسية - واجهة موحدة لجميع الخدمات - محسنة

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import 'logger_service.dart';

/// نتيجة العملية - تستخدم لإرجاع نتائج موحدة من جميع الخدمات
class ServiceResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  ServiceResult._({
    required this.success,
    this.data,
    this.error,
    this.errorCode,
    this.metadata,
  });

  /// نتيجة ناجحة
  factory ServiceResult.success([T? data, Map<String, dynamic>? metadata]) {
    return ServiceResult._(success: true, data: data, metadata: metadata);
  }

  /// نتيجة فاشلة
  factory ServiceResult.failure(
    String error, [
    String? errorCode,
    Map<String, dynamic>? metadata,
  ]) {
    return ServiceResult._(
      success: false,
      error: error,
      errorCode: errorCode,
      metadata: metadata,
    );
  }

  /// تحويل النتيجة
  ServiceResult<R> map<R>(R Function(T data) mapper) {
    if (success && data != null) {
      return ServiceResult.success(mapper(data as T), metadata);
    }
    return ServiceResult.failure(error ?? 'Unknown error', errorCode, metadata);
  }

  /// تنفيذ دالة على البيانات
  void when({
    required void Function(T data) onSuccess,
    required void Function(String error, String? code) onFailure,
  }) {
    if (success && data != null) {
      onSuccess(data as T);
    } else {
      onFailure(error ?? 'Unknown error', errorCode);
    }
  }

  /// التحقق من نوع الخطأ
  bool hasErrorCode(String code) => errorCode == code;

  @override
  String toString() {
    if (success) {
      return 'ServiceResult.success(data: $data)';
    }
    return 'ServiceResult.failure(error: $error, code: $errorCode)';
  }
}

/// نتيجة مع Pagination
class PaginatedResult<T> {
  final List<T> items;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;
  final int totalCount;

  PaginatedResult({
    required this.items,
    required this.hasMore,
    this.lastDocument,
    this.totalCount = 0,
  });
}

/// واجهة الخدمة الأساسية - جميع الخدمات ترث منها
abstract class BaseService {
  /// معالجة الأخطاء الموحدة
  String handleError(dynamic error, [String? context]) {
    AppLogger.e(
      'Service Error${context != null ? ' in $context' : ''}',
      error: error,
    );

    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    }

    if (error is TimeoutException) {
      return 'انتهت مهلة الاتصال، حاول مرة أخرى';
    }

    if (error is FormatException) {
      return 'خطأ في تنسيق البيانات';
    }

    if (error is StateError) {
      return 'حالة غير صالحة';
    }

    final errorMessage = error.toString();

    // تنظيف رسالة الخطأ
    if (errorMessage.contains('Exception:')) {
      return errorMessage.replaceAll('Exception:', '').trim();
    }

    return errorMessage;
  }

  /// معالجة أخطاء Firebase
  String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return AppConstants.permissionDenied;
      case 'unavailable':
        return 'الخدمة غير متاحة حالياً، حاول مرة أخرى';
      case 'not-found':
        return AppConstants.dataNotFound;
      case 'already-exists':
        return 'البيانات موجودة بالفعل';
      case 'cancelled':
        return 'تم إلغاء العملية';
      case 'deadline-exceeded':
        return 'انتهت مهلة الاتصال، حاول مرة أخرى';
      case 'resource-exhausted':
        return 'تم تجاوز الحد المسموح، حاول لاحقاً';
      case 'failed-precondition':
        return 'الشروط المسبقة غير متوفرة';
      case 'aborted':
        return 'تم إلغاء العملية بسبب تعارض';
      case 'out-of-range':
        return 'القيمة خارج النطاق المسموح';
      case 'unimplemented':
        return 'هذه الميزة غير متاحة';
      case 'internal':
        return AppConstants.serverError;
      case 'data-loss':
        return 'فقدان في البيانات';
      default:
        return error.message ?? AppConstants.unknownError;
    }
  }

  /// تنفيذ عملية مع إعادة المحاولة
  Future<ServiceResult<T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    dynamic lastError;

    while (attempts < maxRetries) {
      try {
        final result = await operation();
        return ServiceResult.success(result);
      } catch (e) {
        lastError = e;
        attempts++;

        // التحقق من إمكانية إعادة المحاولة
        final canRetry = shouldRetry?.call(e) ?? _isRetryableError(e);
        if (!canRetry || attempts >= maxRetries) {
          break;
        }

        AppLogger.w('إعادة المحاولة ($attempts/$maxRetries): $e');
        await Future.delayed(delay * attempts);
      }
    }

    return ServiceResult.failure(handleError(lastError));
  }

  /// التحقق من إمكانية إعادة المحاولة
  bool _isRetryableError(dynamic error) {
    if (error is FirebaseException) {
      return [
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'aborted',
      ].contains(error.code);
    }
    return error is TimeoutException;
  }

  /// تنفيذ عملية مع مهلة زمنية
  Future<ServiceResult<T>> executeWithTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final result = await operation().timeout(timeout);
      return ServiceResult.success(result);
    } on TimeoutException {
      return ServiceResult.failure('انتهت مهلة العملية', 'timeout');
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }
}

/// واجهة CRUD الموحدة
abstract class CrudService<T, ID> extends BaseService {
  /// اسم المجموعة
  String get collectionName;

  /// تحويل البيانات من Map
  T fromMap(ID id, Map<String, dynamic> map);

  /// تحويل البيانات إلى Map
  Map<String, dynamic> toMap(T item);

  /// إنشاء عنصر جديد
  Future<ServiceResult<T>> create(T item);

  /// قراءة عنصر واحد
  Future<ServiceResult<T>> read(ID id);

  /// تحديث عنصر
  Future<ServiceResult<void>> update(ID id, T item);

  /// حذف عنصر
  Future<ServiceResult<void>> delete(ID id);

  /// قراءة جميع العناصر
  Future<ServiceResult<List<T>>> readAll();

  /// قراءة مع Pagination
  Future<ServiceResult<PaginatedResult<T>>> readPaginated({
    int limit = AppConstants.defaultPageSize,
    DocumentSnapshot? startAfter,
  });

  /// Stream للعناصر
  Stream<List<T>> stream();

  /// البحث
  Future<ServiceResult<List<T>>> search(String query);
}

/// Mixin لإضافة Cache
mixin CacheableMixin<T> {
  final Map<String, T> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  Duration get cacheDuration => const Duration(minutes: 5);

  T? getFromCache(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp != null) {
      if (DateTime.now().difference(timestamp) < cacheDuration) {
        return _cache[key];
      } else {
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    return null;
  }

  void addToCache(String key, T value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  void removeFromCache(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}

/// Mixin لإدارة الاشتراكات
mixin SubscriptionMixin {
  final List<StreamSubscription> _subscriptions = [];

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void cancelAllSubscriptions() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  void dispose() {
    cancelAllSubscriptions();
  }
}
