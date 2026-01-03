// ═══════════════════════════════════════════════════════════════════════════
// Categories Screen Pro - Professional Design System
// Category Management with Modern UI
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
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
                title: 'التصنيفات',
                subtitle: '${categories.length} تصنيف',
                onBack: () => context.go('/'),
              ),
            ),
            // Search Bar
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
                data: (categories) => _buildCategoriesList(categories),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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

  Widget _buildCategoriesList(List<Category> categories) {
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

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _CategoryCard(
          category: filtered[index],
          onEdit: () => _showCategoryForm(category: filtered[index]),
          onDelete: () => _confirmDelete(filtered[index]),
        );
      },
    );
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: onEdit,
      child: Row(
        children: [
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
                if (category.description != null &&
                    category.description!.isNotEmpty)
                  Text(
                    category.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
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
