// ═══════════════════════════════════════════════════════════════════════════
// Products Screen Pro - Enterprise Design System
// Professional Products Management Interface
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/export/export_button.dart';
import '../../core/services/export/products_export_service.dart';
import '../../core/services/currency_service.dart';
import '../../data/database/app_database.dart';
import 'widgets/product_card_pro.dart';
import 'widgets/products_filter_bar.dart';
import 'widgets/category_chips.dart';

// مفتاح حفظ تفضيل العرض
const String _viewPreferenceKey = 'products_view_is_grid';

class ProductsScreenPro extends ConsumerStatefulWidget {
  const ProductsScreenPro({super.key});

  @override
  ConsumerState<ProductsScreenPro> createState() => _ProductsScreenProState();
}

class _ProductsScreenProState extends ConsumerState<ProductsScreenPro>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _selectedCategoryId = 'all';
  String _sortBy = 'name';
  bool _isGridView = false; // العرض الافتراضي List
  bool _isExporting = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedProducts = {};
  bool _showLowStockOnly = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.easeOut,
    );
    _animationController.forward();
  }

  /// تحميل تفضيل العرض المحفوظ
  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isGrid = prefs.getBool(_viewPreferenceKey) ?? false;
    if (mounted && isGrid != _isGridView) {
      setState(() => _isGridView = isGrid);
    }
  }

  /// حفظ تفضيل العرض
  Future<void> _saveViewPreference(bool isGrid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_viewPreferenceKey, isGrid);
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
    _saveViewPreference(_isGridView);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterProducts(
      List<Map<String, dynamic>> productData, List<Category> categories) {
    return productData.where((item) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;

      // فلتر البحث
      final matchesSearch = _searchController.text.isEmpty ||
          product.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          (product.sku
                  ?.toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ??
              false) ||
          (product.barcode
                  ?.toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ??
              false);

      // فلتر التصنيف
      final matchesCategory = _selectedCategoryId == 'all' ||
          product.categoryId == _selectedCategoryId;

      // فلتر المخزون المنخفض
      final matchesLowStock =
          !_showLowStockOnly || quantity <= product.minQuantity;

      return matchesSearch && matchesCategory && matchesLowStock;
    }).toList();
  }

  List<Map<String, dynamic>> _sortProducts(
      List<Map<String, dynamic>> productData) {
    final sorted = List<Map<String, dynamic>>.from(productData);
    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) => (a['product'] as Product)
            .name
            .compareTo((b['product'] as Product).name));
        break;
      case 'price_asc':
        sorted.sort((a, b) => (a['product'] as Product)
            .salePrice
            .compareTo((b['product'] as Product).salePrice));
        break;
      case 'price_desc':
        sorted.sort((a, b) => (b['product'] as Product)
            .salePrice
            .compareTo((a['product'] as Product).salePrice));
        break;
      case 'stock':
        sorted.sort(
            (a, b) => (a['quantity'] as int).compareTo(b['quantity'] as int));
        break;
      case 'recent':
        sorted.sort((a, b) => (b['product'] as Product)
            .createdAt
            .compareTo((a['product'] as Product).createdAt));
        break;
    }
    return sorted;
  }

  Future<void> _handleExport(
      ExportType type, List<Map<String, dynamic>> productData) async {
    if (productData.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد منتجات للتصدير');
      return;
    }

    setState(() => _isExporting = true);

    try {
      // إنشاء قائمة منتجات بالكميات الصحيحة من المستودعات
      final products = productData.map((item) {
        final product = item['product'] as Product;
        final quantity = item['quantity'] as int;
        // إنشاء نسخة من المنتج بالكمية الفعلية من المستودع
        return Product(
          id: product.id,
          name: product.name,
          barcode: product.barcode,
          sku: product.sku,
          categoryId: product.categoryId,
          quantity: quantity, // استخدام الكمية من المستودع
          minQuantity: product.minQuantity,
          purchasePrice: product.purchasePrice,
          purchasePriceUsd: product.purchasePriceUsd,
          salePrice: product.salePrice,
          salePriceUsd: product.salePriceUsd,
          description: product.description,
          imageUrl: product.imageUrl,
          isActive: product.isActive,
          syncStatus: product.syncStatus,
          createdAt: product.createdAt,
          updatedAt: product.updatedAt,
        );
      }).toList();

      switch (type) {
        case ExportType.excel:
          await ProductsExportService.exportToExcel(
            products: products,
            fileName: 'products_list',
          );
          if (mounted) {
            ProSnackbar.success(
              context,
              'تم تصدير ${products.length} منتج إلى Excel',
            );
          }
          break;
        case ExportType.pdf:
          final bytes = await ProductsExportService.generatePdf(
            products: products,
          );
          await ProductsExportService.savePdf(bytes, 'products_list');
          if (mounted) {
            ProSnackbar.success(
              context,
              'تم تصدير ${products.length} منتج إلى PDF',
            );
          }
          break;
        case ExportType.sharePdf:
          final bytes = await ProductsExportService.generatePdf(
            products: products,
          );
          await ProductsExportService.sharePdfBytes(
            bytes,
            fileName: 'products_list',
            subject: 'قائمة المنتجات',
          );
          break;
        case ExportType.shareExcel:
          final filePath = await ProductsExportService.exportToExcel(
            products: products,
            fileName: 'products_list',
          );
          await ProductsExportService.shareFile(
            filePath,
            subject: 'قائمة المنتجات',
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync =
        ref.watch(activeProductsWithDefaultWarehouseStockProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ═══════════════════════════════════════════════════════════════
            // Header
            // ═══════════════════════════════════════════════════════════════
            productsAsync.when(
              loading: () => ProHeader(
                title: 'المنتجات',
                subtitle: '0 منتج',
                onBack: () => context.go('/'),
              ),
              error: (_, __) => ProHeader(
                title: 'المنتجات',
                subtitle: '0 منتج',
                onBack: () => context.go('/'),
              ),
              data: (productData) {
                final lowStockCount = productData
                    .where((item) =>
                        item['quantity'] <=
                        (item['product'] as Product).minQuantity)
                    .length;

                return ProHeader(
                  title: _isSelectionMode
                      ? 'تم تحديد ${_selectedProducts.length}'
                      : 'المنتجات',
                  subtitle: _isSelectionMode
                      ? null
                      : '${productData.length} منتج${lowStockCount > 0 ? ' • $lowStockCount منخفض' : ''}',
                  onBack: _isSelectionMode
                      ? () => setState(() {
                            _isSelectionMode = false;
                            _selectedProducts.clear();
                          })
                      : () => context.go('/'),
                  actions: _isSelectionMode
                      ? [
                          // حذف المحدد
                          IconButton(
                            onPressed: _selectedProducts.isEmpty
                                ? null
                                : () => _showDeleteConfirmation(productData
                                    .map((item) => item['product'] as Product)
                                    .toList()),
                            icon: Icon(Icons.delete_outline,
                                color: _selectedProducts.isEmpty
                                    ? AppColors.textSecondary
                                        .withValues(alpha: 0.5)
                                    : AppColors.error),
                            tooltip: 'حذف المحدد',
                          ),
                          // تحديث المخزون
                          IconButton(
                            onPressed: _selectedProducts.isEmpty
                                ? null
                                : () => _showBulkStockUpdateDialog(productData
                                    .map((item) => item['product'] as Product)
                                    .toList()),
                            icon: Icon(Icons.inventory_2_outlined,
                                color: _selectedProducts.isEmpty
                                    ? AppColors.textSecondary
                                        .withValues(alpha: 0.5)
                                    : AppColors.primary),
                            tooltip: 'تحديث المخزون',
                          ),
                          // تعديل الأسعار
                          IconButton(
                            onPressed: _selectedProducts.isEmpty
                                ? null
                                : () => _showBulkPriceEditDialog(productData
                                    .map((item) => item['product'] as Product)
                                    .toList()),
                            icon: Icon(Icons.price_change_outlined,
                                color: _selectedProducts.isEmpty
                                    ? AppColors.textSecondary
                                        .withValues(alpha: 0.5)
                                    : AppColors.warning),
                            tooltip: 'تعديل الأسعار',
                          ),
                          // تحديد الكل
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_selectedProducts.length ==
                                    productData.length) {
                                  _selectedProducts.clear();
                                } else {
                                  _selectedProducts.addAll(productData.map(
                                      (item) =>
                                          (item['product'] as Product).id));
                                }
                              });
                            },
                            icon: Icon(
                                _selectedProducts.length == productData.length
                                    ? Icons.deselect
                                    : Icons.select_all,
                                color: AppColors.textSecondary),
                            tooltip:
                                _selectedProducts.length == productData.length
                                    ? 'إلغاء تحديد الكل'
                                    : 'تحديد الكل',
                          ),
                        ]
                      : [
                          // تنبيه المخزون المنخفض
                          if (lowStockCount > 0)
                            Badge(
                              label: Text('$lowStockCount'),
                              backgroundColor: AppColors.error,
                              child: IconButton(
                                onPressed: () => setState(() =>
                                    _showLowStockOnly = !_showLowStockOnly),
                                icon: Icon(
                                    _showLowStockOnly
                                        ? Icons.warning_amber_rounded
                                        : Icons.warning_amber_outlined,
                                    color: _showLowStockOnly
                                        ? AppColors.error
                                        : AppColors.warning),
                                tooltip: _showLowStockOnly
                                    ? 'إظهار الكل'
                                    : 'المنتجات المنخفضة فقط',
                              ),
                            ),
                          // وضع التحديد
                          IconButton(
                            onPressed: () =>
                                setState(() => _isSelectionMode = true),
                            icon: Icon(Icons.checklist_rounded,
                                color: AppColors.textSecondary),
                            tooltip: 'تحديد متعدد',
                          ),
                          ExportMenuButton(
                            onExport: (type) =>
                                _handleExport(type, productData),
                            isLoading: _isExporting,
                            icon: Icons.more_vert,
                            tooltip: 'تصدير ومشاركة',
                            enabledOptions: const {
                              ExportType.excel,
                              ExportType.pdf,
                              ExportType.sharePdf,
                              ExportType.shareExcel,
                            },
                          ),
                        ],
                );
              },
            ),

            // ═══════════════════════════════════════════════════════════════
            // Search & Filter Bar
            // ═══════════════════════════════════════════════════════════════
            ProductsFilterBar(
              searchController: _searchController,
              onSearchChanged: (value) => setState(() {}),
              isGridView: _isGridView,
              onViewToggle: _toggleViewMode,
              sortBy: _sortBy,
              onSortChanged: (value) =>
                  setState(() => _sortBy = value ?? _sortBy),
            ),

            // ═══════════════════════════════════════════════════════════════
            // Category Chips
            // ═══════════════════════════════════════════════════════════════
            categoriesAsync.when(
              loading: () => const SizedBox(height: 50),
              error: (_, __) => const SizedBox(height: 50),
              data: (categories) {
                // حساب عدد المنتجات لكل تصنيف
                final productData = productsAsync.asData?.value ?? [];
                final allCount = productData.length;

                final categoryList = [
                  {'id': 'all', 'name': 'الكل', 'count': allCount},
                  ...categories.map((c) {
                    final count = productData
                        .where((item) =>
                            (item['product'] as Product).categoryId == c.id)
                        .length;
                    return {
                      'id': c.id,
                      'name': c.name,
                      'count': count,
                    };
                  }),
                ];

                return CategoryChips(
                  categories: categoryList,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (categoryId) =>
                      setState(() => _selectedCategoryId = categoryId),
                );
              },
            ),

            // ═══════════════════════════════════════════════════════════════
            // Products Grid/List
            // ═══════════════════════════════════════════════════════════════
            Expanded(
              child: productsAsync.when(
                loading: () => ProLoadingState.grid(),
                error: (error, _) => ProEmptyState.error(
                  error: error.toString(),
                  onRetry: () => ref.invalidate(
                      activeProductsWithDefaultWarehouseStockProvider),
                ),
                data: (productData) {
                  final categories = categoriesAsync.asData?.value ?? [];

                  // Apply filters and sorting
                  var filteredProducts =
                      _filterProducts(productData, categories);
                  filteredProducts = _sortProducts(filteredProducts);

                  if (filteredProducts.isEmpty) {
                    final hasFilter = _searchController.text.isNotEmpty ||
                        _selectedCategoryId != 'all';
                    return hasFilter
                        ? ProEmptyState.noResults(
                            onClear: () {
                              setState(() {
                                _searchController.clear();
                                _selectedCategoryId = 'all';
                              });
                            },
                          )
                        : ProEmptyState.list(
                            itemName: 'منتج',
                          );
                  }

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(
                            activeProductsWithDefaultWarehouseStockProvider);
                      },
                      child: _isGridView
                          ? _buildGridView(filteredProducts, categories)
                          : _buildListView(filteredProducts, categories),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products/add'),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'منتج جديد',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildGridView(
      List<Map<String, dynamic>> productData, List<Category> categories) {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
      ),
      itemCount: productData.length,
      itemBuilder: (context, index) {
        final item = productData[index];
        final product = item['product'] as Product;
        final quantity = item['quantity'] as int;
        final category =
            categories.where((c) => c.id == product.categoryId).firstOrNull;
        final isSelected = _selectedProducts.contains(product.id);

        return GestureDetector(
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedProducts.add(product.id);
              });
            }
          },
          child: Stack(
            children: [
              ProductCardPro(
                product: _productToMap(product, category, quantity),
                isListView: false,
                onTap: _isSelectionMode
                    ? () => _toggleSelection(product.id)
                    : () => context.push('/products/${product.id}'),
                onEdit: _isSelectionMode
                    ? null
                    : () => context.push('/products/edit/${product.id}'),
              ),
              if (_isSelectionMode)
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(
      List<Map<String, dynamic>> productData, List<Category> categories) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: productData.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final item = productData[index];
        final product = item['product'] as Product;
        final quantity = item['quantity'] as int;
        final category =
            categories.where((c) => c.id == product.categoryId).firstOrNull;
        final isSelected = _selectedProducts.contains(product.id);

        return GestureDetector(
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedProducts.add(product.id);
              });
            }
          },
          child: Row(
            children: [
              if (_isSelectionMode)
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.xs),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(product.id),
                    activeColor: AppColors.primary,
                  ),
                ),
              Expanded(
                child: ProductCardPro(
                  product: _productToMap(product, category, quantity),
                  isListView: true,
                  onTap: _isSelectionMode
                      ? () => _toggleSelection(product.id)
                      : () => context.push('/products/${product.id}'),
                  onEdit: _isSelectionMode
                      ? null
                      : () => context.push('/products/edit/${product.id}'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleSelection(String productId) {
    setState(() {
      if (_selectedProducts.contains(productId)) {
        _selectedProducts.remove(productId);
        if (_selectedProducts.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedProducts.add(productId);
      }
    });
  }

  /// حذف المنتجات المحددة
  Future<void> _showDeleteConfirmation(List<Product> allProducts) async {
    final selectedProductsList =
        allProducts.where((p) => _selectedProducts.contains(p.id)).toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: AppSpacing.sm),
            const Text('تأكيد الحذف'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من حذف ${selectedProductsList.length} منتج؟',
              style: AppTypography.bodyMedium,
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.soft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.error, size: 18),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'هذا الإجراء لا يمكن التراجع عنه',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteSelectedProducts(selectedProductsList);
    }
  }

  Future<void> _deleteSelectedProducts(List<Product> products) async {
    try {
      final productRepo = ref.read(productRepositoryProvider);

      for (final product in products) {
        await productRepo.deleteProduct(product.id);
      }

      if (mounted) {
        ProSnackbar.success(
          context,
          'تم حذف ${products.length} منتج بنجاح',
        );
        setState(() {
          _isSelectionMode = false;
          _selectedProducts.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ أثناء الحذف: $e');
      }
    }
  }

  Future<void> _showBulkPriceEditDialog(List<Product> allProducts) async {
    final selectedProductsList =
        allProducts.where((p) => _selectedProducts.contains(p.id)).toList();
    final percentageController = TextEditingController();
    String adjustmentType = 'increase'; // increase or decrease
    String priceType = 'sale'; // sale or purchase

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تعديل الأسعار بالجملة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المنتجات المحددة: ${selectedProductsList.length}',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSpacing.md),

                // نوع السعر
                Text('نوع السعر', style: AppTypography.labelMedium),
                SizedBox(height: AppSpacing.xs),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'sale', label: Text('سعر البيع')),
                    ButtonSegment(value: 'purchase', label: Text('سعر الشراء')),
                  ],
                  selected: {priceType},
                  onSelectionChanged: (selection) {
                    setDialogState(() => priceType = selection.first);
                  },
                ),
                SizedBox(height: AppSpacing.md),

                // نوع التعديل
                Text('نوع التعديل', style: AppTypography.labelMedium),
                SizedBox(height: AppSpacing.xs),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'increase', label: Text('زيادة')),
                    ButtonSegment(value: 'decrease', label: Text('تخفيض')),
                  ],
                  selected: {adjustmentType},
                  onSelectionChanged: (selection) {
                    setDialogState(() => adjustmentType = selection.first);
                  },
                ),
                SizedBox(height: AppSpacing.md),

                // النسبة المئوية
                TextField(
                  controller: percentageController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'النسبة المئوية %',
                    suffixText: '%',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
    );

    if (result == true && percentageController.text.isNotEmpty) {
      final percentage = double.tryParse(percentageController.text) ?? 0;
      if (percentage > 0) {
        await _applyBulkPriceChange(
          selectedProductsList,
          percentage,
          adjustmentType,
          priceType,
        );
      }
    }
  }

  Future<void> _applyBulkPriceChange(
    List<Product> products,
    double percentage,
    String adjustmentType,
    String priceType,
  ) async {
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final multiplier = adjustmentType == 'increase'
          ? (1 + percentage / 100)
          : (1 - percentage / 100);

      for (final product in products) {
        final currentPrice =
            priceType == 'sale' ? product.salePrice : product.purchasePrice;
        final newPrice = currentPrice * multiplier;

        if (priceType == 'sale') {
          await productRepo.updateProduct(id: product.id, salePrice: newPrice);
        } else {
          await productRepo.updateProduct(
              id: product.id, purchasePrice: newPrice);
        }
      }

      if (mounted) {
        final actionText = adjustmentType == 'increase' ? 'زيادة' : 'تخفيض';
        final priceText = priceType == 'sale' ? 'البيع' : 'الشراء';
        ProSnackbar.success(
          context,
          'تم $actionText أسعار $priceText بنسبة $percentage% لـ ${products.length} منتج',
        );
        setState(() {
          _isSelectionMode = false;
          _selectedProducts.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ: $e');
      }
    }
  }

  Future<void> _showBulkStockUpdateDialog(List<Product> allProducts) async {
    final selectedProductsList =
        allProducts.where((p) => _selectedProducts.contains(p.id)).toList();
    final quantityController = TextEditingController();
    String updateType = 'set'; // set, add, subtract

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تحديث المخزون بالجملة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المنتجات المحددة: ${selectedProductsList.length}',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSpacing.md),

                // نوع التحديث
                Text('نوع التحديث', style: AppTypography.labelMedium),
                SizedBox(height: AppSpacing.xs),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'set', label: Text('تعيين')),
                    ButtonSegment(value: 'add', label: Text('إضافة')),
                    ButtonSegment(value: 'subtract', label: Text('خصم')),
                  ],
                  selected: {updateType},
                  onSelectionChanged: (selection) {
                    setDialogState(() => updateType = selection.first);
                  },
                ),
                SizedBox(height: AppSpacing.md),

                // الكمية
                TextField(
                  controller: quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: updateType == 'set'
                        ? 'الكمية الجديدة'
                        : updateType == 'add'
                            ? 'كمية الإضافة'
                            : 'كمية الخصم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                  ),
                ),

                if (updateType == 'set')
                  Padding(
                    padding: EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      '⚠️ سيتم تعيين نفس الكمية لجميع المنتجات المحددة',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.warning),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
    );

    if (result == true && quantityController.text.isNotEmpty) {
      final quantity = double.tryParse(quantityController.text) ?? 0;
      await _applyBulkStockUpdate(selectedProductsList, quantity, updateType);
    }
  }

  Future<void> _applyBulkStockUpdate(
    List<Product> products,
    double quantity,
    String updateType,
  ) async {
    try {
      final productRepo = ref.read(productRepositoryProvider);

      for (final product in products) {
        int newQuantity;
        switch (updateType) {
          case 'set':
            newQuantity = quantity.toInt();
            break;
          case 'add':
            newQuantity = product.quantity + quantity.toInt();
            break;
          case 'subtract':
            newQuantity =
                (product.quantity - quantity.toInt()).clamp(0, 999999);
            break;
          default:
            continue;
        }

        await productRepo.updateProductQuantity(product.id, newQuantity);
      }

      if (mounted) {
        final actionText = updateType == 'set'
            ? 'تعيين'
            : updateType == 'add'
                ? 'إضافة'
                : 'خصم';
        ProSnackbar.success(
          context,
          'تم $actionText المخزون لـ ${products.length} منتج',
        );
        setState(() {
          _isSelectionMode = false;
          _selectedProducts.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ: $e');
      }
    }
  }

  Map<String, dynamic> _productToMap(
      Product product, Category? category, int quantity) {
    String status = 'active';
    if (quantity <= 0) {
      status = 'out_of_stock';
    } else if (quantity <= product.minQuantity) {
      status = 'low_stock';
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // الدولار هو الأساس: حساب السعر بالليرة من الدولار × سعر الصرف الحالي
    // ═══════════════════════════════════════════════════════════════════════════
    final currentRate = CurrencyService.currentRate;
    final salePriceSyp =
        (product.salePriceUsd != null && product.salePriceUsd! > 0)
            ? product.salePriceUsd! * currentRate
            : product.salePrice;
    final purchasePriceSyp =
        (product.purchasePriceUsd != null && product.purchasePriceUsd! > 0)
            ? product.purchasePriceUsd! * currentRate
            : product.purchasePrice;

    return {
      'id': product.id,
      'name': product.name,
      'sku': product.sku ?? '',
      'barcode': product.barcode ?? '',
      'price': salePriceSyp,
      'cost': purchasePriceSyp,
      'priceUsd': product.salePriceUsd,
      'costUsd': product.purchasePriceUsd,
      'stock': quantity,
      'minStock': product.minQuantity,
      'category': category?.name ?? 'بدون تصنيف',
      'categoryId': product.categoryId,
      'image': product.imageUrl,
      'status': status,
      'isActive': product.isActive,
    };
  }
}
