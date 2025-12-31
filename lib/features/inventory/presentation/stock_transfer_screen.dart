import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/warehouse_repository.dart';
import '../../../data/repositories/product_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Stock Transfer Screen - شاشة نقل المخزون بين المستودعات
/// ═══════════════════════════════════════════════════════════════════════════
class StockTransferScreen extends ConsumerStatefulWidget {
  const StockTransferScreen({super.key});

  @override
  ConsumerState<StockTransferScreen> createState() =>
      _StockTransferScreenState();
}

class _StockTransferScreenState extends ConsumerState<StockTransferScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _warehouseRepo = getIt<WarehouseRepository>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نقل المخزون'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'النقل المعلق', icon: Icon(Icons.pending_actions)),
            Tab(text: 'السجل', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/inventory/transfer/new'),
            tooltip: 'نقل جديد',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingTransfersTab(warehouseRepo: _warehouseRepo),
          _TransferHistoryTab(warehouseRepo: _warehouseRepo),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Pending Transfers Tab - تبويب النقل المعلق
/// ═══════════════════════════════════════════════════════════════════════════
class _PendingTransfersTab extends StatelessWidget {
  final WarehouseRepository warehouseRepo;

  const _PendingTransfersTab({required this.warehouseRepo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StockTransfer>>(
      stream: warehouseRepo.watchPendingTransfers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transfers = snapshot.data ?? [];

        if (transfers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz,
                    size: 64.sp, color: AppColors.textSecondary),
                Gap(16.h),
                Text(
                  'لا توجد عمليات نقل معلقة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Gap(8.h),
                ElevatedButton.icon(
                  onPressed: () => context.push('/inventory/transfer/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('إنشاء نقل جديد'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: transfers.length,
          itemBuilder: (context, index) {
            final transfer = transfers[index];
            return _TransferCard(
              transfer: transfer,
              warehouseRepo: warehouseRepo,
            );
          },
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Transfer Card - بطاقة النقل
/// ═══════════════════════════════════════════════════════════════════════════
class _TransferCard extends StatelessWidget {
  final StockTransfer transfer;
  final WarehouseRepository warehouseRepo;

  const _TransferCard({
    required this.transfer,
    required this.warehouseRepo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => context.push('/inventory/transfer/${transfer.id}'),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.swap_horiz, color: _getStatusColor()),
                  Gap(8.w),
                  Expanded(
                    child: Text(
                      transfer.transferNumber,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusChip(status: transfer.status),
                ],
              ),
              Gap(12.h),
              FutureBuilder<List<Warehouse>>(
                future: Future.wait([
                  warehouseRepo.getWarehouseById(transfer.fromWarehouseId),
                  warehouseRepo.getWarehouseById(transfer.toWarehouseId),
                ]).then(
                    (warehouses) => warehouses.whereType<Warehouse>().toList()),
                builder: (context, snapshot) {
                  final warehouses = snapshot.data ?? [];
                  final fromName =
                      warehouses.isNotEmpty ? warehouses[0].name : '---';
                  final toName =
                      warehouses.length > 1 ? warehouses[1].name : '---';

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'من:',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              fromName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'إلى:',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              toName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              Gap(12.h),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14.sp, color: AppColors.textSecondary),
                  Gap(4.w),
                  Text(
                    DateFormat('yyyy/MM/dd HH:mm')
                        .format(transfer.transferDate),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (transfer.status == 'pending' ||
                  transfer.status == 'in_transit') ...[
                Gap(12.h),
                Row(
                  children: [
                    if (transfer.status == 'pending') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancelTransfer(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      Gap(12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _startTransfer(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                          ),
                          child: const Text('بدء النقل'),
                        ),
                      ),
                    ] else if (transfer.status == 'in_transit') ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _completeTransfer(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                          child: const Text('تأكيد الاستلام'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
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
        return AppColors.textSecondary;
    }
  }

  void _startTransfer(BuildContext context) async {
    try {
      await warehouseRepo.startTransfer(transfer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم بدء عملية النقل')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  void _completeTransfer(BuildContext context) async {
    try {
      await warehouseRepo.completeTransfer(transfer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إكمال عملية النقل بنجاح')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  void _cancelTransfer(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل أنت متأكد من إلغاء عملية النقل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await warehouseRepo.cancelTransfer(transfer.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إلغاء عملية النقل')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e')),
          );
        }
      }
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Status Chip
/// ═══════════════════════════════════════════════════════════════════════════
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          fontSize: 12.sp,
          color: _getColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'in_transit':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getLabel() {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'in_transit':
        return 'قيد النقل';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Transfer History Tab - تبويب سجل النقل
/// ═══════════════════════════════════════════════════════════════════════════
class _TransferHistoryTab extends StatelessWidget {
  final WarehouseRepository warehouseRepo;

  const _TransferHistoryTab({required this.warehouseRepo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StockTransfer>>(
      stream: warehouseRepo.watchAllTransfers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transfers = snapshot.data ?? [];
        final completedTransfers = transfers
            .where((t) => t.status == 'completed' || t.status == 'cancelled')
            .toList();

        if (completedTransfers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history,
                    size: 64.sp, color: AppColors.textSecondary),
                Gap(16.h),
                Text(
                  'لا يوجد سجل نقل',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: completedTransfers.length,
          itemBuilder: (context, index) {
            final transfer = completedTransfers[index];
            return _TransferCard(
              transfer: transfer,
              warehouseRepo: warehouseRepo,
            );
          },
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// New Transfer Screen - شاشة إنشاء نقل جديد
/// ═══════════════════════════════════════════════════════════════════════════
class NewStockTransferScreen extends ConsumerStatefulWidget {
  const NewStockTransferScreen({super.key});

  @override
  ConsumerState<NewStockTransferScreen> createState() =>
      _NewStockTransferScreenState();
}

class _NewStockTransferScreenState
    extends ConsumerState<NewStockTransferScreen> {
  final _warehouseRepo = getIt<WarehouseRepository>();
  final _productRepo = getIt<ProductRepository>();
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  List<Warehouse> _warehouses = [];
  String? _fromWarehouseId;
  String? _toWarehouseId;
  final List<_TransferItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
  }

  Future<void> _loadWarehouses() async {
    final warehouses = await _warehouseRepo.getAllWarehouses();
    setState(() {
      _warehouses = warehouses.where((w) => w.isActive).toList();
      if (_warehouses.isNotEmpty) {
        _fromWarehouseId = _warehouses.first.id;
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('نقل جديد'),
        actions: [
          TextButton(
            onPressed: _items.isEmpty ? null : _createTransfer,
            child: const Text('حفظ'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // From Warehouse
            DropdownButtonFormField<String>(
              value: _fromWarehouseId,
              decoration: const InputDecoration(
                labelText: 'من المستودع',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warehouse),
              ),
              items: _warehouses.map((w) {
                return DropdownMenuItem(
                  value: w.id,
                  child: Text(w.name),
                );
              }).toList(),
              validator: (v) => v == null ? 'اختر المستودع' : null,
              onChanged: (value) {
                setState(() {
                  _fromWarehouseId = value;
                  _items.clear();
                });
              },
            ),
            Gap(16.h),

            // To Warehouse
            DropdownButtonFormField<String>(
              value: _toWarehouseId,
              decoration: const InputDecoration(
                labelText: 'إلى المستودع',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warehouse),
              ),
              items:
                  _warehouses.where((w) => w.id != _fromWarehouseId).map((w) {
                return DropdownMenuItem(
                  value: w.id,
                  child: Text(w.name),
                );
              }).toList(),
              validator: (v) => v == null ? 'اختر المستودع' : null,
              onChanged: (value) => setState(() => _toWarehouseId = value),
            ),
            Gap(16.h),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
            Gap(24.h),

            // Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المنتجات المراد نقلها',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed:
                      _fromWarehouseId == null ? null : _showAddProductDialog,
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                ),
              ],
            ),
            Gap(8.h),

            if (_items.isEmpty)
              Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 48.sp, color: AppColors.textSecondary),
                    Gap(8.h),
                    Text(
                      'لم يتم إضافة منتجات بعد',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_items.length, (index) {
                final item = _items[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(item.productName),
                    subtitle:
                        Text('الكمية المتوفرة: ${item.availableQuantity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        setState(() => _items.removeAt(index));
                      },
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() async {
    if (_fromWarehouseId == null) return;

    final stock = await _warehouseRepo.getWarehouseStock(_fromWarehouseId!);
    final products = await _productRepo.getAllProducts();

    final availableStock = stock.where((s) => s.quantity > 0).toList();

    if (availableStock.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('لا توجد منتجات متوفرة في هذا المستودع')),
        );
      }
      return;
    }

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Text(
                        'اختر المنتجات',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: availableStock.length,
                    itemBuilder: (context, index) {
                      final stockItem = availableStock[index];
                      final product = products.firstWhere(
                        (p) => p.id == stockItem.productId,
                        orElse: () => Product(
                          id: '',
                          name: 'غير معروف',
                          purchasePrice: 0,
                          salePrice: 0,
                          quantity: 0,
                          minQuantity: 0,
                          isActive: false,
                          syncStatus: '',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );

                      final alreadyAdded =
                          _items.any((i) => i.productId == stockItem.productId);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text('${stockItem.quantity}'),
                        ),
                        title: Text(product.name),
                        subtitle: Text('المتوفر: ${stockItem.quantity}'),
                        trailing: alreadyAdded
                            ? const Icon(Icons.check, color: AppColors.success)
                            : null,
                        enabled: !alreadyAdded,
                        onTap: () {
                          Navigator.pop(context);
                          _showQuantityDialog(
                            productId: stockItem.productId,
                            productName: product.name,
                            availableQuantity: stockItem.quantity,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  void _showQuantityDialog({
    required String productId,
    required String productName,
    required int availableQuantity,
  }) {
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(productName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الكمية المتوفرة: $availableQuantity'),
            Gap(16.h),
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'الكمية المراد نقلها',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              if (quantity > 0 && quantity <= availableQuantity) {
                setState(() {
                  _items.add(_TransferItem(
                    productId: productId,
                    productName: productName,
                    quantity: quantity,
                    availableQuantity: availableQuantity,
                  ));
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الكمية غير صحيحة')),
                );
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _createTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف منتجات للنقل')),
      );
      return;
    }

    try {
      await _warehouseRepo.createTransfer(
        fromWarehouseId: _fromWarehouseId!,
        toWarehouseId: _toWarehouseId!,
        items: _items
            .map((i) => {
                  'productId': i.productId,
                  'quantity': i.quantity,
                })
            .toList(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء عملية النقل بنجاح')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }
}

class _TransferItem {
  final String productId;
  final String productName;
  final int quantity;
  final int availableQuantity;

  _TransferItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.availableQuantity,
  });
}
