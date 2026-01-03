import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/categories_provider.dart';

/// شاشة الفئات
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفئات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('فئة جديدة'),
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: EdgeInsets.all(16.w),
            child: AppTextField(
              controller: _searchController,
              hint: 'البحث في الفئات...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                ref.read(categoriesProvider.notifier).setSearchQuery(value);
              },
            ),
          ),

          // القائمة
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredCategories.isEmpty
                    ? _EmptyWidget(
                        onAdd: () => _showCategoryDialog(context),
                      )
                    : ReorderableListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: state.filteredCategories.length,
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(categoriesProvider.notifier)
                              .reorderCategories(
                                oldIndex,
                                newIndex,
                              );
                        },
                        itemBuilder: (context, index) {
                          final category = state.filteredCategories[index];
                          return _CategoryCard(
                            key: ValueKey(category.id),
                            category: category,
                            onEdit: () => _showCategoryDialog(
                              context,
                              category: category,
                            ),
                            onDelete: () => _deleteCategory(category),
                            onToggleActive: () {
                              ref
                                  .read(categoriesProvider.notifier)
                                  .toggleActive(
                                    category.id,
                                  );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('حسب الاسم'),
              onTap: () {
                ref.read(categoriesProvider.notifier).setSortBy('name');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('حسب تاريخ الإنشاء'),
              onTap: () {
                ref.read(categoriesProvider.notifier).setSortBy('date');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('حسب عدد المنتجات'),
              onTap: () {
                ref.read(categoriesProvider.notifier).setSortBy('products');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drag_handle),
              title: const Text('ترتيب مخصص'),
              onTap: () {
                ref.read(categoriesProvider.notifier).setSortBy('custom');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryItem? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    String selectedColor = category?.color ?? '#4A90D9';
    String selectedIcon = category?.icon ?? 'category';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(category == null ? 'فئة جديدة' : 'تعديل الفئة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم الفئة
                AppTextField(
                  controller: nameController,
                  label: 'اسم الفئة',
                  hint: 'أدخل اسم الفئة',
                  prefixIcon: Icons.label,
                ),

                SizedBox(height: 16.h),

                // الوصف
                AppTextField(
                  controller: descriptionController,
                  label: 'الوصف',
                  hint: 'وصف الفئة (اختياري)',
                  prefixIcon: Icons.description,
                  maxLines: 2,
                ),

                SizedBox(height: 16.h),

                // اللون
                Text(
                  'اللون',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _categoryColors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color:
                              Color(int.parse(color.replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Color(int.parse(
                                            color.replaceFirst('#', '0xFF')))
                                        .withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 16.h),

                // الأيقونة
                Text(
                  'الأيقونة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _categoryIcons.map((iconData) {
                    final isSelected = selectedIcon == iconData.name;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = iconData.name),
                      child: Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(int.parse(
                                  selectedColor.replaceFirst('#', '0xFF')))
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isSelected
                                ? Color(int.parse(
                                    selectedColor.replaceFirst('#', '0xFF')))
                                : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          iconData.icon,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: 24.sp,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إدخال اسم الفئة')),
                  );
                  return;
                }

                if (category == null) {
                  ref.read(categoriesProvider.notifier).addCategory(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        color: selectedColor,
                        icon: selectedIcon,
                      );
                } else {
                  ref.read(categoriesProvider.notifier).updateCategory(
                        id: category.id,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        color: selectedColor,
                        icon: selectedIcon,
                      );
                }

                Navigator.pop(context);
              },
              child: Text(category == null ? 'إضافة' : 'حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(CategoryItem category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الفئة'),
        content: Text(
          category.productsCount > 0
              ? 'هذه الفئة تحتوي على ${category.productsCount} منتج. سيتم نقل المنتجات إلى فئة "بدون تصنيف".'
              : 'هل تريد حذف هذه الفئة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoriesProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

/// بطاقة الفئة
class _CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _CategoryCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            _getIconData(category.icon),
            color: color,
            size: 24.sp,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration:
                      category.isActive ? null : TextDecoration.lineThrough,
                  color: category.isActive ? null : AppColors.textSecondary,
                ),
              ),
            ),
            if (!category.isActive)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'معطل',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 10.sp,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          category.description ?? '${category.productsCount} منتج',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // عدد المنتجات
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${category.productsCount}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // قائمة الخيارات
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: onEdit,
                  child: const ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('تعديل'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  onTap: onToggleActive,
                  child: ListTile(
                    leading: Icon(
                      category.isActive
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    title: Text(category.isActive ? 'تعطيل' : 'تفعيل'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  onTap: onDelete,
                  child: ListTile(
                    leading: Icon(Icons.delete, color: AppColors.error),
                    title:
                        Text('حذف', style: TextStyle(color: AppColors.error)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            // مقبض السحب
            ReorderableDragStartListener(
              index: 0,
              child: Icon(
                Icons.drag_handle,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }

  IconData _getIconData(String iconName) {
    return _categoryIcons
        .firstWhere(
          (i) => i.name == iconName,
          orElse: () => _categoryIcons.first,
        )
        .icon;
  }
}

/// ويدجت فارغة
class _EmptyWidget extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyWidget({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد فئات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'أضف فئة جديدة لتنظيم منتجاتك',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          AppButton(
            text: 'إضافة فئة',
            onPressed: onAdd,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }
}

/// ألوان الفئات
const _categoryColors = [
  '#4A90D9', // أزرق
  '#50C878', // أخضر
  '#FF6B6B', // أحمر
  '#FFB347', // برتقالي
  '#9B59B6', // بنفسجي
  '#1ABC9C', // فيروزي
  '#E91E63', // وردي
  '#607D8B', // رمادي
  '#795548', // بني
  '#FF5722', // برتقالي داكن
];

/// أيقونات الفئات
class _CategoryIcon {
  final String name;
  final IconData icon;

  const _CategoryIcon(this.name, this.icon);
}

const _categoryIcons = [
  _CategoryIcon('category', Icons.category),
  _CategoryIcon('shopping_bag', Icons.shopping_bag),
  _CategoryIcon('devices', Icons.devices),
  _CategoryIcon('restaurant', Icons.restaurant),
  _CategoryIcon('local_cafe', Icons.local_cafe),
  _CategoryIcon('checkroom', Icons.checkroom),
  _CategoryIcon('sports_basketball', Icons.sports_basketball),
  _CategoryIcon('toys', Icons.toys),
  _CategoryIcon('book', Icons.book),
  _CategoryIcon('headphones', Icons.headphones),
  _CategoryIcon('watch', Icons.watch),
  _CategoryIcon('diamond', Icons.diamond),
  _CategoryIcon('home', Icons.home),
  _CategoryIcon('chair', Icons.chair),
  _CategoryIcon('cleaning_services', Icons.cleaning_services),
  _CategoryIcon('medical_services', Icons.medical_services),
  _CategoryIcon('pets', Icons.pets),
  _CategoryIcon('child_care', Icons.child_care),
  _CategoryIcon('build', Icons.build),
  _CategoryIcon('more_horiz', Icons.more_horiz),
];
