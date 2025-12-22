// lib/core/services/auth_service.dart
// خدمة المصادقة الموحدة

import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import 'base_service.dart';
import 'firebase_service.dart';

/// نموذج بيانات المستخدم
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? AppConstants.roleEmployee,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  bool get isAdmin => role == AppConstants.roleAdmin;
}

/// خدمة المصادقة
class AuthService extends BaseService {
  final FirebaseService _firebase = FirebaseService();

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // المستخدم الحالي
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Stream للمستخدم
  Stream<User?> get authStateChanges => _firebase.auth.authStateChanges();

  // هل المستخدم مسجل الدخول
  bool get isLoggedIn => _firebase.auth.currentUser != null;

  // ID المستخدم الحالي
  String? get currentUserId => _firebase.auth.currentUser?.uid;

  /// تسجيل الدخول
  Future<ServiceResult<UserModel>> signIn(String email, String password) async {
    try {
      final credential = await _firebase.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return ServiceResult.failure('فشل تسجيل الدخول');
      }

      // جلب بيانات المستخدم من Firestore
      final userResult = await _getUserData(credential.user!.uid);
      if (!userResult.success) {
        await _firebase.auth.signOut();
        return ServiceResult.failure(userResult.error!);
      }

      // التحقق من أن الحساب نشط
      if (!userResult.data!.isActive) {
        await _firebase.auth.signOut();
        return ServiceResult.failure('هذا الحساب معطل، تواصل مع المدير');
      }

      _currentUser = userResult.data;
      return ServiceResult.success(_currentUser);
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_handleAuthError(e));
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تسجيل مستخدم جديد (للمدير فقط)
  Future<ServiceResult<UserModel>> signUp({
    required String email,
    required String password,
    required String name,
    String role = AppConstants.roleEmployee,
  }) async {
    try {
      final credential = await _firebase.auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return ServiceResult.failure('فشل إنشاء الحساب');
      }

      // إنشاء بيانات المستخدم في Firestore
      final userData = UserModel(
        id: credential.user!.uid,
        email: email.trim(),
        name: name,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final saveResult = await _firebase.set(
        AppConstants.usersCollection,
        credential.user!.uid,
        userData.toMap(),
      );

      if (!saveResult.success) {
        // حذف المستخدم من Auth إذا فشل الحفظ
        await credential.user!.delete();
        return ServiceResult.failure(saveResult.error!);
      }

      return ServiceResult.success(userData);
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_handleAuthError(e));
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تسجيل الخروج
  Future<ServiceResult<void>> signOut() async {
    try {
      await _firebase.auth.signOut();
      _currentUser = null;
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<ServiceResult<void>> resetPassword(String email) async {
    try {
      await _firebase.auth.sendPasswordResetEmail(email: email.trim());
      return ServiceResult.success();
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_handleAuthError(e));
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تغيير كلمة المرور
  Future<ServiceResult<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _firebase.auth.currentUser;
      if (user == null) {
        return ServiceResult.failure('يجب تسجيل الدخول أولاً');
      }

      // إعادة المصادقة
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // تغيير كلمة المرور
      await user.updatePassword(newPassword);
      return ServiceResult.success();
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_handleAuthError(e));
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// جلب بيانات المستخدم الحالي
  Future<ServiceResult<UserModel>> loadCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) {
      return ServiceResult.failure('لم يتم تسجيل الدخول');
    }

    final result = await _getUserData(userId);
    if (result.success) {
      _currentUser = result.data;
    }
    return result;
  }

  /// جلب بيانات مستخدم من Firestore
  Future<ServiceResult<UserModel>> _getUserData(String userId) async {
    final result = await _firebase.get(AppConstants.usersCollection, userId);

    if (!result.success) {
      return ServiceResult.failure(result.error!);
    }

    final data = result.data!.data();
    if (data == null) {
      return ServiceResult.failure('بيانات المستخدم غير موجودة');
    }

    return ServiceResult.success(UserModel.fromMap(userId, data));
  }

  /// معالجة أخطاء المصادقة
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'هذا الحساب معطل';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      default:
        return e.message ?? 'حدث خطأ في المصادقة';
    }
  }
}
