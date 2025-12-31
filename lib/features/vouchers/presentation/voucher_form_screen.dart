import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/currency_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/voucher_repository.dart';
import '../../../data/repositories/shift_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/supplier_repository.dart';

class VoucherFormScreen extends ConsumerStatefulWidget {
  final VoucherType type;
  final Voucher? voucher; // للتعديل

  const VoucherFormScreen({
    super.key,
    required this.type,
    this.voucher,
  });

  @override
  ConsumerState<VoucherFormScreen> createState() => _VoucherFormScreenState();
}

class _VoucherFormScreenState extends ConsumerState<VoucherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _voucherRepo = getIt<VoucherRepository>();
  final _shiftRepo = getIt<ShiftRepository>();
  final _customerRepo = getIt<CustomerRepository>();
  final _supplierRepo = getIt<SupplierRepository>();
  final _currencyService = getIt<CurrencyService>();

  String? _selectedCustomerId;
  String? _selectedSupplierId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Shift? _currentShift;

  List<Customer> _customers = [];
  List<Supplier> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.voucher != null) {
      _amountController.text = widget.voucher!.amount.toString();
      _descriptionController.text = widget.voucher!.description ?? '';
      _selectedCustomerId = widget.voucher!.customerId;
      _selectedSupplierId = widget.voucher!.supplierId;
      _selectedDate = widget.voucher!.voucherDate;
    }
  }

  Future<void> _loadData() async {
    _currentShift = await _shiftRepo.getOpenShift();
    final customers = await _customerRepo.getAllCustomers();
    final suppliers = await _supplierRepo.getAllSuppliers();

    setState(() {
      _customers = customers;
      _suppliers = suppliers;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double _calculateUsd(double amount) {
    final rate = _currencyService.exchangeRate;
    if (rate <= 0) return 0;
    return amount / rate;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.voucher != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? 'تعديل ${widget.type.arabicName}'
            : 'إنشاء ${widget.type.arabicName}'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteVoucher,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // نوع السند
            _buildTypeHeader(),

            Gap(24.h),

            // المبلغ
            _buildAmountField(),

            Gap(16.h),

            // العميل/المورد حسب النوع
            if (widget.type == VoucherType.receipt) _buildCustomerDropdown(),
            if (widget.type == VoucherType.payment) _buildSupplierDropdown(),

            Gap(16.h),

            // التاريخ
            _buildDatePicker(),

            Gap(16.h),

            // الوصف
            _buildDescriptionField(),

            Gap(24.h),

            // معلومات إضافية
            _buildExchangeRateInfo(),

            Gap(32.h),

            // زر الحفظ
            _buildSubmitButton(isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _getTypeColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _getTypeIcon(),
              color: _getTypeColor(),
              size: 32.sp,
            ),
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.type.arabicName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(),
                  ),
                ),
                Text(
                  _getTypeDescription(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المبلغ *',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap(8.h),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          decoration: InputDecoration(
            hintText: 'أدخل المبلغ بالليرة السورية',
            suffixText: CurrencyService.currencySymbol,
            prefixIcon: Icon(Icons.monetization_on, color: _getTypeColor()),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'المبلغ مطلوب';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'أدخل مبلغ صحيح';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
        if (_amountController.text.isNotEmpty) ...[
          Gap(8.h),
          Text(
            'المعادل بالدولار: ${_currencyService.formatUsd(_calculateUsd(double.tryParse(_amountController.text) ?? 0))}',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomerDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العميل',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap(8.h),
        DropdownButtonFormField<String>(
          value: _selectedCustomerId,
          decoration: const InputDecoration(
            hintText: 'اختر العميل (اختياري)',
            prefixIcon: Icon(Icons.person),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('بدون عميل'),
            ),
            ..._customers.map((customer) {
              return DropdownMenuItem(
                value: customer.id,
                child: Text(customer.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCustomerId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSupplierDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المورد',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap(8.h),
        DropdownButtonFormField<String>(
          value: _selectedSupplierId,
          decoration: const InputDecoration(
            hintText: 'اختر المورد (اختياري)',
            prefixIcon: Icon(Icons.business),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('بدون مورد'),
            ),
            ..._suppliers.map((supplier) {
              return DropdownMenuItem(
                value: supplier.id,
                child: Text(supplier.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedSupplierId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap(8.h),
        InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(dateFormat.format(_selectedDate)),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوصف / الملاحظات',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap(8.h),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'أدخل وصف أو ملاحظات...',
            prefixIcon: Icon(Icons.notes),
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeRateInfo() {
    final rate = _currencyService.exchangeRate;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20.sp, color: AppColors.textSecondary),
          Gap(8.w),
          Expanded(
            child: Text(
              'سعر الصرف الحالي: ${_currencyService.formatSyp(rate, showSymbol: false)} ${CurrencyService.currencySymbol}/\$ - سيتم حفظه مع السند',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitVoucher,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTypeColor(),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                isEditing ? 'حفظ التعديلات' : 'إنشاء السند',
                style: TextStyle(fontSize: 16.sp),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitVoucher() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب فتح وردية أولاً'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      if (widget.voucher != null) {
        // تعديل
        await _voucherRepo.updateVoucher(
          id: widget.voucher!.id,
          amount: amount,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          voucherDate: _selectedDate,
        );
      } else {
        // إنشاء جديد
        await _voucherRepo.createVoucher(
          type: widget.type,
          amount: amount,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          customerId: _selectedCustomerId,
          supplierId: _selectedSupplierId,
          shiftId: _currentShift!.id,
          voucherDate: _selectedDate,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.voucher != null
                ? 'تم تعديل السند بنجاح'
                : 'تم إنشاء السند بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteVoucher() async {
    if (widget.voucher == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السند'),
        content: const Text('هل أنت متأكد من حذف هذا السند؟'),
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
      await _voucherRepo.deleteVoucher(widget.voucher!.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف السند بنجاح')),
        );
      }
    }
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case VoucherType.receipt:
        return AppColors.success;
      case VoucherType.payment:
        return AppColors.primary;
      case VoucherType.expense:
        return AppColors.warning;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case VoucherType.receipt:
        return Icons.arrow_downward;
      case VoucherType.payment:
        return Icons.arrow_upward;
      case VoucherType.expense:
        return Icons.receipt_long;
    }
  }

  String _getTypeDescription() {
    switch (widget.type) {
      case VoucherType.receipt:
        return 'استلام مبلغ من عميل أو جهة خارجية';
      case VoucherType.payment:
        return 'دفع مبلغ لمورد أو جهة خارجية';
      case VoucherType.expense:
        return 'تسجيل مصاريف ونفقات';
    }
  }
}
