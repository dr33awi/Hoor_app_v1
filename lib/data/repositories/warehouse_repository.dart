import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';

import 'base_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Warehouse Repository - مستودع المستودعات
/// ═══════════════════════════════════════════════════════════════════════════
class WarehouseRepository
    extends BaseRepository<Warehouse, WarehousesCompanion> {
  StreamSubscription? _warehouseFirestoreSubscription;

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

    if (isDefault == true) {
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

  /// تعيين مستودع كافتراضي
  Future<void> setDefaultWarehouse(String warehouseId) async {
    await database.setDefaultWarehouse(warehouseId);
  }

  /// حذف مستودع (تعطيل فقط)
  /// ✅ يتحقق من عدم وجود مخزون قبل الحذف
  Future<void> deleteWarehouse(String id) async {
    // التحقق من أن المستودع ليس افتراضي
    final warehouse = await database.getWarehouseById(id);
    if (warehouse == null) return;
    
    if (warehouse.isDefault) {
      throw Exception('لا يمكن حذف المستودع الافتراضي. عيّن مستودعاً آخر كافتراضي أولاً.');
    }
    
    // التحقق من عدم وجود مخزون في المستودع
    final stock = await database.getWarehouseStockByWarehouse(id);
    final totalQty = stock.fold<int>(0, (sum, s) => sum + s.quantity);
    
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

  // ==================== Stock Transfer Operations ====================

  /// الحصول على جميع عمليات النقل
  Future<List<StockTransfer>> getAllTransfers() =>
      database.getAllStockTransfers();

  /// مراقبة جميع عمليات النقل
  Stream<List<StockTransfer>> watchAllTransfers() =>
      database.watchAllStockTransfers();

  /// مراقبة عمليات النقل المعلقة
  Stream<List<StockTransfer>> watchPendingTransfers() =>
      database.watchPendingStockTransfers();

  /// الحصول على عملية نقل بالمعرف
  Future<StockTransfer?> getTransferById(String id) =>
      database.getStockTransferById(id);

  /// الحصول على عناصر عملية النقل
  Future<List<StockTransferItem>> getTransferItems(String transferId) =>
      database.getStockTransferItems(transferId);

  /// إنشاء عملية نقل جديدة
  /// ✅ يتحقق من كفاية المخزون قبل النقل
  Future<String> createTransfer({
    required String fromWarehouseId,
    required String toWarehouseId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    // ✅ التحقق من صحة المستودعات
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
        throw Exception(
          'الكمية المطلوبة ($requestedQty) للمنتج "${product?.name ?? productId}" '
          'أكبر من المتاح ($availableQty) في المستودع المصدر',
        );
      }
    }

    final transferId = generateId();
    final transferNumber = 'TR${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    // إنشاء عملية النقل
    await database.insertStockTransfer(StockTransfersCompanion(
      id: Value(transferId),
      transferNumber: Value(transferNumber),
      fromWarehouseId: Value(fromWarehouseId),
      toWarehouseId: Value(toWarehouseId),
      status: const Value('pending'),
      notes: Value(notes),
      syncStatus: const Value('pending'),
      transferDate: Value(now),
      createdAt: Value(now),
    ));

    // إنشاء عناصر النقل
    final transferItems = <StockTransferItemsCompanion>[];
    for (final item in items) {
      final productId = item['productId'] as String;
      final product = await database.getProductById(productId);
      if (product != null) {
        transferItems.add(StockTransferItemsCompanion(
          id: Value('ti_${DateTime.now().millisecondsSinceEpoch}_$productId'),
          transferId: Value(transferId),
          productId: Value(productId),
          productName: Value(product.name),
          requestedQuantity: Value(item['quantity'] as int),
          notes: Value(item['notes'] as String?),
          syncStatus: const Value('pending'),
          createdAt: Value(now),
        ));
      }
    }

    if (transferItems.isNotEmpty) {
      await database.insertStockTransferItems(transferItems);
    }

    return transferId;
  }

  /// بدء عملية النقل (in_transit)
  Future<void> startTransfer(String transferId) async {
    await database.updateStockTransfer(StockTransfersCompanion(
      id: Value(transferId),
      status: const Value('in_transit'),
    ));
  }

  /// إكمال عملية النقل
  Future<void> completeTransfer(String transferId) async {
    await database.completeStockTransfer(transferId);
  }

  /// إلغاء عملية النقل
  Future<void> cancelTransfer(String transferId) async {
    await database.updateStockTransfer(StockTransfersCompanion(
      id: Value(transferId),
      status: const Value('cancelled'),
    ));
  }

  /// حذف عملية النقل (للمعلقة فقط)
  Future<void> deleteTransfer(String transferId) async {
    final transfer = await getTransferById(transferId);
    if (transfer != null && transfer.status == 'pending') {
      await database.deleteStockTransferItems(transferId);
      await database.deleteStockTransfer(transferId);
    }
  }

  // ==================== Cloud Sync ====================

  @override
  Future<void> syncPendingChanges() async {
    // مزامنة المستودعات
    final allWarehouses = await database.getAllWarehouses();
    final pendingWarehouses =
        allWarehouses.where((w) => w.syncStatus == 'pending').toList();

    for (final warehouse in pendingWarehouses) {
      try {
        await collection.doc(warehouse.id).set(toFirestore(warehouse));
        await database.updateWarehouse(WarehousesCompanion(
          id: Value(warehouse.id),
          syncStatus: const Value('synced'),
        ));
      } catch (e) {
        debugPrint('Error syncing warehouse ${warehouse.id}: $e');
      }
    }

    // مزامنة عمليات النقل المكتملة
    final completedTransfers =
        await database.getStockTransfersByStatus('completed');
    for (final transfer in completedTransfers) {
      if (transfer.syncStatus == 'pending') {
        try {
          await firestore.collection('stock_transfers').doc(transfer.id).set({
            'id': transfer.id,
            'transferNumber': transfer.transferNumber,
            'fromWarehouseId': transfer.fromWarehouseId,
            'toWarehouseId': transfer.toWarehouseId,
            'status': transfer.status,
            'notes': transfer.notes,
            'transferDate': Timestamp.fromDate(transfer.transferDate),
            'completedAt': transfer.completedAt != null
                ? Timestamp.fromDate(transfer.completedAt!)
                : null,
            'createdAt': Timestamp.fromDate(transfer.createdAt),
          });
          await database.updateStockTransfer(StockTransfersCompanion(
            id: Value(transfer.id),
            syncStatus: const Value('synced'),
          ));
        } catch (e) {
          debugPrint('Error syncing transfer ${transfer.id}: $e');
        }
      }
    }
  }

  @override
  Future<void> pullFromCloud() async {
    try {
      final snapshot = await collection.get();
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final companion = fromFirestore(data, doc.id);

        final existing = await database.getWarehouseById(companion.id.value);
        if (existing == null) {
          await database.insertWarehouse(companion);
        } else {
          await database.updateWarehouse(companion);
        }
      }
    } catch (e) {
      debugPrint('Error pulling warehouses from cloud: $e');
    }
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
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': Timestamp.fromDate(entity.updatedAt),
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
      createdAt:
          Value((data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()),
      updatedAt:
          Value((data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now()),
    );
  }

  @override
  void startRealtimeSync() {
    _warehouseFirestoreSubscription?.cancel();
    _warehouseFirestoreSubscription = collection.snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final companion = fromFirestore(data, change.doc.id);
          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              database.getWarehouseById(companion.id.value).then((existing) {
                if (existing == null) {
                  database.insertWarehouse(companion);
                } else {
                  database.updateWarehouse(companion);
                }
              });
              break;
            case DocumentChangeType.removed:
              // لا نحذف المستودعات، نعطلها فقط
              break;
          }
        }
      }
    });
  }

  @override
  void stopRealtimeSync() {
    _warehouseFirestoreSubscription?.cancel();
    _warehouseFirestoreSubscription = null;
  }

  void dispose() {
    stopRealtimeSync();
  }
}
