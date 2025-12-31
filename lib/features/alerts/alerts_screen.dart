import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/services/alert_service.dart';
import '../../data/database/app_database.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// مزود خدمة التنبيهات (Singleton)
/// ═══════════════════════════════════════════════════════════════════════════
AlertService? _alertServiceInstance;

AlertService getAlertService() {
  _alertServiceInstance ??= AlertService(getIt<AppDatabase>())..initialize();
  return _alertServiceInstance!;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// شاشة التنبيهات
/// ═══════════════════════════════════════════════════════════════════════════
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertService = getAlertService();

    return ListenableBuilder(
      listenable: alertService,
      builder: (context, _) {
        final alerts = alertService.alerts;

        return Scaffold(
          appBar: AppBar(
            title: const Text('التنبيهات'),
            actions: [
              if (alertService.hasUnreadAlerts)
                TextButton(
                  onPressed: () => alertService.markAllAsRead(),
                  child: const Text(
                    'تحديد الكل كمقروء',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => alertService.checkAllAlerts(),
                tooltip: 'تحديث',
              ),
            ],
          ),
          body: alerts.isEmpty
              ? _buildEmptyState()
              : _buildAlertsList(context, alertService, alerts),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد تنبيهات',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'كل شيء على ما يرام!',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(
    BuildContext context,
    AlertService alertService,
    List<Alert> alerts,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _AlertCard(
          alert: alert,
          onTap: () => _handleAlertTap(context, alertService, alert),
          onDismiss: () => alertService.dismissAlert(alert.id),
        );
      },
    );
  }

  void _handleAlertTap(
      BuildContext context, AlertService service, Alert alert) {
    service.markAsRead(alert.id);

    switch (alert.type) {
      case AlertType.lowStock:
        // الانتقال لإدارة المخزون
        context.push('/inventory');
        break;
      case AlertType.customerDebt:
        // الانتقال لتقرير الذمم المدينة
        context.push('/reports/receivables');
        break;
      case AlertType.supplierDebt:
        // الانتقال لتقرير الذمم الدائنة
        context.push('/reports/payables');
        break;
      case AlertType.shiftOpen:
        // الانتقال لإدارة الصندوق
        context.push('/cash');
        break;
      case AlertType.backupNeeded:
        // الانتقال للإعدادات
        context.push('/settings');
        break;
      case AlertType.syncError:
        // الانتقال للإعدادات
        context.push('/settings');
        break;
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// بطاقة التنبيه
/// ═══════════════════════════════════════════════════════════════════════════
class _AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _AlertCard({
    required this.alert,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: alert.isRead ? 1 : 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                right: BorderSide(
                  color: _getSeverityColor(alert.severity),
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: TextStyle(
                                fontWeight: alert.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildSeverityBadge(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(alert.createdAt),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getTypeColor(alert.type).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getTypeIcon(alert.type),
        color: _getTypeColor(alert.type),
        size: 24,
      ),
    );
  }

  Widget _buildSeverityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getSeverityColor(alert.severity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getSeverityLabel(alert.severity),
        style: TextStyle(
          color: _getSeverityColor(alert.severity),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Icons.inventory_2_outlined;
      case AlertType.customerDebt:
        return Icons.person_outline;
      case AlertType.supplierDebt:
        return Icons.local_shipping_outlined;
      case AlertType.shiftOpen:
        return Icons.access_time;
      case AlertType.backupNeeded:
        return Icons.backup_outlined;
      case AlertType.syncError:
        return Icons.sync_problem;
    }
  }

  Color _getTypeColor(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Colors.orange;
      case AlertType.customerDebt:
        return Colors.blue;
      case AlertType.supplierDebt:
        return Colors.purple;
      case AlertType.shiftOpen:
        return Colors.amber;
      case AlertType.backupNeeded:
        return Colors.teal;
      case AlertType.syncError:
        return Colors.red;
    }
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.green;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.red.shade900;
    }
  }

  String _getSeverityLabel(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return 'منخفض';
      case AlertSeverity.medium:
        return 'متوسط';
      case AlertSeverity.high:
        return 'مرتفع';
      case AlertSeverity.critical:
        return 'حرج';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${time.day}/${time.month}/${time.year}';
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// زر التنبيهات للـ AppBar
/// ═══════════════════════════════════════════════════════════════════════════
class AlertsButton extends StatelessWidget {
  const AlertsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final alertService = getAlertService();

    return ListenableBuilder(
      listenable: alertService,
      builder: (context, _) {
        final unreadCount = alertService.unreadCount;

        return Stack(
          children: [
            IconButton(
              icon: Icon(
                unreadCount > 0
                    ? Icons.notifications_active
                    : Icons.notifications_outlined,
              ),
              onPressed: () => context.push('/alerts'),
              tooltip: 'التنبيهات',
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ويدجت التنبيهات المصغر للشاشة الرئيسية
/// ═══════════════════════════════════════════════════════════════════════════
class AlertsSummaryWidget extends StatelessWidget {
  const AlertsSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final alertService = getAlertService();

    return ListenableBuilder(
      listenable: alertService,
      builder: (context, _) {
        final criticalCount = alertService.criticalAlerts.length;
        final highCount = alertService.highAlerts.length;
        final totalUnread = alertService.unreadCount;

        if (totalUnread == 0) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.all(16),
          color: criticalCount > 0 ? Colors.red.shade50 : Colors.orange.shade50,
          child: InkWell(
            onTap: () => context.push('/alerts'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: criticalCount > 0
                          ? Colors.red.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: criticalCount > 0 ? Colors.red : Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$totalUnread تنبيه${totalUnread > 1 ? 'ات' : ''} جديد${totalUnread > 1 ? 'ة' : ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: criticalCount > 0
                                ? Colors.red.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _buildSubtitle(criticalCount, highCount),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildSubtitle(int critical, int high) {
    final parts = <String>[];
    if (critical > 0) parts.add('$critical حرج');
    if (high > 0) parts.add('$high مرتفع');
    return parts.isEmpty ? 'انقر للتفاصيل' : parts.join(' • ');
  }
}
