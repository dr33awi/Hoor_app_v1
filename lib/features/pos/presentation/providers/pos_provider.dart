import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/daos/categories_dao.dart';
import '../../../../core/database/daos/customers_dao.dart';
import '../../../../core/database/daos/invoices_dao.dart';
import '../../../../core/database/daos/shifts_dao.dart';
import '../../../../core/database/daos/inventory_dao.dart';
import '../../../../core/database/database.dart';
import '../../../../core/config/app_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// منتج في نقطة البيع
class PosProduct {
  final int id;
  final String name;
  final String? barcode;
  final double salePrice;
  final double costPrice;
  final double currentStock;
  final double minStock;
  final String? imageUrl;
  final int? categoryId;

  const PosProduct({
    required this.id,
    required this.name,
    this.barcode,
    required this.salePrice,
    required this.costPrice,
    required this.currentStock,
    required this.minStock,
    this.imageUrl,
    this.categoryId,
  });

  factory PosProduct.fromEntity(Product product, double stock) {
    return PosProduct(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      salePrice: product.salePrice,
      costPrice: product.costPrice,
      currentStock: stock,
      minStock: product.lowStockAlert.toDouble(),
      imageUrl: product.imagePath,
      categoryId: product.categoryId,
    );
  }
}

/// فئة في نقطة البيع
class PosCategory {
  final int id;
  final String name;
  final String? icon;

  const PosCategory({
    required this.id,
    required this.name,
    this.icon,
  });

  factory PosCategory.fromEntity(Category category) {
    return PosCategory(
      id: category.id,
      name: category.name,
      icon: category.icon,
    );
  }
}

/// عميل في نقطة البيع
class PosCustomer {
  final int id;
  final String name;
  final String? phone;
  final double balance;

  const PosCustomer({
    required this.id,
    required this.name,
    this.phone,
    this.balance = 0,
  });

  factory PosCustomer.fromEntity(Customer customer) {
    return PosCustomer(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      balance: customer.balance,
    );
  }
}

/// عنصر في السلة
class CartItem {
  final int productId;
  final String productName;
  final double unitPrice;
  final double costPrice;
  final int quantity;
  final double discount;
  final String? notes;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.costPrice,
    this.quantity = 1,
    this.discount = 0,
    this.notes,
  });

  double get subtotal => unitPrice * quantity;
  double get total => subtotal - discount;
  double get profit => (unitPrice - costPrice) * quantity - discount;

  CartItem copyWith({
    int? quantity,
    double? discount,
    String? notes,
  }) {
    return CartItem(
      productId: productId,
      productName: productName,
      unitPrice: unitPrice,
      costPrice: costPrice,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
    );
  }
}

/// فاتورة معلقة
class HeldInvoice {
  final String id;
  final List<CartItem> items;
  final PosCustomer? customer;
  final double invoiceDiscount;
  final String note;
  final DateTime createdAt;

  const HeldInvoice({
    required this.id,
    required this.items,
    this.customer,
    this.invoiceDiscount = 0,
    this.note = '',
    required this.createdAt,
  });

  double get total {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
    return subtotal - invoiceDiscount;
  }
}

/// وردية نشطة
class ActiveShift {
  final int id;
  final double openingCash;
  final DateTime startTime;

  const ActiveShift({
    required this.id,
    required this.openingCash,
    required this.startTime,
  });
}

/// حالة نقطة البيع
class PosState {
  final bool isLoading;
  final String? error;
  final List<PosProduct> products;
  final List<PosProduct> filteredProducts;
  final List<PosCategory> categories;
  final List<CartItem> cart;
  final List<HeldInvoice> heldInvoices;
  final int? selectedCategoryId;
  final String searchQuery;
  final PosCustomer? selectedCustomer;
  final double invoiceDiscount;
  final ActiveShift? currentShift;

  const PosState({
    this.isLoading = true,
    this.error,
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.cart = const [],
    this.heldInvoices = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.selectedCustomer,
    this.invoiceDiscount = 0,
    this.currentShift,
  });

  // حسابات السلة
  double get subtotal => cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get itemsDiscount =>
      cart.fold(0.0, (sum, item) => sum + item.discount);
  double get totalDiscount => itemsDiscount + invoiceDiscount;
  double get tax => (subtotal - totalDiscount) * AppConfig.defaultTaxRate;
  double get total => subtotal - totalDiscount + tax;
  double get totalProfit =>
      cart.fold(0.0, (sum, item) => sum + item.profit) - invoiceDiscount;

  PosState copyWith({
    bool? isLoading,
    String? error,
    List<PosProduct>? products,
    List<PosProduct>? filteredProducts,
    List<PosCategory>? categories,
    List<CartItem>? cart,
    List<HeldInvoice>? heldInvoices,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    PosCustomer? selectedCustomer,
    bool clearCustomer = false,
    double? invoiceDiscount,
    ActiveShift? currentShift,
    bool clearShift = false,
  }) {
    return PosState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      cart: cart ?? this.cart,
      heldInvoices: heldInvoices ?? this.heldInvoices,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCustomer:
          clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      invoiceDiscount: invoiceDiscount ?? this.invoiceDiscount,
      currentShift: clearShift ? null : (currentShift ?? this.currentShift),
    );
  }
}

/// نتيجة الدفع
class CheckoutResult {
  final bool success;
  final String paymentMethod;
  final double receivedAmount;
  final String? notes;

  const CheckoutResult({
    required this.success,
    required this.paymentMethod,
    required this.receivedAmount,
    this.notes,
  });
}

/// مزود نقطة البيع
final posProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  return PosNotifier(ref);
});

/// مدير حالة نقطة البيع
class PosNotifier extends StateNotifier<PosState> {
  final Ref _ref;
  final ProductsDao _productDao;
  final CategoriesDao _categoryDao;
  final CustomersDao _customerDao;
  final InvoicesDao _invoiceDao;
  final ShiftsDao _shiftDao;
  final InventoryDao _inventoryDao;

  PosNotifier(this._ref)
      : _productDao = GetIt.I<ProductsDao>(),
        _categoryDao = GetIt.I<CategoriesDao>(),
        _customerDao = GetIt.I<CustomersDao>(),
        _invoiceDao = GetIt.I<InvoicesDao>(),
        _shiftDao = GetIt.I<ShiftsDao>(),
        _inventoryDao = GetIt.I<InventoryDao>(),
        super(const PosState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // تحميل البيانات بالتوازي
      final results = await Future.wait([
        _loadProducts(),
        _loadCategories(),
        _checkActiveShift(),
      ]);

      final products = results[0] as List<PosProduct>;
      final categories = results[1] as List<PosCategory>;
      final activeShift = results[2] as ActiveShift?;

      state = state.copyWith(
        isLoading: false,
        products: products,
        filteredProducts: products,
        categories: categories,
        currentShift: activeShift,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل البيانات: $e',
      );
    }
  }

  Future<List<PosProduct>> _loadProducts() async {
    final products = await _productDao.getAllProducts();
    final activeProducts = products.where((p) => p.isActive).toList();

    final posProducts = <PosProduct>[];
    for (final product in activeProducts) {
      // جلب الكمية المتاحة من المخزون
      final inventory = await _inventoryDao.getProductInventoryAll(product.id);
      final stock =
          inventory.fold<double>(0.0, (sum, inv) => sum + inv.quantity);
      posProducts.add(PosProduct.fromEntity(product, stock));
    }

    return posProducts;
  }

  Future<List<PosCategory>> _loadCategories() async {
    final categories = await _categoryDao.getAllCategories();
    return categories
        .where((c) => c.isActive)
        .map((c) => PosCategory.fromEntity(c))
        .toList();
  }

  Future<ActiveShift?> _checkActiveShift() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return null;

    final activeShift = await _shiftDao.getOpenShift(user.id);
    if (activeShift != null) {
      return ActiveShift(
        id: activeShift.id,
        openingCash: activeShift.openingBalance,
        startTime: activeShift.startTime,
      );
    }
    return null;
  }

  // === فلترة المنتجات ===

  void searchProducts(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void searchByBarcode(String barcode) {
    final product = state.products.firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => const PosProduct(
        id: -1,
        name: '',
        salePrice: 0,
        costPrice: 0,
        currentStock: 0,
        minStock: 0,
      ),
    );

    if (product.id != -1) {
      addToCart(product);
    }
  }

  void selectCategory(int? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    );
    _applyFilters();
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.products.toList();

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

    state = state.copyWith(filteredProducts: filtered);
  }

  // === إدارة السلة ===

  void addToCart(PosProduct product) {
    final existingIndex =
        state.cart.indexWhere((item) => item.productId == product.id);

    if (existingIndex != -1) {
      // زيادة الكمية
      final newCart = List<CartItem>.from(state.cart);
      final existing = newCart[existingIndex];
      newCart[existingIndex] =
          existing.copyWith(quantity: existing.quantity + 1);
      state = state.copyWith(cart: newCart);
    } else {
      // إضافة عنصر جديد
      final newItem = CartItem(
        productId: product.id,
        productName: product.name,
        unitPrice: product.salePrice,
        costPrice: product.costPrice,
      );
      state = state.copyWith(cart: [...state.cart, newItem]);
    }
  }

  void removeFromCart(int productId) {
    state = state.copyWith(
      cart: state.cart.where((item) => item.productId != productId).toList(),
    );
  }

  void incrementQuantity(int productId) {
    final newCart = state.cart.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    state = state.copyWith(cart: newCart);
  }

  void decrementQuantity(int productId) {
    final newCart = <CartItem>[];
    for (final item in state.cart) {
      if (item.productId == productId) {
        if (item.quantity > 1) {
          newCart.add(item.copyWith(quantity: item.quantity - 1));
        }
        // إذا كانت الكمية 1، لا نضيفه (يُحذف)
      } else {
        newCart.add(item);
      }
    }
    state = state.copyWith(cart: newCart);
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final newCart = state.cart.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
    state = state.copyWith(cart: newCart);
  }

  void updateItemDiscount(int productId, double discount) {
    final newCart = state.cart.map((item) {
      if (item.productId == productId) {
        return item.copyWith(discount: discount);
      }
      return item;
    }).toList();
    state = state.copyWith(cart: newCart);
  }

  void clearCart() {
    state = state.copyWith(
      cart: [],
      invoiceDiscount: 0,
      clearCustomer: true,
    );
  }

  // === العميل ===

  void selectCustomer(PosCustomer customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void clearCustomer() {
    state = state.copyWith(clearCustomer: true);
  }

  // === الخصومات ===

  void applyInvoiceDiscount(double value, bool isPercentage) {
    double discount;
    if (isPercentage) {
      discount = state.subtotal * (value / 100);
    } else {
      discount = value;
    }
    state = state.copyWith(invoiceDiscount: discount);
  }

  // === الفواتير المعلقة ===

  void holdInvoice(String note) {
    if (state.cart.isEmpty) return;

    final held = HeldInvoice(
      id: const Uuid().v4(),
      items: List.from(state.cart),
      customer: state.selectedCustomer,
      invoiceDiscount: state.invoiceDiscount,
      note: note,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      heldInvoices: [...state.heldInvoices, held],
      cart: [],
      invoiceDiscount: 0,
      clearCustomer: true,
    );
  }

  void resumeHeldInvoice(String id) {
    final held = state.heldInvoices.firstWhere((h) => h.id == id);

    state = state.copyWith(
      cart: held.items,
      selectedCustomer: held.customer,
      invoiceDiscount: held.invoiceDiscount,
      heldInvoices: state.heldInvoices.where((h) => h.id != id).toList(),
    );
  }

  void deleteHeldInvoice(String id) {
    state = state.copyWith(
      heldInvoices: state.heldInvoices.where((h) => h.id != id).toList(),
    );
  }

  // === الوردية ===

  Future<void> openShift(double openingCash) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final shiftId = await _shiftDao.openShift(user.id, openingCash);

    state = state.copyWith(
      currentShift: ActiveShift(
        id: shiftId,
        openingCash: openingCash,
        startTime: DateTime.now(),
      ),
    );
  }

  Future<void> closeShift(double closingCash, String? notes) async {
    if (state.currentShift == null) return;

    await _shiftDao.closeShift(
      state.currentShift!.id,
      closingCash,
      notes: notes,
    );

    state = state.copyWith(clearShift: true);
  }

  // === إتمام البيع ===

  Future<void> completeSale({
    required String paymentMethod,
    required double receivedAmount,
    String? notes,
  }) async {
    if (state.cart.isEmpty || state.currentShift == null) return;

    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    // إنشاء رقم فاتورة فريد
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

    // حفظ الفاتورة
    final invoiceId = await _invoiceDao.insertInvoice(InvoicesCompanion.insert(
      invoiceNumber: invoiceNumber,
      type: 'sale',
      customerId: Value(state.selectedCustomer?.id),
      userId: user.id,
      shiftId: Value(state.currentShift!.id),
      invoiceDate: DateTime.now(),
      subtotal: state.subtotal,
      discountAmount: Value(state.totalDiscount),
      taxAmount: Value(state.tax),
      total: state.total,
      paymentMethod: Value(paymentMethod),
      paidAmount: Value(receivedAmount),
      status: Value('closed'),
      notes: Value(notes),
      createdAt: Value(DateTime.now()),
    ));

    // حفظ عناصر الفاتورة
    for (final item in state.cart) {
      await _invoiceDao.insertInvoiceItem(InvoiceItemsCompanion.insert(
        invoiceId: invoiceId,
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity.toDouble(),
        unitPrice: item.unitPrice,
        costPrice: Value(item.costPrice),
        discountAmount: Value(item.discount),
        total: item.total,
      ));

      // تحديث المخزون - خصم الكمية المباعة
      final defaultWarehouse = await _inventoryDao.getDefaultWarehouse();
      if (defaultWarehouse != null) {
        await _inventoryDao.subtractFromInventory(
          item.productId,
          defaultWarehouse.id,
          item.quantity.toDouble(),
          user.id,
          movementType: 'sale',
          referenceId: invoiceId,
          referenceType: 'invoice',
          notes: 'بيع - فاتورة $invoiceNumber',
        );
      }
    }

    // مسح السلة
    clearCart();

    // إعادة تحميل المنتجات لتحديث المخزون
    final products = await _loadProducts();
    state = state.copyWith(products: products, filteredProducts: products);
  }

  // === تحديث ===

  Future<void> refresh() async {
    await _initialize();
  }
}
