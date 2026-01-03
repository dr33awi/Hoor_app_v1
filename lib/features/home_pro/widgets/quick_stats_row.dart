// ═══════════════════════════════════════════════════════════════════════════
// Quick Stats Row Widget
// A horizontal row displaying key statistics at a glance
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/design_tokens.dart';

class QuickStatsRow extends StatelessWidget {
  final double sales;
  final double profit;
  final int products;
  final int customers;
  final bool isLoading;
  final bool hasError;

  const QuickStatsRow({
    super.key,
    required this.sales,
    required this.profit,
    required this.products,
    required this.customers,
  })  : isLoading = false,
        hasError = false;

  const QuickStatsRow._loading({super.key})
      : sales = 0,
        profit = 0,
        products = 0,
        customers = 0,
        isLoading = true,
        hasError = false;

  const QuickStatsRow._error({super.key})
      : sales = 0,
        profit = 0,
        products = 0,
        customers = 0,
        isLoading = false,
        hasError = true;

  factory QuickStatsRow.loading() => const QuickStatsRow._loading();
  factory QuickStatsRow.error() => const QuickStatsRow._error();

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (hasError) {
      return _buildErrorState();
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.trending_up_rounded,
            label: 'المبيعات',
            value: _formatNumber(sales),
            suffix: 'ر.س',
            color: AppColors.income,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'الربح',
            value: _formatNumber(profit),
            suffix: 'ر.س',
            color: profit >= 0 ? AppColors.income : AppColors.expense,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.inventory_2_rounded,
            label: 'المنتجات',
            value: products.toString(),
            suffix: '',
            color: AppColors.inventory,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.people_rounded,
            label: 'العملاء',
            value: customers.toString(),
            suffix: '',
            color: AppColors.customers,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String suffix,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppIconSize.sm,
            ),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (suffix.isNotEmpty) ...[
                SizedBox(width: 2.w),
                Text(
                  suffix,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50.h,
      width: 1,
      color: AppColors.border,
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 100.h,
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.secondary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.expenseLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.expense,
            size: AppIconSize.md,
          ),
          SizedBox(width: AppSpacing.sm.w),
          Text(
            'خطأ في تحميل البيانات',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}
