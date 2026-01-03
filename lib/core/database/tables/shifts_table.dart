import 'package:drift/drift.dart';

import 'users_table.dart';

/// جدول الورديات
class Shifts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  RealColumn get openingBalance => real()(); // الرصيد الافتتاحي
  RealColumn get closingBalance => real().nullable()(); // الرصيد الختامي
  RealColumn get expectedBalance => real().nullable()(); // الرصيد المتوقع
  RealColumn get difference => real().nullable()(); // الفرق
  RealColumn get totalSales => real().withDefault(const Constant(0))();
  RealColumn get totalReturns => real().withDefault(const Constant(0))();
  RealColumn get totalCashIn => real().withDefault(const Constant(0))();
  RealColumn get totalCashOut => real().withDefault(const Constant(0))();
  IntColumn get transactionsCount => integer().withDefault(const Constant(0))();
  TextColumn get status =>
      text().withDefault(const Constant('open'))(); // open, closed
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
}
