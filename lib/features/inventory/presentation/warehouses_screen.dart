import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/warehouse_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Warehouses Screen - شاشة إدارة المستودعات
/// ═══════════════════════════════════════════════════════════════════════════
class WarehousesScreen extends ConsumerStatefulWidget {
  const WarehousesScreen({super.key});

  @override
  ConsumerState<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends ConsumerState<WarehousesScreen> {
  final _warehouseRepo = getIt<WarehouseRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستودعات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showWarehouseDialog(),
            tooltip: 'إضافة مستودع',
          ),
        ],
      ),
      body: StreamBuilder<List<Warehouse>>(
        stream: _warehouseRepo.watchAllWarehouses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final warehouses = snapshot.data ?? [];

          if (warehouses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warehouse_outlined,
                      size: 64.sp, color: AppColors.textSecondary),
                  Gap(16.h),
                  Text(
                    'لا توجد مستودعات',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Gap(16.h),
                  ElevatedButton.icon(
                    onPressed: () => _showWarehouseDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة مستودع'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: warehouses.length,
            itemBuilder: (context, index) {
              final warehouse = warehouses[index];
              return _WarehouseCard(
                warehouse: warehouse,
                warehouseRepo: _warehouseRepo,
                onEdit: () => _showWarehouseDialog(warehouse: warehouse),
              );
            },
          );
        },
      ),
    );
  }

  void _showWarehouseDialog({Warehouse? warehouse}) {
    final isEditing = warehouse != null;
    final nameController = TextEditingController(text: warehouse?.name ?? '');
    final codeController = TextEditingController(text: warehouse?.code ?? '');
    final addressController =
        TextEditingController(text: warehouse?.address ?? '');
    final phoneController = TextEditingController(text: warehouse?.phone ?? '');
    final notesController = TextEditingController(text: warehouse?.notes ?? '');
    bool isDefault = warehouse?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'تعديل مستودع' : 'إضافة مستودع'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستودع *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warehouse),
                  ),
                ),
                Gap(12.h),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'رمز المستودع',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),
                Gap(12.h),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                Gap(12.h),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                Gap(12.h),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 2,
                ),
                Gap(12.h),
                SwitchListTile(
                  title: const Text('المستودع الافتراضي'),
                  subtitle: const Text('سيتم اختياره تلقائياً في العمليات'),
                  value: isDefault,
                  onChanged: (value) => setDialogState(() => isDefault = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('أدخل اسم المستودع')),
                  );
                  return;
                }

                try {
                  if (isEditing) {
                    await _warehouseRepo.updateWarehouse(
                      id: warehouse.id,
                      name: nameController.text,
                      code: codeController.text.isEmpty
                          ? null
                          : codeController.text,
                      address: addressController.text.isEmpty
                          ? null
                          : addressController.text,
                      phone: phoneController.text.isEmpty
                          ? null
                          : phoneController.text,
                      notes: notesController.text.isEmpty
                          ? null
                          : notesController.text,
                      isDefault: isDefault,
                    );
                  } else {
                    await _warehouseRepo.createWarehouse(
                      name: nameController.text,
                      code: codeController.text.isEmpty
                          ? null
                          : codeController.text,
                      address: addressController.text.isEmpty
                          ? null
                          : addressController.text,
                      phone: phoneController.text.isEmpty
                          ? null
                          : phoneController.text,
                      notes: notesController.text.isEmpty
                          ? null
                          : notesController.text,
                      isDefault: isDefault,
                    );
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing
                            ? 'تم تحديث المستودع'
                            : 'تم إضافة المستودع'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: $e')),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'تحديث' : 'إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Warehouse Card - بطاقة المستودع
/// ═══════════════════════════════════════════════════════════════════════════
class _WarehouseCard extends StatelessWidget {
  final Warehouse warehouse;
  final WarehouseRepository warehouseRepo;
  final VoidCallback onEdit;

  const _WarehouseCard({
    required this.warehouse,
    required this.warehouseRepo,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => context.push('/inventory/warehouse/${warehouse.id}'),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warehouse,
                    color: warehouse.isDefault
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  Gap(8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                warehouse.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (warehouse.isDefault)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'افتراضي',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (warehouse.code != null) ...[
                          Gap(4.h),
                          Text(
                            warehouse.code!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'default':
                          _setAsDefault(context);
                          break;
                        case 'delete':
                          _deleteWarehouse(context);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      if (!warehouse.isDefault)
                        const PopupMenuItem(
                          value: 'default',
                          child: Row(
                            children: [
                              Icon(Icons.star),
                              SizedBox(width: 8),
                              Text('تعيين كافتراضي'),
                            ],
                          ),
                        ),
                      if (!warehouse.isDefault)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('حذف',
                                  style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Gap(12.h),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: warehouseRepo.getWarehouseStockSummary(),
                builder: (context, snapshot) {
                  final summaryList = snapshot.data ?? [];
                  final summary = summaryList.firstWhere(
                    (s) => s['warehouseId'] == warehouse.id,
                    orElse: () => {
                      'productCount': 0,
                      'totalQuantity': 0,
                      'lowStockCount': 0,
                    },
                  );

                  return Row(
                    children: [
                      _StatItem(
                        icon: Icons.inventory_2,
                        label: 'المنتجات',
                        value: '${summary['productCount']}',
                      ),
                      Gap(16.w),
                      _StatItem(
                        icon: Icons.numbers,
                        label: 'الكمية',
                        value: '${summary['totalQuantity']}',
                      ),
                      Gap(16.w),
                      _StatItem(
                        icon: Icons.warning,
                        label: 'منخفض',
                        value: '${summary['lowStockCount']}',
                        valueColor: (summary['lowStockCount'] as int) > 0
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ],
                  );
                },
              ),
              if (warehouse.address != null) ...[
                Gap(12.h),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14.sp, color: AppColors.textSecondary),
                    Gap(4.w),
                    Expanded(
                      child: Text(
                        warehouse.address!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _setAsDefault(BuildContext context) async {
    try {
      await warehouseRepo.setDefaultWarehouse(warehouse.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعيين المستودع كافتراضي')),
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

  void _deleteWarehouse(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف مستودع "${warehouse.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await warehouseRepo.deleteWarehouse(warehouse.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف المستودع')),
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textSecondary),
        Gap(4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
