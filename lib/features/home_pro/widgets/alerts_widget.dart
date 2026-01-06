// ═══════════════════════════════════════════════════════════════════════════
// Alerts Widget Component - Enterprise Accounting Design
// Displays important notifications and warnings FROM UNIFIED ALERTS SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/providers/alerts_provider.dart';
import '../../../core/widgets/widgets.dart';

// Re-export for backward compatibility
export '../../../core/providers/alerts_provider.dart';

class AlertsWidget extends ConsumerWidget {
  const AlertsWidget({
    super.key,
    this.maxItems = 3,
  });

  final int maxItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return alertsAsync.when(
      loading: () => _buildAlertLoadingCard(),
      error: (error, _) => ProEmptyState.error(error: 'خطأ في تحميل التنبيهات'),
      data: (alerts) {
        if (alerts.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            for (int i = 0; i < alerts.take(maxItems).length; i++) ...[
              _AlertCard(
                alert: alerts[i],
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (alerts[i].route != null) {
                    context.push(alerts[i].route!);
                  }
                },
              ),
              if (i < alerts.take(maxItems).length - 1)
                SizedBox(height: AppSpacing.sm.h),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAlertLoadingCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: AppColors.incomeSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.income.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm.w),
            decoration: BoxDecoration(
              color: AppColors.income.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.income,
              size: AppIconSize.lg,
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كل شيء على ما يرام!',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.incomeDark,
                  ),
                ),
                SizedBox(height: AppSpacing.xxxs.h),
                Text(
                  'لا توجد تنبيهات تحتاج لانتباهك',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    this.onTap,
  });

  final AlertItem alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final severityInfo = _getSeverityInfo(alert.severity);

    return Material(
      color: severityInfo.bgColor,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap ?? alert.onAction,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: severityInfo.color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(AppSpacing.sm.w),
                decoration: BoxDecoration(
                  color: severityInfo.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  severityInfo.icon,
                  color: severityInfo.color,
                  size: AppIconSize.md,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: AppTypography.titleSmall.copyWith(
                        color: severityInfo.textColor,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxxs.h),
                    Text(
                      alert.message,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Action
              if (alert.actionLabel != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm.w,
                    vertical: AppSpacing.xs.h,
                  ),
                  decoration: BoxDecoration(
                    color: severityInfo.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    alert.actionLabel!,
                    style: AppTypography.labelSmall.copyWith(
                      color: severityInfo.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textTertiary,
                  size: AppIconSize.md,
                ),
            ],
          ),
        ),
      ),
    );
  }

  ({IconData icon, Color color, Color bgColor, Color textColor})
      _getSeverityInfo(
    AlertSeverity severity,
  ) {
    return switch (severity) {
      AlertSeverity.critical => (
          icon: Icons.error_outline_rounded,
          color: AppColors.expense,
          bgColor: AppColors.expenseSurface,
          textColor: AppColors.expenseDark,
        ),
      AlertSeverity.warning => (
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
          bgColor: AppColors.warningSurface,
          textColor: AppColors.warning,
        ),
      AlertSeverity.info => (
          icon: Icons.info_outline_rounded,
          color: AppColors.info,
          bgColor: AppColors.infoSurface,
          textColor: AppColors.info,
        ),
      AlertSeverity.success => (
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.income,
          bgColor: AppColors.incomeSurface,
          textColor: AppColors.incomeDark,
        ),
    };
  }
}
