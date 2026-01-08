// ═══════════════════════════════════════════════════════════════════════════
// Profit Report Screen - Enterprise Design System
// تقرير الأرباح والخسائر المفصل
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/export/reports_export_service.dart';
import '../../core/services/export/export_service.dart';
import '../../core/services/export/export_button.dart';

class ProfitReportScreen extends ConsumerStatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  ConsumerState<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends ConsumerState<ProfitReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  Map<String, dynamic>? _profitReport;
  List<Map<String, dynamic>>? _categoryReport;
  List<Map<String, dynamic>>? _customerReport;
  List<Map<String, dynamic>>? _productReport;

  // بيانات مقارنة الفترات
  Map<String, dynamic>? _previousPeriodReport;

  bool _isLoading = true;
  bool _isExporting = false;

  // فلتر سريع للفترة
  String _quickFilter = 'month'; // 'week', 'month', 'quarter', 'year', 'custom'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _applyQuickFilter('month');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyQuickFilter(String filter) {
    final now = DateTime.now();
    setState(() {
      _quickFilter = filter;
      switch (filter) {
        case 'week':
          _startDate = now.subtract(const Duration(days: 7));
          _endDate = now;
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'quarter':
          final quarterStart =
              DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
          _startDate = quarterStart;
          _endDate = now;
          break;
        case 'year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
        case 'custom':
          // لا تغير - المستخدم سيختار
          return;
      }
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ مراقبة تغييرات الفواتير والسندات للتحديث التلقائي
    ref.listen(invoicesStreamProvider, (previous, next) {
      // تحديث فقط عند تغيير البيانات الفعلية (ليس عند التحميل الأول)
      if (previous?.value != null && next.value != null) {
        if (previous!.value!.length != next.value!.length) {
          _loadData();
        }
      }
    });

    ref.listen(vouchersStreamProvider, (previous, next) {
      if (previous?.value != null && next.value != null) {
        if (previous!.value!.length != next.value!.length) {
          _loadData();
        }
      }
    });

    return _buildContent();
  }

  Widget _buildContent() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProAppBar.simple(
        title: 'تقرير الأرباح والخسائر',
        actions: [
          ProAppBarAction(
            icon: Icons.refresh_rounded,
            onPressed: _loadData,
          ),
          ExportMenuButton(
            onExport: _handleExport,
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
      body: SafeArea(
        child: Column(
          children: [
            // Quick Filter Chips
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.3)),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                        'أسبوع', 'week', Icons.calendar_view_week_rounded),
                    SizedBox(width: AppSpacing.xs),
                    _buildFilterChip(
                        'شهر', 'month', Icons.calendar_month_rounded),
                    SizedBox(width: AppSpacing.xs),
                    _buildFilterChip(
                        'ربع سنة', 'quarter', Icons.date_range_rounded),
                    SizedBox(width: AppSpacing.xs),
                    _buildFilterChip(
                        'سنة', 'year', Icons.calendar_today_rounded),
                    SizedBox(width: AppSpacing.xs),
                    _buildFilterChip(
                        'مخصص', 'custom', Icons.edit_calendar_rounded,
                        isCustom: true),
                  ],
                ),
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5), width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTypography.labelMedium,
                tabs: const [
                  Tab(text: 'ملخص الأرباح'),
                  Tab(text: 'حسب الفئة'),
                  Tab(text: 'حسب العميل'),
                  Tab(text: 'حسب المنتج'),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? ProLoadingState.card()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSummaryTab(),
                        _buildCategoryTab(),
                        _buildCustomerTab(),
                        _buildProductTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);

      final profitReport = await db.getEnhancedProfitReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      final categoryReport = await db.getProfitByCategory(
        startDate: _startDate,
        endDate: _endDate,
      );

      final customerReport = await db.getProfitByCustomer(
        startDate: _startDate,
        endDate: _endDate,
      );

      // تقرير حسب المنتج
      final productReport = await db.getProfitByProduct(
        startDate: _startDate,
        endDate: _endDate,
      );

      // تحميل بيانات الفترة السابقة للمقارنة
      final periodDuration = _endDate.difference(_startDate);
      final previousStart = _startDate.subtract(periodDuration);
      final previousEnd = _startDate.subtract(const Duration(days: 1));

      final previousPeriodReport = await db.getEnhancedProfitReport(
        startDate: previousStart,
        endDate: previousEnd,
      );

      setState(() {
        _profitReport = profitReport;
        _categoryReport = categoryReport;
        _customerReport = customerReport;
        _productReport = productReport;
        _previousPeriodReport = previousPeriodReport;
        _isLoading = false;
      });

      // طباعة تصحيحية للمصاريف الدورية
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📊 تقرير الأرباح والخسائر:');
      debugPrint('   إجمالي المصاريف: ${profitReport['totalExpenses']}');
      debugPrint('   المصاريف الدورية: ${profitReport['recurringExpenses']}');
      debugPrint(
          '   المصاريف الموزعة (أقساط): ${profitReport['distributedExpenses']}');
      debugPrint('═══════════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading profit data: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  /// التعامل مع جميع خيارات التصدير
  Future<void> _handleExport(ExportType type) async {
    if (_profitReport == null) return;

    setState(() => _isExporting = true);

    try {
      final sales = ref.read(salesInvoicesProvider).value ?? [];
      final purchases = ref.read(purchaseInvoicesProvider).value ?? [];
      final settings = await ExportService.getExportSettings();

      final filteredSales = sales
          .where((inv) =>
              inv.status != 'cancelled' &&
              inv.invoiceDate
                  .isAfter(_startDate.subtract(const Duration(days: 1))) &&
              inv.invoiceDate.isBefore(_endDate.add(const Duration(days: 1))))
          .toList();

      final filteredPurchases = purchases
          .where((inv) =>
              inv.status != 'cancelled' &&
              inv.invoiceDate
                  .isAfter(_startDate.subtract(const Duration(days: 1))) &&
              inv.invoiceDate.isBefore(_endDate.add(const Duration(days: 1))))
          .toList();

      final dateRange = DateTimeRange(start: _startDate, end: _endDate);
      final fileName =
          'profit_report_${DateFormat('yyyy-MM-dd').format(_startDate)}_${DateFormat('yyyy-MM-dd').format(_endDate)}';

      switch (type) {
        case ExportType.pdf:
          final pdfBytes = await ReportsExportService.generateProfitReportPdf(
            sales: filteredSales,
            purchases: filteredPurchases,
            dateRange: dateRange,
            settings: settings,
          );
          if (mounted) {
            await Printing.layoutPdf(
              onLayout: (_) => pdfBytes,
              name: '$fileName.pdf',
            );
          }
          break;

        case ExportType.excel:
          final excelPath =
              await ReportsExportService.exportProfitReportToExcel(
            sales: filteredSales,
            purchases: filteredPurchases,
            dateRange: dateRange,
            fileName: fileName,
          );
          if (mounted) {
            ProSnackbar.success(context, 'تم حفظ ملف Excel بنجاح');
            debugPrint('Excel saved at: $excelPath');
          }
          break;

        case ExportType.sharePdf:
          final pdfBytes = await ReportsExportService.generateProfitReportPdf(
            sales: filteredSales,
            purchases: filteredPurchases,
            dateRange: dateRange,
            settings: settings,
          );
          await ReportsExportService.sharePdfBytes(
            pdfBytes,
            fileName: fileName,
            subject: 'تقرير الأرباح والخسائر',
          );
          break;

        case ExportType.shareExcel:
          final excelPath =
              await ReportsExportService.exportProfitReportToExcel(
            sales: filteredSales,
            purchases: filteredPurchases,
            dateRange: dateRange,
            fileName: fileName,
          );
          await ReportsExportService.shareFile(
            excelPath,
            subject: 'تقرير الأرباح والخسائر',
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في تصدير التقرير: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _quickFilter = 'custom';
      });
      _loadData();
    }
  }

  Widget _buildFilterChip(String label, String filter, IconData icon,
      {bool isCustom = false}) {
    final isSelected = _quickFilter == filter;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isCustom) {
            _selectDateRange();
          } else {
            _applyQuickFilter(filter);
          }
        },
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8)
                    ],
                  )
                : null,
            color: isSelected ? null : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return '${NumberFormat('#,###').format(price)} ل.س';
  }

  String _formatUsd(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  /// بطاقة مقارنة مع الفترة السابقة - محسنة
  // ignore: unused_element
  Widget _buildPeriodComparisonCard(Map<String, dynamic> currentReport) {
    if (_previousPeriodReport == null) return const SizedBox.shrink();

    final previousReport = _previousPeriodReport!;
    final currentProfit = currentReport['netProfit'] as double;
    final previousProfit = previousReport['netProfit'] as double;
    final currentRevenue = currentReport['totalRevenue'] as double;
    final previousRevenue = previousReport['totalRevenue'] as double;
    final currentExpenses = currentReport['totalExpenses'] as double;
    final previousExpenses = previousReport['totalExpenses'] as double;

    final profitChange = previousProfit != 0
        ? ((currentProfit - previousProfit) / previousProfit.abs() * 100)
        : (currentProfit > 0 ? 100.0 : 0.0);
    final revenueChange = previousRevenue != 0
        ? ((currentRevenue - previousRevenue) / previousRevenue.abs() * 100)
        : (currentRevenue > 0 ? 100.0 : 0.0);
    final expenseChange = previousExpenses != 0
        ? ((currentExpenses - previousExpenses) / previousExpenses.abs() * 100)
        : (currentExpenses > 0 ? 100.0 : 0.0);

    // تحديد اللون العام للبطاقة بناءً على الأداء
    final overallPositive = profitChange >= 0;
    final borderColor = overallPositive ? AppColors.success : AppColors.error;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            borderColor.withValues(alpha: 0.08),
            AppColors.surface,
            borderColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header مع badge
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        borderColor.withValues(alpha: 0.2),
                        borderColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.compare_arrows_rounded,
                    color: borderColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مقارنة مع الفترة السابقة',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        overallPositive
                            ? 'أداء أفضل من السابق ✨'
                            : 'يحتاج تحسين 📊',
                        style: AppTypography.labelSmall.copyWith(
                          color: borderColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge الأداء العام
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: overallPositive
                          ? [
                              AppColors.success,
                              AppColors.success.withValues(alpha: 0.8)
                            ]
                          : [
                              AppColors.error,
                              AppColors.error.withValues(alpha: 0.8)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        overallPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${profitChange.abs().toStringAsFixed(0)}%',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            // عناصر المقارنة
            Row(
              children: [
                Expanded(
                  child: _buildComparisonItem(
                    'الأرباح',
                    currentProfit,
                    previousProfit,
                    profitChange,
                    Icons.account_balance_wallet_rounded,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildComparisonItem(
                    'الإيرادات',
                    currentRevenue,
                    previousRevenue,
                    revenueChange,
                    Icons.trending_up_rounded,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildComparisonItem(
                    'المصاريف',
                    currentExpenses,
                    previousExpenses,
                    expenseChange,
                    Icons.money_off_rounded,
                    invertColors: true, // للمصاريف: الزيادة سلبية
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(
    String label,
    double current,
    double previous,
    double changePercent,
    IconData icon, {
    bool invertColors = false,
  }) {
    // للمصاريف: الزيادة سلبية والنقصان إيجابي
    final isPositive = invertColors ? changePercent <= 0 : changePercent >= 0;
    final displayPercent = changePercent.abs();
    final color = isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.1),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            _formatPrice(current),
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          // Badge التغيير
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  changePercent >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 10.sp,
                  color: color,
                ),
                SizedBox(width: 2.w),
                Text(
                  '${displayPercent.toStringAsFixed(1)}%',
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// قسم مؤشرات الأداء الرئيسية KPIs المحسن
  Widget _buildKPIsSection(Map<String, dynamic> report) {
    final totalRevenue = report['totalRevenue'] as double;
    final grossProfit = report['grossProfit'] as double;
    final netProfit = report['netProfit'] as double;
    final totalInvoices = (report['totalInvoices'] as num?)?.toInt() ?? 0;
    final totalExpenses = report['totalExpenses'] as double;
    final totalPurchases = (report['totalPurchases'] as double?) ?? 0;

    // حساب KPIs
    final profitMargin =
        totalRevenue > 0 ? (netProfit / totalRevenue * 100) : 0.0;
    final grossMargin =
        totalRevenue > 0 ? (grossProfit / totalRevenue * 100) : 0.0;
    final avgProfitPerInvoice =
        totalInvoices > 0 ? (netProfit / totalInvoices) : 0.0;
    final avgRevenuePerInvoice =
        totalInvoices > 0 ? (totalRevenue / totalInvoices) : 0.0;
    final roi = totalPurchases > 0 ? ((netProfit / totalPurchases) * 100) : 0.0;
    final expenseRatio =
        totalRevenue > 0 ? (totalExpenses / totalRevenue * 100) : 0.0;

    return ProCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.analytics_rounded,
                    color: AppColors.primary, size: 20.sp),
              ),
              SizedBox(width: AppSpacing.sm),
              Text('مؤشرات الأداء الرئيسية', style: AppTypography.titleMedium),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // الصف الأول: هوامش الربح
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  'هامش الربح الصافي',
                  '${profitMargin.toStringAsFixed(1)}%',
                  Icons.trending_up_rounded,
                  profitMargin >= 0 ? AppColors.success : AppColors.error,
                  subtitle: 'صافي / إيرادات',
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildKPICard(
                  'هامش الربح الإجمالي',
                  '${grossMargin.toStringAsFixed(1)}%',
                  Icons.show_chart_rounded,
                  AppColors.info,
                  subtitle: 'إجمالي / إيرادات',
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // الصف الثاني: متوسطات
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  'متوسط الفاتورة',
                  _formatPrice(avgRevenuePerInvoice),
                  Icons.receipt_long_rounded,
                  AppColors.secondary,
                  isCompact: true,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildKPICard(
                  'ربح/فاتورة',
                  _formatPrice(avgProfitPerInvoice),
                  Icons.attach_money_rounded,
                  avgProfitPerInvoice >= 0
                      ? AppColors.success
                      : AppColors.error,
                  isCompact: true,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // الصف الثالث: ROI ونسبة المصاريف
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  'العائد على الاستثمار',
                  '${roi.toStringAsFixed(1)}%',
                  Icons.pie_chart_rounded,
                  roi >= 0 ? AppColors.primary : AppColors.warning,
                  subtitle: 'ROI',
                  isCompact: true,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildKPICard(
                  'نسبة المصاريف',
                  '${expenseRatio.toStringAsFixed(1)}%',
                  Icons.money_off_rounded,
                  expenseRatio <= 30
                      ? AppColors.success
                      : (expenseRatio <= 50
                          ? AppColors.warning
                          : AppColors.error),
                  isCompact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isCompact ? 14.sp : 16.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isCompact ? 10.sp : 11.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 4.h : 8.h),
          Text(
            value,
            style: (isCompact
                    ? AppTypography.labelLarge
                    : AppTypography.titleMedium)
                .copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 9.sp,
              ),
            ),
        ],
      ),
    );
  }

  // الدالة القديمة للحفاظ على التوافقية
  // ignore: unused_element
  Widget _buildKPIItem(String label, String value, Color color) {
    return _buildKPICard(label, value, Icons.analytics_rounded, color,
        isCompact: true);
  }

  Widget _buildSummaryTab() {
    if (_profitReport == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    final report = _profitReport!;
    final netProfit = report['netProfit'] as double;
    final isProfit = netProfit >= 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════
          // القسم 1: بطاقة صافي الربح الرئيسية
          // ═══════════════════════════════════════════════════════════
          _buildMainProfitCard(report, isProfit, netProfit),

          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════
          // القسم 2: مؤشرات الأداء
          // ═══════════════════════════════════════════════════════════
          _buildKPIsSection(report),

          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════
          // القسم 3: قائمة الدخل المفصلة
          // ═══════════════════════════════════════════════════════════
          _buildIncomeStatementCard(report),

          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════
          // القسم 4: التدفق النقدي والسندات
          // ═══════════════════════════════════════════════════════════
          _buildCashFlowCard(report),

          SizedBox(height: AppSpacing.md),
          _buildVouchersSection(report),

          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════
          // القسم 5: إحصائيات سريعة
          // ═══════════════════════════════════════════════════════════
          _buildQuickStatsSection(report),

          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// بطاقة صافي الربح الرئيسية - مصغرة
  Widget _buildMainProfitCard(
      Map<String, dynamic> report, bool isProfit, double netProfit) {
    final profitMargin = report['profitMargin'] as double;
    final netProfitUsd = (report['netProfitUsd'] as double?) ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: isProfit
            ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.success,
                  AppColors.success.withValues(alpha: 0.85),
                ],
              )
            : LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.error,
                  AppColors.error.withValues(alpha: 0.85),
                ],
              ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // الأيقونة
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isProfit
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          // المعلومات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isProfit ? 'صافي الربح' : 'صافي الخسارة',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  _formatPrice(netProfit.abs()),
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // هامش الربح والفترة
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${profitMargin.toStringAsFixed(1)}%',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                _formatUsd(netProfitUsd.abs()),
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بطاقة قائمة الدخل المفصلة
  Widget _buildIncomeStatementCard(Map<String, dynamic> report) {
    return ProCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.soft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text('قائمة الدخل', style: AppTypography.titleMedium),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // ═══ الإيرادات ═══
          _buildSectionHeader(
              'الإيرادات', Icons.arrow_upward_rounded, AppColors.success),
          SizedBox(height: AppSpacing.sm),
          _buildIncomeRow(
            'إجمالي المبيعات',
            report['totalRevenue'] as double,
            report['totalRevenueUsd'] as double,
            isRevenue: true,
          ),
          _buildIncomeRow(
            'مرتجعات المشتريات',
            report['totalPurchaseReturns'] as double,
            report['totalPurchaseReturnsUsd'] as double,
            isRevenue: true,
          ),
          _buildSubtotalRow(
            'إجمالي الإيرادات',
            (report['totalRevenue'] as double) +
                (report['totalPurchaseReturns'] as double),
            AppColors.success,
          ),

          SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.border, height: 1),
          SizedBox(height: AppSpacing.md),

          // ═══ التكاليف والمصروفات ═══
          _buildSectionHeader('التكاليف والمصروفات',
              Icons.arrow_downward_rounded, AppColors.error),
          SizedBox(height: AppSpacing.sm),
          _buildIncomeRow(
            'تكلفة المشتريات (${report['purchaseCount'] ?? 0} فاتورة)',
            (report['totalPurchases'] as double?) ?? 0,
            (report['totalPurchasesUsd'] as double?) ?? 0,
            isExpense: true,
          ),
          _buildIncomeRow(
            'الخصومات الممنوحة',
            report['totalDiscounts'] as double,
            0,
            isExpense: true,
          ),
          _buildIncomeRow(
            'المصروفات التشغيلية',
            report['totalExpenses'] as double,
            report['totalExpensesUsd'] as double,
            isExpense: true,
          ),
          if ((report['recurringExpenses'] as double?) != null &&
              (report['recurringExpenses'] as double) > 0)
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.lg),
              child: _buildIncomeRow(
                '↳ منها مصاريف دورية',
                report['recurringExpenses'] as double,
                (report['recurringExpensesUsd'] as double?) ?? 0,
                isSubItem: true,
              ),
            ),
          if ((report['distributedExpenses'] as double?) != null &&
              (report['distributedExpenses'] as double) > 0)
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.lg * 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIncomeRow(
                    '↳ أقساط مصاريف موزعة',
                    report['distributedExpenses'] as double,
                    (report['distributedExpensesUsd'] as double?) ?? 0,
                    isSubItem: true,
                    subtitle: '(قسط الفترة من مصاريف سنوية/ربعية)',
                  ),
                ],
              ),
            ),
          _buildIncomeRow(
            'مرتجعات المبيعات',
            report['totalSaleReturns'] as double,
            report['totalSaleReturnsUsd'] as double,
            isExpense: true,
          ),
          if ((report['inventoryAdjustments'] as double? ?? 0) != 0)
            _buildIncomeRow(
              (report['inventoryAdjustments'] as double) > 0
                  ? 'مكاسب الجرد'
                  : 'خسائر الجرد',
              (report['inventoryAdjustments'] as double).abs(),
              (report['inventoryAdjustmentsUsd'] as double? ?? 0).abs(),
              isRevenue: (report['inventoryAdjustments'] as double) > 0,
              isExpense: (report['inventoryAdjustments'] as double) < 0,
            ),

          _buildSubtotalRow(
            'إجمالي التكاليف',
            ((report['totalPurchases'] as double?) ?? 0) +
                (report['totalDiscounts'] as double) +
                (report['totalExpenses'] as double) +
                (report['totalSaleReturns'] as double),
            AppColors.error,
          ),

          SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.border, thickness: 2, height: 2),
          SizedBox(height: AppSpacing.md),

          // ═══ صافي الربح ═══
          _buildNetProfitRow(report),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16.sp),
        SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeRow(
    String label,
    double amount,
    double amountUsd, {
    bool isRevenue = false,
    bool isExpense = false,
    bool isSubItem = false,
    String? subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSubItem
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontWeight: isSubItem ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? "-" : ""}${_formatPrice(amount)}',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSubItem
                      ? AppColors.textSecondary
                      : (isRevenue
                          ? AppColors.success
                          : (isExpense ? AppColors.error : null)),
                ),
              ),
              if (amountUsd > 0)
                Text(
                  _formatUsd(amountUsd),
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

  Widget _buildSubtotalRow(String label, double amount, Color color) {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            _formatPrice(amount),
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetProfitRow(Map<String, dynamic> report) {
    final netProfit = report['netProfit'] as double;
    final isProfit = netProfit >= 0;
    final color = isProfit ? AppColors.success : AppColors.error;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05)
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isProfit
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: color,
                size: 24.sp,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                isProfit ? 'صافي الربح' : 'صافي الخسارة',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(netProfit.abs()),
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                _formatUsd((report['netProfitUsd'] as double).abs()),
                style: AppTypography.labelMedium.copyWith(
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// قسم الإحصائيات السريعة
  Widget _buildQuickStatsSection(Map<String, dynamic> report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.insights_rounded, color: AppColors.primary, size: 20.sp),
            SizedBox(width: AppSpacing.xs),
            Text('إحصائيات سريعة', style: AppTypography.titleMedium),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                'عدد الفواتير',
                '${report['totalInvoices']}',
                Icons.receipt_rounded,
                AppColors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildMiniStatCard(
                'المنتجات المباعة',
                '${report['totalItemsSold']}',
                Icons.inventory_2_rounded,
                AppColors.secondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                'إجمالي الربح',
                _formatPrice(report['grossProfit'] as double),
                Icons.trending_up_rounded,
                AppColors.success,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildMiniStatCard(
                'هامش الربح',
                '${(report['profitMargin'] as double).toStringAsFixed(1)}%',
                Icons.percent_rounded,
                AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildStatRow(
    String label,
    double amount,
    double amountUsd,
    IconData icon,
    Color color,
  ) {
    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label, style: AppTypography.bodyMedium),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(amount),
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (amountUsd > 0)
                Text(
                  _formatUsd(amountUsd),
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

  /// بطاقة التدفق النقدي المحسنة
  Widget _buildCashFlowCard(Map<String, dynamic> report) {
    final cashFlow = (report['cashFlow'] as double?) ?? 0;
    final cashFlowUsd = (report['cashFlowUsd'] as double?) ?? 0;
    final totalRevenue = report['totalRevenue'] as double;
    final totalPurchases = (report['totalPurchases'] as double?) ?? 0;
    final totalExpenses = report['totalExpenses'] as double;
    final totalReceipts = (report['totalReceipts'] as double?) ?? 0;
    final totalPayments = (report['totalPayments'] as double?) ?? 0;

    final isPositive = cashFlow >= 0;
    final flowColor = isPositive ? AppColors.success : AppColors.error;

    return ProCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان مع الحالة
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      flowColor.withValues(alpha: 0.2),
                      flowColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  isPositive
                      ? Icons.account_balance_wallet_rounded
                      : Icons.money_off_rounded,
                  color: flowColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التدفق النقدي',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'حركة الأموال خلال الفترة',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 6.h),
                decoration: BoxDecoration(
                  color: flowColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: flowColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: flowColor,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isPositive ? 'إيجابي' : 'سلبي',
                      style: AppTypography.labelSmall.copyWith(
                        color: flowColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // قيمة التدفق النقدي الرئيسية
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  flowColor.withValues(alpha: 0.12),
                  flowColor.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: flowColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  'صافي التدفق النقدي',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '${isPositive ? "+" : "-"}${NumberFormat('#,###').format(cashFlow.abs())} ل.س',
                  style: AppTypography.headlineMedium.copyWith(
                    color: flowColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (cashFlowUsd != 0)
                  Text(
                    '\$${cashFlowUsd.abs().toStringAsFixed(2)}',
                    style: AppTypography.titleSmall.copyWith(
                      color: flowColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // تفاصيل التدفق النقدي
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border:
                  Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                // التدفقات الداخلة
                _buildCashFlowSection(
                  'التدفقات الداخلة',
                  Icons.arrow_circle_down_rounded,
                  AppColors.success,
                  [
                    _buildCashFlowDetailRow('المبيعات', totalRevenue),
                    if (totalReceipts > 0)
                      _buildCashFlowDetailRow('التحصيلات', totalReceipts),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Divider(color: AppColors.border, height: 1),
                SizedBox(height: AppSpacing.sm),
                // التدفقات الخارجة
                _buildCashFlowSection(
                  'التدفقات الخارجة',
                  Icons.arrow_circle_up_rounded,
                  AppColors.error,
                  [
                    _buildCashFlowDetailRow('المشتريات', totalPurchases),
                    _buildCashFlowDetailRow('المصروفات', totalExpenses),
                    if (totalPayments > 0)
                      _buildCashFlowDetailRow('المدفوعات', totalPayments),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowSection(
      String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: AppSpacing.xs),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        ...children,
      ],
    );
  }

  Widget _buildCashFlowDetailRow(String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            _formatPrice(amount),
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// قسم السندات المحسن (القبض والدفع)
  Widget _buildVouchersSection(Map<String, dynamic> report) {
    final receiptCount = (report['receiptCount'] as int?) ?? 0;
    final totalReceipts = (report['totalReceipts'] as double?) ?? 0;
    final totalReceiptsUsd = (report['totalReceiptsUsd'] as double?) ?? 0;
    final paymentCount = (report['paymentCount'] as int?) ?? 0;
    final totalPayments = (report['totalPayments'] as double?) ?? 0;
    final totalPaymentsUsd = (report['totalPaymentsUsd'] as double?) ?? 0;

    // لا تعرض القسم إذا لم تكن هناك سندات
    if (receiptCount == 0 && paymentCount == 0) {
      return const SizedBox.shrink();
    }

    final netVouchers = totalReceipts - totalPayments;

    return ProCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.info,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('السندات', style: AppTypography.titleMedium),
                    Text(
                      'لا تؤثر على صافي الربح - حركة نقدية فقط',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // بطاقات السندات
          Row(
            children: [
              if (receiptCount > 0)
                Expanded(
                  child: _buildVoucherCard(
                    'سندات القبض',
                    receiptCount,
                    totalReceipts,
                    totalReceiptsUsd,
                    Icons.call_received_rounded,
                    AppColors.success,
                  ),
                ),
              if (receiptCount > 0 && paymentCount > 0)
                SizedBox(width: AppSpacing.sm),
              if (paymentCount > 0)
                Expanded(
                  child: _buildVoucherCard(
                    'سندات الدفع',
                    paymentCount,
                    totalPayments,
                    totalPaymentsUsd,
                    Icons.call_made_rounded,
                    AppColors.warning,
                  ),
                ),
            ],
          ),

          // صافي السندات
          if (receiptCount > 0 && paymentCount > 0) ...[
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'صافي السندات',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${netVouchers >= 0 ? "+" : ""}${_formatPrice(netVouchers)}',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: netVouchers >= 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoucherCard(
    String title,
    int count,
    double amount,
    double amountUsd,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            _formatPrice(amount),
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (amountUsd > 0)
            Text(
              _formatUsd(amountUsd),
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildFlowItem(String label, double value, Color color, String sign) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '$sign${NumberFormat('#,###').format(value)}',
          style: AppTypography.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab() {
    if (_categoryReport == null || _categoryReport!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_rounded,
                size: 64.sp, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.md),
            Text('لا توجد بيانات', style: AppTypography.bodyLarge),
          ],
        ),
      );
    }

    final totalProfit = _categoryReport!.fold<double>(
      0,
      (sum, item) => sum + (item['totalProfit'] as double),
    );

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: _categoryReport!.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'الفئة',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    'الربح',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: 60.w),
                  Text(
                    'النسبة',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
            ],
          );
        }

        final item = _categoryReport![index - 1];
        final profit = item['totalProfit'] as double;
        final percentage = totalProfit > 0 ? (profit / totalProfit * 100) : 0.0;
        final colors = [
          AppColors.primary,
          AppColors.success,
          AppColors.warning,
          AppColors.info,
          AppColors.secondary,
          AppColors.error,
        ];
        final color = colors[(index - 1) % colors.length];

        return ProCard(
          margin: EdgeInsets.only(bottom: AppSpacing.xs),
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['categoryName'] as String,
                      style: AppTypography.labelLarge,
                    ),
                    Text(
                      '${item['invoiceCount']} فاتورة · ${item['totalQuantity']} منتج',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatPrice(profit),
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: profit >= 0 ? AppColors.success : AppColors.error,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Container(
                width: 50.w,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerTab() {
    if (_customerReport == null || _customerReport!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_rounded,
                size: 64.sp, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.md),
            Text('لا توجد بيانات', style: AppTypography.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: _customerReport!.length,
      itemBuilder: (context, index) {
        final item = _customerReport![index];
        final profit = item['totalProfit'] as double;

        // Badge for top 3
        Widget? badge;
        if (index == 0) {
          badge = _buildRankBadge('🥇', const Color(0xFFFFD700));
        } else if (index == 1) {
          badge = _buildRankBadge('🥈', const Color(0xFFC0C0C0));
        } else if (index == 2) {
          badge = _buildRankBadge('🥉', const Color(0xFFCD7F32));
        }

        return ProCard(
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              if (badge != null) ...[
                badge,
                SizedBox(width: AppSpacing.sm),
              ] else ...[
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['customerName'] as String,
                      style: AppTypography.labelLarge,
                    ),
                    Text(
                      '${item['invoiceCount']} فاتورة · ${item['totalQuantity']} منتج',
                      style: AppTypography.labelSmall.copyWith(
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
                    _formatPrice(profit),
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: profit >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text(
                    'إجمالي: ${_formatPrice(item['totalRevenue'] as double)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(String emoji, Color color) {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: 18.sp)),
      ),
    );
  }

  /// تبويب الأرباح حسب المنتج
  Widget _buildProductTab() {
    if (_productReport == null || _productReport!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_rounded,
                size: 64.sp, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.md),
            Text('لا توجد بيانات', style: AppTypography.bodyLarge),
          ],
        ),
      );
    }

    final totalProfit = _productReport!.fold<double>(
      0,
      (sum, item) => sum + (item['totalProfit'] as double),
    );

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: _productReport!.length,
      itemBuilder: (context, index) {
        final item = _productReport![index];
        final profit = item['totalProfit'] as double;
        final percentage =
            totalProfit != 0 ? (profit / totalProfit * 100).abs() : 0.0;

        // Badge for top 3
        Widget? badge;
        if (index == 0) {
          badge = _buildRankBadge('🥇', const Color(0xFFFFD700));
        } else if (index == 1) {
          badge = _buildRankBadge('🥈', const Color(0xFFC0C0C0));
        } else if (index == 2) {
          badge = _buildRankBadge('🥉', const Color(0xFFCD7F32));
        }

        return ProCard(
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              if (badge != null) ...[
                badge,
                SizedBox(width: AppSpacing.sm),
              ] else ...[
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['productName'] as String,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          '${(item['totalQuantity'] as num).toInt()} قطعة',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPrice(profit),
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: profit >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text(
                    'إجمالي: ${_formatPrice(item['totalRevenue'] as double)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
