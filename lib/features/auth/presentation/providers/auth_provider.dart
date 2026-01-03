import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/di/injection.dart';

/// حالة المصادقة
class AuthState {
  final UserEntity? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// مزود حالة المصادقة
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(getIt<AuthRepository>());
});

/// مزود المستخدم الحالي
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});

/// مدير حالة المصادقة
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// التحقق من حالة المصادقة عند البدء
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// تسجيل الدخول
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _repository.login(username, password);

      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'اسم المستخدم أو كلمة المرور غير صحيحة',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  /// تغيير كلمة المرور
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (state.user == null) return false;

    try {
      return await _repository.changePassword(
        state.user!.id,
        oldPassword,
        newPassword,
      );
    } catch (e) {
      return false;
    }
  }

  /// التحقق من الصلاحية
  bool hasPermission(String permission) {
    if (state.user == null) return false;
    return state.user!.hasPermission(permission);
  }

  /// التحقق من الدور
  bool hasRole(UserRole role) {
    if (state.user == null) return false;
    return state.user!.role == role;
  }

  /// هل المستخدم مدير؟
  bool get isManager => hasRole(UserRole.manager);

  /// هل المستخدم كاشير؟
  bool get isCashier => hasRole(UserRole.cashier);

  /// هل المستخدم محاسب؟
  bool get isAccountant => hasRole(UserRole.accountant);
}
