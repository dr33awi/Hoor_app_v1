// ═══════════════════════════════════════════════════════════════════════════
// Pro Section Title - Enterprise Section Headers
// Professional section dividers for accounting interfaces
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/design_tokens.dart';

/// نوع فاصل القسم
enum SectionDividerStyle {
  /// فاصل بسيط - خط رفيع
  simple,

  /// فاصل مع خلفية
  filled,

  /// فاصل مميز - للأقسام المهمة
  prominent,
}

/// عنوان قسم موحد - تصميم Enterprise
class ProSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final SectionDividerStyle style;

  const ProSectionTitle(
    this.title, {
    super.key,
    this.icon,
    this.trailing,
    this.padding,
    this.style = SectionDividerStyle.simple,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (style) {
      case SectionDividerStyle.simple:
        return _buildSimple();
      case SectionDividerStyle.filled:
        return _buildFilled();
      case SectionDividerStyle.prominent:
        return _buildProminent();
    }
  }

  Widget _buildSimple() {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(width: AppSpacing.xs),
        ],
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }

  Widget _buildFilled() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  Widget _buildProminent() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border(
          right: BorderSide(
            color: AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// عنوان قسم مع خط فاصل - تصميم Enterprise
class ProSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? action;
  final bool showDivider;

  const ProSectionHeader(
    this.title, {
    super.key,
    this.icon,
    this.action,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Icon(
                  icon,
                  size: 14.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (action != null) action!,
          ],
        ),
        if (showDivider) ...[
          SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: AppColors.border),
        ],
      ],
    );
  }
}

/// فاصل للنماذج المالية - مثل فواصل كشف الحساب
class ProLedgerDivider extends StatelessWidget {
  final String? label;
  final bool isTotal;

  const ProLedgerDivider({
    super.key,
    this.label,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Container(
        height: isTotal ? 2 : 1,
        margin: EdgeInsets.symmetric(vertical: AppSpacing.xs.h),
        color: isTotal ? AppColors.textSecondary : AppColors.border,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs.h),
      child: Row(
        children: [
          Container(
            height: 1,
            width: 20.w,
            color: AppColors.border,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
            child: Text(
              label!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}
