import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/invoice_widgets.dart';
import '../../../core/services/invoice_print_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../data/repositories/invoice_repository.dart';

/// إعدادات الطباعة
class PrintSettings {
  final String printSize;
  final bool showBarcode;
  final bool showLogo;
  final bool showCustomerInfo;
  final bool showNotes;
  final bool showPaymentMethod;
  final int copies;

  const PrintSettings({
    this.printSize = '80mm',
    this.showBarcode = true,
    this.showLogo = true,
    this.showCustomerInfo = true,
    this.showNotes = true,
    this.showPaymentMethod = true,
    this.copies = 1,
  });

  PrintSettings copyWith({
    String? printSize,
    bool? showBarcode,
    bool? showLogo,
    bool? showCustomerInfo,
    bool? showNotes,
    bool? showPaymentMethod,
    int? copies,
  }) {
    return PrintSettings(
      printSize: printSize ?? this.printSize,
      showBarcode: showBarcode ?? this.showBarcode,
      showLogo: showLogo ?? this.showLogo,
      showCustomerInfo: showCustomerInfo ?? this.showCustomerInfo,
      showNotes: showNotes ?? this.showNotes,
      showPaymentMethod: showPaymentMethod ?? this.showPaymentMethod,
      copies: copies ?? this.copies,
    );
  }
}

/// شاشة إعدادات الطباعة
class PrintSettingsScreen extends StatefulWidget {
  final Invoice invoice;
  final String invoiceId;

  const PrintSettingsScreen({
    super.key,
    required this.invoice,
    required this.invoiceId,
  });

  @override
  State<PrintSettingsScreen> createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  final _database = getIt<AppDatabase>();
  final _invoiceRepo = getIt<InvoiceRepository>();
  final _customerRepo = getIt<CustomerRepository>();
  final _supplierRepo = getIt<SupplierRepository>();

  late PrintSettings _settings;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _settings = const PrintSettings();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final printSize = await _database.getSetting('print_size');
    final showBarcode = await _database.getSetting('print_show_barcode');
    final showLogo = await _database.getSetting('print_show_logo');
    final showCustomerInfo =
        await _database.getSetting('print_show_customer_info');
    final showNotes = await _database.getSetting('print_show_notes');
    final showPaymentMethod =
        await _database.getSetting('print_show_payment_method');
    final copies = await _database.getSetting('print_copies');

    setState(() {
      _settings = PrintSettings(
        printSize: printSize ?? '80mm',
        showBarcode: showBarcode != 'false',
        showLogo: showLogo != 'false',
        showCustomerInfo: showCustomerInfo != 'false',
        showNotes: showNotes != 'false',
        showPaymentMethod: showPaymentMethod != 'false',
        copies: int.tryParse(copies ?? '1') ?? 1,
      );
    });
  }

  Future<void> _saveSettings() async {
    await _database.setSetting('print_size', _settings.printSize);
    await _database.setSetting(
        'print_show_barcode', _settings.showBarcode.toString());
    await _database.setSetting(
        'print_show_logo', _settings.showLogo.toString());
    await _database.setSetting(
        'print_show_customer_info', _settings.showCustomerInfo.toString());
    await _database.setSetting(
        'print_show_notes', _settings.showNotes.toString());
    await _database.setSetting(
        'print_show_payment_method', _settings.showPaymentMethod.toString());
    await _database.setSetting('print_copies', _settings.copies.toString());
  }

  Future<void> _print() async {
    setState(() => _isPrinting = true);

    try {
      // حفظ الإعدادات
      await _saveSettings();

      // الحصول على عناصر الفاتورة
      final items = await _invoiceRepo.getInvoiceItems(widget.invoiceId);

      // الحصول على معلومات العميل أو المورد
      Customer? customer;
      Supplier? supplier;
      if (widget.invoice.customerId != null) {
        customer =
            await _customerRepo.getCustomerById(widget.invoice.customerId!);
      }
      if (widget.invoice.supplierId != null) {
        supplier =
            await _supplierRepo.getSupplierById(widget.invoice.supplierId!);
      }

      // طباعة عدد النسخ المطلوب
      for (int i = 0; i < _settings.copies; i++) {
        await InvoicePrintService.printInvoice(
          invoice: widget.invoice,
          items: items,
          printSize: _settings.printSize,
          customer: customer,
          supplier: supplier,
          showBarcode: _settings.showBarcode,
          showLogo: _settings.showLogo,
          showCustomerInfo: _settings.showCustomerInfo,
          showNotes: _settings.showNotes,
          showPaymentMethod: _settings.showPaymentMethod,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الطباعة'),
        actions: [
          TextButton.icon(
            onPressed: _isPrinting ? null : _print,
            icon: _isPrinting
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.print, color: Colors.white),
            label: Text(
              'طباعة',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // معلومات الفاتورة
          _buildInvoiceInfoCard(),
          Gap(16.h),

          // حجم الطباعة
          _buildSectionTitle('حجم الورق', Icons.straighten),
          Gap(8.h),
          _buildPrintSizeSelector(),
          Gap(16.h),

          // عدد النسخ
          _buildSectionTitle('عدد النسخ', Icons.copy),
          Gap(8.h),
          _buildCopiesSelector(),
          Gap(16.h),

          // محتوى الفاتورة
          _buildSectionTitle('محتوى الفاتورة', Icons.list_alt),
          Gap(8.h),
          _buildContentOptions(),
          Gap(24.h),

          // زر الطباعة
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton.icon(
              onPressed: _isPrinting ? null : _print,
              icon: _isPrinting
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.print, size: 24.sp),
              label: Text(
                _isPrinting ? 'جاري الطباعة...' : 'طباعة الفاتورة',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          Gap(16.h),

          // زر الإلغاء
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'إلغاء',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.primary, size: 24.sp),
                Gap(8.w),
                Text(
                  'فاتورة رقم: ${widget.invoice.invoiceNumber}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Gap(8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getInvoiceTypeLabel(widget.invoice.type),
                  style: TextStyle(
                    color: getInvoiceTypeColor(widget.invoice.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  formatPrice(widget.invoice.total),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        Gap(8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPrintSizeSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            _buildPrintSizeOption(
              '58mm',
              'إيصال حراري صغير',
              'مناسب للطابعات الحرارية الصغيرة',
              Icons.receipt,
              Colors.orange,
            ),
            Divider(height: 1.h),
            _buildPrintSizeOption(
              '80mm',
              'إيصال حراري عادي',
              'الحجم الأكثر شيوعاً للفواتير',
              Icons.receipt_long,
              Colors.blue,
            ),
            Divider(height: 1.h),
            _buildPrintSizeOption(
              'A4',
              'صفحة كاملة A4',
              'للطباعة على ورق عادي',
              Icons.description,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintSizeOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _settings.printSize == value;
    return InkWell(
      onTap: () {
        setState(() {
          _settings = _settings.copyWith(printSize: value);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _settings.printSize,
              onChanged: (v) {
                setState(() {
                  _settings = _settings.copyWith(printSize: v);
                });
              },
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopiesSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _settings.copies > 1
                  ? () {
                      setState(() {
                        _settings =
                            _settings.copyWith(copies: _settings.copies - 1);
                      });
                    }
                  : null,
              icon: Icon(Icons.remove_circle_outline, size: 32.sp),
              color: AppColors.primary,
            ),
            Gap(16.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${_settings.copies}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            Gap(16.w),
            IconButton(
              onPressed: _settings.copies < 5
                  ? () {
                      setState(() {
                        _settings =
                            _settings.copyWith(copies: _settings.copies + 1);
                      });
                    }
                  : null,
              icon: Icon(Icons.add_circle_outline, size: 32.sp),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentOptions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          children: [
            _buildSwitchOption(
              'إظهار الباركود',
              'طباعة باركود رقم الفاتورة',
              Icons.qr_code,
              _settings.showBarcode,
              (v) => setState(
                  () => _settings = _settings.copyWith(showBarcode: v)),
            ),
            Divider(height: 1.h),
            _buildSwitchOption(
              'إظهار الشعار',
              'طباعة شعار المتجر',
              Icons.store,
              _settings.showLogo,
              (v) =>
                  setState(() => _settings = _settings.copyWith(showLogo: v)),
            ),
            Divider(height: 1.h),
            _buildSwitchOption(
              'معلومات العميل/المورد',
              'طباعة اسم وبيانات العميل أو المورد',
              Icons.person,
              _settings.showCustomerInfo,
              (v) => setState(
                  () => _settings = _settings.copyWith(showCustomerInfo: v)),
            ),
            Divider(height: 1.h),
            _buildSwitchOption(
              'طريقة الدفع',
              'إظهار طريقة الدفع المستخدمة',
              Icons.payment,
              _settings.showPaymentMethod,
              (v) => setState(
                  () => _settings = _settings.copyWith(showPaymentMethod: v)),
            ),
            Divider(height: 1.h),
            _buildSwitchOption(
              'الملاحظات',
              'طباعة ملاحظات الفاتورة',
              Icons.notes,
              _settings.showNotes,
              (v) =>
                  setState(() => _settings = _settings.copyWith(showNotes: v)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchOption(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 14.sp)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
      ),
      secondary: Icon(icon, color: AppColors.primary),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}
