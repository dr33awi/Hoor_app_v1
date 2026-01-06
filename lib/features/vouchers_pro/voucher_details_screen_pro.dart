// ═══════════════════════════════════════════════════════════════════════════
// Voucher Details Screen Pro - Enterprise Accounting Design
// عرض تفاصيل السند مع خيارات الطباعة والتعديل والحذف
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/dual_price_display.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/printing/voucher_pdf_generator.dart';
import '../../core/services/printing/invoice_pdf_generator.dart';
import '../../core/services/printing/print_settings_service.dart';
import '../../core/services/printing/print_menu_button.dart';
import '../../core/di/injection.dart';
import '../../data/database/app_database.dart';

class VoucherDetailsScreenPro extends ConsumerStatefulWidget {
  final String voucherId;

  const VoucherDetailsScreenPro({
    super.key,
    required this.voucherId,
  });

  @override
  ConsumerState<VoucherDetailsScreenPro> createState() =>
      _VoucherDetailsScreenProState();
}

class _VoucherDetailsScreenProState
    extends ConsumerState<VoucherDetailsScreenPro> {
  bool _isLoading = true;
  Voucher? _voucher;
  Customer? _customer;
  Supplier? _supplier;
  VoucherCategory? _category;

  @override
  void initState() {
    super.initState();
    _loadVoucherData();
  }

  Future<void> _loadVoucherData() async {
    setState(() => _isLoading = true);
    try {
      final voucherRepo = ref.read(voucherRepositoryProvider);
      final voucher = await voucherRepo.getVoucherById(widget.voucherId);

      if (voucher != null && mounted) {
        setState(() {
          _voucher = voucher;
        });

        // تحميل بيانات العميل أو المورد
        if (voucher.customerId != null) {
          final customerRepo = ref.read(customerRepositoryProvider);
          final customer =
              await customerRepo.getCustomerById(voucher.customerId!);
          if (mounted) setState(() => _customer = customer);
        }

        if (voucher.supplierId != null) {
          final supplierRepo = ref.read(supplierRepositoryProvider);
          final supplier =
              await supplierRepo.getSupplierById(voucher.supplierId!);
          if (mounted) setState(() => _supplier = supplier);
        }

        // تحميل بيانات الفئة
        if (voucher.categoryId != null) {
          final category =
              await voucherRepo.getCategoryById(voucher.categoryId!);
          if (mounted) setState(() => _category = category);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color get _typeColor {
    switch (_voucher?.type) {
      case 'receipt':
        return AppColors.success;
      case 'payment':
        return AppColors.error;
      case 'expense':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _typeIcon {
    switch (_voucher?.type) {
      case 'receipt':
        return Icons.arrow_downward_rounded;
      case 'payment':
        return Icons.arrow_upward_rounded;
      case 'expense':
        return Icons.receipt_outlined;
      default:
        return Icons.description;
    }
  }

  String get _typeLabel {
    switch (_voucher?.type) {
      case 'receipt':
        return 'سند قبض';
      case 'payment':
        return 'سند صرف';
      case 'expense':
        return 'سند مصاريف';
      default:
        return 'سند';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: ProAppBar.simple(title: 'تفاصيل السند'),
        body: ProLoadingState.withMessage(message: 'جاري تحميل البيانات...'),
      );
    }

    if (_voucher == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: ProAppBar.simple(title: 'تفاصيل السند'),
        body: ProEmptyState.error(error: 'لم يتم العثور على السند'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          _buildAmountSection(),
          SizedBox(height: AppSpacing.lg),
          _buildDetailsCard(),
          if (_customer != null || _supplier != null) ...[
            SizedBox(height: AppSpacing.lg),
            _buildPartyCard(),
          ],
          if (_category != null) ...[
            SizedBox(height: AppSpacing.lg),
            _buildCategoryCard(),
          ],
          if (_voucher?.description != null &&
              _voucher!.description!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.lg),
            _buildDescriptionCard(),
          ],
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return ProAppBar.simple(
      title: '$_typeLabel #${_voucher!.voucherNumber}',
      actions: [
        PrintMenuButton(
          onPrint: _handlePrint,
          showSizeSelector: true,
          enabledOptions: const {
            PrintType.print,
            PrintType.share,
            PrintType.save,
            PrintType.preview,
          },
          tooltip: 'طباعة',
          color: AppColors.textSecondary,
        ),
        IconButton(
          onPressed: () => context.push(
            '/vouchers/${_voucher!.type}/edit/${_voucher!.id}',
          ),
          icon: const Icon(Icons.edit_outlined),
          color: AppColors.textSecondary,
          tooltip: 'تعديل',
        ),
        IconButton(
          onPressed: _deleteVoucher,
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppColors.error,
          tooltip: 'حذف',
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    final exchangeRate = _voucher!.exchangeRate;
    final amountUsd = _voucher!.amountUsd ??
        (exchangeRate > 0 ? _voucher!.amount / exchangeRate : null);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _typeColor.soft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _typeColor.border),
      ),
      child: Row(
        children: [
          // أيقونة النوع
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _typeColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _typeIcon,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          // المبلغ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _typeLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: _typeColor,
                  ),
                ),
                DualPriceDisplay(
                  amountSyp: _voucher!.amount,
                  amountUsd: amountUsd,
                  exchangeRate: exchangeRate,
                  sypStyle: AppTypography.headlineMedium.copyWith(
                    color: _typeColor,
                    fontWeight: FontWeight.bold,
                  ),
                  usdStyle: AppTypography.bodyMedium.copyWith(
                    color: _typeColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // سعر الصرف
          if (exchangeRate > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.currency_exchange,
                    color: _typeColor,
                    size: 12.sp,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${exchangeRate.toStringAsFixed(0)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: _typeColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');

    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل السند',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            'رقم السند',
            _voucher!.voucherNumber,
            Icons.tag_rounded,
          ),
          _buildDetailRow(
            'التاريخ',
            dateFormat.format(_voucher!.voucherDate),
            Icons.calendar_today_rounded,
          ),
          _buildDetailRow(
            'تاريخ الإنشاء',
            dateFormat.format(_voucher!.createdAt),
            Icons.access_time_rounded,
          ),
          if (_voucher!.shiftId != null)
            _buildDetailRow(
              'الشفت',
              _voucher!.shiftId!,
              Icons.work_history_rounded,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.textTertiary),
          SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard() {
    final isCustomer = _customer != null;
    final name = isCustomer ? _customer!.name : _supplier!.name;
    final phone = isCustomer ? _customer!.phone : _supplier!.phone;
    final balance = isCustomer ? _customer!.balance : _supplier!.balance;

    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCustomer ? 'العميل' : 'المورد',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: _typeColor.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: AppTypography.titleLarge.copyWith(
                      color: _typeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (phone != null && phone.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        phone,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Builder(
                    builder: (context) {
                      final exchangeRate =
                          _voucher?.exchangeRate ?? CurrencyService.currentRate;
                      final balanceUsd = exchangeRate > 0
                          ? balance.abs() / exchangeRate
                          : null;
                      return CompactDualPrice(
                        amountSyp: balance.abs(),
                        amountUsd: balanceUsd,
                        sypStyle: AppTypography.titleSmall.copyWith(
                          color:
                              balance > 0 ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                        usdStyle: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                  Text(
                    balance > 0 ? 'عليه' : 'له',
                    style: AppTypography.labelSmall.copyWith(
                      color: balance > 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (isCustomer) {
                  context.push('/customers/${_customer!.id}');
                } else {
                  context.push('/suppliers/${_supplier!.id}');
                }
              },
              icon: const Icon(Icons.visibility_rounded),
              label: Text('عرض ${isCustomer ? 'العميل' : 'المورد'}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    return ProCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.soft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.category_rounded,
              color: AppColors.warning,
              size: 24.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فئة المصاريف',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  _category!.name,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notes_rounded,
                size: 20.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'الوصف',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            _voucher!.description!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  VoucherPrintData _buildVoucherPrintData() {
    return VoucherPrintData(
      voucherNumber: _voucher!.voucherNumber,
      type: _voucher!.type,
      date: _voucher!.voucherDate,
      amount: _voucher!.amount,
      exchangeRate: _voucher!.exchangeRate,
      customerName: _customer?.name,
      supplierName: _supplier?.name,
      description: _voucher!.description,
    );
  }

  VoucherPrintSize _mapPrintSize(InvoicePrintSize size) {
    switch (size) {
      case InvoicePrintSize.a4:
        return VoucherPrintSize.a4;
      case InvoicePrintSize.thermal80mm:
        return VoucherPrintSize.thermal80mm;
      case InvoicePrintSize.thermal58mm:
        return VoucherPrintSize.thermal58mm;
    }
  }

  Future<void> _handlePrint(PrintType type, [InvoicePrintSize? size]) async {
    try {
      final printSettingsService = getIt<PrintSettingsService>();
      final baseOptions = await printSettingsService.getVoucherPrintOptions();

      // تحديث المقاس إذا تم اختياره
      final options = size != null
          ? baseOptions.copyWith(size: _mapPrintSize(size))
          : baseOptions;

      final voucherData = _buildVoucherPrintData();

      switch (type) {
        case PrintType.print:
          await VoucherPdfGenerator.printVoucher(voucherData, options: options);
          break;
        case PrintType.share:
          await VoucherPdfGenerator.shareVoucher(voucherData, options: options);
          break;
        case PrintType.save:
          await VoucherPdfGenerator.saveVoucher(voucherData, options: options);
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case PrintType.preview:
          await VoucherPdfGenerator.previewVoucher(voucherData,
              options: options);
          break;
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ: $e');
      }
    }
  }

  Future<void> _deleteVoucher() async {
    final confirm = await showProDeleteDialog(
      context: context,
      itemName: 'السند',
      message: 'سيتم حذف السند وعكس تأثيره على الأرصدة. هل أنت متأكد؟',
    );

    if (confirm != true || !mounted) return;

    try {
      final voucherRepo = ref.read(voucherRepositoryProvider);
      await voucherRepo.deleteVoucher(_voucher!.id);

      if (mounted) {
        ProSnackbar.deleted(context);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ في الحذف: $e');
      }
    }
  }
}
