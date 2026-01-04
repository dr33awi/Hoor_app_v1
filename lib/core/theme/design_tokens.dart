// ═══════════════════════════════════════════════════════════════════════════
// Hoor Manager Enterprise - Design System 2026
// Professional Accounting & ERP Interface
// ═══════════════════════════════════════════════════════════════════════════
//
// Design Language: Enterprise Accounting
// - High-density layouts optimized for data-heavy screens
// - Neutral, calming color palette for extended use
// - Sharp, professional corners (6-12px radius)
// - Subtle neutral shadows for depth without distraction
// - Maximum readability for numbers and financial data
// - Formal, trustworthy personality
//
// Target Experience:
// - Serious, reliable software you can trust with your finances
// - Reduced eye strain for 8+ hour workdays
// - Professional appearance suitable for business environments
// - Clear data hierarchy with focus on numbers
//
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════
// COLOR PALETTE - Enterprise Accounting (Neutral & Professional)
// ═══════════════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────────────────────────────
  // Primary Colors - Deep Slate (Professional & Trustworthy)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color primary = Color(0xFF1E293B); // Slate 800 - Main brand
  static const Color primaryLight = Color(0xFF334155); // Slate 700
  static const Color primarySoft = Color(0xFF475569); // Slate 600
  static const Color primaryMuted = Color(0xFF64748B); // Slate 500

  // ─────────────────────────────────────────────────────────────────────────
  // Secondary Colors - Steel Blue (Action & Focus)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color secondary = Color(0xFF2563EB); // Blue 600 - Clear action
  static const Color secondaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color secondaryDark = Color(0xFF1D4ED8); // Blue 700
  static const Color secondaryMuted = Color(0xFFDBEAFE); // Blue 100

  // ─────────────────────────────────────────────────────────────────────────
  // Accent Colors - Subtle Teal (Highlights without distraction)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color accent = Color(0xFF0D9488); // Teal 600 - Subtle accent
  static const Color accentLight = Color(0xFF14B8A6); // Teal 500
  static const Color accentMuted = Color(0xFFCCFBF1); // Teal 100

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic Colors - Financial Context (Clear & Functional)
  // ─────────────────────────────────────────────────────────────────────────

  /// Income / Profit / Success - Forest Green (Professional)
  static const Color income =
      Color(0xFF15803D); // Green 700 - Darker for formality
  static const Color incomeLight = Color(0xFFDCFCE7); // Green 100
  static const Color incomeDark = Color(0xFF166534); // Green 800
  static const Color incomeSurface = Color(0xFFF0FDF4); // Green 50

  /// Expense / Loss / Error - Crimson Red (Clear warning)
  static const Color expense = Color(0xFFDC2626); // Red 600
  static const Color expenseLight = Color(0xFFFEE2E2); // Red 100
  static const Color expenseDark = Color(0xFFB91C1C); // Red 700
  static const Color expenseSurface = Color(0xFFFEF2F2); // Red 50

  // Aliases for common naming conventions
  static const Color success = income;
  static const Color successLight = incomeLight;
  static const Color error = expense;
  static const Color errorLight = expenseLight;

  /// Warning - Amber (Attention without alarm)
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningLight = Color(0xFFFEF3C7); // Amber 100
  static const Color warningSurface = Color(0xFFFFFBEB); // Amber 50

  /// Info - Slate Blue (Informational)
  static const Color info = Color(0xFF2563EB); // Blue 600
  static const Color infoLight = Color(0xFFDBEAFE); // Blue 100
  static const Color infoSurface = Color(0xFFEFF6FF); // Blue 50

  /// Neutral - Cool Gray (Data & secondary)
  static const Color neutral = Color(0xFF6B7280); // Gray 500
  static const Color neutralLight = Color(0xFFE5E7EB); // Gray 200
  static const Color neutralSurface = Color(0xFFF9FAFB); // Gray 50

  // ─────────────────────────────────────────────────────────────────────────
  // Business-Specific Colors (Muted Professional Palette)
  // ─────────────────────────────────────────────────────────────────────────

  /// Sales - Professional Blue
  static const Color sales = Color(0xFF2563EB); // Blue 600
  static const Color salesLight = Color(0xFFDBEAFE); // Blue 100

  /// Purchases - Deep Purple (Muted)
  static const Color purchases = Color(0xFF7C3AED); // Violet 600
  static const Color purchasesLight = Color(0xFFEDE9FE); // Violet 100

  /// Inventory - Teal
  static const Color inventory = Color(0xFF0D9488); // Teal 600
  static const Color inventoryLight = Color(0xFFCCFBF1); // Teal 100

  /// Customers - Slate Blue
  static const Color customers = Color(0xFF3B82F6); // Blue 500
  static const Color customersLight = Color(0xFFDBEAFE); // Blue 100

  /// Suppliers - Warm Gray
  static const Color suppliers = Color(0xFF78716C); // Stone 500
  static const Color suppliersLight = Color(0xFFF5F5F4); // Stone 100

  /// Cash - Forest Green
  static const Color cash = Color(0xFF15803D); // Green 700
  static const Color cashLight = Color(0xFFDCFCE7); // Green 100

  // ─────────────────────────────────────────────────────────────────────────
  // Surface & Background Colors (Paper-like, Easy on Eyes)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color background = Color(0xFFF8FAFC); // Slate 50 - Paper white
  static const Color backgroundSecondary = Color(0xFFF1F5F9); // Slate 100
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceHover = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceVariant =
      Color(0xFFF1F5F9); // Neutral tint (no brand color)

  // ─────────────────────────────────────────────────────────────────────────
  // Text Colors (Optimized for extended reading)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color textPrimary =
      Color(0xFF1E293B); // Slate 800 - Not pure black
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textDisabled = Color(0xFFCBD5E1); // Slate 300
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF2563EB); // Blue 600 - Standard link

  // ─────────────────────────────────────────────────────────────────────────
  // Border & Divider Colors (Subtle definition)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderFocused =
      Color(0xFF2563EB); // Blue 600 - Clear focus
  static const Color divider = Color(0xFFE2E8F0); // Slate 200

  // ─────────────────────────────────────────────────────────────────────────
  // Gradient Presets (Professional & Subtle)
  // ─────────────────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF15803D), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Professional header gradient
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Subtle overlay gradient
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x08FFFFFF), Color(0x04FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Dark Theme Colors (Deep Slate - Professional Dark Mode)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceElevated = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF475569); // Slate 600
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
}

// ═══════════════════════════════════════════════════════════════════════════
// SPACING SYSTEM - Compact 4/8-point grid for data-dense interfaces
// ═══════════════════════════════════════════════════════════════════════════

class AppSpacing {
  AppSpacing._();

  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 6.0; // Reduced from 8
  static const double sm = 10.0; // Reduced from 12
  static const double md = 14.0; // Reduced from 16
  static const double lg = 18.0; // Reduced from 20
  static const double xl = 22.0; // Reduced from 24
  static const double xxl = 28.0; // Reduced from 32
  static const double xxxl = 36.0; // Reduced from 40
  static const double huge = 44.0; // Reduced from 48
  static const double massive = 56.0; // Reduced from 64

  // Semantic spacing (tighter for enterprise feel)
  static const double cardPadding = 14.0; // Reduced from 18
  static const double screenPadding = 16.0; // Reduced from 20
  static const double sectionGap = 20.0; // Reduced from 28
  static const double listItemGap = 10.0; // Reduced from 14
  static const double buttonPadding = 14.0; // Reduced from 18
  static const double inputPadding = 12.0; // Reduced from 16
}

// ═══════════════════════════════════════════════════════════════════════════
// RADIUS SYSTEM (Sharper, more professional)
// ═══════════════════════════════════════════════════════════════════════════

class AppRadius {
  AppRadius._();

  static const double none = 0.0;
  static const double xs = 2.0; // Reduced from 4
  static const double sm = 4.0; // Reduced from 8
  static const double md = 6.0; // Reduced from 12
  static const double lg = 8.0; // Reduced from 16
  static const double xl = 10.0; // Reduced from 20
  static const double xxl = 12.0; // Reduced from 24
  static const double xxxl = 16.0; // Reduced from 28
  static const double full = 999.0;

  // Component-specific (Professional sharp corners)
  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get cardLarge => BorderRadius.circular(xl);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get buttonPill => BorderRadius.circular(full);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get chip => BorderRadius.circular(sm); // Sharper chips
  static BorderRadius get sheet =>
      const BorderRadius.vertical(top: Radius.circular(16)); // Less rounded
  static BorderRadius get dialog => BorderRadius.circular(xl);
  static BorderRadius get avatar => BorderRadius.circular(full);

  // Professional card variants
  static BorderRadius get cardSmooth => BorderRadius.circular(lg);
  static BorderRadius get badge => BorderRadius.circular(xs);
}

// ═══════════════════════════════════════════════════════════════════════════
// SHADOW SYSTEM (Neutral professional shadows - no colored tints)
// ═══════════════════════════════════════════════════════════════════════════

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get none => [];

  static List<BoxShadow> get xs => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: -1,
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  /// Colored shadow for accent elements (subdued)
  static List<BoxShadow> colored(Color color, {double opacity = 0.15}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  /// Glow effect for highlighted elements (subtle)
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.20),
          blurRadius: 16,
          spreadRadius: -4,
        ),
      ];

  /// Card shadow - Clean neutral elevation
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  /// Floating action button shadow (Subtle)
  static List<BoxShadow> get fab => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  /// Clean elevation shadow for elevated cards
  static List<BoxShadow> get glass => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: -1,
        ),
      ];
}

// ═══════════════════════════════════════════════════════════════════════════
// TYPOGRAPHY SYSTEM - Professional & Readable
// ═══════════════════════════════════════════════════════════════════════════

class AppTypography {
  AppTypography._();

  // Base font family - IBM Plex Sans Arabic for professional look
  // Falls back to Cairo for better Arabic support
  static TextStyle get _baseStyle => GoogleFonts.ibmPlexSansArabic(
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  // Monospace for numbers - Tabular figures for accounting
  static TextStyle get _monoStyle => GoogleFonts.ibmPlexMono(
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Display Styles - Hero sections (slightly smaller for enterprise)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle get displayLarge => _baseStyle.copyWith(
        fontSize: 42.sp, // Reduced from 48
        fontWeight: FontWeight.w600, // Less bold
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get displayMedium => _baseStyle.copyWith(
        fontSize: 36.sp, // Reduced from 40
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
      );

  static TextStyle get displaySmall => _baseStyle.copyWith(
        fontSize: 28.sp, // Reduced from 32
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.2,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Headline Styles - Page titles (Tighter)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle get headlineLarge => _baseStyle.copyWith(
        fontSize: 24.sp, // Reduced from 28
        fontWeight: FontWeight.w600, // Less bold
        height: 1.3,
      );

  static TextStyle get headlineMedium => _baseStyle.copyWith(
        fontSize: 20.sp, // Reduced from 24
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headlineSmall => _baseStyle.copyWith(
        fontSize: 18.sp, // Reduced from 20
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Title Styles - Cards & sections
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle get titleLarge => _baseStyle.copyWith(
        fontSize: 16.sp, // Reduced from 18
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleMedium => _baseStyle.copyWith(
        fontSize: 14.sp, // Reduced from 16
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleSmall => _baseStyle.copyWith(
        fontSize: 13.sp, // Reduced from 14
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Body Styles - General content (Optimized for data)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 14.sp, // Reduced from 16
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 13.sp, // Reduced from 14
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Label Styles - Buttons & inputs
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle get labelLarge => _baseStyle.copyWith(
        fontSize: 14.sp, // Reduced from 16
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get labelMedium => _baseStyle.copyWith(
        fontSize: 13.sp, // Reduced from 14
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get labelSmall => _baseStyle.copyWith(
        fontSize: 11.sp, // Reduced from 12
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Money Styles - Financial amounts (Tabular Monospace)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle get moneyLarge => _monoStyle.copyWith(
        fontSize: 24.sp, // Reduced from 28
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0,
      );

  static TextStyle get moneyMedium => _monoStyle.copyWith(
        fontSize: 18.sp, // Reduced from 20
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get moneySmall => _monoStyle.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Caption & Overline
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle get caption => _baseStyle.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: AppColors.textTertiary,
      );

  static TextStyle get overline => _baseStyle.copyWith(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 1.0,
        color: AppColors.textTertiary,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// ICON SIZES
// ═══════════════════════════════════════════════════════════════════════════

class AppIconSize {
  AppIconSize._();

  static const double xxs = 12.0;
  static const double xs = 14.0;
  static const double sm = 18.0;
  static const double md = 22.0;
  static const double lg = 26.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double huge = 56.0;
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATION DURATIONS
// ═══════════════════════════════════════════════════════════════════════════

class AppDurations {
  AppDurations._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 350); // Alias
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);
  static const Duration slowest = Duration(milliseconds: 800);
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATION CURVES
// ═══════════════════════════════════════════════════════════════════════════

class AppCurves {
  AppCurves._();

  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.easeOutBack;
  static const Curve easeOut = Curves.easeOut; // Alias
  static const Curve easeIn = Curves.easeIn; // Alias
}

// ═══════════════════════════════════════════════════════════════════════════
// BREAKPOINTS
// ═══════════════════════════════════════════════════════════════════════════

class AppBreakpoints {
  AppBreakpoints._();

  static const double compact = 600; // Mobile
  static const double medium = 840; // Tablet
  static const double expanded = 1200; // Desktop
  static const double large = 1600; // Large desktop

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isMedium(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= compact &&
      MediaQuery.sizeOf(context).width < medium;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium &&
      MediaQuery.sizeOf(context).width < expanded;

  static bool isLarge(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;
}

// ═══════════════════════════════════════════════════════════════════════════
// COLOR EXTENSIONS - Common opacity patterns
// ═══════════════════════════════════════════════════════════════════════════

/// Extension on Color for common opacity variations
/// Replaces repetitive .withOpacity() calls with semantic names
extension ColorOpacity on Color {
  // ─────────────────────────────────────────────────────────────────────────
  // Surface/Background variants (light overlays)
  // ─────────────────────────────────────────────────────────────────────────

  /// Very subtle background (5% opacity) - hover states
  Color get subtle => withValues(alpha: 0.05);

  /// Soft background (10% opacity) - card backgrounds, badges
  Color get soft => withValues(alpha: 0.10);

  /// Muted background (15% opacity) - selected states
  Color get muted => withValues(alpha: 0.15);

  /// Light background (20% opacity) - emphasized backgrounds
  Color get light => withValues(alpha: 0.20);

  // ─────────────────────────────────────────────────────────────────────────
  // Border variants
  // ─────────────────────────────────────────────────────────────────────────

  /// Subtle border (20% opacity)
  Color get borderSubtle => withValues(alpha: 0.20);

  /// Normal border (30% opacity)
  Color get border => withValues(alpha: 0.30);

  /// Strong border (50% opacity)
  Color get borderStrong => withValues(alpha: 0.50);

  // ─────────────────────────────────────────────────────────────────────────
  // Overlay variants
  // ─────────────────────────────────────────────────────────────────────────

  /// Light overlay (40% opacity)
  Color get overlayLight => withValues(alpha: 0.40);

  /// Medium overlay (60% opacity) - backdrop
  Color get overlay => withValues(alpha: 0.60);

  /// Heavy overlay (80% opacity) - strong backdrop
  Color get overlayHeavy => withValues(alpha: 0.80);

  // ─────────────────────────────────────────────────────────────────────────
  // Text variants
  // ─────────────────────────────────────────────────────────────────────────

  /// Disabled text (40% opacity)
  Color get textDisabled => withValues(alpha: 0.40);

  /// Secondary text (60% opacity)
  Color get textSecondary => withValues(alpha: 0.60);

  /// Primary text (87% opacity) - Material standard
  Color get textPrimary => withValues(alpha: 0.87);

  // ─────────────────────────────────────────────────────────────────────────
  // Specific opacity levels
  // ─────────────────────────────────────────────────────────────────────────

  /// 8% opacity - very subtle
  Color get o8 => withValues(alpha: 0.08);

  /// 12% opacity
  Color get o12 => withValues(alpha: 0.12);

  /// 24% opacity
  Color get o24 => withValues(alpha: 0.24);

  /// 38% opacity - disabled
  Color get o38 => withValues(alpha: 0.38);

  /// 54% opacity - medium emphasis
  Color get o54 => withValues(alpha: 0.54);

  /// 70% opacity
  Color get o70 => withValues(alpha: 0.70);

  /// 87% opacity - high emphasis
  Color get o87 => withValues(alpha: 0.87);
}

// ═══════════════════════════════════════════════════════════════════════════
// APP COLOR UTILITIES - Pre-computed semantic colors
// ═══════════════════════════════════════════════════════════════════════════

/// Utility class for common color combinations
class AppColorUtils {
  AppColorUtils._();

  // ─────────────────────────────────────────────────────────────────────────
  // Primary variants
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary color with soft background
  static Color get primarySoft => AppColors.primary.soft;
  static Color get primaryMuted => AppColors.primary.muted;
  static Color get primaryBorder => AppColors.primary.border;

  // ─────────────────────────────────────────────────────────────────────────
  // Secondary variants
  // ─────────────────────────────────────────────────────────────────────────

  static Color get secondarySoft => AppColors.secondary.soft;
  static Color get secondaryMuted => AppColors.secondary.muted;
  static Color get secondaryBorder => AppColors.secondary.border;

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic variants
  // ─────────────────────────────────────────────────────────────────────────

  static Color get successSoft => AppColors.success.soft;
  static Color get errorSoft => AppColors.error.soft;
  static Color get warningSoft => AppColors.warning.soft;
  static Color get infoSoft => AppColors.info.soft;

  static Color get successBorder => AppColors.success.border;
  static Color get errorBorder => AppColors.error.border;
  static Color get warningBorder => AppColors.warning.border;
  static Color get infoBorder => AppColors.info.border;

  // ─────────────────────────────────────────────────────────────────────────
  // Business domain variants
  // ─────────────────────────────────────────────────────────────────────────

  static Color get salesSoft => AppColors.sales.soft;
  static Color get purchasesSoft => AppColors.purchases.soft;
  static Color get inventorySoft => AppColors.inventory.soft;
  static Color get customersSoft => AppColors.customers.soft;
  static Color get suppliersSoft => AppColors.suppliers.soft;
  static Color get incomeSoft => AppColors.income.soft;
  static Color get expenseSoft => AppColors.expense.soft;
  static Color get cashSoft => AppColors.cash.soft;

  // ─────────────────────────────────────────────────────────────────────────
  // Common overlays
  // ─────────────────────────────────────────────────────────────────────────

  static Color get blackOverlay => Colors.black.overlay;
  static Color get whiteOverlay => Colors.white.overlayHeavy;
  static Color get scrim => Colors.black.o54;
}

// ═══════════════════════════════════════════════════════════════════════════
// TYPOGRAPHY EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Extension to easily convert any text style to monospace
/// Replaces repetitive .copyWith(fontFamily: 'JetBrains Mono') calls
extension MonoTypography on TextStyle {
  /// Convert this style to use JetBrains Mono for numbers/codes
  TextStyle get mono => copyWith(fontFamily: 'JetBrains Mono');

  /// Convert with bold weight for emphasis
  TextStyle get monoBold => copyWith(
        fontFamily: 'JetBrains Mono',
        fontWeight: FontWeight.bold,
      );

  /// Convert with semi-bold weight
  TextStyle get monoSemibold => copyWith(
        fontFamily: 'JetBrains Mono',
        fontWeight: FontWeight.w600,
      );
}
