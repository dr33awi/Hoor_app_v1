// ═══════════════════════════════════════════════════════════════════════════
// Unified Alerts Provider - Single Source of Truth for All Alerts
// Enterprise Accounting Alert System
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/currency_service.dart';
import 'app_providers.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Alert Types & Models
// ═══════════════════════════════════════════════════════════════════════════

/// Alert severity levels - ordered by priority
enum AlertSeverity {
  critical, // حرج - أحمر
  warning, // تحذير - برتقالي
  info, // معلومة - أزرق
  success, // نجاح - أخضر
}

/// Unified Alert Item Model
class AlertItem {
  const AlertItem({
    required this.id,
    required this.severity,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.route,
    this.timestamp,
    this.metadata,
  });

  final String id;
  final AlertSeverity severity;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? route;
  final DateTime? timestamp;
  final Map<String, dynamic>? metadata;

  AlertItem copyWith({
    String? id,
    AlertSeverity? severity,
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    String? route,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return AlertItem(
      id: id ?? this.id,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      actionLabel: actionLabel ?? this.actionLabel,
      onAction: onAction ?? this.onAction,
      route: route ?? this.route,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Main Alerts Provider - Single Source of Truth
// ═══════════════════════════════════════════════════════════════════════════

/// Provider for all system alerts (from real database)
final alertsProvider = FutureProvider<List<AlertItem>>((ref) async {
  final List<AlertItem> alerts = [];
  final formatter = NumberFormat('#,##0', 'ar');

  // 1. Check for products with ZERO stock (Critical)
  // استخدام الكميات الفعلية من المستودعات
  try {
    final productData =
        await ref.watch(activeProductsWithDefaultWarehouseStockProvider.future);
    final zeroStockProducts = productData
        .where((item) => (item['quantity'] as int) == 0)
        .map((item) => item['product'])
        .toList();
    if (zeroStockProducts.isNotEmpty) {
      alerts.add(AlertItem(
        id: 'zero_stock',
        severity: AlertSeverity.critical,
        title: 'منتجات نفدت من المخزون',
        message:
            '${zeroStockProducts.length} منتج${zeroStockProducts.length > 1 ? "ات" : ""} بدون مخزون',
        actionLabel: 'عرض المنتجات',
        route: '/products',
        timestamp: DateTime.now(),
        metadata: {
          'count': zeroStockProducts.length,
          'products': zeroStockProducts.map((p) => p.name).toList(),
        },
      ));
    }
  } catch (e) {
    debugPrint('Error checking zero stock: $e');
  }

  // 2. Check for LOW stock products (Warning)
  // استخدام الكميات الفعلية من المستودعات
  try {
    final productData =
        await ref.watch(activeProductsWithDefaultWarehouseStockProvider.future);
    final lowStockProducts = productData
        .where((item) {
          final quantity = item['quantity'] as int;
          final product = item['product'];
          // المخزون أكبر من صفر ولكن أقل من أو يساوي الحد الأدنى
          return quantity > 0 && quantity <= product.minQuantity;
        })
        .map((item) => item['product'])
        .toList();
    if (lowStockProducts.isNotEmpty) {
      alerts.add(AlertItem(
        id: 'low_stock',
        severity: AlertSeverity.warning,
        title: 'منتجات وصلت للحد الأدنى',
        message:
            '${lowStockProducts.length} منتج${lowStockProducts.length > 1 ? "ات" : ""} تحتاج لإعادة طلب',
        actionLabel: 'عرض المنتجات',
        route: '/products',
        timestamp: DateTime.now(),
        metadata: {
          'count': lowStockProducts.length,
          'products': lowStockProducts.map((p) => p.name).toList(),
        },
      ));
    }
  } catch (e) {
    debugPrint('Error checking low stock: $e');
  }

  // 3. Check if no shift is open (Warning)
  try {
    final openShift = await ref.watch(openShiftStreamProvider.future);
    if (openShift == null) {
      alerts.add(AlertItem(
        id: 'no_shift',
        severity: AlertSeverity.warning,
        title: 'لا توجد وردية مفتوحة',
        message: 'افتح وردية جديدة لتسجيل المعاملات',
        actionLabel: 'فتح وردية',
        route: '/shifts',
        timestamp: DateTime.now(),
      ));
    } else {
      // Check for long open shift (more than 12 hours)
      final duration = DateTime.now().difference(openShift.openedAt);
      if (duration.inHours >= 12) {
        alerts.add(AlertItem(
          id: 'long_shift',
          severity: duration.inHours >= 24
              ? AlertSeverity.warning
              : AlertSeverity.info,
          title: 'وردية مفتوحة طويلاً',
          message: 'الوردية مفتوحة منذ ${duration.inHours} ساعة',
          actionLabel: 'إدارة الورديات',
          route: '/shifts',
          timestamp: DateTime.now(),
          metadata: {
            'shiftId': openShift.id,
            'hoursOpen': duration.inHours,
          },
        ));
      }
    }
  } catch (e) {
    debugPrint('Error checking shift: $e');
  }

  // 4. Check for customers with balances (receivables) - Info
  try {
    final customers = await ref.watch(customersStreamProvider.future);
    final customersWithBalance = customers.where((c) => c.balance > 0).toList();
    if (customersWithBalance.isNotEmpty) {
      final totalReceivables =
          customersWithBalance.fold<double>(0, (sum, c) => sum + c.balance);
      alerts.add(AlertItem(
        id: 'receivables',
        severity: AlertSeverity.info,
        title: 'ذمم مدينة مستحقة',
        message:
            '${customersWithBalance.length} عميل بإجمالي ${formatter.format(totalReceivables)} ل.س (\$${(totalReceivables / CurrencyService.currentRate).toStringAsFixed(2)})',
        actionLabel: 'عرض العملاء',
        route: '/customers',
        timestamp: DateTime.now(),
        metadata: {
          'count': customersWithBalance.length,
          'total': totalReceivables,
        },
      ));
    }
  } catch (e) {
    debugPrint('Error checking receivables: $e');
  }

  // 5. Check for suppliers with balances (payables) - Info
  try {
    final suppliers = await ref.watch(suppliersStreamProvider.future);
    final suppliersWithBalance = suppliers.where((s) => s.balance > 0).toList();
    if (suppliersWithBalance.isNotEmpty) {
      final totalPayables =
          suppliersWithBalance.fold<double>(0, (sum, s) => sum + s.balance);
      alerts.add(AlertItem(
        id: 'payables',
        severity: AlertSeverity.info,
        title: 'ذمم دائنة مستحقة',
        message:
            '${suppliersWithBalance.length} مورد بإجمالي ${formatter.format(totalPayables)} ل.س (\$${(totalPayables / CurrencyService.currentRate).toStringAsFixed(2)})',
        actionLabel: 'عرض الموردين',
        route: '/suppliers',
        timestamp: DateTime.now(),
        metadata: {
          'count': suppliersWithBalance.length,
          'total': totalPayables,
        },
      ));
    }
  } catch (e) {
    debugPrint('Error checking payables: $e');
  }

  // Sort by severity (critical first)
  alerts.sort((a, b) {
    final severityOrder = {
      AlertSeverity.critical: 0,
      AlertSeverity.warning: 1,
      AlertSeverity.info: 2,
      AlertSeverity.success: 3,
    };
    return severityOrder[a.severity]!.compareTo(severityOrder[b.severity]!);
  });

  return alerts;
});

// ═══════════════════════════════════════════════════════════════════════════
// Derived Providers
// ═══════════════════════════════════════════════════════════════════════════

/// Provider for alert count
final alertsCountProvider = Provider<int>((ref) {
  return ref
          .watch(alertsProvider)
          .whenOrNull(data: (alerts) => alerts.length) ??
      0;
});

/// Provider for critical alerts only
final criticalAlertsProvider = Provider<List<AlertItem>>((ref) {
  return ref.watch(alertsProvider).whenOrNull(
            data: (alerts) => alerts
                .where((a) => a.severity == AlertSeverity.critical)
                .toList(),
          ) ??
      [];
});

/// Provider for warning alerts only
final warningAlertsProvider = Provider<List<AlertItem>>((ref) {
  return ref.watch(alertsProvider).whenOrNull(
            data: (alerts) => alerts
                .where((a) => a.severity == AlertSeverity.warning)
                .toList(),
          ) ??
      [];
});

/// Provider to check if there are any critical alerts
final hasCriticalAlertsProvider = Provider<bool>((ref) {
  return ref.watch(criticalAlertsProvider).isNotEmpty;
});
