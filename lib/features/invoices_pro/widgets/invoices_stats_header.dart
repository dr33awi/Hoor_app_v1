// ═══════════════════════════════════════════════════════════════════════════
// Invoices Stats Header Widget
// Summary cards showing invoice statistics
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/widgets.dart';

class InvoicesStatsHeader extends StatelessWidget {
  final bool isSales;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final double overdueAmount;

  const InvoicesStatsHeader({
    super.key,
    required this.isSales,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.overdueAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: ProStatCard.centered(
              label: 'الإجمالي',
              amount: totalAmount,
              icon: Icons.receipt_long_rounded,
              color: isSales ? AppColors.success : AppColors.secondary,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ProStatCard.centered(
              label: 'المحصل',
              amount: paidAmount,
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ProStatCard.centered(
              label: 'معلق',
              amount: pendingAmount,
              icon: Icons.schedule_rounded,
              color: AppColors.warning,
            ),
          ),
          if (overdueAmount > 0) ...[
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ProStatCard.centered(
                label: 'متأخر',
                amount: overdueAmount,
                icon: Icons.warning_amber_rounded,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// تم نقل _StatCard إلى ProStatCard في core/widgets/pro_stats_card.dart
