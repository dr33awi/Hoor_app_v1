import 'package:drift/drift.dart';

import 'users_table.dart';
import 'shifts_table.dart';
import 'customers_table.dart';
import 'suppliers_table.dart';
import 'invoices_table.dart';

/// جدول الحركات المالية (سندات القبض والصرف)
class CashTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionNumber => text().unique()();
  TextColumn get type => text()(); // receipt (قبض), payment (صرف)
  RealColumn get amount => real()();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get shiftId => integer().nullable().references(Shifts, #id)();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  IntColumn get supplierId => integer().nullable().references(Suppliers, #id)();
  IntColumn get invoiceId => integer().nullable().references(Invoices, #id)();
  TextColumn get category =>
      text().nullable()(); // sales, purchase, expense, salary, other
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
}
