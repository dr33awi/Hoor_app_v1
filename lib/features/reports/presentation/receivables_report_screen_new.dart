import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/currency_service.dart';
import '../../../data/database/app_database.dart';

/// نموذج بيانات العميل مع رصيد الدولار
class CustomerWithUsdBalance {
  final Customer customer;
  final double usdBalance;

  CustomerWithUsdBalance({required this.customer, required this.usdBalance});
}

/// ═══════════════════════════════════════════════════════════════════════════
/// تقرير الذمم المدينة (ديون العملاء)
/// ═══════════════════════════════════════════════════════════════════════════
class ReceivablesReportScreen extends ConsumerStatefulWidget {
  const ReceivablesReportScreen({super.key});

  @override
  ConsumerState<ReceivablesReportScreen> createState() =>
      _ReceivablesReportScreenState();
}

class _ReceivablesReportScreenState
    extends ConsumerState<ReceivablesReportScreen> {
  final _db = getIt<AppDatabase>();
  final _currencyService = getIt<CurrencyService>();
  String _sortBy = 'balance';
  bool _sortDescending = true;
  bool _showOnlyWithBalance = true;
  bool _isLoading = true;
  List<CustomerWithUsdBalance> _customersWithUsd = [];
  double _totalUsd = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final customers = await _db.getAllCustomers();
    final List<CustomerWithUsdBalance> result = [];
    double totalUsd = 0;

    for (final customer in customers) {
      if (_showOnlyWithBalance && customer.balance <= 0) continue;
      
      final usdBalance = await _db.getCustomerBalanceInUsd(customer.id);
      result.add(CustomerWithUsdBalance(
        customer: customer,
        usdBalance: usdBalance,
      ));
      if (customer.balance > 0) {
        totalUsd += usdBalance;
      }
    }

    // ترتيب القائمة
    result.sort((a, b) {
      int compare;
      switch (_sortBy) {
        case 'name':
          compare = a.customer.name.compareTo(b.customer.name);
          break;
        case 'balance':
        default:
          compare = a.customer.balance.compareTo(b.customer.balance);
      }
      return _sortDescending ? -compare : compare;
    });

    setState(() {
      _customersWithUsd = result;
      _totalUsd = totalUsd;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الذمم المدينة'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _sortDescending = !_sortDescending;
                } else {
                  _sortBy = value;
                  _sortDescending = true;
                }
              });
              _loadData();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'balance',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'balance'
                          ? (_sortDescending
                              ? Icons.arrow_downward
                              : Icons.arrow_upward)
                          : Icons.sort,
                      size: 18,
                    ),
                    Gap(8.w),
                    const Text('الرصيد'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'name'
                          ? (_sortDescending
                              ? Icons.arrow_downward
                              : Icons.arrow_upward)
                          : Icons.sort,
                      size: 18,
                    ),
                    Gap(8.w),
                    const Text('الاسم'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _showOnlyWithBalance ? Icons.filter_alt : Icons.filter_alt_off,
            ),
            onPressed: () {
              setState(() {
                _showOnlyWithBalance = !_showOnlyWithBalance;
              });
              _loadData();
            },
            tooltip:
                _showOnlyWithBalance ? 'إظهار الكل' : 'إظهار من عليهم رصيد فقط',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final totalReceivables = _customersWithUsd.fold<double>(
        0, (sum, c) => sum + (c.customer.balance > 0 ? c.customer.balance : 0));
    final customersWithDebt =
        _customersWithUsd.where((c) => c.customer.balance > 0).length;

    return Column(
      children: [
        // ملخص الذمم المدينة
        Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.error, AppColors.error.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
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
                        'إجمالي الذمم المدينة',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        _currencyService.formatSyp(totalReceivables),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_totalUsd.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                ],
              ),
              Gap(12.h),
              const Divider(color: Colors.white24),
              Gap(8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    label: 'عدد العملاء المدينين',
                    value: '$customersWithDebt',
                  ),
                  _SummaryItem(
                    label: 'متوسط الدين',
                    value: customersWithDebt > 0
                        ? _currencyService
                            .formatSyp(totalReceivables / customersWithDebt)
                        : '0',
                  ),
                ],
              ),
            ],
          ),
        ),

        // ملاحظة حول سعر الصرف
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 16.sp),
              Gap(8.w),
              Expanded(
                child: Text(
                  'قيمة الدولار محسوبة من سعر الصرف المحفوظ لكل فاتورة وسند',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap(8.h),

        // قائمة العملاء
        Expanded(
          child: _customersWithUsd.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64.sp,
                        color: AppColors.success,
                      ),
                      Gap(16.h),
                      Text(
                        'لا توجد ذمم مدينة',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _customersWithUsd.length,
                  itemBuilder: (context, index) {
                    final item = _customersWithUsd[index];
                    return _CustomerDebtCard(
                      customer: item.customer,
                      usdBalance: item.usdBalance,
                      currencyService: _currencyService,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

class _CustomerDebtCard extends StatelessWidget {
  final Customer customer;
  final double usdBalance;
  final CurrencyService currencyService;

  const _CustomerDebtCard({
    required this.customer,
    required this.usdBalance,
    required this.currencyService,
  });

  @override
  Widget build(BuildContext context) {
    final hasDebt = customer.balance > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hasDebt
              ? AppColors.error.withOpacity(0.1)
              : AppColors.success.withOpacity(0.1),
          child: Icon(
            hasDebt ? Icons.warning : Icons.check,
            color: hasDebt ? AppColors.error : AppColors.success,
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: customer.phone != null ? Text(customer.phone!) : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyService.formatSyp(customer.balance),
              style: TextStyle(
                color: hasDebt ? AppColors.error : AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            Text(
              '\$${usdBalance.toStringAsFixed(2)}',
              style: TextStyle(
                color: hasDebt
                    ? AppColors.error.withOpacity(0.7)
                    : AppColors.success.withOpacity(0.7),
                fontSize: 12.sp,
              ),
            ),
            if (hasDebt)
              Text(
                'مدين',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12.sp,
                ),
              ),
          ],
        ),
        onTap: () {
          // يمكن إضافة تفاصيل العميل هنا
        },
      ),
    );
  }
}
