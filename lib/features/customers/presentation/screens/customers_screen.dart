import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/customers_provider.dart';

/// شاشة العملاء
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customersProvider.notifier).loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العملاء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerForm(context),
        icon: const Icon(Icons.person_add),
        label: const Text('عميل جديد'),
      ),
      body: Column(
        children: [
          // شريط البحث والإحصائيات
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                AppTextField(
                  controller: _searchController,
                  hint: 'البحث عن عميل...',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    ref.read(customersProvider.notifier).setSearchQuery(value);
                  },
                ),
                SizedBox(height: 12.h),
                // إحصائيات سريعة
                Row(
                  children: [
                    _StatChip(
                      label: 'إجمالي العملاء',
                      value: '${state.customers.length}',
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    _StatChip(
                      label: 'رصيد مستحق',
                      value: '${state.totalDue.toStringAsFixed(0)} ر.س',
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // القائمة
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredCustomers.isEmpty
                    ? _EmptyWidget(onAdd: () => _showCustomerForm(context))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: state.filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = state.filteredCustomers[index];
                          return _CustomerCard(
                            customer: customer,
                            onTap: () =>
                                _showCustomerDetails(context, customer),
                            onEdit: () =>
                                _showCustomerForm(context, customer: customer),
                            onDelete: () => _deleteCustomer(customer),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    final state = ref.read(customersProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'تصفية وترتيب',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Divider(height: 1),
            ListTile(
              title: const Text('الترتيب حسب الاسم'),
              leading: Radio<String>(
                value: 'name',
                groupValue: state.sortBy,
                onChanged: (value) {
                  ref.read(customersProvider.notifier).setSortBy(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('الترتيب حسب الرصيد'),
              leading: Radio<String>(
                value: 'balance',
                groupValue: state.sortBy,
                onChanged: (value) {
                  ref.read(customersProvider.notifier).setSortBy(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('الترتيب حسب آخر عملية'),
              leading: Radio<String>(
                value: 'lastPurchase',
                groupValue: state.sortBy,
                onChanged: (value) {
                  ref.read(customersProvider.notifier).setSortBy(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            Divider(),
            SwitchListTile(
              title: const Text('عرض العملاء بدين فقط'),
              value: state.showWithDebt,
              onChanged: (value) {
                ref.read(customersProvider.notifier).setShowWithDebt(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerForm(BuildContext context, {CustomerItem? customer}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final addressController =
        TextEditingController(text: customer?.address ?? '');
    final noteController = TextEditingController(text: customer?.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? 'عميل جديد' : 'تعديل العميل'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                label: 'اسم العميل',
                hint: 'أدخل اسم العميل',
                prefixIcon: Icons.person,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: phoneController,
                label: 'رقم الهاتف',
                hint: 'أدخل رقم الهاتف',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: emailController,
                label: 'البريد الإلكتروني',
                hint: 'أدخل البريد الإلكتروني (اختياري)',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: addressController,
                label: 'العنوان',
                hint: 'أدخل العنوان (اختياري)',
                prefixIcon: Icons.location_on,
              ),
              SizedBox(height: 12.h),
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
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال اسم العميل')),
                );
                return;
              }

              if (customer == null) {
                ref.read(customersProvider.notifier).addCustomer(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                      notes: noteController.text.trim(),
                    );
              } else {
                ref.read(customersProvider.notifier).updateCustomer(
                      id: customer.id,
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                      notes: noteController.text.trim(),
                    );
              }

              Navigator.pop(context);
            },
            child: Text(customer == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, CustomerItem customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _CustomerDetailsSheet(
          customer: customer,
          scrollController: scrollController,
          onEdit: () {
            Navigator.pop(context);
            _showCustomerForm(context, customer: customer);
          },
          onAddPayment: () => _showPaymentDialog(context, customer),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, CustomerItem customer) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل دفعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الرصيد المستحق'),
                  Text(
                    '${customer.balance.toStringAsFixed(2)} ر.س',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: customer.balance > 0
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: amountController,
              label: 'المبلغ',
              hint: 'أدخل المبلغ',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              controller: noteController,
              label: 'ملاحظة',
              hint: 'ملاحظة (اختياري)',
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

              ref.read(customersProvider.notifier).addPayment(
                    customerId: customer.id,
                    amount: amount,
                    note: noteController.text.trim(),
                  );

              Navigator.pop(context);
              Navigator.pop(context); // إغلاق sheet التفاصيل

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تسجيل الدفعة بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('تسجيل'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(CustomerItem customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العميل'),
        content: Text(
          customer.balance != 0
              ? 'هذا العميل لديه رصيد ${customer.balance.toStringAsFixed(2)} ر.س. هل تريد الحذف؟'
              : 'هل تريد حذف هذا العميل؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              ref.read(customersProvider.notifier).deleteCustomer(customer.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

/// شريحة الإحصائيات
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              label.contains('عملاء')
                  ? Icons.people
                  : Icons.account_balance_wallet,
              color: color,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14.sp,
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

/// بطاقة العميل
class _CustomerCard extends StatelessWidget {
  final CustomerItem customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerCard({
    required this.customer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // الأيقونة
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0] : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // المعلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (customer.phone != null && customer.phone!.isNotEmpty)
                      Text(
                        customer.phone!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '${customer.invoicesCount} فاتورة',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${customer.totalPurchases.toStringAsFixed(0)} ر.س',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // الرصيد
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${customer.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: customer.balance > 0
                          ? AppColors.warning
                          : customer.balance < 0
                              ? AppColors.success
                              : AppColors.textSecondary,
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
              // القائمة
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: onEdit,
                    child: const ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('تعديل'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    onTap: onDelete,
                    child: ListTile(
                      leading: Icon(Icons.delete, color: AppColors.error),
                      title:
                          Text('حذف', style: TextStyle(color: AppColors.error)),
                      contentPadding: EdgeInsets.zero,
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
}

/// ورقة تفاصيل العميل
class _CustomerDetailsSheet extends StatelessWidget {
  final CustomerItem customer;
  final ScrollController scrollController;
  final VoidCallback onEdit;
  final VoidCallback onAddPayment;

  const _CustomerDetailsSheet({
    required this.customer,
    required this.scrollController,
    required this.onEdit,
    required this.onAddPayment,
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
                children: [
                  CircleAvatar(
                    radius: 32.r,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0] : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (customer.phone != null)
                          Text(
                            customer.phone!,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // الرصيد
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DetailStat(
                      label: 'إجمالي المشتريات',
                      value:
                          '${customer.totalPurchases.toStringAsFixed(0)} ر.س',
                    ),
                    _DetailStat(
                      label: 'الرصيد',
                      value: '${customer.balance.toStringAsFixed(2)} ر.س',
                      valueColor: customer.balance > 0
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                    _DetailStat(
                      label: 'الفواتير',
                      value: '${customer.invoicesCount}',
                    ),
                  ],
                ),
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
              // معلومات الاتصال
              if (customer.email != null || customer.address != null) ...[
                Text(
                  'معلومات الاتصال',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8.h),
                Card(
                  child: Column(
                    children: [
                      if (customer.email != null && customer.email!.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: Text(customer.email!),
                        ),
                      if (customer.address != null &&
                          customer.address!.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(customer.address!),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // الإجراءات
              Text(
                'الإجراءات',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'تسجيل دفعة',
                      onPressed: onAddPayment,
                      icon: Icons.payment,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AppButton(
                      text: 'فاتورة جديدة',
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: الانتقال لنقطة البيع مع تحديد العميل
                      },
                      icon: Icons.receipt,
                      backgroundColor: AppColors.secondary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // آخر الفواتير
              Text(
                'آخر الفواتير',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 8.h),
              if (customer.recentInvoices.isEmpty)
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      'لا توجد فواتير',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...customer.recentInvoices.map((invoice) => Card(
                      margin: EdgeInsets.only(bottom: 8.h),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.receipt, color: AppColors.primary),
                        ),
                        title: Text('فاتورة #${invoice.id}'),
                        subtitle: Text(
                          DateFormat('yyyy/MM/dd').format(invoice.date),
                        ),
                        trailing: Text(
                          '${invoice.total.toStringAsFixed(2)} ر.س',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),

              if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(
                  'ملاحظات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Text(customer.notes!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// إحصائية تفصيلية
class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}

/// ويدجت فارغة
class _EmptyWidget extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyWidget({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد عملاء',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'أضف عملائك لتتبع مشترياتهم وأرصدتهم',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          AppButton(
            text: 'إضافة عميل',
            onPressed: onAdd,
            icon: Icons.person_add,
          ),
        ],
      ),
    );
  }
}
