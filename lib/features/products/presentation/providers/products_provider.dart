import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/daos/categories_dao.dart';
import '../../../../core/database/daos/inventory_dao.dart';
import '../../../../core/database/database.dart';

/// عنصر منتج
class ProductItem {
  final int id;
  final String name;
  final String? barcode;
  final double salePrice;
  final double costPrice;
  final double stock;
  final double minStock;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;
  final bool isActive;

  const ProductItem({
    required this.id,
    required this.name,
    this.barcode,
    required this.salePrice,
    required this.costPrice,
    required this.stock,
    required this.minStock,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    required this.isActive,
  });
}

/// فئة
class CategoryItem {
  final int id;
  final String name;
  final int productCount;

  const CategoryItem({
    required this.id,
    required this.name,
    this.productCount = 0,
  });
}

/// فلاتر المنتجات
class ProductFilters {
  final bool showActive;
  final bool showInactive;
  final bool lowStockOnly;
  final double minPrice;
  final double maxPrice;

  const ProductFilters({
    this.showActive = true,
    this.showInactive = false,
    this.lowStockOnly = false,
    this.minPrice = 0,
    this.maxPrice = double.infinity,
  });
}

/// حالة المنتجات
class ProductsState {
  final bool isLoading;
  final String? error;
  final List<ProductItem> products;
  final List<ProductItem> filteredProducts;
  final List<CategoryItem> categories;
  final int? selectedCategoryId;
  final String searchQuery;
  final String sortBy;
  final ProductFilters filters;

  const ProductsState({
    this.isLoading = true,
    this.error,
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.sortBy = 'name',
    this.filters = const ProductFilters(),
  });

  ProductsState copyWith({
    bool? isLoading,
    String? error,
    List<ProductItem>? products,
    List<ProductItem>? filteredProducts,
    List<CategoryItem>? categories,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    String? sortBy,
    ProductFilters? filters,
  }) {
    return ProductsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      filters: filters ?? this.filters,
    );
  }
}

/// مزود المنتجات
final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier();
});

/// مدير حالة المنتجات
class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductsDao _productDao;
  final CategoriesDao _categoryDao;
  final InventoryDao _inventoryDao;

  ProductsNotifier()
      : _productDao = GetIt.I<ProductsDao>(),
        _categoryDao = GetIt.I<CategoriesDao>(),
        _inventoryDao = GetIt.I<InventoryDao>(),
        super(const ProductsState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final results = await Future.wait([
        _loadProducts(),
        _loadCategories(),
      ]);

      final products = results[0] as List<ProductItem>;
      final categories = results[1] as List<CategoryItem>;

      state = state.copyWith(
        isLoading: false,
        products: products,
        filteredProducts: products,
        categories: categories,
      );

      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل المنتجات: $e',
      );
    }
  }

  Future<List<ProductItem>> _loadProducts() async {
    final products = await _productDao.getAllProducts();
    final categories = await _categoryDao.getAllCategories();

    final categoryMap = {for (var c in categories) c.id: c.name};

    final productItems = <ProductItem>[];
    for (final product in products) {
      final inventory = await _inventoryDao.getProductInventoryAll(product.id);
      final stock =
          inventory.fold<double>(0.0, (sum, inv) => sum + inv.quantity);

      productItems.add(ProductItem(
        id: product.id,
        name: product.name,
        barcode: product.barcode,
        salePrice: product.salePrice,
        costPrice: product.costPrice,
        stock: stock,
        minStock: product.lowStockAlert.toDouble(),
        imageUrl: product.imagePath,
        categoryId: product.categoryId,
        categoryName:
            product.categoryId != null ? categoryMap[product.categoryId] : null,
        isActive: product.isActive,
      ));
    }

    return productItems;
  }

  Future<List<CategoryItem>> _loadCategories() async {
    final categories = await _categoryDao.getAllCategories();
    final products = await _productDao.getAllProducts();

    return categories.where((c) => c.isActive).map((c) {
      final count = products.where((p) => p.categoryId == c.id).length;
      return CategoryItem(
        id: c.id,
        name: c.name,
        productCount: count,
      );
    }).toList();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
    _applyFilters();
  }

  void selectCategory(int? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    );
    _applyFilters();
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    _applyFilters();
  }

  void applyFilters(ProductFilters filters) {
    state = state.copyWith(filters: filters);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.products.toList();

    // فلترة حسب الحالة
    filtered = filtered.where((p) {
      if (p.isActive && state.filters.showActive) return true;
      if (!p.isActive && state.filters.showInactive) return true;
      return false;
    }).toList();

    // فلترة حسب المخزون المنخفض
    if (state.filters.lowStockOnly) {
      filtered = filtered.where((p) => p.stock <= p.minStock).toList();
    }

    // فلترة حسب السعر
    filtered = filtered.where((p) {
      return p.salePrice >= state.filters.minPrice &&
          p.salePrice <= state.filters.maxPrice;
    }).toList();

    // فلترة حسب الفئة
    if (state.selectedCategoryId != null) {
      filtered = filtered
          .where((p) => p.categoryId == state.selectedCategoryId)
          .toList();
    }

    // فلترة حسب البحث
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            (p.barcode?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // الترتيب
    switch (state.sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price':
        filtered.sort((a, b) => a.salePrice.compareTo(b.salePrice));
        break;
      case 'stock':
        filtered.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'created':
        // الأحدث أولاً (حسب ID بشكل افتراضي)
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    state = state.copyWith(filteredProducts: filtered);
  }

  Future<void> deleteProduct(int id) async {
    await _productDao.deleteProduct(id);
    await _loadData();
  }

  Future<void> refresh() async {
    await _loadData();
  }
}

/// مزود منتج واحد
final productDetailProvider =
    FutureProvider.family<ProductItem?, int>((ref, id) async {
  final productDao = GetIt.I<ProductsDao>();
  final categoryDao = GetIt.I<CategoriesDao>();
  final inventoryDao = GetIt.I<InventoryDao>();

  final product = await productDao.getProductById(id);
  if (product == null) return null;

  final categories = await categoryDao.getAllCategories();
  final categoryMap = {for (var c in categories) c.id: c.name};

  final inventory = await inventoryDao.getProductInventoryAll(id);
  final stock = inventory.fold<double>(0.0, (sum, inv) => sum + inv.quantity);

  return ProductItem(
    id: product.id,
    name: product.name,
    barcode: product.barcode,
    salePrice: product.salePrice,
    costPrice: product.costPrice,
    stock: stock,
    minStock: product.lowStockAlert.toDouble(),
    imageUrl: product.imagePath,
    categoryId: product.categoryId,
    categoryName:
        product.categoryId != null ? categoryMap[product.categoryId] : null,
    isActive: product.isActive,
  );
});
