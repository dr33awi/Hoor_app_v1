import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/cash_provider.dart';

/// شاشة الصندوق والمالية
class CashScreen extends ConsumerStatefulWidget {
  const CashScreen({super.key});

  @override
  ConsumerState<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends ConsumerState<CashScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cashProvider.notifier).loadCashData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصندوق والمالية'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ملخص', icon: Icon(Icons.dashboard)),
            Tab(text: 'المعاملات', icon: Icon(Icons.swap_horiz)),
            Tab(text: 'التقارير', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewTransactionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('معاملة جديدة'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _SummaryTab(state: state),
                _TransactionsTab(state: state),
                _ReportsTab(state: state),
              ],
            ),
    );
  }

  void _showNewTransactionDialog(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    CashTransactionType selectedType = CashTransactionType.income;
    String selectedCategory = 'عام';

    final categories = {
      CashTransactionType.income: [
        'مبيعات',
        'مبالغ مستلمة',
        'إيداع',
        'إيرادات أخرى',
      ],
      CashTransactionType.expense: [
        'مشتريات',
        'رواتب',
        'إيجار',
        'فواتير',
        'صيانة',
        'مصاريف أخرى',
      ],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.w,
            right: 16.w,
            top: 16.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'معاملة مالية جديدة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // نوع المعاملة
                Text('نوع المعاملة',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'إيراد',
                        icon: Icons.arrow_downward,
                        color: AppColors.success,
                        isSelected: selectedType == CashTransactionType.income,
                        onTap: () {
                          setModalState(() {
                            selectedType = CashTransactionType.income;
                            selectedCategory = categories[selectedType]!.first;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _TypeButton(
                        label: 'مصروف',
                        icon: Icons.arrow_upward,
                        color: AppColors.error,
                        isSelected: selectedType == CashTransactionType.expense,
                        onTap: () {
                          setModalState(() {
                            selectedType = CashTransactionType.expense;
                            selectedCategory = categories[selectedType]!.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // التصنيف
                Text('التصنيف', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: categories[selectedType]!.map((cat) {
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (_) {
                        setModalState(() => selectedCategory = cat);
                      },
                    );
                  }).toList(),
                ),

                SizedBox(height: 16.h),

                // المبلغ
                AppTextField(
                  controller: amountController,
                  label: 'المبلغ',
                  hint: '0.00',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.attach_money,
                  suffixText: 'ر.س',
                ),

                SizedBox(height: 16.h),

                // الوصف
                AppTextField(
                  controller: descriptionController,
                  label: 'الوصف (اختياري)',
                  hint: 'أدخل وصف المعاملة',
                  maxLines: 2,
                ),

                SizedBox(height: 24.h),

                // زر الحفظ
                AppButton(
                  text: 'حفظ المعاملة',
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
                      );
                      return;
                    }

                    ref.read(cashProvider.notifier).addTransaction(
                          type: selectedType,
                          category: selectedCategory,
                          amount: amount,
                          description: descriptionController.text.trim(),
                        );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          selectedType == CashTransactionType.income
                              ? 'تم إضافة الإيراد بنجاح'
                              : 'تم إضافة المصروف بنجاح',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  isFullWidth: true,
                  icon: Icons.save,
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// تبويب الملخص
class _SummaryTab extends StatelessWidget {
  final CashState state;

  const _SummaryTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // الرصيد الحالي
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text(
                  'رصيد الصندوق',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${state.currentBalance.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BalanceItem(
                      label: 'الإيرادات',
                      value: state.totalIncome,
                      icon: Icons.arrow_downward,
                      color: AppColors.success,
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _BalanceItem(
                      label: 'المصروفات',
                      value: state.totalExpenses,
                      icon: Icons.arrow_upward,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // إحصائيات اليوم
          Row(
            children: [
              Text(
                'إحصائيات اليوم',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'المبيعات',
                  value: state.todaySales,
                  icon: Icons.shopping_cart,
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  label: 'المشتريات',
                  value: state.todayPurchases,
                  icon: Icons.shopping_bag,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'المعاملات',
                  value: state.todayTransactionsCount.toDouble(),
                  icon: Icons.swap_horiz,
                  color: AppColors.info,
                  isCount: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  label: 'صافي اليوم',
                  value: state.todayNet,
                  icon: Icons.trending_up,
                  color:
                      state.todayNet >= 0 ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // آخر المعاملات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آخر المعاملات',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          if (state.transactions.isEmpty)
            Container(
              padding: EdgeInsets.all(32.w),
              child: Column(
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: 48.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'لا توجد معاملات',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...state.transactions.take(5).map((t) => _TransactionListItem(
                  transaction: t,
                )),
        ],
      ),
    );
  }
}

/// عنصر الرصيد
class _BalanceItem extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;

  const _BalanceItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.sp,
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)} ر.س',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// بطاقة إحصائية
class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final bool isCount;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isCount
                        ? '${value.toInt()}'
                        : '${value.toStringAsFixed(0)} ر.س',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// تبويب المعاملات
class _TransactionsTab extends ConsumerWidget {
  final CashState state;

  const _TransactionsTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // فلاتر
        Container(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: state.filter == CashFilter.all,
                  onSelected: (_) {
                    ref.read(cashProvider.notifier).setFilter(CashFilter.all);
                  },
                ),
                SizedBox(width: 8.w),
                FilterChip(
                  label: const Text('الإيرادات'),
                  selected: state.filter == CashFilter.income,
                  onSelected: (_) {
                    ref
                        .read(cashProvider.notifier)
                        .setFilter(CashFilter.income);
                  },
                  avatar: Icon(Icons.arrow_downward,
                      size: 16, color: AppColors.success),
                ),
                SizedBox(width: 8.w),
                FilterChip(
                  label: const Text('المصروفات'),
                  selected: state.filter == CashFilter.expense,
                  onSelected: (_) {
                    ref
                        .read(cashProvider.notifier)
                        .setFilter(CashFilter.expense);
                  },
                  avatar: Icon(Icons.arrow_upward,
                      size: 16, color: AppColors.error),
                ),
              ],
            ),
          ),
        ),

        // القائمة
        Expanded(
          child: state.filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 64.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'لا توجد معاملات',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: state.filteredTransactions.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final transaction = state.filteredTransactions[index];
                    return _TransactionCard(
                      transaction: transaction,
                      onDelete: () {
                        ref
                            .read(cashProvider.notifier)
                            .deleteTransaction(transaction.id);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// بطاقة معاملة
class _TransactionCard extends StatelessWidget {
  final CashTransactionItem transaction;
  final VoidCallback onDelete;

  const _TransactionCard({
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == CashTransactionType.income;
    final color = isIncome ? AppColors.success : AppColors.error;

    return Card(
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: color,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (transaction.description != null &&
                        transaction.description!.isNotEmpty)
                      Text(
                        transaction.description!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 4.h),
                    Text(
                      DateFormat('yyyy/MM/dd - HH:mm').format(transaction.date),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: color,
                    ),
                  ),
                  Text(
                    'ر.س',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final isIncome = transaction.type == CashTransactionType.income;

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              size: 48.sp,
              color: isIncome ? AppColors.success : AppColors.error,
            ),
            SizedBox(height: 12.h),
            Text(
              '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ر.س',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: isIncome ? AppColors.success : AppColors.error,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              transaction.category,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (transaction.description != null &&
                transaction.description!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                transaction.description!,
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 8.h),
            Text(
              DateFormat('yyyy/MM/dd - HH:mm').format(transaction.date),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              icon: Icon(Icons.delete, color: AppColors.error),
              label: Text(
                'حذف المعاملة',
                style: TextStyle(color: AppColors.error),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

/// عنصر معاملة في القائمة
class _TransactionListItem extends StatelessWidget {
  final CashTransactionItem transaction;

  const _TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == CashTransactionType.income;
    final color = isIncome ? AppColors.success : AppColors.error;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
          ),
        ),
        title: Text(transaction.category),
        subtitle: Text(
          DateFormat('HH:mm').format(transaction.date),
          style: TextStyle(fontSize: 11.sp),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} ر.س',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// تبويب التقارير
class _ReportsTab extends StatelessWidget {
  final CashState state;

  const _ReportsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص المصاريف حسب التصنيف',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12.h),

          // تقسيم المصاريف
          if (state.expensesByCategory.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Center(
                  child: Text(
                    'لا توجد مصاريف لعرضها',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: state.expensesByCategory.entries.map((e) {
                  final percentage = (e.value / state.totalExpenses * 100);
                  return _CategoryRow(
                    category: e.key,
                    amount: e.value,
                    percentage: percentage,
                  );
                }).toList(),
              ),
            ),

          SizedBox(height: 24.h),

          Text(
            'ملخص الإيرادات حسب التصنيف',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12.h),

          if (state.incomeByCategory.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Center(
                  child: Text(
                    'لا توجد إيرادات لعرضها',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: state.incomeByCategory.entries.map((e) {
                  final percentage = (e.value / state.totalIncome * 100);
                  return _CategoryRow(
                    category: e.key,
                    amount: e.value,
                    percentage: percentage,
                    isIncome: true,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// صف التصنيف
class _CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;
  final bool isIncome;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.percentage,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? AppColors.success : AppColors.error;

    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category),
              Text(
                '${amount.toStringAsFixed(0)} ر.س',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8.h,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// زر النوع
class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
