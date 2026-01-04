// ═══════════════════════════════════════════════════════════════════════════
// Hoor Manager Enterprise - App Theme Configuration
// Professional Accounting & ERP Interface - Material 3
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME - Enterprise Accounting
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,

      // ─────────────────────────────────────────────────────────────────────
      // Color Scheme - Professional Slate/Blue palette
      // ─────────────────────────────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.surfaceMuted,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnSecondary,
        secondaryContainer: AppColors.secondaryMuted,
        onSecondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.accent,
        onTertiary: AppColors.textOnPrimary,
        tertiaryContainer: AppColors.accentMuted,
        onTertiaryContainer: AppColors.accent,
        error: AppColors.expense,
        onError: Colors.white,
        errorContainer: AppColors.expenseLight,
        onErrorContainer: AppColors.expenseDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceMuted,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
        shadow: Colors.black,
        scrim: Colors.black,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Scaffold
      // ─────────────────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.background,

      // ─────────────────────────────────────────────────────────────────────
      // AppBar Theme - Clean Professional Header
      // ─────────────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppIconSize.md,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: AppIconSize.md,
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Card Theme - Clean Professional Cards
      // ─────────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Elevated Button Theme - Primary Actions (Compact)
      // ─────────────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnSecondary,
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg.w,
            vertical: AppSpacing.sm.h,
          ),
          minimumSize: Size(80.w, 44.h), // Smaller buttons
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            if (states.contains(WidgetState.hovered)) return 2;
            return 1;
          }),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Filled Button Theme (Primary action - Compact)
      // ─────────────────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnSecondary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg.w,
            vertical: AppSpacing.sm.h,
          ),
          minimumSize: Size(80.w, 44.h),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Outlined Button Theme - Secondary Actions
      // ─────────────────────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg.w,
            vertical: AppSpacing.sm.h,
          ),
          minimumSize: Size(80.w, 44.h),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          side: const BorderSide(color: AppColors.border, width: 1),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Text Button Theme - Tertiary Actions
      // ─────────────────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xs.h,
          ),
          textStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Floating Action Button Theme - Professional
      // ─────────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnSecondary,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        extendedTextStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.textOnSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Input Decoration Theme - Clean Professional Inputs
      // ─────────────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm.w,
          vertical: AppSpacing.sm.h,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.expense, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.expense, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
              color: AppColors.border.withValues(alpha: 0.5), width: 1),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.expense,
        ),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
        floatingLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Chip Theme - Compact Professional Pills
      // ─────────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.secondaryMuted,
        disabledColor: AppColors.surfaceMuted,
        labelStyle: AppTypography.labelSmall,
        secondaryLabelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.secondary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm.w,
          vertical: AppSpacing.xxs.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chip,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        side: const BorderSide(color: AppColors.border, width: 1),
        elevation: 0,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Bottom Navigation Bar Theme - Professional
      // ─────────────────────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Navigation Bar Theme (Material 3) - Professional
      // ─────────────────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.secondaryMuted,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64.h, // Compact
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: AppIconSize.sm,
            );
          }
          return const IconThemeData(
            color: AppColors.textTertiary,
            size: AppIconSize.sm,
          );
        }),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Navigation Rail Theme - Professional Sidebar
      // ─────────────────────────────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.secondaryMuted,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primary,
          size: AppIconSize.sm,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textTertiary,
          size: AppIconSize.sm,
        ),
        selectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textTertiary,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Tab Bar Theme - Clean Underlined
      // ─────────────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelMedium,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.secondary,
            width: 2.w,
          ),
          borderRadius: BorderRadius.circular(1),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
        overlayColor: WidgetStateProperty.all(AppColors.surfaceMuted),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Dialog Theme - Clean Professional
      // ─────────────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog,
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Bottom Sheet Theme - Professional
      // ─────────────────────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.sheet,
        ),
        dragHandleColor: AppColors.border,
        dragHandleSize: Size(40.w, 4.h),
        showDragHandle: true,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Snackbar Theme - Professional Toast
      // ─────────────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        actionTextColor: AppColors.accentLight,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // List Tile Theme - Compact Professional
      // ─────────────────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm.w,
          vertical: AppSpacing.xs.h,
        ),
        minVerticalPadding: AppSpacing.xs.h,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        titleTextStyle: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        leadingAndTrailingTextStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        iconColor: AppColors.textSecondary,
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.secondaryMuted,
        dense: false,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Divider Theme - Subtle
      // ─────────────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: AppSpacing.lg.h,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Progress Indicator Theme - Brand Colored
      // ─────────────────────────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
        linearTrackColor: AppColors.secondaryMuted,
        circularTrackColor: AppColors.secondaryMuted,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Switch Theme - Modern Toggle
      // ─────────────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.textOnSecondary;
          }
          return AppColors.surfaceMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary;
          }
          return AppColors.neutralLight;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        thumbIcon: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Icon(Icons.check,
                size: 14, color: AppColors.secondary);
          }
          return null;
        }),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Checkbox Theme - Modern Rounded
      // ─────────────────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnSecondary),
        side: BorderSide(color: AppColors.border, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs + 2),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Radio Theme - Modern
      // ─────────────────────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary;
          }
          return AppColors.textTertiary;
        }),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Tooltip Theme - Modern Dark
      // ─────────────────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: AppShadows.md,
        ),
        textStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textOnPrimary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Badge Theme - Modern Pill
      // ─────────────────────────────────────────────────────────────────────
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.expense,
        textColor: AppColors.textOnPrimary,
        textStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textOnPrimary,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Search Bar Theme - Clean Modern
      // ─────────────────────────────────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(AppColors.surfaceMuted),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: AppRadius.input,
          ),
        ),
        hintStyle: WidgetStateProperty.all(
          AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
        ),
        textStyle: WidgetStateProperty.all(AppTypography.bodyMedium),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
        ),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Popup Menu Theme - Modern Card
      // ─────────────────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppColors.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.bodyMedium,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Date Picker Theme - Modern Dashboard
      // ─────────────────────────────────────────────────────────────────────
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.secondary,
        headerForegroundColor: AppColors.textOnSecondary,
        dayStyle: AppTypography.bodyMedium,
        yearStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary;
          }
          return null;
        }),
        todayBackgroundColor: WidgetStateProperty.all(AppColors.secondaryMuted),
        todayForegroundColor: WidgetStateProperty.all(AppColors.secondary),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Time Picker Theme - Modern
      // ─────────────────────────────────────────────────────────────────────
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.surface,
        hourMinuteColor: AppColors.surfaceMuted,
        hourMinuteTextColor: AppColors.textPrimary,
        dialHandColor: AppColors.secondary,
        dialBackgroundColor: AppColors.surfaceMuted,
        entryModeIconColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Slider Theme - Modern
      // ─────────────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.secondary,
        inactiveTrackColor: AppColors.secondaryMuted,
        thumbColor: AppColors.secondary,
        overlayColor: AppColors.secondary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Extensions
      // ─────────────────────────────────────────────────────────────────────
      extensions: const [
        AppThemeExtension.light,
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME - Modern SaaS Dashboard Dark Mode
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get dark {
    return light.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.secondaryLight,
        onPrimary: AppColors.darkBackground,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.expense,
        onError: Colors.white,
        outline: AppColors.darkBorder,
        surfaceContainerHighest: AppColors.darkSurfaceElevated,
      ),
      appBarTheme: light.appBarTheme.copyWith(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        shadowColor: Colors.black26,
      ),
      cardTheme: light.cardTheme.copyWith(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(
              color: AppColors.darkBorder.withValues(alpha: 0.5), width: 1),
        ),
      ),
      bottomSheetTheme: light.bottomSheetTheme.copyWith(
        backgroundColor: AppColors.darkSurface,
      ),
      dialogTheme: light.dialogTheme.copyWith(
        backgroundColor: AppColors.darkSurface,
      ),
      inputDecorationTheme: light.inputDecorationTheme.copyWith(
        fillColor: AppColors.darkSurfaceElevated,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide:
              const BorderSide(color: AppColors.secondaryLight, width: 2),
        ),
      ),
      navigationBarTheme: light.navigationBarTheme.copyWith(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.secondaryLight.withValues(alpha: 0.2),
      ),
      dividerTheme: light.dividerTheme.copyWith(
        color: AppColors.darkBorder,
      ),
      popupMenuTheme: light.popupMenuTheme.copyWith(
        color: AppColors.darkSurface,
      ),
      snackBarTheme: light.snackBarTheme.copyWith(
        backgroundColor: AppColors.darkSurfaceElevated,
      ),
      extensions: const [
        AppThemeExtension.dark,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// THEME EXTENSION - Custom theme properties for Financial UI
// ═══════════════════════════════════════════════════════════════════════════

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.income,
    required this.incomeLight,
    required this.expense,
    required this.expenseLight,
    required this.warning,
    required this.warningLight,
    required this.cardShadow,
    required this.glowShadow,
  });

  final Color income;
  final Color incomeLight;
  final Color expense;
  final Color expenseLight;
  final Color warning;
  final Color warningLight;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> glowShadow;

  static const light = AppThemeExtension(
    income: AppColors.income,
    incomeLight: AppColors.incomeLight,
    expense: AppColors.expense,
    expenseLight: AppColors.expenseLight,
    warning: AppColors.warning,
    warningLight: AppColors.warningLight,
    cardShadow: [
      BoxShadow(
        color: Color(0x0F1E1B4B),
        blurRadius: 12,
        offset: Offset(0, 4),
        spreadRadius: -2,
      ),
    ],
    glowShadow: [
      BoxShadow(
        color: Color(0x207C3AED),
        blurRadius: 20,
        spreadRadius: -4,
      ),
    ],
  );

  static const dark = AppThemeExtension(
    income: AppColors.income,
    incomeLight: Color(0xFF064E3B),
    expense: AppColors.expense,
    expenseLight: Color(0xFF881337),
    warning: AppColors.warning,
    warningLight: Color(0xFF78350F),
    cardShadow: [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
    glowShadow: [
      BoxShadow(
        color: Color(0x308B5CF6),
        blurRadius: 24,
        spreadRadius: -4,
      ),
    ],
  );

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? income,
    Color? incomeLight,
    Color? expense,
    Color? expenseLight,
    Color? warning,
    Color? warningLight,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? glowShadow,
  }) {
    return AppThemeExtension(
      income: income ?? this.income,
      incomeLight: incomeLight ?? this.incomeLight,
      expense: expense ?? this.expense,
      expenseLight: expenseLight ?? this.expenseLight,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      cardShadow: cardShadow ?? this.cardShadow,
      glowShadow: glowShadow ?? this.glowShadow,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      income: Color.lerp(income, other.income, t)!,
      incomeLight: Color.lerp(incomeLight, other.incomeLight, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      expenseLight: Color.lerp(expenseLight, other.expenseLight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t)!,
      glowShadow: BoxShadow.lerpList(glowShadow, other.glowShadow, t)!,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// THEME HELPERS
// ═══════════════════════════════════════════════════════════════════════════

extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  AppThemeExtension get appColors => theme.extension<AppThemeExtension>()!;

  bool get isDarkMode => theme.brightness == Brightness.dark;
}
