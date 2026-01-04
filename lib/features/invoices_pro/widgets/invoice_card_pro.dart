// ═══════════════════════════════════════════════════════════════════════════
// Invoice Card Pro Widget - Enterprise Accounting Design
// Clean, minimal invoice list card with status and payment info
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/design_tokens.dart';

class InvoiceCardPro extends StatelessWidget {
  final Map<String, dynamic> invoice;
  final bool isSales;
  final VoidCallback onTap;

  const InvoiceCardPro({
    super.key,
    required this.invoice,
    required this.isSales,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = invoice['status'] as String;
    final total = invoice['total'] as double;
    final paid = invoice['paid'] as double;
    final remaining = total - paid;
    final paymentProgress = total > 0 ? paid / total : 0.0;
    final isPartial = status == 'جزئي' || (paid > 0 && paid < total);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // ═══════════════════════════════════════════════════════════════
              // Header Row
              // ═══════════════════════════════════════════════════════════════
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Indicator
                  Container(
                    width: 4.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: isSales ? AppColors.income : AppColors.purchases,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),

                  // Invoice Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                invoice['customer'] ??
                                    (isSales ? 'عميل نقدي' : 'مورد'),
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(status),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              size: 14.sp,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              invoice['id'] ?? '',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs.w),
                              width: 3.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                color: AppColors.textTertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12.sp,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              invoice['date'] ?? '',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ═══════════════════════════════════════════════════════════════
              // Payment Progress (for partial payments)
              // ═══════════════════════════════════════════════════════════════
              if (isPartial && paid > 0) ...[
                SizedBox(height: AppSpacing.md.h),
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: paymentProgress,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(AppColors.income),
                          minHeight: 4.h,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 12.sp, color: AppColors.income),
                              SizedBox(width: 4.w),
                              Text(
                                'مدفوع ${paid.toStringAsFixed(0)} ل.س',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.income,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.schedule,
                                  size: 12.sp, color: AppColors.warning),
                              SizedBox(width: 4.w),
                              Text(
                                'متبقي ${remaining.toStringAsFixed(0)} ل.س',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: AppSpacing.md.h),

              // ═══════════════════════════════════════════════════════════════
              // Footer Row
              // ═══════════════════════════════════════════════════════════════
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Payment Method
                  if (invoice['paymentMethod'] != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm.w,
                        vertical: AppSpacing.xs.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            invoice['paymentMethod'] == 'cash'
                                ? Icons.money
                                : Icons.credit_card_outlined,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            invoice['paymentMethod'] == 'cash' ? 'نقدي' : 'آجل',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // Total Amount
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md.w,
                      vertical: AppSpacing.xs.h,
                    ),
                    decoration: BoxDecoration(
                      color: (isSales ? AppColors.income : AppColors.purchases)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      '${total.toStringAsFixed(0)} ل.س',
                      style: AppTypography.titleSmall.copyWith(
                        color: isSales ? AppColors.income : AppColors.purchases,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'مكتملة':
        color = AppColors.income;
        icon = Icons.check_circle_rounded;
        break;
      case 'جزئي':
        color = AppColors.warning;
        icon = Icons.pie_chart_rounded;
        break;
      case 'ملغية':
        color = AppColors.expense;
        icon = Icons.cancel_rounded;
        break;
      default:
        color = AppColors.textTertiary;
        icon = Icons.schedule_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            status,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
