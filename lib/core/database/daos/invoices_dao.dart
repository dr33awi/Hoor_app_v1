import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/invoices_table.dart';
import '../tables/invoice_items_table.dart';
import '../tables/customers_table.dart';
import '../tables/suppliers_table.dart';
import '../tables/products_table.dart';

part 'invoices_dao.g.dart';

/// نموذج الفاتورة مع التفاصيل
class InvoiceWithDetails {
  final Invoice invoice;
  final Customer? customer;
  final Supplier? supplier;
  final List<InvoiceItemWithProduct> items;

  InvoiceWithDetails({
    required this.invoice,
    this.customer,
    this.supplier,
    this.items = const [],
  });
}

class InvoiceItemWithProduct {
  final InvoiceItem item;
  final Product? product;

  InvoiceItemWithProduct({required this.item, this.product});
}

@DriftAccessor(tables: [Invoices, InvoiceItems, Customers, Suppliers, Products])
class InvoicesDao extends DatabaseAccessor<AppDatabase>
    with _$InvoicesDaoMixin {
  InvoicesDao(super.db);

  // توليد رقم فاتورة جديد
  Future<String> generateInvoiceNumber(String type) async {
    final prefix = type == 'sale' ? 'INV' : 'PUR';
    final today = DateTime.now();
    final dateStr =
        '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    final query = selectOnly(invoices)
      ..where(invoices.invoiceNumber.like('$prefix-$dateStr%'))
      ..addColumns([invoices.invoiceNumber.count()]);
    final result = await query.getSingle();
    final count = (result.read(invoices.invoiceNumber.count()) ?? 0) + 1;

    return '$prefix-$dateStr-${count.toString().padLeft(4, '0')}';
  }

  // الحصول على جميع الفواتير
  Future<List<Invoice>> getAllInvoices() {
    return (select(invoices)
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على فواتير حسب النوع
  Future<List<Invoice>> getInvoicesByType(String type) {
    return (select(invoices)
          ..where((i) => i.type.equals(type))
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على فواتير بتاريخ معين
  Future<List<Invoice>> getInvoicesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(invoices)
          ..where((i) => i.invoiceDate.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على فواتير فترة معينة
  Future<List<Invoice>> getInvoicesByDateRange(DateTime start, DateTime end) {
    return (select(invoices)
          ..where((i) => i.invoiceDate.isBetweenValues(start, end))
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على فاتورة بواسطة المعرف
  Future<Invoice?> getInvoiceById(int id) {
    return (select(invoices)..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  // الحصول على فاتورة بواسطة الرقم
  Future<Invoice?> getInvoiceByNumber(String number) {
    return (select(invoices)..where((i) => i.invoiceNumber.equals(number)))
        .getSingleOrNull();
  }

  // الحصول على فاتورة مع التفاصيل
  Future<InvoiceWithDetails?> getInvoiceWithDetails(int id) async {
    final invoice = await getInvoiceById(id);
    if (invoice == null) return null;

    Customer? customer;
    Supplier? supplier;

    if (invoice.customerId != null) {
      customer = await (select(customers)
            ..where((c) => c.id.equals(invoice.customerId!)))
          .getSingleOrNull();
    }
    if (invoice.supplierId != null) {
      supplier = await (select(suppliers)
            ..where((s) => s.id.equals(invoice.supplierId!)))
          .getSingleOrNull();
    }

    final items = await getInvoiceItems(id);

    return InvoiceWithDetails(
      invoice: invoice,
      customer: customer,
      supplier: supplier,
      items: items,
    );
  }

  // الحصول على بنود الفاتورة
  Future<List<InvoiceItemWithProduct>> getInvoiceItems(int invoiceId) async {
    final query = select(invoiceItems).join([
      leftOuterJoin(products, products.id.equalsExp(invoiceItems.productId)),
    ])
      ..where(invoiceItems.invoiceId.equals(invoiceId));

    final results = await query.get();
    return results.map((row) {
      return InvoiceItemWithProduct(
        item: row.readTable(invoiceItems),
        product: row.readTableOrNull(products),
      );
    }).toList();
  }

  // إضافة فاتورة جديدة
  Future<int> insertInvoice(InvoicesCompanion invoice) {
    return into(invoices).insert(invoice);
  }

  // إضافة بند فاتورة
  Future<int> insertInvoiceItem(InvoiceItemsCompanion item) {
    return into(invoiceItems).insert(item);
  }

  // إضافة فاتورة كاملة مع بنودها
  Future<int> insertInvoiceWithItems(
      InvoicesCompanion invoice, List<InvoiceItemsCompanion> items) async {
    return await transaction(() async {
      final invoiceId = await into(invoices).insert(invoice);
      for (final item in items) {
        await into(invoiceItems)
            .insert(item.copyWith(invoiceId: Value(invoiceId)));
      }
      return invoiceId;
    });
  }

  // تحديث فاتورة
  Future<bool> updateInvoice(Invoice invoice) {
    return update(invoices).replace(invoice);
  }

  // إغلاق فاتورة
  Future<int> closeInvoice(int id) {
    return (update(invoices)..where((i) => i.id.equals(id)))
        .write(InvoicesCompanion(
      status: const Value('closed'),
      closedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // إلغاء فاتورة
  Future<int> cancelInvoice(int id) {
    return (update(invoices)..where((i) => i.id.equals(id)))
        .write(InvoicesCompanion(
      status: const Value('cancelled'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // تحديث المبلغ المدفوع
  Future<int> updatePaidAmount(
      int id, double paidAmount, double remainingAmount) {
    return (update(invoices)..where((i) => i.id.equals(id)))
        .write(InvoicesCompanion(
      paidAmount: Value(paidAmount),
      remainingAmount: Value(remainingAmount),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // حذف فاتورة
  Future<void> deleteInvoice(int id) async {
    await transaction(() async {
      await (delete(invoiceItems)..where((i) => i.invoiceId.equals(id))).go();
      await (delete(invoices)..where((i) => i.id.equals(id))).go();
    });
  }

  // الحصول على فواتير عميل
  Future<List<Invoice>> getCustomerInvoices(int customerId) {
    return (select(invoices)
          ..where((i) => i.customerId.equals(customerId))
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على فواتير مورد
  Future<List<Invoice>> getSupplierInvoices(int supplierId) {
    return (select(invoices)
          ..where((i) => i.supplierId.equals(supplierId))
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على فواتير الوردية
  Future<List<Invoice>> getShiftInvoices(int shiftId) {
    return (select(invoices)
          ..where((i) => i.shiftId.equals(shiftId))
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // إحصائيات الفواتير
  Future<double> getTotalSales(DateTime start, DateTime end) async {
    final query = selectOnly(invoices)
      ..where(invoices.type.equals('sale') &
          invoices.status.equals('closed') &
          invoices.invoiceDate.isBetweenValues(start, end))
      ..addColumns([invoices.total.sum()]);
    final result = await query.getSingle();
    return result.read(invoices.total.sum()) ?? 0;
  }

  Future<double> getTotalPurchases(DateTime start, DateTime end) async {
    final query = selectOnly(invoices)
      ..where(invoices.type.equals('purchase') &
          invoices.status.equals('closed') &
          invoices.invoiceDate.isBetweenValues(start, end))
      ..addColumns([invoices.total.sum()]);
    final result = await query.getSingle();
    return result.read(invoices.total.sum()) ?? 0;
  }

  Future<int> getInvoicesCount(
      String type, DateTime start, DateTime end) async {
    final query = selectOnly(invoices)
      ..where(invoices.type.equals(type) &
          invoices.status.equals('closed') &
          invoices.invoiceDate.isBetweenValues(start, end))
      ..addColumns([invoices.id.count()]);
    final result = await query.getSingle();
    return result.read(invoices.id.count()) ?? 0;
  }

  // مراقبة الفواتير
  Stream<List<Invoice>> watchInvoices() {
    return (select(invoices)
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Stream<List<Invoice>> watchTodayInvoices() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(invoices)
          ..where((i) => i.invoiceDate.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }
}
