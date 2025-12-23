// lib/features/reports/screens/reports_screen.dart
// شاشة التقارير

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../products/providers/product_provider.dart';
import '../../sales/providers/sale_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // اختيار الفترة
          _buildDateRangeSelector(),

          // التبويبات
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'المبيعات'),
              Tab(text: 'المنتجات'),
              Tab(text: 'المخزون'),
            ],
          ),

          // المحتوى
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSalesReport(),
                _buildProductsReport(),
                _buildInventoryReport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey200,
        border: Border(bottom: BorderSide(color: AppTheme.grey300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(true),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.grey300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(dateFormat.format(_startDate)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward, color: AppTheme.grey600),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(false),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.grey300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(dateFormat.format(_endDate)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildSalesReport() {
    return Consumer<SaleProvider>(
      builder: (context, provider, _) {
        final sales = provider.allSales.where((sale) {
          return sale.saleDate.isAfter(
                _startDate.subtract(const Duration(days: 1)),
              ) &&
              sale.saleDate.isBefore(_endDate.add(const Duration(days: 1)));
        }).toList();

        final totalRevenue = sales.fold<double>(
          0,
          (sum, sale) => sum + sale.total,
        );

        final completedSales = sales.where((s) => s.status == 'مكتمل').toList();
        final cancelledSales = sales.where((s) => s.status == 'ملغي').toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقات الإحصائيات
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'إجمالي المبيعات',
                      value: '${totalRevenue.toStringAsFixed(2)} ر.س',
                      icon: Icons.attach_money,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'عدد الفواتير',
                      value: '${sales.length}',
                      icon: Icons.receipt,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'مكتملة',
                      value: '${completedSales.length}',
                      icon: Icons.check_circle,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'ملغية',
                      value: '${cancelledSales.length}',
                      icon: Icons.cancel,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // قائمة المبيعات
              Text(
                'تفاصيل المبيعات',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (sales.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: AppTheme.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد مبيعات في هذه الفترة',
                          style: TextStyle(color: AppTheme.grey600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(
                            sale.status,
                          ).withOpacity(0.1),
                          child: Icon(
                            Icons.receipt,
                            color: _getStatusColor(sale.status),
                          ),
                        ),
                        title: Text(sale.invoiceNumber),
                        subtitle: Text(
                          DateFormat(
                            'dd/MM/yyyy - hh:mm a',
                          ).format(sale.saleDate),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${sale.total.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              sale.status,
                              style: TextStyle(
                                color: _getStatusColor(sale.status),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsReport() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final products = provider.allProducts;

        // أكثر المنتجات مخزوناً
        final sortedByStock = List.of(products)
          ..sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // إحصائيات
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'إجمالي المنتجات',
                      value: '${products.length}',
                      icon: Icons.inventory_2,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'الفئات',
                      value: '${provider.categories.length}',
                      icon: Icons.category,
                      color: AppTheme.infoColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // المنتجات حسب الفئة
              Text(
                'المنتجات حسب الفئة',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...provider.categories.map((category) {
                final categoryProducts = products
                    .where((p) => p.category == category.name)
                    .toList();
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.category,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(category.name),
                    trailing: Text(
                      '${categoryProducts.length} منتج',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // أعلى المنتجات مخزوناً
              Text(
                'أعلى المنتجات مخزوناً',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedByStock.take(10).length,
                itemBuilder: (context, index) {
                  final product = sortedByStock[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(product.name),
                      subtitle: Text(product.category),
                      trailing: Text(
                        '${product.totalQuantity} قطعة',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryReport() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final lowStock = provider.lowStockProducts;
        final outOfStock = provider.outOfStockProducts;
        final totalQuantity = provider.allProducts.fold<int>(
          0,
          (sum, p) => sum + p.totalQuantity,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // إحصائيات المخزون
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'إجمالي المخزون',
                      value: '$totalQuantity قطعة',
                      icon: Icons.inventory,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'منتجات منخفضة',
                      value: '${lowStock.length}',
                      icon: Icons.warning,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                title: 'نفذ المخزون',
                value: '${outOfStock.length}',
                icon: Icons.error,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 24),

              // المنتجات النافذة
              if (outOfStock.isNotEmpty) ...[
                Text(
                  'منتجات نفذت من المخزون',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: outOfStock.length,
                  itemBuilder: (context, index) {
                    final product = outOfStock[index];
                    return Card(
                      color: AppTheme.errorColor.withOpacity(0.05),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.error,
                            color: AppTheme.errorColor,
                          ),
                        ),
                        title: Text(product.name),
                        subtitle: Text(product.category),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'نفذ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              // المنتجات منخفضة المخزون
              if (lowStock.isNotEmpty) ...[
                Text(
                  'منتجات منخفضة المخزون',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lowStock.length,
                  itemBuilder: (context, index) {
                    final product = lowStock[index];
                    return Card(
                      color: AppTheme.warningColor.withOpacity(0.05),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.warningColor.withOpacity(
                            0.1,
                          ),
                          child: const Icon(
                            Icons.warning,
                            color: AppTheme.warningColor,
                          ),
                        ),
                        title: Text(product.name),
                        subtitle: Text(product.category),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${product.totalQuantity} قطعة',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: AppTheme.grey600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return AppTheme.successColor;
      case 'ملغي':
        return AppTheme.errorColor;
      default:
        return AppTheme.grey600;
    }
  }
}
