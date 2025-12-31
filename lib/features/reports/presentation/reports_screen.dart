import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/currency_service.dart';
import '../../../data/database/app_database.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _db = getIt<AppDatabase>();
  final _currencyService = getIt<CurrencyService>();

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Date Range Info
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                Gap(8.w),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(_dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange.end)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectDateRange,
                  child: const Text('تغيير'),
                ),
              ],
            ),
          ),
          Gap(16.h),

          // ═══════════════════════════════════════════════════════════════════
          // ملخص سريع
          // ═══════════════════════════════════════════════════════════════════
          _buildQuickSummary(),
          Gap(24.h),

          // Report Categories
          Text(
            'التقارير المتاحة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(12.h),

          // تقارير المبيعات والأرباح
          Text(
            'المبيعات والأرباح',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Gap(8.h),

          _ReportCard(
            title: 'تقرير المبيعات',
            subtitle: 'تفاصيل المبيعات والإيرادات',
            icon: Icons.point_of_sale,
            color: AppColors.sales,
            onTap: () => context.push('/reports/sales', extra: _dateRange),
          ),
          Gap(8.h),

          _ReportCard(
            title: 'تقرير الأرباح والخسائر',
            subtitle: 'تحليل الربحية والمصاريف',
            icon: Icons.analytics,
            color: AppColors.success,
            onTap: () =>
                context.push('/reports/profit-loss', extra: _dateRange),
          ),
          Gap(16.h),

          // تقارير المخزون
          Text(
            'المخزون',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Gap(8.h),

          _ReportCard(
            title: 'تقرير المخزون',
            subtitle: 'حالة المخزون والتنبيهات',
            icon: Icons.warehouse,
            color: AppColors.warning,
            onTap: () => context.push('/reports/inventory', extra: _dateRange),
          ),
          Gap(16.h),

          // تقارير الذمم
          Text(
            'الذمم المدينة والدائنة',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Gap(8.h),

          _ReportCard(
            title: 'الذمم المدينة',
            subtitle: 'ديون العملاء المستحقة',
            icon: Icons.account_balance_wallet,
            color: AppColors.error,
            onTap: () => context.push('/reports/receivables'),
          ),
          Gap(8.h),

          _ReportCard(
            title: 'الذمم الدائنة',
            subtitle: 'المستحقات للموردين',
            icon: Icons.local_shipping,
            color: AppColors.suppliers,
            onTap: () => context.push('/reports/payables'),
          ),
          Gap(16.h),

          // تقارير العملاء والموردين
          Text(
            'العملاء والموردين',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Gap(8.h),

          _ReportCard(
            title: 'تقرير العملاء',
            subtitle: 'تحليل العملاء والمعاملات',
            icon: Icons.people,
            color: AppColors.customers,
            onTap: () => context.push('/customers'),
          ),
          Gap(8.h),

          _ReportCard(
            title: 'تقرير الموردين',
            subtitle: 'المشتريات والمستحقات',
            icon: Icons.business,
            color: AppColors.primary,
            onTap: () => context.push('/suppliers'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _calculateSummary(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;
        final sales = data['sales'] as double;
        final salesUsd = data['salesUsd'] as double;
        final receivables = data['receivables'] as double;
        final receivablesUsd = data['receivablesUsd'] as double;
        final payables = data['payables'] as double;
        final payablesUsd = data['payablesUsd'] as double;

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'ملخص سريع',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: () => setState(() {}),
                    tooltip: 'تحديث',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Gap(4.h),
              Text(
                'الدولار محسوب من سعر الصرف المحفوظ لكل فاتورة وسند',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.info,
                ),
              ),
              Gap(12.h),
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.trending_up,
                      color: AppColors.success,
                      label: 'المبيعات',
                      value: _currencyService.formatSyp(sales),
                      usdValue: '\$${salesUsd.toStringAsFixed(2)}',
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.account_balance_wallet,
                      color: AppColors.error,
                      label: 'الذمم المدينة',
                      value: _currencyService.formatSyp(receivables),
                      usdValue: '\$${receivablesUsd.toStringAsFixed(2)}',
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.local_shipping,
                      color: AppColors.warning,
                      label: 'الذمم الدائنة',
                      value: _currencyService.formatSyp(payables),
                      usdValue: '\$${payablesUsd.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _calculateSummary() async {
    // حساب المبيعات
    final invoices = await _db.getInvoicesByDateRange(
      _dateRange.start,
      _dateRange.end,
    );
    double sales = 0;
    double salesUsd = 0;
    for (final invoice in invoices) {
      if (invoice.type == 'sale') {
        sales += invoice.total;
        final rate = invoice.exchangeRate ?? 1;
        if (rate > 0) salesUsd += invoice.total / rate;
      }
    }

    // حساب الذمم المدينة (العملاء)
    final customers = await _db.getAllCustomers();
    double receivables = 0;
    double receivablesUsd = 0;
    for (final customer in customers) {
      if (customer.balance > 0) {
        receivables += customer.balance;
        receivablesUsd += await _db.getCustomerBalanceInUsd(customer.id);
      }
    }

    // حساب الذمم الدائنة (الموردين)
    final suppliers = await _db.getAllSuppliers();
    double payables = 0;
    double payablesUsd = 0;
    for (final supplier in suppliers) {
      if (supplier.balance > 0) {
        payables += supplier.balance;
        payablesUsd += await _db.getSupplierBalanceInUsd(supplier.id);
      }
    }

    return {
      'sales': sales,
      'salesUsd': salesUsd,
      'receivables': receivables,
      'receivablesUsd': receivablesUsd,
      'payables': payables,
      'payablesUsd': payablesUsd,
    };
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? usdValue;

  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.usdValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        Gap(8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        Gap(2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (usdValue != null)
          Text(
            usdValue!,
            style: TextStyle(
              fontSize: 9.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              Gap(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
