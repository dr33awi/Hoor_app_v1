// lib/core/services/utilities/notification_service.dart
// 🔔 خدمة الإشعارات المحلية

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// أنواع الإشعارات
enum NotificationType { success, error, warning, info }

/// خدمة إشعارات بسيطة باستخدام SnackBar
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  /// المفتاح العالمي للـ Navigator
  static GlobalKey<NavigatorState>? navigatorKey;

  /// تهيئة الخدمة
  static void initialize(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  /// الحصول على الـ context الحالي
  BuildContext? get _context => navigatorKey?.currentContext;

  /// عرض إشعار
  void show({
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final context = _context;
    if (context == null) return;

    final color = _getColor(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  /// إشعار نجاح
  void success(String message, {String? actionLabel, VoidCallback? onAction}) {
    show(
      message: message,
      type: NotificationType.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// إشعار خطأ
  void error(String message, {String? actionLabel, VoidCallback? onAction}) {
    show(
      message: message,
      type: NotificationType.error,
      duration: const Duration(seconds: 5),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// إشعار تحذير
  void warning(String message, {String? actionLabel, VoidCallback? onAction}) {
    show(
      message: message,
      type: NotificationType.warning,
      duration: const Duration(seconds: 4),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// إشعار معلومات
  void info(String message, {String? actionLabel, VoidCallback? onAction}) {
    show(
      message: message,
      type: NotificationType.info,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  Color _getColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.info:
        return AppColors.info;
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }
}

/// تنبيهات المخزون
class StockAlertService {
  static final StockAlertService _instance = StockAlertService._();
  factory StockAlertService() => _instance;
  StockAlertService._();

  final NotificationService _notification = NotificationService();

  /// الحد الأدنى للمخزون
  int lowStockThreshold = 5;

  /// التحقق من المخزون المنخفض
  void checkLowStock({
    required String productName,
    required int currentQuantity,
    int? customThreshold,
  }) {
    final threshold = customThreshold ?? lowStockThreshold;

    if (currentQuantity == 0) {
      _notification.error(
        'تنبيه: نفد مخزون "$productName"!',
        actionLabel: 'إضافة مخزون',
      );
    } else if (currentQuantity <= threshold) {
      _notification.warning(
        'تحذير: مخزون "$productName" منخفض ($currentQuantity فقط)',
        actionLabel: 'عرض',
      );
    }
  }

  /// تنبيه مخزون متعدد
  void checkMultipleStock(List<Map<String, dynamic>> products) {
    final lowStockProducts = products.where((p) {
      final qty = p['quantity'] as int? ?? 0;
      return qty <= lowStockThreshold;
    }).toList();

    if (lowStockProducts.isEmpty) return;

    if (lowStockProducts.length == 1) {
      final product = lowStockProducts.first;
      checkLowStock(
        productName: product['name'] as String,
        currentQuantity: product['quantity'] as int,
      );
    } else {
      final outOfStock = lowStockProducts
          .where((p) => (p['quantity'] as int) == 0)
          .length;
      final low = lowStockProducts.length - outOfStock;

      String message = '';
      if (outOfStock > 0) message += '$outOfStock منتج نفد مخزونه';
      if (low > 0) {
        if (message.isNotEmpty) message += '، و';
        message += '$low منتج مخزونه منخفض';
      }

      _notification.warning(
        'تنبيه المخزون: $message',
        actionLabel: 'عرض التقرير',
      );
    }
  }
}
