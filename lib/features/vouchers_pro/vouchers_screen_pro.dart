// ═══════════════════════════════════════════════════════════════════════════
// Vouchers Screen Pro - Enterprise Design System
// Voucher Management Interface
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hoor_manager/data/repositories/voucher_repository.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/currency_service.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/dual_price_display.dart';
import '../../core/services/export/export_services.dart';
import '../../core/services/export/export_button.dart';
import '../../data/database/app_database.dart';

class VouchersScreenPro extends ConsumerStatefulWidget {
  const VouchersScreenPro({super.key});

  @override
  ConsumerState<VouchersScreenPro> createState() => _VouchersScreenProState();
}

class _VouchersScreenProState extends ConsumerState<VouchersScreenPro>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  DateTimeRange? _dateRange;
  bool _isExporting = false;
  String? _selectedCategoryId; // فلتر فئة المصاريف
  List<VoucherCategory> _expenseCategories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadExpenseCategories();
  }

  Future<void> _loadExpenseCategories() async {
    final voucherRepo = ref.read(voucherRepositoryProvider);
    final categories =
        await voucherRepo.getCategoriesByType(VoucherType.expense);
    if (mounted) {
      setState(() => _expenseCategories = categories);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Voucher> _filterVouchers(List<Voucher> vouchers, String? type) {
    var filtered = vouchers;

    if (type != null) {
      filtered = filtered.where((v) => v.type == type).toList();
    }

    // تصفية حسب فئة المصاريف
    if (type == 'expense' && _selectedCategoryId != null) {
      filtered =
          filtered.where((v) => v.categoryId == _selectedCategoryId).toList();
    }

    // تصفية حسب نطاق التاريخ
    if (_dateRange != null) {
      filtered = filtered.where((v) {
        return v.voucherDate
                .isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            v.voucherDate
                .isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((v) =>
              v.voucherNumber.toLowerCase().contains(query) ||
              (v.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Sort by date descending
    filtered.sort((a, b) => b.voucherDate.compareTo(a.voucherDate));

    return filtered;
  }

  double _totalReceipts(List<Voucher> vouchers) => vouchers
      .where((v) => v.type == 'receipt')
      .fold(0.0, (sum, v) => sum + v.amount);

  double _totalPayments(List<Voucher> vouchers) => vouchers
      .where((v) => v.type == 'payment')
      .fold(0.0, (sum, v) => sum + v.amount);

  double _totalExpenses(List<Voucher> vouchers) => vouchers
      .where((v) => v.type == 'expense')
      .fold(0.0, (sum, v) => sum + v.amount);

  // حساب المبالغ بالدولار باستخدام سعر الصرف المحفوظ
  double _totalReceiptsUsd(List<Voucher> vouchers) =>
      vouchers.where((v) => v.type == 'receipt').fold(
          0.0,
          (sum, v) =>
              sum +
              (v.amountUsd ??
                  (v.exchangeRate > 0 ? v.amount / v.exchangeRate : 0)));

  double _totalPaymentsUsd(List<Voucher> vouchers) =>
      vouchers.where((v) => v.type == 'payment').fold(
          0.0,
          (sum, v) =>
              sum +
              (v.amountUsd ??
                  (v.exchangeRate > 0 ? v.amount / v.exchangeRate : 0)));

  double _totalExpensesUsd(List<Voucher> vouchers) =>
      vouchers.where((v) => v.type == 'expense').fold(
          0.0,
          (sum, v) =>
              sum +
              (v.amountUsd ??
                  (v.exchangeRate > 0 ? v.amount / v.exchangeRate : 0)));

  @override
  Widget build(BuildContext context) {
    final vouchersAsync = ref.watch(vouchersStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: vouchersAsync.when(
          loading: () => ProLoadingState.list(),
          error: (error, stack) => ProEmptyState.error(error: error.toString()),
          data: (vouchers) {
            final filteredVouchers = _filterVouchers(vouchers, null);
            return Column(
              children: [
                _buildHeader(vouchers.length, filteredVouchers),
                _buildStatsSummary(filteredVouchers),
                _buildSearchBar(),
                _buildFiltersRow(),
                _buildTabs(filteredVouchers),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVoucherList(_filterVouchers(vouchers, null)),
                      _buildVoucherList(_filterVouchers(vouchers, 'receipt')),
                      _buildVoucherList(_filterVouchers(vouchers, 'payment')),
                      _buildExpenseTab(vouchers),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVoucherOptions(context),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'سند جديد',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  void _showAddVoucherOptions(BuildContext context) {
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
              'إضافة سند جديد',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _VoucherTypeButton(
                    icon: Icons.arrow_downward_rounded,
                    label: 'سند قبض',
                    subtitle: 'استلام من عميل',
                    color: AppColors.success,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/vouchers/receipt/add');
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _VoucherTypeButton(
                    icon: Icons.arrow_upward_rounded,
                    label: 'سند صرف',
                    subtitle: 'دفع لمورد',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/vouchers/payment/add');
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _VoucherTypeButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'مصاريف',
                    subtitle: 'مصاريف عامة',
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/vouchers/expense/add');
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int totalVouchers, List<Voucher> filteredVouchers) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السندات',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$totalVouchers سند',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _selectDateRange,
            icon: Badge(
              isLabelVisible: _dateRange != null,
              child: const Icon(Icons.date_range_rounded, size: 22),
            ),
            tooltip: 'تصفية حسب التاريخ',
          ),
          ExportMenuButton(
            onExport: (type) => _handleExport(type, filteredVouchers),
            isLoading: _isExporting,
            enabledOptions: const {
              ExportType.excel,
              ExportType.pdf,
              ExportType.sharePdf,
              ExportType.shareExcel,
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(List<Voucher> vouchers) {
    final receipts = _totalReceipts(vouchers);
    final payments = _totalPayments(vouchers);
    final expenses = _totalExpenses(vouchers);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'قبض',
              amount: receipts,
              amountUsd: _totalReceiptsUsd(vouchers),
              icon: Icons.arrow_downward_rounded,
              color: AppColors.success,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _StatCard(
              label: 'صرف',
              amount: payments,
              amountUsd: _totalPaymentsUsd(vouchers),
              icon: Icons.arrow_upward_rounded,
              color: AppColors.error,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _StatCard(
              label: 'مصاريف',
              amount: expenses,
              amountUsd: _totalExpensesUsd(vouchers),
              icon: Icons.receipt_outlined,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ProSearchBar(
      controller: _searchController,
      hintText: 'ابحث برقم السند أو الوصف...',
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildFiltersRow() {
    if (_dateRange == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Chip(
            label: Text(
              '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            deleteIcon: Icon(Icons.close, size: 18, color: AppColors.primary),
            onDeleted: () => setState(() => _dateRange = null),
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            side: BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _dateRange,
      locale: const Locale('ar'),
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  Future<void> _handleExport(ExportType type, List<Voucher> vouchers) async {
    if (vouchers.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد سندات للتصدير');
      return;
    }

    setState(() => _isExporting = true);
    final fileName = 'السندات_${DateFormat('yyyyMMdd').format(DateTime.now())}';

    try {
      switch (type) {
        case ExportType.excel:
          await ExcelExportService.exportVouchers(
            vouchers: vouchers,
            fileName: fileName,
          );
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.pdf:
          final pdfBytes =
              await PdfExportService.generateVouchersList(vouchers: vouchers);
          await PdfExportService.savePdfFile(pdfBytes, fileName);
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.sharePdf:
          final pdfBytes =
              await PdfExportService.generateVouchersList(vouchers: vouchers);
          await PdfExportService.sharePdfBytes(pdfBytes,
              fileName: fileName, subject: 'تقرير السندات');
          break;
        case ExportType.shareExcel:
          final filePath = await ExcelExportService.exportVouchers(
            vouchers: vouchers,
            fileName: fileName,
          );
          await ExcelExportService.shareFile(filePath,
              subject: 'تقرير السندات');
          break;
      }
    } catch (e) {
      if (mounted) ProSnackbar.error(context, 'حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildTabs(List<Voucher> vouchers) {
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
          _buildTab('الكل', vouchers.length),
          _buildTab('قبض', vouchers.where((v) => v.type == 'receipt').length),
          _buildTab('صرف', vouchers.where((v) => v.type == 'payment').length),
          _buildTab(
              'مصاريف', vouchers.where((v) => v.type == 'expense').length),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTypography.labelSmall),
            SizedBox(width: 4.w),
            Text(
              '$count',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherList(List<Voucher> vouchers) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'لا يوجد سندات',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        final voucher = vouchers[index];
        return _VoucherCard(
          voucher: voucher,
          onTap: () => context.push('/vouchers/${voucher.id}'),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تبويب المصاريف الخاص - مع تقسيم حسب الفئات
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildExpenseTab(List<Voucher> allVouchers) {
    final expenseVouchers = _filterVouchers(allVouchers, 'expense');

    // تجميع المصاريف حسب الفئة
    final Map<String?, List<Voucher>> byCategory = {};
    for (final v in expenseVouchers) {
      byCategory.putIfAbsent(v.categoryId, () => []).add(v);
    }

    return Column(
      children: [
        // فلتر الفئات
        _buildCategoryFilter(),
        // ملخص الفئات (إذا لم يتم اختيار فئة)
        if (_selectedCategoryId == null && _expenseCategories.isNotEmpty)
          _buildCategorySummary(byCategory),
        // قائمة السندات
        Expanded(
          child: _buildVoucherList(expenseVouchers),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // زر الكل
          _CategoryChip(
            label: 'الكل',
            isSelected: _selectedCategoryId == null,
            onTap: () => setState(() => _selectedCategoryId = null),
          ),
          SizedBox(width: AppSpacing.xs),
          // الفئات
          ..._expenseCategories.map((cat) => Padding(
                padding: EdgeInsets.only(left: AppSpacing.xs),
                child: _CategoryChip(
                  label: cat.name,
                  isSelected: _selectedCategoryId == cat.id,
                  onTap: () => setState(() => _selectedCategoryId = cat.id),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCategorySummary(Map<String?, List<Voucher>> byCategory) {
    return Container(
      height: 85.h,
      margin: EdgeInsets.only(top: AppSpacing.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _expenseCategories.length,
        itemBuilder: (context, index) {
          final category = _expenseCategories[index];
          final vouchers = byCategory[category.id] ?? [];
          final total = vouchers.fold(0.0, (sum, v) => sum + v.amount);
          final totalUsd = vouchers.fold(
              0.0,
              (sum, v) =>
                  sum +
                  (v.amountUsd ??
                      (v.exchangeRate > 0 ? v.amount / v.exchangeRate : 0)));

          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = category.id),
            child: Container(
              width: 100.w,
              margin: EdgeInsets.only(left: AppSpacing.sm),
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.soft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.warning.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '${(total / 1000).toStringAsFixed(0)}K',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${totalUsd.toStringAsFixed(1)}\$',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Category Chip Widget
// ═══════════════════════════════════════════════════════════════════════════
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.warning : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.warning : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final double amountUsd;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.amountUsd,
    required this.icon,
    required this.color,
  });

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            _formatCompact(amount),
            style: AppTypography.labelMedium
                .copyWith(color: color, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${amountUsd.toStringAsFixed(1)}\$',
            style: AppTypography.labelSmall.copyWith(
              color: color.withValues(alpha: 0.7),
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final VoidCallback? onTap;

  const _VoucherCard({required this.voucher, this.onTap});

  Color get _typeColor {
    switch (voucher.type) {
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
    switch (voucher.type) {
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return GestureDetector(
      onTap: onTap,
      child: ProCard(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            // أيقونة النوع
            ProIconBox(icon: _typeIcon, color: _typeColor),
            SizedBox(width: AppSpacing.sm),
            // المحتوى الرئيسي
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رقم السند والنوع
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '#${voucher.voucherNumber}',
                          style: AppTypography.labelMedium
                              .copyWith(color: AppColors.textPrimary)
                              .monoSemibold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      ProStatusBadge.fromVoucherType(voucher.type, small: true),
                    ],
                  ),
                  if (voucher.description != null &&
                      voucher.description!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      voucher.description!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 2.h),
                  Text(
                    dateFormat.format(voucher.voucherDate),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            // المبلغ
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(voucher.amount / 1000).toStringAsFixed(0)}K ل.س',
                  style: AppTypography.labelLarge
                      .copyWith(color: _typeColor, fontWeight: FontWeight.bold),
                ),
                if (voucher.exchangeRate > 0)
                  Text(
                    '(${(voucher.amount / voucher.exchangeRate).toStringAsFixed(2)}\$)',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textTertiary,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Voucher Form Screen Pro - Add/Edit Voucher
// ═══════════════════════════════════════════════════════════════════════════

class VoucherFormScreenPro extends ConsumerStatefulWidget {
  final String type; // 'receipt' or 'payment' or 'expense'
  final String? voucherId; // For editing

  const VoucherFormScreenPro({
    super.key,
    required this.type,
    this.voucherId,
  });

  bool get isEditing => voucherId != null;

  @override
  ConsumerState<VoucherFormScreenPro> createState() =>
      _VoucherFormScreenProState();
}

class _VoucherFormScreenProState extends ConsumerState<VoucherFormScreenPro> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _amountUsdController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCustomerId;
  String? _selectedSupplierId;
  String? _selectedCategoryId;
  DateTime _voucherDate = DateTime.now();
  bool _isSaving = false;
  // ignore: unused_field - Reserved for edit mode loading state
  bool _isLoading = false;
  // ignore: unused_field - Reserved for edit mode
  Voucher? _existingVoucher;

  // بيانات العملاء والموردين والفئات
  List<Customer> _customers = [];
  List<Supplier> _suppliers = [];
  List<VoucherCategory> _categories = [];

  String get _title {
    switch (widget.type) {
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

  Color get _accentColor {
    switch (widget.type) {
      case 'receipt':
        return AppColors.success;
      case 'payment':
        return AppColors.error;
      case 'expense':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData get _typeIcon {
    switch (widget.type) {
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

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.isEditing) {
      _loadVoucherData();
    }
  }

  Future<void> _loadVoucherData() async {
    if (widget.voucherId == null) return;

    setState(() => _isLoading = true);
    try {
      final voucherRepo = ref.read(voucherRepositoryProvider);
      final voucher = await voucherRepo.getVoucherById(widget.voucherId!);

      if (voucher != null && mounted) {
        setState(() {
          _existingVoucher = voucher;
          _amountController.text = voucher.amount.toStringAsFixed(0);
          _descriptionController.text = voucher.description ?? '';
          _selectedCustomerId = voucher.customerId;
          _selectedSupplierId = voucher.supplierId;
          _selectedCategoryId = voucher.categoryId;
          _voucherDate = voucher.voucherDate;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    // تحميل العملاء والموردين
    final customersAsync = ref.read(customersStreamProvider);
    final suppliersAsync = ref.read(suppliersStreamProvider);

    customersAsync.whenData((customers) {
      if (mounted) setState(() => _customers = customers);
    });

    suppliersAsync.whenData((suppliers) {
      if (mounted) setState(() => _suppliers = suppliers);
    });

    // تحميل فئات المصاريف
    if (widget.type == 'expense') {
      final voucherRepo = ref.read(voucherRepositoryProvider);
      final categories =
          await voucherRepo.getCategoriesByType(VoucherType.expense);
      if (mounted) setState(() => _categories = categories);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountUsdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to customers and suppliers updates
    ref.listen(customersStreamProvider, (_, next) {
      next.whenData((customers) {
        if (mounted) setState(() => _customers = customers);
      });
    });

    ref.listen(suppliersStreamProvider, (_, next) {
      next.whenData((suppliers) {
        if (mounted) setState(() => _suppliers = suppliers);
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // ═══════════════════════════════════════════════════════════════
            // 1. المبلغ
            // ═══════════════════════════════════════════════════════════════
            const ProSectionTitle('المبلغ'),
            SizedBox(height: AppSpacing.sm),
            // سعر الصرف الحالي
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: _accentColor.soft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: _accentColor.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_typeIcon, color: _accentColor, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '$_title • ',
                    style: AppTypography.labelMedium.copyWith(
                      color: _accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.currency_exchange, color: _accentColor, size: 14),
                  SizedBox(width: 4),
                  Text(
                    '1\$ = ${CurrencyService.currentRate.toStringAsFixed(0)} ل.س',
                    style: AppTypography.labelSmall.copyWith(
                      color: _accentColor,
                    ),
                  ),
                ],
              ),
            ),
            // حقول المبلغ
            Row(
              children: [
                Expanded(
                  child: ProNumberField(
                    controller: _amountController,
                    label: 'المبلغ (ل.س)',
                    hint: '0',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'مبلغ غير صحيح';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        final syp = double.tryParse(value);
                        if (syp != null && syp > 0) {
                          final usd = syp / CurrencyService.currentRate;
                          _amountUsdController.text = usd.toStringAsFixed(2);
                        }
                      }
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ProNumberField(
                    controller: _amountUsdController,
                    label: 'المبلغ (\$)',
                    hint: '0.00',
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        final usd = double.tryParse(value);
                        if (usd != null && usd > 0) {
                          final syp = usd * CurrencyService.currentRate;
                          _amountController.text = syp.toStringAsFixed(0);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // ═══════════════════════════════════════════════════════════════
            // 2. العميل/المورد أو فئة المصاريف
            // ═══════════════════════════════════════════════════════════════
            if (widget.type != 'expense') ...[
              ProSectionTitle(
                widget.type == 'receipt' ? 'العميل' : 'المورد',
              ),
              SizedBox(height: AppSpacing.sm),
              _buildPartySelector(),
              SizedBox(height: AppSpacing.lg),
            ],

            if (widget.type == 'expense') ...[
              const ProSectionTitle('فئة المصاريف'),
              SizedBox(height: AppSpacing.sm),
              _buildCategorySelector(),
              SizedBox(height: AppSpacing.lg),
            ],

            // ═══════════════════════════════════════════════════════════════
            // 3. التاريخ
            // ═══════════════════════════════════════════════════════════════
            const ProSectionTitle('التاريخ'),
            SizedBox(height: AppSpacing.sm),
            _buildDateSelector(),
            SizedBox(height: AppSpacing.lg),

            // ═══════════════════════════════════════════════════════════════
            // 4. ملاحظات
            // ═══════════════════════════════════════════════════════════════
            const ProSectionTitle('ملاحظات (اختياري)'),
            SizedBox(height: AppSpacing.sm),
            ProTextField(
              controller: _descriptionController,
              label: 'وصف السند',
              hint: 'أدخل وصف أو ملاحظات...',
              maxLines: 2,
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return ProAppBar.close(
      title: widget.isEditing ? 'تعديل $_title' : _title,
      onClose: () => Navigator.of(context).pop(),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : _saveVoucher,
          child: _isSaving
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _accentColor,
                  ),
                )
              : Text(
                  'حفظ',
                  style: AppTypography.labelLarge.copyWith(
                    color: _accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Widget _buildPartySelector() {
    final isReceipt = widget.type == 'receipt';
    final items = isReceipt ? _customers : _suppliers;
    final selectedId = isReceipt ? _selectedCustomerId : _selectedSupplierId;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(
                isReceipt
                    ? Icons.person_outline
                    : Icons.local_shipping_outlined,
                color: AppColors.textTertiary,
                size: AppIconSize.sm,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                isReceipt ? 'اختر العميل' : 'اختر المورد',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          items: items.map((item) {
            final id =
                isReceipt ? (item as Customer).id : (item as Supplier).id;
            final name =
                isReceipt ? (item as Customer).name : (item as Supplier).name;
            final balance = isReceipt
                ? (item as Customer).balance
                : (item as Supplier).balance;

            return DropdownMenuItem<String>(
              value: id,
              child: Row(
                children: [
                  Icon(
                    isReceipt
                        ? Icons.person_rounded
                        : Icons.local_shipping_rounded,
                    color: _accentColor,
                    size: AppIconSize.sm,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${balance.toStringAsFixed(0)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: balance > 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              if (isReceipt) {
                _selectedCustomerId = value;
              } else {
                _selectedSupplierId = value;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      children: [
        // قائمة اختيار الفئة
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: _categories.isEmpty
              ? _buildEmptyCategoriesState()
              : DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'فئة المصاريف',
                    hintText: 'اختر فئة',
                    filled: true,
                    fillColor: AppColors.surface,
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      color: AppColors.textTertiary,
                      size: AppIconSize.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(
                        category.name,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                  dropdownColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
        ),
        SizedBox(height: AppSpacing.sm),
        // زر إضافة فئة جديدة
        InkWell(
          onTap: _showAddCategoryDialog,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.soft,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.warning.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: AppColors.warning, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'إضافة فئة جديدة',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCategoriesState() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            color: AppColors.textTertiary,
            size: 32.sp,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'لا توجد فئات مصاريف',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'اضغط على "إضافة فئة جديدة" لإنشاء فئة',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.category_rounded, color: AppColors.warning),
            SizedBox(width: AppSpacing.sm),
            const Text('إضافة فئة مصاريف'),
          ],
        ),
        content: ProTextField(
          controller: nameController,
          label: 'اسم الفئة',
          hint: 'مثال: مصاريف إدارية',
          autofocus: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الاسم مطلوب';
            }
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, nameController.text.trim());
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _createCategory(result);
    }
  }

  Future<void> _createCategory(String name) async {
    try {
      final voucherRepo = ref.read(voucherRepositoryProvider);
      final newCategoryId = await voucherRepo.createCategory(
        name: name,
        type: VoucherType.expense,
      );

      // إعادة تحميل الفئات وتحديد الفئة الجديدة
      final categories =
          await voucherRepo.getCategoriesByType(VoucherType.expense);
      if (mounted) {
        setState(() {
          _categories = categories;
          _selectedCategoryId = newCategoryId;
        });
        ProSnackbar.success(context, 'تم إضافة الفئة "$name"');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في إضافة الفئة: $e');
      }
    }
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppColors.textSecondary,
              size: AppIconSize.sm,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ السند',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('yyyy/MM/dd', 'ar').format(_voucherDate),
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textTertiary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _voucherDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() => _voucherDate = picked);
    }
  }

  Future<void> _saveVoucher() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من اختيار العميل/المورد
    if (widget.type == 'receipt' && _selectedCustomerId == null) {
      ProSnackbar.error(context, 'يرجى اختيار العميل');
      return;
    }
    if (widget.type == 'payment' && _selectedSupplierId == null) {
      ProSnackbar.error(context, 'يرجى اختيار المورد');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final voucherRepo = ref.read(voucherRepositoryProvider);
      final shiftAsync = ref.read(openShiftStreamProvider);

      // الحصول على الشفت المفتوح
      String? shiftId;
      shiftAsync.whenData((shift) => shiftId = shift?.id);

      final amount = double.parse(_amountController.text);

      // تحديد نوع السند
      final voucherType = switch (widget.type) {
        'receipt' => VoucherType.receipt,
        'payment' => VoucherType.payment,
        _ => VoucherType.expense,
      };

      await voucherRepo.createVoucher(
        type: voucherType,
        amount: amount,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        customerId: _selectedCustomerId,
        supplierId: _selectedSupplierId,
        categoryId: _selectedCategoryId,
        shiftId: shiftId,
        voucherDate: _voucherDate,
      );

      if (mounted) {
        ProSnackbar.success(context,
            widget.isEditing ? 'تم تحديث السند بنجاح' : 'تم حفظ السند بنجاح');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Voucher Type Button Widget
// ═══════════════════════════════════════════════════════════════════════════
class _VoucherTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const _VoucherTypeButton({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.soft,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(height: 4.h),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
