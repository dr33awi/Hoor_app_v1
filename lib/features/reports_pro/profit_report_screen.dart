// ═══════════════════════════════════════════════════════════════════════════
// Profit Report Screen - Enterprise Design System
// تقرير الأرباح والخسائر المفصل
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';

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
  List<Map<String, dynamic>>? _dailyProfitData;
  List<Map<String, dynamic>>? _monthlyProfitData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Column(
          children: [
            ProHeader(
              title: 'تقرير الأرباح والخسائر',
              subtitle:
                  '${DateFormat('yyyy/MM/dd').format(_startDate)} - ${DateFormat('yyyy/MM/dd').format(_endDate)}',
              onBack: () => context.pop(),
              actions: [
                IconButton(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range_rounded),
                  tooltip: 'تحديد الفترة',
                ),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'تحديث',
                ),
              ],
            ),

            // Tabs
            Container(
              color: AppColors.surface,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'ملخص الأرباح'),
                  Tab(text: 'حسب الفئة'),
                  Tab(text: 'حسب العميل'),
                  Tab(text: 'الرسوم البيانية'),
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
                        _buildChartsTab(),
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

      final dailyProfitData = await db.getDailyProfitData(
        startDate: _startDate,
        endDate: _endDate,
      );

      final monthlyProfitData = await db.getMonthlyProfitData(
        year: DateTime.now().year,
      );

      setState(() {
        _profitReport = profitReport;
        _categoryReport = categoryReport;
        _customerReport = customerReport;
        _dailyProfitData = dailyProfitData;
        _monthlyProfitData = monthlyProfitData;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading profit data: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
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
      });
      _loadData();
    }
  }

  String _formatPrice(double price) {
    return '${NumberFormat('#,###').format(price)} ل.س';
  }

  String _formatUsd(double price) {
    return '\$${price.toStringAsFixed(2)}';
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
          // Net Profit Card
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
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
                      size: 32.sp,
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
                  _formatPrice(netProfit.abs()),
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatUsd((report['netProfitUsd'] as double).abs()),
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
                    'هامش الربح: ${(report['profitMargin'] as double).toStringAsFixed(1)}%',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Revenue Section
          Text('الإيرادات', style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.sm),
          _buildStatRow(
            'إجمالي المبيعات',
            report['totalRevenue'] as double,
            report['totalRevenueUsd'] as double,
            Icons.shopping_cart_rounded,
            AppColors.success,
          ),
          _buildStatRow(
            'مرتجعات المشتريات',
            report['totalPurchaseReturns'] as double,
            report['totalPurchaseReturnsUsd'] as double,
            Icons.assignment_return_rounded,
            AppColors.info,
          ),

          SizedBox(height: AppSpacing.md),

          // Purchases Section
          Text('المشتريات', style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.sm),
          _buildStatRow(
            'إجمالي المشتريات (${report['purchaseCount'] ?? 0} فاتورة)',
            (report['totalPurchases'] as double?) ?? 0,
            (report['totalPurchasesUsd'] as double?) ?? 0,
            Icons.shopping_bag_rounded,
            AppColors.secondary,
          ),

          SizedBox(height: AppSpacing.md),

          // Costs Section
          Text('التكاليف والمصروفات', style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.sm),
          _buildStatRow(
            'الخصومات',
            report['totalDiscounts'] as double,
            0,
            Icons.discount_rounded,
            AppColors.warning,
          ),
          _buildStatRow(
            'المصروفات',
            report['totalExpenses'] as double,
            report['totalExpensesUsd'] as double,
            Icons.receipt_long_rounded,
            AppColors.error,
          ),
          _buildStatRow(
            'مرتجعات المبيعات',
            report['totalSaleReturns'] as double,
            report['totalSaleReturnsUsd'] as double,
            Icons.replay_rounded,
            AppColors.error,
          ),
          // فروقات الجرد (مكاسب/خسائر المخزون)
          if ((report['inventoryAdjustments'] as double? ?? 0) != 0)
            _buildStatRow(
              (report['inventoryAdjustments'] as double) > 0
                  ? 'مكاسب جرد'
                  : 'خسائر جرد',
              (report['inventoryAdjustments'] as double).abs(),
              (report['inventoryAdjustmentsUsd'] as double? ?? 0).abs(),
              Icons.inventory_rounded,
              (report['inventoryAdjustments'] as double) > 0
                  ? AppColors.success
                  : AppColors.warning,
            ),

          SizedBox(height: AppSpacing.md),

          // Vouchers Section (سندات القبض والدفع)
          _buildVouchersSection(report),

          SizedBox(height: AppSpacing.md),

          // Cash Flow Section
          _buildCashFlowCard(report),

          SizedBox(height: AppSpacing.md),

          // Summary Stats
          Text('إحصائيات عامة', style: AppTypography.titleMedium),
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
      ),
    );
  }

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

  /// بطاقة التدفق النقدي
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: flowColor.soft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: flowColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'التدفق النقدي',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4.h),
                decoration: BoxDecoration(
                  color: flowColor.soft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  isPositive ? 'إيجابي' : 'سلبي',
                  style: AppTypography.labelSmall.copyWith(
                    color: flowColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // Cash Flow Value
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  flowColor.withOpacity(0.1),
                  flowColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: flowColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صافي التدفق النقدي',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(cashFlow.abs())} ل.س',
                      style: AppTypography.headlineSmall.copyWith(
                        color: flowColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (cashFlowUsd != 0)
                  Text(
                    '\$${cashFlowUsd.abs().toStringAsFixed(2)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: flowColor.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Breakdown
          Text(
            'المعادلة: مبيعات - مشتريات - مصروفات + قبض - دفع',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          // الصف الأول: مبيعات - مشتريات - مصروفات
          Row(
            children: [
              Expanded(
                child: _buildFlowItem(
                  'المبيعات',
                  totalRevenue,
                  AppColors.success,
                  '+',
                ),
              ),
              Expanded(
                child: _buildFlowItem(
                  'المشتريات',
                  totalPurchases,
                  AppColors.secondary,
                  '-',
                ),
              ),
              Expanded(
                child: _buildFlowItem(
                  'المصروفات',
                  totalExpenses,
                  AppColors.error,
                  '-',
                ),
              ),
            ],
          ),
          // الصف الثاني: سندات القبض والدفع (إذا وجدت)
          if (totalReceipts > 0 || totalPayments > 0) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (totalReceipts > 0)
                  Expanded(
                    child: _buildFlowItem(
                      'تحصيلات',
                      totalReceipts,
                      AppColors.success,
                      '+',
                    ),
                  ),
                if (totalPayments > 0)
                  Expanded(
                    child: _buildFlowItem(
                      'مدفوعات',
                      totalPayments,
                      AppColors.warning,
                      '-',
                    ),
                  ),
                // إضافة spacer إذا كان هناك عنصر واحد فقط
                if (totalReceipts == 0 || totalPayments == 0)
                  const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// قسم السندات (القبض والدفع)
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('السندات', style: AppTypography.titleMedium),
            SizedBox(width: AppSpacing.xs),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.info.soft,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                'للمعلومية',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.info,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          'لا تؤثر على صافي الربح - فقط حركة نقدية',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        if (receiptCount > 0)
          _buildStatRow(
            'سندات قبض ($receiptCount سند)',
            totalReceipts,
            totalReceiptsUsd,
            Icons.call_received_rounded,
            AppColors.success,
          ),
        if (paymentCount > 0)
          _buildStatRow(
            'سندات دفع ($paymentCount سند)',
            totalPayments,
            totalPaymentsUsd,
            Icons.call_made_rounded,
            AppColors.warning,
          ),
      ],
    );
  }

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
    return ProCard(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
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
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
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
          // Header with Pie Chart
          return Column(
            children: [
              if (_categoryReport!.isNotEmpty) _buildCategoryPieChart(),
              SizedBox(height: AppSpacing.md),
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

  Widget _buildCategoryPieChart() {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      AppColors.secondary,
      AppColors.error,
    ];

    return SizedBox(
      height: 200.h,
      child: PieChart(
        PieChartData(
          sections: _categoryReport!.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final profit = (item['totalProfit'] as double).abs();

            return PieChartSectionData(
              color: colors[index % colors.length],
              value: profit,
              title: '',
              radius: 60.r,
            );
          }).toList(),
          centerSpaceRadius: 40.r,
          sectionsSpace: 2,
        ),
      ),
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

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Profit Chart
          Text('الأرباح اليومية', style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.sm),
          ProCard(
            child: SizedBox(
              height: 250.h,
              child: _buildDailyProfitChart(),
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Monthly Profit Chart
          Text(
            'الأرباح الشهرية (${DateTime.now().year})',
            style: AppTypography.titleMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          ProCard(
            child: SizedBox(
              height: 250.h,
              child: _buildMonthlyProfitChart(),
            ),
          ),

          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildDailyProfitChart() {
    if (_dailyProfitData == null || _dailyProfitData!.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات للفترة المحددة',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final maxProfit = _dailyProfitData!.fold<double>(
      0,
      (max, item) {
        final profit = (item['totalProfit'] as double).abs();
        return profit > max ? profit : max;
      },
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxProfit > 0 ? maxProfit / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50.w,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact(locale: 'ar').format(value),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.h,
              interval: (_dailyProfitData!.length / 5).ceil().toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _dailyProfitData!.length) {
                  return const SizedBox();
                }
                final date = _dailyProfitData![index]['date'] as String;
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    date.substring(5), // MM-DD
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _dailyProfitData!.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value['totalProfit'] as double,
              );
            }).toList(),
            isCurved: true,
            color: AppColors.success,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.success.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyProfitChart() {
    if (_monthlyProfitData == null || _monthlyProfitData!.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات للسنة الحالية',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    // Fill missing months with 0
    final fullData = List.generate(12, (index) {
      final monthData =
          _monthlyProfitData!.cast<Map<String, dynamic>>().firstWhere(
                (item) => item['month'] == index + 1,
                orElse: () =>
                    <String, dynamic>{'month': index + 1, 'totalProfit': 0.0},
              );
      return monthData;
    });

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50.w,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact(locale: 'ar').format(value),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.h,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= 12) return const SizedBox();
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    monthNames[index].substring(0, 3),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: fullData.asMap().entries.map((entry) {
          final profit = (entry.value['totalProfit'] as num).toDouble();
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: profit,
                color: profit >= 0 ? AppColors.success : AppColors.error,
                width: 16.w,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xs),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
