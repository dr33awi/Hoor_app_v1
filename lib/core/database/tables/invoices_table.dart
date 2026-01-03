import 'package:drift/drift.dart';

import 'customers_table.dart';
import 'suppliers_table.dart';
import 'users_table.dart';
import 'shifts_table.dart';

/// جدول الفواتير
class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().unique()(); // رقم الفاتورة
  TextColumn get type => text()(); // sale, purchase
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  IntColumn get supplierId => integer().nullable().references(Suppliers, #id)();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get shiftId => integer().nullable().references(Shifts, #id)();
  DateTimeColumn get invoiceDate => dateTime()();
  RealColumn get subtotal => real()(); // المجموع قبل الخصم
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get discountPercent => real().withDefault(const Constant(0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get total => real()(); // الإجمالي النهائي
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  RealColumn get remainingAmount => real().withDefault(const Constant(0))();
  TextColumn get paymentMethod =>
      text().withDefault(const Constant('cash'))(); // cash, credit, mixed
  TextColumn get status =>
      text().withDefault(const Constant('open'))(); // open, closed, cancelled
  TextColumn get notes => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();
}
