import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/currency_service.dart';
import '../../../data/database/app_database.dart';

/// نموذج بيانات المورد مع رصيد الدولار المحسوب من سعر الصرف المحفوظ
class SupplierWithUsdBalance {
  final Supplier supplier;
  final double usdBalance;

  SupplierWithUsdBalance({required this.supplier, required this.usdBalance});
}

/// ═══════════════════════════════════════════════════════════════════════════
/// تقرير الذمم الدائنة (ديون للموردين)
/// ═══════════════════════════════════════════════════════════════════════════
class PayablesReportScreen extends ConsumerStatefulWidget {
  const PayablesReportScreen({super.key});

  @override
  ConsumerState<PayablesReportScreen> createState() =>
      _PayablesReportScreenState();
}

class _PayablesReportScreenState extends ConsumerState<PayablesReportScreen> {
  final _db = getIt<AppDatabase>();
  final _currencyService = getIt<CurrencyService>();
  String _sortBy = 'balance';
  bool _sortDescending = true;
  bool _showOnlyWithBalance = true;
  bool _isLoading = true;
  List<SupplierWithUsdBalance> _suppliersWithUsd = [];
  double _totalUsd = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final suppliers = await _db.getAllSuppliers();
    final List<SupplierWithUsdBalance> result = [];
    double totalUsd = 0;

    for (final supplier in suppliers) {
      if (_showOnlyWithBalance && supplier.balance <= 0) continue;

      // حساب الدولار من سعر الصرف المحفوظ لكل فاتورة وسند
      final usdBalance = await _db.getSupplierBalanceInUsd(supplier.id);
      result.add(SupplierWithUsdBalance(
        supplier: supplier,
        usdBalance: usdBalance,
      ));
      if (supplier.balance > 0) {
        totalUsd += usdBalance;
      }
    }

    // ترتيب القائمة
    result.sort((a, b) {
      int compare;
      switch (_sortBy) {
        case 'name':
          compare = a.supplier.name.compareTo(b.supplier.name);
          break;
        case 'balance':
        default:
          compare = a.supplier.balance.compareTo(b.supplier.balance);
      }
      return _sortDescending ? -compare : compare;
    });

    setState(() {
      _suppliersWithUsd = result;
      _totalUsd = totalUsd;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الذمم الدائنة'),
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
                _showOnlyWithBalance ? 'إظهار الكل' : 'إظهار من لهم رصيد فقط',
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
    final totalPayables = _suppliersWithUsd.fold<double>(
        0, (sum, s) => sum + (s.supplier.balance > 0 ? s.supplier.balance : 0));
    final suppliersWithCredit =
        _suppliersWithUsd.where((s) => s.supplier.balance > 0).length;

    return Column(
      children: [
        // ملخص الذمم الدائنة
        Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.suppliers,
                AppColors.suppliers.withOpacity(0.7)
              ],
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
                        'إجمالي الذمم الدائنة',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        _currencyService.formatSyp(totalPayables),
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
                      Icons.local_shipping,
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
                    label: 'عدد الموردين الدائنين',
                    value: '$suppliersWithCredit',
                  ),
                  _SummaryItem(
                    label: 'متوسط الدين',
                    value: suppliersWithCredit > 0
                        ? _currencyService
                            .formatSyp(totalPayables / suppliersWithCredit)
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

        // قائمة الموردين
        Expanded(
          child: _suppliersWithUsd.isEmpty
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
                        'لا توجد ذمم دائنة',
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
                  itemCount: _suppliersWithUsd.length,
                  itemBuilder: (context, index) {
                    final item = _suppliersWithUsd[index];
                    return _SupplierDebtCard(
                      supplier: item.supplier,
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

class _SupplierDebtCard extends StatelessWidget {
  final Supplier supplier;
  final double usdBalance;
  final CurrencyService currencyService;

  const _SupplierDebtCard({
    required this.supplier,
    required this.usdBalance,
    required this.currencyService,
  });

  @override
  Widget build(BuildContext context) {
    final hasCredit = supplier.balance > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hasCredit
              ? AppColors.warning.withOpacity(0.1)
              : AppColors.success.withOpacity(0.1),
          child: Icon(
            hasCredit ? Icons.account_balance : Icons.check,
            color: hasCredit ? AppColors.warning : AppColors.success,
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: supplier.phone != null ? Text(supplier.phone!) : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyService.formatSyp(supplier.balance),
              style: TextStyle(
                color: hasCredit ? AppColors.warning : AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            Text(
              '\$${usdBalance.toStringAsFixed(2)}',
              style: TextStyle(
                color: hasCredit
                    ? AppColors.warning.withOpacity(0.7)
                    : AppColors.success.withOpacity(0.7),
                fontSize: 12.sp,
              ),
            ),
            if (hasCredit)
              Text(
                'مستحق',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 12.sp,
                ),
              ),
          ],
        ),
        onTap: () {
          // يمكن إضافة تفاصيل المورد هنا
        },
      ),
    );
  }
}
