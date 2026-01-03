import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/daos/inventory_dao.dart';
import '../../../../core/database/daos/categories_dao.dart';
import '../../../../core/database/database.dart';

/// منتج المخزون
class InventoryProduct {
  final int id;
  final String name;
  final String? barcode;
  final double currentStock;
  final double minStock;
  final int? categoryId;
  final String? categoryName;

  InventoryProduct({
    required this.id,
    required this.name,
    this.barcode,
    required this.currentStock,
    required this.minStock,
    this.categoryId,
    this.categoryName,
  });
}

/// حركة مخزون
class StockMovement {
  final int id;
  final int productId;
  final String productName;
  final double quantity;
  final String type;
  final String? note;
  final DateTime date;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.type,
    this.note,
    required this.date,
  });
}

/// فئة بسيطة
class SimpleCategory {
  final int id;
  final String name;

  SimpleCategory({required this.id, required this.name});
}

/// فلتر المخزون
enum StockFilter { all, low, outOfStock, available }

/// نوع التعديل
enum AdjustmentType { add, subtract, set, count }

/// حالة المخزون
class InventoryState {
  final bool isLoading;
  final List<InventoryProduct> products;
  final List<StockMovement> movements;
  final List<SimpleCategory> categories;
  final String searchQuery;
  final StockFilter stockFilter;
  final int? selectedCategoryId;

  const InventoryState({
    this.isLoading = false,
    this.products = const [],
    this.movements = const [],
    this.categories = const [],
    this.searchQuery = '',
    this.stockFilter = StockFilter.all,
    this.selectedCategoryId,
  });

  List<InventoryProduct> get filteredProducts {
    var result = products.toList();

    // البحث
    if (searchQuery.isNotEmpty) {
      result = result.where((p) {
        return p.name.contains(searchQuery) ||
            (p.barcode?.contains(searchQuery) ?? false);
      }).toList();
    }

    // فلتر المخزون
    switch (stockFilter) {
      case StockFilter.low:
        result = result.where((p) {
          return p.currentStock > 0 && p.currentStock <= p.minStock;
        }).toList();
        break;
      case StockFilter.outOfStock:
        result = result.where((p) => p.currentStock <= 0).toList();
        break;
      case StockFilter.available:
        result = result.where((p) => p.currentStock > p.minStock).toList();
        break;
      case StockFilter.all:
      default:
        break;
    }

    // فلتر الفئة
    if (selectedCategoryId != null) {
      result = result.where((p) => p.categoryId == selectedCategoryId).toList();
    }

    return result;
  }

  List<InventoryProduct> get lowStockProducts {
    return products.where((p) {
      return p.currentStock > 0 && p.currentStock <= p.minStock;
    }).toList();
  }

  List<InventoryProduct> get outOfStockProducts {
    return products.where((p) => p.currentStock <= 0).toList();
  }

  InventoryState copyWith({
    bool? isLoading,
    List<InventoryProduct>? products,
    List<StockMovement>? movements,
    List<SimpleCategory>? categories,
    String? searchQuery,
    StockFilter? stockFilter,
    int? selectedCategoryId,
    bool clearCategoryId = false,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      movements: movements ?? this.movements,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      stockFilter: stockFilter ?? this.stockFilter,
      selectedCategoryId: clearCategoryId
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }
}

/// مدير المخزون
class InventoryNotifier extends StateNotifier<InventoryState> {
  final ProductsDao _productDao;
  final InventoryDao _inventoryDao;
  final CategoriesDao _categoryDao;

  InventoryNotifier(
    this._productDao,
    this._inventoryDao,
    this._categoryDao,
  ) : super(const InventoryState());

  Future<void> loadInventory() async {
    state = state.copyWith(isLoading: true);

    try {
      // تحميل المنتجات
      final products = await _productDao.getAllProducts();
      final categories = await _categoryDao.getAllCategories();

      final inventoryProducts = <InventoryProduct>[];

      for (final product in products) {
        final category = categories.firstWhere(
          (c) => c.id == product.categoryId,
          orElse: () => Category(
            id: 0,
            name: 'بدون تصنيف',
            sortOrder: 0,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // جلب المخزون من جدول Inventory
        final inventoryList =
            await _inventoryDao.getProductInventoryAll(product.id);
        final currentStock =
            inventoryList.fold<double>(0.0, (sum, inv) => sum + inv.quantity);

        inventoryProducts.add(InventoryProduct(
          id: product.id,
          name: product.name,
          barcode: product.barcode,
          currentStock: currentStock,
          minStock: product.lowStockAlert.toDouble(),
          categoryId: product.categoryId,
          categoryName: category.name,
        ));
      }

      // تحميل الحركات - استخدام فترة زمنية (آخر 30 يوم)
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final movements =
          await _inventoryDao.getMovementsByDateRange(thirtyDaysAgo, now);
      final stockMovements = <StockMovement>[];

      for (final movement in movements) {
        final product = products.firstWhere(
          (p) => p.id == movement.productId,
          orElse: () => Product(
            id: 0,
            name: 'منتج محذوف',
            salePrice: 0,
            costPrice: 0,
            unit: 'قطعة',
            lowStockAlert: 0,
            trackInventory: false,
            isActive: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        stockMovements.add(StockMovement(
          id: movement.id,
          productId: movement.productId,
          productName: product.name,
          quantity: movement.quantity,
          type: _getMovementTypeText(movement.movementType),
          note: movement.notes,
          date: movement.createdAt ?? DateTime.now(),
        ));
      }

      // ترتيب الحركات حسب التاريخ
      stockMovements.sort((a, b) => b.date.compareTo(a.date));

      // تحميل الفئات
      final simpleCategories = categories
          .map((c) => SimpleCategory(id: c.id, name: c.name))
          .toList();

      state = state.copyWith(
        products: inventoryProducts,
        movements: stockMovements.take(100).toList(),
        categories: simpleCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStockFilter(StockFilter filter) {
    state = state.copyWith(stockFilter: filter);
  }

  void setCategoryFilter(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategoryId: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      stockFilter: StockFilter.all,
      clearCategoryId: true,
    );
  }

  Future<void> adjustStock({
    required int productId,
    required double quantity,
    required AdjustmentType type,
    String? note,
  }) async {
    try {
      final product = await _productDao.getProductById(productId);
      if (product == null) return;

      // جلب المخزون الحالي
      final inventoryList =
          await _inventoryDao.getProductInventoryAll(productId);
      final currentStock =
          inventoryList.fold<double>(0.0, (sum, inv) => sum + inv.quantity);

      double newStock;

      switch (type) {
        case AdjustmentType.add:
          newStock = currentStock + quantity;
          break;
        case AdjustmentType.subtract:
          newStock = currentStock - quantity;
          break;
        case AdjustmentType.set:
        case AdjustmentType.count:
          newStock = quantity;
          break;
      }

      // الحصول على المستودع الافتراضي
      final defaultWarehouse = await _inventoryDao.getDefaultWarehouse();
      final warehouseId = defaultWarehouse?.id ?? 1;

      // تطبيق التعديل بناءً على النوع
      switch (type) {
        case AdjustmentType.add:
          await _inventoryDao.addToInventory(
            productId, warehouseId, quantity, 1, // userId = 1 مؤقتاً
            movementType: 'add',
            notes: note ?? 'إضافة يدوية',
          );
          break;
        case AdjustmentType.subtract:
          await _inventoryDao.subtractFromInventory(
            productId,
            warehouseId,
            quantity,
            1,
            movementType: 'subtract',
            notes: note ?? 'خصم يدوي',
          );
          break;
        case AdjustmentType.set:
        case AdjustmentType.count:
          // تعيين الكمية مباشرة
          await _inventoryDao.adjustInventory(
            productId,
            warehouseId,
            newStock,
            1,
            notes: note ?? 'جرد المخزون',
          );
          break;
      }

      await loadInventory();
    } catch (e) {
      rethrow;
    }
  }

  String _getMovementTypeText(String type) {
    switch (type) {
      case 'add':
        return 'إضافة يدوية';
      case 'subtract':
        return 'خصم يدوي';
      case 'set':
        return 'تعيين الكمية';
      case 'count':
        return 'جرد';
      case 'sale':
        return 'بيع';
      case 'purchase':
        return 'شراء';
      case 'return':
        return 'مرتجع';
      case 'adjustment':
        return 'تعديل';
      default:
        return type;
    }
  }
}

/// مزود المخزون
final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  final productDao = GetIt.instance<ProductsDao>();
  final inventoryDao = GetIt.instance<InventoryDao>();
  final categoryDao = GetIt.instance<CategoriesDao>();
  return InventoryNotifier(productDao, inventoryDao, categoryDao);
});

/// مزود عدد تنبيهات المخزون
final inventoryAlertsCountProvider = Provider<int>((ref) {
  final state = ref.watch(inventoryProvider);
  return state.lowStockProducts.length + state.outOfStockProducts.length;
});
