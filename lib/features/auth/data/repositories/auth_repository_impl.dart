import 'package:hive/hive.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// تنفيذ مستودع المصادقة
class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _database;
  final Box _settingsBox;

  static const String _currentUserKey = 'current_user_id';

  AuthRepositoryImpl(this._database, this._settingsBox);

  @override
  Future<UserEntity?> login(String username, String password) async {
    final user = await _database.usersDao.authenticate(username, password);

    if (user != null) {
      // حفظ معرف المستخدم الحالي
      await _settingsBox.put(_currentUserKey, user.id);

      // تحديث آخر تسجيل دخول
      await _database.usersDao.updateLastLogin(user.id);

      return _mapUserToEntity(user);
    }

    return null;
  }

  @override
  Future<void> logout() async {
    await _settingsBox.delete(_currentUserKey);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userId = _settingsBox.get(_currentUserKey) as int?;

    if (userId != null) {
      final user = await _database.usersDao.getUserById(userId);
      if (user != null && user.isActive) {
        return _mapUserToEntity(user);
      }
    }

    return null;
  }

  @override
  Future<bool> changePassword(
      int userId, String oldPassword, String newPassword) async {
    final user = await _database.usersDao.getUserById(userId);

    if (user != null && user.password == oldPassword) {
      await _database.usersDao.updatePassword(userId, newPassword);
      return true;
    }

    return false;
  }

  @override
  Future<bool> isSessionValid() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// تحويل من نموذج قاعدة البيانات إلى كيان
  UserEntity _mapUserToEntity(User user) {
    return UserEntity(
      id: user.id,
      name: user.name,
      username: user.username,
      role: UserRole.fromString(user.role),
      phone: user.phone,
      email: user.email,
      isActive: user.isActive,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }
}
