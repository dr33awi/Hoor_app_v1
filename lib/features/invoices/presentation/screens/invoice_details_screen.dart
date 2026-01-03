import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/invoices_provider.dart';

/// شاشة تفاصيل الفاتورة
class InvoiceDetailsScreen extends ConsumerStatefulWidget {
  final int invoiceId;

  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailsScreen> createState() =>
      _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends ConsumerState<InvoiceDetailsScreen> {
  InvoiceItem? _invoice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    setState(() => _isLoading = true);

    try {
      final state = ref.read(invoicesProvider);
      final invoice = state.invoices.firstWhere(
        (i) => i.id == widget.invoiceId,
        orElse: () => throw Exception('Invoice not found'),
      );

      setState(() {
        _invoice = invoice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الفاتورة'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('فاتورة #${widget.invoiceId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printInvoice(),
            tooltip: 'طباعة',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareInvoice(),
            tooltip: 'مشاركة',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoice == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64.sp, color: AppColors.error),
                      SizedBox(height: 16.h),
                      const Text('لم يتم العثور على الفاتورة'),
                    ],
                  ),
                )
              : _buildInvoiceDetails(),
    );
  }

  Widget _buildInvoiceDetails() {
    final invoice = _invoice!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الفاتورة
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'فاتورة #${invoice.invoiceNumber}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            DateFormat('yyyy/MM/dd - HH:mm')
                                .format(invoice.createdAt),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      _StatusChip(status: invoice.status),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (invoice.customerName != null)
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 18.sp, color: AppColors.textSecondary),
                        SizedBox(width: 8.w),
                        Text('العميل: ${invoice.customerName}'),
                      ],
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // المنتجات
          Text(
            'المنتجات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),

          Card(
            child: Column(
              children: [
                // رأس الجدول
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
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
                          child: Text('السعر',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('الكمية',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('الإجمالي',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                // بيانات المنتجات (مؤقت - بدون عناصر فعلية)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'سيتم عرض عناصر الفاتورة هنا',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // ملخص الفاتورة
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _SummaryRow(label: 'المجموع', value: invoice.subtotal),
                  if (invoice.discountAmount > 0)
                    _SummaryRow(
                        label: 'الخصم',
                        value: -invoice.discountAmount,
                        color: AppColors.success),
                  if (invoice.taxAmount > 0)
                    _SummaryRow(label: 'الضريبة', value: invoice.taxAmount),
                  Divider(height: 24.h),
                  _SummaryRow(
                    label: 'الإجمالي',
                    value: invoice.totalAmount,
                    isBold: true,
                    fontSize: 18.sp,
                  ),
                  SizedBox(height: 12.h),
                  _SummaryRow(
                      label: 'المدفوع',
                      value: invoice.paidAmount,
                      color: AppColors.success),
                  if (invoice.totalAmount - invoice.paidAmount > 0)
                    _SummaryRow(
                      label: 'المتبقي',
                      value: invoice.totalAmount - invoice.paidAmount,
                      color: AppColors.error,
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // معلومات إضافية
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات إضافية',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  _InfoRow(
                      icon: Icons.payment,
                      label: 'طريقة الدفع',
                      value: invoice.paymentMethod),
                  if (invoice.notes != null && invoice.notes!.isNotEmpty)
                    _InfoRow(
                        icon: Icons.notes,
                        label: 'ملاحظات',
                        value: invoice.notes!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _printInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري الطباعة...')),
    );
  }

  void _shareInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري المشاركة...')),
    );
  }
}

/// شريحة الحالة
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case 'paid':
        color = AppColors.success;
        text = 'مدفوعة';
        break;
      case 'partial':
        color = AppColors.warning;
        text = 'مدفوعة جزئياً';
        break;
      case 'pending':
        color = AppColors.error;
        text = 'غير مدفوعة';
        break;
      default:
        color = AppColors.textSecondary;
        text = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

/// صف الملخص
class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;
  final bool isBold;
  final double? fontSize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.color,
    this.isBold = false,
    this.fontSize,
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
              fontSize: fontSize ?? 14.sp,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} ر.س',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: fontSize ?? 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// صف المعلومات
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.textSecondary),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          Text(value),
        ],
      ),
    );
  }
}
