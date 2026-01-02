// ═══════════════════════════════════════════════════════════════════════════
// Pro Stats Card - Shared Statistics Widgets
// Unified stats components for all screens
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../theme/design_tokens.dart';

/// بطاقة إحصائية صغيرة
class ProStatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final String? suffix;
  final bool compact;

  const ProStatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.suffix,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
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
