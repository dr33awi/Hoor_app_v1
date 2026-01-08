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
import '../../core/widgets/dual_price_display.dart';
import '../../core/services/currency_service.dart';
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

class _ProductDetailsView extends ConsumerStatefulWidget {
  final Product product;
  final Category? category;
  final WidgetRef ref;

  const _ProductDetailsView({
    required this.product,
    this.category,
    required this.ref,
  });

  @override
  ConsumerState<_ProductDetailsView> createState() =>
      _ProductDetailsViewState();
}

class _ProductDetailsViewState extends ConsumerState<_ProductDetailsView> {
  Product get product => widget.product;
  Category? get category => widget.category;

  double get profit => product.salePrice - product.purchasePrice;
  double get margin =>
      product.salePrice > 0 ? (profit / product.salePrice * 100) : 0;

  // الكمية الإجمالية من المستودعات
  int _totalStock = 0;
  bool _stockLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTotalStock();
  }

  Future<void> _loadTotalStock() async {
    final db = ref.read(databaseProvider);
    final stock = await db.getWarehouseStockByProduct(product.id);
    if (mounted) {
      setState(() {
        _totalStock = stock.isEmpty
            ? product.quantity
            : stock.fold<int>(0, (sum, s) => sum + s.quantity);
        _stockLoaded = true;
      });
    }
  }

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

                  // Warehouse Stock Distribution - توزيع المخزون على المستودعات
                  _buildWarehouseStockSection(),
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
    // حساب السعر من الدولار × سعر الصرف الحالي
    final currentRate = CurrencyService.currentRate;
    final salePriceSyp =
        (product.salePriceUsd != null && product.salePriceUsd! > 0)
            ? product.salePriceUsd! * currentRate
            : product.salePrice;
    final purchasePriceSyp =
        (product.purchasePriceUsd != null && product.purchasePriceUsd! > 0)
            ? product.purchasePriceUsd! * currentRate
            : product.purchasePrice;
    final currentProfit = salePriceSyp - purchasePriceSyp;
    final currentMargin =
        salePriceSyp > 0 ? (currentProfit / salePriceSyp * 100) : 0.0;

    return Row(
      children: [
        Expanded(
          child: ProStatCardText(
            icon: Icons.attach_money_rounded,
            label: 'سعر البيع',
            value: salePriceSyp.toStringAsFixed(0),
            color: AppColors.secondary,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: ProStatCardText(
            icon: Icons.inventory_2_outlined,
            label: 'المخزون',
            value: _stockLoaded ? '$_totalStock' : '...',
            color: _totalStock > product.minQuantity
                ? AppColors.success
                : AppColors.warning,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: ProStatCardText(
            icon: Icons.trending_up_rounded,
            label: 'هامش الربح',
            value: '${currentMargin.toStringAsFixed(0)}%',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    // ═══════════════════════════════════════════════════════════════════════════
    // الدولار هو الأساس: السعر بالليرة = الدولار × سعر الصرف الحالي
    // ═══════════════════════════════════════════════════════════════════════════
    final currentRate = CurrencyService.currentRate;

    // استخدام أسعار الدولار المحفوظة وحساب الليرة من سعر الصرف الحالي
    final purchasePriceUsd = product.purchasePriceUsd;
    final salePriceUsd = product.salePriceUsd;

    // حساب الأسعار بالليرة من الدولار × سعر الصرف الحالي
    final purchasePriceSyp = (purchasePriceUsd != null && purchasePriceUsd > 0)
        ? purchasePriceUsd * currentRate
        : product.purchasePrice;
    final salePriceSyp = (salePriceUsd != null && salePriceUsd > 0)
        ? salePriceUsd * currentRate
        : product.salePrice;

    final profitSyp = salePriceSyp - purchasePriceSyp;
    final profitUsd = (salePriceUsd != null && purchasePriceUsd != null)
        ? salePriceUsd - purchasePriceUsd
        : null;
    final marginPercent =
        salePriceSyp > 0 ? (profitSyp / salePriceSyp * 100) : 0.0;

    return _buildCard(
      title: 'التسعير',
      icon: Icons.attach_money_rounded,
      child: Column(
        children: [
          _buildInfoRowWithDualPrice(
            'سعر البيع',
            salePriceSyp,
            salePriceUsd,
            currentRate,
            valueColor: AppColors.secondary,
            isBold: true,
          ),
          Divider(height: AppSpacing.md, color: AppColors.border),
          _buildInfoRowWithDualPrice(
            'سعر التكلفة',
            purchasePriceSyp,
            purchasePriceUsd,
            currentRate,
            valueColor: AppColors.textSecondary,
          ),
          SizedBox(height: AppSpacing.xs),
          _buildInfoRowWithDualPrice(
            'الربح لكل وحدة',
            profitSyp,
            profitUsd,
            currentRate,
            valueColor: AppColors.success,
            suffix: ' (${marginPercent.toStringAsFixed(1)}%)',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithDualPrice(
    String label,
    double amountSyp,
    double? amountUsd,
    double? exchangeRate, {
    Color? valueColor,
    bool isBold = false,
    String? suffix,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DualPriceDisplay(
              amountSyp: amountSyp,
              amountUsd: amountUsd,
              exchangeRate: exchangeRate,
              type: DualPriceDisplayType.horizontal,
              sypStyle: isBold
                  ? AppTypography.titleMedium
                      .copyWith(color: valueColor ?? AppColors.textPrimary)
                      .monoBold
                  : AppTypography.bodyMedium
                      .copyWith(color: valueColor ?? AppColors.textPrimary)
                      .mono,
              usdStyle: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary)
                  .mono,
            ),
            if (suffix != null)
              Text(
                suffix,
                style: AppTypography.bodyMedium
                    .copyWith(color: valueColor ?? AppColors.textPrimary)
                    .mono,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockSection() {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<WarehouseStockData>>(
      future: db.getWarehouseStockByProduct(product.id),
      builder: (context, snapshot) {
        final stock = snapshot.data ?? [];
        // حساب الكمية الإجمالية من المستودعات أو استخدام كمية المنتج إذا لم توجد بيانات
        final totalQuantity = stock.isEmpty
            ? product.quantity
            : stock.fold<int>(0, (sum, s) => sum + s.quantity);

        return _buildCard(
          title: 'المخزون',
          icon: Icons.inventory_outlined,
          child: Column(
            children: [
              _buildInfoRow('الكمية المتوفرة', '$totalQuantity وحدة'),
              SizedBox(height: AppSpacing.xs),
              _buildInfoRow('حد التنبيه', '${product.minQuantity} وحدة'),
              SizedBox(height: AppSpacing.sm),

              // Stock Status
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: totalQuantity > product.minQuantity
                      ? AppColors.success.soft
                      : totalQuantity > 0
                          ? AppColors.warning.soft
                          : AppColors.error.soft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      totalQuantity > product.minQuantity
                          ? Icons.check_circle_outline
                          : totalQuantity > 0
                              ? Icons.warning_amber_rounded
                              : Icons.error_outline,
                      color: totalQuantity > product.minQuantity
                          ? AppColors.success
                          : totalQuantity > 0
                              ? AppColors.warning
                              : AppColors.error,
                      size: AppIconSize.sm,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        totalQuantity > product.minQuantity
                            ? 'المخزون كافي'
                            : totalQuantity > 0
                                ? 'المخزون منخفض - يُنصح بإعادة الطلب'
                                : 'نفد المخزون',
                        style: AppTypography.bodySmall.copyWith(
                          color: totalQuantity > product.minQuantity
                              ? AppColors.success
                              : totalQuantity > 0
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
      },
    );
  }

  /// قسم توزيع المخزون على المستودعات
  Widget _buildWarehouseStockSection() {
    final db = ref.watch(databaseProvider);
    final warehousesAsync = ref.watch(activeWarehousesStreamProvider);

    return warehousesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (warehouses) {
        if (warehouses.isEmpty) return const SizedBox.shrink();

        return FutureBuilder<List<WarehouseStockData>>(
          future: db.getWarehouseStockByProduct(product.id),
          builder: (context, snapshot) {
            final stock = snapshot.data ?? [];

            // إذا لم توجد بيانات مستودعات وعدد المستودعات واحد فقط - إخفاء القسم
            if (stock.isEmpty && warehouses.length <= 1) {
              return const SizedBox.shrink();
            }

            // حساب الإجمالي - استخدام كمية المنتج الأصلية إذا لم توجد بيانات مستودعات
            final totalFromStock =
                stock.fold<int>(0, (sum, s) => sum + s.quantity);
            final totalQuantity =
                stock.isEmpty ? product.quantity : totalFromStock;

            return _buildCard(
              title: 'توزيع المخزون على المستودعات',
              icon: Icons.warehouse_rounded,
              trailing: IconButton(
                onPressed: () =>
                    _showTransferDialog(context, warehouses, stock),
                icon: Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: AppIconSize.sm,
                ),
                tooltip: 'نقل بين المستودعات',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              child: Column(
                children: [
                  // عرض المستودعات مع الكميات
                  ...warehouses.map((warehouse) {
                    final warehouseStock = stock
                        .where((s) => s.warehouseId == warehouse.id)
                        .firstOrNull;

                    // إذا لم توجد بيانات مستودعات، اعرض كمية المنتج في المستودع الافتراضي
                    final qty = warehouseStock?.quantity ??
                        (warehouse.isDefault && stock.isEmpty
                            ? product.quantity
                            : 0);
                    final isLowStock = qty > 0 && qty <= product.minQuantity;
                    final isOutOfStock = qty <= 0;

                    return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // أيقونة المستودع
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: warehouse.isDefault
                                  ? AppColors.primary.soft
                                  : AppColors.secondary.soft,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.warehouse_outlined,
                                color: warehouse.isDefault
                                    ? AppColors.primary
                                    : AppColors.secondary,
                                size: 16.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),

                          // اسم المستودع
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  warehouse.name,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (warehouse.isDefault) ...[
                                  SizedBox(width: AppSpacing.xs),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.soft,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'افتراضي',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // الكمية
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? AppColors.error.soft
                                  : isLowStock
                                      ? AppColors.warning.soft
                                      : AppColors.success.soft,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '$qty',
                              style: AppTypography.labelMedium.copyWith(
                                color: isOutOfStock
                                    ? AppColors.error
                                    : isLowStock
                                        ? AppColors.warning
                                        : AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // الإجمالي
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي في جميع المستودعات',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$totalQuantity وحدة',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// عرض حوار نقل المخزون بين المستودعات
  void _showTransferDialog(
    BuildContext context,
    List<Warehouse> warehouses,
    List<WarehouseStockData> currentStock,
  ) {
    if (warehouses.length < 2) {
      ProSnackbar.warning(context, 'يجب وجود مستودعين على الأقل للنقل');
      return;
    }

    String? fromWarehouseId;
    String? toWarehouseId;
    int transferQuantity = 0;
    int maxQuantity = 0;
    final quantityController = TextEditingController();

    showProDialog(
      context: context,
      title: 'نقل بين المستودعات',
      icon: Icons.swap_horiz_rounded,
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          // حساب الكمية المتاحة للنقل
          if (fromWarehouseId != null) {
            final fromStock = currentStock
                .where((s) => s.warehouseId == fromWarehouseId)
                .firstOrNull;
            maxQuantity = fromStock?.quantity ?? 0;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.name,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),

              // من مستودع
              DropdownButtonFormField<String>(
                value: fromWarehouseId,
                decoration: InputDecoration(
                  labelText: 'من مستودع',
                  prefixIcon: const Icon(Icons.warehouse_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                items: warehouses.map((w) {
                  final qty = currentStock
                          .where((s) => s.warehouseId == w.id)
                          .firstOrNull
                          ?.quantity ??
                      0;
                  return DropdownMenuItem(
                    value: w.id,
                    enabled: qty > 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(w.name),
                        Text(
                          '$qty',
                          style: TextStyle(
                            color: qty > 0
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    fromWarehouseId = value;
                    // إعادة تعيين الكمية عند تغيير المستودع المصدر
                    transferQuantity = 0;
                    if (toWarehouseId == value) {
                      toWarehouseId = null;
                    }
                  });
                },
              ),
              SizedBox(height: AppSpacing.md),

              // إلى مستودع
              DropdownButtonFormField<String>(
                value: toWarehouseId,
                decoration: InputDecoration(
                  labelText: 'إلى مستودع',
                  prefixIcon: const Icon(Icons.warehouse_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                items: warehouses
                    .where((w) => w.id != fromWarehouseId)
                    .map((w) => DropdownMenuItem(
                          value: w.id,
                          child: Text(w.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() => toWarehouseId = value);
                },
              ),
              SizedBox(height: AppSpacing.md),

              // الكمية
              Row(
                children: [
                  Expanded(
                    child: ProTextField(
                      controller: quantityController,
                      label: 'الكمية',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setDialogState(() {
                          transferQuantity = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                  if (maxQuantity > 0) ...[
                    SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          transferQuantity = maxQuantity;
                          quantityController.text = maxQuantity.toString();
                        });
                      },
                      child: Text('الكل ($maxQuantity)'),
                    ),
                  ],
                ],
              ),
              if (fromWarehouseId != null)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    'المتاح للنقل: $maxQuantity وحدة',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

              SizedBox(height: AppSpacing.xl),

              // الأزرار
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
                      label: 'نقل',
                      type: ProButtonType.filled,
                      onPressed: fromWarehouseId != null &&
                              toWarehouseId != null &&
                              transferQuantity > 0 &&
                              transferQuantity <= maxQuantity
                          ? () async {
                              try {
                                final warehouseRepo =
                                    ref.read(warehouseRepositoryProvider);
                                await warehouseRepo.transferStock(
                                  fromWarehouseId: fromWarehouseId!,
                                  toWarehouseId: toWarehouseId!,
                                  items: [
                                    {
                                      'productId': product.id,
                                      'quantity': transferQuantity,
                                    }
                                  ],
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ProSnackbar.success(context,
                                      'تم نقل $transferQuantity وحدة بنجاح');
                                  setState(() {}); // تحديث الواجهة
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ProSnackbar.error(context, e.toString());
                                }
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
