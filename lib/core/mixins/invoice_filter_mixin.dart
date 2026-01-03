// ═══════════════════════════════════════════════════════════════════════════
// Invoice Filter Mixin - توحيد منطق الفلترة
// Replaces duplicated filter logic across screens
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';

/// Mixin لفلترة الفواتير - يُستخدم في جميع شاشات الفواتير
mixin InvoiceFilterMixin {
  /// فلترة الفواتير حسب المعايير المحددة
  List<Invoice> filterInvoices(
    List<Invoice> invoices, {
    String? type, // 'sale' or 'purchase' or null for all
    String? status, // 'completed', 'pending', 'cancelled' or 'all'
    DateTimeRange? dateRange,
    String? searchQuery,
    String? customerId,
    String? supplierId,
  }) {
    List<Invoice> filtered = List.from(invoices);

    // فلتر النوع
    if (type != null) {
      filtered = filtered.where((i) => i.type == type).toList();
    }

    // فلتر الحالة
    if (status != null && status != 'all') {
      filtered = filtered.where((i) {
        if (status == 'completed') {
          return i.status == 'completed' || i.status == 'paid';
        }
        if (status == 'pending') {
          return i.status == 'pending' || i.status == 'partial';
        }
        return i.status == status;
      }).toList();
    }

    // فلتر البحث
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((i) {
        return i.invoiceNumber.toLowerCase().contains(query) ||
            (i.customerId?.toLowerCase().contains(query) ?? false) ||
            (i.supplierId?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // فلتر العميل
    if (customerId != null) {
      filtered = filtered.where((i) => i.customerId == customerId).toList();
    }

    // فلتر المورد
    if (supplierId != null) {
      filtered = filtered.where((i) => i.supplierId == supplierId).toList();
    }

    // فلتر الفترة الزمنية
    if (dateRange != null) {
      filtered = filtered.where((i) {
        return i.invoiceDate
                .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            i.invoiceDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    // ترتيب حسب التاريخ تنازلياً
    filtered.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));

    return filtered;
  }

  /// حساب إحصائيات الفواتير
  InvoiceStats calculateInvoiceStats(List<Invoice> invoices) {
    final total = invoices.fold(0.0, (sum, i) => sum + i.total);
    final paid = invoices.fold(0.0, (sum, i) => sum + i.paidAmount);
    final pending = total - paid;

    final now = DateTime.now();
    final thisMonth = invoices.where((i) {
      return i.invoiceDate.month == now.month && i.invoiceDate.year == now.year;
    }).fold(0.0, (sum, i) => sum + i.total);

    final today = invoices.where((i) {
      return i.invoiceDate.day == now.day &&
          i.invoiceDate.month == now.month &&
          i.invoiceDate.year == now.year;
    }).fold(0.0, (sum, i) => sum + i.total);

    return InvoiceStats(
      total: total,
      paid: paid,
      pending: pending,
      thisMonth: thisMonth,
      today: today,
      count: invoices.length,
    );
  }

  /// فلترة حسب التبويب
  List<Invoice> filterByTab(List<Invoice> invoices, int tabIndex) {
    switch (tabIndex) {
      case 1: // مكتملة
        return invoices
            .where((i) => i.status == 'completed' || i.status == 'paid')
            .toList();
      case 2: // معلقة
        return invoices
            .where((i) => i.status == 'pending' || i.status == 'partial')
            .toList();
      case 3: // ملغية
        return invoices.where((i) => i.status == 'cancelled').toList();
      default: // الكل
        return invoices;
    }
  }
}

/// إحصائيات الفواتير
class InvoiceStats {
  final double total;
  final double paid;
  final double pending;
  final double thisMonth;
  final double today;
  final int count;

  const InvoiceStats({
    required this.total,
    required this.paid,
    required this.pending,
    required this.thisMonth,
    required this.today,
    required this.count,
  });
}
