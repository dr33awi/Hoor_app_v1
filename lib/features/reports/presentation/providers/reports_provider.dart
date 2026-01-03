import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/invoices_dao.dart';
import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/daos/inventory_dao.dart';
import '../../../../core/database/daos/cash_dao.dart';
import '../../../../core/database/database.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/services/backup_service.dart';

/// بيانات المبيعات
class SalesChartData {
  final String label;
  final double value;

  const SalesChartData({required this.label, required this.value});
}

/// بيانات مبيعات المنتج
class ProductSalesData {
  final int id;
  final String name;
  final double quantity;
  final double sales;

  const ProductSalesData({
    required this.id,
    required this.name,
    required this.quantity,
    required this.sales,
  });
}

/// بيانات طريقة الدفع
class PaymentMethodData {
  final String method;
  final double amount;
  final double percentage;

  const PaymentMethodData({
    required this.method,
    required this.amount,
    required this.percentage,
  });
}

/// بيانات المخزون المنخفض
class LowStockData {
  final int id;
  final String name;
  final double stock;
  final double minStock;

  const LowStockData({
    required this.id,
    required this.name,
    required this.stock,
    required this.minStock,
  });
}

/// بيانات حركة الصندوق
class CashTransactionData {
  final String description;
  final double amount;
  final bool isIncome;
  final String date;

  const CashTransactionData({
    required this.description,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}

/// حالة التقارير
class ReportsState {
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? endDate;

  // ملخص
  final double totalSales;
  final double totalCost;
  final double grossProfit;
  final double expenses;
  final double netProfit;
  final double profitMargin;
  final int invoicesCount;
  final int cancelledCount;
  final double averageInvoice;
  final int productsSold;
  final double previousPeriodSales;
  final double salesGrowth;

  // بيانات الرسوم البيانية
  final List<SalesChartData> salesData;
  final List<double> hourlySales;
  final List<ProductSalesData> topProducts;
  final List<ProductSalesData> lowProducts;
  final List<PaymentMethodData> paymentMethods;
  final List<LowStockData> lowStockProducts;
  final List<CashTransactionData> cashTransactions;

  const ReportsState({
    this.isLoading = true,
    this.error,
    this.startDate,
    this.endDate,
    this.totalSales = 0,
    this.totalCost = 0,
    this.grossProfit = 0,
    this.expenses = 0,
    this.netProfit = 0,
    this.profitMargin = 0,
    this.invoicesCount = 0,
    this.cancelledCount = 0,
    this.averageInvoice = 0,
    this.productsSold = 0,
    this.previousPeriodSales = 0,
    this.salesGrowth = 0,
    this.salesData = const [],
    this.hourlySales = const [],
    this.topProducts = const [],
    this.lowProducts = const [],
    this.paymentMethods = const [],
    this.lowStockProducts = const [],
    this.cashTransactions = const [],
  });

  ReportsState copyWith({
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? endDate,
    double? totalSales,
    double? totalCost,
    double? grossProfit,
    double? expenses,
    double? netProfit,
    double? profitMargin,
    int? invoicesCount,
    int? cancelledCount,
    double? averageInvoice,
    int? productsSold,
    double? previousPeriodSales,
    double? salesGrowth,
    List<SalesChartData>? salesData,
    List<double>? hourlySales,
    List<ProductSalesData>? topProducts,
    List<ProductSalesData>? lowProducts,
    List<PaymentMethodData>? paymentMethods,
    List<LowStockData>? lowStockProducts,
    List<CashTransactionData>? cashTransactions,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalSales: totalSales ?? this.totalSales,
      totalCost: totalCost ?? this.totalCost,
      grossProfit: grossProfit ?? this.grossProfit,
      expenses: expenses ?? this.expenses,
      netProfit: netProfit ?? this.netProfit,
      profitMargin: profitMargin ?? this.profitMargin,
      invoicesCount: invoicesCount ?? this.invoicesCount,
      cancelledCount: cancelledCount ?? this.cancelledCount,
      averageInvoice: averageInvoice ?? this.averageInvoice,
      productsSold: productsSold ?? this.productsSold,
      previousPeriodSales: previousPeriodSales ?? this.previousPeriodSales,
      salesGrowth: salesGrowth ?? this.salesGrowth,
      salesData: salesData ?? this.salesData,
      hourlySales: hourlySales ?? this.hourlySales,
      topProducts: topProducts ?? this.topProducts,
      lowProducts: lowProducts ?? this.lowProducts,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      cashTransactions: cashTransactions ?? this.cashTransactions,
    );
  }
}

/// مزود التقارير
final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier();
});

/// مدير حالة التقارير
class ReportsNotifier extends StateNotifier<ReportsState> {
  final InvoicesDao _invoiceDao;
  final ProductsDao _productDao;
  final InventoryDao _inventoryDao;
  final CashDao _cashDao;

  ReportsNotifier()
      : _invoiceDao = GetIt.I<InvoicesDao>(),
        _productDao = GetIt.I<ProductsDao>(),
        _inventoryDao = GetIt.I<InventoryDao>(),
        _cashDao = GetIt.I<CashDao>(),
        super(const ReportsState()) {
    // تعيين الفترة الافتراضية (اليوم)
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    state = state.copyWith(startDate: startOfDay, endDate: now);
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final start =
          state.startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = state.endDate ?? DateTime.now();

      // جلب الفواتير
      final invoices = await _invoiceDao.getInvoicesByDateRange(
          start, end.add(const Duration(days: 1)));
      final closedInvoices =
          invoices.where((i) => i.status == 'closed').toList();
      final cancelledInvoices =
          invoices.where((i) => i.status == 'cancelled').toList();

      // حساب الإحصائيات
      final totalSales = closedInvoices.fold(0.0, (sum, i) => sum + i.total);
      final invoicesCount = closedInvoices.length;
      final averageInvoice =
          invoicesCount > 0 ? totalSales / invoicesCount : 0.0;

      // جلب تفاصيل المبيعات لحساب التكلفة والربح
      double totalCost = 0;
      int productsSold = 0;
      final productSalesMap = <int, ProductSalesData>{};

      for (final invoice in closedInvoices) {
        final items = await _invoiceDao.getInvoiceItems(invoice.id);
        for (final itemWithProduct in items) {
          final item = itemWithProduct.item;
          totalCost += item.costPrice * item.quantity;
          productsSold += item.quantity.toInt();

          // تجميع مبيعات المنتجات
          if (productSalesMap.containsKey(item.productId)) {
            final existing = productSalesMap[item.productId]!;
            productSalesMap[item.productId] = ProductSalesData(
              id: item.productId,
              name: existing.name,
              quantity: existing.quantity + item.quantity,
              sales: existing.sales + item.total,
            );
          } else {
            final product = await _productDao.getProductById(item.productId);
            productSalesMap[item.productId] = ProductSalesData(
              id: item.productId,
              name: product?.name ?? item.productName,
              quantity: item.quantity,
              sales: item.total,
            );
          }
        }
      }

      final grossProfit = totalSales - totalCost;

      // جلب المصروفات
      final cashTransactions = await _cashDao.getTransactionsByDateRange(
          start, end.add(const Duration(days: 1)));
      final expenses = cashTransactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);

      final netProfit = grossProfit - expenses;
      final profitMargin =
          totalSales > 0 ? (netProfit / totalSales) * 100 : 0.0;

      // المنتجات الأكثر مبيعاً
      final topProducts = productSalesMap.values.toList()
        ..sort((a, b) => b.sales.compareTo(a.sales));

      // المنتجات الأقل مبيعاً
      final lowProducts = productSalesMap.values.toList()
        ..sort((a, b) => a.sales.compareTo(b.sales));

      // طرق الدفع
      final paymentMethodsMap = <String, double>{};
      for (final invoice in closedInvoices) {
        paymentMethodsMap[invoice.paymentMethod] =
            (paymentMethodsMap[invoice.paymentMethod] ?? 0) + invoice.total;
      }
      final paymentMethods = paymentMethodsMap.entries.map((e) {
        return PaymentMethodData(
          method: e.key,
          amount: e.value,
          percentage: totalSales > 0 ? (e.value / totalSales) * 100 : 0,
        );
      }).toList();

      // بيانات الرسم البياني للمبيعات
      final salesData = await _buildSalesChartData(start, end);

      // المبيعات حسب الساعة
      final hourlySales = _buildHourlySales(closedInvoices);

      // المخزون المنخفض
      final lowStockProducts = await _loadLowStockProducts();

      // حركات الصندوق
      final cashTxData = cashTransactions
          .take(20)
          .map((t) => CashTransactionData(
                description: t.description ?? _getTransactionTypeText(t.type),
                amount: t.amount,
                isIncome: t.type == 'income' || t.type == 'sale',
                date:
                    '${(t.createdAt ?? DateTime.now()).day}/${(t.createdAt ?? DateTime.now()).month}',
              ))
          .toList();

      // مقارنة بالفترة السابقة
      final periodDays = end.difference(start).inDays + 1;
      final previousStart = start.subtract(Duration(days: periodDays));
      final previousEnd = start.subtract(const Duration(days: 1));
      final previousInvoices =
          await _invoiceDao.getInvoicesByDateRange(previousStart, previousEnd);
      final previousSales = previousInvoices
          .where((i) => i.status == 'closed')
          .fold(0.0, (sum, i) => sum + i.total);

      final salesGrowth = previousSales > 0
          ? ((totalSales - previousSales) / previousSales) * 100
          : (totalSales > 0 ? 100.0 : 0.0);

      state = state.copyWith(
        isLoading: false,
        totalSales: totalSales,
        totalCost: totalCost,
        grossProfit: grossProfit,
        expenses: expenses,
        netProfit: netProfit,
        profitMargin: profitMargin,
        invoicesCount: invoicesCount,
        cancelledCount: cancelledInvoices.length,
        averageInvoice: averageInvoice,
        productsSold: productsSold,
        previousPeriodSales: previousSales,
        salesGrowth: salesGrowth,
        salesData: salesData,
        hourlySales: hourlySales,
        topProducts: topProducts,
        lowProducts: lowProducts,
        paymentMethods: paymentMethods,
        lowStockProducts: lowStockProducts,
        cashTransactions: cashTxData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل التقارير: $e',
      );
    }
  }

  Future<List<SalesChartData>> _buildSalesChartData(
      DateTime start, DateTime end) async {
    final data = <SalesChartData>[];
    final days = end.difference(start).inDays + 1;

    // إذا كانت الفترة أسبوع أو أقل، نعرض حسب الأيام
    if (days <= 7) {
      for (int i = 0; i < days; i++) {
        final date = start.add(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        final invoices =
            await _invoiceDao.getInvoicesByDateRange(dayStart, dayEnd);
        final sales = invoices
            .where((i) => i.status == 'closed')
            .fold(0.0, (sum, i) => sum + i.total);

        data.add(SalesChartData(
          label: _getDayName(date.weekday),
          value: sales,
        ));
      }
    } else {
      // إذا كانت الفترة أطول، نعرض حسب الأسابيع أو الأشهر
      // تبسيط: عرض آخر 7 أيام
      for (int i = 6; i >= 0; i--) {
        final date = end.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        final invoices =
            await _invoiceDao.getInvoicesByDateRange(dayStart, dayEnd);
        final sales = invoices
            .where((i) => i.status == 'closed')
            .fold(0.0, (sum, i) => sum + i.total);

        data.add(SalesChartData(
          label: _getDayName(date.weekday),
          value: sales,
        ));
      }
    }

    return data;
  }

  List<double> _buildHourlySales(List<Invoice> invoices) {
    final hourlySales = List.filled(24, 0.0);

    for (final invoice in invoices) {
      final hour = (invoice.createdAt ?? DateTime.now()).hour;
      hourlySales[hour] += invoice.total;
    }

    return hourlySales;
  }

  Future<List<LowStockData>> _loadLowStockProducts() async {
    final products = await _productDao.getAllProducts();
    final lowStock = <LowStockData>[];

    for (final product in products.where((p) => p.isActive)) {
      final inventory = await _inventoryDao.getProductInventoryAll(product.id);
      final stock =
          inventory.fold<double>(0.0, (sum, inv) => sum + inv.quantity);

      if (stock <= product.lowStockAlert) {
        lowStock.add(LowStockData(
          id: product.id,
          name: product.name,
          stock: stock,
          minStock: product.lowStockAlert.toDouble(),
        ));
      }
    }

    return lowStock..sort((a, b) => a.stock.compareTo(b.stock));
  }

  String _getDayName(int weekday) {
    const days = ['إ', 'ث', 'أ', 'خ', 'ج', 'س', 'أ'];
    return days[weekday - 1];
  }

  String _getTransactionTypeText(String type) {
    switch (type) {
      case 'income':
        return 'إيراد';
      case 'expense':
        return 'مصروف';
      case 'sale':
        return 'مبيعات';
      case 'purchase':
        return 'مشتريات';
      default:
        return type;
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    state = state.copyWith(startDate: start, endDate: end);
    _loadReports();
  }

  Future<void> exportToPdf() async {
    final printService = GetIt.I<PrintService>();
    // TODO: تنفيذ التصدير إلى PDF
  }

  Future<void> exportToExcel() async {
    final backupService = GetIt.I<BackupService>();
    // TODO: تنفيذ التصدير إلى Excel
  }

  Future<void> print() async {
    final printService = GetIt.I<PrintService>();
    // TODO: تنفيذ الطباعة
  }

  Future<void> refresh() async {
    await _loadReports();
  }
}
