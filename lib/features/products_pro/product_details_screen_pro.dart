// ═══════════════════════════════════════════════════════════════════════════
// Product Details Screen Pro - Enterprise Accounting Design
// View detailed product information with Ledger Precision
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
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
        body: ProLoadingState.card(),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: ProAppBar.simple(title: 'تفاصيل المنتج'),
        body: ProEmptyState.error(error: error.toString()),
      ),
      data: (products) {
        final product = products.where((p) => p.id == productId).firstOrNull;
        if (product == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: ProAppBar.simple(title: 'تفاصيل المنتج'),
            body: const Center(child: Text('المنتج غير موجود')),
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
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.surface.o87,
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
                    color: AppColors.surface.o87,
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
                    color: AppColors.surface.o87,
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
                      value: 'generate_barcode',
                      child: Text('توليد باركود جديد')),
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
                          size: 80.sp,
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
                  SizedBox(height: AppSpacing.md),

                  // Quick Stats - حجم أصغر
                  _buildQuickStats(),
                  SizedBox(height: AppSpacing.md),

                  // Price Info
                  _buildPriceSection(),
                  SizedBox(height: AppSpacing.md),

                  // Stock Info
                  _buildStockSection(),
                  SizedBox(height: AppSpacing.md),

                  // Product Details
                  _buildDetailsSection(),
                  SizedBox(height: AppSpacing.xl),
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
      case 'generate_barcode':
        await _generateAndSaveBarcode(context);
        break;
      case 'delete':
        final confirm = await showProDeleteDialog(
          context: context,
          itemName: 'المنتج',
        );
        if (confirm == true) {
          try {
            final productRepo = ref.read(productRepositoryProvider);
            await productRepo.deleteProduct(product.id);
            if (context.mounted) {
              ProSnackbar.deleted(context);
              context.pop();
            }
          } catch (e) {
            if (context.mounted) {
              ProSnackbar.error(context, e.toString());
            }
          }
        }
        break;
    }
  }

  /// توليد باركود EAN-13 تلقائي
  String _generateEAN13Barcode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final prefix = '200'; // Custom prefix for internal products
    final uniquePart = timestamp.substring(timestamp.length - 9);
    final barcodeWithoutCheck = '$prefix$uniquePart';

    // Calculate check digit for EAN-13
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(barcodeWithoutCheck[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    int checkDigit = (10 - (sum % 10)) % 10;

    return '$barcodeWithoutCheck$checkDigit';
  }

  /// توليد باركود جديد وحفظه
  Future<void> _generateAndSaveBarcode(BuildContext context) async {
    final newBarcode = _generateEAN13Barcode();

    try {
      final productRepo = ref.read(productRepositoryProvider);
      await productRepo.updateProduct(
        id: product.id,
        barcode: newBarcode,
      );

      if (context.mounted) {
        ProSnackbar.success(context, 'تم توليد الباركود: $newBarcode');
        Clipboard.setData(ClipboardData(text: newBarcode));
      }
    } catch (e) {
      if (context.mounted) {
        ProSnackbar.error(context, e.toString());
      }
    }
  }

  /// طباعة الباركود فقط (بدون اسم المنتج والسعر)
  void _printBarcode(BuildContext context) async {
    final barcodeValue = product.barcode;

    if (barcodeValue == null || barcodeValue.isEmpty) {
      ProSnackbar.warning(
          context, 'لا يوجد باركود لهذا المنتج. قم بتوليد باركود أولاً.');
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        margin: const pw.EdgeInsets.all(5),
        build: (pw.Context ctx) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.ean13(),
                  data: barcodeValue,
                  width: 150,
                  height: 50,
                  drawText: true,
                  textStyle: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'barcode_${product.barcode ?? product.id}',
    );
  }

  void _showStockAdjustmentDialog(BuildContext context) {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    String adjustmentType = 'add';

    showProDialog(
      context: context,
      title: 'تعديل المخزون',
      icon: Icons.inventory_2_rounded,
      child: StatefulBuilder(
        builder: (context, setDialogState) => Column(
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
                    activeColor: AppColors.primary,
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
                    activeColor: AppColors.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            ProTextField(
              controller: quantityController,
              label: 'الكمية',
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppSpacing.sm),
            ProTextField(
              controller: reasonController,
              label: 'السبب (اختياري)',
              prefixIcon: Icons.edit_note,
            ),
            SizedBox(height: AppSpacing.xl),
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
                  child: ProButton(
                    label: 'تأكيد',
                    type: ProButtonType.filled,
                    color: adjustmentType == 'add'
                        ? AppColors.primary
                        : AppColors.error,
                    onPressed: () async {
                      final quantity =
                          int.tryParse(quantityController.text) ?? 0;
                      if (quantity <= 0) {
                        ProSnackbar.warning(context, 'أدخل كمية صحيحة');
                        return;
                      }

                      // التحقق من عدم السحب أكثر من المتوفر
                      if (adjustmentType == 'subtract' &&
                          quantity > product.quantity) {
                        ProSnackbar.error(context,
                            'لا يمكن سحب أكثر من الكمية المتوفرة (${product.quantity})');
                        return;
                      }

                      try {
                        final adjustment =
                            adjustmentType == 'add' ? quantity : -quantity;
                        final productRepo = ref.read(productRepositoryProvider);
                        await productRepo.adjustStock(
                            product.id,
                            adjustment,
                            reasonController.text.isEmpty
                                ? 'تعديل يدوي'
                                : reasonController.text);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ProSnackbar.success(
                              context,
                              adjustmentType == 'add'
                                  ? 'تم إضافة $quantity وحدة'
                                  : 'تم سحب $quantity وحدة');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ProSnackbar.error(context, e.toString());
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addToSale(BuildContext context) {
    // Navigate to sales invoice screen with product pre-selected
    context.push('/sales/add', extra: {
      'preSelectedProduct': {
        'id': product.id,
        'name': product.name,
        'barcode': product.barcode,
        'salePrice': product.salePrice,
        'purchasePrice': product.purchasePrice,
        'quantity': 1, // الكمية الافتراضية
        'availableStock': product.quantity,
      },
    });
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
                  color: AppColors.secondary.soft,
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
                  color: AppColors.success.soft,
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
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            if (product.sku != null && product.sku!.isNotEmpty) ...[
              Icon(
                Icons.qr_code_rounded,
                size: AppIconSize.xs,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                product.sku!,
                style: AppTypography.bodySmall
                    .copyWith(
                      color: AppColors.textSecondary,
                    )
                    .mono,
              ),
            ],
            if (product.barcode != null && product.barcode!.isNotEmpty) ...[
              SizedBox(width: AppSpacing.md),
              Icon(
                Icons.view_week_rounded,
                size: AppIconSize.xs,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  product.barcode!,
                  style: AppTypography.bodySmall
                      .copyWith(
                        color: AppColors.textTertiary,
                      )
                      .mono,
                  overflow: TextOverflow.ellipsis,
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
          child: ProStatCardText(
            icon: Icons.attach_money_rounded,
            label: 'سعر البيع',
            value: product.salePrice.toStringAsFixed(0),
            color: AppColors.secondary,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: ProStatCardText(
            icon: Icons.inventory_2_outlined,
            label: 'المخزون',
            value: '${product.quantity}',
            color: product.quantity > product.minQuantity
                ? AppColors.success
                : AppColors.warning,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: ProStatCardText(
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
            '${product.salePrice.toStringAsFixed(0)} ل.س',
            valueStyle: AppTypography.titleMedium
                .copyWith(
                  color: AppColors.secondary,
                )
                .monoBold,
          ),
          Divider(height: AppSpacing.md, color: AppColors.border),
          _buildInfoRow(
            'سعر التكلفة',
            '${product.purchasePrice.toStringAsFixed(0)} ل.س',
            valueStyle: AppTypography.bodyMedium
                .copyWith(
                  color: AppColors.textSecondary,
                )
                .mono,
          ),
          SizedBox(height: AppSpacing.xs),
          _buildInfoRow(
            'الربح لكل وحدة',
            '${profit.toStringAsFixed(0)} ل.س (${margin.toStringAsFixed(1)}%)',
            valueStyle: AppTypography.bodyMedium
                .copyWith(
                  color: AppColors.success,
                )
                .monoSemibold,
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
          SizedBox(height: AppSpacing.xs),
          _buildInfoRow('حد التنبيه', '${product.minQuantity} وحدة'),
          SizedBox(height: AppSpacing.sm),

          // Stock Status
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: product.quantity > product.minQuantity
                  ? AppColors.success.soft
                  : product.quantity > 0
                      ? AppColors.warning.soft
                      : AppColors.error.soft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Icon(
                  product.quantity > product.minQuantity
                      ? Icons.check_circle_outline
                      : product.quantity > 0
                          ? Icons.warning_amber_rounded
                          : Icons.error_outline,
                  color: product.quantity > product.minQuantity
                      ? AppColors.success
                      : product.quantity > 0
                          ? AppColors.warning
                          : AppColors.error,
                  size: AppIconSize.sm,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    product.quantity > product.minQuantity
                        ? 'المخزون كافي'
                        : product.quantity > 0
                            ? 'المخزون منخفض - يُنصح بإعادة الطلب'
                            : 'نفد المخزون',
                    style: AppTypography.bodySmall.copyWith(
                      color: product.quantity > product.minQuantity
                          ? AppColors.success
                          : product.quantity > 0
                              ? AppColors.warning
                              : AppColors.error,
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
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Divider(color: AppColors.border),
            SizedBox(height: AppSpacing.sm),
          ],
          _buildInfoRow('تاريخ الإضافة', dateFormat.format(product.createdAt)),
          SizedBox(height: AppSpacing.xs),
          _buildInfoRow('آخر تحديث', dateFormat.format(product.updatedAt)),
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
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
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
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: AppSpacing.sm),
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
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              AppTypography.bodySmall.copyWith(
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
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// تم نقل _StatCard إلى ProStatCardText في core/widgets/pro_stats_card.dart
