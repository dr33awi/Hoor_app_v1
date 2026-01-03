import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/inventory_provider.dart';

/// شاشة إدارة المخزون
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryProvider.notifier).loadInventory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المخزون'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المخزون'),
            Tab(text: 'الحركات'),
            Tab(text: 'التنبيهات'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdjustmentDialog(context),
        icon: const Icon(Icons.tune),
        label: const Text('تعديل المخزون'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // المخزون
                _InventoryTab(
                  items: state.filteredProducts,
                  searchController: _searchController,
                  onSearch: (query) {
                    ref.read(inventoryProvider.notifier).setSearchQuery(query);
                  },
                  onAdjust: (product) => _showAdjustmentDialog(
                    context,
                    product: product,
                  ),
                ),
                // الحركات
                _MovementsTab(
                  movements: state.movements,
                ),
                // التنبيهات
                _AlertsTab(
                  lowStockItems: state.lowStockProducts,
                  outOfStockItems: state.outOfStockProducts,
                  onAdjust: (product) => _showAdjustmentDialog(
                    context,
                    product: product,
                  ),
                ),
              ],
            ),
    );
  }

  void _showFilters(BuildContext context) {
    final state = ref.read(inventoryProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تصفية المخزون',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(inventoryProvider.notifier).clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('مسح الكل'),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.all(16.w),
                children: [
                  // حالة المخزون
                  Text(
                    'حالة المخزون',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    children: [
                      FilterChip(
                        label: const Text('الكل'),
                        selected: state.stockFilter == StockFilter.all,
                        onSelected: (_) {
                          ref.read(inventoryProvider.notifier).setStockFilter(
                                StockFilter.all,
                              );
                        },
                      ),
                      FilterChip(
                        label: const Text('منخفض'),
                        selected: state.stockFilter == StockFilter.low,
                        onSelected: (_) {
                          ref.read(inventoryProvider.notifier).setStockFilter(
                                StockFilter.low,
                              );
                        },
                      ),
                      FilterChip(
                        label: const Text('نفد'),
                        selected: state.stockFilter == StockFilter.outOfStock,
                        onSelected: (_) {
                          ref.read(inventoryProvider.notifier).setStockFilter(
                                StockFilter.outOfStock,
                              );
                        },
                      ),
                      FilterChip(
                        label: const Text('متوفر'),
                        selected: state.stockFilter == StockFilter.available,
                        onSelected: (_) {
                          ref.read(inventoryProvider.notifier).setStockFilter(
                                StockFilter.available,
                              );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // الفئة
                  Text(
                    'الفئة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      FilterChip(
                        label: const Text('الكل'),
                        selected: state.selectedCategoryId == null,
                        onSelected: (_) {
                          ref
                              .read(inventoryProvider.notifier)
                              .setCategoryFilter(null);
                        },
                      ),
                      ...state.categories.map((category) => FilterChip(
                            label: Text(category.name),
                            selected: state.selectedCategoryId == category.id,
                            onSelected: (_) {
                              ref
                                  .read(inventoryProvider.notifier)
                                  .setCategoryFilter(
                                    category.id,
                                  );
                            },
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: AppButton(
                text: 'تطبيق',
                onPressed: () => Navigator.pop(context),
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustmentDialog(BuildContext context,
      {InventoryProduct? product}) {
    final productController = TextEditingController(text: product?.name ?? '');
    final quantityController = TextEditingController();
    final noteController = TextEditingController();
    AdjustmentType adjustmentType = AdjustmentType.add;
    InventoryProduct? selectedProduct = product;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل المخزون'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اختيار المنتج
                if (product == null)
                  Autocomplete<InventoryProduct>(
                    displayStringForOption: (p) => p.name,
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return ref.read(inventoryProvider).products;
                      }
                      return ref.read(inventoryProvider).products.where((p) {
                        return p.name.contains(textEditingValue.text) ||
                            (p.barcode?.contains(textEditingValue.text) ??
                                false);
                      });
                    },
                    onSelected: (p) => setState(() => selectedProduct = p),
                    fieldViewBuilder:
                        (context, controller, focusNode, onSubmitted) {
                      return AppTextField(
                        controller: controller,
                        focusNode: focusNode,
                        label: 'المنتج',
                        hint: 'ابحث عن المنتج',
                        prefixIcon: Icons.search,
                      );
                    },
                  )
                else
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2, color: AppColors.primary),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'الكمية الحالية: ${product.currentStock.toInt()}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 16.h),

                // نوع التعديل
                Text(
                  'نوع التعديل',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<AdjustmentType>(
                        title: const Text('إضافة'),
                        value: AdjustmentType.add,
                        groupValue: adjustmentType,
                        onChanged: (v) => setState(() => adjustmentType = v!),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<AdjustmentType>(
                        title: const Text('خصم'),
                        value: AdjustmentType.subtract,
                        groupValue: adjustmentType,
                        onChanged: (v) => setState(() => adjustmentType = v!),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<AdjustmentType>(
                        title: const Text('تعيين'),
                        value: AdjustmentType.set,
                        groupValue: adjustmentType,
                        onChanged: (v) => setState(() => adjustmentType = v!),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<AdjustmentType>(
                        title: const Text('جرد'),
                        value: AdjustmentType.count,
                        groupValue: adjustmentType,
                        onChanged: (v) => setState(() => adjustmentType = v!),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // الكمية
                AppTextField(
                  controller: quantityController,
                  label: 'الكمية',
                  hint: 'أدخل الكمية',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.numbers,
                ),

                SizedBox(height: 16.h),

                // ملاحظة
                AppTextField(
                  controller: noteController,
                  label: 'ملاحظة',
                  hint: 'سبب التعديل (اختياري)',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                final targetProduct = selectedProduct ?? product;
                if (targetProduct == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى اختيار المنتج')),
                  );
                  return;
                }

                final quantity = double.tryParse(quantityController.text);
                if (quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إدخال كمية صحيحة')),
                  );
                  return;
                }

                ref.read(inventoryProvider.notifier).adjustStock(
                      productId: targetProduct.id,
                      quantity: quantity,
                      type: adjustmentType,
                      note: noteController.text.trim(),
                    );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تعديل المخزون بنجاح'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

/// تبويب المخزون
class _InventoryTab extends StatelessWidget {
  final List<InventoryProduct> items;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function(InventoryProduct) onAdjust;

  const _InventoryTab({
    required this.items,
    required this.searchController,
    required this.onSearch,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: AppTextField(
            controller: searchController,
            hint: 'البحث عن منتج...',
            prefixIcon: Icons.search,
            onChanged: onSearch,
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'لا توجد منتجات',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final product = items[index];
                    return _InventoryCard(
                      product: product,
                      onAdjust: () => onAdjust(product),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// بطاقة المخزون
class _InventoryCard extends StatelessWidget {
  final InventoryProduct product;
  final VoidCallback onAdjust;

  const _InventoryCard({
    required this.product,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final stockStatus = _getStockStatus();

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: stockStatus.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.inventory_2,
            color: stockStatus.color,
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.barcode != null)
              Text(
                product.barcode!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                ),
              ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: stockStatus.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    stockStatus.text,
                    style: TextStyle(
                      color: stockStatus.color,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'الحد الأدنى: ${product.minStock.toInt()}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.currentStock.toInt()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
                color: stockStatus.color,
              ),
            ),
            Text(
              'وحدة',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
        onTap: onAdjust,
      ),
    );
  }

  ({Color color, String text}) _getStockStatus() {
    if (product.currentStock <= 0) {
      return (color: AppColors.error, text: 'نفد');
    }
    if (product.currentStock <= product.minStock) {
      return (color: AppColors.warning, text: 'منخفض');
    }
    return (color: AppColors.success, text: 'متوفر');
  }
}

/// تبويب الحركات
class _MovementsTab extends StatelessWidget {
  final List<StockMovement> movements;

  const _MovementsTab({required this.movements});

  @override
  Widget build(BuildContext context) {
    if (movements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد حركات',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: movements.length,
      itemBuilder: (context, index) {
        final movement = movements[index];
        return _MovementCard(movement: movement);
      },
    );
  }
}

/// بطاقة حركة المخزون
class _MovementCard extends StatelessWidget {
  final StockMovement movement;

  const _MovementCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isPositive = movement.quantity > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: (isPositive ? AppColors.success : AppColors.error)
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPositive ? Icons.add : Icons.remove,
            color: isPositive ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text(
          movement.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movement.type,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
            if (movement.note != null && movement.note!.isNotEmpty)
              Text(
                movement.note!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                ),
              ),
            Text(
              DateFormat('yyyy/MM/dd - HH:mm').format(movement.date),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${isPositive ? '+' : ''}${movement.quantity.toInt()}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: isPositive ? AppColors.success : AppColors.error,
          ),
        ),
      ),
    );
  }
}

/// تبويب التنبيهات
class _AlertsTab extends StatelessWidget {
  final List<InventoryProduct> lowStockItems;
  final List<InventoryProduct> outOfStockItems;
  final Function(InventoryProduct) onAdjust;

  const _AlertsTab({
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    if (lowStockItems.isEmpty && outOfStockItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64.sp,
              color: AppColors.success,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد تنبيهات',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Text(
              'جميع المنتجات متوفرة بالمخزون',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // نفد المخزون
        if (outOfStockItems.isNotEmpty) ...[
          _SectionHeader(
            title: 'نفد المخزون',
            count: outOfStockItems.length,
            color: AppColors.error,
          ),
          SizedBox(height: 8.h),
          ...outOfStockItems.map((p) => _AlertCard(
                product: p,
                isOutOfStock: true,
                onAdjust: () => onAdjust(p),
              )),
          SizedBox(height: 24.h),
        ],

        // مخزون منخفض
        if (lowStockItems.isNotEmpty) ...[
          _SectionHeader(
            title: 'مخزون منخفض',
            count: lowStockItems.length,
            color: AppColors.warning,
          ),
          SizedBox(height: 8.h),
          ...lowStockItems.map((p) => _AlertCard(
                product: p,
                isOutOfStock: false,
                onAdjust: () => onAdjust(p),
              )),
        ],
      ],
    );
  }
}

/// رأس القسم
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.warning_amber, color: color, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }
}

/// بطاقة تنبيه
class _AlertCard extends StatelessWidget {
  final InventoryProduct product;
  final bool isOutOfStock;
  final VoidCallback onAdjust;

  const _AlertCard({
    required this.product,
    required this.isOutOfStock,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOutOfStock ? AppColors.error : AppColors.warning;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            isOutOfStock ? Icons.error : Icons.warning_amber,
            color: color,
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isOutOfStock
              ? 'نفد من المخزون'
              : 'الكمية المتبقية: ${product.currentStock.toInt()} من ${product.minStock.toInt()}',
          style: TextStyle(
            color: color,
            fontSize: 12.sp,
          ),
        ),
        trailing: AppButton(
          text: 'تعديل',
          onPressed: onAdjust,
          isSmall: true,
        ),
      ),
    );
  }
}
