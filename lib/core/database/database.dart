import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../config/app_config.dart';
import 'tables/users_table.dart';
import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/customers_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/invoices_table.dart';
import 'tables/invoice_items_table.dart';
import 'tables/inventory_table.dart';
import 'tables/inventory_movements_table.dart';
import 'tables/warehouses_table.dart';
import 'tables/shifts_table.dart';
import 'tables/cash_transactions_table.dart';
import 'tables/returns_table.dart';
import 'tables/return_items_table.dart';
import 'tables/settings_table.dart';

import 'daos/users_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/products_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/suppliers_dao.dart';
import 'daos/invoices_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/shifts_dao.dart';
import 'daos/cash_dao.dart';
import 'daos/returns_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Categories,
    Products,
    Customers,
    Suppliers,
    Invoices,
    InvoiceItems,
    Inventory,
    InventoryMovements,
    Warehouses,
    Shifts,
    CashTransactions,
    Returns,
    ReturnItems,
    AppSettings,
  ],
  daos: [
    UsersDao,
    CategoriesDao,
    ProductsDao,
    CustomersDao,
    SuppliersDao,
    InvoicesDao,
    InventoryDao,
    ShiftsDao,
    CashDao,
    ReturnsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => AppConfig.dbVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // إنشاء المستودع الافتراضي
        await into(warehouses).insert(WarehousesCompanion.insert(
          name: 'المستودع الرئيسي',
          isDefault: const Value(true),
          createdAt: Value(DateTime.now()),
        ));
        // إنشاء المستخدم الافتراضي (مدير)
        await into(users).insert(UsersCompanion.insert(
          name: 'المدير',
          username: 'admin',
          password: 'admin123', // يجب تغييره عند أول تسجيل دخول
          role: 'manager',
          isActive: const Value(true),
          createdAt: Value(DateTime.now()),
        ));
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // ترقيات قاعدة البيانات المستقبلية
      },
    );
  }

  // تصدير قاعدة البيانات للنسخ الاحتياطي
  Future<File> exportDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConfig.dbName));
    return file;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConfig.dbName));
    return NativeDatabase.createInBackground(file);
  });
}
