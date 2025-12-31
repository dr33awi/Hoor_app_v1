import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/widgets/invoice_widgets.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../data/repositories/voucher_repository.dart';
import '../../../data/repositories/shift_repository.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _supplierRepo = getIt<SupplierRepository>();
  final _database = getIt<AppDatabase>();
  final _currencyService = getIt<CurrencyService>();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name'; // name, balance
  bool _sortDescending = false;
  bool _showOnlyWithBalance = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الموردين'),
        actions: [
          // فلتر الرصيد
          IconButton(
            icon: Icon(
              _showOnlyWithBalance ? Icons.filter_alt : Icons.filter_alt_off,
              color: _showOnlyWithBalance ? AppColors.primary : null,
            ),
            onPressed: () {
              setState(() => _showOnlyWithBalance = !_showOnlyWithBalance);
            },
            tooltip: _showOnlyWithBalance ? 'إظهار الكل' : 'إظهار من لهم رصيد',
          ),
          // ترتيب
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _sortDescending = !_sortDescending;
                } else {
                  _sortBy = value;
                  _sortDescending = value == 'balance';
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'name'
                          ? (_sortDescending
                              ? Icons.arrow_downward
                              : Icons.arrow_upward)
                          : Icons.sort_by_alpha,
                      size: 18,
                    ),
                    Gap(8.w),
                    const Text('الاسم'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'balance',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'balance'
                          ? (_sortDescending
                              ? Icons.arrow_downward
                              : Icons.arrow_upward)
                          : Icons.account_balance_wallet,
                      size: 18,
                    ),
                    Gap(8.w),
                    const Text('الرصيد'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث عن مورد...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Suppliers List
          Expanded(
            child: StreamBuilder<List<Supplier>>(
              stream: _supplierRepo.watchAllSuppliers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var suppliers = snapshot.data ?? [];

                // فلترة البحث
                if (_searchQuery.isNotEmpty) {
                  suppliers = suppliers
                      .where((s) =>
                          s.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          (s.phone?.contains(_searchQuery) ?? false))
                      .toList();
                }

                // فلترة الرصيد
                if (_showOnlyWithBalance) {
                  suppliers = suppliers.where((s) => s.balance > 0).toList();
                }

                // ترتيب
                suppliers.sort((a, b) {
                  int compare;
                  switch (_sortBy) {
                    case 'balance':
                      compare = a.balance.compareTo(b.balance);
                      break;
                    case 'name':
                    default:
                      compare = a.name.compareTo(b.name);
                  }
                  return _sortDescending ? -compare : compare;
                });

                if (suppliers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        Gap(16.h),
                        Text(
                          _showOnlyWithBalance
                              ? 'لا يوجد موردين لهم رصيد'
                              : 'لا يوجد موردين',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // حساب الإجمالي
                final totalBalance =
                    suppliers.fold<double>(0, (sum, s) => sum + s.balance);

                return Column(
                  children: [
                    // ملخص الإجمالي
                    if (suppliers.isNotEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.suppliers.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إجمالي الالتزامات: ${suppliers.length} مورد',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.suppliers,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _currencyService.formatSyp(totalBalance),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                                FutureBuilder<double>(
                                  future: _calculateTotalUsd(suppliers),
                                  builder: (context, snapshot) {
                                    return Text(
                                      '\$${(snapshot.data ?? 0).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Gap(8.h),

                    // قائمة الموردين
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: suppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = suppliers[index];
                          return _SupplierCard(
                            supplier: supplier,
                            database: _database,
                            currencyService: _currencyService,
                            onTap: () => _showSupplierDetails(supplier),
                            onEdit: () => _showSupplierDialog(supplier),
                            onDelete: () => _deleteSupplier(supplier),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSupplierDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<double> _calculateTotalUsd(List<Supplier> suppliers) async {
    double total = 0;
    for (final supplier in suppliers) {
      if (supplier.balance > 0) {
        total += await _database.getSupplierBalanceInUsd(supplier.id);
      }
    }
    return total;
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    // التحقق من وجود فواتير للمورد
    final invoices = await _database.getInvoicesBySupplier(supplier.id);
    if (invoices.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'لا يمكن حذف المورد لأنه مرتبط بـ ${invoices.length} فاتورة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المورد "${supplier.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _supplierRepo.deleteSupplier(supplier.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المورد بنجاح')),
      );
    }
  }

  void _showSupplierDialog(Supplier? supplier) {
    final nameController = TextEditingController(text: supplier?.name);
    final phoneController = TextEditingController(text: supplier?.phone);
    final emailController = TextEditingController(text: supplier?.email);
    final addressController = TextEditingController(text: supplier?.address);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(supplier == null ? 'إضافة مورد' : 'تعديل مورد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المورد *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              Gap(12.h),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              Gap(12.h),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              Gap(12.h),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              Navigator.pop(context);

              if (supplier == null) {
                await _supplierRepo.createSupplier(
                  name: nameController.text,
                  phone: phoneController.text.isEmpty
                      ? null
                      : phoneController.text,
                  email: emailController.text.isEmpty
                      ? null
                      : emailController.text,
                  address: addressController.text.isEmpty
                      ? null
                      : addressController.text,
                );
              } else {
                await _supplierRepo.updateSupplier(
                  id: supplier.id,
                  name: nameController.text,
                  phone: phoneController.text.isEmpty
                      ? null
                      : phoneController.text,
                  email: emailController.text.isEmpty
                      ? null
                      : emailController.text,
                  address: addressController.text.isEmpty
                      ? null
                      : addressController.text,
                );
              }
            },
            child: Text(supplier == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      ),
    );
  }

  void _showSupplierDetails(Supplier supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SupplierDetailsSheet(
        supplier: supplier,
        database: _database,
        currencyService: _currencyService,
        onEdit: () {
          Navigator.pop(context);
          _showSupplierDialog(supplier);
        },
        onCreateVoucher: () {
          Navigator.pop(context);
          _showCreatePaymentVoucher(supplier);
        },
      ),
    );
  }

  void _showCreatePaymentVoucher(Supplier supplier) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('سند صرف - ${supplier.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // رصيد المورد الحالي
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الرصيد الحالي:'),
                    Text(
                      _currencyService.formatSyp(supplier.balance),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(16.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المبلغ المدفوع *',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'ل.س',
                ),
              ),
              Gap(12.h),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                // الحصول على الوردية المفتوحة
                final shiftRepo = getIt<ShiftRepository>();
                final openShift = await shiftRepo.getOpenShift();

                final voucherRepo = getIt<VoucherRepository>();
                await voucherRepo.createVoucher(
                  type: VoucherType.payment,
                  amount: amount,
                  supplierId: supplier.id,
                  description: descriptionController.text.isNotEmpty
                      ? descriptionController.text
                      : 'سند صرف إلى ${supplier.name}',
                  shiftId: openShift?.id,
                );

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إنشاء سند الصرف بنجاح'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('إنشاء السند'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// بطاقة المورد
// ═══════════════════════════════════════════════════════════════════════════
class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final AppDatabase database;
  final CurrencyService currencyService;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.database,
    required this.currencyService,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasBalance = supplier.balance > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: hasBalance
                    ? AppColors.warning.withOpacity(0.2)
                    : AppColors.suppliers.withOpacity(0.2),
                child: Text(
                  supplier.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasBalance ? AppColors.warning : AppColors.suppliers,
                  ),
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (supplier.phone != null)
                      Text(
                        supplier.phone!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // عرض الرصيد
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyService.formatSyp(supplier.balance),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: hasBalance ? AppColors.warning : AppColors.success,
                      fontSize: 13.sp,
                    ),
                  ),
                  FutureBuilder<double>(
                    future: database.getSupplierBalanceInUsd(supplier.id),
                    builder: (context, snapshot) {
                      return Text(
                        '\$${(snapshot.data ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Gap(8.w),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ],
                    ),
                    onTap: onEdit,
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                    onTap: onDelete,
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

// ═══════════════════════════════════════════════════════════════════════════
// صفحة تفاصيل المورد
// ═══════════════════════════════════════════════════════════════════════════
class _SupplierDetailsSheet extends StatefulWidget {
  final Supplier supplier;
  final AppDatabase database;
  final CurrencyService currencyService;
  final VoidCallback onEdit;
  final VoidCallback onCreateVoucher;

  const _SupplierDetailsSheet({
    required this.supplier,
    required this.database,
    required this.currencyService,
    required this.onEdit,
    required this.onCreateVoucher,
  });

  @override
  State<_SupplierDetailsSheet> createState() => _SupplierDetailsSheetState();
}

class _SupplierDetailsSheetState extends State<_SupplierDetailsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Supplier Info Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppColors.suppliers.withOpacity(0.2),
                  child: Text(
                    widget.supplier.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.suppliers,
                    ),
                  ),
                ),
                Gap(16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.supplier.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.supplier.phone != null)
                        Text(
                          widget.supplier.phone!,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: widget.onEdit,
                ),
              ],
            ),
            Gap(16.h),

            // بطاقة الرصيد
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.supplier.balance > 0
                      ? [AppColors.warning, AppColors.warning.withOpacity(0.7)]
                      : [AppColors.success, AppColors.success.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الرصيد الحالي',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        widget.currencyService
                            .formatSyp(widget.supplier.balance),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FutureBuilder<double>(
                        future: widget.database
                            .getSupplierBalanceInUsd(widget.supplier.id),
                        builder: (context, snapshot) {
                          return Text(
                            '\$${(snapshot.data ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (widget.supplier.balance > 0)
                    ElevatedButton.icon(
                      onPressed: widget.onCreateVoucher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.warning,
                      ),
                      icon: const Icon(Icons.payment),
                      label: const Text('سند صرف'),
                    ),
                ],
              ),
            ),
            Gap(16.h),

            // التبويبات
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              tabs: const [
                Tab(text: 'ملخص'),
                Tab(text: 'الفواتير'),
                Tab(text: 'كشف حساب'),
              ],
            ),

            // محتوى التبويبات
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // تبويب الملخص
                  _buildSummaryTab(scrollController),
                  // تبويب الفواتير
                  _buildInvoicesTab(scrollController),
                  // تبويب كشف الحساب
                  _buildStatementTab(scrollController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          Gap(16.h),
          // ملخص الإحصائيات
          FutureBuilder<Map<String, double>>(
            future: widget.database.getSupplierSummary(widget.supplier.id),
            builder: (context, snapshot) {
              final summary = snapshot.data ?? {};
              return Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      label: 'إجمالي المشتريات',
                      value: formatPrice(
                          (summary['totalPurchases'] ?? 0).toDouble()),
                      color: AppColors.warning,
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: _SummaryItem(
                      label: 'المرتجعات',
                      value: formatPrice(
                          (summary['totalReturns'] ?? 0).toDouble()),
                      color: AppColors.success,
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: _SummaryItem(
                      label: 'عدد الفواتير',
                      value:
                          '${(summary['invoiceCount'] ?? 0).toStringAsFixed(0)}',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              );
            },
          ),
          Gap(16.h),

          // معلومات الاتصال
          if (widget.supplier.email != null ||
              widget.supplier.address != null) ...[
            const Divider(),
            Gap(8.h),
            if (widget.supplier.email != null)
              _DetailRow(
                icon: Icons.email,
                label: 'البريد',
                value: widget.supplier.email!,
              ),
            if (widget.supplier.address != null)
              _DetailRow(
                icon: Icons.location_on,
                label: 'العنوان',
                value: widget.supplier.address!,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoicesTab(ScrollController scrollController) {
    return StreamBuilder<List<Invoice>>(
      stream: widget.database.watchInvoicesBySupplier(widget.supplier.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final invoices = snapshot.data ?? [];

        if (invoices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 48.sp, color: Colors.grey),
                Gap(8.h),
                const Text('لا توجد فواتير',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return InvoiceCard(
              invoice: invoice,
              compact: true,
              onTap: () => context.pushNamed(
                'invoice-details',
                pathParameters: {'id': invoice.id},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatementTab(ScrollController scrollController) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAccountStatement(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 48.sp, color: Colors.grey),
                Gap(8.h),
                const Text('لا توجد حركات',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        double runningBalance = 0;

        return ListView.builder(
          controller: scrollController,
          itemCount: transactions.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // عنوان الكشف
              return Container(
                padding: EdgeInsets.all(12.w),
                margin: EdgeInsets.only(bottom: 8.h, top: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text('التاريخ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 11.sp))),
                    Expanded(
                        flex: 3,
                        child: Text('البيان',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 11.sp))),
                    Expanded(
                        flex: 2,
                        child: Text('مدين',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                                color: AppColors.warning))),
                    Expanded(
                        flex: 2,
                        child: Text('دائن',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                                color: AppColors.success))),
                    Expanded(
                        flex: 2,
                        child: Text('الرصيد',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 11.sp))),
                  ],
                ),
              );
            }

            final tx = transactions[index - 1];
            final debit = tx['debit'] as double;
            final credit = tx['credit'] as double;
            runningBalance += debit - credit;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      DateFormat('dd/MM').format(tx['date'] as DateTime),
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      tx['description'] as String,
                      style: TextStyle(fontSize: 10.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      debit > 0 ? formatPrice(debit) : '',
                      style:
                          TextStyle(fontSize: 10.sp, color: AppColors.warning),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      credit > 0 ? formatPrice(credit) : '',
                      style:
                          TextStyle(fontSize: 10.sp, color: AppColors.success),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      formatPrice(runningBalance),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: runningBalance > 0
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getAccountStatement() async {
    final List<Map<String, dynamic>> transactions = [];

    // جلب الفواتير
    final invoices =
        await widget.database.getInvoicesBySupplier(widget.supplier.id);
    for (final invoice in invoices) {
      if (invoice.type == 'purchase') {
        transactions.add({
          'date': invoice.invoiceDate,
          'description': 'فاتورة شراء #${invoice.invoiceNumber}',
          'debit': invoice.total,
          'credit': 0.0,
        });
      } else if (invoice.type == 'purchase_return') {
        transactions.add({
          'date': invoice.invoiceDate,
          'description': 'مرتجع #${invoice.invoiceNumber}',
          'debit': 0.0,
          'credit': invoice.total,
        });
      }
    }

    // جلب سندات الدفع
    final vouchers =
        await widget.database.getVouchersBySupplier(widget.supplier.id);
    for (final voucher in vouchers) {
      if (voucher.type == 'payment') {
        transactions.add({
          'date': voucher.voucherDate,
          'description': 'سند صرف #${voucher.voucherNumber}',
          'debit': 0.0,
          'credit': voucher.amount,
        });
      }
    }

    // ترتيب حسب التاريخ
    transactions.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return transactions;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widgets مساعدة
// ═══════════════════════════════════════════════════════════════════════════
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.textSecondary),
          Gap(12.w),
          Text('$label:', style: TextStyle(color: AppColors.textSecondary)),
          Gap(8.w),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          Gap(4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
