import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/invoices_dao.dart';
import '../../../../core/database/daos/customers_dao.dart';
import '../../../../core/database/daos/users_dao.dart';
import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/database.dart';

/// عنصر فاتورة
class InvoiceItem {
  final int id;
  final String invoiceNumber;
  final int? customerId;
  final String? customerName;
  final int userId;
  final String? userName;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final double paidAmount;
  final String paymentMethod;
  final String status;
  final String? notes;
  final DateTime createdAt;

  const InvoiceItem({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    this.customerName,
    required this.userId,
    this.userName,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.createdAt,
  });
}

/// حالة الفواتير
class InvoicesState {
  final bool isLoading;
  final String? error;
  final List<InvoiceItem> invoices;
  final List<InvoiceItem> filteredInvoices;
  final String? statusFilter;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const InvoicesState({
    this.isLoading = true,
    this.error,
    this.invoices = const [],
    this.filteredInvoices = const [],
    this.statusFilter,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
  });

  // إحصائيات
  int get totalCount => filteredInvoices.length;
  int get closedCount =>
      filteredInvoices.where((i) => i.status == 'closed').length;
  int get pendingCount =>
      filteredInvoices.where((i) => i.status == 'pending').length;
  int get cancelledCount =>
      filteredInvoices.where((i) => i.status == 'cancelled').length;
  double get totalAmount => filteredInvoices
      .where((i) => i.status != 'cancelled')
      .fold(0.0, (sum, i) => sum + i.totalAmount);

  InvoicesState copyWith({
    bool? isLoading,
    String? error,
    List<InvoiceItem>? invoices,
    List<InvoiceItem>? filteredInvoices,
    String? statusFilter,
    bool clearStatus = false,
    String? searchQuery,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
  }) {
    return InvoicesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      invoices: invoices ?? this.invoices,
      filteredInvoices: filteredInvoices ?? this.filteredInvoices,
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }
}

/// مزود الفواتير
final invoicesProvider =
    StateNotifierProvider<InvoicesNotifier, InvoicesState>((ref) {
  return InvoicesNotifier();
});

/// مدير حالة الفواتير
class InvoicesNotifier extends StateNotifier<InvoicesState> {
  final InvoicesDao _invoiceDao;
  final CustomersDao _customerDao;
  final UsersDao _userDao;

  InvoicesNotifier()
      : _invoiceDao = GetIt.I<InvoicesDao>(),
        _customerDao = GetIt.I<CustomersDao>(),
        _userDao = GetIt.I<UsersDao>(),
        super(const InvoicesState()) {
    // تحميل فواتير اليوم بشكل افتراضي
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    state = state.copyWith(startDate: startOfDay, endDate: now);
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // جلب البيانات المساعدة
      final customers = await _customerDao.getAllCustomers();
      final users = await _userDao.getAllUsers();

      final customerMap = {for (var c in customers) c.id: c.name};
      final userMap = {for (var u in users) u.id: u.name};

      // جلب الفواتير
      List<Invoice> invoices;
      if (state.startDate != null && state.endDate != null) {
        invoices = await _invoiceDao.getInvoicesByDateRange(
          state.startDate!,
          state.endDate!.add(const Duration(days: 1)),
        );
      } else {
        // جلب جميع الفواتير (محدود)
        invoices = await _invoiceDao.getInvoicesByDateRange(
          DateTime.now().subtract(const Duration(days: 30)),
          DateTime.now().add(const Duration(days: 1)),
        );
      }

      // تحويل إلى InvoiceItem
      final invoiceItems = invoices
          .map((inv) => InvoiceItem(
                id: inv.id,
                invoiceNumber: inv.invoiceNumber,
                customerId: inv.customerId,
                customerName:
                    inv.customerId != null ? customerMap[inv.customerId] : null,
                userId: inv.userId,
                userName: userMap[inv.userId],
                subtotal: inv.subtotal,
                discountAmount: inv.discountAmount,
                taxAmount: inv.taxAmount,
                totalAmount: inv.total,
                paidAmount: inv.paidAmount,
                paymentMethod: inv.paymentMethod,
                status: inv.status,
                notes: inv.notes,
                createdAt: inv.createdAt ?? DateTime.now(),
              ))
          .toList();

      // ترتيب الأحدث أولاً
      invoiceItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(
        isLoading: false,
        invoices: invoiceItems,
        filteredInvoices: invoiceItems,
      );

      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل الفواتير: $e',
      );
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void filterByStatus(String? status) {
    state = state.copyWith(
      statusFilter: status,
      clearStatus: status == null,
    );
    _applyFilters();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      clearStartDate: start == null,
      clearEndDate: end == null,
    );
    _loadInvoices();
  }

  void _applyFilters() {
    var filtered = state.invoices.toList();

    // فلترة حسب الحالة
    if (state.statusFilter != null) {
      filtered = filtered.where((i) => i.status == state.statusFilter).toList();
    }

    // فلترة حسب البحث
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((i) {
        return i.invoiceNumber.toLowerCase().contains(query) ||
            (i.customerName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    state = state.copyWith(filteredInvoices: filtered);
  }

  Future<void> cancelInvoice(int id) async {
    await _invoiceDao.cancelInvoice(id);
    await _loadInvoices();
  }

  Future<void> refresh() async {
    await _loadInvoices();
  }
}

/// مزود تفاصيل الفاتورة
final invoiceDetailProvider =
    FutureProvider.family<InvoiceDetail?, int>((ref, id) async {
  final invoiceDao = GetIt.I<InvoicesDao>();
  final customerDao = GetIt.I<CustomersDao>();
  final productDao = GetIt.I<ProductsDao>();

  final invoice = await invoiceDao.getInvoiceById(id);
  if (invoice == null) return null;

  final items = await invoiceDao.getInvoiceItems(id);
  final products = await productDao.getAllProducts();
  final productMap = {for (var p in products) p.id: p};

  String? customerName;
  if (invoice.customerId != null) {
    final customer = await customerDao.getCustomerById(invoice.customerId!);
    customerName = customer?.name;
  }

  return InvoiceDetail(
    id: invoice.id,
    invoiceNumber: invoice.invoiceNumber,
    customerId: invoice.customerId,
    customerName: customerName,
    subtotal: invoice.subtotal,
    discountAmount: invoice.discountAmount,
    taxAmount: invoice.taxAmount,
    totalAmount: invoice.total,
    paidAmount: invoice.paidAmount,
    paymentMethod: invoice.paymentMethod,
    status: invoice.status,
    notes: invoice.notes,
    createdAt: invoice.createdAt ?? DateTime.now(),
    items: items.map((itemWithProduct) {
      final invoiceItem = itemWithProduct.item;
      return InvoiceItemDetail(
        id: invoiceItem.id,
        productId: invoiceItem.productId,
        productName: invoiceItem.productName,
        quantity: invoiceItem.quantity,
        unitPrice: invoiceItem.unitPrice,
        discountAmount: invoiceItem.discountAmount,
        totalPrice: invoiceItem.total,
      );
    }).toList(),
  );
});

/// تفاصيل الفاتورة
class InvoiceDetail {
  final int id;
  final String invoiceNumber;
  final int? customerId;
  final String? customerName;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final double paidAmount;
  final String paymentMethod;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final List<InvoiceItemDetail> items;

  const InvoiceDetail({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    this.customerName,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.items,
  });
}

/// تفاصيل عنصر الفاتورة
class InvoiceItemDetail {
  final int id;
  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double totalPrice;

  const InvoiceItemDetail({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.totalPrice,
  });
}
