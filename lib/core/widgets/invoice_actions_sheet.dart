import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../di/injection.dart';
import '../services/printing/printing_services.dart';
import '../services/print_settings_service.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/supplier_repository.dart';
import 'invoice_widgets.dart';
import 'print_dialog.dart';

/// Bottom Sheet موحد لعرض خيارات الفاتورة (معاينة، طباعة، مشاركة)
class InvoiceActionsSheet extends StatelessWidget {
  final Invoice invoice;
  final bool showDetails;

  const InvoiceActionsSheet({
    super.key,
    required this.invoice,
    this.showDetails = true,
  });

  static final _invoiceRepo = getIt<InvoiceRepository>();
  static final _customerRepo = getIt<CustomerRepository>();
  static final _supplierRepo = getIt<SupplierRepository>();
  static final _printSettingsService = getIt<PrintSettingsService>();

  /// عرض Bottom Sheet للفاتورة
  static void show(BuildContext context, Invoice invoice,
      {bool showDetails = true}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => InvoiceActionsSheet(
        invoice: invoice,
        showDetails: showDetails,
      ),
    );
  }

  /// عرض Dialog الطباعة مباشرة (طباعة + معاينة)
  static Future<void> showPrintDialog(
      BuildContext context, Invoice invoice) async {
    final dialogResult = await PrintDialog.show(
      context: context,
      title: 'طباعة الفاتورة',
      color: Colors.purple,
    );

    if (dialogResult == null || !context.mounted) return;

    try {
      final items = await _invoiceRepo.getInvoiceItems(invoice.id);
      final customer = invoice.customerId != null
          ? await _customerRepo.getCustomerById(invoice.customerId!)
          : null;
      final supplier = invoice.supplierId != null
          ? await _supplierRepo.getSupplierById(invoice.supplierId!)
          : null;

      final options = await _printSettingsService.getPrintOptions();

      if (dialogResult.result == PrintDialogResult.print) {
        await InvoicePdfGenerator.printInvoiceDirectly(
          invoice: invoice,
          items: items,
          customer: customer,
          supplier: supplier,
          options: options,
        );
      } else if (dialogResult.result == PrintDialogResult.preview) {
        final pdfBytes = await InvoicePdfGenerator.generateInvoicePdfBytes(
          invoice: invoice,
          items: items,
          customer: customer,
          supplier: supplier,
          options: options,
        );
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: 'فاتورة_${invoice.invoiceNumber}.pdf',
        );
      } else if (dialogResult.result == PrintDialogResult.share) {
        await InvoicePdfGenerator.shareInvoiceAsPdf(
          invoice: invoice,
          items: items,
          customer: customer,
          supplier: supplier,
          options: options,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeInfo = InvoiceTypeInfo.fromType(invoice.type);

    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Header
          Row(
            children: [
              InvoiceTypeIcon(type: invoice.type),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فاتورة ${invoice.invoiceNumber}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      typeInfo.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: typeInfo.color,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatAmount(invoice.total),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: typeInfo.color,
                ),
              ),
            ],
          ),
          Gap(20.h),
          const Divider(height: 1),
          Gap(12.h),

          // Actions
          if (showDetails)
            _ActionTile(
              icon: Icons.visibility,
              color: Colors.blue,
              title: 'تفاصيل الفاتورة',
              subtitle: 'عرض جميع تفاصيل الفاتورة',
              onTap: () {
                Navigator.pop(context);
                context.push('/invoices/details/${invoice.id}');
              },
            ),
          _ActionTile(
            icon: Icons.preview,
            color: Colors.orange,
            title: 'معاينة الطباعة',
            subtitle: 'معاينة الفاتورة قبل الطباعة',
            onTap: () => _previewInvoice(context),
          ),
          _ActionTile(
            icon: Icons.print,
            color: Colors.purple,
            title: 'طباعة',
            subtitle: 'طباعة الفاتورة مباشرة',
            onTap: () => _printInvoice(context),
          ),
          _ActionTile(
            icon: Icons.share,
            color: Colors.green,
            title: 'مشاركة PDF',
            subtitle: 'مشاركة الفاتورة كملف PDF',
            onTap: () => _shareInvoice(context),
          ),
          Gap(8.h),
        ],
      ),
    );
  }

  Future<void> _previewInvoice(BuildContext context) async {
    Navigator.pop(context);

    try {
      final items = await _invoiceRepo.getInvoiceItems(invoice.id);
      final customer = invoice.customerId != null
          ? await _customerRepo.getCustomerById(invoice.customerId!)
          : null;
      final supplier = invoice.supplierId != null
          ? await _supplierRepo.getSupplierById(invoice.supplierId!)
          : null;

      // استخدام إعدادات الطباعة الموحدة
      final printOptions = await _printSettingsService.getPrintOptions();

      final pdfBytes = await InvoicePdfGenerator.generateInvoicePdfBytes(
        invoice: invoice,
        items: items,
        customer: customer,
        supplier: supplier,
        options: printOptions,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'فاتورة_${invoice.invoiceNumber}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المعاينة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printInvoice(BuildContext context) async {
    Navigator.pop(context);

    // إظهار dialog تأكيد الطباعة مع المقاس
    final shouldPrint = await _showPrintConfirmDialog(context);
    if (shouldPrint != true) return;

    try {
      final items = await _invoiceRepo.getInvoiceItems(invoice.id);
      final customer = invoice.customerId != null
          ? await _customerRepo.getCustomerById(invoice.customerId!)
          : null;
      final supplier = invoice.supplierId != null
          ? await _supplierRepo.getSupplierById(invoice.supplierId!)
          : null;

      // استخدام إعدادات الطباعة الموحدة من الإعدادات المحفوظة
      final printOptions = await _printSettingsService.getPrintOptions();

      await InvoicePdfGenerator.printInvoiceDirectly(
        invoice: invoice,
        items: items,
        customer: customer,
        supplier: supplier,
        options: printOptions,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showPrintConfirmDialog(BuildContext context) async {
    final printOptions = await _printSettingsService.getPrintOptions();
    InvoicePrintSize selectedSize = printOptions.size;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.print, color: Colors.purple, size: 24.sp),
              Gap(8.w),
              const Text('طباعة الفاتورة'),
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
                color: Colors.purple,
                onTap: () => setState(() => selectedSize = InvoicePrintSize.a4),
              ),
              Gap(8.h),
              PrintSizeOption(
                title: 'حراري 80mm',
                subtitle: 'للطابعات الحرارية الكبيرة',
                icon: Icons.receipt_long,
                isSelected: selectedSize == InvoicePrintSize.thermal80mm,
                color: Colors.purple,
                onTap: () =>
                    setState(() => selectedSize = InvoicePrintSize.thermal80mm),
              ),
              Gap(8.h),
              PrintSizeOption(
                title: 'حراري 58mm',
                subtitle: 'للطابعات الحرارية الصغيرة',
                icon: Icons.receipt,
                isSelected: selectedSize == InvoicePrintSize.thermal58mm,
                color: Colors.purple,
                onTap: () =>
                    setState(() => selectedSize = InvoicePrintSize.thermal58mm),
              ),
              Gap(16.h),
              // زر الذهاب للإعدادات المتقدمة
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context, false);
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
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                // حفظ المقاس المختار إذا تغير
                if (selectedSize != printOptions.size) {
                  await _printSettingsService.updateSetting(
                      defaultSize: selectedSize);
                }
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.print, size: 18),
              label: const Text('طباعة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareInvoice(BuildContext context) async {
    Navigator.pop(context);

    try {
      final items = await _invoiceRepo.getInvoiceItems(invoice.id);
      final customer = invoice.customerId != null
          ? await _customerRepo.getCustomerById(invoice.customerId!)
          : null;
      final supplier = invoice.supplierId != null
          ? await _supplierRepo.getSupplierById(invoice.supplierId!)
          : null;

      // استخدام إعدادات الطباعة الموحدة
      final printOptions = await _printSettingsService.getPrintOptions();

      await InvoicePdfGenerator.shareInvoiceAsPdf(
        invoice: invoice,
        items: items,
        customer: customer,
        supplier: supplier,
        options: printOptions,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المشاركة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Tile للإجراءات
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 24.sp),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_left, color: Colors.grey),
      onTap: onTap,
    );
  }
}

/// زر طباعة سريع للإضافة في أي مكان
class InvoicePrintButton extends StatelessWidget {
  final Invoice invoice;
  final bool mini;

  const InvoicePrintButton({
    super.key,
    required this.invoice,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    if (mini) {
      return IconButton(
        icon: const Icon(Icons.print),
        tooltip: 'طباعة الفاتورة',
        onPressed: () => InvoiceActionsSheet.show(context, invoice),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => InvoiceActionsSheet.show(context, invoice),
      icon: const Icon(Icons.print, size: 18),
      label: const Text('طباعة'),
    );
  }
}

/// زر خيارات الفاتورة (More options)
class InvoiceOptionsButton extends StatelessWidget {
  final Invoice invoice;
  final bool showDetails;

  const InvoiceOptionsButton({
    super.key,
    required this.invoice,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      tooltip: 'خيارات الفاتورة',
      onPressed: () => InvoiceActionsSheet.show(
        context,
        invoice,
        showDetails: showDetails,
      ),
    );
  }
}
