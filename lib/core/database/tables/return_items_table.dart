import 'package:drift/drift.dart';

import 'returns_table.dart';
import 'products_table.dart';
import 'warehouses_table.dart';

/// جدول بنود المرتجعات
class ReturnItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get returnId => integer().references(Returns, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get warehouseId =>
      integer().nullable().references(Warehouses, #id)();
  TextColumn get productName => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get total => real()();
  TextColumn get condition =>
      text().nullable()(); // حالة المنتج المرتجع: good, damaged
  TextColumn get notes => text().nullable()();
}
