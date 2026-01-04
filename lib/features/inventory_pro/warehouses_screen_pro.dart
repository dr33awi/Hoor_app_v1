// ═══════════════════════════════════════════════════════════════════════════
// Warehouses Screen Pro - Enterprise Accounting Design
// Warehouse Management with Ledger Precision
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart'; // ✅ إضافة للـ firstWhereOrNull

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/export/export_button.dart';
import '../../core/services/export/excel_export_service.dart';
import '../../core/services/export/pdf_export_service.dart';
import '../../data/database/app_database.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ✅ Provider لجلب مخزون كل مستودع
// ═══════════════════════════════════════════════════════════════════════════

/// Provider لجلب مخزون مستودع معين
/// يجب تنفيذه في WarehouseRepository
final warehouseStockProvider =
    StreamProvider.family<List<WarehouseStockData>, String>((ref, warehouseId) {
  final warehouseRepo = ref.watch(warehouseRepositoryProvider);
  return warehouseRepo.watchWarehouseStock(warehouseId);
});

/// Provider لجلب ملخص مخزون جميع المستودعات
final warehouseStockSummaryProvider =
    FutureProvider.family<WarehouseStockSummary, String>(
        (ref, warehouseId) async {
  final warehouseRepo = ref.read(warehouseRepositoryProvider);
  final summaryList = await warehouseRepo.getWarehouseStockSummary();

  // البحث عن ملخص المستودع المطلوب
  final warehouseSummary = summaryList.firstWhereOrNull(
    (summary) => summary['warehouse_id'] == warehouseId,
  );

  if (warehouseSummary != null) {
    return WarehouseStockSummary(
      productCount: (warehouseSummary['product_count'] as num?)?.toInt() ?? 0,
      totalQuantity: (warehouseSummary['total_quantity'] as num?)?.toInt() ?? 0,
      totalValue: (warehouseSummary['total_value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  return WarehouseStockSummary.empty();
});

/// كلاس لملخص مخزون المستودع
class WarehouseStockSummary {
  final int productCount;
  final int totalQuantity;
  final double totalValue;

  const WarehouseStockSummary({
    required this.productCount,
    required this.totalQuantity,
    required this.totalValue,
  });

  factory WarehouseStockSummary.empty() => const WarehouseStockSummary(
        productCount: 0,
        totalQuantity: 0,
        totalValue: 0,
      );
}

/// كلاس لبيانات مخزون المستودع (يجب أن يكون موجوداً في app_database.dart)
class WarehouseStock {
  final String id;
  final String warehouseId;
  final String productId;
  final int quantity;
  final DateTime updatedAt;

  const WarehouseStock({
    required this.id,
    required this.warehouseId,
    required this.productId,
    required this.quantity,
    required this.updatedAt,
  });
}

class WarehousesScreenPro extends ConsumerStatefulWidget {
  const WarehousesScreenPro({super.key});

  @override
  ConsumerState<WarehousesScreenPro> createState() =>
      _WarehousesScreenProState();
}

class _WarehousesScreenProState extends ConsumerState<WarehousesScreenPro> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isExporting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehousesStreamProvider);
    final productsAsync = ref.watch(activeProductsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            // ملخص إجمالي المخزون
            productsAsync.when(
              data: (products) => _buildTotalStockSummary(products),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Expanded(
              child: warehousesAsync.when(
                loading: () => ProLoadingState.list(),
                error: (error, _) => ProEmptyState.error(
                  error: error.toString(),
                  onRetry: () => ref.invalidate(warehousesStreamProvider),
                ),
                data: (warehouses) {
                  final filtered = _filterWarehouses(warehouses);
                  if (filtered.isEmpty) {
                    return ProEmptyState.list(
                      itemName: 'مستودع',
                    );
                  }
                  return _buildWarehousesList(filtered);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWarehouseDialog(),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'مستودع جديد',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTotalStockSummary(List<Product> products) {
    final totalItems = products.fold<int>(0, (sum, p) => sum + p.quantity);
    final totalValue = products.fold<double>(
      0,
      (sum, p) => sum + (p.quantity * p.purchasePrice),
    );
    final lowStock = products
        .where((p) => p.quantity <= p.minQuantity && p.quantity > 0)
        .length;
    final outOfStock = products.where((p) => p.quantity <= 0).length;

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'إجمالي المنتجات',
              value: '${products.length}',
              icon: Icons.inventory_2_rounded,
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatItem(
              label: 'إجمالي القطع',
              value: NumberFormat('#,###').format(totalItems),
              icon: Icons.category_rounded,
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatItem(
              label: 'قيمة المخزون',
              value: NumberFormat.compact(locale: 'ar').format(totalValue),
              icon: Icons.attach_money_rounded,
            ),
          ),
          if (lowStock > 0 || outOfStock > 0) ...[
            _buildVerticalDivider(),
            Expanded(
              child: _buildStatItem(
                label: 'تنبيهات',
                value: '${lowStock + outOfStock}',
                icon: Icons.warning_rounded,
                isWarning: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    bool isWarning = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: isWarning ? Colors.amber : Colors.white.withOpacity(0.7),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: Colors.white.withOpacity(0.3),
    );
  }

  List<Warehouse> _filterWarehouses(List<Warehouse> warehouses) {
    if (_searchQuery.isEmpty) return warehouses;
    return warehouses.where((w) {
      return w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (w.code?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  Widget _buildHeader() {
    return ProHeader(
      title: 'المستودعات',
      subtitle: 'إدارة مواقع التخزين',
      actions: [
        IconButton(
          onPressed: () => context.push('/inventory/transfer'),
          icon: Icon(Icons.swap_horiz_rounded, color: AppColors.secondary),
          tooltip: 'نقل المخزون',
        ),
        ExportMenuButton(
          onExport: _handleExport,
          isLoading: _isExporting,
          icon: Icons.more_vert,
          tooltip: 'تصدير تقرير المخزون',
          enabledOptions: const {
            ExportType.excel,
            ExportType.pdf,
            ExportType.sharePdf,
            ExportType.shareExcel,
          },
        ),
      ],
    );
  }

  Future<void> _handleExport(ExportType type) async {
    final productsAsync = ref.read(activeProductsStreamProvider);
    final products = productsAsync.when(
      data: (p) => p,
      loading: () => <Product>[],
      error: (_, __) => <Product>[],
    );

    if (products.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد منتجات للتصدير');
      return;
    }

    setState(() => _isExporting = true);

    try {
      switch (type) {
        case ExportType.excel:
          await ExcelExportService.exportProducts(products: products);
          if (mounted)
            ProSnackbar.success(context, 'تم تصدير المخزون إلى Excel');
          break;
        case ExportType.pdf:
          final bytes =
              await PdfExportService.generateProductsList(products: products);
          await _savePdfLocally(bytes, 'inventory_report');
          if (mounted) ProSnackbar.success(context, 'تم تصدير المخزون إلى PDF');
          break;
        case ExportType.sharePdf:
          final bytes =
              await PdfExportService.generateProductsList(products: products);
          await PdfExportService.sharePdfBytes(
            bytes,
            fileName: 'inventory_report',
            subject: 'تقرير المخزون',
          );
          break;
        case ExportType.shareExcel:
          final filePath =
              await ExcelExportService.exportProducts(products: products);
          await ExcelExportService.shareFile(filePath,
              subject: 'تقرير المخزون');
          break;
      }
    } catch (e) {
      if (mounted) ProSnackbar.showError(context, e);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildSearchBar() {
    return ProSearchBar(
      controller: _searchController,
      hintText: 'البحث عن مستودع...',
      margin: EdgeInsets.all(AppSpacing.md),
      onChanged: (value) => setState(() => _searchQuery = value),
      onClear: () => setState(() => _searchQuery = ''),
    );
  }

  // ✅ بناء قائمة المستودعات مع جلب مخزون كل مستودع بشكل منفصل
  Widget _buildWarehousesList(List<Warehouse> warehouses) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: warehouses.length,
      itemBuilder: (context, index) {
        final warehouse = warehouses[index];
        return _WarehouseCardWithStock(
          warehouse: warehouse,
          onTap: () => _showWarehouseDialog(warehouse: warehouse),
          onDelete: () => _deleteWarehouse(warehouse),
          onSetDefault: () => _setAsDefault(warehouse),
          onViewStock: () => _showWarehouseStock(warehouse),
        );
      },
    );
  }

  Future<void> _savePdfLocally(Uint8List bytes, String fileName) async {
    if (kIsWeb) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);
  }

  void _showWarehouseStock(Warehouse warehouse) {
    final productsAsync = ref.read(activeProductsStreamProvider);
    final products = productsAsync.when(
      data: (p) => p,
      loading: () => <Product>[],
      error: (_, __) => <Product>[],
    );

    showProBottomSheet(
      context: context,
      title: 'مخزون ${warehouse.name}',
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: products.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 64.sp, color: AppColors.textTertiary),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'لا توجد منتجات',
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isLowStock = product.quantity <= product.minQuantity;
                  final isOutOfStock = product.quantity <= 0;

                  return ListTile(
                    leading: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? AppColors.error.withOpacity(0.1)
                            : isLowStock
                                ? AppColors.warning.withOpacity(0.1)
                                : AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: Text(
                          '${product.quantity}',
                          style: AppTypography.titleSmall.copyWith(
                            color: isOutOfStock
                                ? AppColors.error
                                : isLowStock
                                    ? AppColors.warning
                                    : AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      'الحد الأدنى: ${product.minQuantity}',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textTertiary),
                    ),
                    trailing: isOutOfStock
                        ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              'نفذ',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : isLowStock
                            ? Icon(Icons.warning_rounded,
                                color: AppColors.warning, size: 20.sp)
                            : null,
                  );
                },
              ),
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

    showProBottomSheet(
      context: context,
      title: isEditing ? 'تعديل المستودع' : 'مستودع جديد',
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Fields
            _buildTextField(
              controller: nameController,
              label: 'اسم المستودع *',
              icon: Icons.warehouse_outlined,
            ),
            SizedBox(height: AppSpacing.md),

            _buildTextField(
              controller: codeController,
              label: 'رمز المستودع',
              icon: Icons.qr_code_rounded,
            ),
            SizedBox(height: AppSpacing.md),

            _buildTextField(
              controller: addressController,
              label: 'العنوان',
              icon: Icons.location_on_outlined,
            ),
            SizedBox(height: AppSpacing.md),

            _buildTextField(
              controller: phoneController,
              label: 'رقم الهاتف',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: AppSpacing.md),

            _buildTextField(
              controller: notesController,
              label: 'ملاحظات',
              icon: Icons.notes_rounded,
              maxLines: 2,
            ),
            SizedBox(height: AppSpacing.md),

            // Default Switch
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: SwitchListTile(
                title:
                    Text('المستودع الافتراضي', style: AppTypography.titleSmall),
                subtitle: Text(
                  'سيتم اختياره تلقائياً في العمليات',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                value: isDefault,
                activeColor: AppColors.secondary,
                onChanged: (value) => setSheetState(() => isDefault = value),
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ProButton(
                    label: 'إلغاء',
                    onPressed: () => Navigator.pop(context),
                    type: ProButtonType.outlined,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: ProButton(
                    label: isEditing ? 'تحديث' : 'إضافة',
                    onPressed: () => _saveWarehouse(
                      isEditing: isEditing,
                      warehouse: warehouse,
                      name: nameController.text,
                      code: codeController.text,
                      address: addressController.text,
                      phone: phoneController.text,
                      notes: notesController.text,
                      isDefault: isDefault,
                    ),
                    type: ProButtonType.filled,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceMuted,
      ),
    );
  }

  Future<void> _saveWarehouse({
    required bool isEditing,
    Warehouse? warehouse,
    required String name,
    required String code,
    required String address,
    required String phone,
    required String notes,
    required bool isDefault,
  }) async {
    if (name.trim().isEmpty) {
      ProSnackbar.warning(context, 'أدخل اسم المستودع');
      return;
    }

    try {
      final warehouseRepo = ref.read(warehouseRepositoryProvider);

      if (isEditing && warehouse != null) {
        await warehouseRepo.updateWarehouse(
          id: warehouse.id,
          name: name.trim(),
          code: code.trim().isEmpty ? null : code.trim(),
          address: address.trim().isEmpty ? null : address.trim(),
          phone: phone.trim().isEmpty ? null : phone.trim(),
          notes: notes.trim().isEmpty ? null : notes.trim(),
          isDefault: isDefault,
        );
      } else {
        await warehouseRepo.createWarehouse(
          name: name.trim(),
          code: code.trim().isEmpty ? null : code.trim(),
          address: address.trim().isEmpty ? null : address.trim(),
          phone: phone.trim().isEmpty ? null : phone.trim(),
          notes: notes.trim().isEmpty ? null : notes.trim(),
          isDefault: isDefault,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ProSnackbar.success(
          context,
          isEditing ? 'تم تحديث المستودع' : 'تم إضافة المستودع',
        );
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ: $e');
      }
    }
  }

  Future<void> _deleteWarehouse(Warehouse warehouse) async {
    // ✅ التحقق من أن المستودع ليس افتراضياً
    if (warehouse.isDefault) {
      ProSnackbar.warning(
        context,
        'لا يمكن حذف المستودع الافتراضي. عيّن مستودعاً آخر كافتراضي أولاً.',
      );
      return;
    }

    final confirm = await showProDeleteDialog(
      context: context,
      itemName: 'المستودع "${warehouse.name}"',
    );

    if (confirm != true) return;

    try {
      final warehouseRepo = ref.read(warehouseRepositoryProvider);
      await warehouseRepo.deleteWarehouse(warehouse.id);
      if (mounted) {
        ProSnackbar.deleted(context, 'المستودع');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في الحذف: $e');
      }
    }
  }

  Future<void> _setAsDefault(Warehouse warehouse) async {
    if (warehouse.isDefault) {
      ProSnackbar.info(context, 'هذا المستودع هو الافتراضي بالفعل');
      return;
    }

    try {
      final warehouseRepo = ref.read(warehouseRepositoryProvider);
      await warehouseRepo.updateWarehouse(
        id: warehouse.id,
        name: warehouse.name,
        isDefault: true,
      );
      if (mounted) {
        ProSnackbar.success(context, 'تم تعيين "${warehouse.name}" كافتراضي');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ: $e');
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ✅ Warehouse Card With Stock - يجلب مخزون المستودع بشكل منفصل
// ═══════════════════════════════════════════════════════════════════════════

class _WarehouseCardWithStock extends ConsumerWidget {
  final Warehouse warehouse;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final VoidCallback onViewStock;

  const _WarehouseCardWithStock({
    required this.warehouse,
    required this.onTap,
    required this.onDelete,
    required this.onSetDefault,
    required this.onViewStock,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ جلب ملخص مخزون المستودع
    final stockSummaryAsync =
        ref.watch(warehouseStockSummaryProvider(warehouse.id));

    return stockSummaryAsync.when(
      loading: () => _buildCard(
        context,
        productCount: null,
        totalQuantity: null,
        isLoading: true,
      ),
      error: (_, __) => _buildCard(
        context,
        productCount: 0,
        totalQuantity: 0,
        isLoading: false,
      ),
      data: (summary) => _buildCard(
        context,
        productCount: summary.productCount,
        totalQuantity: summary.totalQuantity,
        isLoading: false,
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required int? productCount,
    required int? totalQuantity,
    required bool isLoading,
  }) {
    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.md.h),
      borderColor:
          warehouse.isDefault ? AppColors.secondary.withOpacity(0.5) : null,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.warehouse_rounded,
                  color: AppColors.secondary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md),

              // Name & Code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            warehouse.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (warehouse.isDefault)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 12.sp,
                                  color: AppColors.secondary,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'افتراضي',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (warehouse.code != null)
                      Text(
                        warehouse.code!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),

              // Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    color: AppColors.textTertiary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onTap();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                    case 'default':
                      onSetDefault();
                      break;
                    case 'stock':
                      onViewStock();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'stock',
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2_rounded,
                            color: AppColors.info, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        const Text('عرض المخزون'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded,
                            color: AppColors.secondary, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        const Text('تعديل'),
                      ],
                    ),
                  ),
                  if (!warehouse.isDefault)
                    PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.warning, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          const Text('تعيين كافتراضي'),
                        ],
                      ),
                    ),
                  if (!warehouse.isDefault)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded,
                              color: AppColors.error, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          Text('حذف', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Stock Statistics
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 12.sp,
                    height: 12.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'جاري التحميل...',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ] else ...[
                  _buildStockStat(
                      Icons.category_rounded, '${productCount ?? 0} منتج'),
                  SizedBox(width: AppSpacing.md),
                  _buildStockStat(
                      Icons.inventory_rounded, '${totalQuantity ?? 0} قطعة'),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: onViewStock,
                  child: Row(
                    children: [
                      Text(
                        'عرض المخزون',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      Icon(Icons.chevron_left_rounded,
                          size: 16.sp, color: AppColors.secondary),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Additional Info
          if (warehouse.address != null || warehouse.phone != null) ...[
            SizedBox(height: AppSpacing.sm),
            Divider(color: AppColors.border, height: 1),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                if (warehouse.address != null)
                  _buildInfoChip(
                    Icons.location_on_outlined,
                    warehouse.address!,
                  ),
                if (warehouse.phone != null)
                  _buildInfoChip(
                    Icons.phone_outlined,
                    warehouse.phone!,
                  ),
              ],
            ),
          ],

          if (warehouse.notes != null && warehouse.notes!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              warehouse.notes!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textTertiary),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStockStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
