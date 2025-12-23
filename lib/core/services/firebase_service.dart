// lib/core/services/firebase_service.dart
// خدمة Firebase الكاملة - بدون Storage

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'base_service.dart';
import 'logger_service.dart';

class FirebaseService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;

  // Singleton
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // ==================== Getters ====================

  /// Firebase Auth instance
  FirebaseAuth get auth => _auth;

  /// Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// هل تم التهيئة؟
  bool get isInitialized => _isInitialized;

  // ==================== Initialization ====================

  /// تهيئة Firebase
  Future<ServiceResult<void>> initialize() async {
    try {
      if (_isInitialized) {
        return ServiceResult.success();
      }

      await Firebase.initializeApp();

      // إعدادات Firestore
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _isInitialized = true;
      AppLogger.i('✅ Firebase initialized successfully');
      return ServiceResult.success();
    } catch (e) {
      AppLogger.e('❌ Firebase initialization failed', error: e);
      return ServiceResult.failure(handleError(e));
    }
  }

  // ==================== Firestore ====================

  /// الحصول على مرجع Collection
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// الحصول على مرجع Document
  DocumentReference<Map<String, dynamic>> document(
    String collection,
    String docId,
  ) {
    return _firestore.collection(collection).doc(docId);
  }

  /// إضافة مستند جديد (ID تلقائي)
  Future<ServiceResult<String>> add(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      AppLogger.d('💾 DB ADD: $collection');
      final docRef = await _firestore.collection(collection).add(data);
      return ServiceResult.success(docRef.id);
    } catch (e) {
      AppLogger.e('❌ DB ADD Error', error: e);
      return ServiceResult.failure(handleError(e));
    }
  }

  /// إضافة/تحديث مستند بـ ID محدد
  Future<ServiceResult<void>> set(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      AppLogger.d('💾 DB SET: $collection/$docId');
      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
      return ServiceResult.success();
    } catch (e) {
      AppLogger.e('❌ DB SET Error', error: e);
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تحديث مستند
  Future<ServiceResult<void>> update(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      AppLogger.d('💾 DB UPDATE: $collection/$docId');
      await _firestore.collection(collection).doc(docId).update(data);
      return ServiceResult.success();
    } catch (e) {
      AppLogger.e('❌ DB UPDATE Error', error: e);
      return ServiceResult.failure(handleError(e));
    }
  }

  /// حذف مستند
  Future<ServiceResult<void>> delete(String collection, String docId) async {
    try {
      AppLogger.d('💾 DB DELETE: $collection/$docId');
      await _firestore.collection(collection).doc(docId).delete();
      return ServiceResult.success();
    } catch (e) {
      AppLogger.e('❌ DB DELETE Error', error: e);
      return ServiceResult.failure(handleError(e));
    }
  }

  /// الحصول على مستند واحد
  Future<ServiceResult<DocumentSnapshot<Map<String, dynamic>>>> get(
    String collection,
    String docId,
  ) async {
    try {
      AppLogger.d('💾 DB GET: $collection/$docId');
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (!doc.exists) {
        return ServiceResult.failure('المستند غير موجود');
      }
      return ServiceResult.success(doc);
    } catch (e) {
      AppLogger.e('❌ DB GET Error', error: e);
      return ServiceResult.failure(handleError(e));
    }
  }

  /// الحصول على جميع المستندات
  Future<ServiceResult<QuerySnapshot<Map<String, dynamic>>>> getAll(
    String collection, {
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      AppLogger.d('💾 DB GET_ALL: $collection');

      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      if (queryBuilder != null) {
        query = queryBuilder(_firestore.collection(collection));
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return ServiceResult.success(snapshot);
    } catch (e) {
      AppLogger.e('❌ DB GET_ALL Error', error: e);
      return ServiceResult.failure(handleError(e));
    }
  }

  /// Stream لمستند واحد
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(
    String collection,
    String docId,
  ) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Stream لـ Collection
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collection, {
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (queryBuilder != null) {
      query = queryBuilder(_firestore.collection(collection));
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// تنفيذ Transaction
  Future<ServiceResult<T>> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) async {
    try {
      final result = await _firestore.runTransaction(transactionHandler);
      return ServiceResult.success(result);
    } catch (e) {
      AppLogger.e('❌ Transaction Error', error: e);
      return ServiceResult.failure(handleError(e));
    }
  }

  /// Batch Write
  Future<ServiceResult<void>> batchWrite(
    void Function(WriteBatch batch) batchHandler,
  ) async {
    try {
      final batch = _firestore.batch();
      batchHandler(batch);
      await batch.commit();
      return ServiceResult.success();
    } catch (e) {
      AppLogger.e('❌ Batch Write Error', error: e);
      return ServiceResult.failure(handleError(e));
    }
  }

  /// التحقق من وجود مستند
  Future<bool> exists(String collection, String docId) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// عد المستندات
  Future<int> count(
    String collection, {
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      if (queryBuilder != null) {
        query = queryBuilder(_firestore.collection(collection));
      }

      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
