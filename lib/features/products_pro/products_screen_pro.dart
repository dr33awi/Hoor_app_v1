// ═══════════════════════════════════════════════════════════════════════════
// Products Screen Pro - Professional Design System
// Modern Products Management Interface with Real Data
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/export/export_button.dart';
import '../../core/services/export/products_export_service.dart';
import '../../data/database/app_database.dart';
import 'widgets/product_card_pro.dart';
import 'widgets/products_filter_bar.dart';
import 'widgets/category_chips.dart';

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
  bool _isGridView = true;
  bool _isExporting = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedProducts = {};
  bool _showLowStockOnly = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(
      List<Product> products, List<Category> categories) {
    return products.where((product) {
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
          !_showLowStockOnly || product.quantity <= product.minQuantity;

      return matchesSearch && matchesCategory && matchesLowStock;
    }).toList();
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.from(products);
    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_asc':
        sorted.sort((a, b) => a.salePrice.compareTo(b.salePrice));
        break;
      case 'price_desc':
        sorted.sort((a, b) => b.salePrice.compareTo(a.salePrice));
        break;
      case 'stock':
        sorted.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'recent':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sorted;
  }

  Future<void> _handleExport(ExportType type, List<Product> products) async {
    if (products.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد منتجات للتصدير');
      return;
    }

    setState(() => _isExporting = true);

    try {
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
    final productsAsync = ref.watch(activeProductsStreamProvider);
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
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.qr_code_scanner_rounded,
                        color: AppColors.textSecondary),
                    tooltip: 'مسح الباركود',
                  ),
                ],
              ),
              error: (_, __) => ProHeader(
                title: 'المنتجات',
                subtitle: '0 منتج',
                onBack: () => context.go('/'),
              ),
              data: (products) {
                final lowStockCount =
                    products.where((p) => p.quantity <= p.minQuantity).length;

                return ProHeader(
                  title: _isSelectionMode
                      ? 'تم تحديد ${_selectedProducts.length}'
                      : 'المنتجات',
                  subtitle: _isSelectionMode
                      ? null
                      : '${products.length} منتج${lowStockCount > 0 ? ' • $lowStockCount منخفض' : ''}',
                  onBack: _isSelectionMode
                      ? () => setState(() {
                            _isSelectionMode = false;
                            _selectedProducts.clear();
                          })
                      : () => context.go('/'),
                  actions: _isSelectionMode
                      ? [
                          // تحديث المخزون
                          IconButton(
                            onPressed: _selectedProducts.isEmpty
                                ? null
                                : () => _showBulkStockUpdateDialog(products),
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
                                : () => _showBulkPriceEditDialog(products),
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
                                    products.length) {
                                  _selectedProducts.clear();
                                } else {
                                  _selectedProducts
                                      .addAll(products.map((p) => p.id));
                                }
                              });
                            },
                            icon: Icon(
                                _selectedProducts.length == products.length
                                    ? Icons.deselect
                                    : Icons.select_all,
                                color: AppColors.textSecondary),
                            tooltip: _selectedProducts.length == products.length
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
                          // مسح الباركود
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.qr_code_scanner_rounded,
                                color: AppColors.textSecondary),
                            tooltip: 'مسح الباركود',
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
                            onExport: (type) => _handleExport(type, products),
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
              onViewToggle: () => setState(() => _isGridView = !_isGridView),
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
                final products = productsAsync.asData?.value ?? [];
                final allCount = products.length;

                final categoryList = [
                  {'id': 'all', 'name': 'الكل', 'count': allCount},
                  ...categories.map((c) {
                    final count =
                        products.where((p) => p.categoryId == c.id).length;
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
                  onRetry: () => ref.invalidate(activeProductsStreamProvider),
                ),
                data: (products) {
                  final categories = categoriesAsync.asData?.value ?? [];

                  // Apply filters and sorting
                  var filteredProducts = _filterProducts(products, categories);
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
                        ref.invalidate(activeProductsStreamProvider);
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

  Widget _buildGridView(List<Product> products, List<Category> categories) {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
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
                product: _productToMap(product, category),
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
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.transparent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(List<Product> products, List<Category> categories) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: products.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final product = products[index];
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
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(product.id),
                    activeColor: AppColors.primary,
                  ),
                ),
              Expanded(
                child: ProductCardPro(
                  product: _productToMap(product, category),
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

  Map<String, dynamic> _productToMap(Product product, Category? category) {
    String status = 'active';
    if (product.quantity <= 0) {
      status = 'out_of_stock';
    } else if (product.quantity <= product.minQuantity) {
      status = 'low_stock';
    }

    return {
      'id': product.id,
      'name': product.name,
      'sku': product.sku ?? '',
      'barcode': product.barcode ?? '',
      'price': product.salePrice,
      'cost': product.purchasePrice,
      'stock': product.quantity,
      'minStock': product.minQuantity,
      'category': category?.name ?? 'بدون تصنيف',
      'categoryId': product.categoryId,
      'image': product.imageUrl,
      'status': status,
      'isActive': product.isActive,
    };
  }
}
