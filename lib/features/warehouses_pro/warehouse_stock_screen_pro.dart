// ═══════════════════════════════════════════════════════════════════════════
// Warehouse Stock Screen Pro - Enterprise Accounting Design
// View and manage stock for a specific warehouse
// ═══════════════════════════════════════════════════════════════════════════

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../data/database/app_database.dart';
import 'add_product_to_warehouse_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// WAREHOUSE STOCK STREAM PROVIDER (Family)
// ═══════════════════════════════════════════════════════════════════════════

final warehouseStockByIdProvider =
    StreamProvider.family<List<WarehouseStockData>, String>((ref, warehouseId) {
  final db = ref.watch(databaseProvider);
  return db.watchWarehouseStockByWarehouse(warehouseId);
});

final warehouseByIdProvider =
    FutureProvider.family<Warehouse?, String>((ref, warehouseId) async {
  final db = ref.watch(databaseProvider);
  return db.getWarehouseById(warehouseId);
});

class WarehouseStockScreenPro extends ConsumerStatefulWidget {
  final String warehouseId;

  const WarehouseStockScreenPro({
    super.key,
    required this.warehouseId,
  });

  @override
  ConsumerState<WarehouseStockScreenPro> createState() =>
      _WarehouseStockScreenProState();
}

class _WarehouseStockScreenProState
    extends ConsumerState<WarehouseStockScreenPro> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showLowStockOnly = false;

  // --- تحديد متعدد ---
  final Set<String> _selectedStockIds = {};
  bool _selectionMode = false;

  void _toggleSelection(String stockId) {
    setState(() {
      if (_selectedStockIds.contains(stockId)) {
        _selectedStockIds.remove(stockId);
      } else {
        _selectedStockIds.add(stockId);
      }
      _selectionMode = _selectedStockIds.isNotEmpty;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedStockIds.clear();
      _selectionMode = false;
    });
  }

  Future<void> _deleteSelectedStockItems() async {
    final db = ref.read(databaseProvider);
    for (final stockId in _selectedStockIds) {
      await db.deleteWarehouseStock(stockId);
    }
    _clearSelection();
    if (mounted) ProSnackbar.success(context, 'تم حذف المنتجات المحددة');
  }

  Future<void> _deleteStockItem(
      WarehouseStockData stockItem, Product? product) async {
    // 'warehouse' = حذف من المستودع فقط
    // 'permanent' = حذف نهائي من النظام
    // null = إلغاء
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خيارات الحذف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المنتج: "${product?.name ?? 'غير معروف'}"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // خيار 1: حذف من المستودع فقط
            InkWell(
              onTap: () => Navigator.pop(ctx, 'warehouse'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 24, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حذف من هذا المستودع فقط',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'المنتج سيبقى في قائمة المنتجات ويمكن إضافته لمستودع آخر',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // خيار 2: حذف نهائي
            InkWell(
              onTap: () => Navigator.pop(ctx, 'permanent'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.delete_forever, size: 24, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حذف نهائي من النظام',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'سيتم حذف المنتج من جميع المستودعات وقائمة المنتجات نهائياً',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );

    if (result == null) return;

    final db = ref.read(databaseProvider);

    if (result == 'warehouse') {
      // حذف من المستودع فقط
      try {
        await db.deleteWarehouseStock(stockItem.id);
        if (mounted) {
          ProSnackbar.success(
              context, 'تم حذف المنتج من المستودع (المنتج مازال في النظام)');
        }
      } catch (e) {
        if (mounted) ProSnackbar.error(context, 'خطأ في الحذف: $e');
      }
    } else if (result == 'permanent') {
      // تأكيد إضافي للحذف النهائي
      final confirmPermanent = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('تحذير!', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أنت على وشك حذف "${product?.name}" نهائياً',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('سيتم حذف:'),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.remove_circle, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('المنتج من قائمة المنتجات'),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.remove_circle, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('المخزون من جميع المستودعات'),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'هذا الإجراء لا يمكن التراجع عنه!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
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
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف نهائي'),
            ),
          ],
        ),
      );

      if (confirmPermanent == true && product != null) {
        try {
          // حذف المنتج نهائياً (سيحذف مخزون جميع المستودعات تلقائياً بسبب CASCADE)
          await db.deleteProduct(product.id);
          if (mounted) {
            ProSnackbar.success(
                context, 'تم حذف المنتج نهائياً من النظام وجميع المستودعات');
          }
        } catch (e) {
          if (mounted) ProSnackbar.error(context, 'خطأ في الحذف النهائي: $e');
        }
      }
    }
  }

  void _showEditStockItemDialog(
      WarehouseStockData stockItem, Product? product) {
    if (product == null) {
      ProSnackbar.warning(context, 'بيانات المنتج غير متوفرة');
      return;
    }

    // Controllers for all product fields
    final nameController = TextEditingController(text: product.name);
    final barcodeController =
        TextEditingController(text: product.barcode ?? '');
    final costPriceController =
        TextEditingController(text: product.purchasePrice.toStringAsFixed(0));
    final salePriceController =
        TextEditingController(text: product.salePrice.toStringAsFixed(0));
    final quantityController =
        TextEditingController(text: stockItem.quantity.toString());
    final minQuantityController =
        TextEditingController(text: stockItem.minQuantity.toString());
    final locationController =
        TextEditingController(text: stockItem.location ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: AppSpacing.md),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'تعديل "${product.name}"',
                        style: AppTypography.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Info Section
                    const ProSectionTitle('معلومات المنتج'),
                    SizedBox(height: AppSpacing.sm),
                    ProTextField(
                      controller: nameController,
                      label: 'اسم المنتج',
                      prefixIcon: Icons.shopping_bag_outlined,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ProTextField(
                      controller: barcodeController,
                      label: 'الباركود',
                      prefixIcon: Icons.qr_code,
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // Pricing Section
                    const ProSectionTitle('الأسعار'),
                    SizedBox(height: AppSpacing.sm),
                    ProTextField(
                      controller: costPriceController,
                      label: 'سعر التكلفة (ل.س)',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ProTextField(
                      controller: salePriceController,
                      label: 'سعر البيع (ل.س)',
                      prefixIcon: Icons.point_of_sale,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // Warehouse Stock Section
                    const ProSectionTitle('المخزون في المستودع'),
                    SizedBox(height: AppSpacing.sm),
                    ProTextField(
                      controller: quantityController,
                      label: 'الكمية',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ProTextField(
                      controller: minQuantityController,
                      label: 'الحد الأدنى للتنبيه',
                      prefixIcon: Icons.warning_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ProTextField(
                      controller: locationController,
                      label: 'الموقع في المستودع (اختياري)',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    ProButton(
                      label: 'حفظ جميع التعديلات',
                      fullWidth: true,
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final barcode = barcodeController.text.trim();
                        final costPrice =
                            double.tryParse(costPriceController.text) ??
                                product.purchasePrice;
                        final salePrice =
                            double.tryParse(salePriceController.text) ??
                                product.salePrice;
                        final quantity =
                            int.tryParse(quantityController.text) ??
                                stockItem.quantity;
                        final minQty =
                            int.tryParse(minQuantityController.text) ??
                                stockItem.minQuantity;

                        if (name.isEmpty) {
                          ProSnackbar.warning(context, 'اسم المنتج مطلوب');
                          return;
                        }

                        try {
                          final db = ref.read(databaseProvider);

                          // Update product info
                          await db.updateProduct(ProductsCompanion(
                            id: drift.Value(product.id),
                            name: drift.Value(name),
                            barcode:
                                drift.Value(barcode.isEmpty ? null : barcode),
                            purchasePrice: drift.Value(costPrice),
                            salePrice: drift.Value(salePrice),
                            syncStatus: const drift.Value('pending'),
                            updatedAt: drift.Value(DateTime.now()),
                          ));

                          // Update warehouse stock
                          await db.updateWarehouseStock(WarehouseStockCompanion(
                            id: drift.Value(stockItem.id),
                            quantity: drift.Value(quantity),
                            minQuantity: drift.Value(minQty),
                            location: drift.Value(
                                locationController.text.isEmpty
                                    ? null
                                    : locationController.text),
                            syncStatus: const drift.Value('pending'),
                            updatedAt: drift.Value(DateTime.now()),
                          ));

                          if (context.mounted) {
                            Navigator.pop(context);
                            ProSnackbar.success(context,
                                'تم تحديث جميع بيانات المنتج والمخزون');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ProSnackbar.error(context, 'خطأ: $e');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to edit product using the unified add/edit screen
  void _navigateToEditProduct(WarehouseStockData stockItem, Product? product) {
    if (product == null) {
      ProSnackbar.warning(context, 'بيانات المنتج غير متوفرة');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductToWarehouseScreen(
          warehouseId: widget.warehouseId,
          product: product,
          warehouseStock: stockItem,
        ),
      ),
    );
  }

  /// Show dialog to link an existing product to this warehouse
  void _showLinkExistingProductDialog() async {
    final productsAsync = ref.read(activeProductsStreamProvider);
    final products = productsAsync.value ?? [];

    if (products.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد منتجات متاحة للربط');
      return;
    }

    // Get current warehouse stock to filter out already linked products
    final stockAsync = ref.read(warehouseStockByIdProvider(widget.warehouseId));
    final currentStock = stockAsync.value ?? [];
    final linkedProductIds = currentStock.map((s) => s.productId).toSet();

    // Filter products that are not already in this warehouse
    final availableProducts =
        products.where((p) => !linkedProductIds.contains(p.id)).toList();

    if (availableProducts.isEmpty) {
      ProSnackbar.info(context, 'جميع المنتجات مربوطة بهذا المستودع بالفعل');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LinkProductDialog(
        warehouseId: widget.warehouseId,
        availableProducts: availableProducts,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warehouseAsync = ref.watch(warehouseByIdProvider(widget.warehouseId));
    final stockAsync =
        ref.watch(warehouseStockByIdProvider(widget.warehouseId));
    final productsAsync = ref.watch(activeProductsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            warehouseAsync.when(
              loading: () => ProHeader(
                title: 'مخزون المستودع',
                subtitle: 'جاري التحميل...',
                onBack: () => context.go('/warehouses'),
              ),
              error: (_, __) => ProHeader(
                title: 'مخزون المستودع',
                subtitle: 'خطأ',
                onBack: () => context.go('/warehouses'),
              ),
              data: (warehouse) => stockAsync.when(
                loading: () => ProHeader(
                  title: warehouse?.name ?? 'المستودع',
                  subtitle: '0 منتج',
                  onBack: () => context.go('/warehouses'),
                ),
                error: (_, __) => ProHeader(
                  title: warehouse?.name ?? 'المستودع',
                  subtitle: '0 منتج',
                  onBack: () => context.go('/warehouses'),
                ),
                data: (stockItems) => _selectionMode
                    ? AppBar(
                        backgroundColor: AppColors.surface,
                        leading: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _clearSelection,
                        ),
                        title: Text('تحديد (${_selectedStockIds.length})'),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'حذف المحدد',
                            onPressed: _selectedStockIds.isEmpty
                                ? null
                                : () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('تأكيد الحذف'),
                                        content: const Text(
                                            'سيتم حذف المنتجات المحددة نهائياً. هل أنت متأكد؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('إلغاء'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('حذف',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true)
                                      await _deleteSelectedStockItems();
                                  },
                          ),
                        ],
                        elevation: 0,
                      )
                    : ProHeader(
                        title: warehouse?.name ?? 'المستودع',
                        subtitle: '${stockItems.length} منتج',
                        onBack: () => context.go('/warehouses'),
                        actions: [
                          IconButton(
                            onPressed: () => context.go('/stock-transfers'),
                            icon: Icon(
                              Icons.swap_horiz,
                              color: AppColors.primary,
                            ),
                            tooltip: 'نقل المخزون',
                          ),
                          IconButton(
                            onPressed: () => setState(
                                () => _showLowStockOnly = !_showLowStockOnly),
                            icon: Icon(
                              _showLowStockOnly
                                  ? Icons.warning
                                  : Icons.warning_outlined,
                              color: _showLowStockOnly
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                            ),
                            tooltip: _showLowStockOnly
                                ? 'إظهار الكل'
                                : 'المنخفض فقط',
                          ),
                        ],
                      ),
              ),
            ),
            // Search Bar
            ProSearchBar(
              controller: _searchController,
              hintText: 'البحث في المنتجات...',
              onChanged: (value) => setState(() => _searchQuery = value),
              onClear: () => setState(() {}),
            ),
            // Stock Summary
            stockAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (stockItems) {
                final totalItems = stockItems.length;
                final totalQuantity = stockItems.fold<int>(
                  0,
                  (sum, item) => sum + item.quantity,
                );
                final lowStockCount =
                    stockItems.where((s) => s.quantity <= s.minQuantity).length;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'إجمالي الأصناف',
                          value: '$totalItems',
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.numbers,
                          label: 'إجمالي الكميات',
                          value: NumberFormat('#,##0').format(totalQuantity),
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.warning_outlined,
                          label: 'منخفض المخزون',
                          value: '$lowStockCount',
                          color: lowStockCount > 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Stock List
            Expanded(
              child: stockAsync.when(
                loading: () => ProLoadingState.list(),
                error: (error, _) =>
                    ProEmptyState.error(error: error.toString()),
                data: (stockItems) {
                  final products = productsAsync.asData?.value ?? [];
                  return _buildStockList(stockItems, products);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ربط منتج موجود
          FloatingActionButton.extended(
            onPressed: () => _showLinkExistingProductDialog(),
            backgroundColor: AppColors.secondary,
            heroTag: 'link_product',
            icon: const Icon(Icons.link, color: Colors.white),
            label: Text(
              'ربط منتج موجود',
              style: AppTypography.labelMedium.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          // إضافة منتج جديد
          FloatingActionButton.extended(
            onPressed: () => _showAddStockDialog(),
            backgroundColor: AppColors.primary,
            heroTag: 'add_product',
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'منتج جديد',
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList(
      List<WarehouseStockData> stockItems, List<Product> products) {
    // Create a map for quick product lookup
    final productMap = {for (var p in products) p.id: p};

    // Filter stock items
    var filtered = stockItems.where((item) {
      // Low stock filter
      if (_showLowStockOnly && item.quantity > item.minQuantity) {
        return false;
      }

      // Search filter
      if (_searchQuery.isEmpty) return true;
      final product = productMap[item.productId];
      if (product == null) return false;

      final query = _searchQuery.toLowerCase();
      return product.name.toLowerCase().contains(query) ||
          (product.sku?.toLowerCase().contains(query) ?? false) ||
          (product.barcode?.toLowerCase().contains(query) ?? false);
    }).toList();

    // Sort by quantity (low stock first)
    filtered.sort((a, b) {
      final aLowStock = a.quantity <= a.minQuantity;
      final bLowStock = b.quantity <= b.minQuantity;
      if (aLowStock && !bLowStock) return -1;
      if (!aLowStock && bLowStock) return 1;
      return a.quantity.compareTo(b.quantity);
    });

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 32.sp,
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              _searchQuery.isEmpty && !_showLowStockOnly
                  ? 'لا توجد منتجات في المستودع'
                  : 'لا توجد نتائج',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              _searchQuery.isEmpty && !_showLowStockOnly
                  ? 'أضف منتجات لهذا المستودع'
                  : 'جرب تغيير معايير البحث',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.sm),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final stockItem = filtered[index];
        final product = productMap[stockItem.productId];
        final isSelected = _selectedStockIds.contains(stockItem.id);
        return GestureDetector(
          onLongPress: () {
            _toggleSelection(stockItem.id);
          },
          child: Stack(
            children: [
              Opacity(
                opacity: isSelected ? 0.6 : 1.0,
                child: _StockItemCard(
                  stockItem: stockItem,
                  product: product,
                  onAdjust: () => _selectionMode
                      ? _toggleSelection(stockItem.id)
                      : _showAdjustQuantityDialog(stockItem, product),
                  onTransfer: () =>
                      _showQuickTransferDialog(stockItem, product),
                  onEdit: () => _navigateToEditProduct(stockItem, product),
                  onDelete: () => _deleteStockItem(stockItem, product),
                ),
              ),
              if (_selectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(stockItem.id),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickTransferDialog(
      WarehouseStockData stockItem, Product? product) {
    final warehousesAsync = ref.read(warehousesStreamProvider);
    final warehouses = warehousesAsync.asData?.value ?? [];

    final otherWarehouses =
        warehouses.where((w) => w.id != widget.warehouseId).toList();

    if (otherWarehouses.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد مستودعات أخرى للنقل إليها');
      return;
    }

    String? toWarehouseId;
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: EdgeInsets.only(top: AppSpacing.md),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'نقل "${product?.name ?? 'المنتج'}"',
                          style: AppTypography.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current stock info
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16.sp, color: AppColors.info),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              'المتاح في المستودع: ${stockItem.quantity}',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      // Destination warehouse
                      Text(
                        'نقل إلى المستودع',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: toWarehouseId,
                            isExpanded: true,
                            hint: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                'اختر المستودع الهدف',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            items: otherWarehouses
                                .map((w) => DropdownMenuItem(
                                      value: w.id,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                        ),
                                        child: Text(w.name),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setModalState(() => toWarehouseId = value);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      // Quantity
                      Text(
                        'الكمية',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1
                                ? () => setModalState(() => quantity--)
                                : null,
                            icon: Icon(
                              Icons.remove_circle_outline,
                              size: 28.sp,
                              color: quantity > 1
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                '$quantity',
                                style: AppTypography.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: quantity < stockItem.quantity
                                ? () => setModalState(() => quantity++)
                                : null,
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 28.sp,
                              color: quantity < stockItem.quantity
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.lg),
                      ProButton(
                        label: 'نقل الآن',
                        fullWidth: true,
                        onPressed: toWarehouseId != null && quantity > 0
                            ? () async {
                                await _executeQuickTransfer(
                                  stockItem,
                                  product,
                                  toWarehouseId!,
                                  quantity,
                                );
                                if (context.mounted) Navigator.pop(context);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _executeQuickTransfer(
    WarehouseStockData stockItem,
    Product? product,
    String toWarehouseId,
    int quantity,
  ) async {
    try {
      final db = ref.read(databaseProvider);
      final transferId = DateTime.now().millisecondsSinceEpoch.toString();
      final transferNumber =
          'TR${DateTime.now().millisecondsSinceEpoch % 100000}';

      // Create transfer
      await db.insertStockTransfer(StockTransfersCompanion(
        id: drift.Value(transferId),
        transferNumber: drift.Value(transferNumber),
        fromWarehouseId: drift.Value(widget.warehouseId),
        toWarehouseId: drift.Value(toWarehouseId),
        status: const drift.Value('pending'),
        syncStatus: const drift.Value('pending'),
      ));

      // Create transfer item
      await db.insertStockTransferItem(StockTransferItemsCompanion(
        id: drift.Value('${transferId}_${stockItem.productId}'),
        transferId: drift.Value(transferId),
        productId: drift.Value(stockItem.productId),
        productName: drift.Value(product?.name ?? 'منتج غير معروف'),
        requestedQuantity: drift.Value(quantity),
        transferredQuantity: const drift.Value(0),
        syncStatus: const drift.Value('pending'),
      ));

      // Complete transfer immediately
      await db.completeStockTransfer(transferId);

      if (mounted) {
        ProSnackbar.success(context, 'تم نقل $quantity وحدة بنجاح');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في النقل: $e');
      }
    }
  }

  void _showAddStockDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: AppSpacing.md),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'إضافة منتج للمستودع',
                      style: AppTypography.titleLarge,
                    ),
                  ),
                  ProButton(
                    label: 'منتج جديد',
                    type: ProButtonType.outlined,
                    size: ProButtonSize.small,
                    icon: Icons.add_circle_outline,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductToWarehouseScreen(
                            warehouseId: widget.warehouseId,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Products List
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final productsAsync = ref.watch(activeProductsStreamProvider);
                  final stockAsync =
                      ref.watch(warehouseStockByIdProvider(widget.warehouseId));

                  return productsAsync.when(
                    loading: () => ProLoadingState.list(),
                    error: (e, _) => ProEmptyState.error(error: e.toString()),
                    data: (products) {
                      final existingProductIds = stockAsync.asData?.value
                              .map((s) => s.productId)
                              .toSet() ??
                          {};

                      final availableProducts = products
                          .where((p) => !existingProductIds.contains(p.id))
                          .toList();

                      if (availableProducts.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Text(
                              'جميع المنتجات موجودة في المستودع',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: AppSpacing.lg),
                        itemCount: availableProducts.length,
                        itemBuilder: (context, index) {
                          final product = availableProducts[index];
                          return ListTile(
                            leading: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 18.sp,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              product.sku ?? 'بدون SKU',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showSetQuantityDialog(product);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetQuantityDialog(Product product) {
    final quantityController = TextEditingController(text: '0');
    final minQuantityController = TextEditingController(text: '5');
    final locationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: AppSpacing.md),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'إضافة "${product.name}"',
                        style: AppTypography.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProTextField(
                      controller: quantityController,
                      label: 'الكمية',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ProTextField(
                      controller: minQuantityController,
                      label: 'الحد الأدنى للتنبيه',
                      prefixIcon: Icons.warning_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ProTextField(
                      controller: locationController,
                      label: 'الموقع في المستودع (اختياري)',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    ProButton(
                      label: 'إضافة',
                      fullWidth: true,
                      onPressed: () async {
                        final quantity =
                            int.tryParse(quantityController.text) ?? 0;
                        final minQty =
                            int.tryParse(minQuantityController.text) ?? 5;

                        try {
                          final db = ref.read(databaseProvider);
                          final id =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          await db.insertWarehouseStock(WarehouseStockCompanion(
                            id: drift.Value(id),
                            warehouseId: drift.Value(widget.warehouseId),
                            productId: drift.Value(product.id),
                            quantity: drift.Value(quantity),
                            minQuantity: drift.Value(minQty),
                            location: drift.Value(
                                locationController.text.isEmpty
                                    ? null
                                    : locationController.text),
                            syncStatus: const drift.Value('pending'),
                          ));

                          if (context.mounted) {
                            Navigator.pop(context);
                            ProSnackbar.success(
                                context, 'تم إضافة المنتج للمستودع');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ProSnackbar.error(context, 'خطأ: $e');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdjustQuantityDialog(
      WarehouseStockData stockItem, Product? product) {
    final quantityController =
        TextEditingController(text: stockItem.quantity.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: AppSpacing.md),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'تعديل كمية "${product?.name ?? 'المنتج'}"',
                        style: AppTypography.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16.sp, color: AppColors.info),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'الكمية الحالية: ${stockItem.quantity}',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    ProTextField(
                      controller: quantityController,
                      label: 'الكمية الجديدة',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    ProButton(
                      label: 'حفظ',
                      fullWidth: true,
                      onPressed: () async {
                        final newQuantity =
                            int.tryParse(quantityController.text) ?? 0;

                        try {
                          final db = ref.read(databaseProvider);
                          await db.updateWarehouseStockQuantity(
                            widget.warehouseId,
                            stockItem.productId,
                            newQuantity,
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ProSnackbar.success(context, 'تم تحديث الكمية');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ProSnackbar.error(context, 'خطأ: $e');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Summary Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: color),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Stock Item Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _StockItemCard extends StatelessWidget {
  final WarehouseStockData stockItem;
  final Product? product;
  final VoidCallback onAdjust;
  final VoidCallback onTransfer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _StockItemCard({
    required this.stockItem,
    required this.product,
    required this.onAdjust,
    required this.onTransfer,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = stockItem.quantity <= stockItem.minQuantity;
    final isOutOfStock = stockItem.quantity == 0;

    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      onTap: onAdjust,
      child: Column(
        children: [
          Row(
            children: [
              // Product Icon with status
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? AppColors.error.withValues(alpha: 0.1)
                      : isLowStock
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 20.sp,
                  color: isOutOfStock
                      ? AppColors.error
                      : isLowStock
                          ? AppColors.warning
                          : AppColors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'منتج غير معروف',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        if (product?.sku != null) ...[
                          Text(
                            product!.sku!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                        ],
                        if (stockItem.location != null &&
                            stockItem.location!.isNotEmpty) ...[
                          Icon(Icons.location_on_outlined,
                              size: 12.sp, color: AppColors.textTertiary),
                          SizedBox(width: 2.w),
                          Text(
                            stockItem.location!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Quantity
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? AppColors.error.withValues(alpha: 0.1)
                          : isLowStock
                              ? AppColors.warning.withValues(alpha: 0.1)
                              : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      '${stockItem.quantity}',
                      style: AppTypography.labelLarge.copyWith(
                        color: isOutOfStock
                            ? AppColors.error
                            : isLowStock
                                ? AppColors.warning
                                : AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'الحد: ${stockItem.minQuantity}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              // Menu button
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    size: 20.sp, color: AppColors.textSecondary),
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) onEdit!();
                  if (value == 'delete' && onDelete != null) onDelete!();
                  if (value == 'transfer') onTransfer();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18.sp, color: AppColors.info),
                        SizedBox(width: AppSpacing.xs),
                        const Text('تعديل'),
                      ],
                    ),
                  ),
                  if (stockItem.quantity > 0)
                    PopupMenuItem(
                      value: 'transfer',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz,
                              size: 18.sp, color: AppColors.primary),
                          SizedBox(width: AppSpacing.xs),
                          const Text('نقل'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 18.sp, color: AppColors.error),
                        SizedBox(width: AppSpacing.xs),
                        const Text('حذف'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Transfer Button
          if (stockItem.quantity > 0) ...[
            SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onTransfer,
                icon: Icon(
                  Icons.swap_horiz,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
                label: Text(
                  'نقل إلى مستودع آخر',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Link Existing Product Dialog
// ربط منتج موجود بالمستودع
// ═══════════════════════════════════════════════════════════════════════════

class _LinkProductDialog extends ConsumerStatefulWidget {
  final String warehouseId;
  final List<Product> availableProducts;

  const _LinkProductDialog({
    required this.warehouseId,
    required this.availableProducts,
  });

  @override
  ConsumerState<_LinkProductDialog> createState() => _LinkProductDialogState();
}

class _LinkProductDialogState extends ConsumerState<_LinkProductDialog> {
  final _quantityController = TextEditingController(text: '1');
  final _minStockController = TextEditingController(text: '5');
  final _locationController = TextEditingController();
  final _searchController = TextEditingController();

  Product? _selectedProduct;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _minStockController.dispose();
    _locationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return widget.availableProducts;
    return widget.availableProducts.where((p) {
      return p.name.toLowerCase().contains(_searchQuery) ||
          (p.barcode?.toLowerCase().contains(_searchQuery) ?? false) ||
          (p.sku?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  Future<void> _linkProduct() async {
    if (_selectedProduct == null) {
      ProSnackbar.warning(context, 'الرجاء اختيار منتج');
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      ProSnackbar.warning(context, 'الرجاء إدخال كمية صحيحة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final stockId = '${timestamp}_${_selectedProduct!.id}';

      await db.insertWarehouseStock(WarehouseStockCompanion(
        id: drift.Value(stockId),
        warehouseId: drift.Value(widget.warehouseId),
        productId: drift.Value(_selectedProduct!.id),
        quantity: drift.Value(quantity),
        minQuantity: drift.Value(int.tryParse(_minStockController.text) ?? 5),
        location: drift.Value(
          _locationController.text.isEmpty ? null : _locationController.text,
        ),
        syncStatus: const drift.Value('pending'),
      ));

      if (mounted) {
        Navigator.pop(context);
        ProSnackbar.success(
          context,
          'تم ربط "${_selectedProduct!.name}" بالمستودع بنجاح',
        );
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: AppSpacing.md),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.link, color: AppColors.secondary),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ربط منتج موجود',
                        style: AppTypography.titleLarge,
                      ),
                      Text(
                        'اختر منتج من القائمة لإضافته للمستودع',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث عن منتج...',
                prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // Selected Product Info
          if (_selectedProduct != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedProduct!.name,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'سعر البيع: ${_selectedProduct!.salePrice.toStringAsFixed(0)} ل.س',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedProduct = null),
                    child: const Text('تغيير'),
                  ),
                ],
              ),
            ),
          SizedBox(height: AppSpacing.sm),
          // Product List or Quantity Form
          Expanded(
            child: _selectedProduct == null
                ? _buildProductList()
                : _buildQuantityForm(),
          ),
          // Action Button
          if (_selectedProduct != null)
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: ProButton(
                label: 'ربط المنتج بالمستودع',
                icon: Icons.link,
                fullWidth: true,
                isLoading: _isLoading,
                onPressed: _linkProduct,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'لا توجد منتجات مطابقة',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            onTap: () => setState(() => _selectedProduct = product),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: AppTypography.titleSmall,
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text(
                              'سعر البيع: ${product.salePrice.toStringAsFixed(0)} ل.س',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (product.barcode != null) ...[
                              SizedBox(width: AppSpacing.md),
                              Icon(
                                Icons.qr_code,
                                size: 12.sp,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                product.barcode!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textTertiary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_left,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProSectionTitle('معلومات المخزون'),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ProNumberField(
                  controller: _quantityController,
                  label: 'الكمية *',
                  hint: '1',
                  allowDecimal: false,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: ProNumberField(
                  controller: _minStockController,
                  label: 'الحد الأدنى',
                  hint: '5',
                  allowDecimal: false,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ProTextField(
            controller: _locationController,
            label: 'الموقع في المستودع (اختياري)',
            hint: 'مثال: رف A-3',
            prefixIcon: Icons.location_on_outlined,
          ),
          SizedBox(height: AppSpacing.lg),
          // Product Info Card
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلومات المنتج',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                _buildInfoRow('سعر التكلفة',
                    '${_selectedProduct!.purchasePrice.toStringAsFixed(0)} ل.س'),
                _buildInfoRow('سعر البيع',
                    '${_selectedProduct!.salePrice.toStringAsFixed(0)} ل.س'),
                if (_selectedProduct!.barcode != null)
                  _buildInfoRow('الباركود', _selectedProduct!.barcode!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
