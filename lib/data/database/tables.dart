import 'package:drift/drift.dart';

/// Products table
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  RealColumn get purchasePrice => real()();
  RealColumn get purchasePriceUsd => real().nullable()(); // سعر الشراء بالدولار
  RealColumn get salePrice => real()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  IntColumn get minQuantity => integer().withDefault(const Constant(5))();
  RealColumn get taxRate => real().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Categories table
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get parentId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Invoices table
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get type =>
      text()(); // sale, purchase, sale_return, purchase_return
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  TextColumn get supplierId => text().nullable().references(Suppliers, #id)();
  RealColumn get subtotal => real()();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  RealColumn get exchangeRate =>
      real().nullable()(); // سعر صرف الدولار وقت إنشاء الفاتورة
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  TextColumn get notes => text().nullable()();
  TextColumn get shiftId => text().nullable().references(Shifts, #id)();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get invoiceDate =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Invoice Items table
class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get purchasePrice => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Inventory Movements table
class InventoryMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get warehouseId => text()
      .nullable()(); // معرف المستودع (nullable للتوافق مع البيانات القديمة)
  TextColumn get type =>
      text()(); // add, withdraw, return, adjustment, sale, purchase, transfer_in, transfer_out
  IntColumn get quantity => integer()();
  IntColumn get previousQuantity => integer()();
  IntColumn get newQuantity => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get referenceId =>
      text().nullable()(); // Invoice ID or adjustment ID or transfer ID
  TextColumn get referenceType =>
      text().nullable()(); // invoice, adjustment, transfer
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Shifts table
class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get shiftNumber => text()();
  RealColumn get openingBalance => real()();
  RealColumn get closingBalance => real().nullable()();
  RealColumn get expectedBalance => real().nullable()();
  RealColumn get difference => real().nullable()();
  RealColumn get totalSales => real().withDefault(const Constant(0))();
  RealColumn get totalReturns => real().withDefault(const Constant(0))();
  RealColumn get totalExpenses => real().withDefault(const Constant(0))();
  RealColumn get totalIncome => real().withDefault(const Constant(0))();
  IntColumn get transactionCount => integer().withDefault(const Constant(0))();
  TextColumn get status =>
      text().withDefault(const Constant('open'))(); // open, closed
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cash Movements table
class CashMovements extends Table {
  TextColumn get id => text()();
  TextColumn get shiftId => text().references(Shifts, #id)();
  TextColumn get type =>
      text()(); // income, expense, sale, purchase, opening, closing
  RealColumn get amount => real()();
  TextColumn get description => text()();
  TextColumn get category => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  RealColumn get exchangeRate =>
      real().nullable()(); // سعر صرف الدولار وقت الحركة
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Customers table
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get balance =>
      real().withDefault(const Constant(0))(); // Credit balance
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Suppliers table
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get balance =>
      real().withDefault(const Constant(0))(); // Payable balance
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Settings table
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

/// Warehouses table - جدول المستودعات
class Warehouses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()(); // اسم المستودع
  TextColumn get code => text().nullable()(); // رمز المستودع
  TextColumn get address => text().nullable()(); // عنوان المستودع
  TextColumn get phone => text().nullable()(); // رقم الهاتف
  TextColumn get managerId => text().nullable()(); // مدير المستودع
  BoolColumn get isDefault => boolean()
      .withDefault(const Constant(false))(); // هل هو المستودع الافتراضي
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))(); // هل المستودع نشط
  TextColumn get notes => text().nullable()(); // ملاحظات
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))(); // pending, synced
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Warehouse Stock table - جدول مخزون المستودعات
class WarehouseStock extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text().references(Warehouses, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  IntColumn get minQuantity => integer().withDefault(const Constant(5))();
  IntColumn get maxQuantity => integer().nullable()(); // الحد الأقصى للمخزون
  TextColumn get location => text().nullable()(); // موقع المنتج في المستودع
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))(); // pending, synced
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stock Transfers table - جدول نقل المخزون بين المستودعات
class StockTransfers extends Table {
  TextColumn get id => text()();
  TextColumn get transferNumber => text()(); // رقم التحويل
  TextColumn get fromWarehouseId => text().references(Warehouses, #id)();
  TextColumn get toWarehouseId => text().references(Warehouses, #id)();
  TextColumn get status => text().withDefault(
      const Constant('pending'))(); // pending, in_transit, completed, cancelled
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))(); // pending, synced
  DateTimeColumn get transferDate =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stock Transfer Items table - جدول عناصر نقل المخزون
class StockTransferItems extends Table {
  TextColumn get id => text()();
  TextColumn get transferId => text().references(StockTransfers, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productName => text()();
  IntColumn get requestedQuantity => integer()(); // الكمية المطلوبة
  IntColumn get transferredQuantity =>
      integer().withDefault(const Constant(0))(); // الكمية المحولة فعلياً
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))(); // pending, synced
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Voucher Categories table - تصنيفات السندات
class VoucherCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()(); // اسم التصنيف
  TextColumn get type =>
      text()(); // payment (دفع), receipt (قبض), expense (مصاريف)
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))(); // هل التصنيف نشط
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))(); // pending, synced
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Vouchers table - جدول السندات
class Vouchers extends Table {
  TextColumn get id => text()();
  TextColumn get voucherNumber => text()(); // رقم السند
  TextColumn get type =>
      text()(); // payment (دفع), receipt (قبض), expense (مصاريف)
  TextColumn get categoryId =>
      text().nullable().references(VoucherCategories, #id)();
  RealColumn get amount => real()(); // المبلغ بالدينار
  RealColumn get exchangeRate =>
      real().withDefault(const Constant(1.0))(); // سعر الصرف وقت الإنشاء
  TextColumn get description => text().nullable()(); // الوصف/الملاحظات
  TextColumn get customerId =>
      text().nullable().references(Customers, #id)(); // العميل (للقبض)
  TextColumn get supplierId =>
      text().nullable().references(Suppliers, #id)(); // المورد (للدفع)
  TextColumn get shiftId =>
      text().nullable().references(Shifts, #id)(); // رقم الشفت
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))(); // pending, synced
  DateTimeColumn get voucherDate =>
      dateTime().withDefault(currentDateAndTime)(); // تاريخ السند
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
