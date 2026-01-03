import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/users_dao.dart';
import '../../../../core/database/database.dart';

/// صلاحية المستخدم
enum UserRole { admin, manager, cashier, inventory }

/// عنصر مستخدم
class UserItem {
  final int id;
  final String name;
  final String username;
  final String? phone;
  final UserRole role;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;

  UserItem({
    required this.id,
    required this.name,
    required this.username,
    this.phone,
    required this.role,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
  });
}

/// حالة المستخدمين
class UsersState {
  final List<UserItem> users;
  final bool isLoading;

  UsersState({
    this.users = const [],
    this.isLoading = false,
  });

  UsersState copyWith({
    List<UserItem>? users,
    bool? isLoading,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get activeUsersCount => users.where((u) => u.isActive).length;
}

/// مزود المستخدمين
class UsersNotifier extends StateNotifier<UsersState> {
  final UsersDao _dao;

  UsersNotifier(this._dao) : super(UsersState());

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true);

    try {
      final dbUsers = await _dao.getAllUsers();
      final users = dbUsers.map(_mapUser).toList();

      state = state.copyWith(
        users: users,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addUser({
    required String name,
    required String username,
    required String password,
    String? phone,
    required UserRole role,
  }) async {
    try {
      // تشفير كلمة المرور (بسيط للتوضيح)
      final hashedPassword = _hashPassword(password);

      final companion = UsersCompanion.insert(
        username: username,
        password: hashedPassword,
        name: name,
        role: _roleToString(role),
        isActive: const drift.Value(true),
        phone: drift.Value(phone),
        createdAt: drift.Value(DateTime.now()),
      );

      final id = await _dao.insertUser(companion);

      final newUser = UserItem(
        id: id,
        name: name,
        username: username,
        phone: phone,
        role: role,
        isActive: true,
        lastLogin: null,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        users: [...state.users, newUser],
      );
    } catch (e) {
      // معالجة الخطأ
    }
  }

  Future<void> updateUser({
    required int id,
    required String name,
    String? password,
    String? phone,
    required UserRole role,
    required bool isActive,
  }) async {
    try {
      final existingUser = await _dao.getUserById(id);
      if (existingUser == null) return;

      final updatedUser = existingUser.copyWith(
        name: name,
        password:
            password != null ? _hashPassword(password) : existingUser.password,
        phone: drift.Value(phone),
        role: _roleToString(role),
        isActive: isActive,
      );

      await _dao.updateUser(updatedUser);

      state = state.copyWith(
        users: state.users.map((u) {
          if (u.id == id) {
            return UserItem(
              id: u.id,
              name: name,
              username: u.username,
              phone: phone,
              role: role,
              isActive: isActive,
              lastLogin: u.lastLogin,
              createdAt: u.createdAt,
            );
          }
          return u;
        }).toList(),
      );
    } catch (e) {
      // معالجة الخطأ
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dao.deleteUser(id);
      state = state.copyWith(
        users: state.users.where((u) => u.id != id).toList(),
      );
    } catch (e) {
      // معالجة الخطأ
    }
  }

  Future<void> toggleUserStatus(int id) async {
    try {
      final user = state.users.firstWhere((u) => u.id == id);
      await _dao.toggleUserStatus(id, !user.isActive);

      state = state.copyWith(
        users: state.users.map((u) {
          if (u.id == id) {
            return UserItem(
              id: u.id,
              name: u.name,
              username: u.username,
              phone: u.phone,
              role: u.role,
              isActive: !u.isActive,
              lastLogin: u.lastLogin,
              createdAt: u.createdAt,
            );
          }
          return u;
        }).toList(),
      );
    } catch (e) {
      // معالجة الخطأ
    }
  }

  UserItem _mapUser(User u) {
    return UserItem(
      id: u.id,
      name: u.name,
      username: u.username,
      phone: u.phone,
      role: _stringToRole(u.role),
      isActive: u.isActive,
      lastLogin: u.lastLoginAt,
      createdAt: u.createdAt ?? DateTime.now(),
    );
  }

  UserRole _stringToRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'inventory':
        return UserRole.inventory;
      case 'cashier':
      default:
        return UserRole.cashier;
    }
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.manager:
        return 'manager';
      case UserRole.cashier:
        return 'cashier';
      case UserRole.inventory:
        return 'inventory';
    }
  }

  String _hashPassword(String password) {
    // في التطبيق الحقيقي استخدم تشفير قوي مثل bcrypt
    // هنا نستخدم تشفير بسيط للتوضيح
    return password.codeUnits.map((c) => c.toRadixString(16)).join();
  }
}

/// مزود المستخدمين
final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final dao = GetIt.instance<UsersDao>();
  return UsersNotifier(dao);
});
