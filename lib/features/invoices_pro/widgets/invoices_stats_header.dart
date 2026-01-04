// ═══════════════════════════════════════════════════════════════════════════
// Invoices Stats Header Widget - Enterprise Accounting Design
// Summary cards showing invoice statistics with ledger precision
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/services/currency_service.dart';

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

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}م';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}ك';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = isSales ? AppColors.income : AppColors.purchases;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.colored(primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  isSales
                      ? Icons.trending_up_rounded
                      : Icons.shopping_bag_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                isSales ? 'إجمالي المبيعات' : 'إجمالي المشتريات',
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm.h),

          // Total Amount
          Text(
            '${_formatAmount(totalAmount)} ل.س',
            style: AppTypography.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 28.sp,
            ),
          ),
          Text(
            '\$${(totalAmount / CurrencyService.currentRate).toStringAsFixed(2)}',
            style: AppTypography.titleSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),

          SizedBox(height: AppSpacing.md.h),

          // Stats Row
          Row(
            children: [
              _buildStatPill(
                label: 'محصّل',
                amount: paidAmount,
                color: AppColors.income,
              ),
              SizedBox(width: AppSpacing.sm.w),
              _buildStatPill(
                label: 'معلق',
                amount: pendingAmount,
                color: AppColors.warning,
              ),
              if (overdueAmount > 0) ...[
                SizedBox(width: AppSpacing.sm.w),
                _buildStatPill(
                  label: 'متأخر',
                  amount: overdueAmount,
                  color: AppColors.expense,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm.w,
          vertical: AppSpacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              '${_formatAmount(amount)} ل.س (\$${(amount / CurrencyService.currentRate).toStringAsFixed(1)})',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
