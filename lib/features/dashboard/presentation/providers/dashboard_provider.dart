import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/invoices_dao.dart';
import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/daos/customers_dao.dart';
import '../../../../core/database/daos/inventory_dao.dart';
import '../../../../core/database/database.dart';

/// حالة لوحة التحكم
class DashboardState {
  final bool isLoading;
  final String? error;
  final double todaySales;
  final int todayInvoicesCount;
  final int productsCount;
  final int customersCount;
  final int lowStockCount;
  final double salesGrowth;
  final List<double> weeklySales;
  final List<RecentInvoice> recentInvoices;
  final List<TopProduct> topProducts;

  const DashboardState({
    this.isLoading = true,
    this.error,
    this.todaySales = 0,
    this.todayInvoicesCount = 0,
    this.productsCount = 0,
    this.customersCount = 0,
    this.lowStockCount = 0,
    this.salesGrowth = 0,
    this.weeklySales = const [],
    this.recentInvoices = const [],
    this.topProducts = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    double? todaySales,
    int? todayInvoicesCount,
    int? productsCount,
    int? customersCount,
    int? lowStockCount,
    double? salesGrowth,
    List<double>? weeklySales,
    List<RecentInvoice>? recentInvoices,
    List<TopProduct>? topProducts,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      todaySales: todaySales ?? this.todaySales,
      todayInvoicesCount: todayInvoicesCount ?? this.todayInvoicesCount,
      productsCount: productsCount ?? this.productsCount,
      customersCount: customersCount ?? this.customersCount,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      salesGrowth: salesGrowth ?? this.salesGrowth,
      weeklySales: weeklySales ?? this.weeklySales,
      recentInvoices: recentInvoices ?? this.recentInvoices,
      topProducts: topProducts ?? this.topProducts,
    );
  }
}

/// فاتورة حديثة
class RecentInvoice {
  final int id;
  final String number;
  final String? customerName;
  final double total;
  final String status;
  final DateTime date;

  const RecentInvoice({
    required this.id,
    required this.number,
    this.customerName,
    required this.total,
    required this.status,
    required this.date,
  });
}

/// منتج أكثر مبيعاً
class TopProduct {
  final int id;
  final String name;
  final double soldQuantity;
  final double totalSales;

  const TopProduct({
    required this.id,
    required this.name,
    required this.soldQuantity,
    required this.totalSales,
  });
}

/// مزود لوحة التحكم
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

/// مدير حالة لوحة التحكم
class DashboardNotifier extends StateNotifier<DashboardState> {
  final InvoicesDao _invoiceDao;
  final ProductsDao _productDao;
  final CustomersDao _customerDao;
  final InventoryDao _inventoryDao;

  DashboardNotifier()
      : _invoiceDao = GetIt.I<InvoicesDao>(),
        _productDao = GetIt.I<ProductsDao>(),
        _customerDao = GetIt.I<CustomersDao>(),
        _inventoryDao = GetIt.I<InventoryDao>(),
        super(const DashboardState()) {
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // تحميل البيانات بالتوازي
      final results = await Future.wait([
        _loadTodaySales(),
        _loadTodayInvoicesCount(),
        _loadProductsCount(),
        _loadCustomersCount(),
        _loadLowStockCount(),
        _loadWeeklySales(),
        _loadRecentInvoices(),
        _loadTopProducts(),
      ]);

      final todaySales = results[0] as double;
      final todayInvoicesCount = results[1] as int;
      final productsCount = results[2] as int;
      final customersCount = results[3] as int;
      final lowStockCount = results[4] as int;
      final weeklySales = results[5] as List<double>;
      final recentInvoices = results[6] as List<RecentInvoice>;
      final topProducts = results[7] as List<TopProduct>;

      // حساب نسبة النمو
      final salesGrowth = _calculateGrowth(weeklySales);

      state = state.copyWith(
        isLoading: false,
        todaySales: todaySales,
        todayInvoicesCount: todayInvoicesCount,
        productsCount: productsCount,
        customersCount: customersCount,
        lowStockCount: lowStockCount,
        salesGrowth: salesGrowth,
        weeklySales: weeklySales,
        recentInvoices: recentInvoices,
        topProducts: topProducts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل البيانات: $e',
      );
    }
  }

  Future<double> _loadTodaySales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final invoices =
        await _invoiceDao.getInvoicesByDateRange(startOfDay, endOfDay);
    return invoices
        .where((inv) => inv.status != 'cancelled')
        .fold<double>(0.0, (sum, inv) => sum + inv.total);
  }

  Future<int> _loadTodayInvoicesCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final invoices =
        await _invoiceDao.getInvoicesByDateRange(startOfDay, endOfDay);
    return invoices.where((inv) => inv.status != 'cancelled').length;
  }

  Future<int> _loadProductsCount() async {
    final products = await _productDao.getAllProducts();
    return products.where((p) => p.isActive).length;
  }

  Future<int> _loadCustomersCount() async {
    final customers = await _customerDao.getAllCustomers();
    return customers.where((c) => c.isActive).length;
  }

  Future<int> _loadLowStockCount() async {
    final inventory = await _inventoryDao.getLowStockProducts();
    return inventory.length;
  }

  Future<List<double>> _loadWeeklySales() async {
    final List<double> sales = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final invoices =
          await _invoiceDao.getInvoicesByDateRange(startOfDay, endOfDay);
      final daySales = invoices
          .where((inv) => inv.status != 'cancelled')
          .fold<double>(0.0, (sum, inv) => sum + inv.total);
      sales.add(daySales);
    }

    return sales;
  }

  Future<List<RecentInvoice>> _loadRecentInvoices() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final invoices =
        await _invoiceDao.getInvoicesByDateRange(startOfDay, endOfDay);

    // ترتيب حسب التاريخ (الأحدث أولاً)
    final sortedInvoices = invoices.toList()
      ..sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));

    return sortedInvoices.take(10).map((inv) {
      return RecentInvoice(
        id: inv.id,
        number: inv.invoiceNumber,
        customerName: null, // TODO: جلب اسم العميل
        total: inv.total,
        status: inv.status,
        date: inv.createdAt ?? DateTime.now(),
      );
    }).toList();
  }

  Future<List<TopProduct>> _loadTopProducts() async {
    // جلب المنتجات الأكثر مبيعاً من قاعدة البيانات
    final products = await _productDao.getAllProducts();

    // في الإصدار الحقيقي، يجب جلب إحصائيات المبيعات من جدول عناصر الفواتير
    // هذا تطبيق مبسط
    return products
        .take(5)
        .map((p) => TopProduct(
              id: p.id,
              name: p.name,
              soldQuantity: 0, // TODO: حساب من بيانات المبيعات الفعلية
              totalSales: 0,
            ))
        .toList();
  }

  double _calculateGrowth(List<double> weeklySales) {
    if (weeklySales.length < 2) return 0;

    // مقارنة آخر يومين
    final today = weeklySales.last;
    final yesterday = weeklySales[weeklySales.length - 2];

    if (yesterday == 0) return today > 0 ? 100 : 0;
    return ((today - yesterday) / yesterday) * 100;
  }

  Future<void> refresh() async {
    await _loadDashboard();
  }
}
