import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/export_service.dart';
import '../../../core/widgets/invoice_widgets.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/supplier_repository.dart';
import 'print_settings_screen.dart';

class InvoiceDetailsScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailsScreen> createState() =>
      _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends ConsumerState<InvoiceDetailsScreen> {
  final _invoiceRepo = getIt<InvoiceRepository>();
  final _customerRepo = getIt<CustomerRepository>();
  final _supplierRepo = getIt<SupplierRepository>();
  final _exportService = getIt<ExportService>();

  Invoice? _invoice;
  List<InvoiceItem> _items = [];
  Customer? _customer;
  Supplier? _supplier;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final invoice = await _invoiceRepo.getInvoiceById(widget.invoiceId);
    final items = await _invoiceRepo.getInvoiceItems(widget.invoiceId);

    Customer? customer;
    Supplier? supplier;
    if (invoice?.customerId != null) {
      customer = await _customerRepo.getCustomerById(invoice!.customerId!);
    }
    if (invoice?.supplierId != null) {
      supplier = await _supplierRepo.getSupplierById(invoice!.supplierId!);
    }

    setState(() {
      _invoice = invoice;
      _items = items;
      _customer = customer;
      _supplier = supplier;
      _isLoading = false;
    });
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
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الفاتورة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printInvoice(invoice),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareInvoice(invoice),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // رأس الفاتورة
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _TypeBadge(type: invoice.type),
                    ],
                  ),
                  Gap(8.h),
                  _InfoRow(
                    label: 'التاريخ',
                    value: dateFormat.format(invoice.invoiceDate),
                  ),
                  _InfoRow(
                    label: 'طريقة الدفع',
                    value: getPaymentMethodLabel(invoice.paymentMethod),
                  ),
                  if (invoice.notes != null && invoice.notes!.isNotEmpty)
                    _InfoRow(label: 'ملاحظات', value: invoice.notes!),
                ],
              ),
            ),
          ),

          // معلومات العميل أو المورد
          if (_customer != null || _supplier != null) ...[
            Gap(16.h),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _customer != null ? Icons.person : Icons.business,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        Gap(8.w),
                        Text(
                          _customer != null
                              ? 'معلومات العميل'
                              : 'معلومات المورد',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Gap(12.h),
                    _InfoRow(
                      label: 'الاسم',
                      value: _customer?.name ?? _supplier?.name ?? '',
                    ),
                    if ((_customer?.phone ?? _supplier?.phone) != null)
                      _InfoRow(
                        label: 'الهاتف',
                        value: _customer?.phone ?? _supplier?.phone ?? '',
                      ),
                    if ((_customer?.address ?? _supplier?.address) != null)
                      _InfoRow(
                        label: 'العنوان',
                        value: _customer?.address ?? _supplier?.address ?? '',
                      ),
                  ],
                ),
              ),
            ),
          ],
          Gap(16.h),

          // المنتجات
          Text(
            'المنتجات',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(8.h),
          Card(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12.r)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text('المنتج',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('الكمية',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('السعر',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('الإجمالي',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                ...(_items.map((item) => Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(item.productName)),
                          Expanded(
                              child: Text('${item.quantity}',
                                  textAlign: TextAlign.center)),
                          Expanded(
                              child: Text(
                                  formatPrice(item.unitPrice,
                                      showCurrency: false),
                                  textAlign: TextAlign.center)),
                          Expanded(
                              child: Text(
                                  formatPrice(item.total, showCurrency: false),
                                  textAlign: TextAlign.end)),
                        ],
                      ),
                    ))),
              ],
            ),
          ),
          Gap(16.h),

          // الملخص
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _SummaryRow(label: 'المجموع الفرعي', value: invoice.subtotal),
                  if (invoice.discountAmount > 0)
                    _SummaryRow(
                      label: 'الخصم',
                      value: invoice.discountAmount,
                      isNegative: true,
                    ),
                  Divider(),
                  _SummaryRow(
                    label: 'الإجمالي',
                    value: invoice.total,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // طباعة الفاتورة باستخدام صفحة إعدادات الطباعة
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _printInvoice(Invoice invoice) async {
    // فتح صفحة إعدادات الطباعة
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrintSettingsScreen(
          invoice: invoice,
          invoiceId: widget.invoiceId,
        ),
      ),
    );
  }

  Future<void> _shareInvoice(Invoice invoice) async {
    try {
      // عرض خيارات المشاركة
      final result = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('مشاركة كـ PDF'),
                onTap: () => Navigator.pop(context, 'pdf'),
              ),
              ListTile(
                leading: const Icon(Icons.save_alt, color: Colors.blue),
                title: const Text('حفظ PDF محلياً'),
                onTap: () => Navigator.pop(context, 'save'),
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('إلغاء'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );

      if (result == null || !mounted) return;

      switch (result) {
        case 'pdf':
          await _exportService.shareInvoiceAsPdf(
            invoice: invoice,
            items: _items,
            customer: _customer,
            supplier: _supplier,
          );
          break;

        case 'save':
          final filePath = await _exportService.saveInvoiceAsPdf(
            invoice: invoice,
            items: _items,
            customer: _customer,
            supplier: _supplier,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم حفظ الفاتورة بنجاح'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'مشاركة',
                  textColor: Colors.white,
                  onPressed: () => _exportService.sharePdfFile(
                    filePath,
                    subject: 'فاتورة ${invoice.invoiceNumber}',
                  ),
                ),
              ),
            );
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UI WIDGETS - استخدام الـ Widgets الموحدة من invoice_widgets.dart
// ═══════════════════════════════════════════════════════════════════════════

class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return InvoiceTypeBadge(type: type, useShortLabel: true);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return InfoRow(label: label, value: value);
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isNegative;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isNegative = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryRow(
      label: label,
      value: value,
      isNegative: isNegative,
      isTotal: isTotal,
    );
  }
}
