import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/customers_table.dart';

part 'customers_dao.g.dart';

@DriftAccessor(tables: [Customers])
class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.db);

  // الحصول على جميع العملاء
  Future<List<Customer>> getAllCustomers() {
    return (select(customers)
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .get();
  }

  // الحصول على العملاء النشطين
  Future<List<Customer>> getActiveCustomers() {
    return (select(customers)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .get();
  }

  // الحصول على عميل بواسطة المعرف
  Future<Customer?> getCustomerById(int id) {
    return (select(customers)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  // البحث عن عملاء
  Future<List<Customer>> searchCustomers(String query) {
    return (select(customers)
          ..where((c) =>
              (c.name.like('%$query%') | c.phone.like('%$query%')) &
              c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .get();
  }

  // الحصول على عملاء لديهم رصيد مستحق
  Future<List<Customer>> getCustomersWithBalance() {
    return (select(customers)
          ..where(
              (c) => c.balance.isBiggerThanValue(0) & c.isActive.equals(true))
          ..orderBy([
            (c) => OrderingTerm(expression: c.balance, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // إضافة عميل جديد
  Future<int> insertCustomer(CustomersCompanion customer) {
    return into(customers).insert(customer);
  }

  // تحديث عميل
  Future<bool> updateCustomer(Customer customer) {
    return update(customers).replace(customer);
  }

  // تحديث رصيد العميل
  Future<int> updateCustomerBalance(int id, double newBalance) {
    return (update(customers)..where((c) => c.id.equals(id))).write(
        CustomersCompanion(
            balance: Value(newBalance), updatedAt: Value(DateTime.now())));
  }

  // إضافة إلى رصيد العميل
  Future<void> addToCustomerBalance(int id, double amount) async {
    final customer = await getCustomerById(id);
    if (customer != null) {
      final newBalance = customer.balance + amount;
      await updateCustomerBalance(id, newBalance);
    }
  }

  // خصم من رصيد العميل
  Future<void> subtractFromCustomerBalance(int id, double amount) async {
    final customer = await getCustomerById(id);
    if (customer != null) {
      final newBalance = customer.balance - amount;
      await updateCustomerBalance(id, newBalance);
    }
  }

  // تعطيل/تفعيل عميل
  Future<int> toggleCustomerStatus(int id, bool isActive) {
    return (update(customers)..where((c) => c.id.equals(id))).write(
        CustomersCompanion(
            isActive: Value(isActive), updatedAt: Value(DateTime.now())));
  }

  // حذف عميل
  Future<int> deleteCustomer(int id) {
    return (delete(customers)..where((c) => c.id.equals(id))).go();
  }

  // الحصول على إجمالي الذمم المدينة
  Future<double> getTotalReceivables() async {
    final query = selectOnly(customers)
      ..where(customers.isActive.equals(true) &
          customers.balance.isBiggerThanValue(0))
      ..addColumns([customers.balance.sum()]);
    final result = await query.getSingle();
    return result.read(customers.balance.sum()) ?? 0;
  }

  // مراقبة العملاء
  Stream<List<Customer>> watchActiveCustomers() {
    return (select(customers)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .watch();
  }

  // الحصول على عدد العملاء
  Future<int> getCustomersCount() async {
    final query = selectOnly(customers)
      ..where(customers.isActive.equals(true))
      ..addColumns([customers.id.count()]);
    final result = await query.getSingle();
    return result.read(customers.id.count()) ?? 0;
  }
}
