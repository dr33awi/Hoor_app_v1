// ═══════════════════════════════════════════════════════════════════════════
// Supplier Form Screen Pro
// Add/Edit Supplier Form - Professional Design System
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../data/database/app_database.dart';

class SupplierFormScreenPro extends ConsumerStatefulWidget {
  final String? supplierId;

  const SupplierFormScreenPro({
    super.key,
    this.supplierId,
  });

  bool get isEditing => supplierId != null;

  @override
  ConsumerState<SupplierFormScreenPro> createState() =>
      _SupplierFormScreenProState();
}

class _SupplierFormScreenProState extends ConsumerState<SupplierFormScreenPro> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _bankAccountController = TextEditingController();

  String _supplierType = 'company';
  bool _isActive = true;
  bool _isLoading = false;
  bool _isSaving = false;
  Supplier? _existingSupplier;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadSupplierData();
    }
  }

  Future<void> _loadSupplierData() async {
    if (widget.supplierId == null) return;

    setState(() => _isLoading = true);
    try {
      final supplierRepo = ref.read(supplierRepositoryProvider);
      final supplier = await supplierRepo.getSupplierById(widget.supplierId!);

      if (supplier != null && mounted) {
        setState(() {
          _existingSupplier = supplier;
          _nameController.text = supplier.name;
          _phoneController.text = supplier.phone ?? '';
          _emailController.text = supplier.email ?? '';
          _addressController.text = supplier.address ?? '';
          _notesController.text = supplier.notes ?? '';
          _isActive = supplier.isActive;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _contactPersonController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: ProAppBar.close(
          title: widget.isEditing ? 'تعديل مورد' : 'مورد جديد',
        ),
        body: ProLoadingState.withMessage(message: 'جاري تحميل البيانات...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProAppBar.close(
        title: widget.isEditing ? 'تعديل مورد' : 'مورد جديد',
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveSupplier,
            child: _isSaving
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    'حفظ',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Supplier Type Selection
              _buildTypeSelection(),
              SizedBox(height: AppSpacing.lg),

              // Basic Info Section
              const ProSectionTitle('المعلومات الأساسية'),
              SizedBox(height: AppSpacing.md),
              ProTextField(
                controller: _nameController,
                label: _supplierType == 'company' ? 'اسم الشركة' : 'اسم المورد',
                hint: _supplierType == 'company'
                    ? 'أدخل اسم الشركة'
                    : 'أدخل اسم المورد',
                prefixIcon: _supplierType == 'company'
                    ? Icons.business_outlined
                    : Icons.person_outline,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'الاسم مطلوب' : null,
              ),
              SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: ProTextField(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      hint: '05xxxxxxxx',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'رقم الهاتف مطلوب' : null,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ProTextField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      hint: 'email@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              ProTextField(
                controller: _addressController,
                label: 'العنوان',
                hint: 'أدخل العنوان',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
              ),

              // Company Info Section
              if (_supplierType == 'company') ...[
                SizedBox(height: AppSpacing.lg),
                const ProSectionTitle('معلومات الشركة'),
                SizedBox(height: AppSpacing.md),
                ProTextField(
                  controller: _contactPersonController,
                  label: 'شخص التواصل',
                  hint: 'اسم الشخص المسؤول',
                  prefixIcon: Icons.person_pin_outlined,
                ),
                SizedBox(height: AppSpacing.md),
                ProTextField(
                  controller: _bankAccountController,
                  label: 'رقم الحساب البنكي',
                  hint: 'أدخل رقم الحساب',
                  prefixIcon: Icons.account_balance_outlined,
                ),
              ],

              // Notes Section
              SizedBox(height: AppSpacing.lg),
              const ProSectionTitle('ملاحظات'),
              SizedBox(height: AppSpacing.md),
              ProTextField(
                controller: _notesController,
                label: 'ملاحظات إضافية',
                hint: 'أضف أي ملاحظات...',
                prefixIcon: Icons.note_outlined,
                maxLines: 3,
              ),

              // Status Toggle (for editing)
              if (widget.isEditing) ...[
                SizedBox(height: AppSpacing.lg),
                const ProSectionTitle('الحالة'),
                SizedBox(height: AppSpacing.md),
                ProSwitchTile(
                  title: 'مورد نشط',
                  subtitle:
                      _isActive ? 'المورد متاح للتعاملات' : 'المورد غير متاح',
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: AppColors.success,
                ),
              ],

              // Balance Display (for editing)
              if (widget.isEditing && _existingSupplier != null) ...[
                SizedBox(height: AppSpacing.lg),
                _buildBalanceCard(),
              ],

              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              label: 'شركة',
              icon: Icons.business_rounded,
              isSelected: _supplierType == 'company',
              onTap: () => setState(() => _supplierType = 'company'),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildTypeButton(
              label: 'فرد',
              icon: Icons.person_rounded,
              isSelected: _supplierType == 'individual',
              onTap: () => setState(() => _supplierType = 'individual'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 20.sp,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final balance = _existingSupplier!.balance;
    final isOwed = balance > 0;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isOwed ? AppColors.error.soft : AppColors.success.soft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isOwed ? AppColors.error.border : AppColors.success.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isOwed
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: isOwed ? AppColors.error : AppColors.success,
              size: 24.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOwed ? 'مستحقات للمورد' : 'لا توجد مستحقات',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '${balance.abs().toStringAsFixed(0)} ل.س',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isOwed ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isOwed)
            ProButton(
              label: 'سداد',
              icon: Icons.payment_rounded,
              size: ProButtonSize.small,
              type: ProButtonType.tonal,
              onPressed: () => context.push('/vouchers/payment/add'),
            ),
        ],
      ),
    );
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final supplierRepo = ref.read(supplierRepositoryProvider);

      if (widget.isEditing && _existingSupplier != null) {
        // Update existing supplier using repository method
        await supplierRepo.updateSupplier(
          id: _existingSupplier!.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          isActive: _isActive,
        );

        if (mounted) {
          ProSnackbar.success(context, 'تم تحديث بيانات المورد بنجاح');
          context.pop();
        }
      } else {
        // Create new supplier using repository method
        await supplierRepo.createSupplier(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        if (mounted) {
          ProSnackbar.success(context, 'تم إضافة المورد بنجاح');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
