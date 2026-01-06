// ═══════════════════════════════════════════════════════════════════════════
// Add/Edit Expense Screen Pro - Enterprise Design System
// Expense Entry Interface
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════
//
// ⚠️ قواعد إدخال المصروف:
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ ✅ المبلغ يُدخل بالعملة المختارة (ليرة أو دولار)                             │
// │ ✅ سعر الصرف يُثبت تلقائياً وقت الحفظ                                        │
// │ ✅ يتم حساب وحفظ المبلغ بالعملتين                                           │
// │ ✅ يُخصم من الصندوق فوراً                                                    │
// │ ❌ لا تأثير على المخزون                                                      │
// └─────────────────────────────────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/currency_formatter.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/price_locking_service.dart';
import '../../data/database/app_database.dart';

class ExpenseFormScreenPro extends ConsumerStatefulWidget {
  final String? expenseId; // null للإضافة، معرف للتعديل

  const ExpenseFormScreenPro({
    super.key,
    this.expenseId,
  });

  @override
  ConsumerState<ExpenseFormScreenPro> createState() =>
      _ExpenseFormScreenProState();
}

class _ExpenseFormScreenProState extends ConsumerState<ExpenseFormScreenPro> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isUsd = false; // العملة المختارة
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  // بيانات المصروف الأصلي (للتعديل)
  Voucher? _originalExpense;

  // التصنيفات
  List<VoucherCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.expenseId != null;
    _loadCategories();
    if (_isEditMode) {
      _loadExpense();
    }
  }

  Future<void> _loadCategories() async {
    final expenseRepo = ref.read(expenseRepositoryProvider);
    final categories = await expenseRepo.getAllCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty && _selectedCategoryId == null) {
          _selectedCategoryId = _categories.first.id;
        }
      });
    }
  }

  Future<void> _loadExpense() async {
    if (widget.expenseId == null) return;

    setState(() => _isLoading = true);
    try {
      final expenseRepo = ref.read(expenseRepositoryProvider);
      final expense = await expenseRepo.getExpenseById(widget.expenseId!);

      if (expense != null && mounted) {
        setState(() {
          _originalExpense = expense;
          _amountController.text = _isUsd
              ? (expense.amountUsd ?? 0).toStringAsFixed(2)
              : expense.amount.toStringAsFixed(0);
          _descriptionController.text = expense.description ?? '';
          _selectedCategoryId = expense.categoryId;
          _selectedDate = expense.voucherDate;
        });
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في تحميل المصروف: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// حساب المعاينة المباشرة للمبلغ
  LockedPrice? _calculatePreview() {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return null;

    final currencyService = ref.read(currencyServiceProvider);
    final rate = currencyService.exchangeRate;

    if (_isUsd) {
      return LockedPrice(
        usd: amount,
        syp: amount * rate,
        exchangeRate: rate,
        lockedAt: DateTime.now(),
      );
    } else {
      return LockedPrice(
        syp: amount,
        usd: rate > 0 ? amount / rate : 0,
        exchangeRate: rate,
        lockedAt: DateTime.now(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyService = ref.watch(currencyServiceProvider);
    final openShiftAsync = ref.watch(openShiftStreamProvider);
    final preview = _calculatePreview();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProHeader(
              title: _isEditMode ? 'تعديل مصروف' : 'مصروف جديد',
              subtitle: _isEditMode
                  ? _originalExpense?.voucherNumber ?? ''
                  : 'تسجيل مصروف من الصندوق',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _isLoading
                  ? ProLoadingState.simple()
                  : openShiftAsync.when(
                      loading: () => ProLoadingState.simple(),
                      error: (e, _) => ProEmptyState.error(error: e.toString()),
                      data: (shift) {
                        if (shift == null) {
                          return ProEmptyState(
                            icon: Icons.lock_clock,
                            title: 'لا توجد وردية مفتوحة',
                            message: 'يجب فتح وردية قبل تسجيل المصاريف',
                            actionLabel: 'فتح وردية',
                            onAction: () => context.push('/shifts'),
                          );
                        }
                        return _buildForm(currencyService, preview);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(CurrencyService currencyService, LockedPrice? preview) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // سعر الصرف الحالي (للعرض فقط)
          // ═══════════════════════════════════════════════════════════════════
          _buildExchangeRateCard(currencyService),
          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════════════
          // المبلغ والعملة
          // ═══════════════════════════════════════════════════════════════════
          _buildAmountSection(),
          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════════════
          // معاينة المبلغ بالعملتين
          // ═══════════════════════════════════════════════════════════════════
          if (preview != null) ...[
            _buildPreviewCard(preview),
            SizedBox(height: AppSpacing.lg),
          ],

          // ═══════════════════════════════════════════════════════════════════
          // التصنيف
          // ═══════════════════════════════════════════════════════════════════
          _buildCategorySection(),
          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════════════
          // التاريخ
          // ═══════════════════════════════════════════════════════════════════
          _buildDateSection(),
          SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════════════
          // الملاحظة
          // ═══════════════════════════════════════════════════════════════════
          _buildDescriptionSection(),
          SizedBox(height: AppSpacing.xl),

          // ═══════════════════════════════════════════════════════════════════
          // التأثير المحاسبي
          // ═══════════════════════════════════════════════════════════════════
          _buildAccountingNotes(),
          SizedBox(height: AppSpacing.xl),

          // ═══════════════════════════════════════════════════════════════════
          // أزرار الحفظ
          // ═══════════════════════════════════════════════════════════════════
          _buildActionButtons(),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildExchangeRateCard(CurrencyService currencyService) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.currency_exchange, color: AppColors.info, size: 24.sp),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سعر الصرف الحالي',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${CurrencyFormatter.formatNumber(currencyService.exchangeRate)} ل.س / \$',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.info,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'سيُثبّت عند الحفظ',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProSectionTitle('المبلغ', icon: Icons.attach_money),
        SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حقل المبلغ
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: Icon(
                    _isUsd ? Icons.attach_money : Icons.money,
                    color: AppColors.expense,
                  ),
                  suffixText: _isUsd ? 'USD' : 'SYP',
                  suffixStyle: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: AppColors.expense, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  final amount = double.tryParse(value.replaceAll(',', ''));
                  if (amount == null || amount <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            // تبديل العملة
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _CurrencyButton(
                        label: 'ل.س',
                        isSelected: !_isUsd,
                        onTap: () => setState(() => _isUsd = false),
                      ),
                    ),
                    Expanded(
                      child: _CurrencyButton(
                        label: '\$',
                        isSelected: _isUsd,
                        onTap: () => setState(() => _isUsd = true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewCard(LockedPrice preview) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.expense.withValues(alpha: 0.1),
            AppColors.expenseSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.expense.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'سيتم تسجيل المبلغ كالتالي',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.expense,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // المبلغ بالليرة
              Column(
                children: [
                  Text(
                    CurrencyFormatter.formatSyp(preview.syp),
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.expense,
                    ),
                  ),
                  Text(
                    'ليرة سورية',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40.h,
                width: 1,
                color: AppColors.border,
              ),
              // المبلغ بالدولار
              Column(
                children: [
                  Text(
                    CurrencyFormatter.formatUsd(preview.usd),
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'دولار أمريكي',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProSectionTitle('التصنيف', icon: Icons.category),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // الفئات المعروضة كشبكة
              if (_categories.isEmpty)
                Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: AppColors.textSecondary),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'لا توجد تصنيفات',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategoryId == category.id;
                      return ChoiceChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCategoryId = category.id);
                        },
                        selectedColor: AppColors.expense.withValues(alpha: 0.2),
                        backgroundColor: AppColors.surfaceMuted,
                        labelStyle: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.expense
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.expense
                              : Colors.transparent,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              // زر إضافة تصنيف جديد
              Divider(height: 1),
              InkWell(
                onTap: _showAddCategoryDialog,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColors.secondary, size: 18.sp),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'إضافة تصنيف جديد',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.secondary,
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

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصنيف جديد'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم التصنيف',
            hintText: 'مثال: إيجار، رواتب، فواتير...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              Navigator.pop(context);
              try {
                final expenseRepo = ref.read(expenseRepositoryProvider);
                final id = await expenseRepo.createCategory(name: name);
                await _loadCategories();
                setState(() => _selectedCategoryId = id);
                if (mounted) {
                  ProSnackbar.success(context, 'تم إضافة التصنيف');
                }
              } catch (e) {
                if (mounted) {
                  ProSnackbar.error(context, e.toString());
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProSectionTitle('التاريخ', icon: Icons.calendar_today),
        SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: AppColors.secondary),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE', 'ar').format(_selectedDate),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        DateFormat('d MMMM yyyy', 'ar').format(_selectedDate),
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProSectionTitle('الملاحظة', icon: Icons.note),
        SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'وصف المصروف (اختياري)',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.secondary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountingNotes() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 20.sp),
              SizedBox(width: AppSpacing.sm),
              Text(
                'التأثير المحاسبي',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          _AccountingNoteItem(
            icon: Icons.check_circle,
            text: 'سيتم خصم المبلغ من الصندوق',
            isPositive: true,
          ),
          _AccountingNoteItem(
            icon: Icons.check_circle,
            text: 'سيتم تثبيت سعر الصرف الحالي',
            isPositive: true,
          ),
          _AccountingNoteItem(
            icon: Icons.check_circle,
            text: 'سيظهر في تقرير المصاريف والأرباح',
            isPositive: true,
          ),
          _AccountingNoteItem(
            icon: Icons.cancel,
            text: 'لن يؤثر على المخزون',
            isPositive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: BorderSide(color: AppColors.border),
            ),
            child: const Text('إلغاء'),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _saveExpense,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            icon: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isEditMode ? 'حفظ التعديلات' : 'تسجيل المصروف'),
          ),
        ),
      ],
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ProSnackbar.error(context, 'يرجى اختيار تصنيف');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final expenseRepo = ref.read(expenseRepositoryProvider);
      final amountText = _amountController.text.replaceAll(',', '');
      final amount = double.parse(amountText);
      final description = _descriptionController.text.trim();

      if (_isEditMode && widget.expenseId != null) {
        // تحديث المصروف
        await expenseRepo.updateExpense(
          id: widget.expenseId!,
          amount: amount,
          isUsd: _isUsd,
          categoryId: _selectedCategoryId,
          description: description.isEmpty ? null : description,
          expenseDate: _selectedDate,
        );
        if (mounted) {
          ProSnackbar.success(context, 'تم تحديث المصروف بنجاح');
        }
      } else {
        // إنشاء مصروف جديد
        await expenseRepo.createExpense(
          amount: amount,
          isUsd: _isUsd,
          categoryId: _selectedCategoryId!,
          description: description.isEmpty ? null : description,
          expenseDate: _selectedDate,
        );
        if (mounted) {
          ProSnackbar.success(context, 'تم تسجيل المصروف بنجاح');
        }
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Widgets المساعدة
// ═══════════════════════════════════════════════════════════════════════════

class _CurrencyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.expense : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg - 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg - 1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountingNoteItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isPositive;

  const _AccountingNoteItem({
    required this.icon,
    required this.text,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isPositive ? AppColors.success : AppColors.textTertiary,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
