import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/returns_provider.dart';

/// شاشة المرتجعات
class ReturnsScreen extends ConsumerStatefulWidget {
  const ReturnsScreen({super.key});

  @override
  ConsumerState<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends ConsumerState<ReturnsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(returnsProvider.notifier).loadReturns();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(returnsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المرتجعات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewReturnDialog(context),
        icon: const Icon(Icons.assignment_return),
        label: const Text('مرتجع جديد'),
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
                  hint: 'البحث برقم الفاتورة...',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    ref.read(returnsProvider.notifier).setSearchQuery(value);
                  },
                ),
                SizedBox(height: 12.h),
                // إحصائيات
                Row(
                  children: [
                    _StatChip(
                      label: 'إجمالي المرتجعات',
                      value: '${state.returns.length}',
                      icon: Icons.assignment_return,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 8.w),
                    _StatChip(
                      label: 'قيمة المرتجعات',
                      value:
                          '${state.totalReturnsValue.toStringAsFixed(0)} ر.س',
                      icon: Icons.money_off,
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
                : state.filteredReturns.isEmpty
                    ? _EmptyWidget(onAdd: () => _showNewReturnDialog(context))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: state.filteredReturns.length,
                        itemBuilder: (context, index) {
                          final returnItem = state.filteredReturns[index];
                          return _ReturnCard(
                            returnItem: returnItem,
                            onTap: () =>
                                _showReturnDetails(context, returnItem),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    final state = ref.read(returnsProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تصفية المرتجعات',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(returnsProvider.notifier).clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('مسح الكل'),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الفترة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    children: [
                      FilterChip(
                        label: const Text('اليوم'),
                        selected: state.dateFilter == 'today',
                        onSelected: (_) {
                          ref
                              .read(returnsProvider.notifier)
                              .setDateFilter('today');
                        },
                      ),
                      FilterChip(
                        label: const Text('هذا الأسبوع'),
                        selected: state.dateFilter == 'week',
                        onSelected: (_) {
                          ref
                              .read(returnsProvider.notifier)
                              .setDateFilter('week');
                        },
                      ),
                      FilterChip(
                        label: const Text('هذا الشهر'),
                        selected: state.dateFilter == 'month',
                        onSelected: (_) {
                          ref
                              .read(returnsProvider.notifier)
                              .setDateFilter('month');
                        },
                      ),
                      FilterChip(
                        label: const Text('الكل'),
                        selected: state.dateFilter == 'all',
                        onSelected: (_) {
                          ref
                              .read(returnsProvider.notifier)
                              .setDateFilter('all');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewReturnDialog(BuildContext context) {
    final invoiceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مرتجع جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'أدخل رقم الفاتورة للبحث عنها وإنشاء مرتجع',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: invoiceController,
              label: 'رقم الفاتورة',
              hint: 'أدخل رقم الفاتورة',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.receipt,
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
              final invoiceId = int.tryParse(invoiceController.text);
              if (invoiceId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال رقم فاتورة صحيح')),
                );
                return;
              }
              Navigator.pop(context);
              _processReturn(context, invoiceId);
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _processReturn(BuildContext context, int invoiceId) async {
    final invoice =
        await ref.read(returnsProvider.notifier).getInvoiceForReturn(invoiceId);

    if (invoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم يتم العثور على الفاتورة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // عرض تفاصيل الفاتورة للمرتجع
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _ReturnProcessSheet(
          invoice: invoice,
          scrollController: scrollController,
          onConfirm: (items, reason) {
            ref.read(returnsProvider.notifier).createReturn(
                  invoiceId: invoiceId,
                  items: items,
                  reason: reason,
                );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إنشاء المرتجع بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showReturnDetails(BuildContext context, ReturnItem returnItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => _ReturnDetailsSheet(
          returnItem: returnItem,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

/// شريحة إحصائية
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

/// بطاقة المرتجع
class _ReturnCard extends StatelessWidget {
  final ReturnItem returnItem;
  final VoidCallback onTap;

  const _ReturnCard({
    required this.returnItem,
    required this.onTap,
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
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.assignment_return,
                  color: AppColors.warning,
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
                          'مرتجع #${returnItem.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '(فاتورة #${returnItem.invoiceId})',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DateFormat('yyyy/MM/dd - HH:mm').format(returnItem.date),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${returnItem.itemsCount} منتج',
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
                    '${returnItem.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: AppColors.error,
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
              SizedBox(width: 8.w),
              Icon(Icons.chevron_left, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// ورقة معالجة المرتجع
class _ReturnProcessSheet extends StatefulWidget {
  final InvoiceForReturn invoice;
  final ScrollController scrollController;
  final Function(List<ReturnItemData>, String) onConfirm;

  const _ReturnProcessSheet({
    required this.invoice,
    required this.scrollController,
    required this.onConfirm,
  });

  @override
  State<_ReturnProcessSheet> createState() => _ReturnProcessSheetState();
}

class _ReturnProcessSheetState extends State<_ReturnProcessSheet> {
  final Map<int, int> _returnQuantities = {};
  final _reasonController = TextEditingController();

  double get _totalReturn {
    double total = 0;
    for (final item in widget.invoice.items) {
      final qty = _returnQuantities[item.id] ?? 0;
      total += qty * item.price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الرأس
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مرتجع من الفاتورة #${widget.invoice.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تاريخ الفاتورة: ${DateFormat('yyyy/MM/dd').format(widget.invoice.date)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  Text(
                    'الإجمالي: ${widget.invoice.total.toStringAsFixed(2)} ر.س',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // المنتجات
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: EdgeInsets.all(16.w),
            children: [
              Text(
                'اختر المنتجات للإرجاع',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 12.h),
              ...widget.invoice.items.map((item) => _ReturnProductCard(
                    item: item,
                    returnQuantity: _returnQuantities[item.id] ?? 0,
                    onQuantityChanged: (qty) {
                      setState(() {
                        if (qty > 0) {
                          _returnQuantities[item.id] = qty;
                        } else {
                          _returnQuantities.remove(item.id);
                        }
                      });
                    },
                  )),

              SizedBox(height: 16.h),

              // سبب الإرجاع
              AppTextField(
                controller: _reasonController,
                label: 'سبب الإرجاع',
                hint: 'أدخل سبب الإرجاع',
                maxLines: 2,
              ),
            ],
          ),
        ),

        // الإجمالي وزر التأكيد
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إجمالي المرتجع'),
                  Text(
                    '${_totalReturn.toStringAsFixed(2)} ر.س',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              AppButton(
                text: 'تأكيد المرتجع',
                onPressed: _returnQuantities.isEmpty
                    ? null
                    : () {
                        final items = _returnQuantities.entries.map((e) {
                          final item = widget.invoice.items.firstWhere(
                            (i) => i.id == e.key,
                          );
                          return ReturnItemData(
                            productId: item.productId,
                            productName: item.name,
                            quantity: e.value,
                            price: item.price,
                          );
                        }).toList();

                        widget.onConfirm(items, _reasonController.text.trim());
                      },
                isFullWidth: true,
                backgroundColor: AppColors.error,
                icon: Icons.assignment_return,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// بطاقة منتج للإرجاع
class _ReturnProductCard extends StatelessWidget {
  final InvoiceItemForReturn item;
  final int returnQuantity;
  final Function(int) onQuantityChanged;

  const _ReturnProductCard({
    required this.item,
    required this.returnQuantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${item.price.toStringAsFixed(2)} ر.س × ${item.quantity}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            // التحكم بالكمية
            Row(
              children: [
                IconButton(
                  icon:
                      Icon(Icons.remove_circle_outline, color: AppColors.error),
                  onPressed: returnQuantity > 0
                      ? () => onQuantityChanged(returnQuantity - 1)
                      : null,
                ),
                Container(
                  width: 40.w,
                  alignment: Alignment.center,
                  child: Text(
                    '$returnQuantity',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                IconButton(
                  icon:
                      Icon(Icons.add_circle_outline, color: AppColors.success),
                  onPressed: returnQuantity < item.quantity
                      ? () => onQuantityChanged(returnQuantity + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ورقة تفاصيل المرتجع
class _ReturnDetailsSheet extends StatelessWidget {
  final ReturnItem returnItem;
  final ScrollController scrollController;

  const _ReturnDetailsSheet({
    required this.returnItem,
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
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرتجع #${returnItem.id}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    DateFormat('yyyy/MM/dd - HH:mm').format(returnItem.date),
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
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
              // معلومات الفاتورة
              Card(
                child: ListTile(
                  leading: Icon(Icons.receipt, color: AppColors.primary),
                  title: Text('فاتورة #${returnItem.invoiceId}'),
                  subtitle: const Text('الفاتورة الأصلية'),
                ),
              ),

              SizedBox(height: 16.h),

              // المنتجات
              Text(
                'المنتجات المرتجعة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 8.h),
              ...returnItem.items.map((item) => Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                          '${item.price.toStringAsFixed(2)} ر.س × ${item.quantity}'),
                      trailing: Text(
                        '${(item.price * item.quantity).toStringAsFixed(2)} ر.س',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),

              if (returnItem.reason != null &&
                  returnItem.reason!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(
                  'سبب الإرجاع',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Text(returnItem.reason!),
                  ),
                ),
              ],

              SizedBox(height: 16.h),

              // الإجمالي
              Card(
                color: AppColors.error.withOpacity(0.1),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إجمالي المرتجع',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${returnItem.total.toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: AppColors.error,
                        ),
                      ),
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
            Icons.assignment_return_outlined,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد مرتجعات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'قم بإنشاء مرتجع من فاتورة موجودة',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          AppButton(
            text: 'مرتجع جديد',
            onPressed: onAdd,
            icon: Icons.assignment_return,
          ),
        ],
      ),
    );
  }
}
