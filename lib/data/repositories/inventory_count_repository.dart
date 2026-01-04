import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';

import 'base_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Inventory Count Repository - مستودع الجرد الدوري
/// ═══════════════════════════════════════════════════════════════════════════
class InventoryCountRepository
    extends BaseRepository<InventoryCount, InventoryCountsCompanion> {
  StreamSubscription? _countFirestoreSubscription;

  InventoryCountRepository({
    required super.database,
    required super.firestore,
  }) : super(collectionName: 'inventory_counts');

  // ==================== Local Operations ====================

  /// الحصول على جميع عمليات الجرد
  Future<List<InventoryCount>> getAllCounts() =>
      database.getAllInventoryCounts();

  /// مراقبة جميع عمليات الجرد
  Stream<List<InventoryCount>> watchAllCounts() =>
      database.watchAllInventoryCounts();

  /// الحصول على عمليات الجرد النشطة
  Stream<List<InventoryCount>> watchActiveCounts() =>
      database.watchActiveInventoryCounts();

  /// الحصول على عمليات الجرد حسب الحالة
  Future<List<InventoryCount>> getCountsByStatus(String status) =>
      database.getInventoryCountsByStatus(status);

  /// الحصول على جرد بالمعرف
  Future<InventoryCount?> getCountById(String id) =>
      database.getInventoryCountById(id);

  /// الحصول على عناصر الجرد
  Future<List<InventoryCountItem>> getCountItems(String countId) =>
      database.getInventoryCountItems(countId);

  /// مراقبة عناصر الجرد
  Stream<List<InventoryCountItem>> watchCountItems(String countId) =>
      database.watchInventoryCountItems(countId);

  /// الحصول على إحصائيات الجرد
  Future<Map<String, dynamic>> getCountStats(String countId) =>
      database.getInventoryCountStats(countId);

  /// إنشاء جرد جديد
  Future<String> createCount({
    required String warehouseId,
    String countType = 'full',
    String? notes,
    List<String>? productIds,
  }) async {
    final countId = await database.createInventoryCount(
      warehouseId: warehouseId,
      countType: countType,
      notes: notes,
      productIds: productIds,
    );
    return countId;
  }

  /// بدء عملية الجرد
  Future<void> startCount(String countId) async {
    await database.updateInventoryCount(InventoryCountsCompanion(
      id: Value(countId),
      status: const Value('in_progress'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// تحديث كمية عنصر في الجرد
  Future<void> updateItemQuantity(
    String itemId,
    int physicalQuantity, {
    String? reason,
  }) async {
    await database.updateCountItemPhysicalQuantity(
      itemId,
      physicalQuantity,
      reason,
    );
  }

  /// إكمال الجرد وإنشاء تسوية
  Future<String?> completeCount(String countId) async {
    return await database.completeInventoryCount(countId);
  }

  /// إلغاء الجرد
  Future<void> cancelCount(String countId) async {
    await database.updateInventoryCount(InventoryCountsCompanion(
      id: Value(countId),
      status: const Value('cancelled'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// حذف الجرد (للمسودات فقط)
  Future<void> deleteCount(String countId) async {
    final count = await getCountById(countId);
    if (count != null && count.status == 'draft') {
      await database.deleteInventoryCountItems(countId);
      await database.deleteInventoryCount(countId);
    }
  }

  /// البحث في عناصر الجرد بالباركود
  Future<InventoryCountItem?> findItemByBarcode(
    String countId,
    String barcode,
  ) async {
    final items = await getCountItems(countId);
    try {
      return items.firstWhere((item) => item.productBarcode == barcode);
    } catch (e) {
      return null;
    }
  }

  /// الحصول على العناصر غير المجرودة
  Future<List<InventoryCountItem>> getUncountedItems(String countId) =>
      database.getUncountedItems(countId);

  /// الحصول على العناصر التي بها فروقات
  Future<List<InventoryCountItem>> getItemsWithVariance(String countId) =>
      database.getItemsWithVariance(countId);

  // ==================== Adjustments ====================

  /// الحصول على جميع التسويات
  Future<List<InventoryAdjustment>> getAllAdjustments() =>
      database.getAllInventoryAdjustments();

  /// مراقبة التسويات
  Stream<List<InventoryAdjustment>> watchAllAdjustments() =>
      database.watchAllInventoryAdjustments();

  /// الحصول على التسويات المعلقة
  Future<List<InventoryAdjustment>> getPendingAdjustments() =>
      database.getPendingAdjustments();

  /// الحصول على تسوية بالمعرف
  Future<InventoryAdjustment?> getAdjustmentById(String id) =>
      database.getInventoryAdjustmentById(id);

  /// الحصول على عناصر التسوية
  Future<List<InventoryAdjustmentItem>> getAdjustmentItems(
          String adjustmentId) =>
      database.getInventoryAdjustmentItems(adjustmentId);

  /// تطبيق التسوية
  Future<void> applyAdjustment(String adjustmentId) async {
    await database.applyInventoryAdjustment(adjustmentId);
  }

  /// رفض التسوية
  Future<void> rejectAdjustment(String adjustmentId, {String? reason}) async {
    await database.updateInventoryAdjustment(InventoryAdjustmentsCompanion(
      id: Value(adjustmentId),
      status: const Value('rejected'),
      notes: Value(reason),
    ));
  }

  /// إنشاء تسوية يدوية
  Future<String> createManualAdjustment({
    required String warehouseId,
    required String type,
    required String reason,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final adjustmentId = 'adj_${DateTime.now().millisecondsSinceEpoch}';
    final adjustmentNumber = 'ADJ${DateTime.now().millisecondsSinceEpoch}';

    double totalValue = 0;
    final adjustmentItems = <InventoryAdjustmentItemsCompanion>[];

    for (final item in items) {
      final productId = item['productId'] as String;
      final product = await database.getProductById(productId);
      if (product == null) continue;

      final stock = await database.getWarehouseStockByProductAndWarehouse(
        productId,
        warehouseId,
      );
      final currentQty = stock?.quantity ?? 0;
      final adjustedQty = item['quantity'] as int;
      final newQty = type == 'increase'
          ? currentQty + adjustedQty
          : currentQty - adjustedQty;
      final itemValue = adjustedQty * product.purchasePrice;

      totalValue += itemValue.abs();

      adjustmentItems.add(InventoryAdjustmentItemsCompanion(
        id: Value('ai_${DateTime.now().millisecondsSinceEpoch}_$productId'),
        adjustmentId: Value(adjustmentId),
        productId: Value(productId),
        productName: Value(product.name),
        quantityBefore: Value(currentQty),
        quantityAdjusted:
            Value(type == 'increase' ? adjustedQty : -adjustedQty),
        quantityAfter: Value(newQty),
        unitCost: Value(product.purchasePrice),
        adjustmentValue: Value(itemValue),
        reason: Value(item['reason'] as String?),
      ));
    }

    await database.insertInventoryAdjustment(InventoryAdjustmentsCompanion(
      id: Value(adjustmentId),
      adjustmentNumber: Value(adjustmentNumber),
      warehouseId: Value(warehouseId),
      type: Value(type),
      reason: Value(reason),
      totalValue: Value(totalValue),
      notes: Value(notes),
    ));

    await database.insertInventoryAdjustmentItems(adjustmentItems);

    return adjustmentId;
  }

  // ==================== Cloud Sync ====================

  @override
  Future<void> syncPendingChanges() async {
    // مزامنة عمليات الجرد
    final pendingCounts =
        await database.getInventoryCountsByStatus('completed');
    for (final count in pendingCounts) {
      if (count.syncStatus == 'pending') {
        try {
          await collection.doc(count.id).set(toFirestore(count));
          await database.updateInventoryCount(InventoryCountsCompanion(
            id: Value(count.id),
            syncStatus: const Value('synced'),
          ));
        } catch (e) {
          debugPrint('Error syncing inventory count ${count.id}: $e');
        }
      }
    }
  }

  @override
  Future<void> pullFromCloud() async {
    // الجرد الدوري عادة لا يُسحب من السحابة
  }

  @override
  Map<String, dynamic> toFirestore(InventoryCount entity) {
    return {
      'id': entity.id,
      'countNumber': entity.countNumber,
      'warehouseId': entity.warehouseId,
      'status': entity.status,
      'countType': entity.countType,
      'notes': entity.notes,
      'createdBy': entity.createdBy,
      'approvedBy': entity.approvedBy,
      'totalItems': entity.totalItems,
      'countedItems': entity.countedItems,
      'varianceItems': entity.varianceItems,
      'totalVarianceValue': entity.totalVarianceValue,
      'countDate': Timestamp.fromDate(entity.countDate),
      'completedAt': entity.completedAt != null
          ? Timestamp.fromDate(entity.completedAt!)
          : null,
      'approvedAt': entity.approvedAt != null
          ? Timestamp.fromDate(entity.approvedAt!)
          : null,
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': Timestamp.fromDate(entity.updatedAt),
    };
  }

  @override
  InventoryCountsCompanion fromFirestore(Map<String, dynamic> data, String id) {
    return InventoryCountsCompanion(
      id: Value(id),
      countNumber: Value(data['countNumber'] as String),
      warehouseId: Value(data['warehouseId'] as String),
      status: Value(data['status'] as String? ?? 'draft'),
      countType: Value(data['countType'] as String? ?? 'full'),
      notes: Value(data['notes'] as String?),
      createdBy: Value(data['createdBy'] as String?),
      approvedBy: Value(data['approvedBy'] as String?),
      totalItems: Value(data['totalItems'] as int? ?? 0),
      countedItems: Value(data['countedItems'] as int? ?? 0),
      varianceItems: Value(data['varianceItems'] as int? ?? 0),
      totalVarianceValue: Value(data['totalVarianceValue'] as double? ?? 0),
      syncStatus: const Value('synced'),
      countDate:
          Value((data['countDate'] as Timestamp?)?.toDate() ?? DateTime.now()),
      completedAt: Value((data['completedAt'] as Timestamp?)?.toDate()),
      approvedAt: Value((data['approvedAt'] as Timestamp?)?.toDate()),
      createdAt:
          Value((data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()),
      updatedAt:
          Value((data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now()),
    );
  }

  @override
  void startRealtimeSync() {
    // لا نحتاج مزامنة في الوقت الفعلي للجرد
  }

  @override
  void stopRealtimeSync() {
    _countFirestoreSubscription?.cancel();
    _countFirestoreSubscription = null;
  }

  void dispose() {
    stopRealtimeSync();
  }
}
