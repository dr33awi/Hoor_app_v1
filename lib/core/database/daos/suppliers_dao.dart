import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/suppliers_table.dart';

part 'suppliers_dao.g.dart';

@DriftAccessor(tables: [Suppliers])
class SuppliersDao extends DatabaseAccessor<AppDatabase>
    with _$SuppliersDaoMixin {
  SuppliersDao(super.db);

  // الحصول على جميع الموردين
  Future<List<Supplier>> getAllSuppliers() {
    return (select(suppliers)
          ..orderBy([(s) => OrderingTerm(expression: s.name)]))
        .get();
  }

  // الحصول على الموردين النشطين
  Future<List<Supplier>> getActiveSuppliers() {
    return (select(suppliers)
          ..where((s) => s.isActive.equals(true))
          ..orderBy([(s) => OrderingTerm(expression: s.name)]))
        .get();
  }

  // الحصول على مورد بواسطة المعرف
  Future<Supplier?> getSupplierById(int id) {
    return (select(suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  // البحث عن موردين
  Future<List<Supplier>> searchSuppliers(String query) {
    return (select(suppliers)
          ..where((s) =>
              (s.name.like('%$query%') | s.phone.like('%$query%')) &
              s.isActive.equals(true))
          ..orderBy([(s) => OrderingTerm(expression: s.name)]))
        .get();
  }

  // الحصول على موردين لديهم رصيد مستحق
  Future<List<Supplier>> getSuppliersWithBalance() {
    return (select(suppliers)
          ..where(
              (s) => s.balance.isBiggerThanValue(0) & s.isActive.equals(true))
          ..orderBy([
            (s) => OrderingTerm(expression: s.balance, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // إضافة مورد جديد
  Future<int> insertSupplier(SuppliersCompanion supplier) {
    return into(suppliers).insert(supplier);
  }

  // تحديث مورد
  Future<bool> updateSupplier(Supplier supplier) {
    return update(suppliers).replace(supplier);
  }

  // تحديث رصيد المورد
  Future<int> updateSupplierBalance(int id, double newBalance) {
    return (update(suppliers)..where((s) => s.id.equals(id))).write(
        SuppliersCompanion(
            balance: Value(newBalance), updatedAt: Value(DateTime.now())));
  }

  // إضافة إلى رصيد المورد
  Future<void> addToSupplierBalance(int id, double amount) async {
    final supplier = await getSupplierById(id);
    if (supplier != null) {
      final newBalance = supplier.balance + amount;
      await updateSupplierBalance(id, newBalance);
    }
  }

  // خصم من رصيد المورد
  Future<void> subtractFromSupplierBalance(int id, double amount) async {
    final supplier = await getSupplierById(id);
    if (supplier != null) {
      final newBalance = supplier.balance - amount;
      await updateSupplierBalance(id, newBalance);
    }
  }

  // تعطيل/تفعيل مورد
  Future<int> toggleSupplierStatus(int id, bool isActive) {
    return (update(suppliers)..where((s) => s.id.equals(id))).write(
        SuppliersCompanion(
            isActive: Value(isActive), updatedAt: Value(DateTime.now())));
  }

  // حذف مورد
  Future<int> deleteSupplier(int id) {
    return (delete(suppliers)..where((s) => s.id.equals(id))).go();
  }

  // الحصول على إجمالي الذمم الدائنة
  Future<double> getTotalPayables() async {
    final query = selectOnly(suppliers)
      ..where(suppliers.isActive.equals(true) &
          suppliers.balance.isBiggerThanValue(0))
      ..addColumns([suppliers.balance.sum()]);
    final result = await query.getSingle();
    return result.read(suppliers.balance.sum()) ?? 0;
  }

  // مراقبة الموردين
  Stream<List<Supplier>> watchActiveSuppliers() {
    return (select(suppliers)
          ..where((s) => s.isActive.equals(true))
          ..orderBy([(s) => OrderingTerm(expression: s.name)]))
        .watch();
  }

  // الحصول على عدد الموردين
  Future<int> getSuppliersCount() async {
    final query = selectOnly(suppliers)
      ..where(suppliers.isActive.equals(true))
      ..addColumns([suppliers.id.count()]);
    final result = await query.getSingle();
    return result.read(suppliers.id.count()) ?? 0;
  }
}
