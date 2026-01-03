import 'package:drift/drift.dart';

import 'products_table.dart';
import 'warehouses_table.dart';
import 'users_table.dart';
import 'invoices_table.dart';

/// جدول حركات المخزون
class InventoryMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get warehouseId => integer().references(Warehouses, #id)();
  IntColumn get toWarehouseId => integer()
      .nullable()
      .references(Warehouses, #id)(); // للنقل بين المستودعات
  TextColumn get movementType =>
      text()(); // in, out, transfer, adjustment, return
  RealColumn get quantity => real()();
  RealColumn get quantityBefore => real()();
  RealColumn get quantityAfter => real()();
  RealColumn get unitCost => real().nullable()();
  IntColumn get referenceId =>
      integer().nullable()(); // معرف الفاتورة أو المستند المرجعي
  TextColumn get referenceType =>
      text().nullable()(); // invoice, purchase, adjustment, transfer, return
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
}
