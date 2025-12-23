// lib/features/products/screens/add_edit_product_screen.dart
// شاشة إضافة/تعديل منتج - بدون صور

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();

  String? _selectedCategory;
  late List<String> _colors;
  late List<int> _sizes;
  late Map<String, int> _inventory;
  bool _isLoading = false;
  bool _isCategoriesLoading = true;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _colors = [];
    _sizes = [];
    _inventory = {};

    if (isEditing) {
      _loadProductData();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;

    final provider = context.read<ProductProvider>();

    if (provider.categories.isEmpty) {
      await provider.loadCategories();
    }

    if (mounted) {
      setState(() {
        _isCategoriesLoading = false;
        _validateSelectedCategory(provider);
      });
    }
  }

  void _validateSelectedCategory(ProductProvider provider) {
    if (_selectedCategory != null) {
      final categoryNames = provider.categories.map((c) => c.name).toList();
      if (!categoryNames.contains(_selectedCategory)) {
        _selectedCategory = null;
      }
    }
  }

  void _loadProductData() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _brandController.text = product.brand;
    _priceController.text = product.price.toString();
    _costPriceController.text = product.costPrice.toString();
    _selectedCategory = product.category;
    _colors = product.colors.toSet().toList();
    _sizes = (product.sizes.toSet().toList())..sort();
    _inventory = Map.from(product.inventory);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل المنتج' : 'إضافة منتج'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteConfirmation,
              tooltip: 'حذف',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // المعلومات الأساسية
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // الألوان
              _buildColorsSection(),
              const SizedBox(height: 24),

              // المقاسات
              _buildSizesSection(),
              const SizedBox(height: 24),

              // المخزون
              if (_colors.isNotEmpty && _sizes.isNotEmpty)
                _buildInventorySection(),
              const SizedBox(height: 32),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.textOnPrimary,
                          ),
                        )
                      : Text(isEditing ? 'تحديث المنتج' : 'إضافة المنتج'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final uniqueCategories = provider.categories
            .map((c) => c.name)
            .toSet()
            .toList();

        final safeSelectedCategory =
            (_selectedCategory != null &&
                uniqueCategories.contains(_selectedCategory))
            ? _selectedCategory
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المعلومات الأساسية',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // اسم المنتج
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم المنتج *',
                prefixIcon: Icon(Icons.inventory),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم المنتج';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // الوصف
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'الوصف',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // الفئة
            _isCategoriesLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: safeSelectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'الفئة *',
                            prefixIcon: Icon(Icons.category),
                          ),
                          hint: const Text('اختر الفئة'),
                          items: uniqueCategories.isEmpty
                              ? null
                              : uniqueCategories.map((categoryName) {
                                  return DropdownMenuItem<String>(
                                    value: categoryName,
                                    child: Text(categoryName),
                                  );
                                }).toList(),
                          onChanged: uniqueCategories.isEmpty
                              ? null
                              : (value) {
                                  setState(() => _selectedCategory = value);
                                },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء اختيار الفئة';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showAddCategoryDialog,
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'إضافة فئة جديدة',
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),

            if (!_isCategoriesLoading && uniqueCategories.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'لا توجد فئات - اضغط + لإضافة فئة جديدة',
                  style: TextStyle(color: AppTheme.orange700, fontSize: 12),
                ),
              ),

            const SizedBox(height: 16),

            // العلامة التجارية
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'العلامة التجارية',
                prefixIcon: Icon(Icons.branding_watermark),
              ),
            ),
            const SizedBox(height: 16),

            // السعر وسعر التكلفة
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'سعر البيع *',
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: 'ر.س',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال السعر';
                      }
                      if (double.tryParse(value) == null) {
                        return 'سعر غير صالح';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _costPriceController,
                    decoration: const InputDecoration(
                      labelText: 'سعر التكلفة *',
                      prefixIcon: Icon(Icons.money_off),
                      suffixText: 'ر.س',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال التكلفة';
                      }
                      if (double.tryParse(value) == null) {
                        return 'سعر غير صالح';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    bool isAdding = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة فئة جديدة'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'اسم الفئة',
              hintText: 'مثال: رياضي، رسمي، كاجوال',
              prefixIcon: Icon(Icons.category),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            enabled: !isAdding,
          ),
          actions: [
            TextButton(
              onPressed: isAdding ? null : () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: isAdding
                  ? null
                  : () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('الرجاء إدخال اسم الفئة'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isAdding = true);

                      final provider = context.read<ProductProvider>();
                      final success = await provider.addCategory(name);

                      if (!mounted) return;

                      if (success) {
                        Navigator.pop(dialogContext);

                        setState(() {
                          _selectedCategory = name;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم إضافة فئة "$name" بنجاح'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      } else {
                        setDialogState(() => isAdding = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.error ?? 'فشل إضافة الفئة'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
              child: isAdding
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textOnPrimary,
                      ),
                    )
                  : const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الألوان',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _showAddColorDialog,
              icon: const Icon(Icons.add),
              label: const Text('إضافة'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors
              .map(
                (color) => Chip(
                  label: Text(color),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _colors.remove(color);
                      _inventory.removeWhere(
                        (key, _) => key.startsWith('$color-'),
                      );
                    });
                  },
                ),
              )
              .toList(),
        ),
        if (_colors.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'لم يتم إضافة ألوان',
              style: TextStyle(color: AppTheme.grey600),
            ),
          ),
      ],
    );
  }

  Widget _buildSizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المقاسات',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _showAddSizeDialog,
              icon: const Icon(Icons.add),
              label: const Text('إضافة'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _sizes
              .map(
                (size) => Chip(
                  label: Text('$size'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _sizes.remove(size);
                      _inventory.removeWhere(
                        (key, _) => key.endsWith('-$size'),
                      );
                    });
                  },
                ),
              )
              .toList(),
        ),
        if (_sizes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'لم يتم إضافة مقاسات',
              style: TextStyle(color: AppTheme.grey600),
            ),
          ),
      ],
    );
  }

  Widget _buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المخزون',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              border: TableBorder.all(color: AppTheme.grey300),
              children: [
                // العنوان
                TableRow(
                  decoration: BoxDecoration(color: AppTheme.grey200),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'اللون / المقاس',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ..._sizes.map(
                      (size) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '$size',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                // الصفوف
                ..._colors.map(
                  (color) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(color),
                      ),
                      ..._sizes.map((size) {
                        final key = '$color-$size';
                        return Padding(
                          padding: const EdgeInsets.all(4),
                          child: TextFormField(
                            initialValue: (_inventory[key] ?? 0).toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              _inventory[key] = int.tryParse(value) ?? 0;
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddColorDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة لون'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اسم اللون',
            hintText: 'مثال: أسود، أبيض، أزرق',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final colorName = controller.text.trim();
              if (colorName.isNotEmpty) {
                if (_colors.contains(colorName)) {
                  Navigator.pop(dialogContext);
                  _showError('اللون "$colorName" موجود بالفعل');
                  return;
                }
                setState(() {
                  _colors.add(colorName);
                });
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddSizeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة مقاس'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'المقاس',
            hintText: 'مثال: 38، 39، 40',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final size = int.tryParse(controller.text);
              if (size != null) {
                if (_sizes.contains(size)) {
                  Navigator.pop(dialogContext);
                  _showError('المقاس "$size" موجود بالفعل');
                  return;
                }
                setState(() {
                  _sizes.add(size);
                  _sizes.sort();
                });
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_colors.isEmpty) {
      _showError('الرجاء إضافة لون واحد على الأقل');
      return;
    }

    if (_sizes.isEmpty) {
      _showError('الرجاء إضافة مقاس واحد على الأقل');
      return;
    }

    setState(() => _isLoading = true);

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      brand: _brandController.text.trim(),
      price: double.parse(_priceController.text),
      costPrice: double.parse(_costPriceController.text),
      colors: _colors.toSet().toList(),
      sizes: _sizes.toSet().toList()..sort(),
      inventory: _inventory,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<ProductProvider>();
    bool success;

    if (isEditing) {
      success = await provider.updateProduct(product);
    } else {
      success = await provider.addProduct(product);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'تم تحديث المنتج' : 'تم إضافة المنتج'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      _showError(provider.error ?? 'حدث خطأ');
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: const Text('هل أنت متأكد من حذف هذا المنتج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final provider = context.read<ProductProvider>();
              final success = await provider.deleteProduct(widget.product!.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف المنتج'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }
}
