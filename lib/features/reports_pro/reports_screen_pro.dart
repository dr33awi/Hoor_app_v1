// ═══════════════════════════════════════════════════════════════════════════
// Reports Screen Pro - Enterprise Design System
// Reports Hub with Professional Business Analytics
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════
//
// ⚠️ السياسة المحاسبية الصارمة - STRICT ACCOUNTING POLICY ⚠️
// ─────────────────────────────────────────────────────────────────────────────
// ❌ ممنوع: استخدام CurrencyService.currentRate في حسابات التقارير
// ❌ ممنوع: تحويل العملات (syp / currentRate) في التقارير
// ✅ مطلوب: استخدام القيم المحفوظة (invoice.total, invoice.totalUsd)
// ✅ مطلوب: جمع القيم مباشرة بدون تحويل
// ─────────────────────────────────────────────────────────────────────────────

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
import '../../core/mixins/invoice_filter_mixin.dart';
import '../../core/services/export/export_button.dart';
import '../../core/services/export/reports_export_service.dart';
import '../../data/database/app_database.dart';

class ReportsScreenPro extends ConsumerWidget {
  const ReportsScreenPro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesInvoicesProvider);
    final purchasesAsync = ref.watch(purchaseInvoicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProHeader(
              title: 'التقارير',
              subtitle: 'تحليل البيانات والأداء',
              onBack: () => context.go('/'),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.date_range_rounded),
                  tooltip: 'تحديد الفترة',
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats
                    _buildQuickStats(salesAsync, purchasesAsync),
                    SizedBox(height: AppSpacing.md),

                    // Sales Reports
                    _buildSectionTitle('تقارير المبيعات'),
                    SizedBox(height: AppSpacing.sm),
                    _ReportCard(
                      title: 'تقرير المبيعات',
                      description: 'إجمالي المبيعات والإيرادات',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.success,
                      onTap: () => context.push('/reports/sales'),
                    ),

                    SizedBox(height: AppSpacing.md),

                    // Purchase Reports
                    _buildSectionTitle('تقارير المشتريات'),
                    SizedBox(height: AppSpacing.sm),
                    _ReportCard(
                      title: 'تقرير المشتريات',
                      description: 'إجمالي المشتريات والتكاليف',
                      icon: Icons.shopping_cart_rounded,
                      color: AppColors.secondary,
                      onTap: () => context.push('/reports/purchases'),
                    ),

                    SizedBox(height: AppSpacing.md),

                    // Financial Reports
                    _buildSectionTitle('التقارير المالية'),
                    SizedBox(height: AppSpacing.sm),
                    _ReportCard(
                      title: 'تقرير الأرباح والخسائر',
                      description: 'صافي الربح والمصروفات',
                      icon: Icons.analytics_rounded,
                      color: AppColors.success,
                      onTap: () => context.push('/reports/profit'),
                    ),
                    _ReportCard(
                      title: 'تقرير الذمم المدينة',
                      description: 'المبالغ المستحقة من العملاء',
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.error,
                      onTap: () => context.push('/reports/receivables'),
                    ),
                    _ReportCard(
                      title: 'تقرير الذمم الدائنة',
                      description: 'المبالغ المستحقة للموردين',
                      icon: Icons.payments_rounded,
                      color: AppColors.warning,
                      onTap: () => context.push('/reports/payables'),
                    ),

                    SizedBox(height: AppSpacing.md),

                    // Inventory Reports
                    _buildSectionTitle('تقارير المخزون'),
                    SizedBox(height: AppSpacing.sm),
                    _ReportCard(
                      title: 'تقرير المخزون',
                      description: 'الكميات والقيم الحالية',
                      icon: Icons.inventory_2_rounded,
                      color: AppColors.secondary,
                      onTap: () => context.push('/reports/inventory'),
                    ),

                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(
    AsyncValue<List<Invoice>> salesAsync,
    AsyncValue<List<Invoice>> purchasesAsync,
  ) {
    final salesTotal = salesAsync.when(
      data: (invoices) {
        final now = DateTime.now();
        return invoices
            .where((inv) =>
                inv.invoiceDate.month == now.month &&
                inv.invoiceDate.year == now.year)
            .fold(0.0, (sum, inv) => sum + inv.total);
      },
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    final purchasesTotal = purchasesAsync.when(
      data: (invoices) {
        final now = DateTime.now();
        return invoices
            .where((inv) =>
                inv.invoiceDate.month == now.month &&
                inv.invoiceDate.year == now.year)
            .fold(0.0, (sum, inv) => sum + inv.total);
      },
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    final profit = salesTotal - purchasesTotal;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الشهر الحالي',
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatItem(
                  label: 'المبيعات',
                  value: salesTotal.toStringAsFixed(0),
                  icon: Icons.arrow_upward_rounded,
                  trend: '',
                  isPositive: true,
                ),
              ),
              Container(
                width: 1,
                height: 50.h,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildQuickStatItem(
                  label: 'المشتريات',
                  value: purchasesTotal.toStringAsFixed(0),
                  icon: Icons.arrow_downward_rounded,
                  trend: '',
                  isPositive: false,
                ),
              ),
              Container(
                width: 1,
                height: 50.h,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildQuickStatItem(
                  label: 'صافي الربح',
                  value: profit.toStringAsFixed(0),
                  icon: profit >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  trend: '',
                  isPositive: profit >= 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem({
    required String label,
    required String value,
    required IconData icon,
    required String trend,
    required bool isPositive,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Container(
          padding:
              EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12.sp,
                color: Colors.white,
              ),
              SizedBox(width: 2.w),
              Text(
                trend,
                style: AppTypography.labelSmall
                    .copyWith(
                      color: Colors.white,
                    )
                    .mono,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.soft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: AppIconSize.md),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Report Detail Screen Pro - Full Implementation with Export
// ═══════════════════════════════════════════════════════════════════════════

class ReportDetailScreenPro extends ConsumerStatefulWidget {
  final String reportType;

  const ReportDetailScreenPro({
    super.key,
    required this.reportType,
  });

  @override
  ConsumerState<ReportDetailScreenPro> createState() =>
      _ReportDetailScreenProState();
}

class _ReportDetailScreenProState extends ConsumerState<ReportDetailScreenPro>
    with InvoiceFilterMixin {
  DateTimeRange? _dateRange;
  bool _isExporting = false;

  String get _title {
    switch (widget.reportType) {
      case 'sales':
        return 'تقرير المبيعات';
      case 'purchases':
        return 'تقرير المشتريات';
      case 'profit':
        return 'تقرير الأرباح والخسائر';
      case 'receivables':
        return 'تقرير الذمم المدينة';
      case 'payables':
        return 'تقرير الذمم الدائنة';
      case 'inventory':
        return 'تقرير المخزون';
      default:
        return 'تقرير';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProAppBar.simple(
        title: _title,
        actions: [
          ProAppBarAction(
            icon: Icons.date_range_rounded,
            onPressed: _selectDateRange,
            color: _dateRange != null ? AppColors.primary : null,
          ),
          ExportMenuButton(
            onExport: _handleExportMenu,
            isLoading: _isExporting,
            icon: Icons.more_vert,
            tooltip: 'خيارات التصدير',
            enabledOptions: const {
              ExportType.excel,
              ExportType.pdf,
              ExportType.sharePdf,
              ExportType.shareExcel,
            },
          ),
        ],
      ),
      body: _isExporting
          ? ProLoadingState.withMessage(message: 'جاري التصدير...')
          : _buildReportContent(),
    );
  }

  Widget _buildReportContent() {
    switch (widget.reportType) {
      case 'sales':
        return _buildSalesReport();
      case 'purchases':
        return _buildPurchasesReport();
      case 'profit':
        return _buildProfitReport();
      case 'receivables':
        return _buildReceivablesReport();
      case 'payables':
        return _buildPayablesReport();
      case 'inventory':
        return _buildInventoryReport();
      default:
        return _buildPlaceholder();
    }
  }

  Widget _buildSalesReport() {
    final invoicesAsync = ref.watch(salesInvoicesProvider);

    return invoicesAsync.when(
      loading: () => ProLoadingState.list(),
      error: (error, _) => ProEmptyState.error(error: error.toString()),
      data: (invoices) {
        final filtered = _filterByDate(invoices);
        // ═══════════════════════════════════════════════════════════════════
        // ⚠️ السياسة المحاسبية: جمع القيم المحفوظة مباشرة - بدون تحويل
        // ═══════════════════════════════════════════════════════════════════
        final totalSyp =
            filtered.fold<double>(0, (sum, inv) => sum + inv.total);
        final totalUsd =
            filtered.fold<double>(0, (sum, inv) => sum + (inv.totalUsd ?? 0));
        final count = filtered.length;

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRangeChip(),
              SizedBox(height: AppSpacing.md),
              _buildSummaryCardsWithLockedPrice(
                totalSyp: totalSyp,
                totalUsd: totalUsd,
                count: count,
                label: 'إجمالي المبيعات',
                color: AppColors.success,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildInvoicesList(filtered),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchasesReport() {
    final invoicesAsync = ref.watch(purchaseInvoicesProvider);

    return invoicesAsync.when(
      loading: () => ProLoadingState.list(),
      error: (error, _) => ProEmptyState.error(error: error.toString()),
      data: (invoices) {
        final filtered = _filterByDate(invoices);
        // ═══════════════════════════════════════════════════════════════════
        // ⚠️ السياسة المحاسبية: جمع القيم المحفوظة مباشرة - بدون تحويل
        // ═══════════════════════════════════════════════════════════════════
        final totalSyp =
            filtered.fold<double>(0, (sum, inv) => sum + inv.total);
        final totalUsd =
            filtered.fold<double>(0, (sum, inv) => sum + (inv.totalUsd ?? 0));
        final count = filtered.length;

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRangeChip(),
              SizedBox(height: AppSpacing.md),
              _buildSummaryCardsWithLockedPrice(
                totalSyp: totalSyp,
                totalUsd: totalUsd,
                count: count,
                label: 'إجمالي المشتريات',
                color: AppColors.secondary,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildInvoicesList(filtered),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfitReport() {
    // ═══════════════════════════════════════════════════════════════════════
    // ✅ السياسة المحاسبية الصحيحة:
    // صافي الربح = إجمالي الربح - المصاريف - مرتجعات المبيعات + مرتجعات المشتريات ± فروقات الجرد
    // ═══════════════════════════════════════════════════════════════════════
    final db = ref.read(databaseProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: db.getEnhancedProfitReport(
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ProLoadingState.list();
        }

        if (snapshot.hasError) {
          return ProEmptyState.error(error: snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return const ProEmptyState(
            icon: Icons.analytics_rounded,
            title: 'لا توجد بيانات',
            message: 'لم يتم العثور على بيانات للفترة المحددة',
          );
        }

        final report = snapshot.data!;
        final totalRevenue = report['totalRevenue'] as double;
        final totalRevenueUsd = report['totalRevenueUsd'] as double;
        final grossProfit = report['grossProfit'] as double;
        final grossProfitUsd = report['grossProfitUsd'] as double;
        final totalExpenses = report['totalExpenses'] as double;
        final totalExpensesUsd = report['totalExpensesUsd'] as double;
        final totalSaleReturns = report['totalSaleReturns'] as double;
        final totalSaleReturnsUsd = report['totalSaleReturnsUsd'] as double;
        final totalPurchaseReturns = report['totalPurchaseReturns'] as double;
        final totalPurchaseReturnsUsd =
            report['totalPurchaseReturnsUsd'] as double;
        final inventoryAdjustments =
            report['inventoryAdjustments'] as double? ?? 0;
        final inventoryAdjustmentsUsd =
            report['inventoryAdjustmentsUsd'] as double? ?? 0;
        final netProfit = report['netProfit'] as double;
        final netProfitUsd = report['netProfitUsd'] as double;
        final profitMargin = report['profitMargin'] as double;

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRangeChip(),
              SizedBox(height: AppSpacing.md),

              // صافي الربح (العنصر الرئيسي)
              _buildNetProfitCard(
                netProfit: netProfit,
                netProfitUsd: netProfitUsd,
                profitMargin: profitMargin,
              ),
              SizedBox(height: AppSpacing.md),

              // تفاصيل الإيرادات
              Text('الإيرادات', style: AppTypography.titleMedium),
              SizedBox(height: AppSpacing.sm),
              _buildProfitDetailRow(
                label: 'إجمالي المبيعات',
                amountSyp: totalRevenue,
                amountUsd: totalRevenueUsd,
                icon: Icons.shopping_cart_rounded,
                color: AppColors.success,
              ),
              _buildProfitDetailRow(
                label: 'إجمالي الربح (قبل المصاريف)',
                amountSyp: grossProfit,
                amountUsd: grossProfitUsd,
                icon: Icons.trending_up_rounded,
                color: AppColors.info,
              ),
              if (totalPurchaseReturns > 0)
                _buildProfitDetailRow(
                  label: 'مرتجعات المشتريات (+)',
                  amountSyp: totalPurchaseReturns,
                  amountUsd: totalPurchaseReturnsUsd,
                  icon: Icons.assignment_return_rounded,
                  color: AppColors.success,
                ),

              SizedBox(height: AppSpacing.md),

              // التكاليف والمصروفات
              Text('التكاليف والمصروفات', style: AppTypography.titleMedium),
              SizedBox(height: AppSpacing.sm),
              _buildProfitDetailRow(
                label: 'المصروفات',
                amountSyp: totalExpenses,
                amountUsd: totalExpensesUsd,
                icon: Icons.receipt_long_rounded,
                color: AppColors.error,
                isNegative: true,
              ),
              if (totalSaleReturns > 0)
                _buildProfitDetailRow(
                  label: 'مرتجعات المبيعات (-)',
                  amountSyp: totalSaleReturns,
                  amountUsd: totalSaleReturnsUsd,
                  icon: Icons.replay_rounded,
                  color: AppColors.error,
                  isNegative: true,
                ),
              if (inventoryAdjustments != 0)
                _buildProfitDetailRow(
                  label: inventoryAdjustments > 0
                      ? 'مكاسب جرد (+)'
                      : 'خسائر جرد (-)',
                  amountSyp: inventoryAdjustments.abs(),
                  amountUsd: inventoryAdjustmentsUsd.abs(),
                  icon: Icons.inventory_rounded,
                  color: inventoryAdjustments > 0
                      ? AppColors.success
                      : AppColors.warning,
                  isNegative: inventoryAdjustments < 0,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNetProfitCard({
    required double netProfit,
    required double netProfitUsd,
    required double profitMargin,
  }) {
    final isProfit = netProfit >= 0;
    final numberFormat = NumberFormat('#,###');

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: isProfit
            ? LinearGradient(
                colors: [
                  AppColors.success,
                  AppColors.success.withValues(alpha: 0.8)
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.error,
                  AppColors.error.withValues(alpha: 0.8)
                ],
              ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isProfit
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: Colors.white,
                size: 28.sp,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                isProfit ? 'صافي الربح' : 'صافي الخسارة',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '${numberFormat.format(netProfit.abs())} ل.س',
            style: AppTypography.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$${numberFormat.format(netProfitUsd.abs())}',
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              'هامش الربح: ${profitMargin.toStringAsFixed(1)}%',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitDetailRow({
    required String label,
    required double amountSyp,
    required double amountUsd,
    required IconData icon,
    required Color color,
    bool isNegative = false,
  }) {
    final numberFormat = NumberFormat('#,###');

    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isNegative ? "-" : ""}${numberFormat.format(amountSyp)} ل.س',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isNegative ? AppColors.error : null,
                ),
              ),
              if (amountUsd > 0)
                Text(
                  '${isNegative ? "-" : ""}\$${numberFormat.format(amountUsd)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceivablesReport() {
    final invoicesAsync = ref.watch(salesInvoicesProvider);

    return invoicesAsync.when(
      loading: () => ProLoadingState.list(),
      error: (error, _) => ProEmptyState.error(error: error.toString()),
      data: (invoices) {
        final unpaid = invoices
            .where((inv) => inv.status == 'unpaid' || inv.status == 'partial')
            .toList();
        // ═══════════════════════════════════════════════════════════════════
        // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة
        // ═══════════════════════════════════════════════════════════════════
        final totalSyp = unpaid.fold<double>(
            0, (sum, inv) => sum + (inv.total - inv.paidAmount));
        final totalUsd = unpaid.fold<double>(
            0,
            (sum, inv) =>
                sum + ((inv.totalUsd ?? 0) - (inv.paidAmountUsd ?? 0)));

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCardsWithLockedPrice(
                totalSyp: totalSyp,
                totalUsd: totalUsd,
                count: unpaid.length,
                label: 'إجمالي المستحقات',
                color: AppColors.error,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildInvoicesList(unpaid),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPayablesReport() {
    final suppliersAsync = ref.watch(suppliersStreamProvider);

    return suppliersAsync.when(
      loading: () => ProLoadingState.list(),
      error: (error, _) => ProEmptyState.error(error: error.toString()),
      data: (suppliers) {
        final withBalance = suppliers.where((s) => s.balance > 0).toList();
        // ═══════════════════════════════════════════════════════════════════
        // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة (balanceUsd)
        // ═══════════════════════════════════════════════════════════════════
        final totalSyp =
            withBalance.fold<double>(0, (sum, s) => sum + s.balance);
        final totalUsd =
            withBalance.fold<double>(0, (sum, s) => sum + (s.balanceUsd ?? 0));

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCardsWithLockedPrice(
                totalSyp: totalSyp,
                totalUsd: totalUsd,
                count: withBalance.length,
                label: 'إجمالي المستحقات للموردين',
                color: AppColors.warning,
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'الموردين (${withBalance.length})',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              if (withBalance.isEmpty)
                const ProEmptyState(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'لا توجد مستحقات',
                  message: 'جميع الموردين لا يوجد لديهم مستحقات',
                )
              else
                ...withBalance.map((supplier) => ProCard.flat(
                      margin: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          ProIconBox(
                            icon: Icons.business_rounded,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  supplier.name,
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (supplier.phone != null)
                                  Text(
                                    supplier.phone!,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // ⚠️ استخدام القيم المحفوظة
                          CompactDualPrice(
                            amountSyp: supplier.balance,
                            amountUsd: supplier.balanceUsd ?? 0,
                            sypStyle: AppTypography.titleSmall.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                            usdStyle: AppTypography.labelSmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryReport() {
    final productsAsync = ref.watch(activeProductsStreamProvider);

    return productsAsync.when(
      loading: () => ProLoadingState.list(),
      error: (error, _) => ProEmptyState.error(error: error.toString()),
      data: (products) {
        final totalItems = products.fold<int>(0, (sum, p) => sum + p.quantity);
        // ═══════════════════════════════════════════════════════════════════
        // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة
        // قيمة المخزون = الكمية × سعر الشراء المحفوظ (بدون تحويل)
        // ═══════════════════════════════════════════════════════════════════
        final totalValueSyp = products.fold<double>(
            0, (sum, p) => sum + (p.quantity * p.purchasePrice));
        final totalValueUsd = products.fold<double>(
            0, (sum, p) => sum + (p.quantity * (p.purchasePriceUsd ?? 0)));
        final lowStock =
            products.where((p) => p.quantity <= p.minQuantity).length;
        final outOfStock = products.where((p) => p.quantity <= 0).length;

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'إجمالي المنتجات',
                      value: '${products.length}',
                      icon: Icons.inventory_2_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SummaryCard(
                      title: 'إجمالي القطع',
                      value: NumberFormat('#,###').format(totalItems),
                      icon: Icons.category_rounded,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _LockedPriceSummaryCard(
                      title: 'قيمة المخزون',
                      amountSyp: totalValueSyp,
                      amountUsd: totalValueUsd,
                      icon: Icons.attach_money_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SummaryCard(
                      title: 'مخزون منخفض',
                      value: '$lowStock',
                      icon: Icons.warning_rounded,
                      color: lowStock > 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Low Stock Alert
              if (lowStock > 0) ...[
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.soft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.error.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_rounded, color: AppColors.error),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$lowStock منتجات تحت الحد الأدنى',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (outOfStock > 0)
                              Text(
                                'منها $outOfStock نفدت بالكامل',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
              ],

              // Products List
              Text(
                'المنتجات (${products.length})',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              ...products.take(20).map((product) => ProCard.flat(
                    margin: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: product.quantity <= product.minQuantity
                                ? AppColors.error.soft
                                : AppColors.secondary.soft,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Center(
                            child: Text(
                              '${product.quantity}',
                              style: AppTypography.titleSmall.copyWith(
                                color: product.quantity <= product.minQuantity
                                    ? AppColors.error
                                    : AppColors.secondary,
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
                                product.name,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'الحد الأدنى: ${product.minQuantity}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ⚠️ استخدام القيم المحفوظة
                        CompactDualPrice(
                          amountSyp: product.quantity * product.purchasePrice,
                          amountUsd: product.quantity *
                              (product.purchasePriceUsd ?? 0),
                          sypStyle: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          usdStyle: AppTypography.labelSmall
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 80.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'قريباً',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeChip() {
    if (_dateRange == null) return const SizedBox.shrink();

    final format = DateFormat('yyyy/MM/dd', 'ar');
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.soft,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range, size: 16.sp, color: AppColors.primary),
          SizedBox(width: AppSpacing.xs),
          Text(
            '${format.format(_dateRange!.start)} - ${format.format(_dateRange!.end)}',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: () => setState(() => _dateRange = null),
            child: Icon(Icons.close, size: 16.sp, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ⚠️ بطاقات الملخص - تستخدم القيم المحفوظة (LockedPrice)
  // ═══════════════════════════════════════════════════════════════════════════

  /// بطاقة ملخص مع قيم مثبتة (السياسة المحاسبية الصارمة)
  Widget _buildSummaryCardsWithLockedPrice({
    required double totalSyp,
    required double totalUsd,
    required int count,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: _LockedPriceSummaryCard(
            title: label,
            amountSyp: totalSyp,
            amountUsd: totalUsd,
            icon: Icons.attach_money_rounded,
            color: color,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SummaryCard(
            title: 'عدد الفواتير',
            value: '$count',
            icon: Icons.receipt_long_rounded,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  /// بطاقات الأرباح مع قيم مثبتة (السياسة المحاسبية الصارمة)
  Widget _buildProfitCardsWithLockedPrice({
    required double salesSyp,
    required double salesUsd,
    required double purchasesSyp,
    required double purchasesUsd,
    required double profitSyp,
    required double profitUsd,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _LockedPriceSummaryCard(
                title: 'المبيعات',
                amountSyp: salesSyp,
                amountUsd: salesUsd,
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _LockedPriceSummaryCard(
                title: 'المشتريات',
                amountSyp: purchasesSyp,
                amountUsd: purchasesUsd,
                icon: Icons.trending_down_rounded,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        _LockedPriceSummaryCard(
          title: 'صافي الربح',
          amountSyp: profitSyp,
          amountUsd: profitUsd,
          icon: profitSyp >= 0
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
          color: profitSyp >= 0 ? AppColors.success : AppColors.error,
          isLarge: true,
        ),
      ],
    );
  }

  Widget _buildInvoicesList(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 48.sp, color: AppColors.textTertiary),
              SizedBox(height: AppSpacing.md),
              Text(
                'لا توجد فواتير',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفواتير (${invoices.length})',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ...invoices.take(20).map((inv) => _InvoiceListItem(invoice: inv)),
        if (invoices.length > 20)
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text('عرض الكل (${invoices.length})'),
            ),
          ),
      ],
    );
  }

  // استخدام InvoiceFilterMixin للفلترة الموحدة
  List<Invoice> _filterByDate(List<Invoice> invoices) {
    return filterInvoices(invoices, dateRange: _dateRange);
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      locale: const Locale('ar'),
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  Future<void> _handleExportMenu(ExportType type) async {
    setState(() => _isExporting = true);

    try {
      switch (widget.reportType) {
        case 'sales':
          await _exportSalesReport(type);
          break;
        case 'purchases':
          await _exportPurchasesReport(type);
          break;
        case 'profit':
          await _exportProfitReport(type);
          break;
        case 'receivables':
          await _exportReceivablesReport(type);
          break;
        case 'payables':
          await _exportPayablesReport(type);
          break;
        case 'inventory':
          await _exportInventoryReport(type);
          break;
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportSalesReport(ExportType type) async {
    final data = ref.read(salesInvoicesProvider);
    final invoices = _filterByDate(data.value ?? []);

    if (invoices.isEmpty) {
      if (mounted) ProSnackbar.warning(context, 'لا توجد بيانات للتصدير');
      return;
    }

    switch (type) {
      case ExportType.excel:
        await ReportsExportService.exportSalesReportToExcel(
          invoices: invoices,
          dateRange: _dateRange,
        );
        if (mounted)
          ProSnackbar.success(context, 'تم تصدير تقرير المبيعات إلى Excel');
        break;
      case ExportType.pdf:
        final bytes = await ReportsExportService.generateSalesReportPdf(
          invoices: invoices,
          dateRange: _dateRange,
        );
        await ReportsExportService.savePdf(bytes, 'sales_report');
        if (mounted)
          ProSnackbar.success(context, 'تم تصدير تقرير المبيعات إلى PDF');
        break;
      case ExportType.sharePdf:
        final bytes = await ReportsExportService.generateSalesReportPdf(
          invoices: invoices,
          dateRange: _dateRange,
        );
        await ReportsExportService.sharePdfBytes(bytes,
            fileName: 'sales_report', subject: 'تقرير المبيعات');
        break;
      case ExportType.shareExcel:
        final filePath = await ReportsExportService.exportSalesReportToExcel(
          invoices: invoices,
          dateRange: _dateRange,
        );
        await ReportsExportService.shareFile(filePath,
            subject: 'تقرير المبيعات');
        break;
    }
  }

  Future<void> _exportPurchasesReport(ExportType type) async {
    final data = ref.read(purchaseInvoicesProvider);
    final invoices = _filterByDate(data.value ?? []);

    if (invoices.isEmpty) {
      if (mounted) ProSnackbar.warning(context, 'لا توجد بيانات للتصدير');
      return;
    }

    switch (type) {
      case ExportType.excel:
        await ReportsExportService.exportPurchasesReportToExcel(
          invoices: invoices,
          dateRange: _dateRange,
        );
        if (mounted)
          ProSnackbar.success(context, 'تم تصدير تقرير المشتريات إلى Excel');
        break;
      case ExportType.pdf:
        final bytes = await ReportsExportService.generatePurchasesReportPdf(
          invoices: invoices,
          dateRange: _dateRange,
        );
        await ReportsExportService.savePdf(bytes, 'purchases_report');
        if (mounted)
          ProSnackbar.success(context, 'تم تصدير تقرير المشتريات إلى PDF');
        break;
      case ExportType.sharePdf:
        final bytes = await ReportsExportService.generatePurchasesReportPdf(
          invoices: invoices,
          dateRange: _dateRange,
        );
        await ReportsExportService.sharePdfBytes(bytes,
            fileName: 'purchases_report', subject: 'تقرير المشتريات');
        break;
      case ExportType.shareExcel:
        final filePath =
            await ReportsExportService.exportPurchasesReportToExcel(
          invoices: invoices,
          dateRange: _dateRange,
        );
        await ReportsExportService.shareFile(filePath,
            subject: 'تقرير المشتريات');
        break;
    }
  }

  Future<void> _exportProfitReport(ExportType type) async {
    final salesData = ref.read(salesInvoicesProvider);
    final purchasesData = ref.read(purchaseInvoicesProvider);

    final sales = _filterByDate(salesData.value ?? []);
    final purchases = _filterByDate(purchasesData.value ?? []);

    if (sales.isEmpty && purchases.isEmpty) {
      if (mounted) ProSnackbar.warning(context, 'لا توجد بيانات للتصدير');
      return;
    }

    switch (type) {
      case ExportType.excel:
        await ReportsExportService.exportProfitReportToExcel(
          sales: sales,
          purchases: purchases,
          dateRange: _dateRange,
        );
        if (mounted)
          ProSnackbar.success(
              context, 'تم تصدير تقرير الأرباح والخسائر إلى Excel');
        break;
      case ExportType.pdf:
        final bytes = await ReportsExportService.generateProfitReportPdf(
          sales: sales,
          purchases: purchases,
          dateRange: _dateRange,
        );
        await ReportsExportService.savePdf(bytes, 'profit_report');
        if (mounted)
          ProSnackbar.success(
              context, 'تم تصدير تقرير الأرباح والخسائر إلى PDF');
        break;
      case ExportType.sharePdf:
        final bytes = await ReportsExportService.generateProfitReportPdf(
          sales: sales,
          purchases: purchases,
          dateRange: _dateRange,
        );
        await ReportsExportService.sharePdfBytes(bytes,
            fileName: 'profit_report', subject: 'تقرير الأرباح والخسائر');
        break;
      case ExportType.shareExcel:
        final filePath = await ReportsExportService.exportProfitReportToExcel(
          sales: sales,
          purchases: purchases,
          dateRange: _dateRange,
        );
        await ReportsExportService.shareFile(filePath,
            subject: 'تقرير الأرباح والخسائر');
        break;
    }
  }

  Future<void> _exportReceivablesReport(ExportType type) async {
    final customersData = ref.read(customersStreamProvider);
    final customers = customersData.value ?? [];

    if (customers.isEmpty) {
      if (mounted) ProSnackbar.warning(context, 'لا توجد بيانات للتصدير');
      return;
    }

    switch (type) {
      case ExportType.excel:
        await ReportsExportService.exportReceivablesReportToExcel(
            customers: customers);
        if (mounted)
          ProSnackbar.success(
              context, 'تم تصدير تقرير الذمم المدينة إلى Excel');
        break;
      case ExportType.pdf:
        final bytes = await ReportsExportService.generateReceivablesReportPdf(
            customers: customers);
        await ReportsExportService.savePdf(bytes, 'receivables_report');
        if (mounted)
          ProSnackbar.success(context, 'تم تصدير تقرير الذمم المدينة إلى PDF');
        break;
      case ExportType.sharePdf:
        final bytes = await ReportsExportService.generateReceivablesReportPdf(
            customers: customers);
        await ReportsExportService.sharePdfBytes(bytes,
            fileName: 'receivables_report', subject: 'تقرير الذمم المدينة');
        break;
      case ExportType.shareExcel:
        final filePath =
            await ReportsExportService.exportReceivablesReportToExcel(
                customers: customers);
        await ReportsExportService.shareFile(filePath,
            subject: 'تقرير الذمم المدينة');
        break;
    }
  }

  Future<void> _exportPayablesReport(ExportType type) async {
    final suppliersData = ref.read(suppliersStreamProvider);
    final suppliers = suppliersData.value ?? [];

    if (suppliers.isEmpty) {
      if (mounted) ProSnackbar.warning(context, 'لا توجد بيانات للتصدير');
      return;
    }

    switch (type) {
      case ExportType.excel:
        await ReportsExportService.exportPayablesReportToExcel(
            suppliers: suppliers);
        if (mounted)
          ProSnackbar.success(
              context, 'تم تصدير تقرير الذمم الدائنة إلى Excel');
        break;
      case ExportType.pdf:
        final bytes = await ReportsExportService.generatePayablesReportPdf(
            suppliers: suppliers);
        await ReportsExportService.savePdf(bytes, 'payables_report');
        if (mounted)
          ProSnackbar.success(context, 'تم تصدير تقرير الذمم الدائنة إلى PDF');
        break;
      case ExportType.sharePdf:
        final bytes = await ReportsExportService.generatePayablesReportPdf(
            suppliers: suppliers);
        await ReportsExportService.sharePdfBytes(bytes,
            fileName: 'payables_report', subject: 'تقرير الذمم الدائنة');
        break;
      case ExportType.shareExcel:
        final filePath = await ReportsExportService.exportPayablesReportToExcel(
            suppliers: suppliers);
        await ReportsExportService.shareFile(filePath,
            subject: 'تقرير الذمم الدائنة');
        break;
    }
  }

  Future<void> _exportInventoryReport(ExportType type) async {
    final productsData = ref.read(activeProductsStreamProvider);
    final products = productsData.value ?? [];

    if (products.isEmpty) {
      if (mounted) ProSnackbar.warning(context, 'لا توجد بيانات للتصدير');
      return;
    }

    // جلب الكميات المباعة
    final db = ref.read(databaseProvider);
    final soldQuantities = await db.getProductSoldQuantities();

    switch (type) {
      case ExportType.excel:
        await ReportsExportService.exportInventoryReportToExcel(
          products: products,
          soldQuantities: soldQuantities,
        );
        if (mounted)
          ProSnackbar.success(context, 'تم تصدير تقرير المخزون إلى Excel');
        break;
      case ExportType.pdf:
        final bytes = await ReportsExportService.generateInventoryReportPdf(
          products: products,
          soldQuantities: soldQuantities,
        );
        await ReportsExportService.savePdf(bytes, 'inventory_report');
        if (mounted)
          ProSnackbar.success(context, 'تم تصدير تقرير المخزون إلى PDF');
        break;
      case ExportType.sharePdf:
        final bytes = await ReportsExportService.generateInventoryReportPdf(
          products: products,
          soldQuantities: soldQuantities,
        );
        await ReportsExportService.sharePdfBytes(bytes,
            fileName: 'inventory_report', subject: 'تقرير المخزون');
        break;
      case ExportType.shareExcel:
        final filePath =
            await ReportsExportService.exportInventoryReportToExcel(
          products: products,
          soldQuantities: soldQuantities,
        );
        await ReportsExportService.shareFile(filePath,
            subject: 'تقرير المخزون');
        break;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProCard(
      padding: EdgeInsets.all(isLarge ? AppSpacing.lg : AppSpacing.md),
      borderColor: color.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: isLarge ? 24.sp : 20.sp),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: (isLarge
                    ? AppTypography.headlineMedium
                    : AppTypography.titleLarge)
                .copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// بطاقة ملخص مع قيم مثبتة (LockedPrice)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// ⚠️ السياسة المحاسبية:
/// - تعرض القيم المحفوظة مباشرة (amountSyp, amountUsd)
/// - لا تقوم بأي تحويل عملات
/// ═══════════════════════════════════════════════════════════════════════════
class _LockedPriceSummaryCard extends StatelessWidget {
  final String title;
  final double amountSyp;
  final double amountUsd;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _LockedPriceSummaryCard({
    required this.title,
    required this.amountSyp,
    required this.amountUsd,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return ProCard(
      padding: EdgeInsets.all(isLarge ? AppSpacing.lg : AppSpacing.md),
      borderColor: color.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: isLarge ? 24.sp : 20.sp),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // ⚠️ عرض مزدوج للعملة - القيم المحفوظة
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${numberFormat.format(amountSyp)} ل.س',
                style: (isLarge
                        ? AppTypography.headlineMedium
                        : AppTypography.titleLarge)
                    .copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '\$${numberFormat.format(amountUsd)}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceListItem extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceListItem({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy/MM/dd', 'ar');

    return ProCard.flat(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  invoice.customerId ?? invoice.supplierId ?? '-',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة (totalUsd)
              CompactDualPrice(
                amountSyp: invoice.total,
                amountUsd: invoice.totalUsd ?? 0,
                sypStyle: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
                usdStyle: AppTypography.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              Text(
                format.format(invoice.invoiceDate),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
