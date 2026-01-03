import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/pos_widgets.dart';
import '../providers/reports_provider.dart';

/// شاشة التقارير
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'المبيعات'),
            Tab(text: 'المنتجات'),
            Tab(text: 'المالية'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDateFilter(context, ref),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'export_pdf', child: Text('تصدير PDF')),
              const PopupMenuItem(
                  value: 'export_excel', child: Text('تصدير Excel')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'print', child: Text('طباعة')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          _SalesTab(),
          _ProductsTab(),
          _FinancialTab(),
        ],
      ),
    );
  }

  void _showDateFilter(BuildContext context, WidgetRef ref) {
    // TODO: عرض فلتر التاريخ
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'export_pdf':
        ref.read(reportsProvider.notifier).exportToPdf();
        break;
      case 'export_excel':
        ref.read(reportsProvider.notifier).exportToExcel();
        break;
      case 'print':
        ref.read(reportsProvider.notifier).print();
        break;
    }
  }
}

/// تبويب النظرة العامة
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(reportsProvider);

    if (reportsState.isLoading) {
      return const LoadingView(message: 'جاري تحميل التقارير...');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(reportsProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقات الملخص
            _buildSummaryCards(context, reportsState),

            SizedBox(height: 24.h),

            // رسم بياني للمبيعات
            _buildSalesChart(context, reportsState),

            SizedBox(height: 24.h),

            // المنتجات الأكثر مبيعاً
            _buildTopProductsSection(context, reportsState),

            SizedBox(height: 24.h),

            // توزيع طرق الدفع
            _buildPaymentMethodsChart(context, reportsState),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, ReportsState state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'إجمالي المبيعات',
          value: '${state.totalSales.toStringAsFixed(0)} ر.س',
          icon: Icons.attach_money,
          color: AppColors.success,
          subtitle: '${state.invoicesCount} فاتورة',
        ),
        StatCard(
          title: 'صافي الربح',
          value: '${state.netProfit.toStringAsFixed(0)} ر.س',
          icon: Icons.trending_up,
          color: AppColors.primary,
          subtitle: '${state.profitMargin.toStringAsFixed(1)}%',
        ),
        StatCard(
          title: 'متوسط الفاتورة',
          value: '${state.averageInvoice.toStringAsFixed(0)} ر.س',
          icon: Icons.receipt,
          color: AppColors.info,
        ),
        StatCard(
          title: 'المنتجات المباعة',
          value: '${state.productsSold}',
          icon: Icons.inventory_2,
          color: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildSalesChart(BuildContext context, ReportsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المبيعات', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 24.h),
            SizedBox(
              height: 200.h,
              child: state.salesData.isEmpty
                  ? const Center(child: Text('لا توجد بيانات'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: state.salesData
                                .map((e) => e.value)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${state.salesData[groupIndex].label}\n${rod.toY.toStringAsFixed(0)} ر.س',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < state.salesData.length) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Text(
                                      state.salesData[value.toInt()].label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _formatCompactNumber(value),
                                  style: Theme.of(context).textTheme.labelSmall,
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                        ),
                        barGroups: state.salesData.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.value,
                                color: AppColors.primary,
                                width: 20,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(4.r)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsSection(BuildContext context, ReportsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المنتجات الأكثر مبيعاً',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16.h),
            if (state.topProducts.isEmpty)
              const Center(child: Text('لا توجد بيانات'))
            else
              ...state.topProducts
                  .take(5)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final product = entry.value;
                final maxSales = state.topProducts.first.sales;
                final percentage =
                    maxSales > 0 ? product.sales / maxSales : 0.0;

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14.r,
                            backgroundColor:
                                _getRankColor(index).withValues(alpha: 0.1),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: _getRankColor(index),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              product.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              PriceText(price: product.sales, compact: true),
                              Text(
                                '${product.quantity.toInt()} وحدة',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor:
                              AlwaysStoppedAnimation(_getRankColor(index)),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsChart(BuildContext context, ReportsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('توزيع طرق الدفع',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 24.h),
            SizedBox(
              height: 200.h,
              child: state.paymentMethods.isEmpty
                  ? const Center(child: Text('لا توجد بيانات'))
                  : Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40.r,
                              sections: state.paymentMethods
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final method = entry.value;
                                return PieChartSectionData(
                                  color: _getPaymentMethodColor(index),
                                  value: method.amount,
                                  title:
                                      '${method.percentage.toStringAsFixed(0)}%',
                                  radius: 50.r,
                                  titleStyle: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(width: 24.w),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              state.paymentMethods.asMap().entries.map((entry) {
                            final index = entry.key;
                            final method = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12.w,
                                    height: 12.h,
                                    decoration: BoxDecoration(
                                      color: _getPaymentMethodColor(index),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _getPaymentMethodName(method.method),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCompactNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toInt().toString();
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }

  Color _getPaymentMethodColor(int index) {
    final colors = [
      AppColors.success,
      AppColors.info,
      AppColors.warning,
      AppColors.secondary,
    ];
    return colors[index % colors.length];
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة';
      case 'transfer':
        return 'تحويل';
      default:
        return method;
    }
  }
}

/// تبويب المبيعات
class _SalesTab extends ConsumerWidget {
  const _SalesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(reportsProvider);

    if (reportsState.isLoading) {
      return const LoadingView();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // إحصائيات المبيعات
          _buildSalesStats(context, reportsState),
          SizedBox(height: 24.h),

          // مقارنة الفترات
          _buildPeriodComparison(context, reportsState),
          SizedBox(height: 24.h),

          // المبيعات حسب الساعة
          _buildHourlySales(context, reportsState),
        ],
      ),
    );
  }

  Widget _buildSalesStats(BuildContext context, ReportsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إحصائيات المبيعات',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'إجمالي المبيعات',
                    value: '${state.totalSales.toStringAsFixed(0)} ر.س',
                    icon: Icons.attach_money,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _StatItem(
                    label: 'عدد الفواتير',
                    value: '${state.invoicesCount}',
                    icon: Icons.receipt,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'متوسط الفاتورة',
                    value: '${state.averageInvoice.toStringAsFixed(0)} ر.س',
                    icon: Icons.calculate,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _StatItem(
                    label: 'الفواتير الملغاة',
                    value: '${state.cancelledCount}',
                    icon: Icons.cancel,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodComparison(BuildContext context, ReportsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مقارنة بالفترة السابقة',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text('الفترة الحالية',
                            style: Theme.of(context).textTheme.bodySmall),
                        SizedBox(height: 8.h),
                        Text(
                          '${state.totalSales.toStringAsFixed(0)} ر.س',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text('الفترة السابقة',
                            style: Theme.of(context).textTheme.bodySmall),
                        SizedBox(height: 8.h),
                        Text(
                          '${state.previousPeriodSales.toStringAsFixed(0)} ر.س',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: state.salesGrowth >= 0
                    ? AppColors.successLight
                    : AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state.salesGrowth >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: state.salesGrowth >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${state.salesGrowth >= 0 ? '+' : ''}${state.salesGrowth.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: state.salesGrowth >= 0
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlySales(BuildContext context, ReportsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المبيعات حسب الساعة',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 24.h),
            SizedBox(
              height: 200.h,
              child: state.hourlySales.isEmpty
                  ? const Center(child: Text('لا توجد بيانات'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 4,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}:00',
                                  style: Theme.of(context).textTheme.labelSmall,
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: state.hourlySales.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value);
                            }).toList(),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// تبويب المنتجات
class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(reportsProvider);

    if (reportsState.isLoading) {
      return const LoadingView();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الأكثر مبيعاً
          _buildTopProductsList(
              context, reportsState, 'الأكثر مبيعاً', reportsState.topProducts),
          SizedBox(height: 24.h),

          // الأقل مبيعاً
          _buildTopProductsList(
              context, reportsState, 'الأقل مبيعاً', reportsState.lowProducts),
          SizedBox(height: 24.h),

          // المخزون المنخفض
          _buildLowStockList(context, reportsState),
        ],
      ),
    );
  }

  Widget _buildTopProductsList(BuildContext context, ReportsState state,
      String title, List<ProductSalesData> products) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16.h),
            if (products.isEmpty)
              const Center(child: Text('لا توجد بيانات'))
            else
              ...products.take(5).map((product) => ListTile(
                    title: Text(product.name),
                    subtitle: Text('${product.quantity.toInt()} وحدة'),
                    trailing: PriceText(price: product.sales),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockList(BuildContext context, ReportsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.warning),
                SizedBox(width: 8.w),
                Text('المخزون المنخفض',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 16.h),
            if (state.lowStockProducts.isEmpty)
              const Center(child: Text('لا توجد منتجات بمخزون منخفض'))
            else
              ...state.lowStockProducts.take(5).map((product) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: product.stock <= 0
                          ? AppColors.errorLight
                          : AppColors.warningLight,
                      child: Icon(
                        Icons.inventory,
                        color: product.stock <= 0
                            ? AppColors.error
                            : AppColors.warning,
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                        'المخزون: ${product.stock.toInt()} | الحد الأدنى: ${product.minStock.toInt()}'),
                  )),
          ],
        ),
      ),
    );
  }
}

/// تبويب المالية
class _FinancialTab extends ConsumerWidget {
  const _FinancialTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(reportsProvider);

    if (reportsState.isLoading) {
      return const LoadingView();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ملخص مالي
          _buildFinancialSummary(context, reportsState),
          SizedBox(height: 24.h),

          // الإيرادات والمصروفات
          _buildRevenueExpenses(context, reportsState),
          SizedBox(height: 24.h),

          // حركة الصندوق
          _buildCashFlow(context, reportsState),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context, ReportsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الملخص المالي',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16.h),
            _FinancialRow(
                label: 'إجمالي المبيعات',
                value: state.totalSales,
                isPositive: true),
            _FinancialRow(
                label: 'تكلفة المبيعات',
                value: state.totalCost,
                isPositive: false),
            Divider(height: 24.h),
            _FinancialRow(
                label: 'إجمالي الربح',
                value: state.grossProfit,
                isPositive: true),
            _FinancialRow(
                label: 'المصروفات', value: state.expenses, isPositive: false),
            Divider(height: 24.h),
            _FinancialRow(
              label: 'صافي الربح',
              value: state.netProfit,
              isPositive: state.netProfit >= 0,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueExpenses(BuildContext context, ReportsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإيرادات مقابل المصروفات',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('الإيرادات',
                          style: Theme.of(context).textTheme.bodySmall),
                      SizedBox(height: 8.h),
                      Text(
                        '${state.totalSales.toStringAsFixed(0)} ر.س',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 60.h,
                  color: AppColors.border,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('المصروفات',
                          style: Theme.of(context).textTheme.bodySmall),
                      SizedBox(height: 8.h),
                      Text(
                        '${state.expenses.toStringAsFixed(0)} ر.س',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlow(BuildContext context, ReportsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('حركة الصندوق',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16.h),
            if (state.cashTransactions.isEmpty)
              const Center(child: Text('لا توجد حركات'))
            else
              ...state.cashTransactions.take(10).map((tx) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tx.isIncome
                          ? AppColors.successLight
                          : AppColors.errorLight,
                      child: Icon(
                        tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color:
                            tx.isIncome ? AppColors.success : AppColors.error,
                      ),
                    ),
                    title: Text(tx.description),
                    subtitle: Text(tx.date),
                    trailing: Text(
                      '${tx.isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        color:
                            tx.isIncome ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

/// عنصر إحصائية
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// صف مالي
class _FinancialRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isPositive;
  final bool isTotal;

  const _FinancialRow({
    required this.label,
    required this.value,
    required this.isPositive,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${isPositive ? '' : '-'}${value.abs().toStringAsFixed(0)} ر.س',
            style: (isTotal
                    ? Theme.of(context).textTheme.titleMedium
                    : Theme.of(context).textTheme.bodyMedium)
                ?.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
              fontWeight: isTotal ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
