// ═══════════════════════════════════════════════════════════════════════════
// Pro Card - Enterprise Accounting Card Widget
// Professional card component for data-heavy interfaces
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/design_tokens.dart';

/// بطاقة موحدة - تصميم Enterprise المحاسبي
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
      padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding.w),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: 1,
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

  /// بطاقة بسيطة بدون حدود - للبيانات المتجاورة
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

  /// بطاقة مرتفعة - للعناصر المهمة
  factory ProCard.elevated({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return ProCard(
      padding: padding,
      margin: margin,
      borderColor: AppColors.border,
      boxShadow: AppShadows.sm,
      onTap: onTap,
      child: child,
    );
  }

  /// بطاقة ملونة - للتصنيفات والحالات
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
      color: color.withValues(alpha: 0.05),
      borderColor: color.withValues(alpha: 0.15),
      boxShadow: const [],
      onTap: onTap,
      child: child,
    );
  }

  /// بطاقة قائمة - لعرض البيانات المتعددة
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
              padding: EdgeInsets.all(AppSpacing.cardPadding.w),
              child: children[i],
            ),
            if (i < children.length - 1)
              Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NEW ENTERPRISE PATTERNS
  // ═══════════════════════════════════════════════════════════════════════════

  /// بطاقة القسم - للتجميعات المنطقية (Enterprise)
  factory ProCard.section({
    required String title,
    String? subtitle,
    required Widget child,
    EdgeInsetsGeometry? margin,
    List<Widget>? actions,
  }) {
    return ProCard(
      padding: EdgeInsets.zero,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPadding.w,
              vertical: AppSpacing.sm.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (actions != null) ...actions,
              ],
            ),
          ),
          // Section Body
          Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding.w),
            child: child,
          ),
        ],
      ),
    );
  }

  /// بطاقة البيانات - لعرض صفوف المعلومات (Enterprise)
  factory ProCard.data({
    required List<ProDataRow> rows,
    EdgeInsetsGeometry? margin,
    bool compact = false,
  }) {
    return ProCard(
      padding: EdgeInsets.zero,
      margin: margin,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _DataRowWidget(row: rows[i], compact: compact),
            if (i < rows.length - 1)
              Divider(
                  height: 1,
                  color: AppColors.border,
                  indent: AppSpacing.cardPadding.w,
                  endIndent: AppSpacing.cardPadding.w),
          ],
        ],
      ),
    );
  }

  /// بطاقة ملخص - للأرقام والإحصائيات (Enterprise)
  factory ProCard.summary({
    required String title,
    required String value,
    String? subtitle,
    IconData? icon,
    Color? color,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    final accentColor = color ?? AppColors.primary;
    return ProCard(
      margin: margin,
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.cardPadding.w),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: accentColor, size: 20.sp),
            ),
            SizedBox(width: AppSpacing.sm.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بطاقة جدولية - للعناوين والقيم المتقابلة (Enterprise)
  factory ProCard.table({
    required List<MapEntry<String, String>> entries,
    EdgeInsetsGeometry? margin,
    bool striped = true,
  }) {
    return ProCard(
      padding: EdgeInsets.zero,
      margin: margin,
      child: Column(
        children: [
          for (int i = 0; i < entries.length; i++)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding.w,
                vertical: AppSpacing.sm.h,
              ),
              decoration: BoxDecoration(
                color: striped && i.isOdd ? AppColors.surfaceMuted : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entries[i].key,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    entries[i].value,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// بطاقة Glass Effect (للعناصر المميزة)
  factory ProCard.glass({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return ProCard(
      padding: padding,
      margin: margin,
      color: AppColors.surface.withValues(alpha: 0.9),
      borderColor: AppColors.border.withValues(alpha: 0.5),
      boxShadow: AppShadows.sm,
      onTap: onTap,
      child: child,
    );
  }
}

/// صف بيانات للاستخدام مع ProCard.data
class ProDataRow {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  const ProDataRow({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.trailing,
  });
}

class _DataRowWidget extends StatelessWidget {
  final ProDataRow row;
  final bool compact;

  const _DataRowWidget({required this.row, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding.w,
        vertical: compact ? AppSpacing.xs.h : AppSpacing.sm.h,
      ),
      child: Row(
        children: [
          if (row.icon != null) ...[
            Icon(
              row.icon,
              size: 16.sp,
              color: row.iconColor ?? AppColors.textTertiary,
            ),
            SizedBox(width: AppSpacing.xs.w),
          ],
          Expanded(
            child: Text(
              row.label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (row.trailing != null)
            row.trailing!
          else
            Text(
              row.value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
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
