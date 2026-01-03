import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/settings_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// شاشة الإعدادات
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // معلومات المتجر
          _SettingsSection(
            title: 'معلومات المتجر',
            icon: Icons.store,
            children: [
              _SettingsTile(
                title: 'اسم المتجر',
                subtitle: settings.storeName,
                icon: Icons.badge,
                onTap: () => _editStoreName(context, ref, settings.storeName),
              ),
              _SettingsTile(
                title: 'العنوان',
                subtitle: settings.storeAddress ?? 'لم يتم التحديد',
                icon: Icons.location_on,
                onTap: () =>
                    _editStoreAddress(context, ref, settings.storeAddress),
              ),
              _SettingsTile(
                title: 'رقم الهاتف',
                subtitle: settings.storePhone ?? 'لم يتم التحديد',
                icon: Icons.phone,
                onTap: () => _editStorePhone(context, ref, settings.storePhone),
              ),
              _SettingsTile(
                title: 'الرقم الضريبي',
                subtitle: settings.taxNumber ?? 'لم يتم التحديد',
                icon: Icons.numbers,
                onTap: () => _editTaxNumber(context, ref, settings.taxNumber),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // إعدادات الفواتير
          _SettingsSection(
            title: 'إعدادات الفواتير',
            icon: Icons.receipt_long,
            children: [
              _SettingsTile(
                title: 'نسبة الضريبة',
                subtitle: '${(settings.taxRate * 100).toStringAsFixed(1)}%',
                icon: Icons.percent,
                onTap: () => _editTaxRate(context, ref, settings.taxRate),
              ),
              _SettingsTile(
                title: 'العملة',
                subtitle: settings.currency,
                icon: Icons.attach_money,
                onTap: () => _editCurrency(context, ref, settings.currency),
              ),
              SwitchListTile(
                title: const Text('طباعة تلقائية'),
                subtitle: const Text('طباعة الفاتورة بعد كل عملية بيع'),
                secondary: const Icon(Icons.print),
                value: settings.autoPrint,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setAutoPrint(value);
                },
              ),
              SwitchListTile(
                title: const Text('إظهار الضريبة'),
                subtitle: const Text('إظهار الضريبة في الفاتورة'),
                secondary: const Icon(Icons.visibility),
                value: settings.showTax,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setShowTax(value);
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // إعدادات المخزون
          _SettingsSection(
            title: 'إعدادات المخزون',
            icon: Icons.inventory,
            children: [
              _SettingsTile(
                title: 'الحد الأدنى الافتراضي',
                subtitle: '${settings.defaultMinStock.toInt()} وحدة',
                icon: Icons.warning_amber,
                onTap: () =>
                    _editMinStock(context, ref, settings.defaultMinStock),
              ),
              SwitchListTile(
                title: const Text('تنبيهات المخزون'),
                subtitle: const Text('تنبيه عند انخفاض المخزون'),
                secondary: const Icon(Icons.notifications),
                value: settings.stockAlerts,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setStockAlerts(value);
                },
              ),
              SwitchListTile(
                title: const Text('السماح بالبيع السالب'),
                subtitle: const Text('السماح ببيع منتجات غير متوفرة'),
                secondary: const Icon(Icons.remove_shopping_cart),
                value: settings.allowNegativeStock,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setAllowNegativeStock(value);
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // إعدادات العرض
          _SettingsSection(
            title: 'إعدادات العرض',
            icon: Icons.palette,
            children: [
              SwitchListTile(
                title: const Text('الوضع الداكن'),
                subtitle: const Text('تفعيل المظهر الداكن'),
                secondary: const Icon(Icons.dark_mode),
                value: settings.darkMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setDarkMode(value);
                },
              ),
              _SettingsTile(
                title: 'حجم الخط',
                subtitle: _getFontSizeText(settings.fontSize),
                icon: Icons.format_size,
                onTap: () => _editFontSize(context, ref, settings.fontSize),
              ),
              _SettingsTile(
                title: 'اللغة',
                subtitle: settings.language == 'ar' ? 'العربية' : 'English',
                icon: Icons.language,
                onTap: () => _editLanguage(context, ref, settings.language),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // النسخ الاحتياطي
          _SettingsSection(
            title: 'النسخ الاحتياطي',
            icon: Icons.backup,
            children: [
              _SettingsTile(
                title: 'النسخ الاحتياطي',
                subtitle: 'إنشاء نسخة احتياطية من البيانات',
                icon: Icons.cloud_upload,
                onTap: () => context.push('/settings/backup'),
              ),
              _SettingsTile(
                title: 'استعادة البيانات',
                subtitle: 'استعادة من نسخة احتياطية',
                icon: Icons.cloud_download,
                onTap: () => context.push('/settings/restore'),
              ),
              SwitchListTile(
                title: const Text('نسخ تلقائي'),
                subtitle: const Text('نسخ احتياطي يومي تلقائي'),
                secondary: const Icon(Icons.schedule),
                value: settings.autoBackup,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setAutoBackup(value);
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // الطباعة
          _SettingsSection(
            title: 'إعدادات الطباعة',
            icon: Icons.print,
            children: [
              _SettingsTile(
                title: 'الطابعة',
                subtitle: settings.printerName ?? 'لم يتم التحديد',
                icon: Icons.print,
                onTap: () => _selectPrinter(context, ref),
              ),
              _SettingsTile(
                title: 'حجم الورق',
                subtitle: settings.paperSize,
                icon: Icons.straighten,
                onTap: () => _selectPaperSize(context, ref, settings.paperSize),
              ),
              _SettingsTile(
                title: 'طباعة تجريبية',
                subtitle: 'طباعة صفحة اختبار',
                icon: Icons.print_outlined,
                onTap: () => _printTest(context, ref),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // الأمان
          if (user?.role == 'admin') ...[
            _SettingsSection(
              title: 'الأمان',
              icon: Icons.security,
              children: [
                _SettingsTile(
                  title: 'إدارة المستخدمين',
                  subtitle: 'إضافة وتعديل صلاحيات المستخدمين',
                  icon: Icons.people,
                  onTap: () => context.push('/settings/users'),
                ),
                _SettingsTile(
                  title: 'سجل النشاطات',
                  subtitle: 'عرض سجل العمليات',
                  icon: Icons.history,
                  onTap: () => context.push('/settings/activity-log'),
                ),
                SwitchListTile(
                  title: const Text('قفل التطبيق'),
                  subtitle: const Text('طلب كلمة المرور عند الفتح'),
                  secondary: const Icon(Icons.lock),
                  value: settings.appLock,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setAppLock(value);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],

          // حول التطبيق
          _SettingsSection(
            title: 'حول التطبيق',
            icon: Icons.info,
            children: [
              _SettingsTile(
                title: 'الإصدار',
                subtitle: AppConfig.appVersion,
                icon: Icons.new_releases,
                onTap: null,
              ),
              _SettingsTile(
                title: 'سياسة الخصوصية',
                subtitle: '',
                icon: Icons.privacy_tip,
                onTap: () {
                  // TODO: فتح سياسة الخصوصية
                },
              ),
              _SettingsTile(
                title: 'شروط الاستخدام',
                subtitle: '',
                icon: Icons.description,
                onTap: () {
                  // TODO: فتح شروط الاستخدام
                },
              ),
              _SettingsTile(
                title: 'تواصل معنا',
                subtitle: 'للدعم الفني والاستفسارات',
                icon: Icons.support_agent,
                onTap: () {
                  // TODO: فتح صفحة الدعم
                },
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // تسجيل الخروج
          AppButton(
            text: 'تسجيل الخروج',
            onPressed: () => _logout(context, ref),
            icon: Icons.logout,
            backgroundColor: AppColors.error,
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  String _getFontSizeText(double size) {
    if (size <= 0.9) return 'صغير';
    if (size >= 1.1) return 'كبير';
    return 'عادي';
  }

  void _editStoreName(BuildContext context, WidgetRef ref, String current) {
    _showEditDialog(
      context: context,
      title: 'اسم المتجر',
      initialValue: current,
      onSave: (value) {
        ref.read(settingsProvider.notifier).setStoreName(value);
      },
    );
  }

  void _editStoreAddress(BuildContext context, WidgetRef ref, String? current) {
    _showEditDialog(
      context: context,
      title: 'عنوان المتجر',
      initialValue: current ?? '',
      onSave: (value) {
        ref.read(settingsProvider.notifier).setStoreAddress(value);
      },
    );
  }

  void _editStorePhone(BuildContext context, WidgetRef ref, String? current) {
    _showEditDialog(
      context: context,
      title: 'رقم الهاتف',
      initialValue: current ?? '',
      keyboardType: TextInputType.phone,
      onSave: (value) {
        ref.read(settingsProvider.notifier).setStorePhone(value);
      },
    );
  }

  void _editTaxNumber(BuildContext context, WidgetRef ref, String? current) {
    _showEditDialog(
      context: context,
      title: 'الرقم الضريبي',
      initialValue: current ?? '',
      onSave: (value) {
        ref.read(settingsProvider.notifier).setTaxNumber(value);
      },
    );
  }

  void _editTaxRate(BuildContext context, WidgetRef ref, double current) {
    _showEditDialog(
      context: context,
      title: 'نسبة الضريبة (%)',
      initialValue: (current * 100).toString(),
      keyboardType: TextInputType.number,
      onSave: (value) {
        final rate = double.tryParse(value) ?? 0;
        ref.read(settingsProvider.notifier).setTaxRate(rate / 100);
      },
    );
  }

  void _editCurrency(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر العملة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('ريال سعودي (ر.س)'),
              leading: Radio<String>(
                value: 'ر.س',
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setCurrency(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('دولار أمريكي (\$)'),
              leading: Radio<String>(
                value: '\$',
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setCurrency(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('درهم إماراتي (د.إ)'),
              leading: Radio<String>(
                value: 'د.إ',
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setCurrency(value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editMinStock(BuildContext context, WidgetRef ref, double current) {
    _showEditDialog(
      context: context,
      title: 'الحد الأدنى الافتراضي',
      initialValue: current.toInt().toString(),
      keyboardType: TextInputType.number,
      onSave: (value) {
        final stock = double.tryParse(value) ?? 0;
        ref.read(settingsProvider.notifier).setDefaultMinStock(stock);
      },
    );
  }

  void _editFontSize(BuildContext context, WidgetRef ref, double current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حجم الخط'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('صغير'),
              leading: Radio<double>(
                value: 0.9,
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setFontSize(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('عادي'),
              leading: Radio<double>(
                value: 1.0,
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setFontSize(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('كبير'),
              leading: Radio<double>(
                value: 1.1,
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setFontSize(value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editLanguage(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('العربية'),
              leading: Radio<String>(
                value: 'ar',
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPrinter(BuildContext context, WidgetRef ref) {
    // TODO: عرض قائمة الطابعات المتاحة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري البحث عن الطابعات...')),
    );
  }

  void _selectPaperSize(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حجم الورق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('58mm'),
              leading: Radio<String>(
                value: '58mm',
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setPaperSize(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('80mm'),
              leading: Radio<String>(
                value: '80mm',
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setPaperSize(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('A4'),
              leading: Radio<String>(
                value: 'A4',
                groupValue: current,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setPaperSize(value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _printTest(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري طباعة صفحة الاختبار...')),
    );
    // TODO: طباعة صفحة اختبار
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من التطبيق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child:
                Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

/// قسم الإعدادات
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          ...children,
        ],
      ),
    );
  }
}

/// عنصر إعداد
class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_left) : null,
      onTap: onTap,
    );
  }
}
