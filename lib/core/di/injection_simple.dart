import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../database/database.dart';
import '../database/daos/users_dao.dart';
import '../database/daos/categories_dao.dart';
import '../database/daos/products_dao.dart';
import '../database/daos/customers_dao.dart';
import '../database/daos/suppliers_dao.dart';
import '../database/daos/invoices_dao.dart';
import '../database/daos/inventory_dao.dart';
import '../database/daos/shifts_dao.dart';
import '../database/daos/cash_dao.dart';
import '../database/daos/returns_dao.dart';
import '../services/backup_service.dart';
import '../services/print_service.dart';
import '../services/sync_service.dart';
import '../services/barcode_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // قاعدة البيانات
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);

  // Hive Boxes
  final settingsBox = await Hive.openBox('settings');
  getIt.registerSingleton<Box>(settingsBox);

  // DAOs
  getIt.registerLazySingleton<UsersDao>(() => database.usersDao);
  getIt.registerLazySingleton<CategoriesDao>(() => database.categoriesDao);
  getIt.registerLazySingleton<ProductsDao>(() => database.productsDao);
  getIt.registerLazySingleton<CustomersDao>(() => database.customersDao);
  getIt.registerLazySingleton<SuppliersDao>(() => database.suppliersDao);
  getIt.registerLazySingleton<InvoicesDao>(() => database.invoicesDao);
  getIt.registerLazySingleton<InventoryDao>(() => database.inventoryDao);
  getIt.registerLazySingleton<ShiftsDao>(() => database.shiftsDao);
  getIt.registerLazySingleton<CashDao>(() => database.cashDao);
  getIt.registerLazySingleton<ReturnsDao>(() => database.returnsDao);

  // الخدمات الأساسية
  getIt.registerLazySingleton<PrintService>(() => PrintService());
  getIt.registerLazySingleton<BackupService>(() => BackupService(database));
  getIt.registerLazySingleton<SyncService>(() => SyncService(database));
  getIt.registerLazySingleton<BarcodeService>(() => BarcodeService());
}
