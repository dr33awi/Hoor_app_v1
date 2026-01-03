// ═══════════════════════════════════════════════════════════════════════════
// Pro Header - Shared Header Widget
// Unified header component for all screens
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/design_tokens.dart';

/// Header موحد لجميع الشاشات
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Leading: Custom, Drawer Button, or Back Button
          if (leading != null)
            leading!
          else if (showDrawerButton)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted,
                ),
              ),
            )
          else if (showBackButton)
            IconButton(
              onPressed: onBack ?? () => context.pop(),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: AppIconSize.sm,
                color: AppColors.textSecondary,
              ),
            ),

          if (showBackButton || showDrawerButton || leading != null)
            SizedBox(width: AppSpacing.sm),

          // Icon Box (optional)
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: AppIconSize.md,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
          ],

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
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
        PopupMenuButton<String>(
          icon: Icon(Icons.sort_rounded, color: AppColors.textSecondary),
          onSelected: onSortChanged,
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
          Icon(Icons.check_rounded,
              size: AppIconSize.sm, color: AppColors.secondary),
        if (!isSelected) SizedBox(width: AppIconSize.sm),
        SizedBox(width: AppSpacing.sm),
        Text(label),
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
