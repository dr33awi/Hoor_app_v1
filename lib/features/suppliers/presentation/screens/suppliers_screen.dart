import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/suppliers_provider.dart';

/// شاشة الموردين
class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(suppliersProvider.notifier).loadSuppliers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الموردين'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSupplierForm(context),
        icon: const Icon(Icons.add_business),
        label: const Text('مورد جديد'),
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
                  hint: 'البحث عن مورد...',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    ref.read(suppliersProvider.notifier).setSearchQuery(value);
                  },
                ),
                SizedBox(height: 12.h),
                // إحصائيات سريعة
                Row(
                  children: [
                    _StatChip(
                      label: 'إجمالي الموردين',
                      value: '${state.suppliers.length}',
                      icon: Icons.business,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    _StatChip(
                      label: 'مستحقات للموردين',
                      value: '${state.totalDue.toStringAsFixed(0)} ر.س',
                      icon: Icons.account_balance_wallet,
                      color: AppColors.error,
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
                : state.filteredSuppliers.isEmpty
                    ? _EmptyWidget(onAdd: () => _showSupplierForm(context))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: state.filteredSuppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = state.filteredSuppliers[index];
                          return _SupplierCard(
                            supplier: supplier,
                            onTap: () =>
                                _showSupplierDetails(context, supplier),
                            onEdit: () =>
                                _showSupplierForm(context, supplier: supplier),
                            onDelete: () => _deleteSupplier(supplier),
                            onAddPurchase: () =>
                                _showPurchaseDialog(context, supplier),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showSupplierForm(BuildContext context, {SupplierItem? supplier}) {
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final phoneController = TextEditingController(text: supplier?.phone ?? '');
    final emailController = TextEditingController(text: supplier?.email ?? '');
    final addressController =
        TextEditingController(text: supplier?.address ?? '');
    final noteController = TextEditingController(text: supplier?.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(supplier == null ? 'مورد جديد' : 'تعديل المورد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                label: 'اسم المورد',
                hint: 'أدخل اسم المورد',
                prefixIcon: Icons.business,
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
                  const SnackBar(content: Text('يرجى إدخال اسم المورد')),
                );
                return;
              }

              if (supplier == null) {
                ref.read(suppliersProvider.notifier).addSupplier(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                      notes: noteController.text.trim(),
                    );
              } else {
                ref.read(suppliersProvider.notifier).updateSupplier(
                      id: supplier.id,
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                      notes: noteController.text.trim(),
                    );
              }

              Navigator.pop(context);
            },
            child: Text(supplier == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      ),
    );
  }

  void _showSupplierDetails(BuildContext context, SupplierItem supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => _SupplierDetailsSheet(
          supplier: supplier,
          scrollController: scrollController,
          onEdit: () {
            Navigator.pop(context);
            _showSupplierForm(context, supplier: supplier);
          },
          onAddPayment: () => _showPaymentDialog(context, supplier),
          onAddPurchase: () => _showPurchaseDialog(context, supplier),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, SupplierItem supplier) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل دفعة للمورد'),
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
                  const Text('المستحق للمورد'),
                  Text(
                    '${supplier.balance.toStringAsFixed(2)} ر.س',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: supplier.balance > 0
                          ? AppColors.error
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
              hint: 'أدخل المبلغ المدفوع',
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

              ref.read(suppliersProvider.notifier).addPayment(
                    supplierId: supplier.id,
                    amount: amount,
                    note: noteController.text.trim(),
                  );

              Navigator.pop(context);
              Navigator.pop(context);

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

  void _showPurchaseDialog(BuildContext context, SupplierItem supplier) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل مشتريات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.business, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Text(
                    supplier.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: amountController,
              label: 'قيمة المشتريات',
              hint: 'أدخل إجمالي المشتريات',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.shopping_cart,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              controller: noteController,
              label: 'ملاحظة',
              hint: 'وصف المشتريات (اختياري)',
              maxLines: 2,
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
                  const SnackBar(content: Text('يرجى إدخال قيمة صحيحة')),
                );
                return;
              }

              ref.read(suppliersProvider.notifier).addPurchase(
                    supplierId: supplier.id,
                    amount: amount,
                    note: noteController.text.trim(),
                  );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تسجيل المشتريات بنجاح'),
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

  void _deleteSupplier(SupplierItem supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المورد'),
        content: Text(
          supplier.balance != 0
              ? 'هذا المورد لديه رصيد ${supplier.balance.toStringAsFixed(2)} ر.س. هل تريد الحذف؟'
              : 'هل تريد حذف هذا المورد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              ref.read(suppliersProvider.notifier).deleteSupplier(supplier.id);
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
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
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
            Icon(icon, color: color, size: 20.sp),
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

/// بطاقة المورد
class _SupplierCard extends StatelessWidget {
  final SupplierItem supplier;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddPurchase;

  const _SupplierCard({
    required this.supplier,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onAddPurchase,
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
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.business,
                  color: AppColors.secondary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // المعلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (supplier.phone != null && supplier.phone!.isNotEmpty)
                      Text(
                        supplier.phone!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    SizedBox(height: 4.h),
                    Text(
                      'الرصيد: ${supplier.balance.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              // الرصيد
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${supplier.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: supplier.balance > 0
                          ? AppColors.error
                          : supplier.balance < 0
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
                    onTap: onAddPurchase,
                    child: const ListTile(
                      leading: Icon(Icons.shopping_cart),
                      title: Text('مشتريات'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
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

/// ورقة تفاصيل المورد
class _SupplierDetailsSheet extends StatelessWidget {
  final SupplierItem supplier;
  final ScrollController scrollController;
  final VoidCallback onEdit;
  final VoidCallback onAddPayment;
  final VoidCallback onAddPurchase;

  const _SupplierDetailsSheet({
    required this.supplier,
    required this.scrollController,
    required this.onEdit,
    required this.onAddPayment,
    required this.onAddPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الرأس
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child:
                        Icon(Icons.business, color: Colors.white, size: 28.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (supplier.phone != null)
                          Text(
                            supplier.phone!,
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
              // الإحصائيات
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
                      label: 'الرصيد الحالي',
                      value: '${supplier.balance.toStringAsFixed(0)} ر.س',
                    ),
                    _DetailStat(
                      label: 'المستحق',
                      value: '${supplier.balance.toStringAsFixed(2)} ر.س',
                      valueColor: supplier.balance > 0
                          ? AppColors.error
                          : AppColors.success,
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
              if (supplier.email != null || supplier.address != null) ...[
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
                      if (supplier.email != null && supplier.email!.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: Text(supplier.email!),
                        ),
                      if (supplier.address != null &&
                          supplier.address!.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(supplier.address!),
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
                      text: 'مشتريات',
                      onPressed: onAddPurchase,
                      icon: Icons.shopping_cart,
                      backgroundColor: AppColors.secondary,
                    ),
                  ),
                ],
              ),

              if (supplier.notes != null && supplier.notes!.isNotEmpty) ...[
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
                    child: Text(supplier.notes!),
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
            Icons.business_outlined,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد موردين',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'أضف الموردين لتتبع المشتريات والمدفوعات',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          AppButton(
            text: 'إضافة مورد',
            onPressed: onAdd,
            icon: Icons.add_business,
          ),
        ],
      ),
    );
  }
}
