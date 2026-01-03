import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  // الحصول على جميع المستخدمين
  Future<List<User>> getAllUsers() => select(users).get();

  // الحصول على المستخدمين النشطين
  Future<List<User>> getActiveUsers() {
    return (select(users)..where((u) => u.isActive.equals(true))).get();
  }

  // الحصول على مستخدم بواسطة المعرف
  Future<User?> getUserById(int id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  // الحصول على مستخدم بواسطة اسم المستخدم
  Future<User?> getUserByUsername(String username) {
    return (select(users)..where((u) => u.username.equals(username)))
        .getSingleOrNull();
  }

  // التحقق من بيانات الدخول
  Future<User?> authenticate(String username, String password) {
    return (select(users)
          ..where((u) =>
              u.username.equals(username) &
              u.password.equals(password) &
              u.isActive.equals(true)))
        .getSingleOrNull();
  }

  // إضافة مستخدم جديد
  Future<int> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  // تحديث مستخدم
  Future<bool> updateUser(User user) {
    return update(users).replace(user);
  }

  // تحديث كلمة المرور
  Future<int> updatePassword(int userId, String newPassword) {
    return (update(users)..where((u) => u.id.equals(userId))).write(
        UsersCompanion(
            password: Value(newPassword), updatedAt: Value(DateTime.now())));
  }

  // تحديث حالة المستخدم
  Future<int> toggleUserStatus(int userId, bool isActive) {
    return (update(users)..where((u) => u.id.equals(userId))).write(
        UsersCompanion(
            isActive: Value(isActive), updatedAt: Value(DateTime.now())));
  }

  // تحديث آخر تسجيل دخول
  Future<int> updateLastLogin(int userId) {
    return (update(users)..where((u) => u.id.equals(userId)))
        .write(UsersCompanion(lastLoginAt: Value(DateTime.now())));
  }

  // حذف مستخدم
  Future<int> deleteUser(int id) {
    return (delete(users)..where((u) => u.id.equals(id))).go();
  }

  // البحث عن مستخدمين
  Future<List<User>> searchUsers(String query) {
    return (select(users)
          ..where((u) => u.name.like('%$query%') | u.username.like('%$query%')))
        .get();
  }

  // الحصول على مستخدمين حسب الدور
  Future<List<User>> getUsersByRole(String role) {
    return (select(users)..where((u) => u.role.equals(role))).get();
  }
}
