// ═══════════════════════════════════════════════════════════════════════════
// Pro Snackbar - Unified Snackbar Utility
// Consistent snackbars across all screens
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/design_tokens.dart';

/// مدة عرض Snackbar
enum ProSnackbarDuration {
  /// قصيرة (2 ثانية)
  short,

  /// متوسطة (4 ثواني)
  medium,

  /// طويلة (8 ثواني)
  long,
}

/// فئة مساعدة لعرض Snackbars موحدة
class ProSnackbar {
  ProSnackbar._();

  static Duration _getDuration(ProSnackbarDuration duration) {
    switch (duration) {
      case ProSnackbarDuration.short:
        return const Duration(seconds: 2);
      case ProSnackbarDuration.medium:
        return const Duration(seconds: 4);
      case ProSnackbarDuration.long:
        return const Duration(seconds: 8);
    }
  }

  /// عرض Snackbar عام
  static void show({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    ProSnackbarDuration duration = ProSnackbarDuration.medium,
    bool showCloseIcon = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor ?? Colors.white, size: 20.sp),
            SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: textColor ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? AppColors.textPrimary,
      duration: _getDuration(duration),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      margin: EdgeInsets.all(AppSpacing.md),
      showCloseIcon: showCloseIcon,
      closeIconColor: textColor ?? Colors.white,
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: textColor ?? Colors.white,
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// رسالة نجاح
  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    ProSnackbarDuration duration = ProSnackbarDuration.medium,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// رسالة خطأ
  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    ProSnackbarDuration duration = ProSnackbarDuration.medium,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// رسالة تحذير
  static void warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    ProSnackbarDuration duration = ProSnackbarDuration.medium,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: AppColors.warning,
      textColor: AppColors.textPrimary,
      icon: Icons.warning_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// رسالة معلومات
  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    ProSnackbarDuration duration = ProSnackbarDuration.medium,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// رسالة تحميل (مع إمكانية الإلغاء)
  static void loading(
    BuildContext context,
    String message, {
    VoidCallback? onCancel,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 20.sp,
            height: 20.sp,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
      duration: const Duration(days: 1), // Infinite until hidden
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      margin: EdgeInsets.all(AppSpacing.md),
      action: onCancel != null
          ? SnackBarAction(
              label: 'إلغاء',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                onCancel();
              },
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// إخفاء Snackbar الحالي
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// رسالة تم النسخ
  static void copied(BuildContext context, [String? itemName]) {
    success(
      context,
      itemName != null ? 'تم نسخ $itemName' : 'تم النسخ',
      duration: ProSnackbarDuration.short,
    );
  }

  /// رسالة تم الحفظ
  static void saved(BuildContext context, [String? itemName]) {
    success(
      context,
      itemName != null ? 'تم حفظ $itemName' : 'تم الحفظ بنجاح',
    );
  }

  /// رسالة تم الحذف
  static void deleted(BuildContext context, [String? itemName]) {
    success(
      context,
      itemName != null ? 'تم حذف $itemName' : 'تم الحذف بنجاح',
    );
  }

  /// رسالة تم الإرسال
  static void sent(BuildContext context, [String? itemName]) {
    success(
      context,
      itemName != null ? 'تم إرسال $itemName' : 'تم الإرسال بنجاح',
    );
  }

  /// رسالة خطأ في الاتصال
  static void connectionError(BuildContext context, {VoidCallback? onRetry}) {
    error(
      context,
      'تعذر الاتصال بالخادم',
      actionLabel: onRetry != null ? 'إعادة المحاولة' : null,
      onAction: onRetry,
    );
  }

  /// رسالة خطأ عام
  static void showError(BuildContext context, dynamic error) {
    ProSnackbar.error(
      context,
      error.toString().replaceAll('Exception: ', ''),
    );
  }

  /// رسالة مع تراجع (undo)
  static void withUndo(
    BuildContext context,
    String message,
    VoidCallback onUndo,
  ) {
    show(
      context: context,
      message: message,
      backgroundColor: AppColors.textPrimary,
      actionLabel: 'تراجع',
      onAction: onUndo,
      duration: ProSnackbarDuration.long,
    );
  }
}
