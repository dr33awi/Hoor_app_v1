// lib/core/services/auth_service.dart
// خدمة المصادقة الموحدة - محسنة

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/app_constants.dart';
import 'base_service.dart';
import 'firebase_service.dart';
import 'local_storage_service.dart';
import 'audit_service.dart';
import 'logger_service.dart';

/// حالات الموافقة على الحساب
class AccountStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String suspended = 'suspended';
}

/// نموذج بيانات المستخدم
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final String? photoUrl;
  final String authProvider;
  final bool isEmailVerified;
  final String accountStatus;
  final String? rejectionReason;
  final DateTime? approvedAt;
  final String? approvedBy;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.photoUrl,
    this.authProvider = 'email',
    this.isEmailVerified = false,
    this.accountStatus = AccountStatus.pending,
    this.rejectionReason,
    this.approvedAt,
    this.approvedBy,
    this.lastLoginAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? AppConstants.roleEmployee,
      isActive: map['isActive'] ?? true,
      createdAt: _parseDateTime(map['createdAt']),
      photoUrl: map['photoUrl'],
      authProvider: map['authProvider'] ?? 'email',
      isEmailVerified: map['isEmailVerified'] ?? false,
      accountStatus: map['accountStatus'] ?? AccountStatus.pending,
      rejectionReason: map['rejectionReason'],
      approvedAt: _parseDateTimeNullable(map['approvedAt']),
      approvedBy: map['approvedBy'],
      lastLoginAt: _parseDateTimeNullable(map['lastLoginAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return value.toDate();
  }

  static DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return value.toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'photoUrl': photoUrl,
      'authProvider': authProvider,
      'isEmailVerified': isEmailVerified,
      'accountStatus': accountStatus,
      'rejectionReason': rejectionReason,
      'approvedAt': approvedAt,
      'approvedBy': approvedBy,
      'lastLoginAt': lastLoginAt,
    };
  }

  bool get isAdmin => role == AppConstants.roleAdmin;
  bool get isManager => role == AppConstants.roleManager || isAdmin;
  bool get isPending => accountStatus == AccountStatus.pending;
  bool get isApproved => accountStatus == AccountStatus.approved;
  bool get isRejected => accountStatus == AccountStatus.rejected;
  bool get canLogin => isActive && isApproved;

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    String? photoUrl,
    String? authProvider,
    bool? isEmailVerified,
    String? accountStatus,
    String? rejectionReason,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      accountStatus: accountStatus ?? this.accountStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

/// خدمة المصادقة
class AuthService extends BaseService with SubscriptionMixin {
  final FirebaseService _firebase = FirebaseService();
  final LocalStorageService _storage = LocalStorageService();
  final AuditService _audit = AuditService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Stream<User?> get authStateChanges => _firebase.auth.authStateChanges();
  bool get isLoggedIn =>
      _firebase.auth.currentUser != null && _currentUser != null;
  String? get currentUserId => _firebase.auth.currentUser?.uid;
  bool get isEmailVerified =>
      _firebase.auth.currentUser?.emailVerified ?? false;

  Future<ServiceResult<UserModel>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      AppLogger.userAction('محاولة تسجيل دخول', details: {'email': email});

      final credential = await _firebase.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return ServiceResult.failure('فشل تسجيل الدخول');
      }

      final userResult = await _getUserData(credential.user!.uid);
      if (!userResult.success) {
        await _firebase.auth.signOut();
        return ServiceResult.failure(userResult.error!);
      }

      final user = userResult.data!;
      final validationResult = await _validateUserAccess(
        credential.user!,
        user,
      );
      if (!validationResult.success) {
        await _firebase.auth.signOut();
        return validationResult;
      }

      await _updateLastLogin(user.id);
      await _saveSession(user);

      _currentUser = user.copyWith(
        isEmailVerified: credential.user!.emailVerified,
        lastLoginAt: DateTime.now(),
      );

      _audit.setCurrentUser(user.id, user.name);
      await _audit.logLogin();

      AppLogger.i('✅ تم تسجيل الدخول: ${_currentUser?.name}');
      return ServiceResult.success(_currentUser);
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_handleAuthError(e), e.code);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<UserModel>> _validateUserAccess(
    User firebaseUser,
    UserModel user,
  ) async {
    if (!user.isAdmin && !firebaseUser.emailVerified) {
      return ServiceResult.failure(
        'البريد الإلكتروني غير مُفعّل',
        'email-not-verified',
      );
    }
    if (user.isPending) {
      return ServiceResult.failure(
        'حسابك في انتظار موافقة المدير',
        'account-pending',
      );
    }
    if (user.isRejected) {
      return ServiceResult.failure(
        'تم رفض طلب تسجيلك. السبب: ${user.rejectionReason ?? "غير محدد"}',
        'account-rejected',
      );
    }
    if (!user.isActive) {
      return ServiceResult.failure('هذا الحساب معطل', 'account-disabled');
    }
    return ServiceResult.success(user);
  }

  Future<ServiceResult<UserModel>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ServiceResult.failure('تم إلغاء تسجيل الدخول', 'cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebase.auth.signInWithCredential(
        credential,
      );
      if (userCredential.user == null) {
        return ServiceResult.failure('فشل تسجيل الدخول بـ Google');
      }

      final firebaseUser = userCredential.user!;
      final existingUser = await _getUserData(firebaseUser.uid);

      if (existingUser.success) {
        final validationResult = await _validateUserAccess(
          firebaseUser,
          existingUser.data!,
        );
        if (!validationResult.success) {
          await signOut();
          return validationResult;
        }

        await _updateLastLogin(existingUser.data!.id);
        await _saveSession(existingUser.data!);
        _currentUser = existingUser.data;
        _audit.setCurrentUser(_currentUser!.id, _currentUser!.name);
        await _audit.logLogin();
        return ServiceResult.success(_currentUser);
      }

      final newUser = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'مستخدم Google',
        role: AppConstants.roleEmployee,
        isActive: true,
        createdAt: DateTime.now(),
        photoUrl: firebaseUser.photoURL,
        authProvider: 'google',
        isEmailVerified: true,
        accountStatus: AccountStatus.pending,
      );

      await _firebase.set(
        AppConstants.usersCollection,
        firebaseUser.uid,
        newUser.toMap(),
      );
      await signOut();
      return ServiceResult.failure(
        'تم إنشاء حسابك! في انتظار موافقة المدير',
        'account-pending-new',
      );
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_handleAuthError(e), e.code);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<UserModel>> signUpWithEmail({
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

      await credential.user!.updateDisplayName(name);
      await credential.user!.sendEmailVerification();

      final userData = UserModel(
        id: credential.user!.uid,
        email: email.trim(),
        name: name,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
        authProvider: 'email',
        isEmailVerified: false,
        accountStatus: AccountStatus.pending,
      );

      await _firebase.set(
        AppConstants.usersCollection,
        credential.user!.uid,
        userData.toMap(),
      );
      await _firebase.auth.signOut();
      return ServiceResult.success(userData);
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_handleAuthError(e), e.code);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> resendVerificationEmail() async {
    try {
      final user = _firebase.auth.currentUser;
      if (user == null) return ServiceResult.failure('يجب تسجيل الدخول أولاً');
      if (user.emailVerified)
        return ServiceResult.failure('البريد مُفعّل بالفعل');
      await user.sendEmailVerification();
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> sendVerificationEmailToUser(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebase.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user?.emailVerified == true) {
        await _firebase.auth.signOut();
        return ServiceResult.failure('البريد مُفعّل بالفعل');
      }
      await credential.user?.sendEmailVerification();
      await _firebase.auth.signOut();
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> signOut() async {
    try {
      await _audit.logLogout();
      if (await _googleSignIn.isSignedIn()) await _googleSignIn.signOut();
      await _firebase.auth.signOut();
      await _storage.clearSession();
      _currentUser = null;
      _audit.clearCurrentUser();
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> resetPassword(String email) async {
    try {
      await _firebase.auth.sendPasswordResetEmail(email: email.trim());
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _firebase.auth.currentUser;
      if (user == null) return ServiceResult.failure('يجب تسجيل الدخول أولاً');
      if (_currentUser?.authProvider == 'google') {
        return ServiceResult.failure('لا يمكن تغيير كلمة المرور لحساب Google');
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<UserModel>> loadCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) return ServiceResult.failure('لم يتم تسجيل الدخول');
    final result = await _getUserData(userId);
    if (result.success) {
      _currentUser = result.data;
      _audit.setCurrentUser(_currentUser!.id, _currentUser!.name);
    }
    return result;
  }

  Future<ServiceResult<UserModel>> _getUserData(String userId) async {
    final result = await _firebase.get(AppConstants.usersCollection, userId);
    if (!result.success) return ServiceResult.failure(result.error!);
    final data = result.data!.data();
    if (data == null)
      return ServiceResult.failure('بيانات المستخدم غير موجودة');
    return ServiceResult.success(UserModel.fromMap(userId, data));
  }

  Future<void> _updateLastLogin(String userId) async {
    await _firebase.update(AppConstants.usersCollection, userId, {
      'lastLoginAt': DateTime.now(),
    });
  }

  Future<void> _saveSession(UserModel user) async {
    await _storage.saveSession(
      userId: user.id,
      userName: user.name,
      userRole: user.role,
    );
  }

  Future<ServiceResult<void>> updateUserName(String name) async {
    try {
      final userId = currentUserId;
      if (userId == null) return ServiceResult.failure('يجب تسجيل الدخول');
      await _firebase.auth.currentUser?.updateDisplayName(name);
      await _firebase.update(AppConstants.usersCollection, userId, {
        'name': name,
      });
      _currentUser = _currentUser?.copyWith(name: name);
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> updateUserPhoto(String photoUrl) async {
    try {
      final userId = currentUserId;
      if (userId == null) return ServiceResult.failure('يجب تسجيل الدخول');
      await _firebase.update(AppConstants.usersCollection, userId, {
        'photoUrl': photoUrl,
      });
      _currentUser = _currentUser?.copyWith(photoUrl: photoUrl);
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

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
        return AppConstants.networkError;
      default:
        return e.message ?? 'حدث خطأ في المصادقة';
    }
  }

  // ==================== إدارة المستخدمين ====================

  Future<ServiceResult<List<UserModel>>> getPendingUsers() async {
    try {
      final result = await _firebase.getAll(
        AppConstants.usersCollection,
        queryBuilder: (ref) => ref
            .where('accountStatus', isEqualTo: AccountStatus.pending)
            .orderBy('createdAt', descending: true),
      );
      if (!result.success) return ServiceResult.failure(result.error!);
      return ServiceResult.success(
        result.data!.docs
            .map((doc) => UserModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<List<UserModel>>> getAllUsers() async {
    try {
      final result = await _firebase.getAll(
        AppConstants.usersCollection,
        queryBuilder: (ref) => ref.orderBy('createdAt', descending: true),
      );
      if (!result.success) return ServiceResult.failure(result.error!);
      return ServiceResult.success(
        result.data!.docs
            .map((doc) => UserModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> approveUser(String userId) async {
    try {
      if (_currentUser == null || !_currentUser!.isAdmin) {
        return ServiceResult.failure(AppConstants.permissionDenied);
      }
      final userResult = await _getUserData(userId);
      await _firebase.update(AppConstants.usersCollection, userId, {
        'accountStatus': AccountStatus.approved,
        'approvedAt': DateTime.now(),
        'approvedBy': _currentUser!.id,
      });
      if (userResult.success) {
        await _audit.logApproveUser(
          userId: userId,
          userName: userResult.data!.name,
        );
      }
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> rejectUser(String userId, String reason) async {
    try {
      if (_currentUser == null || !_currentUser!.isAdmin) {
        return ServiceResult.failure(AppConstants.permissionDenied);
      }
      final userResult = await _getUserData(userId);
      await _firebase.update(AppConstants.usersCollection, userId, {
        'accountStatus': AccountStatus.rejected,
        'rejectionReason': reason,
        'isActive': false,
      });
      if (userResult.success) {
        await _audit.logRejectUser(
          userId: userId,
          userName: userResult.data!.name,
          reason: reason,
        );
      }
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> deactivateUser(String userId) async {
    if (_currentUser == null || !_currentUser!.isAdmin) {
      return ServiceResult.failure(AppConstants.permissionDenied);
    }
    return _firebase.update(AppConstants.usersCollection, userId, {
      'isActive': false,
    });
  }

  Future<ServiceResult<void>> activateUser(String userId) async {
    if (_currentUser == null || !_currentUser!.isAdmin) {
      return ServiceResult.failure(AppConstants.permissionDenied);
    }
    return _firebase.update(AppConstants.usersCollection, userId, {
      'isActive': true,
    });
  }

  Future<ServiceResult<void>> changeUserRole(
    String userId,
    String newRole,
  ) async {
    if (_currentUser == null || !_currentUser!.isAdmin) {
      return ServiceResult.failure(AppConstants.permissionDenied);
    }
    return _firebase.update(AppConstants.usersCollection, userId, {
      'role': newRole,
    });
  }

  Future<ServiceResult<void>> deleteUser(String userId) async {
    if (_currentUser == null || !_currentUser!.isAdmin) {
      return ServiceResult.failure(AppConstants.permissionDenied);
    }
    return _firebase.delete(AppConstants.usersCollection, userId);
  }

  Stream<List<UserModel>> streamPendingUsers() {
    return _firebase
        .streamCollection(
          AppConstants.usersCollection,
          queryBuilder: (ref) => ref
              .where('accountStatus', isEqualTo: AccountStatus.pending)
              .orderBy('createdAt', descending: true),
        )
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // للتوافق
  Future<ServiceResult<UserModel>> signIn(String email, String password) =>
      signInWithEmail(email, password);
  Future<ServiceResult<UserModel>> signUp({
    required String email,
    required String password,
    required String name,
    String role = AppConstants.roleEmployee,
  }) =>
      signUpWithEmail(email: email, password: password, name: name, role: role);
}
