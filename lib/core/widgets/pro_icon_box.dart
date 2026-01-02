// ═══════════════════════════════════════════════════════════════════════════
// Pro Icon Box - Unified Icon Container Widget
// Consistent icon boxes across all screens
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/design_tokens.dart';

/// صندوق أيقونة موحد
class ProIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double? size;
  final double? iconSize;
  final bool circular;

  const ProIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size,
    this.iconSize,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    final boxSize = size ?? 48.w;
    final icoSize = iconSize ?? 24.sp;

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: circular 
            ? null 
            : BorderRadius.circular(AppRadius.md),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Icon(
        icon,
        color: color,
        size: icoSize,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Size Variants
  // ═══════════════════════════════════════════════════════════════════════════

  /// صغير (32x32)
  factory ProIconBox.small({
    required IconData icon,
    required Color color,
    bool circular = false,
  }) {
    return ProIconBox(
      icon: icon,
      color: color,
      size: 32.w,
      iconSize: 16.sp,
      circular: circular,
    );
  }

  /// متوسط (40x40)
  factory ProIconBox.medium({
    required IconData icon,
    required Color color,
    bool circular = false,
  }) {
    return ProIconBox(
      icon: icon,
      color: color,
      size: 40.w,
      iconSize: 20.sp,
      circular: circular,
    );
  }

  /// كبير (56x56)
  factory ProIconBox.large({
    required IconData icon,
    required Color color,
    bool circular = false,
  }) {
    return ProIconBox(
      icon: icon,
      color: color,
      size: 56.w,
      iconSize: 28.sp,
      circular: circular,
    );
  }

  /// ضخم (72x72)
  factory ProIconBox.xlarge({
    required IconData icon,
    required Color color,
    bool circular = false,
  }) {
    return ProIconBox(
      icon: icon,
      color: color,
      size: 72.w,
      iconSize: 36.sp,
      circular: circular,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Semantic Variants
  // ═══════════════════════════════════════════════════════════════════════════

  /// نجاح
  factory ProIconBox.success({
    IconData icon = Icons.check_circle_rounded,
    double? size,
  }) {
    return ProIconBox(
      icon: icon,
      color: AppColors.success,
      size: size,
    );
  }

  /// خطأ
  factory ProIconBox.error({
    IconData icon = Icons.error_rounded,
    double? size,
  }) {
    return ProIconBox(
      icon: icon,
      color: AppColors.error,
      size: size,
    );
  }

  /// تحذير
  factory ProIconBox.warning({
    IconData icon = Icons.warning_rounded,
    double? size,
  }) {
    return ProIconBox(
      icon: icon,
      color: AppColors.warning,
      size: size,
    );
  }

  /// معلومات
  factory ProIconBox.info({
    IconData icon = Icons.info_rounded,
    double? size,
  }) {
    return ProIconBox(
      icon: icon,
      color: AppColors.info,
      size: size,
    );
  }

  /// أساسي
  factory ProIconBox.primary({
    required IconData icon,
    double? size,
  }) {
    return ProIconBox(
      icon: icon,
      color: AppColors.primary,
      size: size,
    );
  }

  /// ثانوي
  factory ProIconBox.secondary({
    required IconData icon,
    double? size,
  }) {
    return ProIconBox(
      icon: icon,
      color: AppColors.secondary,
      size: size,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Domain-Specific Variants
  // ═══════════════════════════════════════════════════════════════════════════

  /// مبيعات
  factory ProIconBox.sales({double? size}) {
    return ProIconBox(
      icon: Icons.receipt_long_rounded,
      color: AppColors.sales,
      size: size,
    );
  }

  /// مشتريات
  factory ProIconBox.purchases({double? size}) {
    return ProIconBox(
      icon: Icons.shopping_cart_rounded,
      color: AppColors.purchases,
      size: size,
    );
  }

  /// مخزون
  factory ProIconBox.inventory({double? size}) {
    return ProIconBox(
      icon: Icons.inventory_2_rounded,
      color: AppColors.inventory,
      size: size,
    );
  }

  /// عملاء
  factory ProIconBox.customers({double? size}) {
    return ProIconBox(
      icon: Icons.people_rounded,
      color: AppColors.customers,
      size: size,
    );
  }

  /// موردين
  factory ProIconBox.suppliers({double? size}) {
    return ProIconBox(
      icon: Icons.local_shipping_rounded,
      color: AppColors.primary,
      size: size,
    );
  }

  /// إيرادات
  factory ProIconBox.income({double? size}) {
    return ProIconBox(
      icon: Icons.arrow_downward_rounded,
      color: AppColors.income,
      size: size,
    );
  }

  /// مصروفات
  factory ProIconBox.expense({double? size}) {
    return ProIconBox(
      icon: Icons.arrow_upward_rounded,
      color: AppColors.expense,
      size: size,
    );
  }

  /// مستودعات
  factory ProIconBox.warehouse({double? size}) {
    return ProIconBox(
      icon: Icons.warehouse_rounded,
      color: AppColors.secondary,
      size: size,
    );
  }

  /// تصنيفات
  factory ProIconBox.category({double? size, Color? color}) {
    return ProIconBox(
      icon: Icons.category_rounded,
      color: color ?? AppColors.secondary,
      size: size,
    );
  }
}

/// صندوق أيقونة مع صورة (للمنتجات والتصنيفات)
class ProImageBox extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final double? size;
  final double borderRadius;

  const ProImageBox({
    super.key,
    this.imageUrl,
    required this.fallbackIcon,
    this.fallbackColor = const Color(0xFF6B7280),
    this.size,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final boxSize = size ?? 48.w;

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Icon(
        fallbackIcon,
        color: fallbackColor,
        size: (size ?? 48.w) * 0.5,
      ),
    );
  }

  /// للمنتجات
  factory ProImageBox.product({String? imageUrl, double? size}) {
    return ProImageBox(
      imageUrl: imageUrl,
      fallbackIcon: Icons.inventory_2_outlined,
      fallbackColor: AppColors.textTertiary,
      size: size,
    );
  }

  /// للتصنيفات
  factory ProImageBox.category({String? imageUrl, double? size}) {
    return ProImageBox(
      imageUrl: imageUrl,
      fallbackIcon: Icons.category_outlined,
      fallbackColor: AppColors.textTertiary,
      size: size,
    );
  }

  /// للعملاء
  factory ProImageBox.customer({String? imageUrl, double? size}) {
    return ProImageBox(
      imageUrl: imageUrl,
      fallbackIcon: Icons.person_outlined,
      fallbackColor: AppColors.textTertiary,
      size: size,
      borderRadius: 100, // circular
    );
  }
}
