// ═══════════════════════════════════════════════════════════════════════════
// Alerts Screen Pro - Enterprise Accounting Design
// System Alerts and Notifications with Professional Touch
// Uses UNIFIED ALERTS SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/alerts_provider.dart';

class AlertsScreenPro extends ConsumerWidget {
  const AlertsScreenPro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProAppBar.simple(
        title: 'التنبيهات',
        onBack: () => context.go('/'),
        actions: [
          // Badge showing alert count
          alertsAsync.whenOrNull(
                data: (alerts) => alerts.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(left: AppSpacing.sm),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${alerts.length}',
                          style: AppTypography.labelSmall
                              .copyWith(
                                color: Colors.white,
                              )
                              .mono,
                        ),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
          // Refresh button
          IconButton(
            onPressed: () => ref.invalidate(alertsProvider),
            icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => ProLoadingState.list(),
        error: (error, _) => ProEmptyState.error(error: 'خطأ في تحميل التنبيهات: $error'),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const ProEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'لا توجد تنبيهات',
              message: 'ستظهر التنبيهات الجديدة هنا عند وجود:\n• منتجات منخفضة المخزون\n• ذمم مدينة أو دائنة\n• وردية غير مفتوحة',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(alertsProvider);
              await ref.read(alertsProvider.future);
            },
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _AlertCard(
                  alert: alert,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (alert.route != null) {
                      context.push(alert.route!);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertItem alert;
  final VoidCallback onTap;

  const _AlertCard({
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (alert.severity) {
      case AlertSeverity.critical:
        icon = Icons.error_outline_rounded;
        color = AppColors.error;
        break;
      case AlertSeverity.warning:
        icon = Icons.warning_amber_rounded;
        color = AppColors.warning;
        break;
      case AlertSeverity.info:
        icon = Icons.info_outline_rounded;
        color = AppColors.secondary;
        break;
      case AlertSeverity.success:
        icon = Icons.check_circle_outline_rounded;
        color = AppColors.success;
        break;
    }

    // Special icons based on alert ID
    switch (alert.id) {
      case 'low_stock':
        icon = Icons.inventory_2_outlined;
        break;
      case 'zero_stock':
        icon = Icons.remove_shopping_cart_outlined;
        break;
      case 'receivables':
        icon = Icons.account_balance_wallet_outlined;
        break;
      case 'payables':
        icon = Icons.payment_outlined;
        break;
      case 'no_shift':
        icon = Icons.access_time_rounded;
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: color.border),
      ),
      color: color.subtle,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: AppIconSize.md),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      alert.message,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (alert.actionLabel != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            alert.actionLabel!,
                            style: AppTypography.labelMedium.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: color,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
