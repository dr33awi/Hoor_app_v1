// ═══════════════════════════════════════════════════════════════════════════
// Cash Screen Pro - Enterprise Design System
// Cash Drawer Management Interface
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/currency_service.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/dual_price_display.dart';
import '../../core/services/export/export_button.dart';
import '../../core/services/export/export_services.dart';
import '../../data/database/app_database.dart';

class CashScreenPro extends ConsumerStatefulWidget {
  const CashScreenPro({super.key});

  @override
  ConsumerState<CashScreenPro> createState() => _CashScreenProState();
}

class _CashScreenProState extends ConsumerState<CashScreenPro> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all'; // all, income, expense
  DateTimeRange? _dateRange;
  bool _isExporting = false;
  bool _showChart = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CashMovement> _filterMovements(List<CashMovement> movements) {
    return movements.where((m) {
      // فلتر البحث
      final matchesSearch = _searchQuery.isEmpty ||
          m.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // فلتر النوع
      final isIncome = m.type == 'income' ||
          m.type == 'sale' ||
          m.type == 'deposit' ||
          m.type == 'opening';
      final matchesType = _filterType == 'all' ||
          (_filterType == 'income' && isIncome) ||
          (_filterType == 'expense' && !isIncome);

      // فلتر التاريخ
      final matchesDate = _dateRange == null ||
          (m.createdAt.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1))) &&
              m.createdAt
                  .isBefore(_dateRange!.end.add(const Duration(days: 1))));

      return matchesSearch && matchesType && matchesDate;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _filterType != 'all' || _dateRange != null || _searchQuery.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final shiftAsync = ref.watch(openShiftStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProHeader(
              title: 'الصندوق',
              subtitle: 'إدارة النقدية والحركات',
              onBack: () => context.go('/'),
              actions: [
                // فلتر
                Badge(
                  isLabelVisible: _hasActiveFilters,
                  child: IconButton(
                    onPressed: () => _showFilterSheet(),
                    icon: const Icon(Icons.filter_list_rounded),
                    tooltip: 'تصفية',
                  ),
                ),
                // الورديات
                IconButton(
                  onPressed: () => context.push('/shifts'),
                  icon: const Icon(Icons.access_time_rounded),
                  tooltip: 'الورديات',
                ),
              ],
            ),
            Expanded(
              child: shiftAsync.when(
                loading: () => ProLoadingState.simple(),
                error: (error, _) =>
                    ProEmptyState.error(error: error.toString()),
                data: (shift) {
                  if (shift == null) {
                    return _buildNoShiftView();
                  }
                  return _buildCashView(shift);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoShiftView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.point_of_sale_rounded,
                size: 40.sp,
                color: AppColors.warning,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'لا توجد وردية مفتوحة',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'افتح وردية جديدة للبدء في إدارة الصندوق',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ProButton(
              onPressed: () => context.push('/shifts'),
              label: 'فتح وردية',
              icon: Icons.play_arrow_rounded,
              type: ProButtonType.filled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashView(Shift shift) {
    final cashMovementsAsync =
        ref.watch(cashMovementsByShiftProvider(shift.id));

    return cashMovementsAsync.when(
      loading: () => SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildBalanceCard(shift),
            SizedBox(height: AppSpacing.lg),
            ProLoadingState.list(itemCount: 3),
          ],
        ),
      ),
      error: (error, _) => ProEmptyState.error(error: error.toString()),
      data: (movements) {
        final filteredMovements = _filterMovements(movements);

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              _buildBalanceCard(shift),
              SizedBox(height: AppSpacing.lg),

              // Quick Actions
              _buildQuickActions(shift),
              SizedBox(height: AppSpacing.lg),

              // Search Bar
              ProSearchBar(
                controller: _searchController,
                hintText: 'البحث في الحركات...',
                onChanged: (value) => setState(() => _searchQuery = value),
                onClear: () => setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                }),
              ),
              SizedBox(height: AppSpacing.md),

              // Chart Toggle & Export
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'حركات اليوم',
                        style: AppTypography.titleMedium
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (filteredMovements.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(right: AppSpacing.sm),
                          child: Text(
                            '(${filteredMovements.length})',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      // زر الرسم البياني
                      IconButton(
                        onPressed: () =>
                            setState(() => _showChart = !_showChart),
                        icon: Icon(
                          _showChart
                              ? Icons.list_rounded
                              : Icons.pie_chart_rounded,
                          color: _showChart
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        tooltip:
                            _showChart ? 'عرض القائمة' : 'عرض الرسم البياني',
                      ),
                      // تصدير
                      ExportMenuButton(
                        onExport: (type) =>
                            _handleExport(type, filteredMovements),
                        isLoading: _isExporting,
                        icon: Icons.ios_share_rounded,
                        tooltip: 'تصدير',
                        enabledOptions: const {
                          ExportType.excel,
                          ExportType.pdf,
                          ExportType.sharePdf,
                          ExportType.shareExcel,
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              // Chart or List
              if (_showChart && filteredMovements.isNotEmpty)
                _buildChart(filteredMovements)
              else if (filteredMovements.isEmpty)
                Container(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          _hasActiveFilters ? 'لا توجد نتائج' : 'لا توجد حركات',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_hasActiveFilters) ...[
                          SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: () => setState(() {
                              _filterType = 'all';
                              _dateRange = null;
                              _searchQuery = '';
                              _searchController.clear();
                            }),
                            child: const Text('مسح الفلاتر'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredMovements.length,
                  itemBuilder: (context, index) {
                    return _MovementCard(movement: filteredMovements[index]);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(List<CashMovement> movements) {
    // حساب الإجماليات حسب النوع
    double totalIncome = 0;
    double totalExpense = 0;

    for (final m in movements) {
      final isIncome = m.type == 'income' ||
          m.type == 'sale' ||
          m.type == 'deposit' ||
          m.type == 'opening';
      if (isIncome) {
        totalIncome += m.amount;
      } else {
        totalExpense += m.amount;
      }
    }

    final total = totalIncome + totalExpense;
    final incomePercent = total > 0 ? (totalIncome / total * 100) : 0;
    final expensePercent = total > 0 ? (totalExpense / total * 100) : 0;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          // الرسم البياني البسيط
          SizedBox(
            height: 200.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // عمود الإيرادات
                _buildChartBar(
                  label: 'الإيرادات',
                  value: totalIncome,
                  percent: incomePercent.toDouble(),
                  color: AppColors.success,
                ),
                // عمود المصروفات
                _buildChartBar(
                  label: 'المصروفات',
                  value: totalExpense,
                  percent: expensePercent.toDouble(),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // الملخص
          Row(
            children: [
              Expanded(
                child: _buildChartLegend(
                  label: 'الإيرادات',
                  value: totalIncome,
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _buildChartLegend(
                  label: 'المصروفات',
                  value: totalExpense,
                  color: AppColors.error,
                ),
              ),
              Expanded(
                child: _buildChartLegend(
                  label: 'الصافي',
                  value: totalIncome - totalExpense,
                  color: totalIncome >= totalExpense
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar({
    required String label,
    required double value,
    required double percent,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${percent.toStringAsFixed(0)}%',
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
        SizedBox(height: AppSpacing.xs),
        Container(
          width: 60.w,
          height: (percent * 1.5).clamp(20, 150).h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xxs),
        CompactDualPrice(
          amountSyp: value,
          exchangeRate: CurrencyService.currentRate,
          sypStyle: AppTypography.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: ListView(
            controller: scrollController,
            children: [
              Text('تصفية الحركات', style: AppTypography.titleLarge),
              SizedBox(height: AppSpacing.lg),

              // فلتر النوع
              Text('نوع الحركة', style: AppTypography.labelMedium),
              SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('الكل')),
                  ButtonSegment(value: 'income', label: Text('إيرادات')),
                  ButtonSegment(value: 'expense', label: Text('مصروفات')),
                ],
                selected: {_filterType},
                onSelectionChanged: (selection) {
                  setState(() => _filterType = selection.first);
                },
              ),
              SizedBox(height: AppSpacing.lg),

              // فلتر التاريخ
              ListTile(
                leading: Icon(Icons.date_range,
                    color: _dateRange != null ? AppColors.primary : null),
                title: const Text('فترة زمنية'),
                subtitle: _dateRange != null
                    ? Text(
                        '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}',
                        style: TextStyle(color: AppColors.primary),
                      )
                    : const Text('اختر فترة'),
                trailing: _dateRange != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dateRange = null),
                      )
                    : null,
                onTap: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    locale: const Locale('ar'),
                    initialDateRange: _dateRange,
                  );
                  if (range != null) {
                    setState(() => _dateRange = range);
                  }
                },
              ),
              SizedBox(height: AppSpacing.lg),

              // مسح الفلاتر
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _filterType = 'all';
                    _dateRange = null;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('مسح جميع الفلاتر'),
              ),
              SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تطبيق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport(
      ExportType type, List<CashMovement> movements) async {
    if (movements.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد حركات للتصدير');
      return;
    }

    setState(() => _isExporting = true);
    final fileName =
        'حركات_الصندوق_${DateFormat('yyyyMMdd').format(DateTime.now())}';

    try {
      switch (type) {
        case ExportType.excel:
          await ExcelExportService.exportCashMovements(
            movements: movements,
            fileName: fileName,
          );
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.pdf:
          final pdfBytes = await PdfExportService.generateCashMovementsList(
            movements: movements,
          );
          await PdfExportService.savePdfFile(pdfBytes, fileName);
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.sharePdf:
          final pdfBytes = await PdfExportService.generateCashMovementsList(
            movements: movements,
          );
          await PdfExportService.sharePdfBytes(
            pdfBytes,
            fileName: fileName,
            subject: 'حركات الصندوق',
          );
          break;
        case ExportType.shareExcel:
          final filePath = await ExcelExportService.exportCashMovements(
            movements: movements,
            fileName: fileName,
          );
          await ExcelExportService.shareFile(filePath,
              subject: 'حركات الصندوق');
          break;
      }
    } catch (e) {
      if (mounted) ProSnackbar.error(context, 'حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildBalanceCard(Shift shift) {
    final openingBalance = shift.openingBalance;
    final totalIncome = shift.totalIncome;
    final totalExpenses = shift.totalExpenses;
    final currentBalance = openingBalance + totalIncome - totalExpenses;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.overlayHeavy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.border,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رصيد الصندوق',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white.overlayHeavy,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.light,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'وردية #${shift.shiftNumber}',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${currentBalance.toStringAsFixed(0)} ل.س',
                style: AppTypography.displaySmall
                    .copyWith(
                      color: Colors.white,
                    )
                    .monoBold,
              ),
              Text(
                '\$${(currentBalance / CurrencyService.currentRate).toStringAsFixed(2)}',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  label: 'الرصيد الافتتاحي',
                  value: openingBalance,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.light,
              ),
              Expanded(
                child: _buildBalanceItem(
                  label: 'الإيرادات',
                  value: totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  isPositive: true,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.light,
              ),
              Expanded(
                child: _buildBalanceItem(
                  label: 'المصروفات',
                  value: totalExpenses,
                  icon: Icons.arrow_upward_rounded,
                  isPositive: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem({
    required String label,
    required double value,
    required IconData icon,
    bool? isPositive,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.o70,
          size: 20.sp,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white.o70,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value.toStringAsFixed(0),
          style: AppTypography.titleSmall
              .copyWith(
                color: Colors.white,
              )
              .monoBold,
        ),
      ],
    );
  }

  Widget _buildQuickActions(Shift shift) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'إيداع',
            icon: Icons.add_circle_outline,
            color: AppColors.success,
            onTap: () => _showMovementSheet(shift, isDeposit: true),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionButton(
            label: 'سحب',
            icon: Icons.remove_circle_outline,
            color: AppColors.error,
            onTap: () => _showMovementSheet(shift, isDeposit: false),
          ),
        ),
      ],
    );
  }

  void _showMovementSheet(Shift shift, {required bool isDeposit}) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: (isDeposit ? AppColors.success : AppColors.error)
                          .soft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      isDeposit
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                      color: isDeposit ? AppColors.success : AppColors.error,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Text(
                    isDeposit ? 'إيداع في الصندوق' : 'سحب من الصندوق',
                    style: AppTypography.titleLarge,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'المبلغ',
                  suffixText: 'ل.س',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'ملاحظة (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              ProButton(
                label: isDeposit ? 'إيداع' : 'سحب',
                fullWidth: true,
                color: isDeposit ? AppColors.success : AppColors.error,
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) {
                    ProSnackbar.warning(context, 'أدخل مبلغ صحيح');
                    return;
                  }

                  try {
                    final cashRepo = ref.read(cashRepositoryProvider);
                    if (isDeposit) {
                      await cashRepo.addIncome(
                        shiftId: shift.id,
                        amount: amount,
                        description: noteController.text.isNotEmpty
                            ? noteController.text
                            : 'إيداع',
                      );
                    } else {
                      await cashRepo.addExpense(
                        shiftId: shift.id,
                        amount: amount,
                        description: noteController.text.isNotEmpty
                            ? noteController.text
                            : 'سحب',
                      );
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ProSnackbar.success(
                        context,
                        isDeposit ? 'تم الإيداع بنجاح' : 'تم السحب بنجاح',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ProSnackbar.showError(context, e);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Action Button
// ═══════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.soft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.titleSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Movement Card
// ═══════════════════════════════════════════════════════════════════════════

class _MovementCard extends StatelessWidget {
  final CashMovement movement;

  const _MovementCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isIncome = movement.type == 'income' ||
        movement.type == 'sale' ||
        movement.type == 'deposit' ||
        movement.type == 'opening';
    final dateFormat = DateFormat('hh:mm a', 'ar');

    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          ProIconBox(
            icon: isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: isIncome ? AppColors.success : AppColors.error,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.description,
                  style: AppTypography.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateFormat.format(movement.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${movement.amount.toStringAsFixed(0)}',
            style: AppTypography.titleMedium
                .copyWith(
                  color: isIncome ? AppColors.success : AppColors.error,
                )
                .monoBold,
          ),
        ],
      ),
    );
  }
}
