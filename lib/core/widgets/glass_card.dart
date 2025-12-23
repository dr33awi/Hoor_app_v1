// lib/core/widgets/glass_card.dart
// 🪟 بطاقة زجاجية (Glassmorphism)

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// بطاقة بتأثير زجاجي
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final double opacity;
  final VoidCallback? onTap;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.blur = 10,
    this.color,
    this.opacity = 0.1,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (color ?? Colors.white).withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(borderRadius),
                border:
                    border ??
                    Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة متدرجة محسنة
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.onTap,
    this.boxShadow,
  });

  /// بطاقة أساسية
  factory GradientCard.primary({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    return GradientCard(
      padding: padding,
      onTap: onTap,
      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      child: child,
    );
  }

  /// بطاقة نجاح
  factory GradientCard.success({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    return GradientCard(
      padding: padding,
      onTap: onTap,
      colors: [AppColors.success, const Color(0xFF059669)],
      boxShadow: [
        BoxShadow(
          color: AppColors.success.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors:
                colors ??
                [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
          ),
          boxShadow: boxShadow,
        ),
        child: child,
      ),
    );
  }
}

/// بطاقة مرتفعة مع ظل
class ElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final double elevation;

  const ElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.color,
    this.onTap,
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04 * elevation),
              blurRadius: 8 * elevation,
              offset: Offset(0, 2 * elevation),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02 * elevation),
              blurRadius: 4 * elevation,
              offset: Offset(0, 1 * elevation),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
