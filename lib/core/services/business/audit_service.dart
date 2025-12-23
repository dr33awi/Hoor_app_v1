// lib/core/services/business/audit_service.dart
// خدمة التدقيق - تتبع جميع العمليات

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_constants.dart';
import '../base/base_service.dart';
import '../base/logger_service.dart';
import '../infrastructure/firebase_service.dart';

/// أنواع الأحداث
class AuditAction {
  static const String login = 'login';
  static const String logout = 'logout';
  static const String sale = 'sale';
  static const String cancelSale = 'cancel_sale';
  static const String addProduct = 'add_product';
  static const String updateProduct = 'update_product';
  static const String deleteProduct = 'delete_product';
  static const String updateStock = 'update_stock';
  static const String approveUser = 'approve_user';
  static const String rejectUser = 'reject_user';
}

/// نموذج سجل التدقيق
class AuditLog {
  final String id;
  final String action;
  final String userId;
  final String userName;
  final String? targetCollection;
  final String? targetId;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceInfo;

  AuditLog({
    required this.id,
    required this.action,
    required this.userId,
    required this.userName,
    this.targetCollection,
    this.targetId,
    this.oldData,
    this.newData,
    this.metadata,
    required this.timestamp,
    this.ipAddress,
    this.deviceInfo,
  });

  factory AuditLog.fromMap(String id, Map<String, dynamic> map) {
    return AuditLog(
      id: id,
      action: map['action'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      targetCollection: map['targetCollection'],
      targetId: map['targetId'],
      oldData: map['oldData'] as Map<String, dynamic>?,
      newData: map['newData'] as Map<String, dynamic>?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ipAddress: map['ipAddress'],
      deviceInfo: map['deviceInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'userId': userId,
      'userName': userName,
      'targetCollection': targetCollection,
      'targetId': targetId,
      'oldData': oldData,
      'newData': newData,
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
    };
  }
}

/// خدمة التدقيق
class AuditService extends BaseService {
  FirebaseService get _firebase => FirebaseService();
  final String _collection = AppConstants.auditLogsCollection;

  // Singleton
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();

  String? _currentUserId;
  String? _currentUserName;

  void setCurrentUser(String userId, String userName) {
    _currentUserId = userId;
    _currentUserName = userName;
  }

  void clearCurrentUser() {
    _currentUserId = null;
    _currentUserName = null;
  }

  /// تسجيل حدث
  Future<ServiceResult<void>> log({
    required String action,
    String? targetCollection,
    String? targetId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_currentUserId == null) {
        return ServiceResult.success();
      }

      final auditLog = AuditLog(
        id: '',
        action: action,
        userId: _currentUserId!,
        userName: _currentUserName ?? 'غير معروف',
        targetCollection: targetCollection,
        targetId: targetId,
        oldData: _sanitizeData(oldData),
        newData: _sanitizeData(newData),
        metadata: metadata,
        timestamp: DateTime.now(),
      );

      await _firebase.add(_collection, auditLog.toMap());
      AppLogger.d('تم تسجيل حدث: $action');
      return ServiceResult.success();
    } catch (e) {
      AppLogger.e('خطأ في تسجيل الحدث', error: e);
      return ServiceResult.success();
    }
  }

  Map<String, dynamic>? _sanitizeData(Map<String, dynamic>? data) {
    if (data == null) return null;
    final sanitized = Map<String, dynamic>.from(data);
    sanitized.remove('password');
    sanitized.remove('token');
    sanitized.remove('secret');
    return sanitized;
  }

  // ==================== سجلات محددة ====================

  Future<void> logLogin() async {
    await log(
      action: AuditAction.login,
      metadata: {'loginTime': DateTime.now().toIso8601String()},
    );
  }

  Future<void> logLogout() async {
    await log(
      action: AuditAction.logout,
      metadata: {'logoutTime': DateTime.now().toIso8601String()},
    );
  }

  Future<void> logSale({
    required String saleId,
    required String invoiceNumber,
    required double total,
    required int itemsCount,
  }) async {
    await log(
      action: AuditAction.sale,
      targetCollection: AppConstants.salesCollection,
      targetId: saleId,
      metadata: {
        'invoiceNumber': invoiceNumber,
        'total': total,
        'itemsCount': itemsCount,
      },
    );
  }

  Future<void> logCancelSale({
    required String saleId,
    required String invoiceNumber,
    String? reason,
  }) async {
    await log(
      action: AuditAction.cancelSale,
      targetCollection: AppConstants.salesCollection,
      targetId: saleId,
      metadata: {'invoiceNumber': invoiceNumber, 'reason': reason},
    );
  }

  Future<void> logStockUpdate({
    required String productId,
    required String productName,
    required String variant,
    required int oldQuantity,
    required int newQuantity,
    String? reason,
  }) async {
    await log(
      action: AuditAction.updateStock,
      targetCollection: AppConstants.productsCollection,
      targetId: productId,
      oldData: {'quantity': oldQuantity},
      newData: {'quantity': newQuantity},
      metadata: {
        'productName': productName,
        'variant': variant,
        'change': newQuantity - oldQuantity,
        'reason': reason,
      },
    );
  }

  Future<void> logApproveUser({
    required String userId,
    required String userName,
  }) async {
    await log(
      action: AuditAction.approveUser,
      targetCollection: AppConstants.usersCollection,
      targetId: userId,
      metadata: {'approvedUserName': userName},
    );
  }

  Future<void> logRejectUser({
    required String userId,
    required String userName,
    String? reason,
  }) async {
    await log(
      action: AuditAction.rejectUser,
      targetCollection: AppConstants.usersCollection,
      targetId: userId,
      metadata: {'rejectedUserName': userName, 'reason': reason},
    );
  }

  // ==================== استعلامات ====================

  Future<ServiceResult<List<AuditLog>>> getUserLogs(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final result = await _firebase.getAll(
        _collection,
        queryBuilder: (ref) => ref
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .limit(limit),
      );

      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      final logs = result.data!.docs
          .map((doc) => AuditLog.fromMap(doc.id, doc.data()))
          .toList();

      return ServiceResult.success(logs);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<List<AuditLog>>> getRecentLogs({int limit = 50}) async {
    try {
      final result = await _firebase.getAll(
        _collection,
        queryBuilder: (ref) =>
            ref.orderBy('timestamp', descending: true).limit(limit),
      );

      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      final logs = result.data!.docs
          .map((doc) => AuditLog.fromMap(doc.id, doc.data()))
          .toList();

      return ServiceResult.success(logs);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }
}
