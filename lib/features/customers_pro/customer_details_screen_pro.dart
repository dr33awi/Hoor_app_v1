// ═══════════════════════════════════════════════════════════════════════════
// Customer Details Screen Pro - Enterprise Accounting Design
// عرض تفاصيل العميل مع كشف الحساب والفواتير والسندات
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
import '../../core/services/export/export_services.dart';
import '../../core/services/export/export_button.dart';
import '../../data/database/app_database.dart';

class CustomerDetailsScreenPro extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerDetailsScreenPro({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<CustomerDetailsScreenPro> createState() =>
      _CustomerDetailsScreenProState();
}

class _CustomerDetailsScreenProState
    extends ConsumerState<CustomerDetailsScreenPro>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isExporting = false;
  Customer? _customer;
  List<Invoice> _invoices = [];
  List<Voucher> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final customerRepo = ref.read(customerRepositoryProvider);
      final customer = await customerRepo.getCustomerById(widget.customerId);

      if (customer != null && mounted) {
        setState(() => _customer = customer);

        // تحميل الفواتير
        final invoicesAsync = ref.read(invoicesStreamProvider);
        invoicesAsync.whenData((invoices) {
          if (mounted) {
            setState(() {
              _invoices = invoices
                  .where((i) => i.customerId == widget.customerId)
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            });
          }
        });

        // تحميل السندات
        final vouchersAsync = ref.read(vouchersStreamProvider);
        vouchersAsync.whenData((vouchers) {
          if (mounted) {
            setState(() {
              _vouchers = vouchers
                  .where((v) => v.customerId == widget.customerId)
                  .toList()
                ..sort((a, b) => b.voucherDate.compareTo(a.voucherDate));
            });
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: ProAppBar.simple(title: 'تفاصيل العميل'),
        body: ProLoadingState.withMessage(message: 'جاري تحميل البيانات...'),
      );
    }

    if (_customer == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: ProAppBar.simple(title: 'تفاصيل العميل'),
        body: ProEmptyState.error(error: 'لم يتم العثور على العميل'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCustomerCard(),
            _buildBalanceCard(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAccountStatement(),
                  _buildInvoicesList(),
                  _buildVouchersList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActions(),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إجراء سريع'),
      ),
    );
  }

  Widget _buildHeader() {
    return ProHeader(
      title: _customer!.name,
      subtitle: _customer!.phone ?? 'بدون رقم',
      onBack: () => context.pop(),
      actions: [
        ExportMenuButton(
          onExport: _handleExport,
          isLoading: _isExporting,
          enabledOptions: const {
            ExportType.excel,
            ExportType.pdf,
            ExportType.sharePdf,
            ExportType.shareExcel,
          },
          tooltip: 'تصدير كشف الحساب',
        ),
        IconButton(
          onPressed: () => context.push('/customers/edit/${_customer!.id}'),
          icon: const Icon(Icons.edit_rounded),
          color: AppColors.textSecondary,
          tooltip: 'تعديل',
        ),
        IconButton(
          onPressed: _deleteCustomer,
          icon: Icon(Icons.delete_outline_rounded, color: AppColors.error),
          tooltip: 'حذف',
        ),
      ],
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Enterprise: Square avatar with border
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border:
                  Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                _customer!.name[0].toUpperCase(),
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _customer!.name,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_customer!.phone != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          size: 16.sp, color: AppColors.textTertiary),
                      SizedBox(width: 4.w),
                      Text(
                        _customer!.phone!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (_customer!.email != null) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.email_outlined,
                          size: 16.sp, color: AppColors.textTertiary),
                      SizedBox(width: 4.w),
                      Text(
                        _customer!.email!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _customer!.isActive
                  ? AppColors.success.soft
                  : AppColors.error.soft,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              _customer!.isActive ? 'نشط' : 'غير نشط',
              style: AppTypography.labelSmall.copyWith(
                color:
                    _customer!.isActive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final balance = _customer!.balance;
    final isOwed = balance > 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOwed
              ? [AppColors.error, AppColors.error.withValues(alpha: 0.8)]
              : [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: (isOwed ? AppColors.error : AppColors.success)
                .withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرصيد الحالي',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '${balance.abs().toStringAsFixed(0)} ل.س',
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  isOwed ? 'مستحق على العميل' : 'لا توجد مستحقات',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          if (isOwed)
            FilledButton.icon(
              onPressed: () => context.push('/vouchers/receipt/add'),
              icon: const Icon(Icons.payment_rounded, size: 18),
              label: const Text('تحصيل'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary.soft,
          borderRadius: BorderRadius.circular(AppRadius.md - 1),
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_rounded, size: 18),
                SizedBox(width: 4.w),
                const Text('كشف الحساب'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_rounded, size: 18),
                SizedBox(width: 4.w),
                Text('الفواتير (${_invoices.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payments_rounded, size: 18),
                SizedBox(width: 4.w),
                Text('السندات (${_vouchers.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatement() {
    // دمج الفواتير والسندات في كشف حساب موحد
    final List<_AccountEntry> entries = [];

    // إضافة الفواتير
    for (final invoice in _invoices) {
      entries.add(_AccountEntry(
        date: invoice.createdAt,
        description: 'فاتورة #${invoice.invoiceNumber}',
        debit: invoice.type == 'sale' ? invoice.total : 0,
        credit: invoice.type == 'sale_return' ? invoice.total : 0,
        type: 'invoice',
        id: invoice.id,
      ));
    }

    // إضافة السندات
    for (final voucher in _vouchers) {
      entries.add(_AccountEntry(
        date: voucher.voucherDate,
        description: 'سند قبض #${voucher.voucherNumber}',
        debit: 0,
        credit: voucher.amount,
        type: 'voucher',
        id: voucher.id,
      ));
    }

    // ترتيب حسب التاريخ
    entries.sort((a, b) => b.date.compareTo(a.date));

    if (entries.isEmpty) {
      return ProEmptyState.list(
        itemName: 'معاملات',
      );
    }

    // حساب الرصيد التراكمي
    double runningBalance = 0;
    for (int i = entries.length - 1; i >= 0; i--) {
      runningBalance += entries[i].debit - entries[i].credit;
      entries[i].balance = runningBalance;
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header row
          return Container(
            padding: EdgeInsets.all(AppSpacing.md),
            margin: EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.soft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('التاريخ',
                        style: AppTypography.labelMedium
                            .copyWith(fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 3,
                    child: Text('البيان',
                        style: AppTypography.labelMedium
                            .copyWith(fontWeight: FontWeight.w600))),
                Expanded(
                    child: Text('مدين',
                        style: AppTypography.labelMedium
                            .copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)),
                Expanded(
                    child: Text('دائن',
                        style: AppTypography.labelMedium
                            .copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)),
                Expanded(
                    child: Text('الرصيد',
                        style: AppTypography.labelMedium
                            .copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)),
              ],
            ),
          );
        }

        final entry = entries[index - 1];
        return GestureDetector(
          onTap: () {
            if (entry.type == 'invoice') {
              context.push('/invoices/${entry.id}');
            } else {
              context.push('/vouchers/${entry.id}');
            }
          },
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            margin: EdgeInsets.only(bottom: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    DateFormat('MM/dd').format(entry.date),
                    style: AppTypography.bodySmall,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.description,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.debit > 0 ? entry.debit.toStringAsFixed(0) : '-',
                    style: AppTypography.bodySmall.copyWith(
                      color: entry.debit > 0
                          ? AppColors.error
                          : AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.credit > 0 ? entry.credit.toStringAsFixed(0) : '-',
                    style: AppTypography.bodySmall.copyWith(
                      color: entry.credit > 0
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.balance.toStringAsFixed(0),
                    style: AppTypography.bodySmall.copyWith(
                      color: entry.balance > 0
                          ? AppColors.error
                          : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoicesList() {
    if (_invoices.isEmpty) {
      return ProEmptyState.list(
        itemName: 'فواتير',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: _invoices.length,
      itemBuilder: (context, index) {
        final invoice = _invoices[index];
        return _InvoiceCard(
          invoice: invoice,
          onTap: () => context.push('/invoices/${invoice.id}'),
        );
      },
    );
  }

  Widget _buildVouchersList() {
    if (_vouchers.isEmpty) {
      return ProEmptyState.list(
        itemName: 'سندات',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: _vouchers.length,
      itemBuilder: (context, index) {
        final voucher = _vouchers[index];
        return _VoucherMiniCard(
          voucher: voucher,
          onTap: () => context.push('/vouchers/${voucher.id}'),
        );
      },
    );
  }

  void _showQuickActions() {
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
            Text(
              'إجراء سريع',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.secondary.soft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.shopping_cart_rounded,
                    color: AppColors.secondary),
              ),
              title: const Text('فاتورة بيع جديدة'),
              onTap: () {
                Navigator.pop(context);
                context.push('/sales/add');
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.soft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.arrow_downward_rounded,
                    color: AppColors.success),
              ),
              title: const Text('سند قبض'),
              subtitle: const Text('تحصيل مبلغ من العميل'),
              onTap: () {
                Navigator.pop(context);
                context.push('/vouchers/receipt/add');
              },
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport(ExportType type) async {
    setState(() => _isExporting = true);
    final fileName =
        'كشف_حساب_${_customer!.name}_${DateFormat('yyyyMMdd').format(DateTime.now())}';

    try {
      switch (type) {
        case ExportType.excel:
          await ExcelExportService.exportCustomerStatement(
            customer: _customer!,
            invoices: _invoices,
            vouchers: _vouchers,
            fileName: fileName,
          );
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.pdf:
          // TODO: Implement PDF export for customer statement
          if (mounted) ProSnackbar.info(context, 'سيتم إضافة تصدير PDF قريباً');
          break;
        case ExportType.sharePdf:
          // TODO: Implement PDF share for customer statement
          if (mounted)
            ProSnackbar.info(context, 'سيتم إضافة مشاركة PDF قريباً');
          break;
        case ExportType.shareExcel:
          final filePath = await ExcelExportService.exportCustomerStatement(
            customer: _customer!,
            invoices: _invoices,
            vouchers: _vouchers,
            fileName: fileName,
          );
          await ExcelExportService.shareFile(filePath,
              subject: 'كشف حساب ${_customer!.name}');
          break;
      }
    } catch (e) {
      if (mounted) ProSnackbar.error(context, 'حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _deleteCustomer() async {
    final confirm = await showProDeleteDialog(
      context: context,
      itemName: 'العميل',
      message: 'سيتم حذف العميل وجميع بياناته. هل أنت متأكد؟',
    );

    if (confirm != true || !mounted) return;

    try {
      final customerRepo = ref.read(customerRepositoryProvider);
      await customerRepo.deleteCustomer(_customer!.id);

      if (mounted) {
        ProSnackbar.deleted(context);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ: $e');
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Helper Classes
// ═══════════════════════════════════════════════════════════════════════════

class _AccountEntry {
  final DateTime date;
  final String description;
  final double debit;
  final double credit;
  final String type;
  final String id;
  double balance = 0;

  _AccountEntry({
    required this.date,
    required this.description,
    required this.debit,
    required this.credit,
    required this.type,
    required this.id,
  });
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const _InvoiceCard({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.secondary.soft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.receipt_rounded,
                  color: AppColors.secondary, size: 20.sp),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${invoice.invoiceNumber}',
                    style: AppTypography.titleSmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    DateFormat('yyyy/MM/dd').format(invoice.createdAt),
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${invoice.total.toStringAsFixed(0)} ل.س',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class _VoucherMiniCard extends StatelessWidget {
  final Voucher voucher;
  final VoidCallback onTap;

  const _VoucherMiniCard({required this.voucher, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.soft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.arrow_downward_rounded,
                  color: AppColors.success, size: 20.sp),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${voucher.voucherNumber}',
                    style: AppTypography.titleSmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    DateFormat('yyyy/MM/dd').format(voucher.voucherDate),
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${voucher.amount.toStringAsFixed(0)} ل.س',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
