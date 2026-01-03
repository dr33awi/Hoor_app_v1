import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/invoices_dao.dart';
import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/daos/inventory_dao.dart';

/// عنصر مرتجع
class ReturnItemData {
  final int productId;
  final String productName;
  final int quantity;
  final double price;

  ReturnItemData({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });
}

/// عنصر مرتجع مكتمل
class ReturnItem {
  final int id;
  final int invoiceId;
  final DateTime date;
  final List<ReturnItemData> items;
  final String? reason;

  ReturnItem({
    required this.id,
    required this.invoiceId,
    required this.date,
    required this.items,
    this.reason,
  });

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get total =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}

/// عنصر منتج من فاتورة
class InvoiceItemForReturn {
  final int id;
  final int productId;
  final String name;
  final int quantity;
  final double price;

  InvoiceItemForReturn({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });
}

/// فاتورة للإرجاع
class InvoiceForReturn {
  final int id;
  final DateTime date;
  final double total;
  final List<InvoiceItemForReturn> items;

  InvoiceForReturn({
    required this.id,
    required this.date,
    required this.total,
    required this.items,
  });
}

/// حالة المرتجعات
class ReturnsState {
  final List<ReturnItem> returns;
  final bool isLoading;
  final String searchQuery;
  final String dateFilter;

  ReturnsState({
    this.returns = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.dateFilter = 'all',
  });

  ReturnsState copyWith({
    List<ReturnItem>? returns,
    bool? isLoading,
    String? searchQuery,
    String? dateFilter,
  }) {
    return ReturnsState(
      returns: returns ?? this.returns,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      dateFilter: dateFilter ?? this.dateFilter,
    );
  }

  List<ReturnItem> get filteredReturns {
    var filtered = returns;

    // تصفية بالبحث
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.id.toString().contains(searchQuery) ||
            r.invoiceId.toString().contains(searchQuery);
      }).toList();
    }

    // تصفية بالتاريخ
    final now = DateTime.now();
    switch (dateFilter) {
      case 'today':
        filtered = filtered.where((r) {
          return r.date.year == now.year &&
              r.date.month == now.month &&
              r.date.day == now.day;
        }).toList();
        break;
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filtered = filtered.where((r) {
          return r.date.isAfter(weekStart.subtract(const Duration(days: 1)));
        }).toList();
        break;
      case 'month':
        filtered = filtered.where((r) {
          return r.date.year == now.year && r.date.month == now.month;
        }).toList();
        break;
    }

    return filtered;
  }

  double get totalReturnsValue => returns.fold(0.0, (sum, r) => sum + r.total);
}

/// مزود المرتجعات
class ReturnsNotifier extends StateNotifier<ReturnsState> {
  final InvoicesDao _invoicesDao;
  final ProductsDao _productsDao;
  final InventoryDao _inventoryDao;

  // تخزين المرتجعات محلياً (في الإنتاج ستكون في قاعدة البيانات)
  static final List<ReturnItem> _localReturns = [];
  static int _nextId = 1;

  ReturnsNotifier(this._invoicesDao, this._productsDao, this._inventoryDao)
      : super(ReturnsState());

  Future<void> loadReturns() async {
    state = state.copyWith(isLoading: true);

    try {
      // جلب المرتجعات من التخزين المحلي
      state = state.copyWith(
        returns: List.from(_localReturns),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDateFilter(String filter) {
    state = state.copyWith(dateFilter: filter);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      dateFilter: 'all',
    );
  }

  Future<InvoiceForReturn?> getInvoiceForReturn(int invoiceId) async {
    try {
      final invoice = await _invoicesDao.getInvoiceById(invoiceId);
      if (invoice == null) return null;

      final items = await _invoicesDao.getInvoiceItems(invoiceId);
      final invoiceItems = <InvoiceItemForReturn>[];

      for (final itemWithProduct in items) {
        final item = itemWithProduct.item;
        final product = await _productsDao.getProductById(item.productId);
        if (product != null) {
          invoiceItems.add(InvoiceItemForReturn(
            id: item.id,
            productId: item.productId,
            name: product.name,
            quantity: item.quantity.toInt(),
            price: item.unitPrice,
          ));
        }
      }

      return InvoiceForReturn(
        id: invoice.id,
        date: invoice.createdAt ?? DateTime.now(),
        total: invoice.total,
        items: invoiceItems,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> createReturn({
    required int invoiceId,
    required List<ReturnItemData> items,
    required String reason,
  }) async {
    try {
      // إنشاء المرتجع
      final returnItem = ReturnItem(
        id: _nextId++,
        invoiceId: invoiceId,
        date: DateTime.now(),
        items: items,
        reason: reason.isNotEmpty ? reason : null,
      );

      // إرجاع المخزون
      for (final item in items) {
        // جلب المخزون الحالي للمنتج
        final inventories =
            await _inventoryDao.getProductInventoryAll(item.productId);
        if (inventories.isNotEmpty) {
          final inventory = inventories.first;
          final newQuantity = inventory.quantity + item.quantity.toDouble();
          await _inventoryDao.upsertInventory(
            item.productId,
            inventory.warehouseId,
            newQuantity,
          );
        }
      }

      // حفظ المرتجع
      _localReturns.insert(0, returnItem);
      state = state.copyWith(returns: List.from(_localReturns));
    } catch (e) {
      // معالجة الخطأ
    }
  }
}

/// مزود المرتجعات
final returnsProvider =
    StateNotifierProvider<ReturnsNotifier, ReturnsState>((ref) {
  final invoicesDao = GetIt.instance<InvoicesDao>();
  final productsDao = GetIt.instance<ProductsDao>();
  final inventoryDao = GetIt.instance<InventoryDao>();
  return ReturnsNotifier(invoicesDao, productsDao, inventoryDao);
});
