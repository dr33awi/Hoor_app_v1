// ═══════════════════════════════════════════════════════════════════════════════
// Product Form Screen Pro - Enterprise Accounting Design
// Add/Edit product with auto barcode generation and printing
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:math';
import 'dart:ui';
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

class ProductFormScreenPro extends ConsumerStatefulWidget {
  final String? productId; // null for new product

  const ProductFormScreenPro({
    super.key,
    this.productId,
  });

  @override
  ConsumerState<ProductFormScreenPro> createState() =>
      _ProductFormScreenProState();
}

class _ProductFormScreenProState extends ConsumerState<ProductFormScreenPro> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _costPriceUsdController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedWarehouseId;
  bool _isLoading = false;
  bool _isLoadingProduct = false;
  bool _isPrintingBarcode = false;

  bool get isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    // تعيين القيمة الافتراضية للحد الأدنى
    _minStockController.text = '0';

    // تحميل المستودع الافتراضي
    _loadDefaultWarehouse();

    if (isEditing) {
      _loadProduct();
    }
  }

  Future<void> _loadDefaultWarehouse() async {
    try {
      final db = ref.read(databaseProvider);
      final defaultWarehouse = await db.getDefaultWarehouse();
      if (defaultWarehouse != null && mounted) {
        setState(() {
          _selectedWarehouseId = defaultWarehouse.id;
        });
      }
    } catch (e) {
      // Ignore errors - warehouse selection is optional
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _costPriceController.dispose();
    _costPriceUsdController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    if (widget.productId == null) return;

    setState(() => _isLoadingProduct = true);

    try {
      final productRepo = ref.read(productRepositoryProvider);
      final product = await productRepo.getProductById(widget.productId!);

      if (product != null && mounted) {
        // ملء الحقول ببيانات المنتج
        _nameController.text = product.name;
        _barcodeController.text = product.barcode ?? '';
        _descriptionController.text = product.description ?? '';

        // ═══════════════════════════════════════════════════════════════════════
        // تحميل الأسعار: الدولار هو الأساس، والليرة تُحسب من سعر الصرف الحالي
        // ═══════════════════════════════════════════════════════════════════════
        if (product.purchasePriceUsd != null && product.purchasePriceUsd! > 0) {
          // حساب سعر الليرة من الدولار × سعر الصرف الحالي
          _costPriceUsdController.text =
              product.purchasePriceUsd!.toStringAsFixed(2);
          final sypPrice =
              product.purchasePriceUsd! * CurrencyService.currentRate;
          _costPriceController.text = sypPrice.toStringAsFixed(0);
        } else if (product.purchasePrice > 0) {
          _costPriceController.text = product.purchasePrice.toStringAsFixed(0);
        }

        if (product.salePriceUsd != null && product.salePriceUsd! > 0) {
          // حساب سعر البيع بالليرة من الدولار × سعر الصرف الحالي
          final sypSalePrice =
              product.salePriceUsd! * CurrencyService.currentRate;
          _salePriceController.text = sypSalePrice.toStringAsFixed(0);
        } else if (product.salePrice > 0) {
          _salePriceController.text = product.salePrice.toStringAsFixed(0);
        }

        _stockController.text = product.quantity.toString();
        _minStockController.text = product.minQuantity.toString();
        _selectedCategoryId = product.categoryId;

        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProduct = false);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EAN-13 Barcode Generation
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generate a valid EAN-13 barcode
  String _generateEAN13Barcode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = Random();

    // Prefix 200-299 is for internal use (store-specific)
    final prefix = '20${random.nextInt(10)}';

    // Get unique part from timestamp (last 9 digits)
    final uniquePart = timestamp.substring(timestamp.length - 9);

    // Combine to get 12 digits (without check digit)
    final barcodeWithoutCheck = '$prefix$uniquePart';

    // Calculate EAN-13 check digit
    final checkDigit = _calculateEAN13CheckDigit(barcodeWithoutCheck);

    return '$barcodeWithoutCheck$checkDigit';
  }

  /// Calculate the check digit for EAN-13
  int _calculateEAN13CheckDigit(String barcode12) {
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(barcode12[i]);
      // Odd positions (0, 2, 4...) multiply by 1
      // Even positions (1, 3, 5...) multiply by 3
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    return (10 - (sum % 10)) % 10;
  }

  /// Validate if barcode is valid EAN-13
  bool _isValidEAN13(String barcode) {
    if (barcode.length != 13) return false;
    if (!RegExp(r'^\d{13}$').hasMatch(barcode)) return false;

    final checkDigit = _calculateEAN13CheckDigit(barcode.substring(0, 12));
    return checkDigit == int.parse(barcode[12]);
  }

  void _onGenerateBarcodePressed() {
    final newBarcode = _generateEAN13Barcode();
    setState(() {
      _barcodeController.text = newBarcode;
    });

    ProSnackbar.success(context, 'تم توليد الباركود: $newBarcode');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Barcode Printing (Clean - No Name/Price)
  // ═══════════════════════════════════════════════════════════════════════════

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

      // 57mm roll format for thermal printers
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
                  // Barcode only - no product name or price
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.ean13(),
                    data: barcode,
                    width: 45 * PdfPageFormat.mm,
                    height: 20 * PdfPageFormat.mm,
                    drawText: true, // Shows barcode numbers only
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Warehouse Stock Management
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _addToWarehouseStock(
      String productId, int quantity, int minQuantity) async {
    if (_selectedWarehouseId == null) return;

    try {
      final db = ref.read(databaseProvider);
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      await db.insertWarehouseStock(WarehouseStockCompanion(
        id: drift.Value(id),
        warehouseId: drift.Value(_selectedWarehouseId!),
        productId: drift.Value(productId),
        quantity: drift.Value(quantity),
        minQuantity: drift.Value(minQuantity),
        syncStatus: const drift.Value('pending'),
      ));
    } catch (e) {
      // Ignore warehouse stock errors - main product was saved
      debugPrint('Error adding warehouse stock: $e');
    }
  }

  Future<void> _updateWarehouseStock(
      String productId, int quantity, int minQuantity) async {
    if (_selectedWarehouseId == null) return;

    try {
      final db = ref.read(databaseProvider);

      // Check if stock entry exists
      final existingStock = await db.getWarehouseStockByProductAndWarehouse(
        productId,
        _selectedWarehouseId!,
      );

      if (existingStock != null) {
        // Update existing stock
        await db.updateWarehouseStock(WarehouseStockCompanion(
          id: drift.Value(existingStock.id),
          quantity: drift.Value(quantity),
          minQuantity: drift.Value(minQuantity),
          updatedAt: drift.Value(DateTime.now()),
          syncStatus: const drift.Value('pending'),
        ));
      } else {
        // Create new stock entry
        await _addToWarehouseStock(productId, quantity, minQuantity);
      }
    } catch (e) {
      // Ignore warehouse stock errors - main product was saved
      debugPrint('Error updating warehouse stock: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Form Submission
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.tryParse(_stockController.text) ?? 0;
    final minQuantity = int.tryParse(_minStockController.text) ?? 0;

    // ═══════════════════════════════════════════════════════════════════════
    // التحقق من اختيار المستودع إذا كانت الكمية > 0
    // ═══════════════════════════════════════════════════════════════════════
    if (quantity > 0 && _selectedWarehouseId == null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('تنبيه', style: TextStyle(color: Colors.orange)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'لم يتم اختيار مستودع!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'أدخلت كمية مخزون لكن لم تختر مستودعاً. الكمية لن تُضاف لأي مستودع.',
              ),
              SizedBox(height: 8),
              Text(
                'هل تريد المتابعة بدون إضافة المخزون لمستودع؟',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('العودة لاختيار مستودع'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('متابعة بدون مستودع'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final productRepo = ref.read(productRepositoryProvider);

      final name = _nameController.text.trim();
      final barcode = _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim();
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      final purchasePrice = double.tryParse(_costPriceController.text) ?? 0;
      final purchasePriceUsd = double.tryParse(_costPriceUsdController.text);
      final salePrice = double.tryParse(_salePriceController.text) ?? 0;

      if (isEditing && widget.productId != null) {
        // تعديل منتج موجود
        await productRepo.updateProduct(
          id: widget.productId!,
          name: name,
          barcode: barcode,
          description: description,
          purchasePrice: purchasePrice,
          purchasePriceUsd: purchasePriceUsd,
          salePrice: salePrice,
          quantity: quantity,
          minQuantity: minQuantity,
          categoryId: _selectedCategoryId,
        );

        // تحديث مخزون المستودع إذا تم اختيار مستودع
        if (_selectedWarehouseId != null) {
          await _updateWarehouseStock(widget.productId!, quantity, minQuantity);
        }
      } else {
        // إضافة منتج جديد
        final newProductId = await productRepo.createProduct(
          name: name,
          barcode: barcode,
          description: description,
          purchasePrice: purchasePrice,
          purchasePriceUsd: purchasePriceUsd,
          salePrice: salePrice,
          quantity: quantity,
          minQuantity: minQuantity,
          categoryId: _selectedCategoryId,
        );

        // إضافة المخزون للمستودع المختار
        if (_selectedWarehouseId != null) {
          await _addToWarehouseStock(newProductId, quantity, minQuantity);
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ProSnackbar.saved(context);
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.showError(context, e);
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
      appBar: _buildAppBar(),
      body: _isLoadingProduct
          ? ProLoadingState.withMessage(message: 'جاري تحميل بيانات المنتج...')
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return ProAppBar.close(
      title: isEditing ? 'تعديل المنتج' : 'إضافة منتج',
      onClose: () => Navigator.of(context).pop(),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _saveProduct,
          child: _isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Text(
                  'حفظ',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        SizedBox(width: AppSpacing.sm),
      ],
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال اسم المنتج';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildCategorySelector(),
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
              color: AppColors.primary.soft,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.primary.border),
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
                    if (value == null || value.trim().isEmpty) {
                      return 'مطلوب';
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
          const ProSectionTitle('المخزون'),
          SizedBox(height: AppSpacing.sm),
          // تنبيه مهم
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            margin: EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.info.soft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.info.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 18.sp),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'يجب اختيار مستودع لإضافة الكمية. بدون مستودع، المنتج لن يكون له مخزون.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // اختيار المستودع
          _buildWarehouseSelector(),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ProNumberField(
                  controller: _stockController,
                  label: 'الكمية الحالية',
                  hint: '0',
                  allowDecimal: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'مطلوب';
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
                  hint: '0',
                  allowDecimal: false,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════════
          // 4. معلومات إضافية
          // ═══════════════════════════════════════════════════════════════
          const ProSectionTitle('معلومات إضافية'),
          SizedBox(height: AppSpacing.sm),
          _buildBarcodeField(),
          SizedBox(height: AppSpacing.md),
          ProTextField(
            controller: _descriptionController,
            label: 'الوصف',
            hint: 'أدخل وصف المنتج (اختياري)',
            maxLines: 2,
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
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.soft,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          'خطأ في تحميل الفئات',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
        ),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.soft,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.warning.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 20.sp),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'لا توجد فئات. أضف فئات من صفحة التصنيفات.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: InputDecoration(
            labelText: 'الفئة',
            hintText: 'اختر فئة المنتج',
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: Icon(
              Icons.category_outlined,
              color: AppColors.textTertiary,
              size: AppIconSize.sm,
            ),
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
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'بدون فئة',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            ...categories.map((category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        category.name,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        );
      },
    );
  }

  Widget _buildWarehouseSelector() {
    final warehousesAsync = ref.watch(activeWarehousesStreamProvider);

    return warehousesAsync.when(
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
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.soft,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          'خطأ في تحميل المستودعات',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
        ),
      ),
      data: (warehouses) {
        if (warehouses.isEmpty) {
          return Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.soft,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.warning.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 20.sp),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'لا توجد مستودعات. أضف مستودعات من صفحة المستودعات.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // التحقق من أن المستودع المختار موجود في القائمة
        final validWarehouseId =
            warehouses.any((w) => w.id == _selectedWarehouseId)
                ? _selectedWarehouseId
                : null;

        return DropdownButtonFormField<String>(
          value: validWarehouseId,
          decoration: InputDecoration(
            labelText: 'المستودع',
            hintText: 'اختر المستودع',
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: Icon(
              Icons.warehouse_outlined,
              color: AppColors.textTertiary,
              size: AppIconSize.sm,
            ),
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
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: warehouses
              .map((warehouse) => DropdownMenuItem<String>(
                    value: warehouse.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: warehouse.isDefault
                                ? AppColors.warning
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            warehouse.name,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (warehouse.isDefault) ...[
                          SizedBox(width: AppSpacing.xs),
                          Container(
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
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedWarehouseId = value;
            });
          },
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        );
      },
    );
  }

  Widget _buildBarcodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الباركود',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
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
                    size: AppIconSize.sm,
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
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
            // Generate Button
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.primary.soft,
                border: Border.all(color: AppColors.primary.border),
              ),
              child: IconButton(
                onPressed: _onGenerateBarcodePressed,
                icon: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: AppIconSize.sm,
                ),
                tooltip: 'توليد باركود',
              ),
            ),
            // Print Button
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.secondary.soft,
                border: Border.all(color: AppColors.secondary.border),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.md),
                ),
              ),
              child: IconButton(
                onPressed: _isPrintingBarcode ? null : _printBarcodeOnly,
                icon: _isPrintingBarcode
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary,
                        ),
                      )
                    : Icon(
                        Icons.print_rounded,
                        color: AppColors.secondary,
                        size: AppIconSize.sm,
                      ),
                tooltip: 'طباعة الباركود',
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          'اضغط على ✨ لتوليد باركود EAN-13 تلقائياً',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
