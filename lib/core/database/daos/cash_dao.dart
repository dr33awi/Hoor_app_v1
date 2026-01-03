import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/cash_transactions_table.dart';
import '../tables/customers_table.dart';
import '../tables/suppliers_table.dart';

part 'cash_dao.g.dart';

/// نموذج الحركة المالية مع التفاصيل
class CashTransactionWithDetails {
  final CashTransaction transaction;
  final Customer? customer;
  final Supplier? supplier;

  CashTransactionWithDetails({
    required this.transaction,
    this.customer,
    this.supplier,
  });
}

@DriftAccessor(tables: [CashTransactions, Customers, Suppliers])
class CashDao extends DatabaseAccessor<AppDatabase> with _$CashDaoMixin {
  CashDao(super.db);

  // توليد رقم سند جديد
  Future<String> generateTransactionNumber(String type) async {
    final prefix = type == 'receipt' ? 'REC' : 'PAY';
    final today = DateTime.now();
    final dateStr =
        '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    final query = selectOnly(cashTransactions)
      ..where(cashTransactions.transactionNumber.like('$prefix-$dateStr%'))
      ..addColumns([cashTransactions.transactionNumber.count()]);
    final result = await query.getSingle();
    final count =
        (result.read(cashTransactions.transactionNumber.count()) ?? 0) + 1;

    return '$prefix-$dateStr-${count.toString().padLeft(4, '0')}';
  }

  // الحصول على جميع الحركات
  Future<List<CashTransaction>> getAllTransactions() {
    return (select(cashTransactions)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على حركة بواسطة المعرف
  Future<CashTransaction?> getTransactionById(int id) {
    return (select(cashTransactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // الحصول على حركات اليوم
  Future<List<CashTransaction>> getTodayTransactions() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(cashTransactions)
          ..where(
              (t) => t.transactionDate.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على حركات فترة معينة
  Future<List<CashTransaction>> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return (select(cashTransactions)
          ..where((t) => t.transactionDate.isBetweenValues(start, end))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على حركات الوردية
  Future<List<CashTransaction>> getShiftTransactions(int shiftId) {
    return (select(cashTransactions)
          ..where((t) => t.shiftId.equals(shiftId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على حركات عميل
  Future<List<CashTransaction>> getCustomerTransactions(int customerId) {
    return (select(cashTransactions)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على حركات مورد
  Future<List<CashTransaction>> getSupplierTransactions(int supplierId) {
    return (select(cashTransactions)
          ..where((t) => t.supplierId.equals(supplierId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // إضافة سند قبض
  Future<int> insertReceipt({
    required double amount,
    required int userId,
    int? shiftId,
    int? customerId,
    int? supplierId,
    int? invoiceId,
    String? category,
    String paymentMethod = 'cash',
    String? description,
    String? notes,
  }) async {
    final transactionNumber = await generateTransactionNumber('receipt');

    return into(cashTransactions).insert(CashTransactionsCompanion.insert(
      transactionNumber: transactionNumber,
      type: 'receipt',
      amount: amount,
      userId: userId,
      shiftId: Value(shiftId),
      customerId: Value(customerId),
      supplierId: Value(supplierId),
      invoiceId: Value(invoiceId),
      category: Value(category),
      paymentMethod: Value(paymentMethod),
      description: Value(description),
      notes: Value(notes),
      transactionDate: DateTime.now(),
      createdAt: Value(DateTime.now()),
    ));
  }

  // إضافة سند صرف
  Future<int> insertPayment({
    required double amount,
    required int userId,
    int? shiftId,
    int? customerId,
    int? supplierId,
    int? invoiceId,
    String? category,
    String paymentMethod = 'cash',
    String? description,
    String? notes,
  }) async {
    final transactionNumber = await generateTransactionNumber('payment');

    return into(cashTransactions).insert(CashTransactionsCompanion.insert(
      transactionNumber: transactionNumber,
      type: 'payment',
      amount: amount,
      userId: userId,
      shiftId: Value(shiftId),
      customerId: Value(customerId),
      supplierId: Value(supplierId),
      invoiceId: Value(invoiceId),
      category: Value(category),
      paymentMethod: Value(paymentMethod),
      description: Value(description),
      notes: Value(notes),
      transactionDate: DateTime.now(),
      createdAt: Value(DateTime.now()),
    ));
  }

  // إحصائيات الصندوق
  Future<double> getTotalReceipts(DateTime start, DateTime end) async {
    final query = selectOnly(cashTransactions)
      ..where(cashTransactions.type.equals('receipt') &
          cashTransactions.transactionDate.isBetweenValues(start, end))
      ..addColumns([cashTransactions.amount.sum()]);
    final result = await query.getSingle();
    return result.read(cashTransactions.amount.sum()) ?? 0;
  }

  Future<double> getTotalPayments(DateTime start, DateTime end) async {
    final query = selectOnly(cashTransactions)
      ..where(cashTransactions.type.equals('payment') &
          cashTransactions.transactionDate.isBetweenValues(start, end))
      ..addColumns([cashTransactions.amount.sum()]);
    final result = await query.getSingle();
    return result.read(cashTransactions.amount.sum()) ?? 0;
  }

  Future<double> getNetCash(DateTime start, DateTime end) async {
    final receipts = await getTotalReceipts(start, end);
    final payments = await getTotalPayments(start, end);
    return receipts - payments;
  }

  // إحصائيات الوردية
  Future<Map<String, double>> getShiftCashSummary(int shiftId) async {
    final receipts = await (selectOnly(cashTransactions)
          ..where(cashTransactions.shiftId.equals(shiftId) &
              cashTransactions.type.equals('receipt'))
          ..addColumns([cashTransactions.amount.sum()]))
        .getSingle();

    final payments = await (selectOnly(cashTransactions)
          ..where(cashTransactions.shiftId.equals(shiftId) &
              cashTransactions.type.equals('payment'))
          ..addColumns([cashTransactions.amount.sum()]))
        .getSingle();

    return {
      'receipts': receipts.read(cashTransactions.amount.sum()) ?? 0,
      'payments': payments.read(cashTransactions.amount.sum()) ?? 0,
    };
  }

  // مراقبة الحركات
  Stream<List<CashTransaction>> watchTodayTransactions() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(cashTransactions)
          ..where(
              (t) => t.transactionDate.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }
}
