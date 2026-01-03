import 'package:drift/drift.dart';

/// جدول العملاء
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get taxNumber => text().nullable()(); // الرقم الضريبي
  RealColumn get creditLimit =>
      real().withDefault(const Constant(0))(); // حد الائتمان
  RealColumn get balance =>
      real().withDefault(const Constant(0))(); // الرصيد (موجب = مستحق عليه)
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
