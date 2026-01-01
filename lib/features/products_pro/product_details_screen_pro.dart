// ═══════════════════════════════════════════════════════════════════════════
// Product Details Screen Pro
// View detailed product information
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/theme/pro/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';

class ProductDetailsScreenPro extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreenPro({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return productsAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textSecondary),
          ),
        ),
        body: Center(child: Text('خطأ: $error')),
      ),
      data: (products) {
        final product = products.where((p) => p.id == productId).firstOrNull;
        if (product == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: AppColors.textSecondary),
              ),
            ),
            body: Center(child: Text('المنتج غير موجود')),
          );
        }

        final categories = categoriesAsync.asData?.value ?? [];
        final category =
            categories.where((c) => c.id == product.categoryId).firstOrNull;

        return _ProductDetailsView(
          product: product,
          category: category,
          ref: ref,
        );
      },
    );
  }
}

class _ProductDetailsView extends StatelessWidget {
  final Product product;
  final Category? category;
  final WidgetRef ref;

  const _ProductDetailsView({
    required this.product,
    this.category,
    required this.ref,
  });

  double get profit => product.salePrice - product.purchasePrice;
  double get margin =>
      product.salePrice > 0 ? (profit / product.salePrice * 100) : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ═══════════════════════════════════════════════════════════════════
          // App Bar
          // ═══════════════════════════════════════════════════════════════════
          SliverAppBar(
            expandedHeight: 280.h,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: AppIconSize.sm,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/products/edit/${product.id}'),
                icon: Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: AppIconSize.sm,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: AppIconSize.sm,
                    color: AppColors.textPrimary,
                  ),
                ),
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'print', child: Text('طباعة الباركود')),
                  const PopupMenuItem(
                      value: 'history', child: Text('سجل الحركات')),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child:
                        Text('حذف', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.xs),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.background,
                child: product.imageUrl != null
                    ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                    : Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 100.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════════════
          // Content
          // ═══════════════════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name & Category
                  _buildHeader(),
                  SizedBox(height: AppSpacing.lg),

                  // Quick Stats
                  _buildQuickStats(),
                  SizedBox(height: AppSpacing.lg),

                  // Price Info
                  _buildPriceSection(),
                  SizedBox(height: AppSpacing.lg),

                  // Stock Info
                  _buildStockSection(),
                  SizedBox(height: AppSpacing.lg),

                  // Product Details
                  _buildDetailsSection(),
                  SizedBox(height: AppSpacing.lg),

                  // Recent Activity
                  _buildRecentActivity(),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  void _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'print':
        _printBarcode(context);
        break;
      case 'history':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سجل الحركات - قريباً')),
        );
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('حذف المنتج'),
            content: const Text('هل أنت متأكد من حذف هذا المنتج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          try {
            final productRepo = ref.read(productRepositoryProvider);
            await productRepo.deleteProduct(product.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('تم حذف المنتج بنجاح'),
                    backgroundColor: AppColors.success),
              );
              context.pop();
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('خطأ: $e'), backgroundColor: AppColors.error),
              );
            }
          }
        }
        break;
    }
  }

  void _printBarcode(BuildContext context) async {
    final barcodeValue = product.barcode ?? product.id;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        build: (pw.Context ctx) {
          return pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: barcodeValue,
              width: 150,
              height: 50,
              drawText: false,
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'barcode_${product.name}',
    );
  }

  void _showStockAdjustmentDialog(BuildContext context) {
    final quantityController = TextEditingController();
    String adjustmentType = 'add';
    String reason = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تعديل المخزون'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الكمية الحالية: ${product.quantity}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('إضافة'),
                      value: 'add',
                      groupValue: adjustmentType,
                      onChanged: (value) =>
                          setDialogState(() => adjustmentType = value!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('سحب'),
                      value: 'subtract',
                      groupValue: adjustmentType,
                      onChanged: (value) =>
                          setDialogState(() => adjustmentType = value!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الكمية',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                onChanged: (value) => reason = value,
                decoration: InputDecoration(
                  labelText: 'السبب (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('أدخل كمية صحيحة')),
                  );
                  return;
                }

                try {
                  final adjustment =
                      adjustmentType == 'add' ? quantity : -quantity;
                  final productRepo = ref.read(productRepositoryProvider);
                  await productRepo.adjustStock(product.id, adjustment,
                      reason.isEmpty ? 'تعديل يدوي' : reason);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تعديل المخزون بنجاح'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  void _addToSale(BuildContext context) {
    // Navigate to sales screen with product pre-selected
    context.push('/sales', extra: {'productId': product.id});
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (category != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  category!.name,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(width: AppSpacing.sm),
            if (product.isActive)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'نشط',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          product.name,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            if (product.sku != null) ...[
              Icon(
                Icons.qr_code_rounded,
                size: AppIconSize.xs,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                product.sku!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
            if (product.barcode != null) ...[
              SizedBox(width: AppSpacing.md),
              Icon(
                Icons.view_week_rounded,
                size: AppIconSize.xs,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                product.barcode!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_cart_outlined,
            label: 'سعر البيع',
            value: '${product.salePrice.toStringAsFixed(0)}',
            color: AppColors.secondary,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.inventory_2_outlined,
            label: 'المخزون',
            value: '${product.quantity}',
            color: product.quantity > product.minQuantity
                ? AppColors.success
                : AppColors.warning,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            label: 'هامش الربح',
            value: '${margin.toStringAsFixed(0)}%',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return _buildCard(
      title: 'التسعير',
      icon: Icons.attach_money_rounded,
      child: Column(
        children: [
          _buildInfoRow(
            'سعر البيع',
            '${product.salePrice.toStringAsFixed(0)} ر.س',
            valueStyle: AppTypography.titleLarge.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          Divider(height: AppSpacing.lg, color: AppColors.border),
          _buildInfoRow(
            'سعر التكلفة',
            '${product.purchasePrice.toStringAsFixed(0)} ر.س',
            valueStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'الربح لكل وحدة',
            '${profit.toStringAsFixed(0)} ر.س (${margin.toStringAsFixed(1)}%)',
            valueStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSection() {
    return _buildCard(
      title: 'المخزون',
      icon: Icons.inventory_outlined,
      child: Column(
        children: [
          _buildInfoRow('الكمية المتوفرة', '${product.quantity} وحدة'),
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow('حد التنبيه', '${product.minQuantity} وحدة'),
          SizedBox(height: AppSpacing.md),

          // Stock Status
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: product.quantity > product.minQuantity
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  product.quantity > product.minQuantity
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  color: product.quantity > product.minQuantity
                      ? AppColors.success
                      : AppColors.warning,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    product.quantity > product.minQuantity
                        ? 'المخزون كافي'
                        : 'المخزون منخفض - يُنصح بإعادة الطلب',
                    style: AppTypography.bodyMedium.copyWith(
                      color: product.quantity > product.minQuantity
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return _buildCard(
      title: 'التفاصيل',
      icon: Icons.info_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.description != null &&
              product.description!.isNotEmpty) ...[
            Text(
              product.description!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.border),
            SizedBox(height: AppSpacing.md),
          ],
          _buildInfoRow(
            'خاضع للضريبة',
            product.taxRate != null && product.taxRate! > 0 ? 'نعم' : 'لا',
          ),
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow('تاريخ الإضافة', dateFormat.format(product.createdAt)),
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow('آخر تحديث', dateFormat.format(product.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return _buildCard(
      title: 'آخر الحركات',
      icon: Icons.history_rounded,
      trailing: TextButton(
        onPressed: () {},
        child: Text(
          'عرض الكل',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.secondary,
          ),
        ),
      ),
      child: Column(
        children: [
          _ActivityItem(
            type: 'sale',
            description: 'بيع 2 وحدات',
            date: 'اليوم 10:30 ص',
          ),
          Divider(height: AppSpacing.lg, color: AppColors.border),
          _ActivityItem(
            type: 'purchase',
            description: 'إضافة 10 وحدات',
            date: 'أمس 3:15 م',
          ),
          Divider(height: AppSpacing.lg, color: AppColors.border),
          _ActivityItem(
            type: 'adjustment',
            description: 'تعديل الكمية (-1)',
            date: '20 يونيو 2024',
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppIconSize.sm, color: AppColors.textTertiary),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showStockAdjustmentDialog(context),
                icon: const Icon(Icons.inventory_rounded),
                label: const Text('تعديل المخزون'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _addToSale(context),
                icon: const Icon(Icons.shopping_cart_rounded),
                label: const Text('إضافة للبيع'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
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
        children: [
          Icon(icon, size: AppIconSize.sm, color: color),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String type;
  final String description;
  final String date;

  const _ActivityItem({
    required this.type,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case 'sale':
        icon = Icons.arrow_upward_rounded;
        color = AppColors.success;
        break;
      case 'purchase':
        icon = Icons.arrow_downward_rounded;
        color = AppColors.secondary;
        break;
      default:
        icon = Icons.edit_rounded;
        color = AppColors.warning;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: AppIconSize.sm, color: color),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                date,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
