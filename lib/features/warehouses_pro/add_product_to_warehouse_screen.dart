// ═══════════════════════════════════════════════════════════════════════════════
// Add Product To Warehouse Screen - Enterprise Accounting Design
// إضافة منتج جديد مباشرة إلى المستودع
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:math';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/currency_service.dart';
import '../../core/widgets/widgets.dart';
import '../../data/database/app_database.dart';

class AddProductToWarehouseScreen extends ConsumerStatefulWidget {
  final String warehouseId;
  final Product? product;
  final WarehouseStockData? warehouseStock;

  const AddProductToWarehouseScreen({
    super.key,
    required this.warehouseId,
    this.product,
    this.warehouseStock,
  });

  @override
  ConsumerState<AddProductToWarehouseScreen> createState() =>
      _AddProductToWarehouseScreenState();
}

class _AddProductToWarehouseScreenState
    extends ConsumerState<AddProductToWarehouseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _costPriceUsdController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _isPrintingBarcode = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing && widget.product != null) {
      // Fill with existing data
      _nameController.text = widget.product!.name;
      _barcodeController.text = widget.product!.barcode ?? '';
      _costPriceController.text =
          widget.product!.purchasePrice.toStringAsFixed(0);
      _salePriceController.text = widget.product!.salePrice.toStringAsFixed(0);
      _quantityController.text =
          widget.warehouseStock?.quantity.toString() ?? '0';
      _minStockController.text =
          widget.warehouseStock?.minQuantity.toString() ?? '5';
      _locationController.text = widget.warehouseStock?.location ?? '';
      _selectedCategoryId = widget.product!.categoryId;
    } else {
      _quantityController.text = '0';
      _minStockController.text = '5';
      _costPriceController.text = '0';
      _salePriceController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _costPriceController.dispose();
    _costPriceUsdController.dispose();
    _salePriceController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // توليد باركود EAN-13
  String _generateEAN13Barcode() {
    final random = Random();
    final prefix = '978'; // بادئة للكتب
    final manufacturer = random.nextInt(10000).toString().padLeft(4, '0');
    final product = random.nextInt(10000).toString().padLeft(4, '0');
    final first12 = prefix + manufacturer + product;

    // حساب checksum
    int sum = 0;
    for (int i = 0; i < first12.length; i++) {
      final digit = int.parse(first12[i]);
      sum += (i.isEven) ? digit : digit * 3;
    }
    final checksum = (10 - (sum % 10)) % 10;

    return first12 + checksum.toString();
  }

  bool _isValidEAN13(String barcode) {
    if (barcode.length != 13) return false;
    if (!RegExp(r'^\d{13}$').hasMatch(barcode)) return false;

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(barcode[i]);
      sum += (i.isEven) ? digit : digit * 3;
    }
    final checksum = (10 - (sum % 10)) % 10;
    return checksum == int.parse(barcode[12]);
  }

  void _onGenerateBarcodePressed() {
    final newBarcode = _generateEAN13Barcode();
    setState(() {
      _barcodeController.text = newBarcode;
    });
    ProSnackbar.success(context, 'تم توليد الباركود: $newBarcode');
  }

  Future<void> _printBarcodeOnly() async {
    final barcode = _barcodeController.text.trim();

    if (barcode.isEmpty) {
      ProSnackbar.warning(context, 'الرجاء إدخال أو توليد باركود أولاً');
      return;
    }

    if (!_isValidEAN13(barcode)) {
      ProSnackbar.warning(
          context, 'الباركود غير صالح. يجب أن يكون EAN-13 صحيح');
      return;
    }

    setState(() => _isPrintingBarcode = true);

    try {
      final pdf = pw.Document();
      final pageFormat = PdfPageFormat.roll57;

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(8),
          build: (context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.ean13(),
                    data: barcode,
                    width: 45 * PdfPageFormat.mm,
                    height: 20 * PdfPageFormat.mm,
                    drawText: true,
                    textStyle: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'barcode_$barcode',
        format: pageFormat,
      );
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في طباعة الباركود: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isPrintingBarcode = false);
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);

      // Parse values
      final purchasePrice = double.tryParse(_costPriceController.text) ?? 0.0;
      final purchasePriceUsd =
          double.tryParse(_costPriceUsdController.text) ?? 0.0;
      final salePrice = double.tryParse(_salePriceController.text) ?? 0.0;
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final minStock = int.tryParse(_minStockController.text) ?? 5;

      // Calculate sale price USD if needed
      double? salePriceUsd;
      if (salePrice > 0) {
        salePriceUsd = salePrice / CurrencyService.currentRate;
      }

      if (isEditing && widget.product != null) {
        // ═══════════════════════════════════════════════════════════════
        // وضع التعديل - تحديث منتج موجود
        // ═══════════════════════════════════════════════════════════════

        // Update product
        await db.updateProduct(ProductsCompanion(
          id: drift.Value(widget.product!.id),
          name: drift.Value(_nameController.text.trim()),
          barcode: drift.Value(
            _barcodeController.text.trim().isEmpty
                ? null
                : _barcodeController.text.trim(),
          ),
          categoryId: drift.Value(_selectedCategoryId),
          purchasePrice: drift.Value(purchasePrice),
          purchasePriceUsd:
              drift.Value(purchasePriceUsd > 0 ? purchasePriceUsd : null),
          salePrice: drift.Value(salePrice),
          salePriceUsd: drift.Value(salePriceUsd),
          minQuantity: drift.Value(minStock),
          syncStatus: const drift.Value('pending'),
        ));

        // Update warehouse stock
        if (widget.warehouseStock != null) {
          await db.updateWarehouseStock(WarehouseStockCompanion(
            id: drift.Value(widget.warehouseStock!.id),
            quantity: drift.Value(quantity),
            minQuantity: drift.Value(minStock),
            location: drift.Value(
              _locationController.text.isEmpty
                  ? null
                  : _locationController.text,
            ),
            syncStatus: const drift.Value('pending'),
          ));
        }

        if (mounted) {
          Navigator.pop(context);
          ProSnackbar.success(context, 'تم تحديث المنتج بنجاح');
        }
      } else {
        // ═══════════════════════════════════════════════════════════════
        // وضع الإضافة - إنشاء منتج جديد
        // ═══════════════════════════════════════════════════════════════

        // Generate IDs
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final productId = timestamp.toString();
        final stockId = '${timestamp}_stock';

        // Create product
        await db.insertProduct(ProductsCompanion(
          id: drift.Value(productId),
          name: drift.Value(_nameController.text.trim()),
          barcode: drift.Value(
            _barcodeController.text.trim().isEmpty
                ? null
                : _barcodeController.text.trim(),
          ),
          categoryId: drift.Value(_selectedCategoryId),
          purchasePrice: drift.Value(purchasePrice),
          purchasePriceUsd:
              drift.Value(purchasePriceUsd > 0 ? purchasePriceUsd : null),
          salePrice: drift.Value(salePrice),
          salePriceUsd: drift.Value(salePriceUsd),
          exchangeRateAtCreation: drift.Value(CurrencyService.currentRate),
          quantity: const drift.Value(0), // لن يُستخدم مع المستودعات
          minQuantity: drift.Value(minStock),
          isActive: const drift.Value(true),
          syncStatus: const drift.Value('pending'),
        ));

        // Add to warehouse
        await db.insertWarehouseStock(WarehouseStockCompanion(
          id: drift.Value(stockId),
          warehouseId: drift.Value(widget.warehouseId),
          productId: drift.Value(productId),
          quantity: drift.Value(quantity),
          minQuantity: drift.Value(minStock),
          location: drift.Value(
            _locationController.text.isEmpty ? null : _locationController.text,
          ),
          syncStatus: const drift.Value('pending'),
        ));

        if (mounted) {
          Navigator.pop(context);
          ProSnackbar.success(
              context, 'تم إنشاء المنتج وإضافته للمستودع بنجاح');
        }
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'تعديل منتج في المستودع' : 'إضافة منتج جديد للمستودع',
          style: AppTypography.titleLarge,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.md),
            child: ProButton(
              label: 'حفظ',
              icon: Icons.check,
              isLoading: _isLoading,
              onPressed: _saveProduct,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          // ═══════════════════════════════════════════════════════════════
          // 1. المعلومات الأساسية
          // ═══════════════════════════════════════════════════════════════
          const ProSectionTitle('المعلومات الأساسية'),
          SizedBox(height: AppSpacing.sm),
          ProTextField(
            controller: _nameController,
            label: 'اسم المنتج',
            hint: 'أدخل اسم المنتج',
            prefixIcon: Icons.inventory_2_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال اسم المنتج';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildCategorySelector(),
          SizedBox(height: AppSpacing.md),
          // حقل الباركود مع أزرار التوليد والطباعة
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _barcodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    labelText: 'الباركود',
                    hintText: '0000000000000',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    prefixIcon: Icon(
                      Icons.qr_code_rounded,
                      color: AppColors.textTertiary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(AppRadius.md),
                      ),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(AppRadius.md),
                      ),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(AppRadius.md),
                      ),
                      borderSide:
                          BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ),
              // Generate Button
              Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: IconButton(
                  onPressed: _onGenerateBarcodePressed,
                  icon: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                  ),
                  tooltip: 'توليد باركود',
                ),
              ),
              // Print Button
              Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.md),
                  ),
                ),
                child: IconButton(
                  onPressed: _isPrintingBarcode ? null : _printBarcodeOnly,
                  icon: Icon(
                    Icons.print_rounded,
                    color: _isPrintingBarcode
                        ? AppColors.textTertiary
                        : AppColors.secondary,
                  ),
                  tooltip: 'طباعة الباركود',
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════════
          // 2. التسعير
          // ═══════════════════════════════════════════════════════════════
          const ProSectionTitle('التسعير'),
          SizedBox(height: AppSpacing.sm),
          // سعر الصرف الحالي
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            margin: EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.currency_exchange,
                    color: AppColors.primary, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'سعر الصرف: 1\$ = ${CurrencyService.currentRate.toStringAsFixed(0)} ل.س',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // سعر التكلفة
          Row(
            children: [
              Expanded(
                child: ProNumberField(
                  controller: _costPriceUsdController,
                  label: 'سعر التكلفة (\$)',
                  hint: '0.00',
                  validator: (value) {
                    // يجب إدخال سعر التكلفة بالدولار أو الليرة
                    if ((value == null || value.trim().isEmpty) &&
                        _costPriceController.text.trim().isEmpty) {
                      return 'مطلوب';
                    }
                    // عند الإضافة (ليس التعديل)، يجب أن يكون السعر أكبر من صفر
                    if (!isEditing) {
                      final usd = double.tryParse(value ?? '');
                      final syp = double.tryParse(_costPriceController.text);
                      if ((usd == null || usd <= 0) &&
                          (syp == null || syp <= 0)) {
                        return 'السعر مطلوب';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // حساب تلقائي لليرة
                    if (value.isNotEmpty) {
                      final usd = double.tryParse(value);
                      if (usd != null && usd > 0) {
                        final syp = usd * CurrencyService.currentRate;
                        _costPriceController.text = syp.toStringAsFixed(0);
                      }
                    }
                  },
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: ProNumberField(
                  controller: _costPriceController,
                  label: 'سعر التكلفة (ل.س)',
                  hint: '0',
                  validator: (value) {
                    // عند الإضافة (ليس التعديل)، يجب أن يكون السعر أكبر من صفر
                    if (!isEditing) {
                      final syp = double.tryParse(value ?? '');
                      final usd = double.tryParse(_costPriceUsdController.text);
                      if ((syp == null || syp <= 0) &&
                          (usd == null || usd <= 0)) {
                        return 'السعر مطلوب';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // حساب تلقائي للدولار إذا كان فارغاً
                    if (_costPriceUsdController.text.isEmpty &&
                        value.isNotEmpty) {
                      final syp = double.tryParse(value);
                      if (syp != null && syp > 0) {
                        final usd = syp / CurrencyService.currentRate;
                        _costPriceUsdController.text = usd.toStringAsFixed(2);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // سعر البيع
          ProNumberField(
            controller: _salePriceController,
            label: 'سعر البيع (ل.س)',
            hint: 'اختياري - اتركه فارغاً لحسابه تلقائياً',
          ),
          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════════
          // 3. المخزون
          // ═══════════════════════════════════════════════════════════════
          const ProSectionTitle('معلومات المستودع'),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ProNumberField(
                  controller: _quantityController,
                  label: 'الكمية',
                  hint: '0',
                  allowDecimal: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الكمية مطلوبة';
                    }
                    final qty = int.tryParse(value);
                    if (qty == null || qty < 0) {
                      return 'كمية غير صالحة';
                    }
                    // عند الإضافة، يجب أن تكون الكمية أكبر من صفر
                    if (!isEditing && qty == 0) {
                      return 'يجب إدخال كمية أكبر من صفر';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: ProNumberField(
                  controller: _minStockController,
                  label: 'الحد الأدنى',
                  hint: '5',
                  allowDecimal: false,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ProTextField(
            controller: _locationController,
            label: 'الموقع في المستودع',
            hint: 'مثال: رف A-3 (اختياري)',
            prefixIcon: Icons.location_on_outlined,
          ),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      loading: () => Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Text(
          'خطأ في تحميل الفئات',
          style: TextStyle(color: AppColors.error),
        ),
      ),
      data: (categories) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'الفئة',
              prefixIcon:
                  Icon(Icons.category_outlined, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
            hint: const Text('اختر الفئة (اختياري)'),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
          ),
        );
      },
    );
  }
}
