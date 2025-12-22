// lib/features/products/providers/product_provider.dart
// مزود حالة المنتجات

import 'dart:io';
import 'package:hoor_manager/features/products/models/product_model.dart';
import 'package:hoor_manager/features/products/services/product_service.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../../../core/services/logger_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  // Getters
  List<ProductModel> get products => _getFilteredProducts();
  List<ProductModel> get allProducts => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  /// المنتجات المفلترة
  List<ProductModel> _getFilteredProducts() {
    var filtered = _products.where((p) => p.isActive).toList();

    // فلترة حسب الفئة
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered = filtered
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // فلترة حسب البحث
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.brand.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  /// المنتجات منخفضة المخزون
  List<ProductModel> get lowStockProducts {
    return _products.where((p) => p.isActive && p.isLowStock()).toList();
  }

  /// المنتجات نفذت من المخزون
  List<ProductModel> get outOfStockProducts {
    return _products.where((p) => p.isActive && p.isOutOfStock).toList();
  }

  /// تحميل المنتجات
  Future<void> loadProducts() async {
    AppLogger.startOperation('تحميل المنتجات');
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _productService.getAllProducts();

    if (result.success) {
      _products = result.data!;
      _error = null;
      AppLogger.i('✅ تم تحميل ${_products.length} منتج');
    } else {
      _error = result.error;
      AppLogger.e('❌ فشل تحميل المنتجات', error: result.error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تحميل الفئات
  Future<void> loadCategories() async {
    final result = await _categoryService.getAllCategories();

    if (result.success) {
      _categories = result.data!;
    }

    notifyListeners();
  }

  /// تحميل كل البيانات
  Future<void> loadAll() async {
    await Future.wait([loadProducts(), loadCategories()]);
  }

  /// إضافة منتج
  Future<bool> addProduct(ProductModel product, {File? imageFile}) async {
    AppLogger.startOperation('إضافة منتج: ${product.name}');
    _error = null;

    final result = await _productService.addProduct(product);

    if (result.success) {
      // رفع الصورة إذا وجدت
      if (imageFile != null) {
        await _productService.uploadProductImage(result.data!.id, imageFile);
      }
      await loadProducts();
      AppLogger.endOperation('إضافة منتج: ${product.name}', success: true);
      return true;
    } else {
      _error = result.error;
      AppLogger.endOperation('إضافة منتج: ${product.name}', success: false);
      notifyListeners();
      return false;
    }
  }

  /// تحديث منتج
  Future<bool> updateProduct(ProductModel product, {File? imageFile}) async {
    _error = null;

    final result = await _productService.updateProduct(product);

    if (result.success) {
      // رفع الصورة إذا وجدت
      if (imageFile != null) {
        await _productService.uploadProductImage(product.id, imageFile);
      }
      await loadProducts();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  /// حذف منتج
  Future<bool> deleteProduct(String productId) async {
    _error = null;

    final result = await _productService.deleteProduct(productId);

    if (result.success) {
      await loadProducts();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  /// تحديث المخزون
  Future<bool> updateInventory(
    String productId,
    String color,
    int size,
    int quantity,
  ) async {
    _error = null;

    final result = await _productService.updateInventory(
      productId,
      color,
      size,
      quantity,
    );

    if (result.success) {
      await loadProducts();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  /// البحث
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// اختيار فئة
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// مسح الفلاتر
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  /// الحصول على منتج بالـ ID
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// إضافة فئة
  Future<bool> addCategory(String name) async {
    final category = CategoryModel(
      id: '',
      name: name,
      order: _categories.length,
      createdAt: DateTime.now(),
    );

    final result = await _categoryService.addCategory(category);

    if (result.success) {
      await loadCategories();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  /// حذف فئة
  Future<bool> deleteCategory(String categoryId) async {
    final result = await _categoryService.deleteCategory(categoryId);

    if (result.success) {
      await loadCategories();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  /// مسح الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Stream للمنتجات (للتحديثات الفورية)
  void startListening() {
    _productService.streamProducts().listen((products) {
      _products = products;
      notifyListeners();
    });

    _categoryService.streamCategories().listen((categories) {
      _categories = categories;
      notifyListeners();
    });
  }
}
