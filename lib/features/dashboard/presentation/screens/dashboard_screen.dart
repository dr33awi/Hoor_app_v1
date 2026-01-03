import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/pos_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

/// شاشة لوحة التحكم
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحباً ${user?.name ?? ""}'),
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
        actions: [
          // حالة المزامنة
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
            tooltip: 'تحديث',
          ),
          // الإشعارات
          IconButton(
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              // TODO: عرض الإشعارات
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: dashboardState.isLoading
            ? const LoadingView(message: 'جاري تحميل البيانات...')
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بطاقات الإحصائيات السريعة
                    _buildQuickStats(context, ref, dashboardState),
                    SizedBox(height: 24.h),

                    // تنبيهات المخزون
                    if (dashboardState.lowStockCount > 0)
                      _buildLowStockAlert(
                          context, dashboardState.lowStockCount),

                    SizedBox(height: 24.h),

                    // رسم بياني للمبيعات
                    _buildSalesChart(context, dashboardState),

                    SizedBox(height: 24.h),

                    // الاختصارات السريعة
                    _buildQuickActions(context),

                    SizedBox(height: 24.h),

                    // آخر الفواتير
                    _buildRecentInvoices(context, ref, dashboardState),

                    SizedBox(height: 24.h),

                    // المنتجات الأكثر مبيعاً
                    _buildTopProducts(context, dashboardState),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
      ),

      // زر البيع السريع
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.pos),
        icon: const Icon(Icons.point_of_sale),
        label: const Text('بيع سريع'),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }

  Widget _buildQuickStats(
      BuildContext context, WidgetRef ref, DashboardState state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'مبيعات اليوم',
          value: _formatPrice(state.todaySales),
          icon: Icons.trending_up,
          color: AppColors.success,
          onTap: () => context.go(AppRoutes.reports),
        ),
        StatCard(
          title: 'عدد الفواتير',
          value: state.todayInvoicesCount.toString(),
          icon: Icons.receipt_long,
          color: AppColors.info,
          onTap: () => context.go(AppRoutes.invoices),
        ),
        StatCard(
          title: 'المنتجات',
          value: state.productsCount.toString(),
          icon: Icons.inventory_2,
          color: AppColors.secondary,
          onTap: () => context.go(AppRoutes.products),
        ),
        StatCard(
          title: 'العملاء',
          value: state.customersCount.toString(),
          icon: Icons.people,
          color: AppColors.warning,
          onTap: () => context.go(AppRoutes.customers),
        ),
      ],
    );
  }

  Widget _buildLowStockAlert(BuildContext context, int count) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.warning_amber,
              color: AppColors.warning,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنبيه المخزون',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$count منتج بحاجة لإعادة التوريد',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.inventory),
            child: const Text('عرض'),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart(BuildContext context, DashboardState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المبيعات (آخر 7 أيام)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up,
                          size: 16.sp, color: AppColors.success),
                      SizedBox(width: 4.w),
                      Text(
                        '+${state.salesGrowth.toStringAsFixed(1)}%',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 200.h,
              child: state.weeklySales.isEmpty
                  ? const Center(child: Text('لا توجد بيانات'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: AppColors.border,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const days = [
                                  'س',
                                  'أ',
                                  'إ',
                                  'ث',
                                  'أ',
                                  'خ',
                                  'ج'
                                ];
                                if (value.toInt() >= 0 &&
                                    value.toInt() < days.length) {
                                  return Text(
                                    days[value.toInt()],
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _formatCompactPrice(value),
                                  style: Theme.of(context).textTheme.labelSmall,
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: state.weeklySales.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value);
                            }).toList(),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
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

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختصارات سريعة',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickActionButton(
                icon: Icons.add_shopping_cart,
                label: 'فاتورة جديدة',
                color: AppColors.primary,
                onTap: () => context.go(AppRoutes.pos),
              ),
              SizedBox(width: 12.w),
              _QuickActionButton(
                icon: Icons.add_box,
                label: 'منتج جديد',
                color: AppColors.success,
                onTap: () => context.go('${AppRoutes.products}/form'),
              ),
              SizedBox(width: 12.w),
              _QuickActionButton(
                icon: Icons.person_add,
                label: 'عميل جديد',
                color: AppColors.info,
                onTap: () => context.go('${AppRoutes.customers}/form'),
              ),
              SizedBox(width: 12.w),
              _QuickActionButton(
                icon: Icons.inventory,
                label: 'جرد المخزون',
                color: AppColors.warning,
                onTap: () => context.go('${AppRoutes.inventory}/count'),
              ),
              SizedBox(width: 12.w),
              _QuickActionButton(
                icon: Icons.bar_chart,
                label: 'التقارير',
                color: AppColors.secondary,
                onTap: () => context.go(AppRoutes.reports),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentInvoices(
      BuildContext context, WidgetRef ref, DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آخر الفواتير',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.invoices),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (state.recentInvoices.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: const Center(
                child: Text('لا توجد فواتير اليوم'),
              ),
            ),
          )
        else
          ...state.recentInvoices.take(5).map((invoice) => Card(
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getInvoiceStatusColor(invoice.status)
                        .withValues(alpha: 0.1),
                    child: Icon(
                      Icons.receipt,
                      color: _getInvoiceStatusColor(invoice.status),
                    ),
                  ),
                  title: Text(invoice.number),
                  subtitle: Text(invoice.customerName ?? 'عميل نقدي'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PriceText(price: invoice.total, compact: true),
                      Text(
                        _formatTime(invoice.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  onTap: () =>
                      context.go('${AppRoutes.invoices}/details/${invoice.id}'),
                ),
              )),
      ],
    );
  }

  Widget _buildTopProducts(BuildContext context, DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الأكثر مبيعاً',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.reports),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (state.topProducts.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: const Center(
                child: Text('لا توجد مبيعات'),
              ),
            ),
          )
        else
          ...state.topProducts.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(index).withValues(alpha: 0.1),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: _getRankColor(index),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(product.name),
                subtitle: Text('${product.soldQuantity.toInt()} مبيعات'),
                trailing: PriceText(price: product.totalSales, compact: true),
              ),
            );
          }),
      ],
    );
  }

  Color _getInvoiceStatusColor(String status) {
    switch (status) {
      case 'closed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // ذهبي
      case 1:
        return const Color(0xFFC0C0C0); // فضي
      case 2:
        return const Color(0xFFCD7F32); // برونزي
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    }
    return price.toInt().toString();
  }

  String _formatCompactPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toInt().toString();
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// زر اختصار سريع
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
