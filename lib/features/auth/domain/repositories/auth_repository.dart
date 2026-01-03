import '../entities/user_entity.dart';

/// واجهة مستودع المصادقة
abstract class AuthRepository {
  /// تسجيل الدخول
  Future<UserEntity?> login(String username, String password);

  /// تسجيل الخروج
  Future<void> logout();

  /// الحصول على المستخدم الحالي
  Future<UserEntity?> getCurrentUser();

  /// تغيير كلمة المرور
  Future<bool> changePassword(
      int userId, String oldPassword, String newPassword);

  /// التحقق من الجلسة
  Future<bool> isSessionValid();
}
