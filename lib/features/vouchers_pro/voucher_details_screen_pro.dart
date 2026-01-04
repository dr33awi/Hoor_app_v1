// ═══════════════════════════════════════════════════════════════════════════
// Voucher Details Screen Pro
// عرض تفاصيل السند مع خيارات الطباعة والتعديل والحذف
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/printing/voucher_pdf_generator.dart';
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
  bool _isDeleting = false;
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountCard(),
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
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ProHeader(
      title: _typeLabel,
      subtitle: '#${_voucher!.voucherNumber}',
      onBack: () => context.pop(),
      actions: [
        IconButton(
          onPressed: _showMoreOptions,
          icon: const Icon(Icons.more_vert_rounded),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _typeColor,
            _typeColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: _typeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _typeIcon,
              color: Colors.white,
              size: 40.sp,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            '${_voucher!.amount.toStringAsFixed(0)} ل.س',
            style: AppTypography.displayLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              _typeLabel,
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
              ),
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
                  Text(
                    '${balance.abs().toStringAsFixed(0)} ل.س',
                    style: AppTypography.titleSmall.copyWith(
                      color: balance > 0 ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
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

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: AppShadows.sm,
      ),
      child: SafeArea(
        child: Row(
          children: [
            // زر الطباعة الموحد
            PrintMenuButton(
              onPrint: _handlePrint,
              enabledOptions: const {
                PrintType.print,
                PrintType.share,
                PrintType.save,
              },
              tooltip: 'خيارات الطباعة',
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.push(
                  '/vouchers/${_voucher!.type}/edit/${_voucher!.id}',
                ),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('تعديل'),
                style: FilledButton.styleFrom(
                  backgroundColor: _typeColor,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            IconButton(
              onPressed: _deleteVoucher,
              icon: Icon(Icons.delete_outline_rounded, color: AppColors.error),
              tooltip: 'حذف',
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Icon(Icons.edit_rounded, color: AppColors.secondary),
              title: const Text('تعديل السند'),
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/vouchers/${_voucher!.type}/edit/${_voucher!.id}',
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: AppColors.error),
              title: Text(
                'حذف السند',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteVoucher();
              },
            ),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
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

  Future<void> _handlePrint(PrintType type) async {
    try {
      final printSettingsService = getIt<PrintSettingsService>();
      final options = await printSettingsService.getVoucherPrintOptions();
      final voucherData = _buildVoucherPrintData();

      switch (type) {
        case PrintType.print:
          await VoucherPdfGenerator.printVoucher(voucherData, options: options);
          break;
        case PrintType.share:
          await VoucherPdfGenerator.shareVoucher(voucherData, options: options);
          break;
        case PrintType.save:
          final path = await VoucherPdfGenerator.saveVoucher(voucherData,
              options: options);
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

  Future<void> _printVoucher() async {
    try {
      final printSettingsService = getIt<PrintSettingsService>();
      final options = await printSettingsService.getVoucherPrintOptions();

      final voucherData = VoucherPrintData(
        voucherNumber: _voucher!.voucherNumber,
        type: _voucher!.type,
        date: _voucher!.voucherDate,
        amount: _voucher!.amount,
        exchangeRate: _voucher!.exchangeRate,
        customerName: _customer?.name,
        supplierName: _supplier?.name,
        description: _voucher!.description,
      );

      await VoucherPdfGenerator.printVoucher(
        voucherData,
        options: options,
      );
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ في الطباعة: $e');
      }
    }
  }

  Future<void> _shareVoucher() async {
    try {
      final printSettingsService = getIt<PrintSettingsService>();
      final options = await printSettingsService.getVoucherPrintOptions();

      final voucherData = VoucherPrintData(
        voucherNumber: _voucher!.voucherNumber,
        type: _voucher!.type,
        date: _voucher!.voucherDate,
        amount: _voucher!.amount,
        exchangeRate: _voucher!.exchangeRate,
        customerName: _customer?.name,
        supplierName: _supplier?.name,
        description: _voucher!.description,
      );

      await VoucherPdfGenerator.shareVoucher(
        voucherData,
        options: options,
      );
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ في المشاركة: $e');
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

    setState(() => _isDeleting = true);

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
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}
