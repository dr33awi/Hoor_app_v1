import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/users_provider.dart';

/// شاشة إدارة المستخدمين
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider.notifier).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showUserForm(context),
            tooltip: 'إضافة مستخدم',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserForm(context),
        icon: const Icon(Icons.person_add),
        label: const Text('مستخدم جديد'),
      ),
      body: Column(
        children: [
          // إحصائيات
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                _StatChip(
                  label: 'إجمالي المستخدمين',
                  value: '${state.users.length}',
                  icon: Icons.people,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                _StatChip(
                  label: 'المستخدمون النشطون',
                  value: '${state.activeUsersCount}',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ],
            ),
          ),

          // القائمة
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.users.isEmpty
                    ? _EmptyWidget(onAdd: () => _showUserForm(context))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: state.users.length,
                        itemBuilder: (context, index) {
                          final user = state.users[index];
                          return _UserCard(
                            user: user,
                            onTap: () => _showUserDetails(context, user),
                            onEdit: () => _showUserForm(context, user: user),
                            onDelete: () => _confirmDelete(context, user),
                            onToggleStatus: () {
                              ref
                                  .read(usersProvider.notifier)
                                  .toggleUserStatus(user.id);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showUserForm(BuildContext context, {UserItem? user}) {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.name);
    final usernameController = TextEditingController(text: user?.username);
    final passwordController = TextEditingController();
    final phoneController = TextEditingController(text: user?.phone);
    UserRole selectedRole = user?.role ?? UserRole.cashier;
    bool isActive = user?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.w,
            right: 16.w,
            top: 16.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'تعديل المستخدم' : 'مستخدم جديد',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // الاسم
                AppTextField(
                  controller: nameController,
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسم المستخدم',
                  prefixIcon: Icons.person,
                ),
                SizedBox(height: 12.h),

                // اسم المستخدم
                AppTextField(
                  controller: usernameController,
                  label: 'اسم الدخول',
                  hint: 'أدخل اسم الدخول',
                  prefixIcon: Icons.account_circle,
                  enabled: !isEditing, // لا يمكن تغيير اسم الدخول
                ),
                SizedBox(height: 12.h),

                // كلمة المرور
                AppTextField(
                  controller: passwordController,
                  label: isEditing
                      ? 'كلمة المرور الجديدة (اختياري)'
                      : 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                ),
                SizedBox(height: 12.h),

                // الهاتف
                AppTextField(
                  controller: phoneController,
                  label: 'رقم الهاتف (اختياري)',
                  hint: '05xxxxxxxx',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.h),

                // الصلاحية
                Text(
                  'الصلاحية',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: UserRole.values.map((role) {
                    return ChoiceChip(
                      label: Text(_getRoleName(role)),
                      selected: selectedRole == role,
                      onSelected: (_) {
                        setModalState(() => selectedRole = role);
                      },
                    );
                  }).toList(),
                ),

                SizedBox(height: 16.h),

                // الحالة
                SwitchListTile(
                  title: const Text('حساب نشط'),
                  subtitle: Text(
                    isActive
                        ? 'المستخدم يمكنه الدخول'
                        : 'المستخدم لا يمكنه الدخول',
                    style: TextStyle(
                      color: isActive ? AppColors.success : AppColors.error,
                      fontSize: 12.sp,
                    ),
                  ),
                  value: isActive,
                  onChanged: (value) {
                    setModalState(() => isActive = value);
                  },
                ),

                SizedBox(height: 24.h),

                // زر الحفظ
                AppButton(
                  text: isEditing ? 'حفظ التعديلات' : 'إضافة المستخدم',
                  onPressed: () {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إدخال الاسم')),
                      );
                      return;
                    }

                    if (usernameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إدخال اسم الدخول')),
                      );
                      return;
                    }

                    if (!isEditing && passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إدخال كلمة المرور')),
                      );
                      return;
                    }

                    if (isEditing) {
                      ref.read(usersProvider.notifier).updateUser(
                            id: user!.id,
                            name: nameController.text.trim(),
                            password: passwordController.text.isNotEmpty
                                ? passwordController.text
                                : null,
                            phone: phoneController.text.trim(),
                            role: selectedRole,
                            isActive: isActive,
                          );
                    } else {
                      ref.read(usersProvider.notifier).addUser(
                            name: nameController.text.trim(),
                            username: usernameController.text.trim(),
                            password: passwordController.text,
                            phone: phoneController.text.trim(),
                            role: selectedRole,
                          );
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing
                            ? 'تم تحديث المستخدم بنجاح'
                            : 'تم إضافة المستخدم بنجاح'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  isFullWidth: true,
                  icon: Icons.save,
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context, UserItem user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40.sp,
                color: _getRoleColor(user.role),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '@${user.username}',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _getRoleName(user.role),
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  user.isActive ? Icons.check_circle : Icons.cancel,
                  color: user.isActive ? AppColors.success : AppColors.error,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  user.isActive ? 'نشط' : 'غير نشط',
                  style: TextStyle(
                    color: user.isActive ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            if (user.phone != null && user.phone!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone,
                      size: 16.sp, color: AppColors.textSecondary),
                  SizedBox(width: 4.w),
                  Text(
                    user.phone!,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
            SizedBox(height: 8.h),
            Text(
              'آخر تسجيل دخول: ${user.lastLogin != null ? DateFormat('yyyy/MM/dd HH:mm').format(user.lastLogin!) : 'لم يسجل دخول'}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showUserForm(context, user: user);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل'),
                ),
                SizedBox(width: 12.w),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(context, user);
                  },
                  icon: Icon(Icons.delete, color: AppColors.error),
                  label: Text('حذف', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserItem user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: Text('هل أنت متأكد من حذف "${user.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              ref.read(usersProvider.notifier).deleteUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف المستخدم'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.manager:
        return 'مدير';
      case UserRole.cashier:
        return 'كاشير';
      case UserRole.inventory:
        return 'أمين مخزن';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.manager:
        return AppColors.primary;
      case UserRole.cashier:
        return AppColors.success;
      case UserRole.inventory:
        return AppColors.warning;
    }
  }
}

/// شريحة إحصائية
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة المستخدم
class _UserCard extends StatelessWidget {
  final UserItem user;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: _getRoleColor(user.role),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: user.isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (!user.isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'معطّل',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        _getRoleName(user.role),
                        style: TextStyle(
                          color: _getRoleColor(user.role),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'toggle':
                      onToggleStatus();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20.sp),
                        SizedBox(width: 8.w),
                        const Text('تعديل'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          user.isActive ? Icons.block : Icons.check_circle,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(user.isActive ? 'تعطيل' : 'تفعيل'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20.sp, color: AppColors.error),
                        SizedBox(width: 8.w),
                        Text('حذف', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.manager:
        return 'مدير';
      case UserRole.cashier:
        return 'كاشير';
      case UserRole.inventory:
        return 'أمين مخزن';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.manager:
        return AppColors.primary;
      case UserRole.cashier:
        return AppColors.success;
      case UserRole.inventory:
        return AppColors.warning;
    }
  }
}

/// ويدجت فارغة
class _EmptyWidget extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyWidget({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد مستخدمون',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'قم بإضافة مستخدمين للنظام',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          AppButton(
            text: 'إضافة مستخدم',
            onPressed: onAdd,
            icon: Icons.person_add,
          ),
        ],
      ),
    );
  }
}
