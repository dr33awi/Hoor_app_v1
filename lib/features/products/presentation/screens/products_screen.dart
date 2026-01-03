import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/pos_widgets.dart';
import '../providers/products_provider.dart';

/// شاشة المنتجات
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        actions: [
          // تبديل العرض
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          // فلتر
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
          // المزيد
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'import', child: Text('استيراد المنتجات')),
              const PopupMenuItem(
                  value: 'export', child: Text('تصدير المنتجات')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                  value: 'print_barcodes', child: Text('طباعة الباركودات')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: EdgeInsets.all(16.w),
            child: AppTextField(
              controller: _searchController,
              hint: 'بحث بالاسم أو الباركود...',
              prefixIcon: Icons.search,
              suffixIcon:
                  _searchController.text.isNotEmpty ? Icons.clear : null,
              onSuffixTap: () {
                _searchController.clear();
                ref.read(productsProvider.notifier).clearSearch();
              },
              onChanged: (value) {
                ref.read(productsProvider.notifier).search(value);
              },
            ),
          ),

          // شريط الفئات
          _buildCategoriesBar(context, ref, productsState),

          // معلومات سريعة
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text(
                  '${productsState.filteredProducts.length} منتج',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                // ترتيب
                DropdownButton<String>(
                  value: productsState.sortBy,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('الاسم')),
                    DropdownMenuItem(value: 'price', child: Text('السعر')),
                    DropdownMenuItem(value: 'stock', child: Text('المخزون')),
                    DropdownMenuItem(value: 'created', child: Text('الأحدث')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(productsProvider.notifier).setSortBy(value);
                    }
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // قائمة المنتجات
          Expanded(
            child: _buildProductsList(context, ref, productsState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('${AppRoutes.products}/form'),
        icon: const Icon(Icons.add),
        label: const Text('منتج جديد'),
      ),
    );
  }

  Widget _buildCategoriesBar(
      BuildContext context, WidgetRef ref, ProductsState state) {
    return Container(
      height: 45.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: state.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: CategoryChip(
                name: 'الكل',
                isSelected: state.selectedCategoryId == null,
                onTap: () =>
                    ref.read(productsProvider.notifier).selectCategory(null),
              ),
            );
          }

          final category = state.categories[index - 1];
          return Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: CategoryChip(
              name: category.name,
              isSelected: state.selectedCategoryId == category.id,
              onTap: () => ref
                  .read(productsProvider.notifier)
                  .selectCategory(category.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsList(
      BuildContext context, WidgetRef ref, ProductsState state) {
    if (state.isLoading) {
      return const LoadingView(message: 'جاري تحميل المنتجات...');
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(productsProvider.notifier).refresh(),
      );
    }

    if (state.filteredProducts.isEmpty) {
      return EmptyView(
        icon: Icons.inventory_2_outlined,
        message: state.searchQuery.isNotEmpty
            ? 'لا توجد نتائج للبحث'
            : 'لا توجد منتجات',
        actionLabel: 'إضافة منتج',
        onAction: () => context.push('${AppRoutes.products}/form'),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: state.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = state.filteredProducts[index];
          return _ProductGridItem(
            product: product,
            onTap: () =>
                context.push('${AppRoutes.products}/details/${product.id}'),
            onEdit: () =>
                context.push('${AppRoutes.products}/form/${product.id}'),
          );
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: state.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];
        return _ProductListItem(
          product: product,
          onTap: () =>
              context.push('${AppRoutes.products}/details/${product.id}'),
          onEdit: () =>
              context.push('${AppRoutes.products}/form/${product.id}'),
          onDelete: () => _deleteProduct(context, ref, product),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ProductFilterSheet(
        onApply: (filters) {
          ref.read(productsProvider.notifier).applyFilters(filters);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'import':
        // TODO: استيراد المنتجات
        break;
      case 'export':
        // TODO: تصدير المنتجات
        break;
      case 'print_barcodes':
        // TODO: طباعة الباركودات
        break;
    }
  }

  Future<void> _deleteProduct(
      BuildContext context, WidgetRef ref, ProductItem product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل تريد حذف "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(productsProvider.notifier).deleteProduct(product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المنتج')),
        );
      }
    }
  }
}

/// عنصر المنتج في الشبكة
class _ProductGridItem extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _ProductGridItem({
    required this.product,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),

                  // حالة المخزون
                  if (product.stock <= product.minStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: product.stock <= 0
                              ? AppColors.error
                              : AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.stock <= 0 ? 'نفذ' : 'منخفض',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // المعلومات
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriceText(
                        price: product.salePrice,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                ),
                      ),
                      Text(
                        '${product.stock.toInt()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: product.stock <= product.minStock
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
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
      color: AppColors.surfaceVariant,
      child: Icon(
        Icons.inventory_2,
        size: 48,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// عنصر المنتج في القائمة
class _ProductListItem extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductListItem({
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56.w,
            height: 56.h,
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
        title: Text(product.name),
        subtitle: Row(
          children: [
            if (product.barcode != null) ...[
              Icon(Icons.qr_code, size: 14.sp, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text(
                product.barcode!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(width: 12.w),
            ],
            Icon(Icons.inventory, size: 14.sp, color: AppColors.textSecondary),
            SizedBox(width: 4.w),
            Text(
              '${product.stock.toInt()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: product.stock <= product.minStock
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PriceText(price: product.salePrice),
            if (!product.isActive)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'غير نشط',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Icon(
        Icons.inventory_2,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// ورقة فلتر المنتجات
class _ProductFilterSheet extends StatefulWidget {
  final Function(ProductFilters) onApply;

  const _ProductFilterSheet({required this.onApply});

  @override
  State<_ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<_ProductFilterSheet> {
  bool _showActive = true;
  bool _showInactive = false;
  bool _lowStockOnly = false;
  double _minPrice = 0;
  double _maxPrice = 10000;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('فلتر المنتجات', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16.h),

          // الحالة
          CheckboxListTile(
            title: const Text('المنتجات النشطة'),
            value: _showActive,
            onChanged: (v) => setState(() => _showActive = v ?? true),
          ),
          CheckboxListTile(
            title: const Text('المنتجات غير النشطة'),
            value: _showInactive,
            onChanged: (v) => setState(() => _showInactive = v ?? false),
          ),
          CheckboxListTile(
            title: const Text('المخزون المنخفض فقط'),
            value: _lowStockOnly,
            onChanged: (v) => setState(() => _lowStockOnly = v ?? false),
          ),

          SizedBox(height: 16.h),

          // نطاق السعر
          Text('نطاق السعر', style: Theme.of(context).textTheme.titleSmall),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 10000,
            divisions: 100,
            labels: RangeLabels(
              _minPrice.toStringAsFixed(0),
              _maxPrice.toStringAsFixed(0),
            ),
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),

          SizedBox(height: 24.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton(
                  text: 'تطبيق',
                  onPressed: () {
                    widget.onApply(ProductFilters(
                      showActive: _showActive,
                      showInactive: _showInactive,
                      lowStockOnly: _lowStockOnly,
                      minPrice: _minPrice,
                      maxPrice: _maxPrice,
                    ));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
