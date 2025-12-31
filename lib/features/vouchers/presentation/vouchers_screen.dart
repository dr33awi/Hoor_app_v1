import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/services/print_settings_service.dart';
import '../../../core/services/printing/voucher_pdf_generator.dart';
import '../../../core/services/export/excel_export_service.dart';
import '../../../core/services/export/export_button.dart';
import '../../../core/services/export/pdf_export_service.dart';
import '../../../core/widgets/print_dialog.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/voucher_repository.dart';
import '../../../data/repositories/shift_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/supplier_repository.dart';
import 'voucher_form_screen.dart';

class VouchersScreen extends ConsumerStatefulWidget {
  const VouchersScreen({super.key});

  @override
  ConsumerState<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends ConsumerState<VouchersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _voucherRepo = getIt<VoucherRepository>();
  final _shiftRepo = getIt<ShiftRepository>();
  final _currencyService = getIt<CurrencyService>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return _currencyService.formatSyp(amount);
  }

  String _formatUsd(double amount, double exchangeRate) {
    if (exchangeRate <= 0) return '';
    final usdAmount = amount / exchangeRate;
    return '\$${usdAmount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السندات'),
        actions: [
          // زر الطباعة والتصدير الموحد
          ExportMenuButton(
            onExport: _handleExportMenu,
            enabledOptions: const {
              ExportType.excel,
              ExportType.pdf,
              ExportType.sharePdf,
              ExportType.shareExcel,
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.arrow_downward),
              text: 'سند قبض',
            ),
            Tab(
              icon: Icon(Icons.arrow_upward),
              text: 'سند دفع',
            ),
            Tab(
              icon: Icon(Icons.receipt_long),
              text: 'مصاريف',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVoucherList(VoucherType.receipt),
          _buildVoucherList(VoucherType.payment),
          _buildVoucherList(VoucherType.expense),
        ],
      ),
      floatingActionButton: StreamBuilder<Shift?>(
        stream: _shiftRepo.watchOpenShift(),
        builder: (context, snapshot) {
          final hasOpenShift = snapshot.data != null;
          return FloatingActionButton.extended(
            onPressed: hasOpenShift
                ? () => _navigateToAddVoucher()
                : () => _showNoShiftWarning(),
            icon: const Icon(Icons.add),
            label: const Text('سند جديد'),
            backgroundColor: hasOpenShift ? null : AppColors.textSecondary,
          );
        },
      ),
    );
  }

  Widget _buildVoucherList(VoucherType type) {
    return StreamBuilder<List<Voucher>>(
      stream: _voucherRepo.watchVouchersByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final vouchers = snapshot.data ?? [];

        if (vouchers.isEmpty) {
          return _buildEmptyState(type);
        }

        // حساب المجموع
        final total = vouchers.fold<double>(0, (sum, v) => sum + v.amount);

        return Column(
          children: [
            // بطاقة المجموع
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _getTypeColor(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _getTypeColor(type).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'إجمالي ${type.arabicName}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    _formatCurrency(total),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: _getTypeColor(type),
                    ),
                  ),
                  Text(
                    _formatUsd(total, _currencyService.exchangeRate),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // قائمة السندات
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: vouchers.length,
                itemBuilder: (context, index) {
                  final voucher = vouchers[index];
                  return _VoucherCard(
                    voucher: voucher,
                    typeColor: _getTypeColor(type),
                    onTap: () => _showVoucherDetails(voucher),
                    onDelete: () => _deleteVoucher(voucher),
                    formatCurrency: _formatCurrency,
                    formatUsd: _formatUsd,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(VoucherType type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getTypeIcon(type),
            size: 64.sp,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          Gap(16.h),
          Text(
            'لا توجد سندات ${type.arabicName}',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(VoucherType type) {
    switch (type) {
      case VoucherType.receipt:
        return AppColors.success;
      case VoucherType.payment:
        return AppColors.primary;
      case VoucherType.expense:
        return AppColors.warning;
    }
  }

  IconData _getTypeIcon(VoucherType type) {
    switch (type) {
      case VoucherType.receipt:
        return Icons.arrow_downward;
      case VoucherType.payment:
        return Icons.arrow_upward;
      case VoucherType.expense:
        return Icons.receipt_long;
    }
  }

  void _navigateToAddVoucher() {
    final type = switch (_tabController.index) {
      0 => VoucherType.receipt,
      1 => VoucherType.payment,
      2 => VoucherType.expense,
      _ => VoucherType.expense,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoucherFormScreen(type: type),
      ),
    );
  }

  void _showNoShiftWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يجب فتح وردية أولاً لإنشاء سند'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _showVoucherDetails(Voucher voucher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _VoucherDetailsSheet(
        voucher: voucher,
        voucherRepo: _voucherRepo,
        formatCurrency: _formatCurrency,
        formatUsd: _formatUsd,
      ),
    );
  }

  Future<void> _deleteVoucher(Voucher voucher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السند'),
        content: Text('هل أنت متأكد من حذف السند ${voucher.voucherNumber}؟'),
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

    if (confirm == true) {
      await _voucherRepo.deleteVoucher(voucher.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف السند بنجاح')),
        );
      }
    }
  }

  Future<void> _handleExportMenu(ExportType exportType) async {
    // الحصول على نوع التاب الحالي
    final currentTabIndex = _tabController.index;
    String? currentType;
    switch (currentTabIndex) {
      case 0:
        currentType = 'receipt';
        break;
      case 1:
        currentType = 'payment';
        break;
      case 2:
        currentType = 'expense';
        break;
    }

    // الحصول على السندات
    List<Voucher> vouchers;
    if (currentType != null) {
      vouchers = await _voucherRepo.getVouchersByType(
        VoucherType.values.firstWhere((e) => e.name == currentType),
      );
    } else {
      vouchers = await _voucherRepo.getAllVouchers();
    }

    if (vouchers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد سندات للتصدير'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    try {
      switch (exportType) {
        case ExportType.excel:
          final filePath = await ExcelExportService.exportVouchers(
            vouchers: vouchers,
            type: currentType,
            fileName: currentType != null
                ? '${currentType}_vouchers'
                : 'all_vouchers',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم تصدير السندات بنجاح'),
                backgroundColor: AppColors.success,
                action: SnackBarAction(
                  label: 'مشاركة',
                  textColor: Colors.white,
                  onPressed: () => ExcelExportService.shareFile(filePath),
                ),
              ),
            );
          }
          break;

        case ExportType.pdf:
          final pdfBytes = await PdfExportService.generateVouchersList(
            vouchers: vouchers,
            type: currentType,
          );
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdfBytes,
            name: 'vouchers_list.pdf',
          );
          break;

        case ExportType.sharePdf:
          final pdfBytes = await PdfExportService.generateVouchersList(
            vouchers: vouchers,
            type: currentType,
          );
          await Printing.sharePdf(
            bytes: pdfBytes,
            filename: 'vouchers_list.pdf',
          );
          break;

        case ExportType.shareExcel:
          final filePath = await ExcelExportService.exportVouchers(
            vouchers: vouchers,
            type: currentType,
            fileName: currentType != null
                ? '${currentType}_vouchers'
                : 'all_vouchers',
          );
          await ExcelExportService.shareFile(filePath);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التصدير: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final Color typeColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(double) formatCurrency;
  final String Function(double, double) formatUsd;

  const _VoucherCard({
    required this.voucher,
    required this.typeColor,
    required this.onTap,
    required this.onDelete,
    required this.formatCurrency,
    required this.formatUsd,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd - HH:mm', 'ar');

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getVoucherIcon(),
                      color: typeColor,
                      size: 24.sp,
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.voucherNumber,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dateFormat.format(voucher.voucherDate),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(voucher.amount),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      Text(
                        formatUsd(voucher.amount, voucher.exchangeRate),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (voucher.description != null &&
                  voucher.description!.isNotEmpty) ...[
                Gap(8.h),
                Text(
                  voucher.description!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getVoucherIcon() {
    switch (voucher.type) {
      case 'receipt':
        return Icons.arrow_downward;
      case 'payment':
        return Icons.arrow_upward;
      case 'expense':
        return Icons.receipt_long;
      default:
        return Icons.receipt;
    }
  }
}

class _VoucherDetailsSheet extends StatefulWidget {
  final Voucher voucher;
  final VoucherRepository voucherRepo;
  final String Function(double) formatCurrency;
  final String Function(double, double) formatUsd;

  const _VoucherDetailsSheet({
    required this.voucher,
    required this.voucherRepo,
    required this.formatCurrency,
    required this.formatUsd,
  });

  @override
  State<_VoucherDetailsSheet> createState() => _VoucherDetailsSheetState();
}

class _VoucherDetailsSheetState extends State<_VoucherDetailsSheet> {
  bool _isPrinting = false;
  final _printSettingsService = getIt<PrintSettingsService>();
  final _customerRepo = getIt<CustomerRepository>();
  final _supplierRepo = getIt<SupplierRepository>();

  Future<VoucherPrintData> _getVoucherPrintData() async {
    String? customerName;
    String? supplierName;

    // جلب اسم العميل إن وجد
    if (widget.voucher.customerId != null) {
      try {
        final customer =
            await _customerRepo.getCustomerById(widget.voucher.customerId!);
        customerName = customer?.name;
      } catch (_) {}
    }

    // جلب اسم المورد إن وجد
    if (widget.voucher.supplierId != null) {
      try {
        final supplier =
            await _supplierRepo.getSupplierById(widget.voucher.supplierId!);
        supplierName = supplier?.name;
      } catch (_) {}
    }

    return VoucherPrintData(
      voucherNumber: widget.voucher.voucherNumber,
      type: widget.voucher.type,
      date: widget.voucher.voucherDate,
      amount: widget.voucher.amount,
      exchangeRate: widget.voucher.exchangeRate,
      description: widget.voucher.description,
      customerName: customerName,
      supplierName: supplierName,
    );
  }

  Future<void> _showPrintDialog() async {
    final voucherType = VoucherTypeExtension.fromString(widget.voucher.type);

    final dialogResult = await PrintDialog.show(
      context: context,
      title: 'طباعة ${voucherType.arabicName}',
      color: _getTypeColor(),
    );

    if (dialogResult == null || !mounted) return;

    setState(() => _isPrinting = true);

    try {
      final data = await _getVoucherPrintData();
      final options = await _printSettingsService.getVoucherPrintOptions();

      if (dialogResult.result == PrintDialogResult.print) {
        await VoucherPdfGenerator.printVoucher(data, options: options);
      } else if (dialogResult.result == PrintDialogResult.preview) {
        final pdfBytes = await VoucherPdfGenerator.generateVoucherPdf(data,
            options: options);
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: 'سند_${data.voucherNumber}.pdf',
        );
      } else if (dialogResult.result == PrintDialogResult.share) {
        await VoucherPdfGenerator.shareVoucher(data, options: options);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  /// الانتقال إلى شاشة تعديل السند
  void _editVoucher() {
    final voucherType = VoucherTypeExtension.fromString(widget.voucher.type);
    Navigator.pop(context); // إغلاق الـ BottomSheet أولاً
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoucherFormScreen(
          type: voucherType,
          voucher: widget.voucher,
        ),
      ),
    );
  }

  /// حذف السند
  Future<void> _deleteVoucher() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السند'),
        content:
            Text('هل أنت متأكد من حذف السند ${widget.voucher.voucherNumber}؟'),
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

    if (confirm == true) {
      try {
        await widget.voucherRepo.deleteVoucher(widget.voucher.id);
        if (mounted) {
          Navigator.pop(context); // إغلاق الـ BottomSheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف السند بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في حذف السند: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd - HH:mm', 'ar');
    final type = VoucherTypeExtension.fromString(widget.voucher.type);

    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: _getTypeColor(),
                  size: 32.sp,
                ),
              ),
              Gap(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.arabicName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.voucher.voucherNumber,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // زر الطباعة - يفتح ديالوج الطباعة مباشرة
              IconButton(
                icon: _isPrinting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.print, color: _getTypeColor()),
                onPressed: _isPrinting ? null : _showPrintDialog,
                tooltip: 'طباعة',
              ),
              // زر التعديل
              IconButton(
                icon: Icon(Icons.edit, color: _getTypeColor()),
                onPressed: () => _editVoucher(),
                tooltip: 'تعديل',
              ),
              // زر الحذف
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () => _deleteVoucher(),
                tooltip: 'حذف',
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          Gap(24.h),

          // المبلغ
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  'المبلغ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Gap(8.h),
                Text(
                  widget.formatCurrency(widget.voucher.amount),
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(),
                  ),
                ),
                Text(
                  widget.formatUsd(
                      widget.voucher.amount, widget.voucher.exchangeRate),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Gap(16.h),

          // التفاصيل
          _DetailRow(
            label: 'التاريخ',
            value: dateFormat.format(widget.voucher.voucherDate),
          ),
          _DetailRow(
            label: 'سعر الصرف',
            value:
                '${widget.voucher.exchangeRate.toStringAsFixed(0)} ${CurrencyService.currencySymbol}/\$',
          ),
          if (widget.voucher.description != null &&
              widget.voucher.description!.isNotEmpty)
            _DetailRow(
              label: 'الوصف',
              value: widget.voucher.description!,
            ),

          Gap(24.h),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (widget.voucher.type) {
      case 'receipt':
        return AppColors.success;
      case 'payment':
        return AppColors.primary;
      case 'expense':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.voucher.type) {
      case 'receipt':
        return Icons.arrow_downward;
      case 'payment':
        return Icons.arrow_upward;
      case 'expense':
        return Icons.receipt_long;
      default:
        return Icons.receipt;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
