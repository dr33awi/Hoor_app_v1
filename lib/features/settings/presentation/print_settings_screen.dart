import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/print_settings_service.dart';
import '../../../core/services/printing/print_settings.dart';
import '../../../core/services/printing/invoice_pdf_generator.dart';

/// صفحة إعدادات الطباعة الموحدة
class PrintSettingsScreen extends StatefulWidget {
  const PrintSettingsScreen({super.key});

  @override
  State<PrintSettingsScreen> createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  final _printSettingsService = getIt<PrintSettingsService>();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyTaxNumberController = TextEditingController();
  final _footerMessageController = TextEditingController();

  // State
  PrintSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  // Stream subscription للتحديثات في الوقت الفعلي
  StreamSubscription<PrintSettings>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupRealtimeSync();
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _companyTaxNumberController.dispose();
    _footerMessageController.dispose();
    super.dispose();
  }

  /// إعداد الاستماع للتحديثات في الوقت الفعلي من Firestore
  void _setupRealtimeSync() {
    _settingsSubscription =
        _printSettingsService.settingsStream.listen((settings) {
      if (mounted && !_isSaving) {
        setState(() {
          _settings = settings;
          _companyNameController.text = settings.companyName ?? '';
          _companyAddressController.text = settings.companyAddress ?? '';
          _companyPhoneController.text = settings.companyPhone ?? '';
          _companyTaxNumberController.text = settings.companyTaxNumber ?? '';
          _footerMessageController.text = settings.footerMessage ?? '';
        });
      }
    });
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _printSettingsService.getSettings();
      setState(() {
        _settings = settings;
        _companyNameController.text = settings.companyName ?? '';
        _companyAddressController.text = settings.companyAddress ?? '';
        _companyPhoneController.text = settings.companyPhone ?? '';
        _companyTaxNumberController.text = settings.companyTaxNumber ?? '';
        _footerMessageController.text = settings.footerMessage ?? '';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updatedSettings = _settings!.copyWith(
        companyName: _companyNameController.text.trim().isEmpty
            ? null
            : _companyNameController.text.trim(),
        companyAddress: _companyAddressController.text.trim().isEmpty
            ? null
            : _companyAddressController.text.trim(),
        companyPhone: _companyPhoneController.text.trim().isEmpty
            ? null
            : _companyPhoneController.text.trim(),
        companyTaxNumber: _companyTaxNumberController.text.trim().isEmpty
            ? null
            : _companyTaxNumberController.text.trim(),
        footerMessage: _footerMessageController.text.trim().isEmpty
            ? null
            : _footerMessageController.text.trim(),
      );

      await _printSettingsService.saveSettings(updatedSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الإعدادات بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ الإعدادات: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _updateSetting(PrintSettings Function(PrintSettings) updater) {
    if (_settings != null) {
      setState(() {
        _settings = updater(_settings!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الطباعة'),
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                'حفظ',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // قسم معلومات الشركة
                  _buildSectionTitle('معلومات الشركة'),
                  _buildCompanyInfoCard(),
                  Gap(16.h),

                  // قسم إعدادات الطباعة العامة
                  _buildSectionTitle('إعدادات الطباعة العامة'),
                  _buildGeneralSettingsCard(),
                  Gap(16.h),

                  // قسم محتوى الفاتورة
                  _buildSectionTitle('محتوى الفاتورة'),
                  _buildInvoiceContentCard(),
                  Gap(16.h),

                  // قسم رسالة التذييل
                  _buildSectionTitle('رسالة التذييل'),
                  _buildFooterMessageCard(),
                  Gap(16.h),

                  // زر إعادة التعيين
                  _buildResetButton(),
                  Gap(32.h),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCompanyInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الشركة',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),
            Gap(12.h),
            TextFormField(
              controller: _companyAddressController,
              decoration: const InputDecoration(
                labelText: 'العنوان',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            Gap(12.h),
            TextFormField(
              controller: _companyPhoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            Gap(12.h),
            TextFormField(
              controller: _companyTaxNumberController,
              decoration: const InputDecoration(
                labelText: 'الرقم الضريبي',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettingsCard() {
    return Card(
      child: Column(
        children: [
          // حجم الطباعة الافتراضي
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('حجم الطباعة الافتراضي'),
            subtitle: Text(_getPrintSizeLabel(_settings!.defaultSize)),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => _showPrintSizeDialog(),
          ),
          const Divider(height: 1),

          // عدد النسخ
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('عدد النسخ'),
            subtitle: Text('${_settings!.copies} نسخة'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _settings!.copies > 1
                      ? () => _updateSetting(
                          (s) => s.copyWith(copies: s.copies - 1))
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '${_settings!.copies}',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _settings!.copies < 5
                      ? () => _updateSetting(
                          (s) => s.copyWith(copies: s.copies + 1))
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // طباعة تلقائية
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome),
            title: const Text('طباعة تلقائية'),
            subtitle: const Text('طباعة الفاتورة تلقائياً بعد الحفظ'),
            value: _settings!.autoPrintAfterSave,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(autoPrintAfterSave: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceContentCard() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.person),
            title: const Text('إظهار معلومات العميل'),
            value: _settings!.showCustomerInfo,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(showCustomerInfo: value)),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.qr_code_2),
            title: const Text('إظهار باركود رقم الفاتورة'),
            value: _settings!.showInvoiceBarcode,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(showInvoiceBarcode: value)),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.payment),
            title: const Text('إظهار طريقة الدفع'),
            value: _settings!.showPaymentMethod,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(showPaymentMethod: value)),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.notes),
            title: const Text('إظهار الملاحظات'),
            value: _settings!.showNotes,
            onChanged: (value) =>
                _updateSetting((s) => s.copyWith(showNotes: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterMessageCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: TextFormField(
          controller: _footerMessageController,
          decoration: const InputDecoration(
            labelText: 'رسالة شكر / تذييل الفاتورة',
            hintText: 'مثال: شكراً لتعاملكم معنا',
            prefixIcon: Icon(Icons.message),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return OutlinedButton.icon(
      onPressed: () => _showResetConfirmDialog(),
      icon: const Icon(Icons.restore, color: AppColors.error),
      label: const Text(
        'إعادة تعيين الإعدادات',
        style: TextStyle(color: AppColors.error),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.error),
      ),
    );
  }

  void _showPrintSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حجم الطباعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: InvoicePrintSize.values.map((size) {
            return RadioListTile<InvoicePrintSize>(
              title: Text(_getPrintSizeLabel(size)),
              subtitle: Text(_getPrintSizeDescription(size)),
              value: size,
              groupValue: _settings!.defaultSize,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting((s) => s.copyWith(defaultSize: value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text(
          'هل أنت متأكد من إعادة تعيين جميع إعدادات الطباعة إلى القيم الافتراضية؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _printSettingsService.resetToDefaults();
              await _loadSettings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إعادة تعيين الإعدادات'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  String _getPrintSizeLabel(InvoicePrintSize size) {
    switch (size) {
      case InvoicePrintSize.a4:
        return 'A4';
      case InvoicePrintSize.thermal80mm:
        return '80mm حراري';
      case InvoicePrintSize.thermal58mm:
        return '58mm حراري';
    }
  }

  String _getPrintSizeDescription(InvoicePrintSize size) {
    switch (size) {
      case InvoicePrintSize.a4:
        return 'للطابعات العادية';
      case InvoicePrintSize.thermal80mm:
        return 'للطابعات الحرارية عرض 80mm';
      case InvoicePrintSize.thermal58mm:
        return 'للطابعات الحرارية عرض 58mm';
    }
  }
}
