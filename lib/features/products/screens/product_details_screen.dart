// lib/features/products/screens/product_details_screen.dart
// شاشة تفاصيل المنتج - بدون صور

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import 'add_edit_product_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditProductScreen(product: product),
                ),
              );
            },
            tooltip: 'تعديل',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context),
            tooltip: 'حذف',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج (placeholder)
            Container(
              height: 250,
              width: double.infinity,
              color: AppTheme.grey200,
              child: Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: AppTheme.grey400,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الاسم والعلامة التجارية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (product.brand.isNotEmpty)
                              Text(
                                product.brand,
                                style: TextStyle(
                                  color: AppTheme.grey600,
                                  fontSize: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _buildStockBadge(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // السعر
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ربح ${product.profitMargin.toStringAsFixed(2)} ر.س',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سعر التكلفة: ${product.costPrice.toStringAsFixed(2)} ر.س',
                    style: TextStyle(color: AppTheme.grey600),
                  ),
                  const SizedBox(height: 24),

                  // الفئة
                  _buildInfoRow(
                    icon: Icons.category,
                    label: 'الفئة',
                    value: product.category,
                  ),
                  const SizedBox(height: 16),

                  // الوصف
                  if (product.description.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: Icons.description,
                      label: 'الوصف',
                      value: product.description,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // الألوان
                  Text(
                    'الألوان المتوفرة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.colors
                        .map((color) => Chip(label: Text(color)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // المقاسات
                  Text(
                    'المقاسات المتوفرة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.sizes
                        .map((size) => Chip(label: Text('$size')))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // جدول المخزون
                  Text(
                    'المخزون',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInventoryTable(),
                  const SizedBox(height: 24),

                  // معلومات إضافية
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'إجمالي المخزون',
                            '${product.totalQuantity} قطعة',
                          ),
                          const Divider(),
                          _buildDetailRow(
                            'نسبة الربح',
                            '${product.profitPercentage.toStringAsFixed(1)}%',
                          ),
                          const Divider(),
                          _buildDetailRow(
                            'تاريخ الإضافة',
                            DateFormat('dd/MM/yyyy').format(product.createdAt),
                          ),
                          if (product.updatedAt != null) ...[
                            const Divider(),
                            _buildDetailRow(
                              'آخر تحديث',
                              DateFormat(
                                'dd/MM/yyyy',
                              ).format(product.updatedAt!),
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildStockBadge() {
    Color color;
    String text;
    IconData icon;

    if (product.isOutOfStock) {
      color = AppTheme.errorColor;
      text = 'نفذ المخزون';
      icon = Icons.error_outline;
    } else if (product.isLowStock) {
      color = AppTheme.warningColor;
      text = 'مخزون منخفض';
      icon = Icons.warning_amber;
    } else {
      color = AppTheme.successColor;
      text = 'متوفر';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.grey600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: AppTheme.grey600, fontSize: 12),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryTable() {
    if (product.colors.isEmpty || product.sizes.isEmpty) {
      return const Text('لا توجد بيانات مخزون');
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.grey200),
          columns: [
            const DataColumn(label: Text('اللون')),
            ...product.sizes.map(
              (size) => DataColumn(label: Text('$size'), numeric: true),
            ),
          ],
          rows: product.colors.map((color) {
            return DataRow(
              cells: [
                DataCell(Text(color)),
                ...product.sizes.map((size) {
                  final qty = product.getQuantity(color, size);
                  return DataCell(
                    Text(
                      '$qty',
                      style: TextStyle(
                        color: _getStockColor(qty),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStockColor(int quantity) {
    if (quantity == 0) return AppTheme.errorColor;
    if (quantity <= 5) return AppTheme.warningColor;
    return AppTheme.textPrimary;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.grey600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final provider = context.read<ProductProvider>();
              final success = await provider.deleteProduct(product.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف المنتج'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
