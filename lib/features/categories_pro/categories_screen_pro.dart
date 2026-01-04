// ═══════════════════════════════════════════════════════════════════════════
// Categories Screen Pro - Professional Design System
// Category Management with Modern UI
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/export/export_button.dart';
import '../../core/services/export/export_services.dart';
import '../../data/database/app_database.dart';

class CategoriesScreenPro extends ConsumerStatefulWidget {
  const CategoriesScreenPro({super.key});

  @override
  ConsumerState<CategoriesScreenPro> createState() =>
      _CategoriesScreenProState();
}

class _CategoriesScreenProState extends ConsumerState<CategoriesScreenPro> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isExporting = false;
  bool _isReorderMode = false;

  // أيقونات التصنيفات المتاحة
  static const List<IconData> _availableIcons = [
    Icons.category_rounded,
    Icons.shopping_bag_rounded,
    Icons.fastfood_rounded,
    Icons.local_drink_rounded,
    Icons.local_cafe_rounded,
    Icons.restaurant_rounded,
    Icons.icecream_rounded,
    Icons.cake_rounded,
    Icons.spa_rounded,
    Icons.cleaning_services_rounded,
    Icons.home_rounded,
    Icons.devices_rounded,
    Icons.phone_android_rounded,
    Icons.computer_rounded,
    Icons.watch_rounded,
    Icons.checkroom_rounded,
    Icons.sports_soccer_rounded,
    Icons.child_care_rounded,
    Icons.pets_rounded,
    Icons.local_florist_rounded,
  ];

  // ألوان التصنيفات المتاحة
  static const List<Color> _availableColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFF44336), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF3F51B5), // Indigo
    Color(0xFF009688), // Teal
    Color(0xFFFFEB3B), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final productsAsync = ref.watch(activeProductsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            categoriesAsync.when(
              loading: () => ProHeader(
                title: 'التصنيفات',
                subtitle: '0 تصنيف',
                onBack: () => context.go('/'),
              ),
              error: (_, __) => ProHeader(
                title: 'التصنيفات',
                subtitle: '0 تصنيف',
                onBack: () => context.go('/'),
              ),
              data: (categories) => ProHeader(
                title: _isReorderMode ? 'إعادة الترتيب' : 'التصنيفات',
                subtitle: _isReorderMode 
                    ? 'اسحب لإعادة ترتيب التصنيفات' 
                    : '${categories.length} تصنيف',
                onBack: _isReorderMode 
                    ? () => setState(() => _isReorderMode = false)
                    : () => context.go('/'),
                actions: [
                  if (!_isReorderMode) ...[
                    IconButton(
                      onPressed: () => setState(() => _isReorderMode = true),
                      icon: Icon(Icons.swap_vert_rounded, color: AppColors.textSecondary),
                      tooltip: 'إعادة الترتيب',
                    ),
                    ExportMenuButton(
                      onExport: (type) => _handleExport(type, categories),
                      isLoading: _isExporting,
                      icon: Icons.more_vert,
                      tooltip: 'تصدير ومشاركة',
                      enabledOptions: const {
                        ExportType.excel,
                        ExportType.pdf,
                        ExportType.sharePdf,
                        ExportType.shareExcel,
                      },
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () => setState(() => _isReorderMode = false),
                      child: const Text('تم'),
                    ),
                  ],
                ],
              ),
            ),
            // Search Bar
            if (!_isReorderMode)
              ProSearchBar(
                controller: _searchController,
                hintText: 'البحث في التصنيفات...',
                onChanged: (value) => setState(() => _searchQuery = value),
                onClear: () => setState(() {}),
              ),
            // Categories List
            Expanded(
              child: categoriesAsync.when(
                loading: () => ProLoadingState.list(),
                error: (error, _) =>
                    ProEmptyState.error(error: error.toString()),
                data: (categories) {
                  final products = productsAsync.asData?.value ?? [];
                  return _buildCategoriesList(categories, products);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isReorderMode ? null : FloatingActionButton.extended(
        onPressed: () => _showCategoryForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'فئة جديدة',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoriesList(List<Category> categories, List<Product> products) {
    var filtered = categories.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              _searchQuery.isEmpty ? 'لا توجد فئات' : 'لا توجد نتائج',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              _searchQuery.isEmpty
                  ? 'أضف فئة جديدة لتنظيم منتجاتك'
                  : 'جرب البحث بكلمات أخرى',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    // حساب عدد المنتجات لكل تصنيف
    Map<String, int> productCounts = {};
    for (final category in filtered) {
      productCounts[category.id] = products.where((p) => p.categoryId == category.id).length;
    }

    if (_isReorderMode) {
      return ReorderableListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: filtered.length,
        onReorder: (oldIndex, newIndex) => _handleReorder(filtered, oldIndex, newIndex),
        itemBuilder: (context, index) {
          final category = filtered[index];
          final count = productCounts[category.id] ?? 0;
          return _CategoryCard(
            key: ValueKey(category.id),
            category: category,
            productCount: count,
            isReorderMode: true,
            onEdit: () {},
            onDelete: () {},
          );
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final category = filtered[index];
        final count = productCounts[category.id] ?? 0;
        return _CategoryCard(
          category: category,
          productCount: count,
          isReorderMode: false,
          onEdit: () => _showCategoryForm(category: category),
          onDelete: () => _confirmDelete(category),
        );
      },
    );
  }

  Future<void> _handleReorder(List<Category> categories, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    setState(() {
      final item = categories.removeAt(oldIndex);
      categories.insert(newIndex, item);
    });
    
    // ملاحظة: إعادة الترتيب مرئية فقط أثناء الجلسة الحالية
    // يمكن إضافة حقل sortOrder للجدول لحفظ الترتيب بشكل دائم
    if (mounted) {
      ProSnackbar.success(context, 'تم إعادة الترتيب');
    }
  }

  Future<void> _handleExport(ExportType type, List<Category> categories) async {
    if (categories.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد تصنيفات للتصدير');
      return;
    }

    setState(() => _isExporting = true);
    final fileName = 'التصنيفات_${DateFormat('yyyyMMdd').format(DateTime.now())}';

    try {
      switch (type) {
        case ExportType.excel:
          await _exportCategoriesToExcel(categories, fileName);
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.pdf:
          await _exportCategoriesToPdf(categories, fileName);
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.sharePdf:
          await _shareCategoriesPdf(categories, fileName);
          break;
        case ExportType.shareExcel:
          await _shareCategoriesExcel(categories, fileName);
          break;
      }
    } catch (e) {
      if (mounted) ProSnackbar.error(context, 'حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportCategoriesToExcel(List<Category> categories, String fileName) async {
    await ExcelExportService.exportCategories(
      categories: categories,
      fileName: fileName,
    );
  }

  Future<void> _exportCategoriesToPdf(List<Category> categories, String fileName) async {
    final pdfBytes = await PdfExportService.generateCategoriesList(categories: categories);
    await PdfExportService.savePdfFile(pdfBytes, fileName);
  }

  Future<void> _shareCategoriesPdf(List<Category> categories, String fileName) async {
    final pdfBytes = await PdfExportService.generateCategoriesList(categories: categories);
    await PdfExportService.sharePdfBytes(pdfBytes, fileName: fileName, subject: 'قائمة التصنيفات');
  }

  Future<void> _shareCategoriesExcel(List<Category> categories, String fileName) async {
    final filePath = await ExcelExportService.exportCategories(
      categories: categories,
      fileName: fileName,
    );
    await ExcelExportService.shareFile(filePath, subject: 'قائمة التصنيفات');
  }

  void _showCategoryForm({Category? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController =
        TextEditingController(text: category?.description ?? '');
    final isEditing = category != null;

    showProBottomSheet(
      context: context,
      title: isEditing ? 'تعديل الفئة' : 'فئة جديدة',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProTextField(
            controller: nameController,
            label: 'اسم الفئة',
            prefixIcon: Icons.category_rounded,
          ),
          SizedBox(height: AppSpacing.md),
          ProTextField(
            controller: descriptionController,
            label: 'الوصف (اختياري)',
            prefixIcon: Icons.description_rounded,
            maxLines: 3,
          ),
          SizedBox(height: AppSpacing.lg),
          ProButton(
            label: isEditing ? 'حفظ التغييرات' : 'إضافة الفئة',
            fullWidth: true,
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ProSnackbar.showError(context, 'أدخل اسم الفئة');
                return;
              }

              try {
                final categoryRepo = ref.read(categoryRepositoryProvider);
                if (isEditing) {
                  await categoryRepo.updateCategory(
                    id: category.id,
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  );
                } else {
                  await categoryRepo.createCategory(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  if (context.mounted) {
                    ProSnackbar.success(
                      context,
                      isEditing ? 'تم تحديث الفئة' : 'تم إضافة الفئة',
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ProSnackbar.error(context, 'خطأ: $e');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Category category) async {
    final confirm = await showProDeleteDialog(
      context: context,
      itemName: 'الفئة "${category.name}"',
    );

    if (confirm == true && mounted) {
      try {
        final categoryRepo = ref.read(categoryRepositoryProvider);
        await categoryRepo.deleteCategory(category.id);
        if (mounted) {
          ProSnackbar.deleted(context, 'الفئة');
        }
      } catch (e) {
        if (mounted) {
          ProSnackbar.error(context, 'خطأ: $e');
        }
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Category Card
// ═══════════════════════════════════════════════════════════════════════════

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int productCount;
  final bool isReorderMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    super.key,
    required this.category,
    required this.productCount,
    required this.isReorderMode,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: isReorderMode ? null : onEdit,
      child: Row(
        children: [
          if (isReorderMode)
            Padding(
              padding: EdgeInsets.only(left: AppSpacing.sm),
              child: Icon(Icons.drag_handle, color: AppColors.textTertiary),
            ),
          ProIconBox.category(),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: AppTypography.titleSmall,
                ),
                Row(
                  children: [
                    if (category.description != null &&
                        category.description!.isNotEmpty)
                      Expanded(
                        child: Text(
                          category.description!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Container(
                      margin: EdgeInsets.only(right: AppSpacing.xs),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: productCount > 0 
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.textTertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                      ),
                      child: Text(
                        '$productCount منتج',
                        style: AppTypography.labelSmall.copyWith(
                          color: productCount > 0 
                              ? AppColors.primary 
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isReorderMode)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.textTertiary),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('تعديل'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
