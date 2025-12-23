// lib/core/widgets/stat_card.dart
// 📊 بطاقة إحصائية موحدة

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// بطاقة إحصائية موحدة
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double? iconSize;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: cardColor, size: iconSize ?? 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: cardColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
