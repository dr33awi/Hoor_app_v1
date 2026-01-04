// ═══════════════════════════════════════════════════════════════════════════
// Inventory Screen Pro - Enterprise Accounting Design
// Inventory Management with Ledger Precision
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';

class InventoryScreenPro extends ConsumerStatefulWidget {
  const InventoryScreenPro({super.key});

  @override
  ConsumerState<InventoryScreenPro> createState() => _InventoryScreenProState();
}

class _InventoryScreenProState extends ConsumerState<InventoryScreenPro>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMovementsTab(),
                  _buildAlertsTab(),
                  _buildStockTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMovementSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'حركة جديدة',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ProHeader(
          title: 'المخزون',
          subtitle: 'إدارة حركات المخزون والجرد',
          onBack: () => context.go('/'),
          actions: [
            IconButton(
              onPressed: () => context.push('/inventory/warehouses'),
              icon: const Icon(Icons.warehouse_outlined),
              tooltip: 'المستودعات',
            ),
            IconButton(
              onPressed: () => context.push('/inventory/transfer'),
              icon: const Icon(Icons.swap_horiz_rounded),
              tooltip: 'نقل المخزون',
            ),
            IconButton(
              onPressed: () => context.push('/inventory/count'),
              icon: const Icon(Icons.inventory_2_outlined),
              tooltip: 'جرد المخزون',
            ),
          ],
        ),
        ProSearchBar(
          controller: _searchController,
          hintText: 'البحث في المخزون...',
          onChanged: (value) => setState(() => _searchQuery = value),
          onClear: () => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle:
            AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'الحركات'),
          Tab(text: 'التنبيهات'),
          Tab(text: 'المخزون'),
        ],
      ),
    );
  }

  Widget _buildMovementsTab() {
    final movementsAsync = ref.watch(inventoryMovementsStreamProvider);

    return movementsAsync.when(
      loading: () => ProLoadingState.list(),
      error: (error, _) => ProEmptyState.error(error: error.toString()),
      data: (movements) {
        var filtered = movements.where((m) {
          if (_searchQuery.isEmpty) return true;
          return m.reason?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false;
        }).toList();

        if (filtered.isEmpty) {
          return const ProEmptyState(
            icon: Icons.swap_vert_rounded,
            title: 'لا توجد حركات',
            message: 'سجل حركات المخزون ستظهر هنا',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _MovementCard(movement: filtered[index]);
          },
        );
      },
    );
  }

  Widget _buildAlertsTab() {
    final productsAsync = ref.watch(activeProductsStreamProvider);

    return productsAsync.when(
      loading: () => ProLoadingState.list(),
      error: (error, _) => ProEmptyState.error(error: error.toString()),
      data: (products) {
        final lowStock =
            products.where((p) => p.quantity <= p.minQuantity).toList();

        if (lowStock.isEmpty) {
          return const ProEmptyState(
            icon: Icons.check_circle_outline,
            title: 'لا توجد تنبيهات',
            message: 'جميع المنتجات لديها مخزون كافٍ',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: lowStock.length,
          itemBuilder: (context, index) {
            return _LowStockCard(product: lowStock[index]);
          },
        );
      },
    );
  }

  Widget _buildStockTab() {
    final productsAsync = ref.watch(activeProductsStreamProvider);

    return productsAsync.when(
      loading: () => ProLoadingState.list(),
      error: (error, _) => ProEmptyState.error(error: error.toString()),
      data: (products) {
        var filtered = products.where((p) {
          if (_searchQuery.isEmpty) return true;
          return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filtered.isEmpty) {
          return ProEmptyState.list(
            itemName: 'منتج',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _StockCard(product: filtered[index]);
          },
        );
      },
    );
  }

  void _showAddMovementSheet() {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    String selectedType = 'add';
    Product? selectedProduct;

    showProBottomSheet(
      context: context,
      title: 'إضافة مخزون',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final productsAsync = ref.watch(activeProductsStreamProvider);

          return Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text('حركة مخزون جديدة', style: AppTypography.titleLarge),
                SizedBox(height: AppSpacing.lg),

                // Movement Type
                Text('نوع الحركة', style: AppTypography.labelLarge),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'إضافة',
                        icon: Icons.add_circle_outline,
                        isSelected: selectedType == 'add',
                        color: AppColors.success,
                        onTap: () => setSheetState(() => selectedType = 'add'),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _TypeButton(
                        label: 'سحب',
                        icon: Icons.remove_circle_outline,
                        isSelected: selectedType == 'withdraw',
                        color: AppColors.error,
                        onTap: () =>
                            setSheetState(() => selectedType = 'withdraw'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),

                // Product Selection
                Text('المنتج', style: AppTypography.labelLarge),
                SizedBox(height: AppSpacing.sm),
                productsAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('خطأ في تحميل المنتجات'),
                  data: (products) => Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Product>(
                        isExpanded: true,
                        value: selectedProduct,
                        hint: const Text('اختر المنتج'),
                        items: products
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setSheetState(() => selectedProduct = value),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Quantity
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الكمية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Reason
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'السبب (اختياري)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Save Button
                ProButton(
                  label: 'حفظ الحركة',
                  fullWidth: true,
                  onPressed: () async {
                    if (selectedProduct == null) {
                      ProSnackbar.warning(context, 'اختر المنتج');
                      return;
                    }
                    final quantity = int.tryParse(quantityController.text) ?? 0;
                    if (quantity <= 0) {
                      ProSnackbar.warning(context, 'أدخل كمية صحيحة');
                      return;
                    }

                    // ✅ التحقق من الكمية المتاحة عند السحب
                    if (selectedType == 'withdraw' &&
                        quantity > selectedProduct!.quantity) {
                      ProSnackbar.warning(
                        context,
                        'الكمية المطلوبة أكبر من المتوفرة (${selectedProduct!.quantity})',
                      );
                      return;
                    }

                    try {
                      final inventoryRepo =
                          ref.read(inventoryRepositoryProvider);
                      if (selectedType == 'add') {
                        await inventoryRepo.addStock(
                          productId: selectedProduct!.id,
                          quantity: quantity,
                          reason: reasonController.text.isNotEmpty
                              ? reasonController.text
                              : 'إضافة يدوية',
                        );
                      } else {
                        await inventoryRepo.withdrawStock(
                          productId: selectedProduct!.id,
                          quantity: quantity,
                          reason: reasonController.text.isNotEmpty
                              ? reasonController.text
                              : 'سحب يدوي',
                        );
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        ProSnackbar.success(context, 'تم تسجيل الحركة بنجاح');
                      }
                    } catch (e) {
                      if (mounted) {
                        ProSnackbar.error(context, e.toString());
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Movement Card - Enterprise Style with Tabular Figures
// ═══════════════════════════════════════════════════════════════════════════

class _MovementCard extends StatelessWidget {
  final InventoryMovement movement;

  const _MovementCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isAdd = movement.type == 'add' || movement.type == 'purchase';
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a', 'ar');

    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          // Enterprise: Square icon container
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: (isAdd ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: (isAdd ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              isAdd ? Icons.add_circle_outline : Icons.remove_circle_outline,
              size: 18.sp,
              color: isAdd ? AppColors.success : AppColors.error,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.reason ?? (isAdd ? 'إضافة' : 'سحب'),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  dateFormat.format(movement.createdAt),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2.h,
            ),
            decoration: BoxDecoration(
              color: (isAdd ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              '${isAdd ? '+' : '-'}${movement.quantity}',
              style: AppTypography.labelMedium.copyWith(
                color: isAdd ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Low Stock Card - Enterprise Style
// ═══════════════════════════════════════════════════════════════════════════

class _LowStockCard extends StatelessWidget {
  final Product product;

  const _LowStockCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // ✅ حساب مستوى الخطورة
    final severity = _calculateSeverity();

    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      borderColor: severity.color.withValues(alpha: 0.3),
      child: Row(
        children: [
          // ✅ أيقونة حسب مستوى الخطورة - Enterprise Square Style
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: severity.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: severity.color.withValues(alpha: 0.2)),
            ),
            child: Icon(severity.icon, color: severity.color, size: 18.sp),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'الحد الأدنى: ${product.minQuantity}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: severity.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  '${product.quantity}',
                  style: AppTypography.labelMedium.copyWith(
                    color: severity.color,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                severity.label,
                style: AppTypography.labelSmall.copyWith(
                  color: severity.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ دالة لحساب مستوى الخطورة
  _StockSeverity _calculateSeverity() {
    if (product.quantity <= 0) {
      return _StockSeverity(
        color: AppColors.error,
        icon: Icons.error_rounded,
        label: 'نفذ',
      );
    } else if (product.quantity <= product.minQuantity * 0.5) {
      return _StockSeverity(
        color: AppColors.error,
        icon: Icons.warning_rounded,
        label: 'حرج',
      );
    } else {
      return _StockSeverity(
        color: AppColors.warning,
        icon: Icons.info_rounded,
        label: 'منخفض',
      );
    }
  }
}

// ✅ كلاس مساعد لمستوى الخطورة
class _StockSeverity {
  final Color color;
  final IconData icon;
  final String label;

  const _StockSeverity({
    required this.color,
    required this.icon,
    required this.label,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// Stock Card - Enterprise Style with Tabular Figures
// ═══════════════════════════════════════════════════════════════════════════

class _StockCard extends StatelessWidget {
  final Product product;

  const _StockCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isLow = product.quantity <= product.minQuantity;
    final isOut = product.quantity <= 0;

    // ✅ تحديد اللون حسب الحالة
    final Color statusColor = isOut
        ? AppColors.error
        : isLow
            ? AppColors.warning
            : AppColors.success;

    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          // Enterprise: Compact square icon
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border),
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
                  product.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'SKU: ${product.sku ?? 'N/A'}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (product.barcode != null) ...[
                      SizedBox(width: AppSpacing.xs),
                      Icon(Icons.qr_code,
                          size: 10.sp, color: AppColors.textTertiary),
                      SizedBox(width: 2.w),
                      Text(
                        product.barcode!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.xs),
              border: Border.all(color: statusColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isOut)
                  Icon(Icons.error_outline, size: 12.sp, color: statusColor),
                if (isOut) SizedBox(width: 2.w),
                Text(
                  isOut ? 'نفذ' : '${product.quantity}',
                  style: AppTypography.labelMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontFeatures:
                        isOut ? null : const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Type Button - Enterprise Style
// ═══════════════════════════════════════════════════════════════════════════

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18.sp,
                color: isSelected ? color : AppColors.textSecondary),
            SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
