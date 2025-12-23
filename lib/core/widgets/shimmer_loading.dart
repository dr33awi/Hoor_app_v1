// lib/core/widgets/shimmer_loading.dart
// ✨ تأثير Shimmer للتحميل

import 'package:flutter/material.dart';

/// تأثير Shimmer للتحميل
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  /// Shimmer لبطاقة إحصائية
  static Widget statCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const ShimmerLoading(width: 48, height: 48, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(width: 60, height: 12),
                SizedBox(height: 8),
                ShimmerLoading(width: 100, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shimmer لبطاقة منتج
  static Widget productCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerLoading(height: 100, borderRadius: 16),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(width: 100, height: 14),
                SizedBox(height: 8),
                ShimmerLoading(width: 60, height: 12),
                SizedBox(height: 8),
                ShimmerLoading(width: 80, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shimmer لعنصر قائمة
  static Widget listTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const ShimmerLoading(width: 48, height: 48, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(width: 120, height: 14),
                SizedBox(height: 8),
                ShimmerLoading(width: 80, height: 12),
              ],
            ),
          ),
          const ShimmerLoading(width: 60, height: 24, borderRadius: 8),
        ],
      ),
    );
  }

  /// شبكة منتجات shimmer
  static Widget productGrid({int count = 4}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: count,
      itemBuilder: (_, __) => productCard(),
    );
  }

  /// قائمة shimmer
  static Widget list({int count = 5}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (_, __) => listTile(),
    );
  }

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// بطاقات إحصائية shimmer
class ShimmerStatCards extends StatelessWidget {
  const ShimmerStatCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: ShimmerLoading.statCard()),
            const SizedBox(width: 12),
            Expanded(child: ShimmerLoading.statCard()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: ShimmerLoading.statCard()),
            const SizedBox(width: 12),
            Expanded(child: ShimmerLoading.statCard()),
          ],
        ),
      ],
    );
  }
}
