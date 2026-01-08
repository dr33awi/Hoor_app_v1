import 'package:drift/drift.dart';

/// Products table
/// ═══════════════════════════════════════════════════════════════════════════
/// سياسة تثبيت السعر (Price Locking Policy):
/// - يتم حفظ السعر بالدولار + سعر الصرف وقت الإنشاء
/// - السعر بالليرة = السعر بالدولار × سعر الصرف وقت الإنشاء
/// - تغيير سعر الصرف لاحقاً لا يؤثر على الأسعار المحفوظة
/// ═══════════════════════════════════════════════════════════════════════════
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  // ═══════════════════════════════════════════════════════════════════════════
  // أسعار الشراء (مع تثبيت السعر)
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get purchasePrice => real()(); // سعر الشراء بالليرة (محسوب ومخزن)
  RealColumn get purchasePriceUsd =>
      real().nullable()(); // سعر الشراء بالدولار (المرجع الأساسي)

  // ═══════════════════════════════════════════════════════════════════════════
  // أسعار البيع (مع تثبيت السعر)
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get salePrice => real()(); // سعر البيع بالليرة (محسوب ومخزن)
  RealColumn get salePriceUsd =>
      real().nullable()(); // سعر البيع بالدولار (المرجع الأساسي)

  // ═══════════════════════════════════════════════════════════════════════════
  // سعر الصرف المثبت وقت الإنشاء/التحديث
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get exchangeRateAtCreation =>
      real().nullable()(); // سعر الصرف وقت إنشاء/تحديث المنتج

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
/// ═══════════════════════════════════════════════════════════════════════════
/// سياسة تثبيت السعر (Price Locking Policy):
/// - يتم حفظ الإجمالي بالدولار + سعر الصرف وقت الإنشاء
/// - الإجمالي بالليرة = الإجمالي بالدولار × سعر الصرف
/// - تغيير سعر الصرف لاحقاً لا يؤثر على الفواتير السابقة
/// ═══════════════════════════════════════════════════════════════════════════
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get type =>
      text()(); // sale, purchase, sale_return, purchase_return
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  TextColumn get supplierId => text().nullable().references(Suppliers, #id)();
  TextColumn get warehouseId => text()
      .nullable()(); // معرف المستودع (nullable للتوافق مع البيانات القديمة)

  // ═══════════════════════════════════════════════════════════════════════════
  // المبالغ بالليرة السورية (محسوبة ومخزنة)
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get subtotal => real()();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();

  // ═══════════════════════════════════════════════════════════════════════════
  // المبالغ بالدولار (المرجع الأساسي للحسابات)
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get totalUsd => real().nullable()(); // الإجمالي بالدولار
  RealColumn get paidAmountUsd =>
      real().nullable()(); // المبلغ المدفوع بالدولار

  // ═══════════════════════════════════════════════════════════════════════════
  // سعر الصرف المثبت وقت إنشاء الفاتورة
  // ═══════════════════════════════════════════════════════════════════════════
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
/// ═══════════════════════════════════════════════════════════════════════════
/// سياسة تثبيت السعر: كل عنصر يحتفظ بسعره الخاص وقت الإنشاء
/// ═══════════════════════════════════════════════════════════════════════════
class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();

  // ═══════════════════════════════════════════════════════════════════════════
  // الأسعار بالليرة السورية (محسوبة ومخزنة)
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get unitPrice => real()(); // سعر الوحدة بالليرة
  RealColumn get purchasePrice => real()(); // سعر الشراء بالليرة
  RealColumn get costPrice =>
      real().nullable()(); // سعر التكلفة وقت البيع (للدقة المحاسبية)
  RealColumn get costPriceUsd =>
      real().nullable()(); // سعر التكلفة بالدولار وقت البيع
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get total => real()(); // الإجمالي بالليرة

  // ═══════════════════════════════════════════════════════════════════════════
  // الأسعار بالدولار (المرجع الأساسي)
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get unitPriceUsd => real().nullable()(); // سعر الوحدة بالدولار
  RealColumn get totalUsd => real().nullable()(); // الإجمالي بالدولار

  // ═══════════════════════════════════════════════════════════════════════════
  // سعر الصرف المثبت وقت إضافة العنصر
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get exchangeRate =>
      real().nullable()(); // سعر الصرف وقت إضافة العنصر

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
/// ═══════════════════════════════════════════════════════════════════════════
/// سياسة تثبيت السعر: الوردية تحتفظ بسعر الصرف والأرصدة بالدولار
/// ═══════════════════════════════════════════════════════════════════════════
class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get shiftNumber => text()();

  // ═══════════════════════════════════════════════════════════════════════════
  // الأرصدة بالليرة
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get openingBalance => real()();
  RealColumn get closingBalance => real().nullable()();
  RealColumn get expectedBalance => real().nullable()();
  RealColumn get difference => real().nullable()();

  // ═══════════════════════════════════════════════════════════════════════════
  // الأرصدة بالدولار (مع تثبيت السعر)
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get openingBalanceUsd =>
      real().nullable()(); // الرصيد الافتتاحي بالدولار
  RealColumn get closingBalanceUsd =>
      real().nullable()(); // الرصيد الختامي بالدولار
  RealColumn get expectedBalanceUsd => real().nullable()(); // المتوقع بالدولار
  RealColumn get exchangeRate =>
      real().nullable()(); // سعر الصرف وقت فتح الوردية

  // ═══════════════════════════════════════════════════════════════════════════
  // إجماليات الوردية بالليرة
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get totalSales => real().withDefault(const Constant(0))();
  RealColumn get totalReturns => real().withDefault(const Constant(0))();
  RealColumn get totalExpenses => real().withDefault(const Constant(0))();
  RealColumn get totalIncome => real().withDefault(const Constant(0))();

  // ═══════════════════════════════════════════════════════════════════════════
  // إجماليات الوردية بالدولار
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get totalSalesUsd => real().withDefault(const Constant(0))();
  RealColumn get totalReturnsUsd => real().withDefault(const Constant(0))();
  RealColumn get totalExpensesUsd => real().withDefault(const Constant(0))();
  RealColumn get totalIncomeUsd => real().withDefault(const Constant(0))();

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
/// ═══════════════════════════════════════════════════════════════════════════
/// سياسة تثبيت السعر: الحركة تحتفظ بالمبلغ بالدولار + سعر الصرف
/// ═══════════════════════════════════════════════════════════════════════════
class CashMovements extends Table {
  TextColumn get id => text()();
  TextColumn get shiftId => text().references(Shifts, #id)();
  TextColumn get type =>
      text()(); // income, expense, sale, purchase, opening, closing

  // ═══════════════════════════════════════════════════════════════════════════
  // المبالغ (مع تثبيت السعر)
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get amount => real()(); // المبلغ بالليرة (محسوب ومخزن)
  RealColumn get amountUsd => real().nullable()(); // المبلغ بالدولار (المرجع)
  RealColumn get exchangeRate =>
      real().nullable()(); // سعر صرف الدولار وقت الحركة

  TextColumn get description => text()();
  TextColumn get category => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Customers table
/// ═══════════════════════════════════════════════════════════════════════════
/// سياسة تثبيت السعر: الرصيد بالدولار يُحسب من سعر الصرف المحفوظ لكل فاتورة
/// ═══════════════════════════════════════════════════════════════════════════
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get balance =>
      real().withDefault(const Constant(0))(); // Credit balance بالليرة
  RealColumn get balanceUsd => real()
      .nullable()(); // Credit balance بالدولار (محسوب من سعر الصرف المحفوظ)
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Suppliers table
/// ═══════════════════════════════════════════════════════════════════════════
/// سياسة تثبيت السعر: الرصيد بالدولار يُحسب من سعر الصرف المحفوظ لكل فاتورة
/// ═══════════════════════════════════════════════════════════════════════════
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get balance =>
      real().withDefault(const Constant(0))(); // Payable balance بالليرة
  RealColumn get balanceUsd => real()
      .nullable()(); // Payable balance بالدولار (محسوب من سعر الصرف المحفوظ)
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
/// ═══════════════════════════════════════════════════════════════════════════
/// سياسة تثبيت السعر: السند يحتفظ بالمبلغ بالدولار + سعر الصرف
/// ═══════════════════════════════════════════════════════════════════════════
class Vouchers extends Table {
  TextColumn get id => text()();
  TextColumn get voucherNumber => text()(); // رقم السند
  TextColumn get type =>
      text()(); // payment (دفع), receipt (قبض), expense (مصاريف)
  TextColumn get categoryId =>
      text().nullable().references(VoucherCategories, #id)();

  // ═══════════════════════════════════════════════════════════════════════════
  // المبالغ (مع تثبيت السعر)
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get amount => real()(); // المبلغ بالليرة (محسوب ومخزن)
  RealColumn get amountUsd => real().nullable()(); // المبلغ بالدولار (المرجع)
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

/// ═══════════════════════════════════════════════════════════════════════════
/// Inventory Count (الجرد الدوري)
/// ═══════════════════════════════════════════════════════════════════════════

/// Inventory Counts table - جدول عمليات الجرد
class InventoryCounts extends Table {
  TextColumn get id => text()();
  TextColumn get countNumber => text()(); // رقم الجرد
  TextColumn get warehouseId => text().references(Warehouses, #id)();
  TextColumn get status => text().withDefault(const Constant(
      'draft'))(); // draft, in_progress, completed, cancelled, approved
  TextColumn get countType =>
      text().withDefault(const Constant('full'))(); // full, partial, cycle
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text().nullable()(); // المستخدم الذي أنشأ الجرد
  TextColumn get approvedBy =>
      text().nullable()(); // المستخدم الذي وافق على الجرد
  IntColumn get totalItems =>
      integer().withDefault(const Constant(0))(); // عدد الأصناف
  IntColumn get countedItems =>
      integer().withDefault(const Constant(0))(); // عدد الأصناف المجرودة
  IntColumn get varianceItems =>
      integer().withDefault(const Constant(0))(); // عدد الأصناف بها فروقات
  RealColumn get totalVarianceValue =>
      real().withDefault(const Constant(0))(); // إجمالي قيمة الفروقات
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get countDate =>
      dateTime().withDefault(currentDateAndTime)(); // تاريخ الجرد
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Inventory Count Items table - جدول عناصر الجرد
class InventoryCountItems extends Table {
  TextColumn get id => text()();
  TextColumn get countId => text().references(InventoryCounts, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productName => text()();
  TextColumn get productSku => text().nullable()();
  TextColumn get productBarcode => text().nullable()();
  IntColumn get systemQuantity => integer()(); // الكمية في النظام
  IntColumn get physicalQuantity =>
      integer().nullable()(); // الكمية الفعلية (المعدودة)
  IntColumn get variance => integer().nullable()(); // الفرق (physical - system)
  RealColumn get unitCost => real()(); // تكلفة الوحدة
  RealColumn get varianceValue => real().nullable()(); // قيمة الفرق
  TextColumn get varianceReason => text().nullable()(); // سبب الفرق
  BoolColumn get isCounted =>
      boolean().withDefault(const Constant(false))(); // هل تم العد
  TextColumn get location => text().nullable()(); // موقع المنتج في المستودع
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get countedAt => dateTime().nullable()(); // وقت العد
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Inventory Adjustments table - جدول تسويات الجرد
class InventoryAdjustments extends Table {
  TextColumn get id => text()();
  TextColumn get adjustmentNumber => text()(); // رقم التسوية
  TextColumn get countId =>
      text().nullable().references(InventoryCounts, #id)(); // مرتبط بجرد
  TextColumn get warehouseId => text().references(Warehouses, #id)();
  TextColumn get type => text()(); // increase, decrease, write_off, correction
  TextColumn get reason => text()(); // سبب التسوية
  TextColumn get status => text()
      .withDefault(const Constant('pending'))(); // pending, approved, rejected
  TextColumn get approvedBy => text().nullable()();
  RealColumn get totalValue =>
      real().withDefault(const Constant(0))(); // إجمالي قيمة التسوية بالليرة
  RealColumn get totalValueUsd =>
      real().nullable()(); // إجمالي قيمة التسوية بالدولار
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get adjustmentDate =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Inventory Adjustment Items table - جدول عناصر تسويات الجرد
class InventoryAdjustmentItems extends Table {
  TextColumn get id => text()();
  TextColumn get adjustmentId => text().references(InventoryAdjustments, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productName => text()();
  IntColumn get quantityBefore => integer()(); // الكمية قبل التسوية
  IntColumn get quantityAdjusted => integer()(); // الكمية المعدلة
  IntColumn get quantityAfter => integer()(); // الكمية بعد التسوية
  RealColumn get unitCost => real()(); // تكلفة الوحدة بالليرة
  RealColumn get unitCostUsd => real().nullable()(); // تكلفة الوحدة بالدولار
  RealColumn get adjustmentValue => real()(); // قيمة التسوية بالليرة
  RealColumn get adjustmentValueUsd =>
      real().nullable()(); // قيمة التسوية بالدولار
  TextColumn get reason => text().nullable()(); // سبب محدد لهذا الصنف
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Recurring Expense Templates - قوالب المصاريف الدورية
/// ═══════════════════════════════════════════════════════════════════════════
/// يحل محل SharedPreferences لضمان:
/// - عدم فقدان البيانات عند مسح الكاش
/// - التزامن مع Firestore
/// - الـ Transaction Atomicity
/// ═══════════════════════════════════════════════════════════════════════════
class RecurringExpenseTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()(); // اسم القالب
  TextColumn get categoryId =>
      text().nullable().references(VoucherCategories, #id)();
  TextColumn get categoryName => text().nullable()();

  // ═══════════════════════════════════════════════════════════════════════════
  // المبالغ (مع تثبيت السعر)
  // ═══════════════════════════════════════════════════════════════════════════
  RealColumn get amountSyp => real()(); // المبلغ بالليرة
  RealColumn get amountUsd => real().nullable()(); // المبلغ بالدولار
  RealColumn get exchangeRate =>
      real().nullable()(); // سعر الصرف وقت إنشاء القالب

  TextColumn get description => text().nullable()();

  // ═══════════════════════════════════════════════════════════════════════════
  // إعدادات التكرار
  // ═══════════════════════════════════════════════════════════════════════════
  TextColumn get frequency =>
      text()(); // daily, weekly, biweekly, monthly, quarterly, yearly
  DateTimeColumn get lastGeneratedDate =>
      dateTime().nullable()(); // آخر تاريخ إنشاء
  DateTimeColumn get nextDueDate =>
      dateTime().nullable()(); // تاريخ الاستحقاق التالي

  // ═══════════════════════════════════════════════════════════════════════════
  // إعدادات التوزيع (للمصاريف الكبيرة)
  // ═══════════════════════════════════════════════════════════════════════════
  TextColumn get distributionType => text()
      .withDefault(const Constant('immediate'))(); // immediate, distributed
  TextColumn get distributionPeriod =>
      text().nullable()(); // monthly, quarterly, semiAnnual, annual
  IntColumn get distributionCount =>
      integer().nullable()(); // عدد فترات التوزيع
  DateTimeColumn get distributionStartDate =>
      dateTime().nullable()(); // تاريخ بداية التوزيع
  DateTimeColumn get distributionEndDate =>
      dateTime().nullable()(); // تاريخ نهاية التوزيع

  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))(); // هل القالب نشط
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))(); // pending, synced
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Recurring Expense Logs - سجل المصاريف الدورية المنشأة
/// ═══════════════════════════════════════════════════════════════════════════
/// يحفظ سجل كل مصروف دوري تم إنشاؤه مع Period Key لمنع التكرار
/// ═══════════════════════════════════════════════════════════════════════════
class RecurringExpenseLogs extends Table {
  TextColumn get id => text()();
  TextColumn get templateId =>
      text().references(RecurringExpenseTemplates, #id)();

  // ═══════════════════════════════════════════════════════════════════════════
  // Period Key - المفتاح الفريد للفترة (لمنع التكرار)
  // ═══════════════════════════════════════════════════════════════════════════
  TextColumn get periodKey => text()(); // مثال: template123_2026_01

  // معرف المصروف المنشأ
  TextColumn get expenseId => text().nullable()();

  // ═══════════════════════════════════════════════════════════════════════════
  // معلومات التوزيع (للمصاريف الموزعة)
  // ═══════════════════════════════════════════════════════════════════════════
  IntColumn get periodNumber =>
      integer().nullable()(); // رقم الفترة (1, 2, 3...)
  IntColumn get totalPeriods => integer().nullable()(); // إجمالي الفترات
  RealColumn get amountSyp => real()(); // المبلغ لهذه الفترة
  RealColumn get amountUsd => real().nullable()();
  RealColumn get totalAmountSyp =>
      real().nullable()(); // المبلغ الإجمالي للمصروف الأب
  DateTimeColumn get periodStartDate => dateTime().nullable()(); // بداية الفترة
  DateTimeColumn get periodEndDate => dateTime().nullable()(); // نهاية الفترة

  // حالة الإنشاء
  TextColumn get status => text()
      .withDefault(const Constant('created'))(); // created, failed, cancelled
  TextColumn get errorMessage => text().nullable()(); // رسالة الخطأ إن وجد

  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  // فهرس فريد على Period Key لمنع التكرار
  @override
  List<Set<Column>> get uniqueKeys => [
        {templateId, periodKey}
      ];
}
