import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/daos/categories_dao.dart';
import '../../../../core/database/daos/inventory_dao.dart';
import '../../../../core/database/database.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/products_provider.dart';

/// شاشة إضافة/تعديل منتج
class ProductFormScreen extends ConsumerStatefulWidget {
  final int? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCategoryId;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isSaving = false;
  List<Category> _categories = [];

  bool get isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _salePriceController.dispose();
    _costPriceController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // تحميل الفئات
      final categoryDao = GetIt.I<CategoriesDao>();
      _categories = await categoryDao.getAllCategories();
      _categories = _categories.where((c) => c.isActive).toList();

      // تحميل بيانات المنتج إذا كان تعديل
      if (widget.productId != null) {
        final productDao = GetIt.I<ProductsDao>();
        final product = await productDao.getProductById(widget.productId!);

        if (product != null) {
          _nameController.text = product.name;
          _barcodeController.text = product.barcode ?? '';
          _salePriceController.text = product.salePrice.toString();
          _costPriceController.text = product.costPrice.toString();
          _minStockController.text = product.lowStockAlert.toString();
          _descriptionController.text = product.description ?? '';
          _selectedCategoryId = product.categoryId;
          _isActive = product.isActive;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل البيانات: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل المنتج' : 'منتج جديد'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteProduct,
              color: AppColors.error,
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingView()
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // اسم المنتج
                  AppTextField(
                    controller: _nameController,
                    label: 'اسم المنتج *',
                    hint: 'أدخل اسم المنتج',
                    prefixIcon: Icons.inventory_2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'اسم المنتج مطلوب';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // الباركود
                  AppTextField(
                    controller: _barcodeController,
                    label: 'الباركود',
                    hint: 'أدخل الباركود أو امسحه',
                    prefixIcon: Icons.qr_code,
                    suffixIcon: Icons.qr_code_scanner,
                    onSuffixTap: _scanBarcode,
                  ),

                  SizedBox(height: 16.h),

                  // الفئة
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'الفئة',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('بدون فئة'),
                      ),
                      ..._categories.map((c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.name),
                          )),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedCategoryId = value),
                  ),

                  SizedBox(height: 24.h),

                  // الأسعار
                  Text('الأسعار',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _salePriceController,
                          label: 'سعر البيع *',
                          hint: '0.00',
                          prefixIcon: Icons.sell,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'قيمة غير صالحة';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AppTextField(
                          controller: _costPriceController,
                          label: 'سعر التكلفة *',
                          hint: '0.00',
                          prefixIcon: Icons.price_check,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'قيمة غير صالحة';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  // حساب الربح
                  if (_salePriceController.text.isNotEmpty &&
                      _costPriceController.text.isNotEmpty)
                    Builder(builder: (context) {
                      final salePrice =
                          double.tryParse(_salePriceController.text) ?? 0;
                      final costPrice =
                          double.tryParse(_costPriceController.text) ?? 0;
                      final profit = salePrice - costPrice;
                      final profitPercent =
                          costPrice > 0 ? (profit / costPrice) * 100 : 0;

                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: profit >= 0
                                ? AppColors.successLight
                                : AppColors.errorLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text('الربح',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  Text(
                                    '${profit.toStringAsFixed(2)} ر.س',
                                    style: TextStyle(
                                      color: profit >= 0
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('نسبة الربح',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  Text(
                                    '${profitPercent.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: profit >= 0
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  SizedBox(height: 24.h),

                  // المخزون
                  Text('المخزون',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 12.h),

                  AppTextField(
                    controller: _minStockController,
                    label: 'الحد الأدنى للمخزون',
                    hint: '0',
                    prefixIcon: Icons.warning_amber,
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 24.h),

                  // الوصف
                  AppTextField(
                    controller: _descriptionController,
                    label: 'الوصف',
                    hint: 'أدخل وصف المنتج (اختياري)',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                  ),

                  SizedBox(height: 24.h),

                  // الحالة
                  SwitchListTile(
                    title: const Text('المنتج نشط'),
                    subtitle: const Text('المنتج سيظهر في نقطة البيع'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),

                  SizedBox(height: 32.h),

                  // أزرار الإجراءات
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          text: isEditing ? 'حفظ التعديلات' : 'إضافة المنتج',
                          onPressed: _saveProduct,
                          isLoading: _isSaving,
                          icon: Icons.save,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
    );
  }

  void _scanBarcode() {
    // TODO: فتح ماسح الباركود
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final productDao = GetIt.I<ProductsDao>();

      final salePrice = double.parse(_salePriceController.text);
      final costPrice = double.parse(_costPriceController.text);
      final lowStockAlert = int.tryParse(_minStockController.text) ?? 10;

      if (isEditing) {
        // تحديث المنتج
        await productDao.updateProductPartial(
          widget.productId!,
          ProductsCompanion(
            name: Value(_nameController.text),
            barcode: Value(_barcodeController.text.isNotEmpty
                ? _barcodeController.text
                : null),
            categoryId: Value(_selectedCategoryId),
            salePrice: Value(salePrice),
            costPrice: Value(costPrice),
            lowStockAlert: Value(lowStockAlert),
            description: Value(_descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null),
            isActive: Value(_isActive),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } else {
        // إضافة منتج جديد
        final productId =
            await productDao.insertProduct(ProductsCompanion.insert(
          name: _nameController.text,
          barcode: _barcodeController.text.isNotEmpty
              ? Value(_barcodeController.text)
              : const Value.absent(),
          categoryId: Value(_selectedCategoryId),
          salePrice: salePrice,
          costPrice: Value(costPrice),
          lowStockAlert: Value(lowStockAlert),
          description: _descriptionController.text.isNotEmpty
              ? Value(_descriptionController.text)
              : const Value.absent(),
          isActive: Value(_isActive),
        ));

        // إضافة سجل مخزون أولي - استخدام المستودع الافتراضي
        final inventoryDao = GetIt.I<InventoryDao>();
        final defaultWarehouse = await inventoryDao.getDefaultWarehouse();
        if (defaultWarehouse != null) {
          await inventoryDao.upsertInventory(productId, defaultWarehouse.id, 0);
        }
      }

      // تحديث قائمة المنتجات
      ref.read(productsProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'تم تحديث المنتج' : 'تم إضافة المنتج'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حفظ المنتج: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: const Text(
            'هل تريد حذف هذا المنتج؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(productsProvider.notifier)
            .deleteProduct(widget.productId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف المنتج')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في حذف المنتج: $e')),
          );
        }
      }
    }
  }
}
