// lib/features/products/screens/product_details_screen.dart
// شاشة تفاصيل المنتج

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../models/product_model.dart';
import 'add_edit_product_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'ar');

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditProductScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة
            AspectRatio(
              aspectRatio: 1.2,
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppTheme.grey200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الاسم والعلامة التجارية
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.brand.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.brand,
                      style: TextStyle(fontSize: 16, color: AppTheme.grey600),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // الفئة
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الأسعار
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'سعر البيع',
                                  style: TextStyle(color: AppTheme.grey600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${formatter.format(product.price)} ر.س',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.successColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.grey300,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'التكلفة',
                                  style: TextStyle(color: AppTheme.grey600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${formatter.format(product.costPrice)} ر.س',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.grey300,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'الربح',
                                  style: TextStyle(color: AppTheme.grey600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${formatter.format(product.profitMargin)} ر.س',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الوصف
                  if (product.description.isNotEmpty) ...[
                    Text(
                      'الوصف',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(product.description),
                    const SizedBox(height: 16),
                  ],

                  // الألوان
                  Text(
                    'الألوان المتاحة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: product.colors
                        .map((color) => Chip(label: Text(color)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // المقاسات
                  Text(
                    'المقاسات المتاحة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: product.sizes
                        .map((size) => Chip(label: Text('$size')))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // المخزون
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المخزون',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStockColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'إجمالي: ${product.totalQuantity} قطعة',
                          style: TextStyle(
                            color: _getStockColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // جدول المخزون
                  Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          const DataColumn(label: Text('اللون')),
                          ...product.sizes.map(
                            (size) =>
                                DataColumn(label: Text('$size'), numeric: true),
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
                                      color: qty == 0
                                          ? AppTheme.errorColor
                                          : qty <= 5
                                          ? AppTheme.warningColor
                                          : null,
                                      fontWeight: qty <= 5
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        }).toList(),
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

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.grey200,
      child: Icon(Icons.image, size: 64, color: AppTheme.grey400),
    );
  }

  Color _getStockColor() {
    if (product.isOutOfStock) return AppTheme.errorColor;
    if (product.isLowStock()) return AppTheme.warningColor;
    return AppTheme.successColor;
  }
}
