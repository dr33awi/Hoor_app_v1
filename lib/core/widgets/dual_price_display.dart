import 'package:flutter/material.dart';
import '../services/currency_formatter.dart';
import '../theme/design_tokens.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Dual Price Display Widget
/// ═══════════════════════════════════════════════════════════════════════════
/// يعرض السعر بالليرة السورية والدولار معاً
///
/// مثال الاستخدام:
/// ```dart
/// DualPriceDisplay(
///   amountSyp: 1500000,
///   amountUsd: 100,
/// )
/// ```
///
/// سيعرض:
/// 1,500,000 ل.س
/// $100.00
/// ═══════════════════════════════════════════════════════════════════════════
class DualPriceDisplay extends StatelessWidget {
  /// المبلغ بالليرة السورية
  final double amountSyp;

  /// المبلغ بالدولار (اختياري - إذا لم يُحدد سيُحسب من سعر الصرف)
  final double? amountUsd;

  /// سعر الصرف المستخدم (للحساب إذا لم يُحدد المبلغ بالدولار)
  final double? exchangeRate;

  /// حجم الخط للمبلغ بالليرة
  final TextStyle? sypStyle;

  /// حجم الخط للمبلغ بالدولار
  final TextStyle? usdStyle;

  /// محاذاة النص
  final CrossAxisAlignment alignment;

  /// إظهار المبلغ بالدولار (افتراضياً true)
  final bool showUsd;

  /// إظهار المبلغ بالليرة (افتراضياً true)
  final bool showSyp;

  /// المسافة بين السعرين
  final double spacing;

  /// اللون الرئيسي (للمبلغ بالليرة)
  final Color? sypColor;

  /// لون المبلغ بالدولار
  final Color? usdColor;

  /// هل المبلغ سالب (للعرض بلون مختلف)
  final bool isNegative;

  /// نوع العرض
  final DualPriceDisplayType type;

  const DualPriceDisplay({
    super.key,
    required this.amountSyp,
    this.amountUsd,
    this.exchangeRate,
    this.sypStyle,
    this.usdStyle,
    this.alignment = CrossAxisAlignment.end,
    this.showUsd = true,
    this.showSyp = true,
    this.spacing = 2,
    this.sypColor,
    this.usdColor,
    this.isNegative = false,
    this.type = DualPriceDisplayType.vertical,
  });

  /// حساب المبلغ بالدولار إذا لم يكن محدداً
  double get _calculatedUsd {
    if (amountUsd != null) return amountUsd!;
    if (exchangeRate != null && exchangeRate! > 0) {
      return amountSyp / exchangeRate!;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSypColor =
        isNegative ? AppColors.error : (sypColor ?? AppColors.textPrimary);

    final effectiveUsdColor = isNegative
        ? AppColors.error.withValues(alpha: 0.7)
        : (usdColor ?? AppColors.textSecondary);

    final effectiveSypStyle = sypStyle ??
        AppTypography.titleMedium.copyWith(
          color: effectiveSypColor,
          fontWeight: FontWeight.bold,
        );

    final effectiveUsdStyle = usdStyle ??
        AppTypography.bodySmall.copyWith(
          color: effectiveUsdColor,
        );

    final sypText = CurrencyFormatter.formatSyp(
      isNegative ? -amountSyp.abs() : amountSyp.abs(),
    );

    final usdText = CurrencyFormatter.formatUsd(
      isNegative ? -_calculatedUsd.abs() : _calculatedUsd.abs(),
    );

    if (type == DualPriceDisplayType.horizontal) {
      return _buildHorizontal(
        sypText: sypText,
        usdText: usdText,
        sypStyle: effectiveSypStyle,
        usdStyle: effectiveUsdStyle,
      );
    }

    if (type == DualPriceDisplayType.inline) {
      return _buildInline(
        sypText: sypText,
        usdText: usdText,
        sypStyle: effectiveSypStyle,
        usdStyle: effectiveUsdStyle,
      );
    }

    return _buildVertical(
      sypText: sypText,
      usdText: usdText,
      sypStyle: effectiveSypStyle,
      usdStyle: effectiveUsdStyle,
    );
  }

  Widget _buildVertical({
    required String sypText,
    required String usdText,
    required TextStyle sypStyle,
    required TextStyle usdStyle,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSyp)
          Text(
            sypText,
            style: sypStyle,
            textDirection: TextDirection.rtl,
          ),
        if (showSyp && showUsd) SizedBox(height: spacing),
        if (showUsd && _calculatedUsd != 0)
          Text(
            usdText,
            style: usdStyle,
            textDirection: TextDirection.ltr,
          ),
      ],
    );
  }

  Widget _buildHorizontal({
    required String sypText,
    required String usdText,
    required TextStyle sypStyle,
    required TextStyle usdStyle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSyp)
          Text(
            sypText,
            style: sypStyle,
            textDirection: TextDirection.rtl,
          ),
        if (showSyp && showUsd && _calculatedUsd != 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '•',
              style: usdStyle,
            ),
          ),
        if (showUsd && _calculatedUsd != 0)
          Text(
            usdText,
            style: usdStyle,
            textDirection: TextDirection.ltr,
          ),
      ],
    );
  }

  Widget _buildInline({
    required String sypText,
    required String usdText,
    required TextStyle sypStyle,
    required TextStyle usdStyle,
  }) {
    if (!showUsd || _calculatedUsd == 0) {
      return Text(sypText, style: sypStyle);
    }

    return Text.rich(
      TextSpan(
        children: [
          if (showSyp)
            TextSpan(
              text: sypText,
              style: sypStyle,
            ),
          if (showSyp && showUsd)
            TextSpan(
              text: ' (',
              style: usdStyle,
            ),
          if (showUsd)
            TextSpan(
              text: usdText,
              style: usdStyle,
            ),
          if (showSyp && showUsd)
            TextSpan(
              text: ')',
              style: usdStyle,
            ),
        ],
      ),
      textDirection: TextDirection.rtl,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// نوع عرض السعر المزدوج
/// ═══════════════════════════════════════════════════════════════════════════
enum DualPriceDisplayType {
  /// عرض عمودي (الليرة فوق، الدولار تحت)
  /// 1,500,000 ل.س
  /// $100.00
  vertical,

  /// عرض أفقي (الليرة • الدولار)
  /// 1,500,000 ل.س • $100.00
  horizontal,

  /// عرض في سطر واحد (الليرة (الدولار))
  /// 1,500,000 ل.س ($100.00)
  inline,
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Compact Dual Price (للأماكن الضيقة)
/// ═══════════════════════════════════════════════════════════════════════════
class CompactDualPrice extends StatelessWidget {
  final double amountSyp;
  final double? amountUsd;
  final double? exchangeRate;
  final TextStyle? style;
  final TextStyle? sypStyle;
  final TextStyle? usdStyle;
  final Color? color;

  const CompactDualPrice({
    super.key,
    required this.amountSyp,
    this.amountUsd,
    this.exchangeRate,
    this.style,
    this.sypStyle,
    this.usdStyle,
    this.color,
  });

  double get _calculatedUsd {
    if (amountUsd != null) return amountUsd!;
    if (exchangeRate != null && exchangeRate! > 0) {
      return amountSyp / exchangeRate!;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ??
        AppTypography.bodySmall.copyWith(
          color: color ?? AppColors.textSecondary,
        );

    final effectiveSypStyle = sypStyle ?? effectiveStyle;
    final effectiveUsdStyle = usdStyle ??
        effectiveStyle.copyWith(
          fontSize: (effectiveStyle.fontSize ?? 14) * 0.85,
          color: AppColors.textTertiary,
        );

    final sypFormatted = CurrencyFormatter.formatSypCompact(amountSyp);
    final usdFormatted = _calculatedUsd > 0
        ? CurrencyFormatter.formatUsdCompact(_calculatedUsd)
        : null;

    if (sypStyle != null || usdStyle != null) {
      // إذا تم تحديد أنماط مخصصة، نستخدم RichText
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(text: sypFormatted, style: effectiveSypStyle),
            if (usdFormatted != null) ...[
              TextSpan(text: ' (', style: effectiveUsdStyle),
              TextSpan(text: usdFormatted, style: effectiveUsdStyle),
              TextSpan(text: ')', style: effectiveUsdStyle),
            ],
          ],
        ),
      );
    }

    return Text(
      usdFormatted != null ? '$sypFormatted ($usdFormatted)' : sypFormatted,
      style: effectiveStyle,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Price Tag Widget (للمنتجات)
/// ═══════════════════════════════════════════════════════════════════════════
class PriceTag extends StatelessWidget {
  final double priceSyp;
  final double? priceUsd;
  final double? exchangeRate;
  final bool showBadge;
  final Color? backgroundColor;
  final Color? textColor;

  const PriceTag({
    super.key,
    required this.priceSyp,
    this.priceUsd,
    this.exchangeRate,
    this.showBadge = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary.withValues(alpha: 0.1);
    final txtColor = textColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DualPriceDisplay(
        amountSyp: priceSyp,
        amountUsd: priceUsd,
        exchangeRate: exchangeRate,
        alignment: CrossAxisAlignment.center,
        sypStyle: AppTypography.titleMedium.copyWith(
          color: txtColor,
          fontWeight: FontWeight.bold,
        ),
        usdStyle: AppTypography.bodySmall.copyWith(
          color: txtColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Total Display Widget (للإجماليات)
/// ═══════════════════════════════════════════════════════════════════════════
class TotalDisplay extends StatelessWidget {
  final String label;
  final double amountSyp;
  final double? amountUsd;
  final double? exchangeRate;
  final bool isHighlighted;
  final bool isNegative;

  const TotalDisplay({
    super.key,
    required this.label,
    required this.amountSyp,
    this.amountUsd,
    this.exchangeRate,
    this.isHighlighted = false,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          DualPriceDisplay(
            amountSyp: amountSyp,
            amountUsd: amountUsd,
            exchangeRate: exchangeRate,
            isNegative: isNegative,
            sypStyle: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isNegative
                  ? AppColors.error
                  : (isHighlighted ? AppColors.primary : AppColors.textPrimary),
            ),
            usdStyle: AppTypography.bodySmall.copyWith(
              color: isNegative
                  ? AppColors.error.withValues(alpha: 0.7)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Exchange Rate Badge (لعرض سعر الصرف المستخدم)
/// ═══════════════════════════════════════════════════════════════════════════
class ExchangeRateBadge extends StatelessWidget {
  final double exchangeRate;
  final bool isHistorical;

  const ExchangeRateBadge({
    super.key,
    required this.exchangeRate,
    this.isHistorical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHistorical
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isHistorical
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHistorical ? Icons.history : Icons.currency_exchange,
            size: 12,
            color: isHistorical ? AppColors.warning : AppColors.info,
          ),
          const SizedBox(width: 4),
          Text(
            CurrencyFormatter.formatExchangeRate(exchangeRate),
            style: AppTypography.labelSmall.copyWith(
              color: isHistorical ? AppColors.warning : AppColors.info,
            ),
          ),
        ],
      ),
    );
  }
}
