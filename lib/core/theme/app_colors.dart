import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام الألوان للتطبيق
class AppColors {
  AppColors._();

  // الألوان الأساسية
  static const Color primary = Color(0xFF12334e);
  static const Color primaryLight = Color(0xFF1e4a6d);
  static const Color primaryDark = Color(0xFF0a1f30);

  // الألوان الثانوية
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF64B5F6);
  static const Color secondaryDark = Color(0xFF1976D2);

  // ألوان النجاح والخطأ والتحذير
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF29B6F6);
  static const Color infoLight = Color(0xFFE1F5FE);

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;

  // ألوان الخلفية
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;

  // ألوان الحدود
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // ألوان Dark Mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkCardBackground = Color(0xFF252525);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkBorder = Color(0xFF424242);
  static const Color darkDivider = Color(0xFF373737);

  // ألوان الفئات
  static const List<Color> categoryColors = [
    Color(0xFF2196F3), // أزرق
    Color(0xFF4CAF50), // أخضر
    Color(0xFFF44336), // أحمر
    Color(0xFFFF9800), // برتقالي
    Color(0xFF9C27B0), // بنفسجي
    Color(0xFF00BCD4), // سماوي
    Color(0xFFE91E63), // وردي
    Color(0xFF795548), // بني
    Color(0xFF607D8B), // رمادي أزرق
    Color(0xFF3F51B5), // نيلي
  ];

  // ألوان حالات الفواتير
  static const Color invoiceOpen = Color(0xFF2196F3);
  static const Color invoiceClosed = Color(0xFF4CAF50);
  static const Color invoiceCancelled = Color(0xFFE53935);

  // ألوان المخزون
  static const Color stockLow = Color(0xFFE53935);
  static const Color stockMedium = Color(0xFFFFA726);
  static const Color stockGood = Color(0xFF4CAF50);
}

/// نظام الخطوط
class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.4,
      );

  static TextStyle get displayMedium => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.4,
      );

  static TextStyle get displaySmall => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.4,
      );

  static TextStyle get headlineLarge => GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get headlineMedium => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get headlineSmall => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleLarge => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get titleMedium => GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get titleSmall => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get bodyLarge => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // أنماط خاصة
  static TextStyle get priceStyle => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.3,
      );

  static TextStyle get currencyStyle => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  static TextStyle get numberStyle => GoogleFonts.robotoMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );
}

/// المسافات
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Padding
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Padding أفقي
  static const EdgeInsets paddingHorizontalSm =
      EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg =
      EdgeInsets.symmetric(horizontal: lg);

  // Padding عمودي
  static const EdgeInsets paddingVerticalSm =
      EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd =
      EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg =
      EdgeInsets.symmetric(vertical: lg);
}

/// الظلال
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get none => [];

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}

/// الانحناءات
class AppBorderRadius {
  AppBorderRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  static BorderRadius get roundedXs => BorderRadius.circular(xs);
  static BorderRadius get roundedSm => BorderRadius.circular(sm);
  static BorderRadius get roundedMd => BorderRadius.circular(md);
  static BorderRadius get roundedLg => BorderRadius.circular(lg);
  static BorderRadius get roundedXl => BorderRadius.circular(xl);
  static BorderRadius get roundedFull => BorderRadius.circular(full);
}

/// أحجام الأيقونات
class AppIconSize {
  AppIconSize._();

  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double xxl = 64.0;
}

/// مدد الرسوم المتحركة
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
