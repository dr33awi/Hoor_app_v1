// lib/core/services/firebase_service.dart
// خدمة Firebase الموحدة - محسنة مع دعم Offline

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:typed_data';
import 'base_service.dart';
import 'logger_service.dart';
import 'connectivity_service.dart';

/// خدمة Firebase الموحدة
/// تستخدم Singleton Pattern لضمان وجود نسخة واحدة فقط
class FirebaseService extends BaseService with SubscriptionMixin {
  // Singleton
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  FirebaseStorage? _storage;

  bool _initialized = false;
  bool _offlineMode = false;

  // Getters
  FirebaseFirestore get firestore {
    _checkInitialized();
    return _firestore!;
  }

  FirebaseAuth get auth {
    _checkInitialized();
    return _auth!;
  }

  FirebaseStorage get storage {
    _checkInitialized();
    return _storage!;
  }

  bool get isInitialized => _initialized;
  bool get isOfflineMode => _offlineMode;

  void _checkInitialized() {
    if (!_initialized) {
      throw StateError(
        'Firebase لم يتم تهيئته بعد. قم بتشغيل initialize() أولاً',
      );
    }
  }

  /// تهيئة Firebase
  Future<ServiceResult<void>> initialize() async {
    if (_initialized) {
      AppLogger.d('Firebase مهيأ مسبقاً');
      return ServiceResult.success();
    }

    try {
      AppLogger.startOperation('تهيئة Firebase');

      await Firebase.initializeApp();

      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _storage = FirebaseStorage.instance;

      // إعدادات Firestore للـ Offline
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // الاستماع لحالة الاتصال
      _setupConnectivityListener();

      _initialized = true;
      AppLogger.endOperation('تهيئة Firebase', success: true);
      return ServiceResult.success();
    } catch (e, stackTrace) {
      AppLogger.firebaseError('initialize', e, stackTrace);
      return ServiceResult.failure(handleError(e, 'Firebase initialization'));
    }
  }

  /// إعداد مستمع الاتصال
  void _setupConnectivityListener() {
    final subscription = ConnectivityService().onConnectivityChanged.listen((
      isConnected,
    ) {
      _offlineMode = !isConnected;
      if (isConnected) {
        AppLogger.i('🌐 تم استعادة الاتصال بالإنترنت');
      } else {
        AppLogger.w('📴 تم فقدان الاتصال - الوضع Offline');
      }
    });
    addSubscription(subscription);
  }

  // ==================== Firestore Operations ====================

  /// الحصول على مرجع Collection
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return firestore.collection(path);
  }

  /// الحصول على مرجع Document
  DocumentReference<Map<String, dynamic>> document(
    String collectionPath,
    String docId,
  ) {
    return firestore.collection(collectionPath).doc(docId);
  }

  /// إضافة document جديد مع ID تلقائي
  Future<ServiceResult<String>> add(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      AppLogger.database('ADD', collectionPath);
      final docRef = await collection(collectionPath).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ServiceResult.success(docRef.id);
    } catch (e) {
      return ServiceResult.failure(handleError(e, 'add to $collectionPath'));
    }
  }

  /// إضافة document مع ID محدد
  Future<ServiceResult<void>> set(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      AppLogger.database('SET', collectionPath, docId: docId);
      await document(collectionPath, docId).set({
        ...data,
        if (!merge) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: merge));
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(
        handleError(e, 'set $collectionPath/$docId'),
      );
    }
  }

  /// تحديث document
  Future<ServiceResult<void>> update(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      AppLogger.database('UPDATE', collectionPath, docId: docId);
      await document(
        collectionPath,
        docId,
      ).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(
        handleError(e, 'update $collectionPath/$docId'),
      );
    }
  }

  /// حذف document
  Future<ServiceResult<void>> delete(
    String collectionPath,
    String docId,
  ) async {
    try {
      AppLogger.database('DELETE', collectionPath, docId: docId);
      await document(collectionPath, docId).delete();
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(
        handleError(e, 'delete $collectionPath/$docId'),
      );
    }
  }

  /// الحصول على document واحد
  Future<ServiceResult<DocumentSnapshot<Map<String, dynamic>>>> get(
    String collectionPath,
    String docId, {
    Source source = Source.serverAndCache,
  }) async {
    try {
      AppLogger.database('GET', collectionPath, docId: docId);
      final doc = await document(
        collectionPath,
        docId,
      ).get(GetOptions(source: source));

      if (!doc.exists) {
        return ServiceResult.failure('البيانات غير موجودة', 'not-found');
      }
      return ServiceResult.success(doc);
    } catch (e) {
      return ServiceResult.failure(
        handleError(e, 'get $collectionPath/$docId'),
      );
    }
  }

  /// الحصول على جميع documents في collection مع Pagination
  Future<ServiceResult<QuerySnapshot<Map<String, dynamic>>>> getAll(
    String collectionPath, {
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
    int? limit,
    DocumentSnapshot? startAfter,
    Source source = Source.serverAndCache,
  }) async {
    try {
      AppLogger.database('GET_ALL', collectionPath);
      Query<Map<String, dynamic>> query = collection(collectionPath);

      if (queryBuilder != null) {
        query = queryBuilder(collection(collectionPath));
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get(GetOptions(source: source));
      return ServiceResult.success(snapshot);
    } catch (e) {
      return ServiceResult.failure(handleError(e, 'getAll $collectionPath'));
    }
  }

  /// عد documents
  Future<ServiceResult<int>> count(
    String collectionPath, {
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
  }) async {
    try {
      Query<Map<String, dynamic>> query = collection(collectionPath);
      if (queryBuilder != null) {
        query = queryBuilder(collection(collectionPath));
      }

      final snapshot = await query.count().get();
      return ServiceResult.success(snapshot.count ?? 0);
    } catch (e) {
      return ServiceResult.failure(handleError(e, 'count $collectionPath'));
    }
  }

  /// Stream لـ collection
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collectionPath, {
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = collection(collectionPath);

    if (queryBuilder != null) {
      query = queryBuilder(collection(collectionPath));
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Stream لـ document
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(
    String collectionPath,
    String docId,
  ) {
    return document(collectionPath, docId).snapshots();
  }

  /// تنفيذ Transaction
  Future<ServiceResult<T>> runTransaction<T>(
    Future<T> Function(Transaction transaction) handler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    try {
      AppLogger.d('بدء Transaction');
      final result = await firestore.runTransaction(
        handler,
        timeout: timeout,
        maxAttempts: maxAttempts,
      );
      AppLogger.d('اكتمل Transaction بنجاح');
      return ServiceResult.success(result);
    } catch (e) {
      AppLogger.e('فشل Transaction', error: e);
      return ServiceResult.failure(handleError(e, 'transaction'));
    }
  }

  /// تنفيذ Batch Write
  Future<ServiceResult<void>> runBatch(
    void Function(WriteBatch batch) handler,
  ) async {
    try {
      AppLogger.d('بدء Batch Write');
      final batch = firestore.batch();
      handler(batch);
      await batch.commit();
      AppLogger.d('اكتمل Batch Write بنجاح');
      return ServiceResult.success();
    } catch (e) {
      AppLogger.e('فشل Batch Write', error: e);
      return ServiceResult.failure(handleError(e, 'batch'));
    }
  }

  /// التحقق من وجود document
  Future<bool> exists(String collectionPath, String docId) async {
    try {
      final doc = await document(collectionPath, docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ==================== Storage Operations ====================

  /// رفع ملف من Bytes
  Future<ServiceResult<String>> uploadFile(
    String path,
    Uint8List data,
    String contentType,
  ) async {
    try {
      AppLogger.d('رفع ملف: $path');
      final ref = storage.ref().child(path);
      final uploadTask = ref.putData(
        data,
        SettableMetadata(contentType: contentType),
      );

      // تتبع التقدم
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        AppLogger.d('تقدم الرفع: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      AppLogger.d('تم رفع الملف بنجاح: $downloadUrl');
      return ServiceResult.success(downloadUrl);
    } catch (e) {
      return ServiceResult.failure(handleError(e, 'upload file'));
    }
  }

  /// حذف ملف
  Future<ServiceResult<void>> deleteFile(String path) async {
    try {
      AppLogger.d('حذف ملف: $path');
      await storage.ref().child(path).delete();
      return ServiceResult.success();
    } catch (e) {
      // تجاهل الخطأ إذا كان الملف غير موجود
      if (e is FirebaseException && e.code == 'object-not-found') {
        return ServiceResult.success();
      }
      return ServiceResult.failure(handleError(e, 'delete file'));
    }
  }

  /// الحصول على رابط الملف
  Future<ServiceResult<String>> getFileUrl(String path) async {
    try {
      final url = await storage.ref().child(path).getDownloadURL();
      return ServiceResult.success(url);
    } catch (e) {
      return ServiceResult.failure(handleError(e, 'get file url'));
    }
  }

  /// الحصول على metadata الملف
  Future<ServiceResult<FullMetadata>> getFileMetadata(String path) async {
    try {
      final metadata = await storage.ref().child(path).getMetadata();
      return ServiceResult.success(metadata);
    } catch (e) {
      return ServiceResult.failure(handleError(e, 'get file metadata'));
    }
  }

  // ==================== Utility Methods ====================

  /// تمكين الوضع Offline
  Future<void> enableOfflineMode() async {
    await firestore.disableNetwork();
    _offlineMode = true;
    AppLogger.i('تم تفعيل الوضع Offline');
  }

  /// تعطيل الوضع Offline
  Future<void> disableOfflineMode() async {
    await firestore.enableNetwork();
    _offlineMode = false;
    AppLogger.i('تم تعطيل الوضع Offline');
  }

  /// مسح الـ Cache
  Future<void> clearCache() async {
    await firestore.clearPersistence();
    AppLogger.i('تم مسح Cache');
  }

  /// الانتظار حتى تتم المزامنة
  Future<void> waitForPendingWrites() async {
    await firestore.waitForPendingWrites();
  }

  @override
  void dispose() {
    super.dispose();
    AppLogger.d('تم تنظيف FirebaseService');
  }
}
