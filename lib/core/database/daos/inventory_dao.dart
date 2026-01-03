import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/inventory_table.dart';
import '../tables/inventory_movements_table.dart';
import '../tables/warehouses_table.dart';
import '../tables/products_table.dart';

part 'inventory_dao.g.dart';

/// نموذج المخزون مع تفاصيل المنتج
class InventoryWithProduct {
  final InventoryData inventory;
  final Product product;
  final Warehouse warehouse;

  InventoryWithProduct({
    required this.inventory,
    required this.product,
    required this.warehouse,
  });
}

@DriftAccessor(tables: [Inventory, InventoryMovements, Warehouses, Products])
class InventoryDao extends DatabaseAccessor<AppDatabase>
    with _$InventoryDaoMixin {
  InventoryDao(super.db);

  // ==================== المستودعات ====================

  // الحصول على جميع المستودعات
  Future<List<Warehouse>> getAllWarehouses() {
    return (select(warehouses)
          ..orderBy([(w) => OrderingTerm(expression: w.name)]))
        .get();
  }

  // الحصول على المستودعات النشطة
  Future<List<Warehouse>> getActiveWarehouses() {
    return (select(warehouses)
          ..where((w) => w.isActive.equals(true))
          ..orderBy([(w) => OrderingTerm(expression: w.name)]))
        .get();
  }

  // الحصول على المستودع الافتراضي
  Future<Warehouse?> getDefaultWarehouse() {
    return (select(warehouses)..where((w) => w.isDefault.equals(true)))
        .getSingleOrNull();
  }

  // الحصول على مستودع بواسطة المعرف
  Future<Warehouse?> getWarehouseById(int id) {
    return (select(warehouses)..where((w) => w.id.equals(id)))
        .getSingleOrNull();
  }

  // إضافة مستودع
  Future<int> insertWarehouse(WarehousesCompanion warehouse) {
    return into(warehouses).insert(warehouse);
  }

  // تحديث مستودع
  Future<bool> updateWarehouse(Warehouse warehouse) {
    return update(warehouses).replace(warehouse);
  }

  // تعيين المستودع الافتراضي
  Future<void> setDefaultWarehouse(int id) async {
    await transaction(() async {
      // إزالة الافتراضي من جميع المستودعات
      await (update(warehouses))
          .write(const WarehousesCompanion(isDefault: Value(false)));
      // تعيين المستودع الجديد كافتراضي
      await (update(warehouses)..where((w) => w.id.equals(id)))
          .write(const WarehousesCompanion(isDefault: Value(true)));
    });
  }

  // ==================== المخزون ====================

  // الحصول على مخزون منتج في مستودع
  Future<InventoryData?> getProductInventory(int productId, int warehouseId) {
    return (select(inventory)
          ..where((i) =>
              i.productId.equals(productId) &
              i.warehouseId.equals(warehouseId)))
        .getSingleOrNull();
  }

  // الحصول على مخزون منتج في جميع المستودعات
  Future<List<InventoryData>> getProductInventoryAll(int productId) {
    return (select(inventory)..where((i) => i.productId.equals(productId)))
        .get();
  }

  // الحصول على إجمالي مخزون منتج
  Future<double> getProductTotalStock(int productId) async {
    final query = selectOnly(inventory)
      ..where(inventory.productId.equals(productId))
      ..addColumns([inventory.quantity.sum()]);
    final result = await query.getSingle();
    return result.read(inventory.quantity.sum()) ?? 0;
  }

  // الحصول على مخزون مستودع
  Future<List<InventoryWithProduct>> getWarehouseInventory(
      int warehouseId) async {
    final query = select(inventory).join([
      innerJoin(products, products.id.equalsExp(inventory.productId)),
      innerJoin(warehouses, warehouses.id.equalsExp(inventory.warehouseId)),
    ])
      ..where(inventory.warehouseId.equals(warehouseId) &
          products.isActive.equals(true));

    final results = await query.get();
    return results.map((row) {
      return InventoryWithProduct(
        inventory: row.readTable(inventory),
        product: row.readTable(products),
        warehouse: row.readTable(warehouses),
      );
    }).toList();
  }

  // إضافة أو تحديث المخزون
  Future<void> upsertInventory(
      int productId, int warehouseId, double quantity) async {
    final existing = await getProductInventory(productId, warehouseId);

    if (existing != null) {
      await (update(inventory)
            ..where((i) =>
                i.productId.equals(productId) &
                i.warehouseId.equals(warehouseId)))
          .write(InventoryCompanion(
        quantity: Value(quantity),
        lastUpdated: Value(DateTime.now()),
      ));
    } else {
      await into(inventory).insert(InventoryCompanion.insert(
        productId: productId,
        warehouseId: warehouseId,
        quantity: Value(quantity),
        lastUpdated: Value(DateTime.now()),
      ));
    }
  }

  // إضافة كمية للمخزون
  Future<void> addToInventory(
    int productId,
    int warehouseId,
    double quantity,
    int userId, {
    String? movementType,
    int? referenceId,
    String? referenceType,
    double? unitCost,
    String? notes,
  }) async {
    final current = await getProductInventory(productId, warehouseId);
    final currentQty = current?.quantity ?? 0;
    final newQty = currentQty + quantity;

    await transaction(() async {
      await upsertInventory(productId, warehouseId, newQty);

      // تسجيل الحركة
      await into(inventoryMovements).insert(InventoryMovementsCompanion.insert(
        productId: productId,
        warehouseId: warehouseId,
        movementType: movementType ?? 'in',
        quantity: quantity,
        quantityBefore: currentQty,
        quantityAfter: newQty,
        unitCost: Value(unitCost),
        referenceId: Value(referenceId),
        referenceType: Value(referenceType),
        userId: userId,
        notes: Value(notes),
        createdAt: Value(DateTime.now()),
      ));
    });
  }

  // خصم كمية من المخزون
  Future<bool> subtractFromInventory(
    int productId,
    int warehouseId,
    double quantity,
    int userId, {
    String? movementType,
    int? referenceId,
    String? referenceType,
    String? notes,
  }) async {
    final current = await getProductInventory(productId, warehouseId);
    final currentQty = current?.quantity ?? 0;

    if (currentQty < quantity) {
      return false; // الكمية غير كافية
    }

    final newQty = currentQty - quantity;

    await transaction(() async {
      await upsertInventory(productId, warehouseId, newQty);

      // تسجيل الحركة
      await into(inventoryMovements).insert(InventoryMovementsCompanion.insert(
        productId: productId,
        warehouseId: warehouseId,
        movementType: movementType ?? 'out',
        quantity: quantity,
        quantityBefore: currentQty,
        quantityAfter: newQty,
        referenceId: Value(referenceId),
        referenceType: Value(referenceType),
        userId: userId,
        notes: Value(notes),
        createdAt: Value(DateTime.now()),
      ));
    });

    return true;
  }

  // نقل بين المستودعات
  Future<bool> transferBetweenWarehouses(
    int productId,
    int fromWarehouseId,
    int toWarehouseId,
    double quantity,
    int userId, {
    String? notes,
  }) async {
    final fromInventory = await getProductInventory(productId, fromWarehouseId);
    final fromQty = fromInventory?.quantity ?? 0;

    if (fromQty < quantity) {
      return false; // الكمية غير كافية
    }

    final toInventory = await getProductInventory(productId, toWarehouseId);
    final toQty = toInventory?.quantity ?? 0;

    await transaction(() async {
      // خصم من المستودع المصدر
      await upsertInventory(productId, fromWarehouseId, fromQty - quantity);

      // إضافة للمستودع الهدف
      await upsertInventory(productId, toWarehouseId, toQty + quantity);

      // تسجيل حركة النقل
      await into(inventoryMovements).insert(InventoryMovementsCompanion.insert(
        productId: productId,
        warehouseId: fromWarehouseId,
        toWarehouseId: Value(toWarehouseId),
        movementType: 'transfer',
        quantity: quantity,
        quantityBefore: fromQty,
        quantityAfter: fromQty - quantity,
        userId: userId,
        notes: Value(notes),
        createdAt: Value(DateTime.now()),
      ));
    });

    return true;
  }

  // تعديل المخزون (جرد)
  Future<void> adjustInventory(
    int productId,
    int warehouseId,
    double newQuantity,
    int userId, {
    String? notes,
  }) async {
    final current = await getProductInventory(productId, warehouseId);
    final currentQty = current?.quantity ?? 0;

    await transaction(() async {
      await upsertInventory(productId, warehouseId, newQuantity);

      // تسجيل حركة التعديل
      await into(inventoryMovements).insert(InventoryMovementsCompanion.insert(
        productId: productId,
        warehouseId: warehouseId,
        movementType: 'adjustment',
        quantity: (newQuantity - currentQty).abs(),
        quantityBefore: currentQty,
        quantityAfter: newQuantity,
        userId: userId,
        notes: Value(notes ?? 'تعديل جرد'),
        createdAt: Value(DateTime.now()),
      ));
    });
  }

  // ==================== حركات المخزون ====================

  // الحصول على حركات منتج
  Future<List<InventoryMovement>> getProductMovements(int productId,
      {int limit = 50}) {
    return (select(inventoryMovements)
          ..where((m) => m.productId.equals(productId))
          ..orderBy([
            (m) =>
                OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
  }

  // الحصول على حركات مستودع
  Future<List<InventoryMovement>> getWarehouseMovements(int warehouseId,
      {int limit = 50}) {
    return (select(inventoryMovements)
          ..where((m) => m.warehouseId.equals(warehouseId))
          ..orderBy([
            (m) =>
                OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
  }

  // الحصول على حركات فترة معينة
  Future<List<InventoryMovement>> getMovementsByDateRange(
      DateTime start, DateTime end) {
    return (select(inventoryMovements)
          ..where((m) => m.createdAt.isBetweenValues(start, end))
          ..orderBy([
            (m) =>
                OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // ==================== تقارير المخزون ====================

  // الحصول على المنتجات منخفضة المخزون
  Future<List<InventoryWithProduct>> getLowStockProducts() async {
    final query = select(inventory).join([
      innerJoin(products, products.id.equalsExp(inventory.productId)),
      innerJoin(warehouses, warehouses.id.equalsExp(inventory.warehouseId)),
    ])
      ..where(products.isActive.equals(true) &
          products.trackInventory.equals(true));

    final results = await query.get();
    return results
        .map((row) {
          final product = row.readTable(products);
          final inv = row.readTable(inventory);
          return InventoryWithProduct(
            inventory: inv,
            product: product,
            warehouse: row.readTable(warehouses),
          );
        })
        .where((item) => item.inventory.quantity <= item.product.lowStockAlert)
        .toList();
  }

  // الحصول على قيمة المخزون
  Future<double> getTotalInventoryValue() async {
    final query = select(inventory).join([
      innerJoin(products, products.id.equalsExp(inventory.productId)),
    ])
      ..where(products.isActive.equals(true));

    final results = await query.get();
    double totalValue = 0;
    for (final row in results) {
      final product = row.readTable(products);
      final inv = row.readTable(inventory);
      totalValue += inv.quantity * product.costPrice;
    }
    return totalValue;
  }

  // مراقبة المخزون
  Stream<List<InventoryData>> watchInventory(int warehouseId) {
    return (select(inventory)..where((i) => i.warehouseId.equals(warehouseId)))
        .watch();
  }
}
