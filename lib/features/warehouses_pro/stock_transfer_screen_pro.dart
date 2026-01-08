// ═══════════════════════════════════════════════════════════════════════════
// Stock Transfer Screen Pro - Enterprise Accounting Design
// Transfer stock between warehouses
// ═══════════════════════════════════════════════════════════════════════════

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../data/database/app_database.dart';

// ═══════════════════════════════════════════════════════════════════════════
// STOCK TRANSFERS STREAM PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final stockTransfersProvider = StreamProvider<List<StockTransfer>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllStockTransfers();
});

// ═══════════════════════════════════════════════════════════════════════════
// STOCK TRANSFER SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class StockTransferScreenPro extends ConsumerStatefulWidget {
  const StockTransferScreenPro({super.key});

  @override
  ConsumerState<StockTransferScreenPro> createState() =>
      _StockTransferScreenProState();
}

class _StockTransferScreenProState
    extends ConsumerState<StockTransferScreenPro> {
  String _filterStatus = 'all'; // all, pending, in_transit, completed

  @override
  Widget build(BuildContext context) {
    final transfersAsync = ref.watch(stockTransfersProvider);
    final warehousesAsync = ref.watch(warehousesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            transfersAsync.when(
              loading: () => ProHeader(
                title: 'نقل المخزون',
                subtitle: '0 عملية نقل',
                onBack: () => context.go('/warehouses'),
              ),
              error: (_, __) => ProHeader(
                title: 'نقل المخزون',
                subtitle: 'خطأ',
                onBack: () => context.go('/warehouses'),
              ),
              data: (transfers) => ProHeader(
                title: 'نقل المخزون',
                subtitle: '${transfers.length} عملية نقل',
                onBack: () => context.go('/warehouses'),
              ),
            ),
            // Filter Tabs
            _buildFilterTabs(),
            // Transfers List
            Expanded(
              child: transfersAsync.when(
                loading: () => ProLoadingState.list(),
                error: (error, _) =>
                    ProEmptyState.error(error: error.toString()),
                data: (transfers) {
                  final warehouses = warehousesAsync.asData?.value ?? [];
                  return _buildTransfersList(transfers, warehouses);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewTransferDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.swap_horiz, color: Colors.white),
        label: Text(
          'نقل جديد',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 44.h,
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'الكل',
            isSelected: _filterStatus == 'all',
            onTap: () => setState(() => _filterStatus = 'all'),
          ),
          SizedBox(width: AppSpacing.xs),
          _FilterChip(
            label: 'قيد الانتظار',
            isSelected: _filterStatus == 'pending',
            onTap: () => setState(() => _filterStatus = 'pending'),
            color: AppColors.warning,
          ),
          SizedBox(width: AppSpacing.xs),
          _FilterChip(
            label: 'جاري النقل',
            isSelected: _filterStatus == 'in_transit',
            onTap: () => setState(() => _filterStatus = 'in_transit'),
            color: AppColors.info,
          ),
          SizedBox(width: AppSpacing.xs),
          _FilterChip(
            label: 'مكتمل',
            isSelected: _filterStatus == 'completed',
            onTap: () => setState(() => _filterStatus = 'completed'),
            color: AppColors.success,
          ),
          SizedBox(width: AppSpacing.xs),
          _FilterChip(
            label: 'ملغي',
            isSelected: _filterStatus == 'cancelled',
            onTap: () => setState(() => _filterStatus = 'cancelled'),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildTransfersList(
      List<StockTransfer> transfers, List<Warehouse> warehouses) {
    final warehouseMap = {for (var w in warehouses) w.id: w};

    var filtered = transfers;
    if (_filterStatus != 'all') {
      filtered = transfers.where((t) => t.status == _filterStatus).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.swap_horiz_outlined,
                size: 32.sp,
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'لا توجد عمليات نقل',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              'ابدأ بنقل منتجات بين المستودعات',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.sm),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final transfer = filtered[index];
        final fromWarehouse = warehouseMap[transfer.fromWarehouseId];
        final toWarehouse = warehouseMap[transfer.toWarehouseId];
        return _TransferCard(
          transfer: transfer,
          fromWarehouse: fromWarehouse,
          toWarehouse: toWarehouse,
          onTap: () =>
              _showTransferDetails(transfer, fromWarehouse, toWarehouse),
          onComplete:
              transfer.status == 'pending' || transfer.status == 'in_transit'
                  ? () => _completeTransfer(transfer)
                  : null,
          onCancel: transfer.status == 'pending'
              ? () => _cancelTransfer(transfer)
              : null,
        );
      },
    );
  }

  void _showNewTransferDialog() {
    final warehousesAsync = ref.read(warehousesStreamProvider);
    final warehouses = warehousesAsync.asData?.value ?? [];

    if (warehouses.length < 2) {
      ProSnackbar.warning(context, 'تحتاج لمستودعين على الأقل لإجراء نقل');
      return;
    }

    String? fromWarehouseId;
    String? toWarehouseId;
    final selectedProducts = <String, int>{}; // productId: quantity

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: AppSpacing.md),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'نقل مخزون جديد',
                        style: AppTypography.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From Warehouse
                      Text(
                        'من المستودع',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: fromWarehouseId,
                            isExpanded: true,
                            hint: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                'اختر المستودع المصدر',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            items: warehouses
                                .where((w) => w.id != toWarehouseId)
                                .map((w) => DropdownMenuItem(
                                      value: w.id,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                        ),
                                        child: Text(w.name),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setModalState(() {
                                fromWarehouseId = value;
                                selectedProducts.clear();
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      // To Warehouse
                      Text(
                        'إلى المستودع',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: toWarehouseId,
                            isExpanded: true,
                            hint: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                'اختر المستودع الهدف',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            items: warehouses
                                .where((w) => w.id != fromWarehouseId)
                                .map((w) => DropdownMenuItem(
                                      value: w.id,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                        ),
                                        child: Text(w.name),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setModalState(() => toWarehouseId = value);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      // Products Selection
                      if (fromWarehouseId != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المنتجات للنقل',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showAddProductsToTransfer(
                                fromWarehouseId!,
                                selectedProducts,
                                (products) =>
                                    setModalState(() => selectedProducts
                                      ..clear()
                                      ..addAll(products)),
                              ),
                              icon: Icon(Icons.add,
                                  size: 18.sp, color: AppColors.primary),
                              label: Text(
                                'إضافة منتجات',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xs),
                        if (selectedProducts.isEmpty)
                          Container(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 32.sp,
                                    color: AppColors.textTertiary,
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'اختر المنتجات للنقل',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          _buildSelectedProductsList(
                            selectedProducts,
                            (productId) => setModalState(
                                () => selectedProducts.remove(productId)),
                            (productId, qty) => setModalState(
                                () => selectedProducts[productId] = qty),
                          ),
                      ],
                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              // Submit Button
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: ProButton(
                  label: 'إنشاء عملية النقل',
                  fullWidth: true,
                  onPressed: fromWarehouseId != null &&
                          toWarehouseId != null &&
                          selectedProducts.isNotEmpty
                      ? () async {
                          await _createTransfer(
                            fromWarehouseId!,
                            toWarehouseId!,
                            selectedProducts,
                          );
                          if (context.mounted) Navigator.pop(context);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedProductsList(
    Map<String, int> selectedProducts,
    Function(String) onRemove,
    Function(String, int) onUpdateQuantity,
  ) {
    final productsAsync = ref.watch(activeProductsStreamProvider);
    final products = productsAsync.asData?.value ?? [];
    final productMap = {for (var p in products) p.id: p};

    return Column(
      children: selectedProducts.entries.map((entry) {
        final product = productMap[entry.key];
        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.xs),
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'منتج غير معروف',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'الكمية: ${entry.value}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: entry.value > 1
                        ? () => onUpdateQuantity(entry.key, entry.value - 1)
                        : null,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 20.sp,
                      color: entry.value > 1
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 32.w,
                      minHeight: 32.w,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  Container(
                    width: 40.w,
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.value}',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        onUpdateQuantity(entry.key, entry.value + 1),
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 32.w,
                      minHeight: 32.w,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              IconButton(
                onPressed: () => onRemove(entry.key),
                icon: Icon(
                  Icons.close,
                  size: 18.sp,
                  color: AppColors.error,
                ),
                constraints: BoxConstraints(
                  minWidth: 32.w,
                  minHeight: 32.w,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showAddProductsToTransfer(
    String warehouseId,
    Map<String, int> currentSelection,
    Function(Map<String, int>) onUpdate,
  ) {
    final db = ref.read(databaseProvider);
    final tempSelection = Map<String, int>.from(currentSelection);
    List<WarehouseStockData>? cachedStockItems;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: AppSpacing.md),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'اختيار المنتجات',
                        style: AppTypography.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Select All / Deselect All Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: cachedStockItems != null &&
                                cachedStockItems!.isNotEmpty
                            ? () {
                                setModalState(() {
                                  for (var item in cachedStockItems!) {
                                    if (item.quantity > 0) {
                                      tempSelection[item.productId] =
                                          item.quantity;
                                    }
                                  }
                                });
                              }
                            : null,
                        icon: Icon(Icons.select_all, size: 18.sp),
                        label: Text('تحديد الكل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: tempSelection.isNotEmpty
                            ? () {
                                setModalState(() {
                                  tempSelection.clear();
                                });
                              }
                            : null,
                        icon: Icon(Icons.deselect, size: 18.sp),
                        label: Text('إلغاء التحديد'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(
                              color: tempSelection.isNotEmpty
                                  ? AppColors.error
                                  : AppColors.border),
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              // Products from warehouse
              Expanded(
                child: FutureBuilder<List<WarehouseStockData>>(
                  future: db.getWarehouseStockByWarehouse(warehouseId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ProLoadingState.list();
                    }

                    if (snapshot.hasError) {
                      return ProEmptyState.error(
                          error: snapshot.error.toString());
                    }

                    final stockItems = snapshot.data ?? [];
                    cachedStockItems = stockItems;

                    if (stockItems.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد منتجات في هذا المستودع',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return Consumer(
                      builder: (context, ref, _) {
                        final productsAsync =
                            ref.watch(activeProductsStreamProvider);
                        final products = productsAsync.asData?.value ?? [];
                        final productMap = {for (var p in products) p.id: p};

                        return ListView.builder(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          itemCount: stockItems.length,
                          itemBuilder: (context, index) {
                            final stockItem = stockItems[index];
                            final product = productMap[stockItem.productId];
                            final isSelected =
                                tempSelection.containsKey(stockItem.productId);
                            final selectedQty =
                                tempSelection[stockItem.productId] ?? 0;

                            return Container(
                              margin: EdgeInsets.only(bottom: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.05)
                                    : AppColors.background,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 20.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  product?.name ?? 'منتج غير معروف',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'المتاح: ${stockItem.quantity}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: selectedQty > 1
                                                ? () => setModalState(() {
                                                      tempSelection[stockItem
                                                              .productId] =
                                                          selectedQty - 1;
                                                    })
                                                : null,
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                              color: selectedQty > 1
                                                  ? AppColors.primary
                                                  : AppColors.textTertiary,
                                            ),
                                          ),
                                          Text(
                                            '$selectedQty',
                                            style: AppTypography.titleSmall,
                                          ),
                                          IconButton(
                                            onPressed:
                                                selectedQty < stockItem.quantity
                                                    ? () => setModalState(() {
                                                          tempSelection[stockItem
                                                                  .productId] =
                                                              selectedQty + 1;
                                                        })
                                                    : null,
                                            icon: Icon(
                                              Icons.add_circle_outline,
                                              color: selectedQty <
                                                      stockItem.quantity
                                                  ? AppColors.primary
                                                  : AppColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      )
                                    : null,
                                onTap: stockItem.quantity > 0
                                    ? () {
                                        setModalState(() {
                                          if (isSelected) {
                                            tempSelection
                                                .remove(stockItem.productId);
                                          } else {
                                            tempSelection[stockItem.productId] =
                                                1;
                                          }
                                        });
                                      }
                                    : null,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              // Confirm Button
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: ProButton(
                  label: 'تأكيد الاختيار (${tempSelection.length})',
                  fullWidth: true,
                  onPressed: tempSelection.isNotEmpty
                      ? () {
                          onUpdate(tempSelection);
                          Navigator.pop(context);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTransfer(
    String fromWarehouseId,
    String toWarehouseId,
    Map<String, int> products,
  ) async {
    try {
      final db = ref.read(databaseProvider);
      final transferId = DateTime.now().millisecondsSinceEpoch.toString();
      final transferNumber =
          'TR${DateTime.now().millisecondsSinceEpoch % 100000}';

      // Create transfer
      await db.insertStockTransfer(StockTransfersCompanion(
        id: drift.Value(transferId),
        transferNumber: drift.Value(transferNumber),
        fromWarehouseId: drift.Value(fromWarehouseId),
        toWarehouseId: drift.Value(toWarehouseId),
        status: const drift.Value('pending'),
        syncStatus: const drift.Value('pending'),
      ));

      // Create transfer items
      final productsData = await db.getAllProducts();
      final productMap = {for (var p in productsData) p.id: p};

      final items = products.entries.map((entry) {
        final product = productMap[entry.key];
        return StockTransferItemsCompanion(
          id: drift.Value('${transferId}_${entry.key}'),
          transferId: drift.Value(transferId),
          productId: drift.Value(entry.key),
          productName: drift.Value(product?.name ?? 'منتج غير معروف'),
          requestedQuantity: drift.Value(entry.value),
          transferredQuantity: const drift.Value(0),
          syncStatus: const drift.Value('pending'),
        );
      }).toList();

      await db.insertStockTransferItems(items);

      if (mounted) {
        ProSnackbar.success(context, 'تم إنشاء عملية النقل بنجاح');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في إنشاء عملية النقل: $e');
      }
    }
  }

  void _showTransferDetails(
    StockTransfer transfer,
    Warehouse? fromWarehouse,
    Warehouse? toWarehouse,
  ) async {
    final db = ref.read(databaseProvider);
    final items = await db.getStockTransferItems(transfer.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: AppSpacing.md),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'عملية نقل #${transfer.transferNumber}',
                          style: AppTypography.titleLarge,
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        _buildStatusBadge(transfer.status),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Transfer Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.warehouse_outlined,
                            size: 24.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(height: AppSpacing.xxs),
                          Text(
                            'من',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            fromWarehouse?.name ?? 'غير معروف',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 24.sp,
                      color: AppColors.textTertiary,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.warehouse_outlined,
                            size: 24.sp,
                            color: AppColors.success,
                          ),
                          SizedBox(height: AppSpacing.xxs),
                          Text(
                            'إلى',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            toWarehouse?.name ?? 'غير معروف',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            // Items List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Text(
                    'المنتجات (${items.length})',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: AppSpacing.xs),
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.requestedQuantity}',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (transfer.status == 'completed')
                              Text(
                                'تم نقل ${item.transferredQuantity}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Actions
            if (transfer.status == 'pending' || transfer.status == 'in_transit')
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    if (transfer.status == 'pending')
                      Expanded(
                        child: ProButton(
                          label: 'إلغاء',
                          type: ProButtonType.outlined,
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelTransfer(transfer);
                          },
                        ),
                      ),
                    if (transfer.status == 'pending')
                      SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ProButton(
                        label: 'تأكيد النقل',
                        onPressed: () {
                          Navigator.pop(context);
                          _completeTransfer(transfer);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'قيد الانتظار';
        break;
      case 'in_transit':
        color = AppColors.info;
        label = 'جاري النقل';
        break;
      case 'completed':
        color = AppColors.success;
        label = 'مكتمل';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'ملغي';
        break;
      default:
        color = AppColors.textTertiary;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _completeTransfer(StockTransfer transfer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text('تأكيد النقل', style: AppTypography.titleLarge),
        content: Text(
          'هل تريد تأكيد عملية النقل؟\nسيتم خصم الكميات من المستودع المصدر وإضافتها للمستودع الهدف.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('تأكيد', style: TextStyle(color: AppColors.success)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final db = ref.read(databaseProvider);
      await db.completeStockTransfer(transfer.id);

      if (mounted) {
        ProSnackbar.success(context, 'تم إكمال عملية النقل بنجاح');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في إكمال عملية النقل: $e');
      }
    }
  }

  Future<void> _cancelTransfer(StockTransfer transfer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text('إلغاء النقل', style: AppTypography.titleLarge),
        content: Text(
          'هل تريد إلغاء عملية النقل؟',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('لا', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('نعم، إلغاء', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final db = ref.read(databaseProvider);
      await db.updateStockTransfer(StockTransfersCompanion(
        id: drift.Value(transfer.id),
        status: const drift.Value('cancelled'),
      ));

      if (mounted) {
        ProSnackbar.success(context, 'تم إلغاء عملية النقل');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في إلغاء عملية النقل: $e');
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FILTER CHIP WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? chipColor.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? chipColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TRANSFER CARD WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _TransferCard extends StatelessWidget {
  final StockTransfer transfer;
  final Warehouse? fromWarehouse;
  final Warehouse? toWarehouse;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const _TransferCard({
    required this.transfer,
    required this.fromWarehouse,
    required this.toWarehouse,
    required this.onTap,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.swap_horiz,
                  size: 22.sp,
                  color: _getStatusColor(),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${transfer.transferNumber}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        _buildStatusBadge(),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      DateFormat('yyyy/MM/dd - HH:mm')
                          .format(transfer.transferDate),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          // Warehouses Row
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warehouse_outlined,
                        size: 14.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          fromWarehouse?.name ?? 'غير معروف',
                          style: AppTypography.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 14.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warehouse_outlined,
                        size: 14.sp,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          toWarehouse?.name ?? 'غير معروف',
                          style: AppTypography.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Quick Actions for pending transfers
          if (onCancel != null || onComplete != null) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (onCancel != null)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onCancel,
                      icon: Icon(Icons.cancel_outlined,
                          size: 16.sp, color: AppColors.error),
                      label: Text(
                        'إلغاء',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.error),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      ),
                    ),
                  ),
                if (onCancel != null && onComplete != null)
                  SizedBox(width: AppSpacing.sm),
                if (onComplete != null)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onComplete,
                      icon: Icon(Icons.check_circle_outline,
                          size: 16.sp, color: AppColors.success),
                      label: Text(
                        'تأكيد النقل',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.success),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            AppColors.success.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (transfer.status) {
      case 'pending':
        return AppColors.warning;
      case 'in_transit':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  Widget _buildStatusBadge() {
    String label;
    switch (transfer.status) {
      case 'pending':
        label = 'قيد الانتظار';
        break;
      case 'in_transit':
        label = 'جاري النقل';
        break;
      case 'completed':
        label = 'مكتمل';
        break;
      case 'cancelled':
        label = 'ملغي';
        break;
      default:
        label = transfer.status;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
