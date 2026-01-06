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
import '../../data/database/app_database.dart';

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
    } catch (e) {
      debugPrint('Error loading profit data: $e');
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

  @override
  Widget build(BuildContext context) {
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
      final monthData = _monthlyProfitData!.firstWhere(
        (item) => item['month'] == index + 1,
        orElse: () => {'month': index + 1, 'totalProfit': 0.0},
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
