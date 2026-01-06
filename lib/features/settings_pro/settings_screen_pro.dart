// ═══════════════════════════════════════════════════════════════════════════
// Settings Screen Pro - Enterprise Accounting Design
// App Settings and Configuration with Professional Touch
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/di/injection.dart';
import '../../core/services/backup_service.dart';
import '../../core/widgets/widgets.dart';

class SettingsScreenPro extends ConsumerStatefulWidget {
  const SettingsScreenPro({super.key});

  @override
  ConsumerState<SettingsScreenPro> createState() => _SettingsScreenProState();
}

class _SettingsScreenProState extends ConsumerState<SettingsScreenPro> {
  bool _notifications = true;
  String _appVersion = '';
  String _buildNumber = '';
  DateTime? _lastBackupDate;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _loadLastBackupDate();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _loadLastBackupDate() async {
    final backupService = getIt<BackupService>();
    final lastBackupTime = await backupService.getLastBackupTime();
    setState(() {
      _lastBackupDate = lastBackupTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProAppBar.noBack(title: 'الإعدادات'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════════════
            // Business Info
            // ═══════════════════════════════════════════════════════════════
            _buildBusinessCard(),

            // ═══════════════════════════════════════════════════════════════
            // App Settings
            // ═══════════════════════════════════════════════════════════════
            _buildSectionTitle('إعدادات التطبيق'),
            _buildSettingsTile(
              icon: Icons.currency_exchange_rounded,
              title: 'سعر الصرف',
              subtitle: 'إدارة سعر صرف الدولار',
              onTap: () => context.push('/settings/exchange-rate'),
            ),

            // ═══════════════════════════════════════════════════════════════
            // Notifications
            // ═══════════════════════════════════════════════════════════════
            _buildSectionTitle('الإشعارات'),
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              title: 'الإشعارات',
              subtitle: 'تلقي إشعارات التنبيهات',
              trailing: Switch.adaptive(
                value: _notifications,
                onChanged: (value) => setState(() => _notifications = value),
                activeTrackColor: AppColors.secondary.withValues(alpha: 0.5),
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.secondary;
                  }
                  return null;
                }),
              ),
            ),
            _buildSettingsTile(
              icon: Icons.inventory_2_outlined,
              title: 'تنبيهات المخزون',
              subtitle: 'تنبيه عند انخفاض المخزون',
              onTap: () {},
            ),

            // ═══════════════════════════════════════════════════════════════
            // Data & Backup
            // ═══════════════════════════════════════════════════════════════
            _buildSectionTitle('البيانات والنسخ الاحتياطي'),
            _buildSettingsTile(
              icon: Icons.cloud_upload_outlined,
              title: 'النسخ الاحتياطي',
              subtitle: _lastBackupDate != null
                  ? 'آخر نسخة: ${_formatDate(_lastBackupDate!)}'
                  : 'لم يتم إنشاء نسخة احتياطية',
              onTap: () => context.push('/backup'),
            ),

            // ═══════════════════════════════════════════════════════════════
            // Invoice Settings
            // ═══════════════════════════════════════════════════════════════
            _buildSectionTitle('إعدادات الفواتير'),
            _buildSettingsTile(
              icon: Icons.print_rounded,
              title: 'إعدادات الطباعة',
              subtitle: 'إعداد الطابعة وتخصيص الفاتورة',
              onTap: () => context.push('/settings/print'),
            ),

            // ═══════════════════════════════════════════════════════════════
            // Logout
            // ═══════════════════════════════════════════════════════════════
            SizedBox(height: AppSpacing.lg),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: OutlinedButton(
                onPressed: () => _showLogoutDialog(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'تسجيل الخروج',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Enterprise: Square icon container
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مؤسسة الهور التجارية',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'الباقة المميزة',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.o87,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.edit_outlined,
                  color: Colors.white.o87,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.muted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white.o87,
                  size: 16.sp,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Hoor Manager',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.o87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.light,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'v$_appVersion${_buildNumber.isNotEmpty ? ' ($_buildNumber)' : ''}',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: AppIconSize.sm),
      ),
      title: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textTertiary,
          ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'اليوم ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'أمس ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showLogoutDialog() async {
    final confirm = await showProConfirmDialog(
      context: context,
      title: 'تسجيل الخروج',
      message: 'هل أنت متأكد من تسجيل الخروج؟',
      icon: Icons.logout_rounded,
      isDanger: true,
      confirmText: 'تسجيل الخروج',
    );
    if (confirm == true && mounted) {
      // عرض رسالة نجاح
      ProSnackbar.success(context, 'تم تسجيل الخروج بنجاح');
      // العودة للشاشة الرئيسية
      context.go('/');
    }
  }
}
