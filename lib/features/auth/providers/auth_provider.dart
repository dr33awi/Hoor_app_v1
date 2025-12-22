// lib/features/auth/providers/auth_provider.dart
// مزود حالة المصادقة

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/logger_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  String? get userId => _user?.id;
  String? get userName => _user?.name;

  AuthProvider() {
    _init();
  }

  /// تهيئة المزود
  Future<void> _init() async {
    AppLogger.startOperation('تهيئة AuthProvider');
    _isLoading = true;
    notifyListeners();

    // تهيئة Firebase
    await _firebaseService.initialize();

    // الاستماع لتغييرات حالة المصادقة
    _authService.authStateChanges.listen(_onAuthStateChanged);
    AppLogger.endOperation('تهيئة AuthProvider');
  }

  /// معالجة تغيير حالة المصادقة
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // جلب بيانات المستخدم
    final result = await _authService.loadCurrentUser();
    if (result.success) {
      _user = result.data;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تسجيل الدخول
  Future<bool> signIn(String email, String password) async {
    AppLogger.userAction('محاولة تسجيل دخول', details: {'email': email});
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.signIn(email, password);

    if (result.success) {
      _user = result.data;
      _error = null;
      AppLogger.i('✅ تم تسجيل الدخول بنجاح: ${_user?.name}');
    } else {
      _error = result.error;
      AppLogger.w('❌ فشل تسجيل الدخول', error: result.error);
    }

    _isLoading = false;
    notifyListeners();
    return result.success;
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    AppLogger.userAction('تسجيل خروج', details: {'user': _user?.name});
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _user = null;

    AppLogger.i('✅ تم تسجيل الخروج');
    _isLoading = false;
    notifyListeners();
  }

  /// إعادة تعيين كلمة المرور
  Future<bool> resetPassword(String email) async {
    _error = null;
    final result = await _authService.resetPassword(email);

    if (!result.success) {
      _error = result.error;
    }

    notifyListeners();
    return result.success;
  }

  /// تغيير كلمة المرور
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _error = null;
    final result = await _authService.changePassword(
      currentPassword,
      newPassword,
    );

    if (!result.success) {
      _error = result.error;
    }

    notifyListeners();
    return result.success;
  }

  /// إنشاء مستخدم جديد (للمدير فقط)
  Future<bool> createUser({
    required String email,
    required String password,
    required String name,
    String role = 'employee',
  }) async {
    if (!isAdmin) {
      _error = 'غير مصرح لك بهذه العملية';
      notifyListeners();
      return false;
    }

    _error = null;
    final result = await _authService.signUp(
      email: email,
      password: password,
      name: name,
      role: role,
    );

    if (!result.success) {
      _error = result.error;
    }

    notifyListeners();
    return result.success;
  }

  /// مسح الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
