import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/categories_dao.dart';
import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/database.dart';

/// عنصر فئة
class CategoryItem {
  final int id;
  final String name;
  final String? description;
  final String color;
  final String icon;
  final int productsCount;
  final bool isActive;
  final int sortOrder;

  CategoryItem({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.icon,
    required this.productsCount,
    required this.isActive,
    required this.sortOrder,
  });
}

/// حالة الفئات
class CategoriesState {
  final bool isLoading;
  final List<CategoryItem> categories;
  final String searchQuery;
  final String sortBy;

  const CategoriesState({
    this.isLoading = false,
    this.categories = const [],
    this.searchQuery = '',
    this.sortBy = 'custom',
  });

  List<CategoryItem> get filteredCategories {
    var result = categories.toList();

    // البحث
    if (searchQuery.isNotEmpty) {
      result = result.where((c) {
        return c.name.contains(searchQuery) ||
            (c.description?.contains(searchQuery) ?? false);
      }).toList();
    }

    // الترتيب
    switch (sortBy) {
      case 'name':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'products':
        result.sort((a, b) => b.productsCount.compareTo(a.productsCount));
        break;
      case 'custom':
      default:
        result.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return result;
  }

  CategoriesState copyWith({
    bool? isLoading,
    List<CategoryItem>? categories,
    String? searchQuery,
    String? sortBy,
  }) {
    return CategoriesState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// مدير الفئات
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final CategoriesDao _categoryDao;
  final ProductsDao _productDao;

  CategoriesNotifier(this._categoryDao, this._productDao)
      : super(const CategoriesState());

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true);

    try {
      final categories = await _categoryDao.getAllCategories();
      final items = <CategoryItem>[];

      for (final category in categories) {
        final products = await _productDao.getProductsByCategory(category.id);

        items.add(CategoryItem(
          id: category.id,
          name: category.name,
          description: category.description,
          color: category.color ?? '#4A90D9',
          icon: category.icon ?? 'category',
          productsCount: products.length,
          isActive: category.isActive,
          sortOrder: category.sortOrder,
        ));
      }

      state = state.copyWith(
        categories: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortBy(String sort) {
    state = state.copyWith(sortBy: sort);
  }

  Future<void> addCategory({
    required String name,
    String? description,
    required String color,
    required String icon,
  }) async {
    try {
      final maxOrder = state.categories.isEmpty
          ? 0
          : state.categories
              .map((c) => c.sortOrder)
              .reduce((a, b) => a > b ? a : b);

      await _categoryDao.insertCategory(
        CategoriesCompanion.insert(
          name: name,
          description: Value(description),
          color: Value(color),
          icon: Value(icon),
          sortOrder: Value(maxOrder + 1),
          isActive: const Value(true),
        ),
      );

      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    String? description,
    required String color,
    required String icon,
  }) async {
    try {
      final existing = await _categoryDao.getCategoryById(id);
      if (existing != null) {
        await _categoryDao.updateCategory(
          existing.copyWith(
            name: name,
            description: Value(description),
            color: Value(color),
            icon: Value(icon),
          ),
        );
        await loadCategories();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _categoryDao.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleActive(int id) async {
    try {
      final category = await _categoryDao.getCategoryById(id);
      if (category != null) {
        await _categoryDao.updateCategory(
          category.copyWith(isActive: !category.isActive),
        );
        await loadCategories();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final categories = state.filteredCategories.toList();
    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);

    // تحديث الترتيب
    for (var i = 0; i < categories.length; i++) {
      final category = await _categoryDao.getCategoryById(categories[i].id);
      if (category != null) {
        await _categoryDao.updateCategory(
          category.copyWith(sortOrder: i),
        );
      }
    }

    await loadCategories();
  }
}

/// مزود الفئات
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  final categoryDao = GetIt.instance<CategoriesDao>();
  final productDao = GetIt.instance<ProductsDao>();
  return CategoriesNotifier(categoryDao, productDao);
});

/// مزود قائمة الفئات للاختيار
final categoryListProvider = FutureProvider<List<CategoryItem>>((ref) async {
  final categoryDao = GetIt.instance<CategoriesDao>();
  final productDao = GetIt.instance<ProductsDao>();

  final categories = await categoryDao.getActiveCategories();
  final items = <CategoryItem>[];

  for (final category in categories) {
    final products = await productDao.getProductsByCategory(category.id);

    items.add(CategoryItem(
      id: category.id,
      name: category.name,
      description: category.description,
      color: category.color ?? '#4A90D9',
      icon: category.icon ?? 'category',
      productsCount: products.length,
      isActive: category.isActive,
      sortOrder: category.sortOrder,
    ));
  }

  return items;
});
