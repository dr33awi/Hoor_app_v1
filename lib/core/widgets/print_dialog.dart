import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../services/print_settings_service.dart';
import '../services/printing/invoice_pdf_generator.dart';

/// نتيجة ديالوج الطباعة
enum PrintDialogResult {
  print,
  preview,
  share,
  cancel,
}

/// ديالوج طباعة موحد
/// يمكن استخدامه للفواتير والسندات وأي مستند آخر
class PrintDialog {
  PrintDialog._();

  static final _printSettingsService = getIt<PrintSettingsService>();

  /// إظهار ديالوج الطباعة الموحد
  ///
  /// [context] - السياق
  /// [title] - عنوان الديالوج (مثل: "طباعة الفاتورة" أو "طباعة السند")
  /// [color] - لون الديالوج الرئيسي (اختياري، الافتراضي بنفسجي)
  ///
  /// يعيد [PrintDialogResult] مع [InvoicePrintSize] المختار
  static Future<({PrintDialogResult result, InvoicePrintSize size})?> show({
    required BuildContext context,
    required String title,
    Color? color,
  }) async {
    final themeColor = color ?? Colors.purple;
    final printOptions = await _printSettingsService.getPrintOptions();
    InvoicePrintSize selectedSize = printOptions.size;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.print, color: themeColor, size: 24.sp),
              Gap(8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // عنوان اختيار المقاس
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختر مقاس الورق',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Gap(12.h),
              // خيارات المقاس
              PrintSizeOption(
                title: 'A4',
                subtitle: 'للطابعات العادية',
                icon: Icons.description,
                isSelected: selectedSize == InvoicePrintSize.a4,
                color: themeColor,
                onTap: () => setState(() => selectedSize = InvoicePrintSize.a4),
              ),
              Gap(8.h),
              PrintSizeOption(
                title: 'حراري 80mm',
                subtitle: 'للطابعات الحرارية الكبيرة',
                icon: Icons.receipt_long,
                isSelected: selectedSize == InvoicePrintSize.thermal80mm,
                color: themeColor,
                onTap: () =>
                    setState(() => selectedSize = InvoicePrintSize.thermal80mm),
              ),
              Gap(8.h),
              PrintSizeOption(
                title: 'حراري 58mm',
                subtitle: 'للطابعات الحرارية الصغيرة',
                icon: Icons.receipt,
                isSelected: selectedSize == InvoicePrintSize.thermal58mm,
                color: themeColor,
                onTap: () =>
                    setState(() => selectedSize = InvoicePrintSize.thermal58mm),
              ),
              Gap(16.h),
              // زر الذهاب للإعدادات المتقدمة
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/settings/print');
                },
                icon: Icon(Icons.settings, size: 18.sp),
                label: const Text('إعدادات متقدمة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[400]!),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            IconButton(
              onPressed: () async {
                if (selectedSize != printOptions.size) {
                  await _printSettingsService.updateSetting(
                      defaultSize: selectedSize);
                }
                if (context.mounted) Navigator.pop(context, 'share');
              },
              icon: const Icon(Icons.share, size: 20),
              tooltip: 'مشاركة PDF',
              color: Colors.green,
            ),
            OutlinedButton.icon(
              onPressed: () async {
                if (selectedSize != printOptions.size) {
                  await _printSettingsService.updateSetting(
                      defaultSize: selectedSize);
                }
                if (context.mounted) Navigator.pop(context, 'preview');
              },
              icon: const Icon(Icons.preview, size: 18),
              label: const Text('معاينة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (selectedSize != printOptions.size) {
                  await _printSettingsService.updateSetting(
                      defaultSize: selectedSize);
                }
                if (context.mounted) Navigator.pop(context, 'print');
              },
              icon: const Icon(Icons.print, size: 18),
              label: const Text('طباعة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    if (result == null) return null;

    final dialogResult = switch (result) {
      'print' => PrintDialogResult.print,
      'preview' => PrintDialogResult.preview,
      'share' => PrintDialogResult.share,
      _ => PrintDialogResult.cancel,
    };

    // إعادة قراءة الإعدادات بعد التحديث
    final updatedOptions = await _printSettingsService.getPrintOptions();

    return (result: dialogResult, size: updatedOptions.size);
  }
}

/// خيار حجم الطباعة
class PrintSizeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const PrintSizeOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color = Colors.purple,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : Colors.grey[600],
                size: 20.sp,
              ),
            ),
            Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }
}
