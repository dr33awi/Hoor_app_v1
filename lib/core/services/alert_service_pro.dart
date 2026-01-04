// ═══════════════════════════════════════════════════════════════════════════
// Alert Service Pro - Enhanced Alert Management
// Comprehensive alert system for inventory, payments, and system notifications
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../data/repositories/shift_repository.dart';
import '../di/injection.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Alert Types & Models
// ═══════════════════════════════════════════════════════════════════════════

enum AlertType {
  lowStock, // مخزون منخفض
  outOfStock, // نفاد المخزون
  overdueInvoice, // فاتورة متأخرة
  overdueReceivable, // ذمم متأخرة
  overduePayable, // مستحقات متأخرة للموردين
  longOpenShift, // وردية مفتوحة طويلاً
  backupReminder, // تذكير النسخ الاحتياطي
  expiringProducts, // منتجات قاربت على الانتهاء (للمستقبل)
  systemUpdate, // تحديث النظام
}

enum AlertPriority { low, medium, high, critical }

class AlertItem {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final AlertPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final String? actionRoute;

  AlertItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
    this.actionRoute,
  });

  AlertItem copyWith({
    String? id,
    AlertType? type,
    String? title,
    String? message,
    AlertPriority? priority,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
    String? actionRoute,
  }) {
    return AlertItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Alert Service
// ═══════════════════════════════════════════════════════════════════════════

class AlertServicePro extends ChangeNotifier {
  final AppDatabase _database;

  Timer? _checkTimer;
  List<AlertItem> _alerts = [];
  bool _isLoading = false;

  AlertServicePro(this._database) {
    _startPeriodicCheck();
  }

  List<AlertItem> get alerts => _alerts;
  List<AlertItem> get unreadAlerts => _alerts.where((a) => !a.isRead).toList();
  int get unreadCount => unreadAlerts.length;
  bool get isLoading => _isLoading;

  // Filtered alerts by priority
  List<AlertItem> get criticalAlerts =>
      _alerts.where((a) => a.priority == AlertPriority.critical).toList();
  List<AlertItem> get highPriorityAlerts =>
      _alerts.where((a) => a.priority == AlertPriority.high).toList();

  void _startPeriodicCheck() {
    // Check every 5 minutes
    _checkTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => checkAllAlerts(),
    );
    // Initial check
    checkAllAlerts();
  }

  Future<void> checkAllAlerts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newAlerts = <AlertItem>[];

      // 1. Check Low Stock Products
      await _checkLowStock(newAlerts);

      // 2. Check Out of Stock Products
      await _checkOutOfStock(newAlerts);

      // 3. Check Overdue Receivables (customer debts)
      await _checkOverdueReceivables(newAlerts);

      // 4. Check Overdue Payables (supplier debts)
      await _checkOverduePayables(newAlerts);

      // 5. Check Long Open Shift
      await _checkLongOpenShift(newAlerts);

      // 6. Check Backup Reminder
      await _checkBackupReminder(newAlerts);

      // Preserve read status from existing alerts
      for (int i = 0; i < newAlerts.length; i++) {
        final existingAlert = _alerts.firstWhere(
          (a) => a.id == newAlerts[i].id,
          orElse: () => newAlerts[i],
        );
        if (existingAlert.isRead) {
          newAlerts[i] = newAlerts[i].copyWith(isRead: true);
        }
      }

      _alerts = newAlerts;
      _alerts.sort((a, b) {
        // Sort by priority first, then by date
        final priorityCompare = b.priority.index.compareTo(a.priority.index);
        if (priorityCompare != 0) return priorityCompare;
        return b.createdAt.compareTo(a.createdAt);
      });
    } catch (e) {
      debugPrint('Error checking alerts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkLowStock(List<AlertItem> alerts) async {
    try {
      final productRepo = getIt<ProductRepository>();
      final products = await productRepo.getLowStockProducts();

      if (products.isNotEmpty) {
        alerts.add(AlertItem(
          id: 'low_stock_${DateTime.now().millisecondsSinceEpoch}',
          type: AlertType.lowStock,
          title: 'مخزون منخفض',
          message:
              '${products.length} منتجات وصلت للحد الأدنى وتحتاج إعادة طلب',
          priority: AlertPriority.high,
          createdAt: DateTime.now(),
          metadata: {
            'count': products.length,
            'products': products
                .map((p) => {
                      'id': p.id,
                      'name': p.name,
                      'quantity': p.quantity,
                      'minQuantity': p.minQuantity,
                    })
                .toList(),
          },
          actionRoute: '/products',
        ));
      }
    } catch (e) {
      debugPrint('Error checking low stock: $e');
    }
  }

  Future<void> _checkOutOfStock(List<AlertItem> alerts) async {
    try {
      final products = await _database.getAllProducts();
      final outOfStock =
          products.where((p) => p.isActive && p.quantity <= 0).toList();

      if (outOfStock.isNotEmpty) {
        alerts.add(AlertItem(
          id: 'out_of_stock_${DateTime.now().millisecondsSinceEpoch}',
          type: AlertType.outOfStock,
          title: 'نفاد المخزون!',
          message: '${outOfStock.length} منتجات نفدت من المخزون بالكامل',
          priority: AlertPriority.critical,
          createdAt: DateTime.now(),
          metadata: {
            'count': outOfStock.length,
            'products': outOfStock
                .map((p) => {
                      'id': p.id,
                      'name': p.name,
                    })
                .toList(),
          },
          actionRoute: '/products',
        ));
      }
    } catch (e) {
      debugPrint('Error checking out of stock: $e');
    }
  }

  Future<void> _checkOverdueReceivables(List<AlertItem> alerts) async {
    try {
      final customerRepo = getIt<CustomerRepository>();
      final customers = await customerRepo.getAllCustomers();
      final overdueCustomers = customers.where((c) => c.balance > 0).toList();

      if (overdueCustomers.isNotEmpty) {
        final totalOwed = overdueCustomers.fold<double>(
          0,
          (sum, c) => sum + c.balance,
        );

        alerts.add(AlertItem(
          id: 'overdue_receivables_${DateTime.now().millisecondsSinceEpoch}',
          type: AlertType.overdueReceivable,
          title: 'ذمم مدينة مستحقة',
          message:
              '${overdueCustomers.length} عملاء لديهم ذمم بقيمة ${totalOwed.toStringAsFixed(0)} ل.س',
          priority: AlertPriority.medium,
          createdAt: DateTime.now(),
          metadata: {
            'count': overdueCustomers.length,
            'total': totalOwed,
            'customers': overdueCustomers
                .map((c) => {
                      'id': c.id,
                      'name': c.name,
                      'balance': c.balance,
                    })
                .toList(),
          },
          actionRoute: '/customers',
        ));
      }
    } catch (e) {
      debugPrint('Error checking overdue receivables: $e');
    }
  }

  Future<void> _checkOverduePayables(List<AlertItem> alerts) async {
    try {
      final supplierRepo = getIt<SupplierRepository>();
      final suppliers = await supplierRepo.getAllSuppliers();
      final overdueSuppliers = suppliers.where((s) => s.balance > 0).toList();

      if (overdueSuppliers.isNotEmpty) {
        final totalOwed = overdueSuppliers.fold<double>(
          0,
          (sum, s) => sum + s.balance,
        );

        alerts.add(AlertItem(
          id: 'overdue_payables_${DateTime.now().millisecondsSinceEpoch}',
          type: AlertType.overduePayable,
          title: 'مستحقات للموردين',
          message:
              '${overdueSuppliers.length} موردين لديهم مستحقات بقيمة ${totalOwed.toStringAsFixed(0)} ل.س',
          priority: AlertPriority.medium,
          createdAt: DateTime.now(),
          metadata: {
            'count': overdueSuppliers.length,
            'total': totalOwed,
            'suppliers': overdueSuppliers
                .map((s) => {
                      'id': s.id,
                      'name': s.name,
                      'balance': s.balance,
                    })
                .toList(),
          },
          actionRoute: '/suppliers',
        ));
      }
    } catch (e) {
      debugPrint('Error checking overdue payables: $e');
    }
  }

  Future<void> _checkLongOpenShift(List<AlertItem> alerts) async {
    try {
      final shiftRepo = getIt<ShiftRepository>();
      final openShift = await shiftRepo.getOpenShift();

      if (openShift != null) {
        final duration = DateTime.now().difference(openShift.openedAt);

        // Alert if shift is open for more than 12 hours
        if (duration.inHours >= 12) {
          alerts.add(AlertItem(
            id: 'long_shift_${openShift.id}',
            type: AlertType.longOpenShift,
            title: 'وردية مفتوحة طويلاً',
            message:
                'الوردية مفتوحة منذ ${duration.inHours} ساعة. يُنصح بإغلاقها.',
            priority: duration.inHours >= 24
                ? AlertPriority.high
                : AlertPriority.medium,
            createdAt: DateTime.now(),
            metadata: {
              'shiftId': openShift.id,
              'shiftNumber': openShift.shiftNumber,
              'openedAt': openShift.openedAt.toIso8601String(),
              'hoursOpen': duration.inHours,
            },
            actionRoute: '/shifts',
          ));
        }
      }
    } catch (e) {
      debugPrint('Error checking long open shift: $e');
    }
  }

  Future<void> _checkBackupReminder(List<AlertItem> alerts) async {
    try {
      final lastBackup = await _database.getSetting('last_backup_time');

      if (lastBackup == null) {
        alerts.add(AlertItem(
          id: 'backup_never',
          type: AlertType.backupReminder,
          title: 'لم يتم النسخ الاحتياطي',
          message:
              'لم تقم بعمل نسخة احتياطية من قبل. قم بعمل نسخة احتياطية للحفاظ على بياناتك.',
          priority: AlertPriority.high,
          createdAt: DateTime.now(),
          actionRoute: '/backup',
        ));
      } else {
        final lastBackupTime = DateTime.parse(lastBackup);
        final daysSinceBackup =
            DateTime.now().difference(lastBackupTime).inDays;

        // Remind if no backup in last 7 days
        if (daysSinceBackup >= 7) {
          alerts.add(AlertItem(
            id: 'backup_old',
            type: AlertType.backupReminder,
            title: 'تذكير بالنسخ الاحتياطي',
            message:
                'مر $daysSinceBackup يوم منذ آخر نسخة احتياطية. قم بعمل نسخة جديدة.',
            priority:
                daysSinceBackup >= 30 ? AlertPriority.high : AlertPriority.low,
            createdAt: DateTime.now(),
            metadata: {
              'daysSinceBackup': daysSinceBackup,
              'lastBackupTime': lastBackup,
            },
            actionRoute: '/backup',
          ));
        }
      }
    } catch (e) {
      debugPrint('Error checking backup reminder: $e');
    }
  }

  void markAsRead(String alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _alerts = _alerts.map((a) => a.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void dismissAlert(String alertId) {
    _alerts.removeWhere((a) => a.id == alertId);
    notifyListeners();
  }

  void clearAllAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Riverpod Provider
// ═══════════════════════════════════════════════════════════════════════════

final alertServiceProProvider = ChangeNotifierProvider<AlertServicePro>((ref) {
  final database = getIt<AppDatabase>();
  return AlertServicePro(database);
});

/// Provider للتنبيهات كقائمة
final alertsProvider = Provider<List<AlertItem>>((ref) {
  return ref.watch(alertServiceProProvider).alerts;
});

/// Provider لعدد التنبيهات غير المقروءة
final unreadAlertsCountProvider = Provider<int>((ref) {
  return ref.watch(alertServiceProProvider).unreadCount;
});

/// Provider للتنبيهات الحرجة
final criticalAlertsProvider = Provider<List<AlertItem>>((ref) {
  return ref.watch(alertServiceProProvider).criticalAlerts;
});
