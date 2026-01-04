// ═══════════════════════════════════════════════════════════════════════════
// Pro Card - Modern Shared Card Widget
// Unified card component for all screens - Modern Pro Design 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/design_tokens.dart';

/// بطاقة موحدة مع تصميم متناسق - التصميم الحديث
class ProCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        border: Border.all(
          color: borderColor ?? AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: boxShadow ?? AppShadows.xs,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
          child: card,
        ),
      );
    }

    return card;
  }

  /// بطاقة بسيطة بدون حدود
  factory ProCard.flat({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ProCard(
      padding: padding,
      margin: margin,
      color: color ?? AppColors.surface,
      borderColor: Colors.transparent,
      boxShadow: const [],
      onTap: onTap,
      child: child,
    );
  }

  /// بطاقة مرتفعة مع ظل أكبر
  factory ProCard.elevated({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return ProCard(
      padding: padding,
      margin: margin,
      borderColor: Colors.transparent,
      boxShadow: AppShadows.md,
      onTap: onTap,
      child: child,
    );
  }

  /// بطاقة ملونة مع خلفية لونية
  factory ProCard.colored({
    required Widget child,
    required Color color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return ProCard(
      padding: padding,
      margin: margin,
      color: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.2),
      boxShadow: const [],
      onTap: onTap,
      child: child,
    );
  }

  /// بطاقة قائمة مع divider
  factory ProCard.list({
    required List<Widget> children,
    EdgeInsetsGeometry? margin,
  }) {
    return ProCard(
      padding: EdgeInsets.zero,
      margin: margin,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            Padding(
              padding: EdgeInsets.all(AppSpacing.md.w),
              child: children[i],
            ),
            if (i < children.length - 1)
              Divider(
                  height: 1, color: AppColors.border.withValues(alpha: 0.5)),
          ],
        ],
      ),
    );
  }

  /// بطاقة Glass Morphism
  factory ProCard.glass({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return ProCard(
      padding: padding,
      margin: margin,
      color: AppColors.surface.withValues(alpha: 0.8),
      borderColor: Colors.white.withValues(alpha: 0.2),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
      onTap: onTap,
      child: child,
    );
  }
}

/// بطاقة عنصر قائمة - التصميم الحديث
class ProListTile extends StatelessWidget {
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const ProListTile({
    super.key,
    this.leadingIcon,
    this.leadingIconColor,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.sm.h,
              ),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: AppSpacing.md.w),
                  ] else if (leadingIcon != null) ...[
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm.w),
                      decoration: BoxDecoration(
                        color: (leadingIconColor ?? AppColors.secondary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        leadingIcon,
                        size: 20.sp,
                        color: leadingIconColor ?? AppColors.secondary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md.w),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            subtitle!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
      ],
    );
  }
}

/// بطاقة معلومات سريعة - التصميم الحديث
class ProInfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const ProInfoCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              if (trend != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: isPositiveTrend
                        ? AppColors.income.withValues(alpha: 0.1)
                        : AppColors.expense.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 12.sp,
                        color: isPositiveTrend
                            ? AppColors.income
                            : AppColors.expense,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        trend!,
                        style: AppTypography.labelSmall.copyWith(
                          color: isPositiveTrend
                              ? AppColors.income
                              : AppColors.expense,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
