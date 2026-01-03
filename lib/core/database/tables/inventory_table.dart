import 'package:drift/drift.dart';

import 'products_table.dart';
import 'warehouses_table.dart';

/// جدول المخزون
class Inventory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get warehouseId => integer().references(Warehouses, #id)();
  RealColumn get quantity => real().withDefault(const Constant(0))();
  RealColumn get reservedQuantity =>
      real().withDefault(const Constant(0))(); // الكمية المحجوزة
  DateTimeColumn get lastUpdated => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {productId, warehouseId},
      ];
}
