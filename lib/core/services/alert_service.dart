import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/database/app_database.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// نموذج التنبيه
/// ═══════════════════════════════════════════════════════════════════════════
class Alert {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final AlertSeverity severity;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  bool isRead;

  Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    this.data,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();
}

enum AlertType {
  lowStock, // مخزون منخفض
  customerDebt, // دين عميل
  supplierDebt, // دين للمورد
  shiftOpen, // وردية مفتوحة طويلة
  backupNeeded, // نسخ احتياطي مطلوب
  syncError, // خطأ في المزامنة
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

/// ═══════════════════════════════════════════════════════════════════════════
/// خدمة التنبيهات
/// ═══════════════════════════════════════════════════════════════════════════
class AlertService extends ChangeNotifier {
  final AppDatabase _database;

  final List<Alert> _alerts = [];
  Timer? _checkTimer;

  // إعدادات التنبيهات (للاستخدام المستقبلي)
  // ignore: unused_field
  double _lowStockThreshold = 5;
  double _highDebtThreshold = 500000; // 500,000 ل.س
  int _maxShiftHours = 12;
  int _backupIntervalDays = 7;

  AlertService(this._database);

  // ═══════════════════════════════════════════════════════════════════════════
  // Getters
  // ═══════════════════════════════════════════════════════════════════════════

  List<Alert> get alerts => List.unmodifiable(_alerts);
  List<Alert> get unreadAlerts => _alerts.where((a) => !a.isRead).toList();
  int get unreadCount => unreadAlerts.length;
  bool get hasUnreadAlerts => unreadCount > 0;

  List<Alert> get criticalAlerts =>
      _alerts.where((a) => a.severity == AlertSeverity.critical).toList();
  List<Alert> get highAlerts =>
      _alerts.where((a) => a.severity == AlertSeverity.high).toList();

  // ═══════════════════════════════════════════════════════════════════════════
  // التهيئة
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> initialize() async {
    await checkAllAlerts();
    // فحص دوري كل 30 دقيقة
    _checkTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => checkAllAlerts(),
    );
  }

  /// تحديث إعدادات التنبيهات
  void updateSettings({
    double? lowStockThreshold,
    double? highDebtThreshold,
    int? maxShiftHours,
    int? backupIntervalDays,
  }) {
    if (lowStockThreshold != null) _lowStockThreshold = lowStockThreshold;
    if (highDebtThreshold != null) _highDebtThreshold = highDebtThreshold;
    if (maxShiftHours != null) _maxShiftHours = maxShiftHours;
    if (backupIntervalDays != null) _backupIntervalDays = backupIntervalDays;
    checkAllAlerts();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // فحص التنبيهات
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> checkAllAlerts() async {
    _alerts.clear();
    await Future.wait([
      _checkLowStockAlerts(),
      _checkCustomerDebtAlerts(),
      _checkSupplierDebtAlerts(),
      _checkShiftAlerts(),
      _checkBackupAlerts(),
    ]);
    // ترتيب حسب الأهمية
    _alerts.sort((a, b) {
      final severityCompare = b.severity.index.compareTo(a.severity.index);
      if (severityCompare != 0) return severityCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
    notifyListeners();
  }

  /// فحص المنتجات منخفضة المخزون
  Future<void> _checkLowStockAlerts() async {
    try {
      final lowStockProducts = await _database.getLowStockProducts();
      for (final product in lowStockProducts) {
        final severity =
            _getStockSeverity(product.quantity, product.minQuantity);
        _alerts.add(Alert(
          id: 'low_stock_${product.id}',
          type: AlertType.lowStock,
          title: 'مخزون منخفض',
          message:
              '${product.name}: الكمية ${product.quantity} (الحد الأدنى: ${product.minQuantity})',
          severity: severity,
          data: {
            'productId': product.id,
            'productName': product.name,
            'quantity': product.quantity,
            'minQuantity': product.minQuantity,
          },
        ));
      }
    } catch (e) {
      debugPrint('Error checking low stock alerts: $e');
    }
  }

  /// فحص ديون العملاء المرتفعة
  Future<void> _checkCustomerDebtAlerts() async {
    try {
      final customers = await _database.getAllCustomers();
      for (final customer in customers) {
        if (customer.balance > 0) {
          final severity = _getDebtSeverity(customer.balance);
          if (severity.index >= AlertSeverity.medium.index) {
            _alerts.add(Alert(
              id: 'customer_debt_${customer.id}',
              type: AlertType.customerDebt,
              title: 'دين عميل مرتفع',
              message: '${customer.name}: ${_formatAmount(customer.balance)}',
              severity: severity,
              data: {
                'customerId': customer.id,
                'customerName': customer.name,
                'balance': customer.balance,
              },
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking customer debt alerts: $e');
    }
  }

  /// فحص الديون للموردين
  Future<void> _checkSupplierDebtAlerts() async {
    try {
      final suppliers = await _database.getAllSuppliers();
      for (final supplier in suppliers) {
        if (supplier.balance > 0) {
          final severity = _getDebtSeverity(supplier.balance);
          if (severity.index >= AlertSeverity.medium.index) {
            _alerts.add(Alert(
              id: 'supplier_debt_${supplier.id}',
              type: AlertType.supplierDebt,
              title: 'مستحقات مورد',
              message: '${supplier.name}: ${_formatAmount(supplier.balance)}',
              severity: severity,
              data: {
                'supplierId': supplier.id,
                'supplierName': supplier.name,
                'balance': supplier.balance,
              },
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking supplier debt alerts: $e');
    }
  }

  /// فحص الورديات المفتوحة طويلاً
  Future<void> _checkShiftAlerts() async {
    try {
      final openShift = await _database.getOpenShift();
      if (openShift != null) {
        final hoursOpen = DateTime.now().difference(openShift.openedAt).inHours;
        if (hoursOpen >= _maxShiftHours) {
          _alerts.add(Alert(
            id: 'shift_open_${openShift.id}',
            type: AlertType.shiftOpen,
            title: 'وردية مفتوحة طويلاً',
            message: 'الوردية مفتوحة منذ $hoursOpen ساعة',
            severity: hoursOpen >= _maxShiftHours * 2
                ? AlertSeverity.high
                : AlertSeverity.medium,
            data: {
              'shiftId': openShift.id,
              'openedAt': openShift.openedAt.toIso8601String(),
              'hoursOpen': hoursOpen,
            },
          ));
        }
      }
    } catch (e) {
      debugPrint('Error checking shift alerts: $e');
    }
  }

  /// فحص الحاجة للنسخ الاحتياطي
  Future<void> _checkBackupAlerts() async {
    try {
      final lastBackupStr = await _database.getSetting('last_backup_time');
      if (lastBackupStr == null) {
        _alerts.add(Alert(
          id: 'backup_needed',
          type: AlertType.backupNeeded,
          title: 'نسخ احتياطي مطلوب',
          message: 'لم يتم عمل نسخ احتياطي بعد',
          severity: AlertSeverity.high,
        ));
        return;
      }

      final lastBackup = DateTime.tryParse(lastBackupStr);
      if (lastBackup != null) {
        final daysSinceBackup = DateTime.now().difference(lastBackup).inDays;
        if (daysSinceBackup >= _backupIntervalDays) {
          _alerts.add(Alert(
            id: 'backup_needed',
            type: AlertType.backupNeeded,
            title: 'نسخ احتياطي مطلوب',
            message: 'آخر نسخ احتياطي منذ $daysSinceBackup يوم',
            severity: daysSinceBackup >= _backupIntervalDays * 2
                ? AlertSeverity.high
                : AlertSeverity.medium,
            data: {
              'lastBackup': lastBackup.toIso8601String(),
              'daysSinceBackup': daysSinceBackup,
            },
          ));
        }
      }
    } catch (e) {
      debugPrint('Error checking backup alerts: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // المساعدات
  // ═══════════════════════════════════════════════════════════════════════════

  AlertSeverity _getStockSeverity(int quantity, int minQuantity) {
    if (quantity == 0) return AlertSeverity.critical;
    if (quantity <= minQuantity / 2) return AlertSeverity.high;
    if (quantity <= minQuantity) return AlertSeverity.medium;
    return AlertSeverity.low;
  }

  AlertSeverity _getDebtSeverity(double amount) {
    if (amount >= _highDebtThreshold * 2) return AlertSeverity.critical;
    if (amount >= _highDebtThreshold) return AlertSeverity.high;
    if (amount >= _highDebtThreshold / 2) return AlertSeverity.medium;
    return AlertSeverity.low;
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ل.س';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ل.س';
    }
    return '${amount.toStringAsFixed(0)} ل.س';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إدارة التنبيهات
  // ═══════════════════════════════════════════════════════════════════════════

  void markAsRead(String alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (final alert in _alerts) {
      alert.isRead = true;
    }
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
