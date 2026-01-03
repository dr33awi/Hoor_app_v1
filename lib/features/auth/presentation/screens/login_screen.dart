import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/auth_provider.dart';

/// شاشة تسجيل الدخول
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).login(
            _usernameController.text.trim(),
            _passwordController.text,
          );

      if (!mounted) return;

      if (success) {
        context.go(AppRoutes.dashboard);
      } else {
        AppSnackBar.showError(context, 'اسم المستخدم أو كلمة المرور غير صحيحة');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'حدث خطأ أثناء تسجيل الدخول');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60.h),

                // الشعار
                Center(
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: AppShadows.lg,
                    ),
                    child: Icon(
                      Icons.store,
                      size: 50.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // اسم التطبيق
                Text(
                  AppConfig.appNameAr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'نظام إدارة المتجر',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),

                SizedBox(height: 48.h),

                // نموذج تسجيل الدخول
                Text(
                  'تسجيل الدخول',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 24.h),

                // اسم المستخدم
                AppTextField(
                  controller: _usernameController,
                  label: 'اسم المستخدم',
                  hint: 'أدخل اسم المستخدم',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم المستخدم';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // كلمة المرور
                AppTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixTap: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onSubmitted: (_) => _login(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 32.h),

                // زر تسجيل الدخول
                AppButton(
                  label: 'تسجيل الدخول',
                  onPressed: _login,
                  isLoading: _isLoading,
                  icon: Icons.login,
                ),

                SizedBox(height: 24.h),

                // معلومات الدخول الافتراضية (للتطوير فقط)
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18.sp, color: AppColors.info),
                          SizedBox(width: 8.w),
                          Text(
                            'بيانات الدخول الافتراضية',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.info,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'اسم المستخدم: admin',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'كلمة المرور: admin123',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // الإصدار
                Center(
                  child: Text(
                    'الإصدار ${AppConfig.version}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
