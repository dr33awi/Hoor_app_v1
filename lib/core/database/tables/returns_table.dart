import 'package:drift/drift.dart';

import 'invoices_table.dart';
import 'users_table.dart';
import 'customers_table.dart';

/// جدول المرتجعات
class Returns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get returnNumber => text().unique()();
  TextColumn get type => text()(); // sale_return, purchase_return
  IntColumn get originalInvoiceId =>
      integer().nullable().references(Invoices, #id)();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get returnDate => dateTime()();
  RealColumn get subtotal => real()();
  RealColumn get total => real()();
  TextColumn get reason => text().nullable()(); // سبب الإرجاع
  TextColumn get status => text().withDefault(const Constant('completed'))();
  TextColumn get refundMethod =>
      text().withDefault(const Constant('cash'))(); // cash, credit
  TextColumn get notes => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
}
