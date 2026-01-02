// ═══════════════════════════════════════════════════════════════════════════
// Pro Empty State - Shared Empty State Widget
// Unified empty state component for all screens
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/design_tokens.dart';

/// حالة فارغة موحدة
class ProEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const ProEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.textTertiary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.sp,
                color: iconColor ?? AppColors.textTertiary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// حالة فارغة للقوائم
  factory ProEmptyState.list({
    required String itemName,
    VoidCallback? onAdd,
  }) {
    return ProEmptyState(
      icon: Icons.inbox_rounded,
      title: 'لا يوجد $itemName',
      message: 'ابدأ بإضافة $itemName جديد',
      actionLabel: onAdd != null ? 'إضافة $itemName' : null,
      onAction: onAdd,
    );
  }

  /// حالة خطأ
  factory ProEmptyState.error({
    String? error,
    VoidCallback? onRetry,
  }) {
    return ProEmptyState(
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
      title: 'حدث خطأ',
      message: error ?? 'حدث خطأ غير متوقع',
      actionLabel: onRetry != null ? 'إعادة المحاولة' : null,
      onAction: onRetry,
    );
  }

  /// حالة لا يوجد اتصال
  factory ProEmptyState.noConnection({
    VoidCallback? onRetry,
  }) {
    return ProEmptyState(
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.warning,
      title: 'لا يوجد اتصال',
      message: 'تحقق من اتصالك بالإنترنت',
      actionLabel: onRetry != null ? 'إعادة المحاولة' : null,
      onAction: onRetry,
    );
  }

  /// حالة فارغة للبحث
  factory ProEmptyState.search() {
    return const ProEmptyState(
      icon: Icons.search_off_rounded,
      title: 'لا توجد نتائج',
      message: 'جرب البحث بكلمات مختلفة',
    );
  }

  /// حالة فارغة للمرتجعات
  factory ProEmptyState.returns({bool isSales = true}) {
    return ProEmptyState(
      icon: Icons.assignment_return_rounded,
      title: 'لا توجد مرتجعات',
      message: isSales
          ? 'لم يتم تسجيل أي مرتجعات مبيعات'
          : 'لم يتم تسجيل أي مرتجعات مشتريات',
      iconColor: isSales ? AppColors.error : AppColors.warning,
    );
  }

  /// حالة فارغة للفواتير
  factory ProEmptyState.invoices({bool isSales = true}) {
    return ProEmptyState(
      icon: Icons.receipt_long_rounded,
      title: 'لا توجد فواتير',
      message: isSales ? 'لم يتم إنشاء فواتير بيع' : 'لم يتم إنشاء فواتير شراء',
      iconColor: isSales ? AppColors.income : AppColors.purchases,
    );
  }

  /// حالة لا توجد نتائج
  factory ProEmptyState.noResults({
    VoidCallback? onClear,
  }) {
    return ProEmptyState(
      icon: Icons.search_off_rounded,
      title: 'لا توجد نتائج',
      message: 'جرب تغيير معايير البحث',
      actionLabel: onClear != null ? 'مسح الفلاتر' : null,
      onAction: onClear,
    );
  }
}

/// حالة الخطأ الموحدة
class ProErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ProErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'حدث خطأ',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
