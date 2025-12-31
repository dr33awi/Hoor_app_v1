import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/currency_service.dart';
import '../../../data/database/app_database.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// تقرير الأرباح والخسائر
/// ═══════════════════════════════════════════════════════════════════════════
class ProfitLossReportScreen extends ConsumerStatefulWidget {
  final DateTimeRange? dateRange;

  const ProfitLossReportScreen({super.key, this.dateRange});

  @override
  ConsumerState<ProfitLossReportScreen> createState() =>
      _ProfitLossReportScreenState();
}

class _ProfitLossReportScreenState
    extends ConsumerState<ProfitLossReportScreen> {
  final _db = getIt<AppDatabase>();
  final _currencyService = getIt<CurrencyService>();

  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();
    _dateRange = widget.dateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الأرباح والخسائر'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _calculateProfitLoss(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final totalSales = data['totalSales'] as double;
          final totalSalesUsd = data['totalSalesUsd'] as double;
          final totalCost = data['totalCost'] as double;
          final totalCostUsd = data['totalCostUsd'] as double;
          final totalExpenses = data['totalExpenses'] as double;
          final totalExpensesUsd = data['totalExpensesUsd'] as double;
          final totalReturns = data['totalReturns'] as double;
          final totalReturnsUsd = data['totalReturnsUsd'] as double;
          final grossProfit = data['grossProfit'] as double;
          final grossProfitUsd = data['grossProfitUsd'] as double;
          final netProfit = data['netProfit'] as double;
          final netProfitUsd = data['netProfitUsd'] as double;
          final profitMargin = data['profitMargin'] as double;
          final invoiceCount = data['invoiceCount'] as int;

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // الفترة الزمنية
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

              // بطاقة صافي الربح
              _ProfitCard(
                netProfit: netProfit,
                netProfitUsd: netProfitUsd,
                profitMargin: profitMargin,
                currencyService: _currencyService,
              ),
              Gap(16.h),

              // ملخص الأرقام
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي المبيعات',
                      value: totalSales,
                      icon: Icons.trending_up,
                      color: AppColors.success,
                      currencyService: _currencyService,
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: _StatCard(
                      title: 'تكلفة البضاعة',
                      value: totalCost,
                      icon: Icons.shopping_cart,
                      color: AppColors.primary,
                      currencyService: _currencyService,
                    ),
                  ),
                ],
              ),
              Gap(8.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي الربح',
                      value: grossProfit,
                      icon: Icons.account_balance_wallet,
                      color: AppColors.accent,
                      currencyService: _currencyService,
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: _StatCard(
                      title: 'المصاريف',
                      value: totalExpenses,
                      icon: Icons.money_off,
                      color: AppColors.error,
                      currencyService: _currencyService,
                    ),
                  ),
                ],
              ),
              Gap(8.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'المرتجعات',
                      value: totalReturns,
                      icon: Icons.assignment_return,
                      color: AppColors.warning,
                      currencyService: _currencyService,
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: _StatCard(
                      title: 'عدد الفواتير',
                      value: invoiceCount.toDouble(),
                      icon: Icons.receipt_long,
                      color: AppColors.primary,
                      currencyService: _currencyService,
                      isCurrency: false,
                    ),
                  ),
                ],
              ),
              Gap(24.h),

              // رسم بياني للتوزيع
              Text(
                'توزيع الإيرادات والمصاريف',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(12.h),
              Container(
                height: 200.h,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: _buildPieChart(
                    totalSales, totalCost, totalExpenses, totalReturns),
              ),
              Gap(24.h),

              // تفاصيل حساب الربح
              Text(
                'تفاصيل الحساب',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(12.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'إجمالي المبيعات',
                        value: _currencyService.formatSyp(totalSales),
                        usdValue: '\$${totalSalesUsd.toStringAsFixed(2)}',
                        isPositive: true,
                      ),
                      Divider(height: 16.h),
                      _DetailRow(
                        label: '(-) تكلفة البضاعة المباعة',
                        value: _currencyService.formatSyp(totalCost),
                        usdValue: '\$${totalCostUsd.toStringAsFixed(2)}',
                        isPositive: false,
                      ),
                      Divider(height: 16.h),
                      _DetailRow(
                        label: '= إجمالي الربح',
                        value: _currencyService.formatSyp(grossProfit),
                        usdValue: '\$${grossProfitUsd.toStringAsFixed(2)}',
                        isPositive: grossProfit > 0,
                        isBold: true,
                      ),
                      Divider(height: 16.h),
                      _DetailRow(
                        label: '(-) المصاريف التشغيلية',
                        value: _currencyService.formatSyp(totalExpenses),
                        usdValue: '\$${totalExpensesUsd.toStringAsFixed(2)}',
                        isPositive: false,
                      ),
                      _DetailRow(
                        label: '(-) المرتجعات',
                        value: _currencyService.formatSyp(totalReturns),
                        usdValue: '\$${totalReturnsUsd.toStringAsFixed(2)}',
                        isPositive: false,
                      ),
                      Divider(height: 16.h, thickness: 2),
                      _DetailRow(
                        label: '= صافي الربح',
                        value: _currencyService.formatSyp(netProfit),
                        usdValue: '\$${netProfitUsd.toStringAsFixed(2)}',
                        isPositive: netProfit > 0,
                        isBold: true,
                        isLarge: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _calculateProfitLoss() async {
    // جلب فواتير المبيعات
    final invoices = await _db.getInvoicesByDateRange(
      _dateRange.start,
      _dateRange.end,
    );

    double totalSales = 0;
    double totalSalesUsd = 0;
    double totalCost = 0;
    double totalCostUsd = 0;
    double totalReturns = 0;
    double totalReturnsUsd = 0;
    int invoiceCount = 0;

    for (final invoice in invoices) {
      final rate = invoice.exchangeRate ?? 1;
      if (invoice.type == 'sale') {
        totalSales += invoice.total;
        if (rate > 0) totalSalesUsd += invoice.total / rate;
        invoiceCount++;
        // حساب تكلفة البضاعة
        final items = await _db.getInvoiceItems(invoice.id);
        for (final item in items) {
          final itemCost = item.purchasePrice * item.quantity;
          totalCost += itemCost;
          if (rate > 0) totalCostUsd += itemCost / rate;
        }
      } else if (invoice.type == 'sale_return') {
        totalReturns += invoice.total;
        if (rate > 0) totalReturnsUsd += invoice.total / rate;
      }
    }

    // جلب المصاريف من حركات الصندوق
    final cashMovements = await _db.getCashMovementsByDateRange(
      _dateRange.start,
      _dateRange.end,
    );

    double totalExpenses = 0;
    double totalExpensesUsd = 0;
    for (final movement in cashMovements) {
      if (movement.type == 'expense') {
        totalExpenses += movement.amount;
        // حركات الصندوق لا تحفظ سعر الصرف، نستخدم السعر الحالي
        totalExpensesUsd += _currencyService.sypToUsd(movement.amount);
      }
    }

    // جلب مصاريف السندات
    final vouchers = await _db.getVouchersByDateRange(
      _dateRange.start,
      _dateRange.end,
    );
    for (final voucher in vouchers) {
      if (voucher.type == 'expense') {
        totalExpenses += voucher.amount;
        final rate = voucher.exchangeRate;
        if (rate > 0) totalExpensesUsd += voucher.amount / rate;
      }
    }

    final grossProfit = totalSales - totalCost;
    final grossProfitUsd = totalSalesUsd - totalCostUsd;
    final netProfit = grossProfit - totalExpenses - totalReturns;
    final netProfitUsd = grossProfitUsd - totalExpensesUsd - totalReturnsUsd;
    final profitMargin = totalSales > 0 ? (netProfit / totalSales) * 100 : 0;

    return {
      'totalSales': totalSales,
      'totalSalesUsd': totalSalesUsd,
      'totalCost': totalCost,
      'totalCostUsd': totalCostUsd,
      'totalExpenses': totalExpenses,
      'totalExpensesUsd': totalExpensesUsd,
      'totalReturns': totalReturns,
      'totalReturnsUsd': totalReturnsUsd,
      'grossProfit': grossProfit,
      'grossProfitUsd': grossProfitUsd,
      'netProfit': netProfit,
      'netProfitUsd': netProfitUsd,
      'profitMargin': profitMargin,
      'invoiceCount': invoiceCount,
    };
  }

  Widget _buildPieChart(
    double sales,
    double cost,
    double expenses,
    double returns,
  ) {
    final total = cost + expenses + returns;
    if (total == 0) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: cost,
            title: 'التكلفة',
            color: AppColors.primary,
            radius: 60.r,
            titleStyle: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          PieChartSectionData(
            value: expenses,
            title: 'المصاريف',
            color: AppColors.error,
            radius: 60.r,
            titleStyle: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (returns > 0)
            PieChartSectionData(
              value: returns,
              title: 'المرتجعات',
              color: AppColors.warning,
              radius: 60.r,
              titleStyle: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
        centerSpaceRadius: 40.r,
      ),
    );
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

class _ProfitCard extends StatelessWidget {
  final double netProfit;
  final double netProfitUsd;
  final double profitMargin;
  final CurrencyService currencyService;

  const _ProfitCard({
    required this.netProfit,
    required this.netProfitUsd,
    required this.profitMargin,
    required this.currencyService,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = netProfit >= 0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit
              ? [AppColors.success, AppColors.success.withOpacity(0.7)]
              : [AppColors.error, AppColors.error.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? AppColors.success : AppColors.error)
                .withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isProfit ? 'صافي الربح' : 'صافي الخسارة',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    currencyService.formatSyp(netProfit.abs()),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${netProfitUsd.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  isProfit ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
            ],
          ),
          Gap(16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                  size: 18.sp,
                ),
                Gap(4.w),
                Text(
                  'نسبة الربح: ${profitMargin.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Gap(8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'محسوب من سعر الصرف المحفوظ لكل فاتورة',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final CurrencyService currencyService;
  final bool isCurrency;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.currencyService,
    this.isCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 20.sp),
                ),
                const Spacer(),
              ],
            ),
            Gap(12.h),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
            Gap(4.h),
            Text(
              isCurrency
                  ? currencyService.formatSyp(value)
                  : value.toInt().toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? usdValue;
  final bool isPositive;
  final bool isBold;
  final bool isLarge;

  const _DetailRow({
    required this.label,
    required this.value,
    this.usdValue,
    required this.isPositive,
    this.isBold = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16.sp : 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isLarge ? 18.sp : 14.sp,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
              if (usdValue != null)
                Text(
                  usdValue!,
                  style: TextStyle(
                    fontSize: isLarge ? 14.sp : 12.sp,
                    color: (isPositive ? AppColors.success : AppColors.error)
                        .withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
