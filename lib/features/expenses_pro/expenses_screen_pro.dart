// ═══════════════════════════════════════════════════════════════════════════
// Expenses Screen Pro - Enterprise Design System
// Expense Management Interface
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════
//
// ⚠️ قواعد المصاريف المحاسبية:
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ ✅ المصاريف تُخصم من الصندوق مباشرة                                         │
// │ ✅ المصاريف تؤثر على الأرباح والخسائر                                        │
// │ ✅ القيم المعروضة هي القيم المثبتة وقت التسجيل                               │
// │ ❌ المصاريف لا تؤثر على المخزون                                              │
// │ ❌ لا يتم إعادة حساب القيم بسعر صرف جديد                                    │
// └─────────────────────────────────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/dual_price_display.dart';
import '../../core/services/currency_formatter.dart';
import '../../core/services/export/export_services.dart';
import '../../data/database/app_database.dart';

class ExpensesScreenPro extends ConsumerStatefulWidget {
  const ExpensesScreenPro({super.key});

  @override
  ConsumerState<ExpensesScreenPro> createState() => _ExpensesScreenProState();
}

class _ExpensesScreenProState extends ConsumerState<ExpensesScreenPro> {
  final _searchController = TextEditingController();
  DateTimeRange? _dateRange;
  String? _selectedCategoryId;
  List<VoucherCategory> _categories = [];
  bool _showChart = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final expenseRepo = ref.read(expenseRepositoryProvider);
    final categories = await expenseRepo.getAllCategories();
    if (mounted) {
      setState(() => _categories = categories);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Voucher> _filterExpenses(List<Voucher> expenses) {
    var filtered = expenses;

    // تصفية حسب التصنيف
    if (_selectedCategoryId != null) {
      filtered =
          filtered.where((e) => e.categoryId == _selectedCategoryId).toList();
    }

    // تصفية حسب نطاق التاريخ
    if (_dateRange != null) {
      filtered = filtered.where((e) {
        return e.voucherDate
                .isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            e.voucherDate
                .isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // تصفية حسب البحث
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((e) =>
              e.voucherNumber.toLowerCase().contains(query) ||
              (e.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // ترتيب حسب التاريخ (الأحدث أولاً)
    filtered.sort((a, b) => b.voucherDate.compareTo(a.voucherDate));

    return filtered;
  }

  /// حساب إجمالي المصاريف بالليرة (القيم المثبتة)
  double _totalExpensesSyp(List<Voucher> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  /// حساب إجمالي المصاريف بالدولار (القيم المثبتة)
  double _totalExpensesUsd(List<Voucher> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + (e.amountUsd ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesStreamProvider);
    final categoriesAsync = ref.watch(expenseCategoriesStreamProvider);

    // تحديث التصنيفات
    categoriesAsync.whenData((categories) {
      if (_categories.isEmpty || _categories.length != categories.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _categories = categories);
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: expensesAsync.when(
          loading: () => ProLoadingState.list(),
          error: (error, stack) => ProEmptyState.error(error: error.toString()),
          data: (expenses) {
            final filteredExpenses = _filterExpenses(expenses);
            return Column(
              children: [
                _buildHeader(expenses.length, filteredExpenses, expenses),
                _buildBudgetWarning(expenses),
                _buildStatsSummary(filteredExpenses, expenses),
                _buildSearchBar(),
                _buildFiltersRow(),
                Expanded(
                  child: filteredExpenses.isEmpty
                      ? _buildEmptyState()
                      : _buildExpensesList(filteredExpenses),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader(
      int total, List<Voucher> filteredExpenses, List<Voucher> allExpenses) {
    return ProHeader(
      title: 'المصاريف',
      subtitle: filteredExpenses.length < total
          ? 'إدارة المصاريف اليومية (${filteredExpenses.length} / $total)'
          : 'إدارة المصاريف اليومية ($total)',
      onBack: () => context.go('/'),
      actions: [
        // زر المصاريف الدورية
        IconButton(
          onPressed: () => context.push('/expenses/recurring'),
          icon: const Icon(Icons.repeat),
          tooltip: 'المصاريف الدورية',
        ),
        // زر التصدير
        ExportMenuButton(
          isLoading: _isExporting,
          onExport: (type) => _handleExport(type, filteredExpenses),
        ),
        // زر الرسم البياني
        IconButton(
          onPressed: () => setState(() => _showChart = !_showChart),
          icon: Icon(_showChart ? Icons.list : Icons.pie_chart_outline),
          tooltip: _showChart ? 'عرض القائمة' : 'عرض الرسم البياني',
        ),
      ],
    );
  }

  /// تنبيه الحد الأقصى للميزانية
  Widget _buildBudgetWarning(List<Voucher> expenses) {
    // الحد الأقصى للمصاريف الشهرية (يمكن تخصيصه من الإعدادات)
    const double monthlyBudgetSyp = 50000000; // 50 مليون ليرة مثال

    final today = DateTime.now();
    final monthExpenses = expenses.where((e) {
      return e.voucherDate.year == today.year &&
          e.voucherDate.month == today.month;
    }).toList();

    final monthTotalSyp = _totalExpensesSyp(monthExpenses);
    final percentage = (monthTotalSyp / monthlyBudgetSyp * 100).clamp(0, 100);

    if (percentage < 80) return const SizedBox.shrink();

    final isExceeded = percentage >= 100;
    final warningColor = isExceeded ? AppColors.error : AppColors.warning;

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: warningColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isExceeded ? Icons.warning_amber_rounded : Icons.info_outline,
            color: warningColor,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isExceeded
                  ? 'تم تجاوز الميزانية الشهرية! (${percentage.toStringAsFixed(0)}%)'
                  : 'اقتربت من الحد الأقصى للميزانية (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                color: warningColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // شريط التقدم
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: warningColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// تصدير المصاريف
  Future<void> _handleExport(ExportType type, List<Voucher> expenses) async {
    if (_isExporting || expenses.isEmpty) {
      if (expenses.isEmpty) {
        ProSnackbar.warning(context, 'لا توجد مصاريف للتصدير');
      }
      return;
    }

    setState(() => _isExporting = true);

    try {
      switch (type) {
        case ExportType.pdf:
          final pdfBytes = await PdfExportService.generateVouchersList(
            vouchers: expenses,
            type: 'expense',
          );
          if (mounted) {
            ProSnackbar.success(context, 'تم إنشاء التقرير بنجاح');
          }
          break;

        case ExportType.excel:
          final filePath = await ExcelExportService.exportVouchers(
            vouchers: expenses,
            type: 'expense',
          );
          if (mounted) {
            ProSnackbar.success(context, 'تم حفظ الملف: $filePath');
          }
          break;

        case ExportType.sharePdf:
          final pdfData = await PdfExportService.generateVouchersList(
            vouchers: expenses,
            type: 'expense',
          );
          // PDF sharing would require saving to temp file first
          if (mounted) {
            ProSnackbar.success(context, 'تم إنشاء التقرير');
          }
          break;

        case ExportType.shareExcel:
          final excelPath = await ExcelExportService.exportVouchers(
            vouchers: expenses,
            type: 'expense',
          );
          await Share.shareXFiles([XFile(excelPath)], text: 'تقرير المصاريف');
          break;
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'فشل التصدير: $e');
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildStatsSummary(List<Voucher> expenses, List<Voucher> allExpenses) {
    final totalSyp = _totalExpensesSyp(expenses);
    final totalUsd = _totalExpensesUsd(expenses);

    // حساب مصاريف اليوم
    final today = DateTime.now();
    final todayExpenses = expenses.where((e) {
      return e.voucherDate.year == today.year &&
          e.voucherDate.month == today.month &&
          e.voucherDate.day == today.day;
    }).toList();
    final todaySyp = _totalExpensesSyp(todayExpenses);
    final todayUsd = _totalExpensesUsd(todayExpenses);

    // حساب مصاريف الشهر الحالي
    final monthExpenses = allExpenses.where((e) {
      return e.voucherDate.year == today.year &&
          e.voucherDate.month == today.month;
    }).toList();
    final monthSyp = _totalExpensesSyp(monthExpenses);
    final monthUsd = _totalExpensesUsd(monthExpenses);

    // حساب مصاريف الشهر السابق للمقارنة
    final lastMonth = DateTime(today.year, today.month - 1, 1);
    final lastMonthExpenses = allExpenses.where((e) {
      return e.voucherDate.year == lastMonth.year &&
          e.voucherDate.month == lastMonth.month;
    }).toList();
    final lastMonthSyp = _totalExpensesSyp(lastMonthExpenses);

    // حساب نسبة التغيير
    double changePercent = 0;
    if (lastMonthSyp > 0) {
      changePercent = ((monthSyp - lastMonthSyp) / lastMonthSyp * 100);
    }

    if (_showChart) {
      return _buildCategoryChart(expenses);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'اليوم',
                  amountSyp: todaySyp,
                  amountUsd: todayUsd,
                  icon: Icons.today,
                  color: AppColors.expense,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  title: 'الشهر',
                  amountSyp: monthSyp,
                  amountUsd: monthUsd,
                  icon: Icons.calendar_month,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  title: 'الإجمالي',
                  amountSyp: totalSyp,
                  amountUsd: totalUsd,
                  icon: Icons.account_balance_wallet,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          // تقرير المقارنة مع الشهر السابق
          if (lastMonthSyp > 0) ...[
            SizedBox(height: AppSpacing.sm),
            _buildComparisonCard(monthSyp, lastMonthSyp, changePercent),
          ],
        ],
      ),
    );
  }

  /// بطاقة المقارنة مع الشهر السابق
  Widget _buildComparisonCard(
      double currentMonth, double lastMonth, double changePercent) {
    final isIncrease = changePercent > 0;
    final isDecrease = changePercent < 0;
    final color = isIncrease
        ? AppColors.error
        : (isDecrease ? AppColors.success : AppColors.textTertiary);

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isIncrease
                ? Icons.trending_up
                : (isDecrease ? Icons.trending_down : Icons.trending_flat),
            color: color,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مقارنة مع الشهر السابق',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.formatSyp(lastMonth),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Icon(Icons.arrow_forward,
                        size: 12, color: AppColors.textTertiary),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      CurrencyFormatter.formatSyp(currentMonth),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              '${isIncrease ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(List<Voucher> expenses) {
    // تجميع المصاريف حسب التصنيف
    final Map<String, double> categoryTotals = {};
    for (final expense in expenses) {
      final catId = expense.categoryId ?? 'other';
      categoryTotals[catId] = (categoryTotals[catId] ?? 0) + expense.amount;
    }

    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    // ترتيب التصنيفات حسب المبلغ
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AppColors.expense,
      AppColors.warning,
      AppColors.secondary,
      AppColors.accent,
      AppColors.primarySoft,
      AppColors.info,
    ];

    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'توزيع المصاريف حسب التصنيف',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ...sortedCategories.take(6).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final catEntry = entry.value;
            final catName = _getCategoryName(catEntry.key);
            final percentage = (catEntry.value / total * 100);
            final color = colors[index % colors.length];

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: Text(
                      catName,
                      style: AppTypography.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 8.h,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 50.w,
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => VoucherCategory(
        id: categoryId,
        name: 'غير مصنف',
        type: 'expense',
        isActive: true,
        syncStatus: 'synced',
        createdAt: DateTime.now(),
      ),
    );
    return category.name;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: ProSearchBar(
        controller: _searchController,
        hintText: 'بحث في المصاريف...',
        onChanged: (_) => setState(() {}),
        onClear: () {
          _searchController.clear();
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFiltersRow() {
    final hasFilters = _selectedCategoryId != null || _dateRange != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // فلتر التصنيف
          _FilterChip(
            label: _selectedCategoryId != null
                ? _getCategoryName(_selectedCategoryId!)
                : 'التصنيف',
            isSelected: _selectedCategoryId != null,
            onTap: () => _showCategoryFilter(),
          ),
          SizedBox(width: AppSpacing.sm),
          // فلتر التاريخ
          _FilterChip(
            label: _dateRange != null
                ? '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}'
                : 'التاريخ',
            isSelected: _dateRange != null,
            onTap: () => _showDateRangeFilter(),
          ),
          if (hasFilters) ...[
            SizedBox(width: AppSpacing.sm),
            ActionChip(
              label: Text(
                'مسح الفلاتر',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
              backgroundColor: AppColors.errorLight,
              side: BorderSide.none,
              onPressed: () {
                setState(() {
                  _selectedCategoryId = null;
                  _dateRange = null;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showCategoryFilter() {
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
              'اختر التصنيف',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            // الكل
            ListTile(
              leading: Icon(
                Icons.all_inclusive,
                color: _selectedCategoryId == null
                    ? AppColors.secondary
                    : AppColors.textSecondary,
              ),
              title: Text('الكل'),
              trailing: _selectedCategoryId == null
                  ? Icon(Icons.check, color: AppColors.secondary)
                  : null,
              onTap: () {
                setState(() => _selectedCategoryId = null);
                Navigator.pop(context);
              },
            ),
            Divider(),
            // التصنيفات
            SizedBox(
              height: 300.h,
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategoryId == category.id;
                  return ListTile(
                    leading: Icon(
                      Icons.label_outline,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                    title: Text(category.name),
                    trailing: isSelected
                        ? Icon(Icons.check, color: AppColors.secondary)
                        : null,
                    onTap: () {
                      setState(() => _selectedCategoryId = category.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangeFilter() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _dateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() => _dateRange = result);
    }
  }

  Widget _buildExpensesList(List<Voucher> expenses) {
    // تجميع المصاريف حسب التاريخ
    final Map<String, List<Voucher>> groupedExpenses = {};
    for (final expense in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.voucherDate);
      groupedExpenses.putIfAbsent(dateKey, () => []).add(expense);
    }

    final sortedDates = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dayExpenses = groupedExpenses[dateKey]!;
        final date = DateTime.parse(dateKey);
        final daySyp = _totalExpensesSyp(dayExpenses);
        final dayUsd = _totalExpensesUsd(dayExpenses);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان اليوم
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        _formatDate(date),
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        '(${dayExpenses.length})',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  DualPriceDisplay(
                    amountSyp: daySyp,
                    amountUsd: dayUsd,
                    type: DualPriceDisplayType.horizontal,
                    sypStyle: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.expense,
                    ),
                    usdStyle: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // قائمة المصاريف لهذا اليوم
            ...dayExpenses.map((expense) => _buildExpenseCard(expense)),
            SizedBox(height: AppSpacing.md),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'اليوم';
    } else if (dateOnly == yesterday) {
      return 'أمس';
    } else {
      return DateFormat('EEEE، d MMMM yyyy', 'ar').format(date);
    }
  }

  Widget _buildExpenseCard(Voucher expense) {
    final categoryName = _getCategoryName(expense.categoryId ?? 'other');

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.xs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showExpenseDetails(expense),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // أيقونة التصنيف
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.expenseSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppColors.expense,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                // التفاصيل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              expense.description ?? expense.voucherNumber,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.label_outline,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            categoryName,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.access_time,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            DateFormat('HH:mm').format(expense.voucherDate),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // المبلغ
                DualPriceDisplay(
                  amountSyp: expense.amount,
                  amountUsd: expense.amountUsd ?? 0,
                  type: DualPriceDisplayType.vertical,
                  alignment: CrossAxisAlignment.end,
                  sypStyle: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.expense,
                  ),
                  usdStyle: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExpenseDetails(Voucher expense) {
    final categoryName = _getCategoryName(expense.categoryId ?? 'other');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
            // Header
            Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: AppColors.expenseSurface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppColors.expense,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.voucherNumber,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        categoryName,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl),
            // المبلغ
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.expenseSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  Text(
                    'المبلغ',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  DualPriceDisplay(
                    amountSyp: expense.amount,
                    amountUsd: expense.amountUsd ?? 0,
                    type: DualPriceDisplayType.vertical,
                    alignment: CrossAxisAlignment.center,
                    sypStyle: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.expense,
                    ),
                    usdStyle: AppTypography.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'سعر الصرف: ${CurrencyFormatter.formatNumber(expense.exchangeRate)} ل.س/\$',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            // التفاصيل
            _DetailRow(
                label: 'التاريخ',
                value: DateFormat('yyyy/MM/dd HH:mm', 'ar')
                    .format(expense.voucherDate)),
            _DetailRow(label: 'الوصف', value: expense.description ?? '-'),
            _DetailRow(label: 'الوردية', value: expense.shiftId ?? '-'),
            SizedBox(height: AppSpacing.lg),
            // الأزرار
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(expense);
                    },
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    label:
                        Text('حذف', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/expenses/edit/${expense.id}');
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('تعديل'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Voucher expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
            'هل أنت متأكد من حذف المصروف "${expense.description ?? expense.voucherNumber}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final expenseRepo = ref.read(expenseRepositoryProvider);
                await expenseRepo.deleteExpense(expense.id);
                if (mounted) {
                  ProSnackbar.success(context, 'تم حذف المصروف بنجاح');
                }
              } catch (e) {
                if (mounted) {
                  ProSnackbar.error(context, e.toString());
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _selectedCategoryId != null ||
        _dateRange != null ||
        _searchController.text.isNotEmpty;

    return ProEmptyState(
      icon: hasFilters ? Icons.filter_list_off : Icons.receipt_long_outlined,
      title: hasFilters ? 'لا توجد نتائج' : 'لا توجد مصاريف',
      message: hasFilters
          ? 'جرب تغيير الفلاتر أو البحث'
          : 'ابدأ بتسجيل مصاريفك اليومية',
      actionLabel: hasFilters ? 'مسح الفلاتر' : 'إضافة مصروف',
      onAction: hasFilters
          ? () {
              setState(() {
                _selectedCategoryId = null;
                _dateRange = null;
                _searchController.clear();
              });
            }
          : () => context.push('/expenses/add'),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/expenses/add'),
      backgroundColor: AppColors.expense,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'مصروف جديد',
        style: AppTypography.labelLarge.copyWith(color: Colors.white),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widgets المساعدة
// ═══════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String title;
  final double amountSyp;
  final double amountUsd;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.amountSyp,
    required this.amountUsd,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: 16.sp),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          DualPriceDisplay(
            amountSyp: amountSyp,
            amountUsd: amountUsd,
            type: DualPriceDisplayType.vertical,
            sypStyle: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            usdStyle: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.secondaryMuted : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check : Icons.filter_list,
                size: 16.sp,
                color:
                    isSelected ? AppColors.secondary : AppColors.textSecondary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color:
                      isSelected ? AppColors.secondary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
