import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/inventory_provider.dart';

/// شاشة جرد المخزون
class StockCountScreen extends ConsumerStatefulWidget {
  const StockCountScreen({super.key});

  @override
  ConsumerState<StockCountScreen> createState() => _StockCountScreenState();
}

class _StockCountScreenState extends ConsumerState<StockCountScreen> {
  final _searchController = TextEditingController();
  final Map<int, int> _countedQuantities = {};
  bool _showOnlyDifferences = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جرد المخزون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCount,
            tooltip: 'حفظ الجرد',
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والفلاتر
          Container(
            padding: EdgeInsets.all(16.w),
            color: AppColors.surface,
            child: Column(
              children: [
                AppTextField(
                  controller: _searchController,
                  hint: 'البحث عن منتج...',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    ref.read(inventoryProvider.notifier).setSearchQuery(value);
                  },
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('عرض الفروقات فقط'),
                      selected: _showOnlyDifferences,
                      onSelected: (value) {
                        setState(() => _showOnlyDifferences = value);
                      },
                    ),
                    const Spacer(),
                    Text(
                      'تم جرد: ${_countedQuantities.length} منتج',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // تعليمات
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: AppColors.info.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'أدخل الكمية الفعلية لكل منتج. سيتم حساب الفرق تلقائياً.',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // قائمة المنتجات
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.products.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد منتجات',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _getFilteredProducts(state).length,
                        itemBuilder: (context, index) {
                          final product = _getFilteredProducts(state)[index];
                          return _StockCountCard(
                            product: product,
                            countedQuantity: _countedQuantities[product.id],
                            onQuantityChanged: (qty) {
                              setState(() {
                                if (qty != null) {
                                  _countedQuantities[product.id] = qty;
                                } else {
                                  _countedQuantities.remove(product.id);
                                }
                              });
                            },
                          );
                        },
                      ),
          ),

          // ملخص
          if (_countedQuantities.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي المنتجات المجرودة'),
                      Text(
                        '${_countedQuantities.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('منتجات بها فروقات'),
                      Text(
                        '${_getDifferencesCount(state)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getDifferencesCount(state) > 0
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  AppButton(
                    text: 'حفظ الجرد',
                    onPressed: _saveCount,
                    isFullWidth: true,
                    icon: Icons.save,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<InventoryProduct> _getFilteredProducts(InventoryState state) {
    var products = state.filteredProducts;

    if (_showOnlyDifferences) {
      products = products.where((p) {
        final counted = _countedQuantities[p.id];
        return counted != null && counted != p.currentStock.toInt();
      }).toList();
    }

    return products;
  }

  int _getDifferencesCount(InventoryState state) {
    return _countedQuantities.entries.where((e) {
      final product = state.products.firstWhere(
        (p) => p.id == e.key,
        orElse: () =>
            InventoryProduct(id: 0, name: '', currentStock: 0, minStock: 0),
      );
      return e.value != product.currentStock.toInt();
    }).length;
  }

  void _saveCount() {
    if (_countedQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم جرد أي منتج')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حفظ الجرد'),
        content: Text(
          'سيتم تعديل المخزون لـ ${_countedQuantities.length} منتج.\n'
          'هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // حفظ كل تعديل
              for (final entry in _countedQuantities.entries) {
                await ref.read(inventoryProvider.notifier).adjustStock(
                      productId: entry.key,
                      type: AdjustmentType.set,
                      quantity: entry.value.toDouble(),
                      note: 'جرد المخزون',
                    );
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حفظ الجرد بنجاح'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.pop();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

/// بطاقة جرد منتج
class _StockCountCard extends StatefulWidget {
  final InventoryProduct product;
  final int? countedQuantity;
  final Function(int?) onQuantityChanged;

  const _StockCountCard({
    required this.product,
    required this.countedQuantity,
    required this.onQuantityChanged,
  });

  @override
  State<_StockCountCard> createState() => _StockCountCardState();
}

class _StockCountCardState extends State<_StockCountCard> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.countedQuantity != null) {
      _controller.text = widget.countedQuantity.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? get _difference {
    if (widget.countedQuantity == null) return null;
    return widget.countedQuantity! - widget.product.currentStock.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // معلومات المنتج
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'الكمية الحالية: ${widget.product.currentStock.toInt()}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  if (_difference != null) ...[
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _difference == 0
                            ? AppColors.success.withOpacity(0.1)
                            : _difference! > 0
                                ? AppColors.info.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        _difference == 0
                            ? 'لا يوجد فرق ✓'
                            : 'الفرق: ${_difference! > 0 ? '+' : ''}$_difference',
                        style: TextStyle(
                          color: _difference == 0
                              ? AppColors.success
                              : _difference! > 0
                                  ? AppColors.info
                                  : AppColors.error,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // حقل الكمية
            Expanded(
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onChanged: (value) {
                  final qty = int.tryParse(value);
                  widget.onQuantityChanged(qty);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
