// ═══════════════════════════════════════════════════════════════════════════
// Pro Search Bar - Shared Search Widget
// Unified search bar component for all screens
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/design_tokens.dart';

/// شريط بحث موحد
class ProSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final Widget? suffixIcon;
  final bool autofocus;
  final EdgeInsetsGeometry? margin;

  const ProSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'بحث...',
    this.onChanged,
    this.onClear,
    this.suffixIcon,
    this.autofocus = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textTertiary,
            ),
            suffixIcon: _buildSuffixIcon(),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (controller.text.isNotEmpty) {
      return IconButton(
        onPressed: () {
          controller.clear();
          onClear?.call();
          onChanged?.call('');
        },
        icon: Icon(
          Icons.close_rounded,
          color: AppColors.textTertiary,
          size: AppIconSize.sm,
        ),
      );
    }
    return suffixIcon;
  }
}

/// شريط بحث مع فلتر
class ProSearchBarWithFilter extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;
  final EdgeInsetsGeometry? margin;

  const ProSearchBarWithFilter({
    super.key,
    required this.controller,
    this.hintText = 'بحث...',
    this.onChanged,
    required this.onFilterTap,
    this.hasActiveFilters = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: ProSearchBar(
              controller: controller,
              hintText: hintText,
              onChanged: onChanged,
              margin: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // Filter Button
          Container(
            height: 48.h,
            width: 48.h,
            decoration: BoxDecoration(
              color: hasActiveFilters
                  ? AppColors.primary.soft
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: hasActiveFilters ? AppColors.primary : AppColors.border,
              ),
            ),
            child: IconButton(
              onPressed: onFilterTap,
              icon: Badge(
                isLabelVisible: hasActiveFilters,
                smallSize: 8,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.tune_rounded,
                  color: hasActiveFilters
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط بحث مع اختيار التاريخ
class ProSearchBarWithDateRange extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final DateTimeRange? dateRange;
  final VoidCallback onDateRangeTap;
  final EdgeInsetsGeometry? margin;

  const ProSearchBarWithDateRange({
    super.key,
    required this.controller,
    this.hintText = 'بحث...',
    this.onChanged,
    this.dateRange,
    required this.onDateRangeTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: ProSearchBar(
              controller: controller,
              hintText: hintText,
              onChanged: onChanged,
              margin: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // Date Range Button
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: dateRange != null
                  ? AppColors.primary.soft
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: dateRange != null ? AppColors.primary : AppColors.border,
              ),
            ),
            child: TextButton.icon(
              onPressed: onDateRangeTap,
              icon: Icon(
                Icons.date_range_rounded,
                color: dateRange != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: AppIconSize.sm,
              ),
              label: Text(
                dateRange != null ? 'تصفية' : 'التاريخ',
                style: AppTypography.labelMedium.copyWith(
                  color: dateRange != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
