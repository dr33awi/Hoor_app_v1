// ═══════════════════════════════════════════════════════════════════════════
// Pro Section Title - Shared Section Header Widget
// Unified section title component for all forms
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// عنوان قسم موحد
class ProSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const ProSectionTitle(
    this.title, {
    super.key,
    this.icon,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppIconSize.sm,
              color: AppColors.secondary,
            ),
            SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// عنوان قسم مع خط فاصل
class ProSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? action;

  const ProSectionHeader(
    this.title, {
    super.key,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  size: AppIconSize.sm,
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (action != null) action!,
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Divider(color: AppColors.border, height: 1),
      ],
    );
  }
}
