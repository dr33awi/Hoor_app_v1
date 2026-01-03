import 'package:drift/drift.dart';

/// جدول الإعدادات
class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get value => text().nullable()();
  TextColumn get type => text().withDefault(
      const Constant('string'))(); // string, int, double, bool, json
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
