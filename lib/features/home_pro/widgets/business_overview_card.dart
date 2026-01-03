// ═══════════════════════════════════════════════════════════════════════════
// Business Overview Card Widget
// A summary card showing key business metrics
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/design_tokens.dart';

class BusinessOverviewCard extends StatelessWidget {
  final double todaySales;
  final double todayPurchases;
  final double todayProfit;
  final int lowStockCount;
  final bool isLoading;
  final bool hasError;

  const BusinessOverviewCard({
    super.key,
    required this.todaySales,
    required this.todayPurchases,
    required this.todayProfit,
    required this.lowStockCount,
  })  : isLoading = false,
        hasError = false;

  const BusinessOverviewCard._loading({super.key})
      : todaySales = 0,
        todayPurchases = 0,
        todayProfit = 0,
        lowStockCount = 0,
        isLoading = true,
        hasError = false;

  const BusinessOverviewCard._error({super.key})
      : todaySales = 0,
        todayPurchases = 0,
        todayProfit = 0,
        lowStockCount = 0,
        isLoading = false,
        hasError = true;

  factory BusinessOverviewCard.loading() => const BusinessOverviewCard._loading();
  factory BusinessOverviewCard.error() => const BusinessOverviewCard._error();

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(2);
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
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // First Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.trending_up_rounded,
                  title: 'مبيعات اليوم',
                  value: _formatNumber(todaySales),
                  suffix: 'ر.س',
                  color: AppColors.income,
                  gradient: AppColors.incomeGradient,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.shopping_cart_rounded,
                  title: 'مشتريات اليوم',
                  value: _formatNumber(todayPurchases),
                  suffix: 'ر.س',
                  color: AppColors.expense,
                  gradient: AppColors.expenseGradient,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'صافي الربح',
                  value: _formatNumber(todayProfit),
                  suffix: 'ر.س',
                  color: todayProfit >= 0 ? AppColors.income : AppColors.expense,
                  gradient: todayProfit >= 0
                      ? AppColors.incomeGradient
                      : AppColors.expenseGradient,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.warning_amber_rounded,
                  title: 'نفاد المخزون',
                  value: lowStockCount.toString(),
                  suffix: 'منتج',
                  color: lowStockCount > 0 ? AppColors.warning : AppColors.success,
                  gradient: lowStockCount > 0
                      ? LinearGradient(
                          colors: [AppColors.warning, AppColors.accentLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : AppColors.incomeGradient,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required String suffix,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: AppColors.textOnPrimary,
                  size: AppIconSize.sm,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textTertiary,
                size: AppIconSize.xs,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xxs.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTypography.titleLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.xxs.w),
              Text(
                suffix,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
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
      padding: EdgeInsets.all(AppSpacing.lg.w),
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
