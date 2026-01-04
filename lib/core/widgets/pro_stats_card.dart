// ═══════════════════════════════════════════════════════════════════════════
// Pro Stats Card - Shared Statistics Widgets
// Unified stats components for all screens
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../theme/design_tokens.dart';

/// بطاقة إحصائية صغيرة - موحدة لجميع الشاشات
class ProStatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final String? suffix;
  final bool compact;
  final ProStatCardStyle style;

  const ProStatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.suffix,
    this.compact = false,
    this.style = ProStatCardStyle.standard,
  });

  /// نمط مُدمج للورديات والسندات
  const ProStatCard.horizontal({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.suffix,
  })  : compact = false,
        style = ProStatCardStyle.horizontal;

  /// نمط مركزي للفواتير
  const ProStatCard.centered({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.suffix,
  })  : compact = true,
        style = ProStatCardStyle.centered;

  /// نمط صغير جداً
  const ProStatCard.mini({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.suffix,
  })  : compact = true,
        style = ProStatCardStyle.mini;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case ProStatCardStyle.horizontal:
        return _buildHorizontal();
      case ProStatCardStyle.centered:
        return _buildCentered();
      case ProStatCardStyle.mini:
        return _buildMini();
      case ProStatCardStyle.standard:
        return _buildStandard();
    }
  }

  Widget _buildStandard() {
    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: color.o8,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.light),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: compact ? 16.sp : 20.sp),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: (compact
                          ? AppTypography.labelSmall
                          : AppTypography.labelMedium)
                      .copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            '${NumberFormat('#,###').format(amount)}${suffix ?? ''}',
            style:
                (compact ? AppTypography.titleSmall : AppTypography.titleMedium)
                    .copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontal() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppIconSize.md),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(color: color),
                ),
                Text(
                  ' ${NumberFormat('#,###').format(amount)}${suffix ?? ' ر.س'}',
                  style:
                      AppTypography.titleSmall.copyWith(color: color).monoBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentered() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppIconSize.sm, color: color),
          SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCompactAmount(amount),
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMini() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppIconSize.sm),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
          Text(
            NumberFormat('#,###').format(amount),
            style: AppTypography.titleSmall.copyWith(color: color).monoBold,
          ),
        ],
      ),
    );
  }

  String _formatCompactAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return NumberFormat('#,###').format(amount);
  }
}

/// أنماط بطاقة الإحصائيات
enum ProStatCardStyle {
  standard, // النمط العادي
  horizontal, // أفقي (للورديات)
  centered, // مركزي (للفواتير)
  mini, // صغير (للسندات)
}

/// بطاقة إحصائية نصية (للقيم النصية مثل النسب المئوية)
class ProStatCardText extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ProStatCardText({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: AppIconSize.xs, color: color),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTypography.labelLarge
                .copyWith(
                  color: AppColors.textPrimary,
                )
                .monoBold,
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// صف من البطاقات الإحصائية
class ProStatsRow extends StatelessWidget {
  final List<ProStatCard> cards;
  final EdgeInsetsGeometry? margin;

  const ProStatsRow({
    super.key,
    required this.cards,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: cards
            .asMap()
            .entries
            .map((entry) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: entry.key == 0 ? 0 : AppSpacing.xs,
                      right: entry.key == cards.length - 1 ? 0 : AppSpacing.xs,
                    ),
                    child: entry.value,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// بطاقة إحصائية كبيرة
class ProStatCardLarge extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ProStatCardLarge({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.soft,
              color.subtle,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.light),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.muted,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color.borderStrong,
                    size: 16.sp,
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ملخص إحصائي للعملاء/الموردين
class ProBalanceSummary extends StatelessWidget {
  final double receivables; // ديون لنا
  final double payables; // ديون علينا
  final String receivablesLabel;
  final String payablesLabel;
  final EdgeInsetsGeometry? margin;

  const ProBalanceSummary({
    super.key,
    required this.receivables,
    required this.payables,
    this.receivablesLabel = 'ديون لنا',
    this.payablesLabel = 'ديون علينا',
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ProStatsRow(
      margin: margin,
      cards: [
        ProStatCard(
          label: payablesLabel,
          amount: payables,
          icon: Icons.arrow_upward_rounded,
          color: AppColors.error,
        ),
        ProStatCard(
          label: receivablesLabel,
          amount: receivables,
          icon: Icons.arrow_downward_rounded,
          color: AppColors.success,
        ),
      ],
    );
  }
}

/// شريحة إحصائية صغيرة
class ProStatsChip extends StatelessWidget {
  final int count;
  final double total;
  final Color color;

  const ProStatsChip({
    super.key,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            NumberFormat.compact(locale: 'ar').format(total),
            style: AppTypography.labelSmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
