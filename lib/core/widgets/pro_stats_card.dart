// ═══════════════════════════════════════════════════════════════════════════
// Pro Stats Card - Enterprise Statistics Widgets
// Professional metrics display for accounting interfaces
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../theme/design_tokens.dart';

/// بطاقة إحصائية - تصميم Enterprise المحاسبي
class ProStatCard extends StatelessWidget {
  final String label;
  final double amount;
  final double? amountUsd; // السعر بالدولار (اختياري)
  final IconData icon;
  final Color color;
  final String? suffix;
  final bool compact;
  final ProStatCardStyle style;

  const ProStatCard({
    super.key,
    required this.label,
    required this.amount,
    this.amountUsd,
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
    this.amountUsd,
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
    this.amountUsd,
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
    this.amountUsd,
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
      case ProStatCardStyle.ledger:
        return _buildLedger();
      case ProStatCardStyle.metric:
        return _buildMetric();
    }
  }

  // النمط القياسي - Enterprise
  Widget _buildStandard() {
    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Icon(icon, color: color, size: compact ? 14.sp : 16.sp),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '${NumberFormat('#,###').format(amount)}${suffix ?? ''}',
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          // عرض السعر بالدولار إذا كان متوفراً
          if (amountUsd != null && amountUsd! > 0)
            Text(
              '\$${amountUsd!.toStringAsFixed(1)}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }

  // نمط أفقي - Enterprise
  Widget _buildHorizontal() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${NumberFormat('#,###').format(amount)}${suffix ?? ' ل.س'}',
                  style: AppTypography.titleSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                // عرض السعر بالدولار إذا كان متوفراً
                if (amountUsd != null && amountUsd! > 0)
                  Text(
                    '\$${amountUsd!.toStringAsFixed(1)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
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

  // نمط مركزي - Enterprise
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
          Icon(icon, size: 16.sp, color: color),
          SizedBox(height: AppSpacing.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCompactAmount(amount),
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  // نمط مصغّر - Enterprise
  Widget _buildMini() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 9.sp,
            ),
          ),
          Text(
            NumberFormat('#,###').format(amount),
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NEW ENTERPRISE STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  /// نمط دفتري - للأرصدة والحسابات (Enterprise)
  Widget _buildLedger() {
    final isPositive = amount >= 0;
    final displayColor = isPositive ? AppColors.income : AppColors.expense;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: displayColor,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '${NumberFormat('#,###.00').format(amount.abs())}${suffix ?? ' ل.س'}',
            style: AppTypography.titleSmall.copyWith(
              color: displayColor,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Icon(
            isPositive ? Icons.add : Icons.remove,
            size: 14.sp,
            color: displayColor,
          ),
        ],
      ),
    );
  }

  /// نمط متري - للـ KPIs (Enterprise)
  Widget _buildMetric() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat('#,###').format(amount),
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (suffix != null) ...[
                SizedBox(width: AppSpacing.xxs),
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    suffix!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
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
  ledger, // دفتري (للحسابات) - NEW
  metric, // متري (للـ KPIs) - NEW
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
