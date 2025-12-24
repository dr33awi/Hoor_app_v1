import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hoor_manager/core/services/Barcode_print_service.dart';
import 'package:hoor_manager/core/services/barcode_service.dart';

import '../../../../core/constants/constants.dart';

import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/entities.dart';
import '../providers/product_providers.dart';
import '../widgets/widgets.dart';

/// شاشة إضافة/تعديل منتج
class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  bool get isEditing => productId != null;

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _barcodeController = TextEditingController();

  String? _selectedCategoryId;
  List<ProductVariant> _variants = [];
  bool _isLoading = false;
  bool _isActive = true;
  bool _isDataLoaded = false;
  VariantSortOption _currentSort = VariantSortOption.color;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadProduct();
    } else {
      _isDataLoaded = true;
    }
  }

  Future<void> _loadProduct() async {
    try {
      final product = await ref.read(productProvider(widget.productId!).future);
      if (product != null && mounted) {
        setState(() {
          _nameController.text = product.name;
          _descriptionController.text = product.description ?? '';
          _priceController.text = product.price.toString();
          _costController.text = product.cost.toString();
          _barcodeController.text = product.barcode ?? '';
          _selectedCategoryId = product.categoryId;
          _variants = List.from(product.variants);
          _isActive = product.isActive;
          _isDataLoaded = true;
        });
      } else {
        setState(() => _isDataLoaded = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDataLoaded = true);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  /// ترتيب المتغيرات حسب الخيار المحدد
  List<ProductVariant> get _sortedVariants {
    final sorted = List<ProductVariant>.from(_variants);
    switch (_currentSort) {
      case VariantSortOption.color:
        sorted.sort((a, b) => a.color.compareTo(b.color));
        break;
      case VariantSortOption.size:
        sorted.sort((a, b) => a.size.compareTo(b.size));
        break;
      case VariantSortOption.quantityAsc:
        sorted.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case VariantSortOption.quantityDesc:
        sorted.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    // إظهار مؤشر التحميل أثناء جلب البيانات
    if (!_isDataLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing
              ? AppStrings.editProduct
              : AppStrings.addProduct),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isEditing ? AppStrings.editProduct : AppStrings.addProduct),
        actions: [
          if (widget.isEditing)
            Switch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            // اسم المنتج
            AppTextField(
              controller: _nameController,
              label: AppStrings.productName,
              hint: 'أدخل اسم المنتج',
              prefixIcon: Icons.inventory_2_outlined,
              validator: Validators.required,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppSizes.md),

            // الوصف
            AppTextField(
              controller: _descriptionController,
              label: 'الوصف (اختياري)',
              hint: 'وصف المنتج',
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppSizes.md),

            // الفئة
            categoriesAsync.when(
              data: (categories) => _buildCategoryDropdown(categories),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('فشل تحميل الفئات'),
            ),

            const SizedBox(height: AppSizes.md),

            // السعر والتكلفة
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _priceController,
                    label: AppStrings.productPrice,
                    hint: '0',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: Validators.positiveNumber,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: AppTextField(
                    controller: _costController,
                    label: AppStrings.productCost,
                    hint: '0',
                    prefixIcon: Icons.money_off,
                    keyboardType: TextInputType.number,
                    validator: Validators.positiveNumber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // الباركود
            _buildBarcodeField(),

            const SizedBox(height: AppSizes.lg),

            // المتغيرات (الألوان والمقاسات)
            _buildVariantsSection(),

            const SizedBox(height: AppSizes.xl),

            // زر الحفظ
            AppButton(
              text: widget.isEditing ? AppStrings.save : AppStrings.addProduct,
              onPressed: _saveProduct,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<CategoryEntity> categories) {
    // التأكد من أن الفئة المحددة موجودة في القائمة
    final validCategoryId = categories.any((c) => c.id == _selectedCategoryId)
        ? _selectedCategoryId
        : null;

    return DropdownButtonFormField<String>(
      value: validCategoryId,
      decoration: InputDecoration(
        labelText: AppStrings.productCategory,
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategoryId = value),
      validator: (value) => value == null ? 'اختر الفئة' : null,
    );
  }

  /// حقل الباركود مع أزرار المسح والتوليد
  Widget _buildBarcodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.productBarcode,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSizes.xs),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  hintText: 'اختياري - امسح أو أدخل يدوياً',
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: _barcodeController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _barcodeController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            // زر مسح الباركود
            _buildIconButton(
              icon: Icons.qr_code_scanner,
              tooltip: 'مسح باركود',
              color: AppColors.primary,
              onTap: _scanBarcode,
            ),
            const SizedBox(width: AppSizes.xs),
            // زر توليد باركود
            _buildIconButton(
              icon: Icons.auto_awesome,
              tooltip: 'توليد باركود',
              color: AppColors.success,
              onTap: _generateBarcode,
            ),
            // زر طباعة الباركود (يظهر فقط عند وجود باركود)
            if (_barcodeController.text.isNotEmpty) ...[
              const SizedBox(width: AppSizes.xs),
              _buildIconButton(
                icon: Icons.print,
                tooltip: 'طباعة الباركود',
                color: AppColors.info,
                onTap: _printBarcode,
              ),
            ],
          ],
        ),
        // عرض معاينة الباركود إذا كان موجوداً
        if (_barcodeController.text.isNotEmpty) ...[
          const SizedBox(height: AppSizes.sm),
          _buildBarcodePreview(),
        ],
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  /// معاينة الباركود
  Widget _buildBarcodePreview() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'الباركود: ${_barcodeController.text}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ),
          _buildBarcodeValidationBadge(),
        ],
      ),
    );
  }

  /// شارة التحقق من صحة الباركود
  Widget _buildBarcodeValidationBadge() {
    final barcode = _barcodeController.text.trim();
    final isValid = _isValidBarcode(barcode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: isValid
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        isValid ? 'صالح' : 'مخصص',
        style: TextStyle(
          fontSize: 12,
          color: isValid ? AppColors.success : AppColors.warning,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// التحقق من صحة الباركود
  bool _isValidBarcode(String barcode) {
    if (barcode.length == 13 || barcode.length == 8) {
      return RegExp(r'^\d+$').hasMatch(barcode);
    }
    return false;
  }

  /// قسم المتغيرات المحسن
  Widget _buildVariantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // شريط الأدوات
        VariantsToolbar(
          onAddSingle: _addVariant,
          onAddBulk: _addBulkVariants,
          currentSort: _currentSort,
          onSortChanged: (sort) => setState(() => _currentSort = sort),
        ),

        const SizedBox(height: AppSizes.sm),

        // إحصائيات المتغيرات
        if (_variants.isNotEmpty) ...[
          VariantsStats(variants: _variants),
          const SizedBox(height: AppSizes.md),
        ],

        // قائمة المتغيرات أو الحالة الفارغة
        if (_variants.isEmpty)
          _buildEmptyVariantsState()
        else
          ..._sortedVariants.map((variant) => VariantCard(
                variant: variant,
                onEdit: () => _editVariant(variant),
                onDelete: () => _deleteVariant(variant),
                onCopy: () => _copyVariant(variant),
                onQuantityChanged: (newQty) =>
                    _updateVariantQuantity(variant, newQty),
              )),
      ],
    );
  }

  /// حالة عدم وجود متغيرات
  Widget _buildEmptyVariantsState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.palette_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'أضف ألوان ومقاسات المنتج',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              OutlinedButton.icon(
                onPressed: _addVariant,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة واحد'),
              ),
              ElevatedButton.icon(
                onPressed: _addBulkVariants,
                icon: const Icon(Icons.add_box, size: 18),
                label: const Text('إضافة متعددة'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// إضافة متغير واحد
  void _addVariant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => VariantFormSheet(
        existingVariants: _variants,
        onSave: (variant) {
          setState(() {
            _variants.add(variant);
          });
        },
      ),
    );
  }

  /// إضافة متغيرات متعددة
  void _addBulkVariants() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BulkVariantFormSheet(
        existingVariants: _variants,
        onSave: (newVariants) {
          setState(() {
            _variants.addAll(newVariants);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إضافة ${newVariants.length} متغير'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  /// تعديل متغير
  void _editVariant(ProductVariant variant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => VariantFormSheet(
        variant: variant,
        existingVariants: _variants,
        onSave: (updatedVariant) {
          setState(() {
            final index = _variants.indexWhere((v) => v.id == variant.id);
            if (index != -1) {
              _variants[index] = updatedVariant;
            }
          });
        },
      ),
    );
  }

  /// نسخ متغير
  void _copyVariant(ProductVariant variant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => VariantFormSheet(
        variant: variant,
        existingVariants: _variants,
        onSave: (newVariant) {
          setState(() {
            _variants.add(newVariant);
          });
        },
        isCopyMode: true,
      ),
    );
  }

  /// حذف متغير
  void _deleteVariant(ProductVariant variant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المتغير'),
        content: Text(
          'هل تريد حذف "${variant.color} - ${variant.size}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _variants.removeWhere((v) => v.id == variant.id);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  /// تحديث كمية متغير مباشرة
  void _updateVariantQuantity(ProductVariant variant, int newQuantity) {
    setState(() {
      final index = _variants.indexWhere((v) => v.id == variant.id);
      if (index != -1) {
        _variants[index] = ProductVariant(
          id: variant.id,
          color: variant.color,
          colorCode: variant.colorCode,
          size: variant.size,
          quantity: newQuantity,
        );
      }
    });
  }

  /// مسح الباركود باستخدام الكاميرا
  Future<void> _scanBarcode() async {
    final barcode = await BarcodeScannerService.scan(context);

    if (barcode != null && barcode.isNotEmpty && mounted) {
      try {
        final existingProduct =
            await ref.read(productByBarcodeProvider(barcode).future);

        if (mounted) {
          if (existingProduct != null &&
              existingProduct.id != widget.productId) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'هذا الباركود مستخدم للمنتج: ${existingProduct.name}',
                ),
                backgroundColor: AppColors.error,
                action: SnackBarAction(
                  label: 'عرض',
                  textColor: Colors.white,
                  onPressed: () {
                    context.push('/products/${existingProduct.id}');
                  },
                ),
              ),
            );
          } else {
            setState(() {
              _barcodeController.text = barcode;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم مسح الباركود: $barcode'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _barcodeController.text = barcode;
          });
        }
      }
    }
  }

  /// توليد باركود جديد
  void _generateBarcode() {
    final barcode = AppUtils.generateBarcode();
    setState(() {
      _barcodeController.text = barcode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم توليد الباركود: $barcode'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// طباعة الباركود
  void _printBarcode() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    final price = double.tryParse(_priceController.text);

    BarcodePrintService.previewBarcode(
      context: context,
      barcode: barcode,
      price: price,
    );
  }

  /// حفظ المنتج
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر الفئة')),
      );
      return;
    }

    if (_variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف لون ومقاس واحد على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // الحصول على اسم الفئة
      final categories = await ref.read(categoriesProvider.future);
      final category = categories.cast<CategoryEntity>().firstWhere(
            (c) => c.id == _selectedCategoryId,
            orElse: () => categories.first,
          );

      final product = ProductEntity(
        id: widget.productId ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        categoryName: category.name,
        price: double.tryParse(_priceController.text) ?? 0,
        cost: double.tryParse(_costController.text) ?? 0,
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        variants: _variants,
        isActive: _isActive,
        createdAt: DateTime.now(),
      );

      bool success;
      if (widget.isEditing) {
        success = await ref
            .read(productActionsProvider.notifier)
            .updateProduct(product);
      } else {
        success =
            await ref.read(productActionsProvider.notifier).addProduct(product);
      }

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  widget.isEditing ? 'تم تحديث المنتج' : 'تم إضافة المنتج'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ، حاول مرة أخرى'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
