// lib/features/products/screens/add_edit_product_screen.dart
// شاشة إضافة/تعديل منتج - مُصحح

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  List<String> _colors = [];
  List<int> _sizes = [];
  Map<String, int> _inventory = {};
  File? _imageFile;
  bool _isLoading = false;
  bool _isCategoriesLoading = true;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (isEditing) {
      _loadProductData();
    }
  }

  Future<void> _loadCategories() async {
    final provider = context.read<ProductProvider>();

    // تحميل الفئات إذا لم تكن محملة
    if (provider.categories.isEmpty) {
      await provider.loadCategories();
    }

    if (mounted) {
      setState(() {
        _isCategoriesLoading = false;
        // التحقق من أن الفئة المحددة موجودة في القائمة
        _validateSelectedCategory(provider);
      });
    }
  }

  /// التحقق من صحة الفئة المحددة
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
    _colors = List.from(product.colors);
    _sizes = List.from(product.sizes);
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
              // الصورة
              _buildImageSection(),
              const SizedBox(height: 24),

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

  Widget _buildImageSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: AppTheme.grey200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.grey300),
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
              : widget.product?.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.product!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  ),
                )
              : _buildImagePlaceholder(),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 48, color: AppTheme.grey400),
        const SizedBox(height: 8),
        Text('إضافة صورة', style: TextStyle(color: AppTheme.grey600)),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        // إزالة الفئات المكررة وإنشاء قائمة فريدة
        final uniqueCategories = provider.categories
            .map((c) => c.name)
            .toSet()
            .toList();

        // التحقق من أن القيمة المحددة موجودة في القائمة
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

            // الفئة - مُصحح
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
                      // زر إضافة فئة جديدة
                      IconButton(
                        onPressed: _showAddCategoryDialog,
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'إضافة فئة جديدة',
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),

            // رسالة إذا لم توجد فئات
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

  /// ✅ دالة إضافة فئة جديدة - مُصححة
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

                        // ✅ تحديث الفئة المحددة بعد الإضافة
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
    // إزالة الألوان المكررة
    final uniqueColors = _colors.toSet().toList();
    if (uniqueColors.length != _colors.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _colors = uniqueColors);
      });
    }

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
          children: uniqueColors
              .map(
                (color) => Chip(
                  label: Text(color),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _colors.remove(color);
                      // حذف المخزون المرتبط
                      _inventory.removeWhere(
                        (key, _) => key.startsWith('$color-'),
                      );
                    });
                  },
                ),
              )
              .toList(),
        ),
        if (uniqueColors.isEmpty)
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
    // إزالة المقاسات المكررة
    final uniqueSizes = _sizes.toSet().toList()..sort();
    if (uniqueSizes.length != _sizes.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _sizes = uniqueSizes);
      });
    }

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
          children: uniqueSizes
              .map(
                (size) => Chip(
                  label: Text('$size'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _sizes.remove(size);
                      // حذف المخزون المرتبط
                      _inventory.removeWhere(
                        (key, _) => key.endsWith('-$size'),
                      );
                    });
                  },
                ),
              )
              .toList(),
        ),
        if (uniqueSizes.isEmpty)
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
    // استخدام القوائم الفريدة
    final uniqueColors = _colors.toSet().toList();
    final uniqueSizes = _sizes.toSet().toList()..sort();

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
                    ...uniqueSizes.map(
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
                ...uniqueColors.map(
                  (color) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(color),
                      ),
                      ...uniqueSizes.map((size) {
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
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
                // التحقق من عدم وجود اللون مسبقاً
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
                // التحقق من عدم وجود المقاس مسبقاً
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
      imageUrl: widget.product?.imageUrl,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<ProductProvider>();
    bool success;

    if (isEditing) {
      success = await provider.updateProduct(product, imageFile: _imageFile);
    } else {
      success = await provider.addProduct(product, imageFile: _imageFile);
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
