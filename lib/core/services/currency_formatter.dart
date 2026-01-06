import 'package:intl/intl.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Currency Formatter - Static Utility Class
/// Single Responsibility: Format numbers for display ONLY
/// No business logic, no state, no conversion
/// ═══════════════════════════════════════════════════════════════════════════
class CurrencyFormatter {
  CurrencyFormatter._(); // Prevent instantiation

  // ═══════════════════════════════════════════════════════════════════════════
  // Format Instances (Cached for performance)
  // ═══════════════════════════════════════════════════════════════════════════

  static final _sypFormat = NumberFormat.decimalPattern('ar');
  static final _usdFormat = NumberFormat.currency(
    locale: 'en',
    symbol: '\$',
    decimalDigits: 2,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Currency Symbols
  // ═══════════════════════════════════════════════════════════════════════════

  static const String sypSymbol = 'ل.س';
  static const String sypCode = 'SYP';
  static const String usdSymbol = '\$';
  static const String usdCode = 'USD';

  // ═══════════════════════════════════════════════════════════════════════════
  // Syrian Pound Formatting
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق الليرة السورية - أرقام كاملة بدون كسور
  /// مثال: 1,500,000 ل.س
  static String formatSyp(double value, {bool withSymbol = true}) {
    final formatted = _sypFormat.format(value.round());
    return withSymbol ? '$formatted $sypSymbol' : formatted;
  }

  /// تنسيق الليرة السورية بشكل مختصر للمبالغ الكبيرة
  /// مثال: 1.5M ل.س أو 14.5K ل.س
  static String formatSypCompact(double value, {bool withSymbol = true}) {
    String formatted;
    if (value >= 1000000) {
      formatted = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      // استخدام منزلة عشرية واحدة لدقة أفضل
      final kValue = value / 1000;
      // إذا كانت القيمة صحيحة (مثل 15.0)، لا نعرض المنزلة العشرية
      formatted = kValue == kValue.truncate()
          ? '${kValue.toStringAsFixed(0)}K'
          : '${kValue.toStringAsFixed(1)}K';
    } else {
      formatted = value.toStringAsFixed(0);
    }
    return withSymbol ? '$formatted $sypSymbol' : formatted;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // US Dollar Formatting
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق الدولار - منزلتين عشريتين
  /// مثال: $103.45
  static String formatUsd(double value, {bool withSymbol = true}) {
    return withSymbol ? _usdFormat.format(value) : value.toStringAsFixed(2);
  }

  /// تنسيق الدولار بشكل مختصر
  /// مثال: $1.5M أو $150K
  static String formatUsdCompact(double value, {bool withSymbol = true}) {
    String formatted;
    if (value >= 1000000) {
      formatted = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      formatted = '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      formatted = value.toStringAsFixed(2);
    }
    return withSymbol ? '$usdSymbol$formatted' : formatted;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Generic Number Formatting
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق رقم بفواصل الآلاف (بدون رمز عملة)
  static String formatNumber(double value, {int decimals = 0}) {
    if (decimals == 0) {
      return _sypFormat.format(value.round());
    }
    return NumberFormat.decimalPatternDigits(
      locale: 'ar',
      decimalDigits: decimals,
    ).format(value);
  }

  /// تنسيق كمية (عدد صحيح)
  static String formatQuantity(int value) {
    return _sypFormat.format(value);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Dual Currency Display (للفواتير والإيصالات)
  // ═══════════════════════════════════════════════════════════════════════════

  /// عرض المبلغ بالعملتين
  /// مثال: 1,500,000 ل.س ($103.45)
  static String formatDual({
    required double syp,
    required double usd,
    bool sypFirst = true,
  }) {
    final sypFormatted = formatSyp(syp);
    final usdFormatted = formatUsd(usd);

    return sypFirst
        ? '$sypFormatted ($usdFormatted)'
        : '$usdFormatted ($sypFormatted)';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Percentage Formatting
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق النسبة المئوية
  /// مثال: 15.5%
  static String formatPercent(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Exchange Rate Display
  // ═══════════════════════════════════════════════════════════════════════════

  /// عرض سعر الصرف
  /// مثال: 1$ = 14,500 ل.س
  static String formatExchangeRate(double rate) {
    return '1$usdSymbol = ${formatSyp(rate)}';
  }
}
