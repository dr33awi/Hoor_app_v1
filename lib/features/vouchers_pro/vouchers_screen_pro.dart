// ═══════════════════════════════════════════════════════════════════════════
// Vouchers Screen Pro - Professional Design System
// Voucher Management Interface with Real Data
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hoor_manager/data/repositories/voucher_repository.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/export/export_services.dart';
import '../../core/services/export/export_button.dart';
import '../../data/database/app_database.dart';

class VouchersScreenPro extends ConsumerStatefulWidget {
  const VouchersScreenPro({super.key});

  @override
  ConsumerState<VouchersScreenPro> createState() => _VouchersScreenProState();
}

class _VouchersScreenProState extends ConsumerState<VouchersScreenPro>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  DateTimeRange? _dateRange;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Voucher> _filterVouchers(List<Voucher> vouchers, String? type) {
    var filtered = vouchers;

    if (type != null) {
      filtered = filtered.where((v) => v.type == type).toList();
    }

    // تصفية حسب نطاق التاريخ
    if (_dateRange != null) {
      filtered = filtered.where((v) {
        return v.voucherDate
                .isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            v.voucherDate
                .isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((v) =>
              v.voucherNumber.toLowerCase().contains(query) ||
              (v.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Sort by date descending
    filtered.sort((a, b) => b.voucherDate.compareTo(a.voucherDate));

    return filtered;
  }

  double _totalReceipts(List<Voucher> vouchers) => vouchers
      .where((v) => v.type == 'receipt')
      .fold(0.0, (sum, v) => sum + v.amount);

  double _totalPayments(List<Voucher> vouchers) => vouchers
      .where((v) => v.type == 'payment')
      .fold(0.0, (sum, v) => sum + v.amount);

  double _totalExpenses(List<Voucher> vouchers) => vouchers
      .where((v) => v.type == 'expense')
      .fold(0.0, (sum, v) => sum + v.amount);

  @override
  Widget build(BuildContext context) {
    final vouchersAsync = ref.watch(vouchersStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: vouchersAsync.when(
          loading: () => ProLoadingState.list(),
          error: (error, stack) => ProEmptyState.error(error: error.toString()),
          data: (vouchers) {
            final filteredVouchers = _filterVouchers(vouchers, null);
            return Column(
              children: [
                _buildHeader(vouchers.length, filteredVouchers),
                _buildStatsSummary(filteredVouchers),
                _buildSearchBar(),
                _buildFiltersRow(),
                _buildTabs(filteredVouchers),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVoucherList(_filterVouchers(vouchers, null)),
                      _buildVoucherList(_filterVouchers(vouchers, 'receipt')),
                      _buildVoucherList(_filterVouchers(vouchers, 'payment')),
                      _buildVoucherList(_filterVouchers(vouchers, 'expense')),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVoucherOptions(context),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'سند جديد',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  void _showAddVoucherOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'إضافة سند جديد',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _VoucherTypeButton(
                    icon: Icons.arrow_downward_rounded,
                    label: 'سند قبض',
                    color: AppColors.success,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/vouchers/receipt/add');
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _VoucherTypeButton(
                    icon: Icons.arrow_upward_rounded,
                    label: 'سند صرف',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/vouchers/payment/add');
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int totalVouchers, List<Voucher> filteredVouchers) {
    return ProHeader(
      title: 'السندات',
      subtitle: '$totalVouchers سند',
      onBack: () => context.go('/'),
      actions: [
        ExportMenuButton(
          onExport: (type) => _handleExport(type, filteredVouchers),
          isLoading: _isExporting,
          enabledOptions: const {
            ExportType.excel,
            ExportType.pdf,
            ExportType.sharePdf,
            ExportType.shareExcel,
          },
        ),
      ],
    );
  }

  Widget _buildStatsSummary(List<Voucher> vouchers) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'قبض',
              amount: _totalReceipts(vouchers),
              icon: Icons.arrow_downward_rounded,
              color: AppColors.success,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _StatCard(
              label: 'صرف',
              amount: _totalPayments(vouchers),
              icon: Icons.arrow_upward_rounded,
              color: AppColors.error,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _StatCard(
              label: 'مصاريف',
              amount: _totalExpenses(vouchers),
              icon: Icons.receipt_outlined,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ProSearchBar(
      controller: _searchController,
      hintText: 'ابحث برقم السند أو الوصف...',
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildFiltersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // فلتر التاريخ
          ActionChip(
            avatar: Icon(
              _dateRange != null ? Icons.clear : Icons.date_range_rounded,
              size: 18,
              color: _dateRange != null ? AppColors.error : AppColors.primary,
            ),
            label: Text(
              _dateRange != null
                  ? '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}'
                  : 'التاريخ',
              style: AppTypography.bodySmall.copyWith(
                color: _dateRange != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            backgroundColor: _dateRange != null
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface,
            side: BorderSide(
              color: _dateRange != null ? AppColors.primary : AppColors.border,
            ),
            onPressed: _dateRange != null
                ? () => setState(() => _dateRange = null)
                : _selectDateRange,
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _dateRange,
      locale: const Locale('ar'),
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  Future<void> _handleExport(ExportType type, List<Voucher> vouchers) async {
    if (vouchers.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد سندات للتصدير');
      return;
    }

    setState(() => _isExporting = true);
    final fileName = 'السندات_${DateFormat('yyyyMMdd').format(DateTime.now())}';

    try {
      switch (type) {
        case ExportType.excel:
          final filePath = await ExcelExportService.exportVouchers(
            vouchers: vouchers,
            fileName: fileName,
          );
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.pdf:
          final pdfBytes =
              await PdfExportService.generateVouchersList(vouchers: vouchers);
          await PdfExportService.savePdfFile(pdfBytes, fileName);
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.sharePdf:
          final pdfBytes =
              await PdfExportService.generateVouchersList(vouchers: vouchers);
          await PdfExportService.sharePdfBytes(pdfBytes,
              fileName: fileName, subject: 'تقرير السندات');
          break;
        case ExportType.shareExcel:
          final filePath = await ExcelExportService.exportVouchers(
            vouchers: vouchers,
            fileName: fileName,
          );
          await ExcelExportService.shareFile(filePath,
              subject: 'تقرير السندات');
          break;
      }
    } catch (e) {
      if (mounted) ProSnackbar.error(context, 'حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildTabs(List<Voucher> vouchers) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary.soft,
          borderRadius: BorderRadius.circular(AppRadius.md - 1),
        ),
        dividerColor: Colors.transparent,
        tabs: [
          _buildTab('الكل', vouchers.length),
          _buildTab('قبض', vouchers.where((v) => v.type == 'receipt').length),
          _buildTab('صرف', vouchers.where((v) => v.type == 'payment').length),
          _buildTab(
              'مصاريف', vouchers.where((v) => v.type == 'expense').length),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          SizedBox(width: AppSpacing.xs),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.textTertiary.light,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '$count',
              style: AppTypography.labelSmall.mono,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherList(List<Voucher> vouchers) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'لا يوجد سندات',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        final voucher = vouchers[index];
        return _VoucherCard(
          voucher: voucher,
          onTap: () => context.push('/vouchers/${voucher.id}'),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppIconSize.sm),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
          Text(
            amount.toStringAsFixed(0),
            style: AppTypography.titleSmall
                .copyWith(
                  color: color,
                )
                .monoBold,
          ),
        ],
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final VoidCallback? onTap;

  const _VoucherCard({required this.voucher, this.onTap});

  Color get _typeColor {
    switch (voucher.type) {
      case 'receipt':
        return AppColors.success;
      case 'payment':
        return AppColors.error;
      case 'expense':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _typeIcon {
    switch (voucher.type) {
      case 'receipt':
        return Icons.arrow_downward_rounded;
      case 'payment':
        return Icons.arrow_upward_rounded;
      case 'expense':
        return Icons.receipt_outlined;
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return GestureDetector(
      onTap: onTap,
      child: ProCard(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            ProIconBox(icon: _typeIcon, color: _typeColor),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${voucher.voucherNumber}',
                        style: AppTypography.titleSmall
                            .copyWith(
                              color: AppColors.textPrimary,
                            )
                            .monoSemibold,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      ProStatusBadge.fromVoucherType(voucher.type, small: true),
                    ],
                  ),
                  if (voucher.description != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      voucher.description!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 4.h),
                  Text(
                    dateFormat.format(voucher.voucherDate),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${voucher.amount.toStringAsFixed(0)} ل.س',
              style: AppTypography.titleMedium
                  .copyWith(
                    color: _typeColor,
                  )
                  .monoBold,
            ),
            SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Voucher Form Screen Pro - Add/Edit Voucher
// ═══════════════════════════════════════════════════════════════════════════

class VoucherFormScreenPro extends ConsumerStatefulWidget {
  final String type; // 'receipt' or 'payment' or 'expense'
  final String? voucherId; // For editing

  const VoucherFormScreenPro({
    super.key,
    required this.type,
    this.voucherId,
  });

  bool get isEditing => voucherId != null;

  @override
  ConsumerState<VoucherFormScreenPro> createState() =>
      _VoucherFormScreenProState();
}

class _VoucherFormScreenProState extends ConsumerState<VoucherFormScreenPro> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCustomerId;
  String? _selectedSupplierId;
  String? _selectedCategoryId;
  DateTime _voucherDate = DateTime.now();
  bool _isSaving = false;
  bool _isLoading = false;
  Voucher? _existingVoucher;

  // بيانات العملاء والموردين والفئات
  List<Customer> _customers = [];
  List<Supplier> _suppliers = [];
  List<VoucherCategory> _categories = [];

  String get _title {
    switch (widget.type) {
      case 'receipt':
        return 'سند قبض';
      case 'payment':
        return 'سند صرف';
      case 'expense':
        return 'سند مصاريف';
      default:
        return 'سند';
    }
  }

  Color get _accentColor {
    switch (widget.type) {
      case 'receipt':
        return AppColors.success;
      case 'payment':
        return AppColors.error;
      case 'expense':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData get _typeIcon {
    switch (widget.type) {
      case 'receipt':
        return Icons.arrow_downward_rounded;
      case 'payment':
        return Icons.arrow_upward_rounded;
      case 'expense':
        return Icons.receipt_outlined;
      default:
        return Icons.description;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.isEditing) {
      _loadVoucherData();
    }
  }

  Future<void> _loadVoucherData() async {
    if (widget.voucherId == null) return;

    setState(() => _isLoading = true);
    try {
      final voucherRepo = ref.read(voucherRepositoryProvider);
      final voucher = await voucherRepo.getVoucherById(widget.voucherId!);

      if (voucher != null && mounted) {
        setState(() {
          _existingVoucher = voucher;
          _amountController.text = voucher.amount.toStringAsFixed(0);
          _descriptionController.text = voucher.description ?? '';
          _selectedCustomerId = voucher.customerId;
          _selectedSupplierId = voucher.supplierId;
          _selectedCategoryId = voucher.categoryId;
          _voucherDate = voucher.voucherDate;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    // تحميل العملاء والموردين
    final customersAsync = ref.read(customersStreamProvider);
    final suppliersAsync = ref.read(suppliersStreamProvider);

    customersAsync.whenData((customers) {
      if (mounted) setState(() => _customers = customers);
    });

    suppliersAsync.whenData((suppliers) {
      if (mounted) setState(() => _suppliers = suppliers);
    });

    // تحميل فئات المصاريف
    if (widget.type == 'expense') {
      final voucherRepo = ref.read(voucherRepositoryProvider);
      final categories =
          await voucherRepo.getCategoriesByType(VoucherType.expense);
      if (mounted) setState(() => _categories = categories);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to customers and suppliers updates
    ref.listen(customersStreamProvider, (_, next) {
      next.whenData((customers) {
        if (mounted) setState(() => _customers = customers);
      });
    });

    ref.listen(suppliersStreamProvider, (_, next) {
      next.whenData((suppliers) {
        if (mounted) setState(() => _suppliers = suppliers);
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProAppBar.close(
        title: _title,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveVoucher,
            child: _isSaving
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _accentColor,
                    ),
                  )
                : Text(
                    'حفظ',
                    style: AppTypography.labelLarge.copyWith(
                      color: _accentColor,
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
              // Type Icon Header
              _buildTypeHeader(),
              SizedBox(height: AppSpacing.xl),

              // Amount Section
              const ProSectionTitle('المبلغ'),
              SizedBox(height: AppSpacing.md),
              _buildAmountField(),
              SizedBox(height: AppSpacing.lg),

              // Party Selection (Customer/Supplier)
              if (widget.type != 'expense') ...[
                ProSectionTitle(
                  widget.type == 'receipt' ? 'العميل' : 'المورد',
                ),
                SizedBox(height: AppSpacing.md),
                _buildPartySelector(),
                SizedBox(height: AppSpacing.lg),
              ],

              // Category Selection (for expenses)
              if (widget.type == 'expense') ...[
                const ProSectionTitle('فئة المصاريف'),
                SizedBox(height: AppSpacing.md),
                _buildCategorySelector(),
                SizedBox(height: AppSpacing.lg),
              ],

              // Date Selection
              const ProSectionTitle('التاريخ'),
              SizedBox(height: AppSpacing.md),
              _buildDateSelector(),
              SizedBox(height: AppSpacing.lg),

              // Description
              const ProSectionTitle('الوصف'),
              SizedBox(height: AppSpacing.md),
              ProTextField(
                controller: _descriptionController,
                label: 'وصف السند',
                hint: 'أدخل وصف أو ملاحظات...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeHeader() {
    return Center(
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          color: _accentColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: _accentColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Icon(
          _typeIcon,
          color: _accentColor,
          size: 40.sp,
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium.copyWith(
              color: _accentColor,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: AppTypography.displayMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              suffixText: 'ر.س',
              suffixStyle: AppTypography.titleLarge.copyWith(
                color: AppColors.textSecondary,
              ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPartySelector() {
    final isReceipt = widget.type == 'receipt';
    final items = isReceipt ? _customers : _suppliers;
    final selectedId = isReceipt ? _selectedCustomerId : _selectedSupplierId;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(
                isReceipt
                    ? Icons.person_outline
                    : Icons.local_shipping_outlined,
                color: AppColors.textTertiary,
                size: AppIconSize.sm,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                isReceipt ? 'اختر العميل' : 'اختر المورد',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          items: items.map((item) {
            final id =
                isReceipt ? (item as Customer).id : (item as Supplier).id;
            final name =
                isReceipt ? (item as Customer).name : (item as Supplier).name;
            final balance = isReceipt
                ? (item as Customer).balance
                : (item as Supplier).balance;

            return DropdownMenuItem<String>(
              value: id,
              child: Row(
                children: [
                  Icon(
                    isReceipt
                        ? Icons.person_rounded
                        : Icons.local_shipping_rounded,
                    color: _accentColor,
                    size: AppIconSize.sm,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${balance.toStringAsFixed(0)} ل.س',
                    style: AppTypography.labelSmall.copyWith(
                      color: balance > 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              if (isReceipt) {
                _selectedCustomerId = value;
              } else {
                _selectedSupplierId = value;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategoryId,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(
                Icons.category_outlined,
                color: AppColors.textTertiary,
                size: AppIconSize.sm,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'اختر فئة المصاريف',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    color: AppColors.warning,
                    size: AppIconSize.sm,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    category.name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCategoryId = value);
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppColors.textSecondary,
              size: AppIconSize.sm,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ السند',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('yyyy/MM/dd', 'ar').format(_voucherDate),
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textTertiary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _voucherDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() => _voucherDate = picked);
    }
  }

  Future<void> _saveVoucher() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من اختيار العميل/المورد
    if (widget.type == 'receipt' && _selectedCustomerId == null) {
      ProSnackbar.error(context, 'يرجى اختيار العميل');
      return;
    }
    if (widget.type == 'payment' && _selectedSupplierId == null) {
      ProSnackbar.error(context, 'يرجى اختيار المورد');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final voucherRepo = ref.read(voucherRepositoryProvider);
      final shiftAsync = ref.read(openShiftStreamProvider);

      // الحصول على الشفت المفتوح
      String? shiftId;
      shiftAsync.whenData((shift) => shiftId = shift?.id);

      final amount = double.parse(_amountController.text);

      // تحديد نوع السند
      final voucherType = switch (widget.type) {
        'receipt' => VoucherType.receipt,
        'payment' => VoucherType.payment,
        _ => VoucherType.expense,
      };

      await voucherRepo.createVoucher(
        type: voucherType,
        amount: amount,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        customerId: _selectedCustomerId,
        supplierId: _selectedSupplierId,
        categoryId: _selectedCategoryId,
        shiftId: shiftId,
        voucherDate: _voucherDate,
      );

      if (mounted) {
        ProSnackbar.success(context,
            widget.isEditing ? 'تم تحديث السند بنجاح' : 'تم حفظ السند بنجاح');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Voucher Type Button Widget
// ═══════════════════════════════════════════════════════════════════════════
class _VoucherTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _VoucherTypeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: color.soft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color.border),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
