import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/backup_provider.dart';

/// شاشة النسخ الاحتياطي
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('النسخ الاحتياطي'),
      ),
      body: backupState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // معلومات النسخ الاحتياطي
                _BackupInfoCard(
                  lastBackup: backupState.lastBackupDate,
                  backupSize: backupState.lastBackupSize,
                ),

                SizedBox(height: 16.h),

                // إنشاء نسخة احتياطية
                _ActionCard(
                  title: 'إنشاء نسخة احتياطية',
                  description: 'حفظ نسخة من جميع البيانات',
                  icon: Icons.backup,
                  color: AppColors.primary,
                  onTap: () => _createBackup(context, ref),
                ),

                SizedBox(height: 12.h),

                // استعادة من نسخة
                _ActionCard(
                  title: 'استعادة البيانات',
                  description: 'استعادة من نسخة احتياطية سابقة',
                  icon: Icons.restore,
                  color: AppColors.warning,
                  onTap: () => _restoreBackup(context, ref),
                ),

                SizedBox(height: 12.h),

                // مشاركة النسخة
                _ActionCard(
                  title: 'مشاركة النسخة',
                  description: 'إرسال النسخة الاحتياطية عبر التطبيقات',
                  icon: Icons.share,
                  color: AppColors.info,
                  onTap: () => _shareBackup(context, ref),
                ),

                SizedBox(height: 24.h),

                // قائمة النسخ الاحتياطية
                Text(
                  'النسخ الاحتياطية المحفوظة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                SizedBox(height: 12.h),

                if (backupState.backups.isEmpty)
                  _EmptyBackupsWidget()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: backupState.backups.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final backup = backupState.backups[index];
                      return _BackupListItem(
                        backup: backup,
                        onRestore: () => _restoreFromFile(context, ref, backup),
                        onDelete: () => _deleteBackup(context, ref, backup),
                        onShare: () => _shareBackupFile(context, backup),
                      );
                    },
                  ),

                SizedBox(height: 24.h),

                // إعدادات النسخ التلقائي
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'النسخ الاحتياطي التلقائي',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(height: 12.h),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('تفعيل النسخ التلقائي'),
                          subtitle: const Text('نسخ احتياطي يومي تلقائي'),
                          value: backupState.autoBackupEnabled,
                          onChanged: (value) {
                            ref
                                .read(backupProvider.notifier)
                                .setAutoBackup(value);
                          },
                        ),
                        if (backupState.autoBackupEnabled) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('وقت النسخ'),
                            subtitle: Text(
                              backupState.autoBackupTime ?? '02:00 ص',
                            ),
                            trailing: const Icon(Icons.chevron_left),
                            onTap: () => _selectBackupTime(context, ref),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('الاحتفاظ بالنسخ'),
                            subtitle: Text(
                              '${backupState.keepBackupsCount} نسخ',
                            ),
                            trailing: const Icon(Icons.chevron_left),
                            onTap: () => _selectKeepCount(context, ref),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // تحذير
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border:
                        Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: AppColors.warning),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'يُنصح بإجراء نسخ احتياطي دوري للبيانات وحفظها في مكان آمن.',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 12.sp,
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

  Future<void> _createBackup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء نسخة احتياطية'),
        content: const Text(
            'سيتم إنشاء نسخة احتياطية من جميع البيانات. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('جاري إنشاء النسخة الاحتياطية...'),
            ],
          ),
        ),
      );

      try {
        await ref.read(backupProvider.notifier).createBackup();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء النسخة الاحتياطية بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إنشاء النسخة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استعادة البيانات'),
        icon: Icon(Icons.warning_amber, color: AppColors.warning, size: 48),
        content: const Text(
          'تحذير: سيتم استبدال جميع البيانات الحالية بالبيانات من النسخة الاحتياطية. هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('استعادة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: فتح منتقي الملفات واختيار ملف النسخة
      try {
        await ref.read(backupProvider.notifier).restoreFromFile(null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت استعادة البيانات بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في استعادة البيانات: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _shareBackup(BuildContext context, WidgetRef ref) async {
    try {
      final path = await ref.read(backupProvider.notifier).createBackup();
      if (path != null) {
        await Share.shareXFiles([XFile(path)],
            text: 'نسخة احتياطية - متجر حور');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في مشاركة النسخة: $e')),
      );
    }
  }

  Future<void> _restoreFromFile(
      BuildContext context, WidgetRef ref, BackupFile backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استعادة من نسخة'),
        icon: Icon(Icons.warning_amber, color: AppColors.warning, size: 48),
        content: Text(
          'سيتم استعادة البيانات من نسخة ${DateFormat('yyyy/MM/dd - HH:mm').format(backup.date)}.\n\nتحذير: سيتم استبدال جميع البيانات الحالية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('استعادة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('جاري استعادة البيانات...'),
            ],
          ),
        ),
      );

      try {
        await ref.read(backupProvider.notifier).restoreFromFile(backup.path);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت استعادة البيانات بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في استعادة البيانات: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteBackup(
      BuildContext context, WidgetRef ref, BackupFile backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف النسخة'),
        content: const Text('هل تريد حذف هذه النسخة الاحتياطية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(backupProvider.notifier).deleteBackup(backup.path);
    }
  }

  Future<void> _shareBackupFile(BuildContext context, BackupFile backup) async {
    try {
      await Share.shareXFiles([XFile(backup.path)],
          text: 'نسخة احتياطية - متجر حور');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في مشاركة النسخة: $e')),
      );
    }
  }

  Future<void> _selectBackupTime(BuildContext context, WidgetRef ref) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 2, minute: 0),
    );

    if (time != null) {
      ref.read(backupProvider.notifier).setAutoBackupTime(time.format(context));
    }
  }

  Future<void> _selectKeepCount(BuildContext context, WidgetRef ref) async {
    final count = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عدد النسخ المحفوظة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [3, 5, 7, 10, 15, 30].map((count) {
            return ListTile(
              title: Text('$count نسخ'),
              onTap: () => Navigator.pop(context, count),
            );
          }).toList(),
        ),
      ),
    );

    if (count != null) {
      ref.read(backupProvider.notifier).setKeepBackupsCount(count);
    }
  }
}

/// بطاقة معلومات النسخ الاحتياطي
class _BackupInfoCard extends StatelessWidget {
  final DateTime? lastBackup;
  final String? backupSize;

  const _BackupInfoCard({
    this.lastBackup,
    this.backupSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.backup, color: AppColors.primary, size: 32.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'آخر نسخة احتياطية',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    lastBackup != null
                        ? DateFormat('yyyy/MM/dd - HH:mm').format(lastBackup!)
                        : 'لم يتم إنشاء نسخة بعد',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (backupSize != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'حجم النسخة: $backupSize',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة إجراء
class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// عنصر قائمة النسخ الاحتياطية
class _BackupListItem extends StatelessWidget {
  final BackupFile backup;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _BackupListItem({
    required this.backup,
    required this.onRestore,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.file_copy, color: AppColors.primary),
        ),
        title: Text(
          DateFormat('yyyy/MM/dd - HH:mm').format(backup.date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(backup.size),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onRestore,
              child: const ListTile(
                leading: Icon(Icons.restore),
                title: Text('استعادة'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              onTap: onShare,
              child: const ListTile(
                leading: Icon(Icons.share),
                title: Text('مشاركة'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text('حذف', style: TextStyle(color: AppColors.error)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ويدجت عند عدم وجود نسخ
class _EmptyBackupsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.backup_outlined,
            size: 48.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد نسخ احتياطية',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'قم بإنشاء أول نسخة احتياطية للحفاظ على بياناتك',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
