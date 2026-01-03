// ═══════════════════════════════════════════════════════════════════════════
// Welcome Header Widget
// A warm welcome message with time-based greeting
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/design_tokens.dart';

class WelcomeHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const WelcomeHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 17) {
      return 'مساء الخير';
    } else {
      return 'مساء الخير';
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return Icons.nights_stay_rounded;
    } else if (hour < 12) {
      return Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      return Icons.wb_sunny_outlined;
    } else if (hour < 20) {
      return Icons.wb_twilight_rounded;
    } else {
      return Icons.nights_stay_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.colored(AppColors.secondary),
          ),
          child: Icon(
            _getGreetingIcon(),
            color: AppColors.textOnPrimary,
            size: AppIconSize.lg,
          ),
        ),
        SizedBox(width: AppSpacing.md.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getGreeting(),
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  Text(
                    '👋',
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ],
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
