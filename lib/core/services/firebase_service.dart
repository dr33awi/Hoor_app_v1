// lib/core/services/firebase_service.dart
// خدمة Firebase الموحدة - نقطة الوصول الوحيدة لـ Firebase

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'base_service.dart';
import 'logger_service.dart';

/// خدمة Firebase الموحدة
/// تستخدم Singleton Pattern لضمان وجود نسخة واحدة فقط
class FirebaseService extends BaseService {
  // Singleton
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  FirebaseStorage? _storage;

  bool _initialized = false;

  // Getters
  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception(
        'Firebase لم يتم تهيئته بعد. قم بتشغيل initialize() أولاً',
      );
    }
    return _firestore!;
  }

  FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception(
        'Firebase لم يتم تهيئته بعد. قم بتشغيل initialize() أولاً',
      );
    }
    return _auth!;
  }

  FirebaseStorage get storage {
    if (_storage == null) {
      throw Exception(
        'Firebase لم يتم تهيئته بعد. قم بتشغيل initialize() أولاً',
      );
    }
    return _storage!;
  }

  bool get isInitialized => _initialized;

  /// تهيئة Firebase
  Future<ServiceResult<void>> initialize() async {
    if (_initialized) {
      AppLogger.d('Firebase مهيأ مسبقاً');
      return ServiceResult.success();
    }

    try {
      AppLogger.d('جاري تهيئة Firebase...');
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _storage = FirebaseStorage.instance;

      // إعدادات Firestore
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _initialized = true;
      AppLogger.i('✅ تم تهيئة Firebase بنجاح');
      return ServiceResult.success();
    } catch (e) {
      AppLogger.firebaseError('initialize', e);
      return ServiceResult.failure(handleError(e));
    }
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
      final docRef = await collection(collectionPath).add(data);
      return ServiceResult.success(docRef.id);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
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
      await document(collectionPath, docId).set(data, SetOptions(merge: merge));
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تحديث document
  Future<ServiceResult<void>> update(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await document(collectionPath, docId).update(data);
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// حذف document
  Future<ServiceResult<void>> delete(
    String collectionPath,
    String docId,
  ) async {
    try {
      await document(collectionPath, docId).delete();
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// الحصول على document واحد
  Future<ServiceResult<DocumentSnapshot<Map<String, dynamic>>>> get(
    String collectionPath,
    String docId,
  ) async {
    try {
      final doc = await document(collectionPath, docId).get();
      if (!doc.exists) {
        return ServiceResult.failure('البيانات غير موجودة', 'not-found');
      }
      return ServiceResult.success(doc);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// الحصول على جميع documents في collection
  Future<ServiceResult<QuerySnapshot<Map<String, dynamic>>>> getAll(
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
      final snapshot = await query.get();
      return ServiceResult.success(snapshot);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// Stream لـ collection
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collectionPath, {
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = collection(collectionPath);
    if (queryBuilder != null) {
      query = queryBuilder(collection(collectionPath));
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
    Future<T> Function(Transaction transaction) handler,
  ) async {
    try {
      final result = await firestore.runTransaction(handler);
      return ServiceResult.success(result);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تنفيذ Batch Write
  Future<ServiceResult<void>> runBatch(
    void Function(WriteBatch batch) handler,
  ) async {
    try {
      final batch = firestore.batch();
      handler(batch);
      await batch.commit();
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  // ==================== Storage Operations ====================

  /// رفع ملف
  Future<ServiceResult<String>> uploadFile(
    String path,
    List<int> data,
    String contentType,
  ) async {
    try {
      final ref = storage.ref().child(path);
      final uploadTask = ref.putData(
        data as dynamic,
        SettableMetadata(contentType: contentType),
      );
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return ServiceResult.success(downloadUrl);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// حذف ملف
  Future<ServiceResult<void>> deleteFile(String path) async {
    try {
      await storage.ref().child(path).delete();
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// الحصول على رابط الملف
  Future<ServiceResult<String>> getFileUrl(String path) async {
    try {
      final url = await storage.ref().child(path).getDownloadURL();
      return ServiceResult.success(url);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }
}
