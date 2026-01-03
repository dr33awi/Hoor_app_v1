import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/customers_dao.dart';
import '../../../../core/database/daos/invoices_dao.dart';
import '../../../../core/database/database.dart';

/// فاتورة عميل
class CustomerInvoice {
  final int id;
  final DateTime date;
  final double total;
  final String status;

  CustomerInvoice({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
  });
}

/// عنصر عميل
class CustomerItem {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final double balance;
  final double totalPurchases;
  final int invoicesCount;
  final DateTime? lastPurchase;
  final List<CustomerInvoice> recentInvoices;

  CustomerItem({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    required this.balance,
    required this.totalPurchases,
    required this.invoicesCount,
    this.lastPurchase,
    this.recentInvoices = const [],
  });
}

/// حالة العملاء
class CustomersState {
  final bool isLoading;
  final List<CustomerItem> customers;
  final String searchQuery;
  final String sortBy;
  final bool showWithDebt;

  const CustomersState({
    this.isLoading = false,
    this.customers = const [],
    this.searchQuery = '',
    this.sortBy = 'name',
    this.showWithDebt = false,
  });

  List<CustomerItem> get filteredCustomers {
    var result = customers.toList();

    // البحث
    if (searchQuery.isNotEmpty) {
      result = result.where((c) {
        return c.name.contains(searchQuery) ||
            (c.phone?.contains(searchQuery) ?? false) ||
            (c.email?.contains(searchQuery) ?? false);
      }).toList();
    }

    // فلتر الدين
    if (showWithDebt) {
      result = result.where((c) => c.balance > 0).toList();
    }

    // الترتيب
    switch (sortBy) {
      case 'balance':
        result.sort((a, b) => b.balance.compareTo(a.balance));
        break;
      case 'lastPurchase':
        result.sort((a, b) {
          if (a.lastPurchase == null) return 1;
          if (b.lastPurchase == null) return -1;
          return b.lastPurchase!.compareTo(a.lastPurchase!);
        });
        break;
      case 'name':
      default:
        result.sort((a, b) => a.name.compareTo(b.name));
    }

    return result;
  }

  double get totalDue {
    return customers.fold(0, (sum, c) => sum + (c.balance > 0 ? c.balance : 0));
  }

  CustomersState copyWith({
    bool? isLoading,
    List<CustomerItem>? customers,
    String? searchQuery,
    String? sortBy,
    bool? showWithDebt,
  }) {
    return CustomersState(
      isLoading: isLoading ?? this.isLoading,
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      showWithDebt: showWithDebt ?? this.showWithDebt,
    );
  }
}

/// مدير العملاء
class CustomersNotifier extends StateNotifier<CustomersState> {
  final CustomersDao _customerDao;
  final InvoicesDao _invoiceDao;

  CustomersNotifier(this._customerDao, this._invoiceDao)
      : super(const CustomersState());

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true);

    try {
      final customers = await _customerDao.getAllCustomers();
      final items = <CustomerItem>[];

      for (final customer in customers) {
        // جلب فواتير العميل
        final invoices = await _invoiceDao.getCustomerInvoices(customer.id);

        // حساب الإحصائيات
        double totalPurchases = 0;
        DateTime? lastPurchase;
        final recentInvoices = <CustomerInvoice>[];

        for (final invoice in invoices) {
          totalPurchases += invoice.total;
          final invoiceDate = invoice.createdAt ?? DateTime.now();
          if (lastPurchase == null || invoiceDate.isAfter(lastPurchase)) {
            lastPurchase = invoiceDate;
          }
        }

        // آخر 5 فواتير
        final sortedInvoices = invoices.toList()
          ..sort((a, b) => (b.createdAt ?? DateTime.now())
              .compareTo(a.createdAt ?? DateTime.now()));

        for (final invoice in sortedInvoices.take(5)) {
          recentInvoices.add(CustomerInvoice(
            id: invoice.id,
            date: invoice.createdAt ?? DateTime.now(),
            total: invoice.total,
            status: invoice.status,
          ));
        }

        items.add(CustomerItem(
          id: customer.id,
          name: customer.name,
          phone: customer.phone,
          email: customer.email,
          address: customer.address,
          notes: customer.notes,
          balance: customer.balance,
          totalPurchases: totalPurchases,
          invoicesCount: invoices.length,
          lastPurchase: lastPurchase,
          recentInvoices: recentInvoices,
        ));
      }

      state = state.copyWith(
        customers: items,
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

  void setShowWithDebt(bool show) {
    state = state.copyWith(showWithDebt: show);
  }

  Future<void> addCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    try {
      await _customerDao.insertCustomer(
        CustomersCompanion.insert(
          name: name,
          phone: Value(phone?.isNotEmpty == true ? phone : null),
          email: Value(email?.isNotEmpty == true ? email : null),
          address: Value(address?.isNotEmpty == true ? address : null),
          notes: Value(notes?.isNotEmpty == true ? notes : null),
          balance: const Value(0),
        ),
      );

      await loadCustomers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCustomer({
    required int id,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    try {
      final existing = await _customerDao.getCustomerById(id);
      if (existing != null) {
        await _customerDao.updateCustomer(
          existing.copyWith(
            name: name,
            phone: Value(phone?.isNotEmpty == true ? phone : null),
            email: Value(email?.isNotEmpty == true ? email : null),
            address: Value(address?.isNotEmpty == true ? address : null),
            notes: Value(notes?.isNotEmpty == true ? notes : null),
          ),
        );
        await loadCustomers();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await _customerDao.deleteCustomer(id);
      await loadCustomers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPayment({
    required int customerId,
    required double amount,
    String? note,
  }) async {
    try {
      final customer = await _customerDao.getCustomerById(customerId);
      if (customer != null) {
        final newBalance = customer.balance - amount;
        await _customerDao.updateCustomer(
          customer.copyWith(balance: newBalance),
        );

        // TODO: تسجيل الدفعة في جدول المعاملات المالية

        await loadCustomers();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBalance({
    required int customerId,
    required double amount,
    bool add = true,
  }) async {
    try {
      final customer = await _customerDao.getCustomerById(customerId);
      if (customer != null) {
        final newBalance =
            add ? customer.balance + amount : customer.balance - amount;

        await _customerDao.updateCustomer(
          customer.copyWith(balance: newBalance),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// مزود العملاء
final customersProvider =
    StateNotifierProvider<CustomersNotifier, CustomersState>((ref) {
  final customerDao = GetIt.instance<CustomersDao>();
  final invoiceDao = GetIt.instance<InvoicesDao>();
  return CustomersNotifier(customerDao, invoiceDao);
});

/// مزود قائمة العملاء للاختيار
final customerListProvider = FutureProvider<List<CustomerItem>>((ref) async {
  final customerDao = GetIt.instance<CustomersDao>();

  final customers = await customerDao.getAllCustomers();

  return customers
      .map((c) => CustomerItem(
            id: c.id,
            name: c.name,
            phone: c.phone,
            balance: c.balance,
            totalPurchases: 0,
            invoicesCount: 0,
          ))
      .toList();
});
