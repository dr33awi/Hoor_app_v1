import 'package:drift/drift.dart';

import 'invoices_table.dart';
import 'products_table.dart';
import 'warehouses_table.dart';

/// جدول بنود الفواتير
class InvoiceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer().references(Invoices, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get warehouseId =>
      integer().nullable().references(Warehouses, #id)();
  TextColumn get productName => text()(); // اسم المنتج وقت البيع
  TextColumn get barcode => text().nullable()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()(); // سعر الوحدة
  RealColumn get costPrice =>
      real().withDefault(const Constant(0))(); // سعر التكلفة
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get discountPercent => real().withDefault(const Constant(0))();
  RealColumn get total => real()(); // الإجمالي بعد الخصم
  TextColumn get notes => text().nullable()();
}
