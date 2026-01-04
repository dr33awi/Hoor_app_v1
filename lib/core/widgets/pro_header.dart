// ═══════════════════════════════════════════════════════════════════════════
// Pro Header - Enterprise Header Widget
// Professional header for accounting interfaces
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../theme/design_tokens.dart';

/// Header موحد - تصميم Enterprise المحاسبي
class ProHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showBackButton;
  final bool showDrawerButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final IconData? icon;
  final Color? iconColor;
  final bool centerTitle;

  const ProHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showBackButton = true,
    this.showDrawerButton = false,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.icon,
    this.iconColor,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Leading: Custom, Drawer Button, or Back Button
          if (leading != null)
            leading!
          else if (showDrawerButton)
            Builder(
              builder: (context) => _buildIconButton(
                icon: Icons.menu_rounded,
                onTap: () => Scaffold.of(context).openDrawer(),
              ),
            )
          else if (showBackButton)
            _buildIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack ?? () => context.pop(),
            ),

          if (showBackButton || showDrawerButton || leading != null)
            SizedBox(width: AppSpacing.sm.w),

          // Icon Box (optional) - Enterprise style
          if (icon != null) ...[
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 16.sp,
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
          ],

          // Title & Subtitle
          Expanded(
            child: centerTitle
                ? Center(child: _buildTitleContent())
                : _buildTitleContent(),
          ),

          // Actions
          if (actions != null) ...[
            SizedBox(width: AppSpacing.xs.w),
            ...actions!,
          ],
        ],
      ),
    );
  }

  Widget _buildTitleContent() {
    return Column(
      crossAxisAlignment:
          centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ENTERPRISE FACTORY CONSTRUCTORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Header للصفحة الرئيسية (بدون border سفلي)
  factory ProHeader.home({
    required String title,
    String? subtitle,
    required VoidCallback onMenuTap,
    List<Widget>? actions,
  }) {
    return _ProHeaderHome(
      title: title,
      subtitle: subtitle,
      onMenuTap: onMenuTap,
      actions: actions,
    );
  }

  /// Header للتفاصيل مع إجراءات
  factory ProHeader.detail({
    required String title,
    String? subtitle,
    VoidCallback? onBack,
    List<Widget>? actions,
  }) {
    return ProHeader(
      title: title,
      subtitle: subtitle,
      onBack: onBack,
      showBackButton: true,
      actions: actions,
    );
  }

  /// Header للنماذج
  factory ProHeader.form({
    required String title,
    VoidCallback? onClose,
    VoidCallback? onSave,
    bool canSave = true,
  }) {
    return _ProHeaderForm(
      title: title,
      onClose: onClose,
      onSave: onSave,
      canSave: canSave,
    );
  }
}

/// Header خاص بالصفحة الرئيسية
class _ProHeaderHome extends ProHeader {
  final VoidCallback onMenuTap;

  const _ProHeaderHome({
    required super.title,
    super.subtitle,
    required this.onMenuTap,
    super.actions,
  }) : super(showBackButton: false, showDrawerButton: false);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding.w,
        vertical: AppSpacing.sm.h,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          // Menu Button
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.menu_rounded,
                size: 20.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

/// Header خاص بالنماذج
class _ProHeaderForm extends ProHeader {
  final VoidCallback? onClose;
  final VoidCallback? onSave;
  final bool canSave;

  const _ProHeaderForm({
    required super.title,
    this.onClose,
    this.onSave,
    this.canSave = true,
  }) : super(showBackButton: false);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Close Button
          GestureDetector(
            onTap: onClose ?? () => context.pop(),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 18.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),

          // Title
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Save Button
          if (onSave != null)
            TextButton.icon(
              onPressed: canSave ? onSave : null,
              icon: Icon(Icons.check_rounded, size: 18.sp),
              label: const Text('حفظ'),
              style: TextButton.styleFrom(
                foregroundColor:
                    canSave ? AppColors.secondary : AppColors.textDisabled,
              ),
            ),
        ],
      ),
    );
  }
}

/// Header مع عداد
class ProHeaderWithCount extends StatelessWidget {
  final String title;
  final int count;
  final String countLabel;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? trailing;

  const ProHeaderWithCount({
    super.key,
    required this.title,
    required this.count,
    required this.countLabel,
    this.onBack,
    this.actions,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ProHeader(
      title: title,
      subtitle: '$count $countLabel',
      onBack: onBack,
      actions: [
        if (trailing != null) trailing!,
        if (actions != null) ...actions!,
      ],
    );
  }
}

/// Header مع قائمة الترتيب
class ProHeaderWithSort extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String currentSort;
  final List<SortOption> sortOptions;
  final ValueChanged<String> onSortChanged;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const ProHeaderWithSort({
    super.key,
    required this.title,
    this.subtitle,
    required this.currentSort,
    required this.sortOptions,
    required this.onSortChanged,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ProHeader(
      title: title,
      subtitle: subtitle,
      onBack: onBack,
      actions: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(Icons.sort_rounded,
                color: AppColors.textSecondary, size: 20.sp),
            onSelected: onSortChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            itemBuilder: (context) => sortOptions
                .map((option) => PopupMenuItem(
                      value: option.value,
                      child: _SortOptionItem(
                        label: option.label,
                        isSelected: currentSort == option.value,
                      ),
                    ))
                .toList(),
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
}

class _SortOptionItem extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _SortOptionItem({
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isSelected)
          Icon(Icons.check_rounded, size: 18.sp, color: AppColors.secondary),
        if (!isSelected) SizedBox(width: 18.sp),
        SizedBox(width: AppSpacing.sm.w),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// خيار الترتيب
class SortOption {
  final String value;
  final String label;

  const SortOption({required this.value, required this.label});
}
