import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/invoice_widgets.dart';
import '../../../core/widgets/invoice_actions_sheet.dart';
import '../../../core/services/currency_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/supplier_repository.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final _invoiceRepo = getIt<InvoiceRepository>();
  final _customerRepo = getIt<CustomerRepository>();
  final _supplierRepo = getIt<SupplierRepository>();
  final _currencyService = getIt<CurrencyService>();

  Invoice? _invoice;
  List<InvoiceItem> _items = [];
  Customer? _customer;
  Supplier? _supplier;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    setState(() => _isLoading = true);

    try {
      final invoice = await _invoiceRepo.getInvoiceById(widget.invoiceId);
      if (invoice == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الفاتورة غير موجودة'),
              backgroundColor: Colors.red,
            ),
          );
          context.pop();
        }
        return;
      }

      final items = await _invoiceRepo.getInvoiceItems(widget.invoiceId);

      Customer? customer;
      Supplier? supplier;

      if (invoice.customerId != null) {
        customer = await _customerRepo.getCustomerById(invoice.customerId!);
      }
      if (invoice.supplierId != null) {
        supplier = await _supplierRepo.getSupplierById(invoice.supplierId!);
      }

      setState(() {
        _invoice = invoice;
        _items = items;
        _customer = customer;
        _supplier = supplier;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الفاتورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// تحويل المبلغ من ليرة إلى دولار باستخدام سعر الصرف المحفوظ في الفاتورة
  String _toUsd(double sypAmount) {
    // استخدام سعر الصرف المحفوظ في الفاتورة أو الحالي إذا لم يكن محفوظاً
    final rate = _invoice?.exchangeRate ?? _currencyService.exchangeRate;
    if (rate <= 0) return '\$0.00';
    return '\$${(sypAmount / rate).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الفاتورة')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الفاتورة')),
        body: const Center(child: Text('الفاتورة غير موجودة')),
      );
    }

    final invoice = _invoice!;
    final typeInfo = InvoiceTypeInfo.fromType(invoice.type);

    return Scaffold(
      appBar: AppBar(
        title: Text('فاتورة ${invoice.invoiceNumber}'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInvoice,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(invoice, typeInfo),
              Gap(16.h),

              // Customer/Supplier Info
              if (_customer != null || _supplier != null) _buildContactCard(),
              if (_customer != null || _supplier != null) Gap(16.h),

              // Items List
              _buildItemsCard(),
              Gap(16.h),

              // Summary Card
              _buildSummaryCard(invoice),
              Gap(16.h),

              // Payment Info
              _buildPaymentCard(invoice),

              // Notes
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                Gap(16.h),
                _buildNotesCard(invoice.notes!),
              ],

              Gap(32.h),
            ],
          ),
        ),
      ),
      // أزرار الإجراءات العائمة
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر الحذف
          FloatingActionButton(
            heroTag: 'delete_invoice',
            onPressed: () => _deleteInvoice(invoice),
            backgroundColor: AppColors.error,
            mini: true,
            child: const Icon(Icons.delete),
          ),
          Gap(8.h),
          // زر التعديل
          FloatingActionButton(
            heroTag: 'edit_invoice',
            onPressed: () => _editInvoice(invoice),
            backgroundColor: AppColors.secondary,
            child: const Icon(Icons.edit),
          ),
          Gap(12.h),
          // زر الطباعة
          FloatingActionButton.extended(
            heroTag: 'print_invoice',
            onPressed: () =>
                InvoiceActionsSheet.showPrintDialog(context, invoice),
            icon: const Icon(Icons.print),
            label: const Text('طباعة'),
            backgroundColor: typeInfo.color,
          ),
        ],
      ),
    );
  }

  /// حذف الفاتورة
  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الفاتورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف الفاتورة ${invoice.invoiceNumber}؟'),
            Gap(12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.warning, size: 20.sp),
                  Gap(8.w),
                  Expanded(
                    child: Text(
                      'سيتم إرجاع الكميات للمخزون تلقائياً',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _invoiceRepo.deleteInvoiceWithReverse(invoice.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الفاتورة وإرجاع الكميات للمخزون'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في حذف الفاتورة: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// الانتقال إلى شاشة تعديل الفاتورة
  Future<void> _editInvoice(Invoice invoice) async {
    final result = await context.push<bool>(
      '/invoices/edit/${invoice.id}/${invoice.type}',
    );

    // إعادة تحميل البيانات إذا تم التعديل بنجاح
    if (result == true) {
      _loadInvoice();
    }
  }

  Widget _buildHeaderCard(Invoice invoice, InvoiceTypeInfo typeInfo) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: [
                InvoiceTypeIcon(type: invoice.type, size: 48),
                Gap(16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeInfo.label,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: typeInfo.color,
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        'رقم: ${invoice.invoiceNumber}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatAmount(invoice.total),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: typeInfo.color,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _toUsd(invoice.total),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (invoice.exchangeRate != null) ...[
                          Gap(4.w),
                          Text(
                            '(${NumberFormat('#,###').format(invoice.exchangeRate)})',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      DateFormat('yyyy/MM/dd HH:mm')
                          .format(invoice.invoiceDate),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    final isCustomer = _customer != null;
    final name = isCustomer ? _customer!.name : _supplier!.name;
    final phone = isCustomer ? _customer!.phone : _supplier!.phone;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: (isCustomer ? AppColors.primary : AppColors.secondary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                isCustomer ? Icons.person : Icons.business,
                color: isCustomer ? AppColors.primary : AppColors.secondary,
                size: 24.sp,
              ),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCustomer ? 'العميل' : 'المورد',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (phone != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, size: 14.sp, color: Colors.grey[600]),
                    Gap(4.w),
                    Text(
                      phone,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(Icons.shopping_cart,
                    size: 20.sp, color: AppColors.primary),
                Gap(8.w),
                Text(
                  'المنتجات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${_items.length} صنف',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Gap(2.h),
                          Text(
                            '${item.quantity} × ${formatAmount(item.unitPrice)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatAmount(item.total),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _toUsd(item.total),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.green.shade600,
                          ),
                        ),
                        if (item.discountAmount > 0)
                          Text(
                            '-${formatAmount(item.discountAmount)}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.error,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Invoice invoice) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _summaryRow('المجموع الفرعي', invoice.subtotal),
            if (invoice.discountAmount > 0) ...[
              Gap(8.h),
              _summaryRow('الخصم', invoice.discountAmount,
                  isNegative: true, color: AppColors.error),
            ],
            if (invoice.taxAmount > 0) ...[
              Gap(8.h),
              _summaryRow('الضريبة', invoice.taxAmount),
            ],
            Gap(12.h),
            const Divider(),
            Gap(12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatAmount(invoice.total),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _toUsd(invoice.total),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // عرض سعر الصرف المستخدم
            if (invoice.exchangeRate != null) ...[
              Gap(12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.currency_exchange,
                      size: 16.sp,
                      color: Colors.blue.shade700,
                    ),
                    Gap(8.w),
                    Text(
                      'سعر الصرف: ${NumberFormat('#,###').format(invoice.exchangeRate)} ل.س/\$',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount,
      {bool isNegative = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '${isNegative ? '-' : ''}${formatAmount(amount)}',
          style: TextStyle(
            fontSize: 14.sp,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(Invoice invoice) {
    final paymentInfo = _getPaymentInfo(invoice.paymentMethod);

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
                    color: paymentInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    paymentInfo.icon,
                    color: paymentInfo.color,
                    size: 20.sp,
                  ),
                ),
                Gap(12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طريقة الدفع',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      paymentInfo.label,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: paymentInfo.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (invoice.paymentMethod == 'partial' ||
                invoice.paymentMethod == 'credit') ...[
              Gap(16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: invoice.paidAmount >= invoice.total
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المدفوع',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            formatAmount(invoice.paidAmount),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            _toUsd(invoice.paidAmount),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40.h,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'المتبقي',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            formatAmount(invoice.total - invoice.paidAmount),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: invoice.total - invoice.paidAmount > 0
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                          Text(
                            _toUsd(invoice.total - invoice.paidAmount),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.note, size: 20.sp, color: Colors.amber),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظات',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    notes,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _PaymentInfo _getPaymentInfo(String method) {
    switch (method) {
      case 'cash':
        return _PaymentInfo('نقداً', Icons.payments, AppColors.success);
      case 'credit':
        return _PaymentInfo('آجل', Icons.schedule, AppColors.warning);
      case 'partial':
        return _PaymentInfo(
            'دفع جزئي', Icons.account_balance_wallet, AppColors.info);
      case 'card':
        return _PaymentInfo('بطاقة', Icons.credit_card, AppColors.primary);
      default:
        return _PaymentInfo('غير محدد', Icons.help_outline, Colors.grey);
    }
  }
}

class _PaymentInfo {
  final String label;
  final IconData icon;
  final Color color;

  _PaymentInfo(this.label, this.icon, this.color);
}
