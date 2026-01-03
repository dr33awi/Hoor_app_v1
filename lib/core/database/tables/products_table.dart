import 'package:drift/drift.dart';

import 'categories_table.dart';

/// جدول المنتجات
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get barcode => text().nullable().unique()();
  TextColumn get sku => text().nullable()(); // رمز المنتج الداخلي
  RealColumn get costPrice =>
      real().withDefault(const Constant(0))(); // سعر التكلفة
  RealColumn get salePrice => real()(); // سعر البيع
  RealColumn get wholesalePrice => real().nullable()(); // سعر الجملة
  RealColumn get minPrice => real().nullable()(); // أقل سعر مسموح
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get unit => text().withDefault(const Constant('قطعة'))(); // الوحدة
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get trackInventory =>
      boolean().withDefault(const Constant(true))(); // تتبع المخزون
  IntColumn get lowStockAlert =>
      integer().withDefault(const Constant(10))(); // تنبيه المخزون المنخفض
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
