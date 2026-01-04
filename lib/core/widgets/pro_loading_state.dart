// ═══════════════════════════════════════════════════════════════════════════
// Pro Loading State - Shared Loading State Widget
// Unified loading component for all screens
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/design_tokens.dart';

/// حالة تحميل موحدة
class ProLoadingState extends StatelessWidget {
  final String? message;
  final Color? color;

  const ProLoadingState({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primary,
          ),
          if (message != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// حالة تحميل بسيطة
  factory ProLoadingState.simple() {
    return const ProLoadingState();
  }

  /// حالة تحميل مع رسالة
  factory ProLoadingState.withMessage({String? message}) {
    return ProLoadingState(
      message: message ?? 'جاري التحميل...',
    );
  }

  /// حالة تحميل للقوائم - shimmer effect
  static Widget list({int itemCount = 5}) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return _ShimmerCard(height: 80.h);
      },
    );
  }

  /// حالة تحميل للشبكة - shimmer effect
  static Widget grid({int itemCount = 6, int crossAxisCount = 2}) {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.78,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _ShimmerCard();
      },
    );
  }

  /// حالة تحميل للبطاقات
  static Widget card({double? height}) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: _ShimmerCard(height: height ?? 120.h),
    );
  }
}

/// بطاقة shimmer للتحميل
class _ShimmerCard extends StatefulWidget {
  final double? height;

  const _ShimmerCard({this.height});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                AppColors.surfaceMuted,
                AppColors.surface,
                AppColors.surfaceMuted,
              ],
            ),
          ),
        );
      },
    );
  }
}
