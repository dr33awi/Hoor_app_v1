import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/shifts_provider.dart';

/// شاشة إدارة الورديات
class ShiftsScreen extends ConsumerStatefulWidget {
  const ShiftsScreen({super.key});

  @override
  ConsumerState<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends ConsumerState<ShiftsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shiftsProvider.notifier).loadShifts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shiftsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الورديات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الوردية الحالية'),
            Tab(text: 'سجل الورديات'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // الوردية الحالية
                _CurrentShiftTab(
                  currentShift: state.currentShift,
                  onOpen: () => _openShift(context),
                  onClose: () => _closeShift(context),
                  onAddCash: () => _addCash(context),
                  onWithdrawCash: () => _withdrawCash(context),
                ),
                // سجل الورديات
                _ShiftsHistoryTab(
                  shifts: state.shifts,
                  onViewDetails: (shift) => _showShiftDetails(context, shift),
                ),
              ],
            ),
    );
  }

  void _openShift(BuildContext context) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فتح وردية جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'يرجى إدخال الرصيد الافتتاحي للصندوق',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: amountController,
              label: 'الرصيد الافتتاحي',
              hint: '0.00',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              ref
                  .read(shiftsProvider.notifier)
                  .openShift(openingBalance: amount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم فتح الوردية بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('فتح الوردية'),
          ),
        ],
      ),
    );
  }

  void _closeShift(BuildContext context) {
    final state = ref.read(shiftsProvider);
    final currentShift = state.currentShift;

    if (currentShift == null) return;

    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final enteredAmount = double.tryParse(amountController.text) ?? 0;
          final difference = enteredAmount - currentShift.expectedCash;

          return AlertDialog(
            title: const Text('إغلاق الوردية'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ملخص الوردية
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'الرصيد الافتتاحي',
                          value:
                              '${currentShift.openingBalance.toStringAsFixed(2)} ر.س',
                        ),
                        _SummaryRow(
                          label: 'المبيعات النقدية',
                          value:
                              '${currentShift.cashSales.toStringAsFixed(2)} ر.س',
                          valueColor: AppColors.success,
                        ),
                        _SummaryRow(
                          label: 'المبيعات بالبطاقة',
                          value:
                              '${currentShift.cardSales.toStringAsFixed(2)} ر.س',
                        ),
                        _SummaryRow(
                          label: 'الإضافات',
                          value:
                              '+${currentShift.cashIn.toStringAsFixed(2)} ر.س',
                          valueColor: AppColors.success,
                        ),
                        _SummaryRow(
                          label: 'السحوبات',
                          value:
                              '-${currentShift.cashOut.toStringAsFixed(2)} ر.س',
                          valueColor: AppColors.error,
                        ),
                        Divider(height: 16.h),
                        _SummaryRow(
                          label: 'المتوقع في الصندوق',
                          value:
                              '${currentShift.expectedCash.toStringAsFixed(2)} ر.س',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // إدخال المبلغ الفعلي
                  AppTextField(
                    controller: amountController,
                    label: 'المبلغ الفعلي في الصندوق',
                    hint: '0.00',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.calculate,
                    onChanged: (_) => setState(() {}),
                  ),

                  SizedBox(height: 8.h),

                  // الفرق
                  if (amountController.text.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: difference == 0
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الفرق:',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          Text(
                            '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(2)} ر.س',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: difference == 0
                                  ? AppColors.success
                                  : difference > 0
                                      ? AppColors.success
                                      : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 16.h),

                  // ملاحظات
                  AppTextField(
                    controller: noteController,
                    label: 'ملاحظات',
                    hint: 'ملاحظات إضافية (اختياري)',
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  final actualAmount =
                      double.tryParse(amountController.text) ?? 0;
                  ref.read(shiftsProvider.notifier).closeShift(
                        closingBalance: actualAmount,
                        note: noteController.text.trim(),
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إغلاق الوردية بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('إغلاق الوردية'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addCash(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة نقدية للصندوق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: amountController,
              label: 'المبلغ',
              hint: '0.00',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.add,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              controller: noteController,
              label: 'السبب',
              hint: 'سبب الإضافة',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
                );
                return;
              }
              ref.read(shiftsProvider.notifier).addCash(
                    amount: amount,
                    note: noteController.text.trim(),
                  );
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _withdrawCash(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سحب نقدية من الصندوق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: amountController,
              label: 'المبلغ',
              hint: '0.00',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.remove,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              controller: noteController,
              label: 'السبب',
              hint: 'سبب السحب',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
                );
                return;
              }
              ref.read(shiftsProvider.notifier).withdrawCash(
                    amount: amount,
                    note: noteController.text.trim(),
                  );
              Navigator.pop(context);
            },
            child: const Text('سحب'),
          ),
        ],
      ),
    );
  }

  void _showShiftDetails(BuildContext context, ShiftItem shift) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _ShiftDetailsSheet(
          shift: shift,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

/// تبويب الوردية الحالية
class _CurrentShiftTab extends StatelessWidget {
  final ShiftItem? currentShift;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final VoidCallback onAddCash;
  final VoidCallback onWithdrawCash;

  const _CurrentShiftTab({
    this.currentShift,
    required this.onOpen,
    required this.onClose,
    required this.onAddCash,
    required this.onWithdrawCash,
  });

  @override
  Widget build(BuildContext context) {
    if (currentShift == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد وردية مفتوحة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'افتح وردية جديدة لبدء البيع',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),
            AppButton(
              text: 'فتح وردية',
              onPressed: onOpen,
              icon: Icons.play_arrow,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // حالة الوردية
        Card(
          color: AppColors.success.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, color: AppColors.success),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوردية مفتوحة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'منذ ${DateFormat('HH:mm').format(currentShift!.startTime)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _getDuration(currentShift!.startTime),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // إحصائيات الوردية
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'المبيعات',
                value: '${currentShift!.totalSales.toStringAsFixed(0)}',
                subtitle: 'ر.س',
                icon: Icons.shopping_cart,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _StatCard(
                title: 'الفواتير',
                value: '${currentShift!.invoicesCount}',
                subtitle: 'فاتورة',
                icon: Icons.receipt,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'نقدي',
                value: '${currentShift!.cashSales.toStringAsFixed(0)}',
                subtitle: 'ر.س',
                icon: Icons.payments,
                color: AppColors.success,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _StatCard(
                title: 'بطاقة',
                value: '${currentShift!.cardSales.toStringAsFixed(0)}',
                subtitle: 'ر.س',
                icon: Icons.credit_card,
                color: AppColors.info,
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // تفاصيل الصندوق
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل الصندوق',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 12.h),
                _SummaryRow(
                  label: 'الرصيد الافتتاحي',
                  value:
                      '${currentShift!.openingBalance.toStringAsFixed(2)} ر.س',
                ),
                _SummaryRow(
                  label: 'المبيعات النقدية',
                  value: '+${currentShift!.cashSales.toStringAsFixed(2)} ر.س',
                  valueColor: AppColors.success,
                ),
                _SummaryRow(
                  label: 'الإضافات',
                  value: '+${currentShift!.cashIn.toStringAsFixed(2)} ر.س',
                  valueColor: AppColors.success,
                ),
                _SummaryRow(
                  label: 'السحوبات',
                  value: '-${currentShift!.cashOut.toStringAsFixed(2)} ر.س',
                  valueColor: AppColors.error,
                ),
                Divider(height: 24.h),
                _SummaryRow(
                  label: 'المتوقع في الصندوق',
                  value: '${currentShift!.expectedCash.toStringAsFixed(2)} ر.س',
                  isBold: true,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // إجراءات
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'إضافة نقدية',
                onPressed: onAddCash,
                icon: Icons.add,
                backgroundColor: AppColors.success,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AppButton(
                text: 'سحب نقدية',
                onPressed: onWithdrawCash,
                icon: Icons.remove,
                backgroundColor: AppColors.warning,
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // إغلاق الوردية
        AppButton(
          text: 'إغلاق الوردية',
          onPressed: onClose,
          icon: Icons.stop_circle,
          backgroundColor: AppColors.error,
          isFullWidth: true,
        ),
      ],
    );
  }

  String _getDuration(DateTime start) {
    final duration = DateTime.now().difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}س ${minutes}د';
  }
}

/// بطاقة إحصائية
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
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
                Icon(icon, color: color, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                    color: color,
                  ),
                ),
                SizedBox(width: 4.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// صف ملخص
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
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
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 14.sp : 13.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 14.sp : 13.sp,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// تبويب سجل الورديات
class _ShiftsHistoryTab extends StatelessWidget {
  final List<ShiftItem> shifts;
  final Function(ShiftItem) onViewDetails;

  const _ShiftsHistoryTab({
    required this.shifts,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (shifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا يوجد سجل ورديات',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: shifts.length,
      itemBuilder: (context, index) {
        final shift = shifts[index];
        return _ShiftHistoryCard(
          shift: shift,
          onTap: () => onViewDetails(shift),
        );
      },
    );
  }
}

/// بطاقة سجل الوردية
class _ShiftHistoryCard extends StatelessWidget {
  final ShiftItem shift;
  final VoidCallback onTap;

  const _ShiftHistoryCard({
    required this.shift,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = shift.endTime == null;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: (isOpen ? AppColors.success : AppColors.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isOpen ? Icons.play_circle : Icons.check_circle,
                  color: isOpen ? AppColors.success : AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('yyyy/MM/dd').format(shift.startTime),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: (isOpen
                                    ? AppColors.success
                                    : AppColors.textSecondary)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            isOpen ? 'مفتوحة' : 'مغلقة',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isOpen
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${DateFormat('HH:mm').format(shift.startTime)} - ${shift.endTime != null ? DateFormat('HH:mm').format(shift.endTime!) : 'الآن'}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${shift.invoicesCount} فاتورة',
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
                    '${shift.totalSales.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'ر.س',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_left, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// ورقة تفاصيل الوردية
class _ShiftDetailsSheet extends StatelessWidget {
  final ShiftItem shift;
  final ScrollController scrollController;

  const _ShiftDetailsSheet({
    required this.shift,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الرأس
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تفاصيل الوردية',
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
              SizedBox(height: 8.h),
              Text(
                DateFormat('yyyy/MM/dd - EEEE', 'ar').format(shift.startTime),
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        // المحتوى
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.all(16.w),
            children: [
              // الوقت
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوقت',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: 12.h),
                      _SummaryRow(
                        label: 'وقت البدء',
                        value: DateFormat('HH:mm').format(shift.startTime),
                      ),
                      _SummaryRow(
                        label: 'وقت الانتهاء',
                        value: shift.endTime != null
                            ? DateFormat('HH:mm').format(shift.endTime!)
                            : 'مستمرة',
                      ),
                      if (shift.endTime != null)
                        _SummaryRow(
                          label: 'المدة',
                          value: _getDuration(shift.startTime, shift.endTime!),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // المبيعات
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبيعات',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: 12.h),
                      _SummaryRow(
                        label: 'عدد الفواتير',
                        value: '${shift.invoicesCount}',
                      ),
                      _SummaryRow(
                        label: 'المبيعات النقدية',
                        value: '${shift.cashSales.toStringAsFixed(2)} ر.س',
                      ),
                      _SummaryRow(
                        label: 'المبيعات بالبطاقة',
                        value: '${shift.cardSales.toStringAsFixed(2)} ر.س',
                      ),
                      Divider(height: 16.h),
                      _SummaryRow(
                        label: 'إجمالي المبيعات',
                        value: '${shift.totalSales.toStringAsFixed(2)} ر.س',
                        isBold: true,
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // الصندوق
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الصندوق',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: 12.h),
                      _SummaryRow(
                        label: 'الرصيد الافتتاحي',
                        value: '${shift.openingBalance.toStringAsFixed(2)} ر.س',
                      ),
                      _SummaryRow(
                        label: 'الإضافات',
                        value: '+${shift.cashIn.toStringAsFixed(2)} ر.س',
                        valueColor: AppColors.success,
                      ),
                      _SummaryRow(
                        label: 'السحوبات',
                        value: '-${shift.cashOut.toStringAsFixed(2)} ر.س',
                        valueColor: AppColors.error,
                      ),
                      Divider(height: 16.h),
                      _SummaryRow(
                        label: 'المتوقع',
                        value: '${shift.expectedCash.toStringAsFixed(2)} ر.س',
                      ),
                      if (shift.closingBalance != null) ...[
                        _SummaryRow(
                          label: 'الفعلي',
                          value:
                              '${shift.closingBalance!.toStringAsFixed(2)} ر.س',
                        ),
                        _SummaryRow(
                          label: 'الفرق',
                          value: '${shift.difference.toStringAsFixed(2)} ر.س',
                          valueColor: shift.difference == 0
                              ? AppColors.success
                              : shift.difference > 0
                                  ? AppColors.success
                                  : AppColors.error,
                          isBold: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours} ساعة و ${minutes} دقيقة';
  }
}
