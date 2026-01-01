// ═══════════════════════════════════════════════════════════════════════════
// Product Form Screen Pro
// Add/Edit Product Form with Professional Design
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/pro/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';

class ProductFormScreenPro extends ConsumerStatefulWidget {
  final String? productId;

  const ProductFormScreenPro({
    super.key,
    this.productId,
  });

  bool get isEditing => productId != null;

  @override
  ConsumerState<ProductFormScreenPro> createState() =>
      _ProductFormScreenProState();
}

class _ProductFormScreenProState extends ConsumerState<ProductFormScreenPro> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  String _selectedUnit = 'قطعة';
  bool _isActive = true;
  bool _isTaxable = true;
  bool _hasExpiry = false;
  bool _isLoading = false;
  bool _isSaving = false;
  Product? _existingProduct;

  final List<String> _units = [
    'قطعة',
    'كيلو',
    'متر',
    'لتر',
    'علبة',
    'كرتون',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadProductData();
    }
  }

  Future<void> _loadProductData() async {
    if (widget.productId == null) return;

    setState(() => _isLoading = true);
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final product = await productRepo.getProductById(widget.productId!);

      if (product != null && mounted) {
        setState(() {
          _existingProduct = product;
          _nameController.text = product.name;
          _skuController.text = product.sku ?? '';
          _barcodeController.text = product.barcode ?? '';
          _priceController.text = product.salePrice.toStringAsFixed(0);
          _costController.text = product.purchasePrice.toStringAsFixed(0);
          _stockController.text = product.quantity.toString();
          _minStockController.text = product.minQuantity.toString();
          _descriptionController.text = product.description ?? '';
          _selectedCategoryId = product.categoryId;
          _isActive = product.isActive;
          _isTaxable = product.taxRate != null && product.taxRate! > 0;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _generateBarcode() {
    // Generate EAN-13 compatible barcode
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

    final barcode = '$barcodeWithoutCheck$checkDigit';
    setState(() {
      _barcodeController.text = barcode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم توليد الباركود: $barcode'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
          ),
          title: Text(
            widget.isEditing ? 'تعديل منتج' : 'منتج جديد',
            style:
                AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.close_rounded,
            color: AppColors.textSecondary,
          ),
        ),
        title: Text(
          widget.isEditing ? 'تعديل منتج' : 'منتج جديد',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProduct,
            child: _isSaving
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'حفظ',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════════════════════════════
              // Image Section
              // ═══════════════════════════════════════════════════════════════
              _buildImagePicker(),
              SizedBox(height: AppSpacing.lg),

              // ═══════════════════════════════════════════════════════════════
              // Basic Info Section
              // ═══════════════════════════════════════════════════════════════
              _buildSectionTitle('المعلومات الأساسية'),
              SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _nameController,
                label: 'اسم المنتج',
                hint: 'أدخل اسم المنتج',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'اسم المنتج مطلوب' : null,
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _skuController,
                      label: 'رمز المنتج (SKU)',
                      hint: 'PRD-001',
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTextField(
                      controller: _barcodeController,
                      label: 'الباركود',
                      hint: 'امسح أو أدخل الباركود',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _generateBarcode,
                            icon: Icon(
                              Icons.autorenew_rounded,
                              color: AppColors.success,
                            ),
                            tooltip: 'توليد باركود تلقائي',
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: Open barcode scanner
                            },
                            icon: Icon(
                              Icons.qr_code_scanner_rounded,
                              color: AppColors.secondary,
                            ),
                            tooltip: 'مسح الباركود',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: categoriesAsync.when(
                      data: (categories) => _buildCategoryDropdown(categories),
                      loading: () => _buildLoadingDropdown('التصنيف'),
                      error: (_, __) => _buildErrorDropdown('التصنيف'),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildDropdown(
                      label: 'الوحدة',
                      value: _selectedUnit,
                      items: _units,
                      onChanged: (value) =>
                          setState(() => _selectedUnit = value!),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.xl),

              // ═══════════════════════════════════════════════════════════════
              // Pricing Section
              // ═══════════════════════════════════════════════════════════════
              _buildSectionTitle('التسعير'),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'سعر البيع',
                      hint: '0.00',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      prefixText: 'ر.س ',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'السعر مطلوب' : null,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTextField(
                      controller: _costController,
                      label: 'سعر التكلفة',
                      hint: '0.00',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      prefixText: 'ر.س ',
                    ),
                  ),
                ],
              ),
              if (_priceController.text.isNotEmpty &&
                  _costController.text.isNotEmpty)
                _buildProfitIndicator(),

              SizedBox(height: AppSpacing.xl),

              // ═══════════════════════════════════════════════════════════════
              // Inventory Section
              // ═══════════════════════════════════════════════════════════════
              _buildSectionTitle('المخزون'),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'الكمية الحالية',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTextField(
                      controller: _minStockController,
                      label: 'الحد الأدنى للتنبيه',
                      hint: '5',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.xl),

              // ═══════════════════════════════════════════════════════════════
              // Settings Section
              // ═══════════════════════════════════════════════════════════════
              _buildSectionTitle('الإعدادات'),
              SizedBox(height: AppSpacing.md),
              _buildSwitchTile(
                title: 'منتج نشط',
                subtitle: 'يظهر في المبيعات والتقارير',
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              _buildSwitchTile(
                title: 'خاضع للضريبة',
                subtitle: 'يتم احتساب ضريبة القيمة المضافة',
                value: _isTaxable,
                onChanged: (value) => setState(() => _isTaxable = value),
              ),
              _buildSwitchTile(
                title: 'له تاريخ صلاحية',
                subtitle: 'تتبع صلاحية المنتج',
                value: _hasExpiry,
                onChanged: (value) => setState(() => _hasExpiry = value),
              ),

              SizedBox(height: AppSpacing.xl),

              // ═══════════════════════════════════════════════════════════════
              // Description Section
              // ═══════════════════════════════════════════════════════════════
              _buildSectionTitle('الوصف (اختياري)'),
              SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _descriptionController,
                label: 'وصف المنتج',
                hint: 'أضف وصفاً تفصيلياً للمنتج...',
                maxLines: 4,
              ),

              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: Show image picker options
        },
        child: Container(
          width: 140.w,
          height: 140.w,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.border,
              width: 2,
              strokeAlign: BorderSide.strokeAlignCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'إضافة صورة',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          style: AppTypography.bodyMedium.copyWith(
            fontFamily:
                keyboardType == TextInputType.number ? 'JetBrains Mono' : null,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixText: prefixText,
            prefixStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'JetBrains Mono',
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التصنيف',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedCategoryId,
              isExpanded: true,
              hint: Text('اختر التصنيف',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textTertiary)),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('بدون تصنيف'),
                ),
                ...categories.map((cat) => DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    )),
              ],
              onChanged: (value) => setState(() => _selectedCategoryId = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.textSecondary)),
        SizedBox(height: AppSpacing.xs),
        Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
              child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      ],
    );
  }

  Widget _buildErrorDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.textSecondary)),
        SizedBox(height: AppSpacing.xs),
        Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.error),
          ),
          child: Center(
              child: Text('خطأ في التحميل',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.error))),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitIndicator() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final cost = double.tryParse(_costController.text) ?? 0;
    final profit = price - cost;
    final margin = price > 0 ? (profit / price * 100) : 0;

    return Container(
      margin: EdgeInsets.only(top: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: profit >= 0
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'هامش الربح',
            style: AppTypography.bodyMedium.copyWith(
              color: profit >= 0 ? AppColors.success : AppColors.error,
            ),
          ),
          Text(
            '${profit.toStringAsFixed(0)} ر.س (${margin.toStringAsFixed(1)}%)',
            style: AppTypography.titleSmall.copyWith(
              color: profit >= 0 ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w700,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (widget.isEditing)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _deleteProduct,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: const Text('حذف'),
                ),
              ),
            if (widget.isEditing) SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveProduct,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.isEditing ? 'حفظ التغييرات' : 'إضافة المنتج',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProduct() async {
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

    if (confirm != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final productRepo = ref.read(productRepositoryProvider);
      await productRepo.deleteProduct(widget.productId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('تم حذف المنتج بنجاح'),
              backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ في حذف المنتج: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final productRepo = ref.read(productRepositoryProvider);

      if (widget.isEditing && _existingProduct != null) {
        // Update existing product
        await productRepo.updateProduct(
          id: widget.productId!,
          name: _nameController.text.trim(),
          sku: _skuController.text.trim().isEmpty
              ? null
              : _skuController.text.trim(),
          barcode: _barcodeController.text.trim().isEmpty
              ? null
              : _barcodeController.text.trim(),
          categoryId: _selectedCategoryId,
          purchasePrice: double.tryParse(_costController.text) ?? 0,
          salePrice: double.tryParse(_priceController.text) ?? 0,
          quantity: int.tryParse(_stockController.text) ?? 0,
          minQuantity: int.tryParse(_minStockController.text) ?? 5,
          taxRate: _isTaxable ? 15.0 : null,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isActive: _isActive,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('تم تحديث المنتج بنجاح'),
                backgroundColor: AppColors.success),
          );
        }
      } else {
        // Create new product
        await productRepo.createProduct(
          name: _nameController.text.trim(),
          sku: _skuController.text.trim().isEmpty
              ? null
              : _skuController.text.trim(),
          barcode: _barcodeController.text.trim().isEmpty
              ? null
              : _barcodeController.text.trim(),
          categoryId: _selectedCategoryId,
          purchasePrice: double.tryParse(_costController.text) ?? 0,
          salePrice: double.tryParse(_priceController.text) ?? 0,
          quantity: int.tryParse(_stockController.text) ?? 0,
          minQuantity: int.tryParse(_minStockController.text) ?? 5,
          taxRate: _isTaxable ? 15.0 : null,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('تم إضافة المنتج بنجاح'),
                backgroundColor: AppColors.success),
          );
        }
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ في حفظ المنتج: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
