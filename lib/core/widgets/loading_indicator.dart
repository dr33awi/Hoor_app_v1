// lib/core/widgets/loading_indicator.dart
// ⏳ مؤشر التحميل الموحد

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// مؤشر تحميل موحد
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
    this.message,
  });

  /// مؤشر صغير للأزرار
  factory LoadingIndicator.small({Color? color}) =>
      LoadingIndicator(size: 20, strokeWidth: 2, color: color);

  /// مؤشر كامل الشاشة
  static Widget fullScreen({String? message}) {
    return Container(
      color: AppColors.background,
      child: Center(child: LoadingIndicator(message: message)),
    );
  }

  /// مؤشر داخل بطاقة
  static Widget inCard({String? message}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: LoadingIndicator(message: message, size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
