// lib/core/theme/app_theme.dart
// 🎨 ثيم موحد للتطبيق - بسيط وسهل التطوير

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎨 ألوان التطبيق الموحدة
class AppColors {
  AppColors._();

  // ==================== الألوان الأساسية ====================
  /// اللون الأساسي (أزرق داكن)
  static const Color primary = Color(0xFF12334E);

  /// اللون الثانوي (بيج/كريمي)
  static const Color secondary = Color(0xFFE9DAC1);

  // ==================== ألوان مشتقة من الأساسي ====================
  /// أغمق من الأساسي - للضغط والتأثيرات
  static const Color primaryDark = Color(0xFF0A1F30);

  // ==================== ألوان مشتقة من الثانوي ====================
  /// أفتح من الثانوي - للخلفيات
  static const Color secondaryLight = Color(0xFFF5EDE0);

  // ==================== ألوان الخلفية والسطح ====================
  /// خلفية التطبيق الرئيسية
  static const Color background = Color(0xFFFAF8F5);

  /// لون السطح (البطاقات والحوارات)
  static const Color surface = Colors.white;

  /// لون الفواصل والحدود
  static const Color border = Color(0xFFE0DDD8);

  // ==================== ألوان النص ====================
  /// نص أساسي (عناوين)
  static const Color textPrimary = Color(0xFF12334E);

  /// نص ثانوي (وصف)
  static const Color textSecondary = Color(0xFF5A6978);

  /// نص خافت (تلميحات)
  static const Color textHint = Color(0xFF9CA3AB);

  /// نص على الخلفية الأساسية
  static const Color textOnPrimary = Colors.white;

  /// نص على الخلفية الثانوية
  static const Color textOnSecondary = Color(0xFF12334E);

  // ==================== ألوان الحالات ====================
  /// نجاح (أخضر)
  static const Color success = Color(0xFF10B981);

  /// خطأ (أحمر)
  static const Color error = Color(0xFFEF4444);

  /// تحذير (برتقالي)
  static const Color warning = Color(0xFFD97706);

  /// معلومات (أزرق)
  static const Color info = Color(0xFF3B82F6);

  // ==================== ألوان مساعدة ====================
  /// للأيقونات الخافتة
  static const Color iconLight = Color(0xFF8A9299);

  /// بنفسجي (للفئات والتصنيفات)
  static const Color purple = Color(0xFF8B5CF6);

  /// خلفية بنفسجية فاتحة
  static const Color purpleLight = Color(0xFFEDE9FE);

  /// أحمر Google
  static const Color google = Color(0xFFEA4335);

  /// أزرق سماوي (للروابط والمعلومات)
  static const Color skyBlue = Color(0xFF0369A1);

  /// خلفية سماوية فاتحة
  static const Color skyBlueLight = Color(0xFFF0F9FF);

  /// خلفية خطأ فاتحة
  static const Color errorLight = Color(0xFFFEE2E2);

  /// خلفية تحذير فاتحة
  static const Color warningLight = Color(0xFFFEF3C7);

  /// رمادي داكن (للنصوص)
  static const Color gray600 = Color(0xFF4B5563);

  /// رمادي فاتح (للنصوص)
  static const Color gray700 = Color(0xFF374151);

  /// خلفية الحقول
  static const Color inputFill = Color(0xFFF9FAFB);

  /// خلفية الحقول البديلة
  static const Color inputFillAlt = Color(0xFFF3F4F6);

  /// خلفية الشاشات
  static const Color scaffoldBg = Color(0xFFFAFAFA);

  // ==================== ألوان المنتجات ====================
  /// بيج
  static const Color beige = Color(0xFFF5F5DC);

  /// كحلي
  static const Color navy = Color(0xFF000080);

  /// عنابي
  static const Color burgundy = Color(0xFF800020);
}

/// 🎨 ثيم التطبيق الموحد
class AppTheme {
  AppTheme._();

  // ==================== أنصاف الأقطار ====================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // ==================== المسافات ====================
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // ==================== الظلال ====================
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ==================== الثيم الرئيسي ====================
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // الألوان
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnSecondary,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,

    // === AppBar ===
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      ),
      iconTheme: IconThemeData(color: AppColors.textOnPrimary),
    ),

    // === Card ===
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.all(spacingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),

    // === FloatingActionButton ===
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // === Input Decoration ===
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textHint),
      prefixIconColor: AppColors.iconLight,
      suffixIconColor: AppColors.iconLight,
    ),

    // === Elevated Button ===
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: 14),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // === Outlined Button ===
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: 14),
        minimumSize: const Size(88, 48),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // === Text Button ===
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // === Icon Button ===
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.primary),
    ),

    // === Chip ===
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.secondaryLight,
      selectedColor: AppColors.secondary,
      labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      padding: const EdgeInsets.symmetric(
        horizontal: spacingS,
        vertical: spacingXS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXLarge),
      ),
      side: BorderSide.none,
    ),

    // === Bottom Navigation Bar ===
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.iconLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),

    // === Navigation Bar (Material 3) ===
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.secondary,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          );
        }
        return const TextStyle(fontSize: 12, color: AppColors.textSecondary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary);
        }
        return const IconThemeData(color: AppColors.iconLight);
      }),
    ),

    // === Dialog ===
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),

    // === Bottom Sheet ===
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
      ),
    ),

    // === SnackBar ===
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primary,
      contentTextStyle: const TextStyle(color: AppColors.textOnPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
    ),

    // === Divider ===
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // === List Tile ===
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingXS,
      ),
      iconColor: AppColors.iconLight,
      textColor: AppColors.textPrimary,
    ),

    // === Progress Indicator ===
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.secondaryLight,
      circularTrackColor: AppColors.secondaryLight,
    ),

    // === Switch ===
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.iconLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.secondary;
        }
        return AppColors.border;
      }),
    ),

    // === Checkbox ===
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
      side: const BorderSide(color: AppColors.border, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // === Radio ===
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.iconLight;
      }),
    ),

    // === Tab Bar ===
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 14),
    ),

    // === Tooltip ===
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
      textStyle: const TextStyle(color: AppColors.textOnPrimary, fontSize: 12),
    ),

    // === Badge ===
    badgeTheme: const BadgeThemeData(
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    ),

    // === Text Theme ===
    textTheme: const TextTheme(
      // العناوين الكبيرة
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      // العناوين
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      // المحتوى
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      // التسميات
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(fontSize: 10, color: AppColors.textHint),
    ),
  );

  // للتوافق مع الكود القديم
  static ThemeData get lightTheme => theme;
  static ThemeData get darkTheme => theme;

  // ==================== دوال مساعدة ====================

  /// الحصول على لون الحالة
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
      case 'approved':
        return AppColors.success;
      case 'error':
      case 'failed':
      case 'rejected':
      case 'cancelled':
        return AppColors.error;
      case 'warning':
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  /// الحصول على لون خلفية الحالة (شفاف)
  static Color getStatusBackgroundColor(String status) {
    return getStatusColor(status).withValues(alpha: 0.1);
  }
}
