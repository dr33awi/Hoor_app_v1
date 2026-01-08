// ═══════════════════════════════════════════════════════════════════════════
// Warehouses Screen Pro - Enterprise Accounting Design
// Warehouse Management with Inventory Tracking
// ═══════════════════════════════════════════════════════════════════════════

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/export/warehouses_export_service.dart';
import '../../core/services/export/export_button.dart';
import '../../data/database/app_database.dart';

class WarehousesScreenPro extends ConsumerStatefulWidget {
  const WarehousesScreenPro({super.key});

  @override
  ConsumerState<WarehousesScreenPro> createState() =>
      _WarehousesScreenProState();
}

class _WarehousesScreenProState extends ConsumerState<WarehousesScreenPro> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehousesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            warehousesAsync.when(
              loading: () => ProHeader(
                title: 'المستودعات',
                subtitle: '0 مستودع',
                onBack: () => context.go('/'),
              ),
              error: (_, __) => ProHeader(
                title: 'المستودعات',
                subtitle: '0 مستودع',
                onBack: () => context.go('/'),
              ),
              data: (warehouses) {
                final filtered = _showActiveOnly
                    ? warehouses.where((w) => w.isActive).toList()
                    : warehouses;
                return ProHeader(
                  title: 'المستودعات',
                  subtitle: '${filtered.length} مستودع',
                  onBack: () => context.go('/'),
                  actions: [
                    // Export Menu Button - زر التصدير الموحد
                    ExportMenuButton(
                      onExport: (type) => _handleExport(type, warehouses),
                      tooltip: 'تصدير المستودعات',
                    ),
                    // Toggle active only
                    IconButton(
                      onPressed: () =>
                          setState(() => _showActiveOnly = !_showActiveOnly),
                      icon: Icon(
                        _showActiveOnly
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined,
                        color: _showActiveOnly
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      tooltip: _showActiveOnly ? 'إظهار الكل' : 'النشطة فقط',
                    ),
                  ],
                );
              },
            ),
            // Search Bar
            ProSearchBar(
              controller: _searchController,
              hintText: 'البحث في المستودعات...',
              onChanged: (value) => setState(() => _searchQuery = value),
              onClear: () => setState(() {}),
            ),
            // Statistics Cards
            warehousesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (warehouses) {
                final activeCount = warehouses.where((w) => w.isActive).length;
                final defaultWarehouse =
                    warehouses.where((w) => w.isDefault).firstOrNull;
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.warehouse_outlined,
                          label: 'إجمالي المستودعات',
                          value: '${warehouses.length}',
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_outline,
                          label: 'المستودعات النشطة',
                          value: '$activeCount',
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.star_outline,
                          label: 'الافتراضي',
                          value: defaultWarehouse?.name ?? '-',
                          color: AppColors.warning,
                          isText: true,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Warehouses List
            Expanded(
              child: warehousesAsync.when(
                loading: () => ProLoadingState.list(),
                error: (error, _) =>
                    ProEmptyState.error(error: error.toString()),
                data: (warehouses) {
                  return _buildWarehousesList(warehouses);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'transfer',
            onPressed: () => context.go('/stock-transfers'),
            backgroundColor: AppColors.secondary,
            child: const Icon(Icons.swap_horiz, color: Colors.white),
          ),
          SizedBox(height: AppSpacing.sm),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () => _showWarehouseForm(),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'مستودع جديد',
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehousesList(List<Warehouse> warehouses) {
    var filtered = warehouses.where((w) {
      // Filter by active status
      if (_showActiveOnly && !w.isActive) return false;

      // Filter by search
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return w.name.toLowerCase().contains(query) ||
          (w.code?.toLowerCase().contains(query) ?? false) ||
          (w.address?.toLowerCase().contains(query) ?? false);
    }).toList();

    // Sort: default first, then active, then by name
    filtered.sort((a, b) {
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return a.name.compareTo(b.name);
    });

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
                Icons.warehouse_outlined,
                size: 32.sp,
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              _searchQuery.isEmpty ? 'لا توجد مستودعات' : 'لا توجد نتائج',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              _searchQuery.isEmpty
                  ? 'أضف مستودع جديد لتنظيم مخزونك'
                  : 'جرب البحث بكلمات أخرى',
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
        final warehouse = filtered[index];
        return _WarehouseCard(
          warehouse: warehouse,
          onEdit: () => _showWarehouseForm(warehouse: warehouse),
          onDelete: () => _confirmDelete(warehouse),
          onSetDefault: () => _setAsDefault(warehouse),
          onToggleActive: () => _toggleActive(warehouse),
          onViewStock: () => _viewWarehouseStock(warehouse),
          onExport: () => _showSingleWarehouseExportDialog(warehouse),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Export Functions - تصدير موحد للمستودعات باستخدام ExportMenuButton
  // ═══════════════════════════════════════════════════════════════════════════

  /// معالجة اختيار نوع التصدير من ExportMenuButton
  void _handleExport(ExportType type, List<Warehouse> warehouses) {
    switch (type) {
      case ExportType.excel:
        _exportToExcel(warehouses, share: false);
        break;
      case ExportType.shareExcel:
        _exportToExcel(warehouses, share: true);
        break;
      case ExportType.pdf:
        _exportToPdf(warehouses);
        break;
      case ExportType.sharePdf:
        _sharePdf(warehouses);
        break;
    }
  }

  Future<void> _exportToExcel(List<Warehouse> warehouses,
      {bool share = true}) async {
    try {
      ProSnackbar.info(context, 'جاري إعداد ملف Excel...');

      final db = ref.read(databaseProvider);

      await WarehousesExportService.shareExcel(
        warehouses: warehouses,
        db: db,
      );

      if (mounted) {
        ProSnackbar.success(context, 'تم تصدير الملف بنجاح');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في التصدير: $e');
      }
    }
  }

  Future<void> _exportToPdf(List<Warehouse> warehouses) async {
    try {
      ProSnackbar.info(context, 'جاري إعداد ملف PDF...');

      final db = ref.read(databaseProvider);

      final pdfBytes = await WarehousesExportService.generatePdf(
        warehouses: warehouses,
        db: db,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'تقرير_المستودعات',
      );

      if (mounted) {
        ProSnackbar.success(context, 'تم إعداد التقرير بنجاح');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في التصدير: $e');
      }
    }
  }

  /// مشاركة ملف PDF مباشرة
  Future<void> _sharePdf(List<Warehouse> warehouses) async {
    try {
      ProSnackbar.info(context, 'جاري إعداد ملف PDF للمشاركة...');

      final db = ref.read(databaseProvider);

      await WarehousesExportService.sharePdf(
        warehouses: warehouses,
        db: db,
      );

      if (mounted) {
        ProSnackbar.success(context, 'تم مشاركة التقرير بنجاح');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في المشاركة: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير مستودع واحد
  // ═══════════════════════════════════════════════════════════════════════════

  /// عرض خيارات تصدير مستودع واحد
  void _showSingleWarehouseExportDialog(Warehouse warehouse) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Title
            Row(
              children: [
                Icon(Icons.warehouse_outlined,
                    color: AppColors.primary, size: 24.sp),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'تصدير: ${warehouse.name}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            // Export Options
            Row(
              children: [
                Expanded(
                  child: _buildExportOptionTile(
                    icon: Icons.table_chart,
                    title: 'Excel',
                    subtitle: 'جدول بيانات',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(ctx);
                      _exportSingleWarehouse(warehouse, isPdf: false);
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildExportOptionTile(
                    icon: Icons.picture_as_pdf,
                    title: 'PDF',
                    subtitle: 'تقرير للطباعة',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(ctx);
                      _exportSingleWarehouse(warehouse, isPdf: true);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32.sp),
            SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// تصدير مستودع واحد
  Future<void> _exportSingleWarehouse(Warehouse warehouse,
      {required bool isPdf}) async {
    try {
      ProSnackbar.info(context, 'جاري تصدير ${warehouse.name}...');

      final db = ref.read(databaseProvider);

      if (isPdf) {
        final pdfBytes = await WarehousesExportService.generatePdf(
          warehouses: [warehouse],
          db: db,
        );

        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: 'تقرير_${warehouse.name}',
        );
      } else {
        await WarehousesExportService.shareExcel(
          warehouses: [warehouse],
          db: db,
          fileName: 'مستودع_${warehouse.name}',
        );
      }

      if (mounted) {
        ProSnackbar.success(context, 'تم تصدير ${warehouse.name} بنجاح');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في التصدير: $e');
      }
    }
  }

  void _showWarehouseForm({Warehouse? warehouse}) {
    final nameController = TextEditingController(text: warehouse?.name ?? '');
    final codeController = TextEditingController(text: warehouse?.code ?? '');
    final addressController =
        TextEditingController(text: warehouse?.address ?? '');
    final phoneController = TextEditingController(text: warehouse?.phone ?? '');
    final notesController = TextEditingController(text: warehouse?.notes ?? '');
    final isEditing = warehouse != null;
    bool isDefault = warehouse?.isDefault ?? false;
    bool isActive = warehouse?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
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
                          isEditing ? 'تعديل المستودع' : 'مستودع جديد',
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
                // Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProTextField(
                          controller: nameController,
                          label: 'اسم المستودع',
                          prefixIcon: Icons.warehouse_rounded,
                        ),
                        SizedBox(height: AppSpacing.md),
                        ProTextField(
                          controller: codeController,
                          label: 'رمز المستودع (اختياري)',
                          prefixIcon: Icons.tag_rounded,
                        ),
                        SizedBox(height: AppSpacing.md),
                        ProTextField(
                          controller: addressController,
                          label: 'العنوان (اختياري)',
                          prefixIcon: Icons.location_on_rounded,
                          maxLines: 2,
                        ),
                        SizedBox(height: AppSpacing.md),
                        ProTextField(
                          controller: phoneController,
                          label: 'رقم الهاتف (اختياري)',
                          prefixIcon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: AppSpacing.md),
                        ProTextField(
                          controller: notesController,
                          label: 'ملاحظات (اختياري)',
                          prefixIcon: Icons.notes_rounded,
                          maxLines: 2,
                        ),
                        SizedBox(height: AppSpacing.md),
                        // Switches
                        ProSwitchTile(
                          title: 'المستودع الافتراضي',
                          subtitle: 'استخدم هذا المستودع بشكل افتراضي للعمليات',
                          value: isDefault,
                          onChanged: (value) {
                            setModalState(() => isDefault = value);
                          },
                        ),
                        SizedBox(height: AppSpacing.xs),
                        ProSwitchTile(
                          title: 'مستودع نشط',
                          subtitle: 'المستودعات غير النشطة لن تظهر في القوائم',
                          value: isActive,
                          onChanged: (value) {
                            setModalState(() => isActive = value);
                          },
                        ),
                        SizedBox(height: AppSpacing.lg),
                        ProButton(
                          label: isEditing ? 'حفظ التغييرات' : 'إضافة المستودع',
                          fullWidth: true,
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty) {
                              ProSnackbar.showError(
                                  context, 'أدخل اسم المستودع');
                              return;
                            }

                            try {
                              final db = ref.read(databaseProvider);
                              if (isEditing) {
                                await db.updateWarehouse(WarehousesCompanion(
                                  id: drift.Value(warehouse.id),
                                  name: drift.Value(nameController.text.trim()),
                                  code: drift.Value(
                                      codeController.text.trim().isEmpty
                                          ? null
                                          : codeController.text.trim()),
                                  address: drift.Value(
                                      addressController.text.trim().isEmpty
                                          ? null
                                          : addressController.text.trim()),
                                  phone: drift.Value(
                                      phoneController.text.trim().isEmpty
                                          ? null
                                          : phoneController.text.trim()),
                                  notes: drift.Value(
                                      notesController.text.trim().isEmpty
                                          ? null
                                          : notesController.text.trim()),
                                  isActive: drift.Value(isActive),
                                  updatedAt: drift.Value(DateTime.now()),
                                  syncStatus: const drift.Value('pending'),
                                ));

                                // Handle default warehouse setting
                                if (isDefault && !warehouse.isDefault) {
                                  await db.setDefaultWarehouse(warehouse.id);
                                }
                              } else {
                                final id = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                await db.insertWarehouse(WarehousesCompanion(
                                  id: drift.Value(id),
                                  name: drift.Value(nameController.text.trim()),
                                  code: drift.Value(
                                      codeController.text.trim().isEmpty
                                          ? null
                                          : codeController.text.trim()),
                                  address: drift.Value(
                                      addressController.text.trim().isEmpty
                                          ? null
                                          : addressController.text.trim()),
                                  phone: drift.Value(
                                      phoneController.text.trim().isEmpty
                                          ? null
                                          : phoneController.text.trim()),
                                  notes: drift.Value(
                                      notesController.text.trim().isEmpty
                                          ? null
                                          : notesController.text.trim()),
                                  isDefault: drift.Value(isDefault),
                                  isActive: drift.Value(isActive),
                                  syncStatus: const drift.Value('pending'),
                                ));

                                // Set as default if checked
                                if (isDefault) {
                                  await db.setDefaultWarehouse(id);
                                }
                              }

                              if (context.mounted) {
                                Navigator.pop(context);
                                if (context.mounted) {
                                  ProSnackbar.success(
                                    context,
                                    isEditing
                                        ? 'تم تحديث المستودع'
                                        : 'تم إضافة المستودع',
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ProSnackbar.error(context, 'خطأ: $e');
                              }
                            }
                          },
                        ),
                        SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(Warehouse warehouse) async {
    if (warehouse.isDefault) {
      ProSnackbar.warning(context, 'لا يمكن حذف المستودع الافتراضي');
      return;
    }

    final confirm = await showProDeleteDialog(
      context: context,
      itemName: 'المستودع "${warehouse.name}"',
    );

    if (confirm == true && mounted) {
      try {
        final db = ref.read(databaseProvider);
        await db.deleteWarehouse(warehouse.id);
        if (mounted) {
          ProSnackbar.deleted(context, 'المستودع');
        }
      } catch (e) {
        if (mounted) {
          ProSnackbar.error(context, 'خطأ: $e');
        }
      }
    }
  }

  Future<void> _setAsDefault(Warehouse warehouse) async {
    if (warehouse.isDefault) {
      ProSnackbar.info(context, 'هذا المستودع هو الافتراضي بالفعل');
      return;
    }

    try {
      final db = ref.read(databaseProvider);
      await db.setDefaultWarehouse(warehouse.id);
      if (mounted) {
        ProSnackbar.success(context, 'تم تعيين "${warehouse.name}" كافتراضي');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ: $e');
      }
    }
  }

  Future<void> _toggleActive(Warehouse warehouse) async {
    if (warehouse.isDefault && warehouse.isActive) {
      ProSnackbar.warning(context, 'لا يمكن تعطيل المستودع الافتراضي');
      return;
    }

    try {
      final db = ref.read(databaseProvider);
      await db.updateWarehouse(WarehousesCompanion(
        id: drift.Value(warehouse.id),
        isActive: drift.Value(!warehouse.isActive),
        updatedAt: drift.Value(DateTime.now()),
        syncStatus: const drift.Value('pending'),
      ));
      if (mounted) {
        ProSnackbar.success(
          context,
          warehouse.isActive ? 'تم تعطيل المستودع' : 'تم تفعيل المستودع',
        );
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ: $e');
      }
    }
  }

  void _viewWarehouseStock(Warehouse warehouse) {
    context.go('/warehouses/${warehouse.id}/stock');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Statistics Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isText;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: color),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: isText
                ? AppTypography.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  )
                : AppTypography.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Warehouse Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _WarehouseCard extends StatelessWidget {
  final Warehouse warehouse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final VoidCallback onToggleActive;
  final VoidCallback onViewStock;
  final VoidCallback onExport;

  const _WarehouseCard({
    required this.warehouse,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    required this.onToggleActive,
    required this.onViewStock,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      onTap: onViewStock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon with status indicator
              Stack(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: warehouse.isActive
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.textTertiary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      Icons.warehouse_outlined,
                      size: 20.sp,
                      color: warehouse.isActive
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                  if (warehouse.isDefault)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.star,
                          size: 10.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppSpacing.sm),
              // Warehouse Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            warehouse.name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: warehouse.isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ),
                        // Status badges
                        if (!warehouse.isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.textTertiary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              'غير نشط',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        if (warehouse.isDefault)
                          Container(
                            margin: EdgeInsets.only(right: AppSpacing.xxs),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              'افتراضي',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    // Details row
                    Row(
                      children: [
                        if (warehouse.code != null &&
                            warehouse.code!.isNotEmpty) ...[
                          Icon(Icons.tag,
                              size: 12.sp, color: AppColors.textTertiary),
                          SizedBox(width: 2.w),
                          Text(
                            warehouse.code!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                        ],
                        if (warehouse.address != null &&
                            warehouse.address!.isNotEmpty) ...[
                          Icon(Icons.location_on_outlined,
                              size: 12.sp, color: AppColors.textTertiary),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              warehouse.address!,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    size: 18.sp, color: AppColors.textTertiary),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'stock':
                      onViewStock();
                      break;
                    case 'export':
                      onExport();
                      break;
                    case 'default':
                      onSetDefault();
                      break;
                    case 'toggle':
                      onToggleActive();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'stock',
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2_outlined),
                        SizedBox(width: 8),
                        Text('المخزون'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.ios_share_rounded, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('تصدير المستودع',
                            style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                  if (!warehouse.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(Icons.star_outline),
                          SizedBox(width: 8),
                          Text('تعيين كافتراضي'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(warehouse.isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        const SizedBox(width: 8),
                        Text(warehouse.isActive ? 'تعطيل' : 'تفعيل'),
                      ],
                    ),
                  ),
                  if (!warehouse.isDefault)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Phone if available
          if (warehouse.phone != null && warehouse.phone!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                SizedBox(width: 50.w), // Align with content
                Icon(Icons.phone_outlined,
                    size: 12.sp, color: AppColors.textTertiary),
                SizedBox(width: 4.w),
                Text(
                  warehouse.phone!,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
          // Notes if available
          if (warehouse.notes != null && warehouse.notes!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 4.h),
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.xs),
                border:
                    Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_outlined,
                      size: 12.sp, color: AppColors.info),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      warehouse.notes!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
