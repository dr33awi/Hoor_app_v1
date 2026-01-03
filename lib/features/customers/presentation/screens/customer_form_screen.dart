import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/customers_provider.dart';

/// شاشة نموذج العميل
class CustomerFormScreen extends ConsumerStatefulWidget {
  final int? customerId;

  const CustomerFormScreen({super.key, this.customerId});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditing => widget.customerId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadCustomer();
    }
  }

  void _loadCustomer() async {
    setState(() => _isLoading = true);
    try {
      final state = ref.read(customersProvider);
      final customer = state.customers.firstWhere(
        (c) => c.id == widget.customerId,
        orElse: () => throw Exception('Customer not found'),
      );

      _nameController.text = customer.name;
      _phoneController.text = customer.phone ?? '';
      _emailController.text = customer.email ?? '';
      _addressController.text = customer.address ?? '';
      _notesController.text = customer.notes ?? '';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل بيانات العميل'),
          backgroundColor: AppColors.error,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل العميل' : 'عميل جديد'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
              tooltip: 'حذف',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // أيقونة العميل
                    Center(
                      child: CircleAvatar(
                        radius: 40.r,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 40.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // الاسم
                    AppTextField(
                      controller: _nameController,
                      label: 'اسم العميل *',
                      hint: 'أدخل اسم العميل',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال اسم العميل';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // الهاتف
                    AppTextField(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      hint: '05xxxxxxxx',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.h),

                    // البريد الإلكتروني
                    AppTextField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      hint: 'example@email.com',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.h),

                    // العنوان
                    AppTextField(
                      controller: _addressController,
                      label: 'العنوان',
                      hint: 'أدخل عنوان العميل',
                      prefixIcon: Icons.location_on,
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.h),

                    // ملاحظات
                    AppTextField(
                      controller: _notesController,
                      label: 'ملاحظات',
                      hint: 'أي ملاحظات إضافية',
                      prefixIcon: Icons.notes,
                      maxLines: 3,
                    ),
                    SizedBox(height: 32.h),

                    // زر الحفظ
                    AppButton(
                      text: _isEditing ? 'حفظ التعديلات' : 'إضافة العميل',
                      onPressed: _saveCustomer,
                      isFullWidth: true,
                      icon: Icons.save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        await ref.read(customersProvider.notifier).updateCustomer(
              id: widget.customerId!,
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              address: _addressController.text.trim(),
              notes: _notesController.text.trim(),
            );
      } else {
        await ref.read(customersProvider.notifier).addCustomer(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              address: _addressController.text.trim(),
              notes: _notesController.text.trim(),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'تم تحديث العميل بنجاح' : 'تم إضافة العميل بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العميل'),
        content: const Text('هل أنت متأكد من حذف هذا العميل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(customersProvider.notifier)
                  .deleteCustomer(widget.customerId!);
              if (mounted) {
                context.pop();
              }
            },
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
