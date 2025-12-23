// lib/core/widgets/empty_state.dart
// 📭 حالة فارغة موحدة

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// عرض حالة فارغة موحدة
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double iconSize;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconSize = 64,
    this.iconColor,
  });

  /// حالة فارغة للمنتجات
  factory EmptyState.products({VoidCallback? onAdd}) => EmptyState(
    icon: Icons.inventory_2_outlined,
    title: 'لا توجد منتجات',
    subtitle: 'أضف منتجات جديدة للبدء',
    action: onAdd != null
        ? ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('إضافة منتج'),
          )
        : null,
  );

  /// حالة فارغة للمبيعات
  factory EmptyState.sales({VoidCallback? onAdd}) => EmptyState(
    icon: Icons.receipt_long_outlined,
    title: 'لا توجد مبيعات',
    subtitle: 'ابدأ بإنشاء فاتورة جديدة',
    action: onAdd != null
        ? ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('بيع جديد'),
          )
        : null,
  );

  /// حالة بحث فارغة
  factory EmptyState.search(String query) => EmptyState(
    icon: Icons.search_off_outlined,
    title: 'لا توجد نتائج',
    subtitle: 'لم يتم العثور على نتائج لـ "$query"',
  );

  /// حالة خطأ
  factory EmptyState.error({String? message, VoidCallback? onRetry}) =>
      EmptyState(
        icon: Icons.error_outline,
        title: 'حدث خطأ',
        subtitle: message ?? 'فشل في تحميل البيانات',
        iconColor: AppColors.error,
        action: onRetry != null
            ? TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              )
            : null,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: iconColor ?? AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
