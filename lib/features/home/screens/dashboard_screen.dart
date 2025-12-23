// lib/features/home/screens/dashboard_screen.dart
// شاشة لوحة التحكم - تصميم حديث

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../products/providers/product_provider.dart';
import '../../sales/providers/sale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final productProvider = context.read<ProductProvider>();
    final saleProvider = context.read<SaleProvider>();
    await Future.wait([productProvider.loadAll(), saleProvider.loadSales()]);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 24),
            _buildStatsCards(),
            const SizedBox(height: 28),
            _buildLowStockSection(),
            const SizedBox(height: 28),
            _buildRecentSalesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'صباح الخير';
    } else if (hour < 18) {
      greeting = 'مساء الخير';
    } else {
      greeting = 'مساء الخير';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          'نظرة عامة على المبيعات',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Consumer2<SaleProvider, ProductProvider>(
      builder: (context, saleProvider, productProvider, _) {
        final formatter = NumberFormat('#,##0.00', 'ar');

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'مبيعات اليوم',
                    value: '${formatter.format(saleProvider.todayTotal)} ر.س',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'فواتير اليوم',
                    value: '${saleProvider.todayOrdersCount}',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'المنتجات',
                    value:
                        '${productProvider.allProducts.where((p) => p.isActive).length}',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'منخفض المخزون',
                    value: '${productProvider.lowStockProducts.length}',
                    icon: Icons.warning_rounded,
                    color: productProvider.lowStockProducts.isEmpty
                        ? Colors.grey.shade400
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLowStockSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final lowStock = provider.lowStockProducts;
        if (lowStock.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'منتجات منخفضة المخزون',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${lowStock.length}',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lowStock.take(5).length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final product = lowStock[index];
                  return Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                product.brand,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: product.isOutOfStock
                                ? AppColors.errorLight
                                : AppColors.warningLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.isOutOfStock
                                ? 'نفذ'
                                : '${product.totalQuantity}',
                            style: TextStyle(
                              color: product.isOutOfStock
                                  ? AppColors.error
                                  : AppColors.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentSalesSection() {
    return Consumer<SaleProvider>(
      builder: (context, provider, _) {
        final recentSales = provider.allSales.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.purpleLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColors.purple,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'آخر الفواتير',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: recentSales.isEmpty
                  ? EmptyState.sales()
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentSales.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (context, index) {
                        final sale = recentSales[index];
                        final formatter = NumberFormat('#,##0.00', 'ar');
                        final dateFormatter = DateFormat(
                          'dd/MM - hh:mm a',
                          'ar',
                        );

                        return Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    sale.status,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.receipt_outlined,
                                  color: _getStatusColor(sale.status),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sale.invoiceNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      dateFormatter.format(sale.saleDate),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${formatter.format(sale.total)} ر.س',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    sale.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getStatusColor(sale.status),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return AppColors.success;
      case 'ملغي':
        return AppColors.error;
      case 'معلق':
        return AppColors.warning;
      default:
        return Colors.grey.shade500;
    }
  }
}
