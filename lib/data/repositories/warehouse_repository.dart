import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import 'base_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Warehouse Repository - مستودع المستودعات
/// ═══════════════════════════════════════════════════════════════════════════
class WarehouseRepository
    extends BaseRepository<Warehouse, WarehousesCompanion> {
  WarehouseRepository({
    required super.database,
    required super.firestore,
  }) : super(collectionName: 'warehouses');

  // ==================== Warehouse Operations ====================

  /// الحصول على جميع المستودعات
  Future<List<Warehouse>> getAllWarehouses() => database.getAllWarehouses();

  /// مراقبة جميع المستودعات
  Stream<List<Warehouse>> watchAllWarehouses() => database.watchAllWarehouses();

  /// مراقبة المستودعات النشطة
  Stream<List<Warehouse>> watchActiveWarehouses() =>
      database.watchActiveWarehouses();

  /// الحصول على مستودع بالمعرف
  Future<Warehouse?> getWarehouseById(String id) =>
      database.getWarehouseById(id);

  /// الحصول على المستودع الافتراضي
  Future<Warehouse?> getDefaultWarehouse() => database.getDefaultWarehouse();

  /// إنشاء مستودع جديد
  Future<String> createWarehouse({
    required String name,
    String? code,
    String? address,
    String? phone,
    String? managerId,
    bool isDefault = false,
    String? notes,
  }) async {
    final id = generateId();
    final now = DateTime.now();

    // إذا كان المستودع افتراضي، إلغاء الافتراضي من المستودعات الأخرى
    if (isDefault) {
      await database.setDefaultWarehouse(id);
    }

    await database.insertWarehouse(WarehousesCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
      address: Value(address),
      phone: Value(phone),
      managerId: Value(managerId),
      isDefault: Value(isDefault),
      isActive: const Value(true),
      notes: Value(notes),
      syncStatus: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    return id;
  }

  /// تحديث مستودع
  Future<void> updateWarehouse({
    required String id,
    String? name,
    String? code,
    String? address,
    String? phone,
    String? managerId,
    bool? isDefault,
    bool? isActive,
    String? notes,
  }) async {
    final existing = await database.getWarehouseById(id);
    if (existing == null) return;

    // إذا كان سيصبح افتراضي، إلغاء الافتراضي من المستودعات الأخرى
    if (isDefault == true && !existing.isDefault) {
      await database.setDefaultWarehouse(id);
    }

    await database.updateWarehouse(WarehousesCompanion(
      id: Value(id),
      name: Value(name ?? existing.name),
      code: Value(code ?? existing.code),
      address: Value(address ?? existing.address),
      phone: Value(phone ?? existing.phone),
      managerId: Value(managerId ?? existing.managerId),
      isDefault: Value(isDefault ?? existing.isDefault),
      isActive: Value(isActive ?? existing.isActive),
      notes: Value(notes ?? existing.notes),
      syncStatus: const Value('pending'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// حذف مستودع (soft delete - تعطيل فقط)
  Future<void> deleteWarehouse(String id) async {
    // التحقق من عدم وجود مخزون في المستودع
    final stock = await database.getWarehouseStockByWarehouse(id);
    final totalQty = stock.fold<int>(0, (sum, item) => sum + item.quantity);

    if (totalQty > 0) {
      throw Exception(
        'لا يمكن حذف المستودع لأنه يحتوي على مخزون ($totalQty وحدة). '
        'انقل المخزون إلى مستودع آخر أولاً.',
      );
    }

    // التحقق من عدم وجود عمليات نقل معلقة
    final pendingTransfers = await database.getPendingTransfersForWarehouse(id);
    if (pendingTransfers.isNotEmpty) {
      throw Exception(
        'لا يمكن حذف المستودع لأنه يوجد ${pendingTransfers.length} عملية نقل معلقة.',
      );
    }

    await updateWarehouse(id: id, isActive: false);
  }

  // ==================== Warehouse Stock Operations ====================

  /// الحصول على مخزون مستودع
  Future<List<WarehouseStockData>> getWarehouseStock(String warehouseId) =>
      database.getWarehouseStockByWarehouse(warehouseId);

  /// مراقبة مخزون مستودع
  Stream<List<WarehouseStockData>> watchWarehouseStock(String warehouseId) =>
      database.watchWarehouseStockByWarehouse(warehouseId);

  /// الحصول على مخزون منتج في جميع المستودعات
  Future<List<WarehouseStockData>> getProductStockInAllWarehouses(
          String productId) =>
      database.getWarehouseStockByProduct(productId);

  /// الحصول على إجمالي مخزون منتج
  Future<int> getTotalProductStock(String productId) =>
      database.getTotalStockForProduct(productId);

  /// الحصول على المنتجات منخفضة المخزون في مستودع
  Future<List<Map<String, dynamic>>> getLowStockProducts(String warehouseId) =>
      database.getLowStockInWarehouse(warehouseId);

  /// الحصول على ملخص المخزون لجميع المستودعات
  Future<List<Map<String, dynamic>>> getWarehouseStockSummary() =>
      database.getWarehouseStockSummary();

  /// تحديث كمية منتج في مستودع
  Future<void> updateProductStock({
    required String warehouseId,
    required String productId,
    required int quantity,
    int? minQuantity,
    int? maxQuantity,
    String? location,
  }) async {
    var stock = await database.getWarehouseStockByProductAndWarehouse(
      productId,
      warehouseId,
    );

    if (stock == null) {
      // إنشاء سجل مخزون جديد
      await database.insertWarehouseStock(WarehouseStockCompanion(
        id: Value('ws_${DateTime.now().millisecondsSinceEpoch}_$productId'),
        warehouseId: Value(warehouseId),
        productId: Value(productId),
        quantity: Value(quantity),
        minQuantity: Value(minQuantity ?? 5),
        maxQuantity: Value(maxQuantity),
        location: Value(location),
        syncStatus: const Value('pending'),
      ));
    } else {
      // تحديث المخزون الموجود
      await database.updateWarehouseStock(WarehouseStockCompanion(
        id: Value(stock.id),
        quantity: Value(quantity),
        minQuantity: Value(minQuantity ?? stock.minQuantity),
        maxQuantity: Value(maxQuantity ?? stock.maxQuantity),
        location: Value(location ?? stock.location),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }

  /// إضافة منتج لمستودع
  Future<void> addProductToWarehouse({
    required String productId,
    required String warehouseId,
    required int quantity,
    int? minQuantity,
    int? maxQuantity,
    String? location,
  }) async {
    await updateProductStock(
      productId: productId,
      warehouseId: warehouseId,
      quantity: quantity,
      minQuantity: minQuantity,
      maxQuantity: maxQuantity,
      location: location,
    );
  }

  // ==================== Stock Transfers ====================

  /// نقل المخزون بين المستودعات
  Future<String> transferStock({
    required String fromWarehouseId,
    required String toWarehouseId,
    required List<Map<String, dynamic>> items, // {productId, quantity}
    String? notes,
  }) async {
    // التحقق من وجود المستودعات
    final fromWarehouse = await database.getWarehouseById(fromWarehouseId);
    if (fromWarehouse == null) {
      throw Exception('المستودع المصدر غير موجود');
    }
    if (!fromWarehouse.isActive) {
      throw Exception('المستودع المصدر غير نشط');
    }

    final toWarehouse = await database.getWarehouseById(toWarehouseId);
    if (toWarehouse == null) {
      throw Exception('المستودع الهدف غير موجود');
    }
    if (!toWarehouse.isActive) {
      throw Exception('المستودع الهدف غير نشط');
    }

    // ✅ التحقق من كفاية المخزون لكل منتج
    for (final item in items) {
      final productId = item['productId'] as String;
      final requestedQty = item['quantity'] as int;

      final stock = await database.getWarehouseStockByProductAndWarehouse(
        productId,
        fromWarehouseId,
      );

      final availableQty = stock?.quantity ?? 0;

      if (availableQty < requestedQty) {
        final product = await database.getProductById(productId);
        throw Exception('المخزون غير كافٍ لـ "${product?.name ?? "المنتج"}"\n'
            'المتوفر: $availableQty | المطلوب: $requestedQty');
      }
    }

    // إنشاء عملية النقل
    final transferId = generateId();
    final transferNumber = 'TRF${DateTime.now().millisecondsSinceEpoch}';

    await database.insertStockTransfer(StockTransfersCompanion(
      id: Value(transferId),
      transferNumber: Value(transferNumber),
      fromWarehouseId: Value(fromWarehouseId),
      toWarehouseId: Value(toWarehouseId),
      status: const Value('completed'), // مباشرة completed للبساطة
      notes: Value(notes),
      syncStatus: const Value('pending'),
      transferDate: Value(DateTime.now()),
      completedAt: Value(DateTime.now()),
      createdAt: Value(DateTime.now()),
    ));

    // نقل المخزون
    await database.transaction(() async {
      for (final item in items) {
        final productId = item['productId'] as String;
        final qty = item['quantity'] as int;

        // خصم من المستودع المصدر
        final fromStock = await database.getWarehouseStockByProductAndWarehouse(
          productId,
          fromWarehouseId,
        );

        if (fromStock != null) {
          await database.updateWarehouseStockQuantity(
            fromWarehouseId,
            productId,
            fromStock.quantity - qty,
          );
        }

        // إضافة للمستودع الهدف
        final toStock = await database.getWarehouseStockByProductAndWarehouse(
          productId,
          toWarehouseId,
        );

        if (toStock != null) {
          await database.updateWarehouseStockQuantity(
            toWarehouseId,
            productId,
            toStock.quantity + qty,
          );
        } else {
          // إنشاء سجل جديد
          await database.insertWarehouseStock(WarehouseStockCompanion(
            id: Value('ws_${DateTime.now().millisecondsSinceEpoch}_$productId'),
            warehouseId: Value(toWarehouseId),
            productId: Value(productId),
            quantity: Value(qty),
            minQuantity: const Value(5),
            syncStatus: const Value('pending'),
          ));
        }

        // إضافة بند النقل
        final product = await database.getProductById(productId);
        await database.insertStockTransferItem(StockTransferItemsCompanion(
          id: Value(generateId()),
          transferId: Value(transferId),
          productId: Value(productId),
          productName: Value(product?.name ?? ''),
          requestedQuantity: Value(qty),
          transferredQuantity: Value(qty),
          syncStatus: const Value('pending'),
        ));
      }
    });

    return transferId;
  }

  // ==================== Base Repository Implementation ====================

  @override
  Future<void> syncPendingChanges() async {
    // TODO: Implement warehouse sync to cloud
    debugPrint('WarehouseRepository.syncPendingChanges() not implemented yet');
  }

  @override
  Future<void> pullFromCloud() async {
    // TODO: Implement warehouse pull from cloud
    debugPrint('WarehouseRepository.pullFromCloud() not implemented yet');
  }

  @override
  Map<String, dynamic> toFirestore(Warehouse entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'code': entity.code,
      'address': entity.address,
      'phone': entity.phone,
      'managerId': entity.managerId,
      'isDefault': entity.isDefault,
      'isActive': entity.isActive,
      'notes': entity.notes,
      'createdAt': entity.createdAt.toIso8601String(),
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  @override
  WarehousesCompanion fromFirestore(Map<String, dynamic> data, String id) {
    return WarehousesCompanion(
      id: Value(id),
      name: Value(data['name'] as String),
      code: Value(data['code'] as String?),
      address: Value(data['address'] as String?),
      phone: Value(data['phone'] as String?),
      managerId: Value(data['managerId'] as String?),
      isDefault: Value(data['isDefault'] as bool? ?? false),
      isActive: Value(data['isActive'] as bool? ?? true),
      notes: Value(data['notes'] as String?),
      syncStatus: const Value('synced'),
      createdAt: Value(DateTime.parse(data['createdAt'] as String)),
      updatedAt: Value(DateTime.parse(data['updatedAt'] as String)),
    );
  }

  @override
  void startRealtimeSync() {
    // TODO: Implement warehouse realtime sync
    debugPrint('WarehouseRepository.startRealtimeSync() not implemented yet');
  }

  @override
  void stopRealtimeSync() {
    super.stopRealtimeSync();
  }

  void dispose() {
    stopRealtimeSync();
  }
}
