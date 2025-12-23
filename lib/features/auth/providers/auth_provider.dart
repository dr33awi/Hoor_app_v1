// lib/features/auth/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/logger_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _error;
  String? _errorCode;
  String? _pendingVerificationEmail;
  bool _needsEmailVerification = false;
  StreamSubscription<User?>? _authSubscription;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorCode => _errorCode;
  String? get pendingVerificationEmail => _pendingVerificationEmail;
  bool get needsEmailVerification => _needsEmailVerification;
  bool get isAuthenticated => _currentUser != null && _currentUser!.isApproved;
  bool get isAdmin => _currentUser?.role == 'admin';
  String? get userName => _currentUser?.name;
  String? get userPhoto => _currentUser?.photoUrl;
  bool get isGoogleUser => _currentUser?.isGoogleUser ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authSubscription = _firebaseAuth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUser = null;
        _authService.setCurrentUser(null);
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  /// التحقق من حالة المصادقة
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUser = null;
      }
    } catch (e) {
      AppLogger.e('Error checking auth status', error: e);
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تحميل بيانات المستخدم
  Future<void> _loadUserData(String uid) async {
    try {
      final result = await _authService.getUserById(uid);
      if (result.success && result.data != null) {
        _currentUser = result.data;
        _authService.setCurrentUser(_currentUser);

        // التحقق من حالة الحساب
        if (_currentUser!.status == 'pending') {
          _errorCode = 'account-pending';
        } else if (_currentUser!.status == 'rejected') {
          _errorCode = 'account-rejected';
        } else if (!_currentUser!.isActive) {
          _errorCode = 'account-disabled';
        } else {
          _errorCode = null;
        }
      } else {
        // إنشاء مستخدم جديد
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          _currentUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'مستخدم',
            role: 'employee',
            status: 'pending',
            isActive: true,
            createdAt: DateTime.now(),
          );
          await _authService.createOrUpdateUser(_currentUser!);
          _authService.setCurrentUser(_currentUser);
        }
      }
    } catch (e) {
      AppLogger.e('Error loading user data', error: e);
    }
  }

  /// تسجيل الدخول بالبريد وكلمة المرور
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithEmail(email, password);
      if (result.success) {
        await _loadUserData(_firebaseAuth.currentUser!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.error;
        _errorCode = _getErrorCode(result.error);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تسجيل الدخول';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الدخول بـ Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();
      if (result.success) {
        await _loadUserData(_firebaseAuth.currentUser!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تسجيل الدخول بـ Google';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// إنشاء حساب جديد (signUp)
  Future<bool> signUp(String email, String password, String name) async {
    return signUpWithEmail(email, password, name);
  }

  /// إنشاء حساب جديد (signUpWithEmail)
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      final result = await _authService.signUp(email, password, name);
      if (result.success) {
        _pendingVerificationEmail = email;
        await _loadUserData(_firebaseAuth.currentUser!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.error;
        _errorCode = _getErrorCode(result.error);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء إنشاء الحساب';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _error = null;
      _errorCode = null;
      _pendingVerificationEmail = null;
      _needsEmailVerification = false;
    } catch (e) {
      AppLogger.e('Error signing out', error: e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// إعادة تعيين كلمة المرور
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.resetPassword(email);
      _isLoading = false;
      if (!result.success) {
        _error = result.error;
      }
      notifyListeners();
      return result.success;
    } catch (e) {
      _error = 'حدث خطأ';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// إعادة إرسال رسالة التحقق
  Future<bool> resendVerificationEmail() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.resendVerificationEmail();
      _isLoading = false;
      notifyListeners();
      return result.success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// التحقق من تأكيد البريد وتسجيل الدخول
  Future<bool> checkVerificationAndLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.checkVerificationAndLogin();
      if (result.success && result.data == true) {
        await _loadUserData(_firebaseAuth.currentUser!.uid);
        _needsEmailVerification = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _needsEmailVerification = true;
        _errorCode = 'email-not-verified';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// مسح حالة التحقق
  void clearVerificationState() {
    _pendingVerificationEmail = null;
    _needsEmailVerification = false;
    _errorCode = null;
    notifyListeners();
  }

  /// مسح الخطأ
  void clearError() {
    _error = null;
    _errorCode = null;
    notifyListeners();
  }

  /// استخراج كود الخطأ من الرسالة
  String? _getErrorCode(String? errorMessage) {
    if (errorMessage == null) return null;
    if (errorMessage.contains('قيد المراجعة')) return 'account-pending';
    if (errorMessage.contains('رفض')) return 'account-rejected';
    if (errorMessage.contains('معطل')) return 'account-disabled';
    return null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
