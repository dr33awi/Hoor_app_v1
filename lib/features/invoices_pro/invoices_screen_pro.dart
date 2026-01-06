// ═══════════════════════════════════════════════════════════════════════════
// Invoices Screen Pro - Enterprise Design System
// Sales & Purchase Invoices List with Professional Interface
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/mixins/invoice_filter_mixin.dart';
import '../../core/services/party_name_resolver.dart';
import '../../core/services/export/export_button.dart';
import '../../core/services/export/export_services.dart';
import '../../data/database/app_database.dart';

import 'widgets/invoice_card_pro.dart';
import 'widgets/invoices_stats_header.dart';

class InvoicesScreenPro extends ConsumerStatefulWidget {
  final String? type; // 'sale' or 'purchase' or null for all

  const InvoicesScreenPro({
    super.key,
    this.type,
  });

  @override
  ConsumerState<InvoicesScreenPro> createState() => _InvoicesScreenProState();
}

class _InvoicesScreenProState extends ConsumerState<InvoicesScreenPro>
    with SingleTickerProviderStateMixin, InvoiceFilterMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _filterStatus = 'all';
  DateTimeRange? _dateRange;
  String? _filterCustomerId;
  String? _filterSupplierId;
  String? _filterPaymentMethod; // 'cash' or 'credit'
  bool _isExporting = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedInvoices = {};

  bool get isSales => widget.type == null || widget.type == 'sale';

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

  // استخدام InvoiceFilterMixin للفلترة الموحدة
  List<Invoice> _filterInvoicesLocal(List<Invoice> invoices) {
    var filtered = filterInvoices(
      invoices,
      type: widget.type,
      status: _filterStatus,
      searchQuery: _searchController.text,
      dateRange: _dateRange,
    );

    // فلتر العميل/المورد
    if (_filterCustomerId != null) {
      filtered =
          filtered.where((i) => i.customerId == _filterCustomerId).toList();
    }
    if (_filterSupplierId != null) {
      filtered =
          filtered.where((i) => i.supplierId == _filterSupplierId).toList();
    }

    // فلتر طريقة الدفع
    if (_filterPaymentMethod != null) {
      filtered = filtered
          .where((i) => i.paymentMethod == _filterPaymentMethod)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ═══════════════════════════════════════════════════════════════
            // Header
            // ═══════════════════════════════════════════════════════════════
            _buildHeader(),

            // ═══════════════════════════════════════════════════════════════
            // Stats Header
            // ═══════════════════════════════════════════════════════════════
            invoicesAsync.when(
              loading: () => _buildStatsLoading(),
              error: (_, __) => const SizedBox.shrink(),
              data: (invoices) {
                final filtered = widget.type != null
                    ? invoices.where((i) => i.type == widget.type).toList()
                    : invoices;
                final totalAmount =
                    filtered.fold(0.0, (sum, i) => sum + i.total);
                // جمع قيم USD المحفوظة مع fallback لحساب من سعر الصرف
                final totalAmountUsd = filtered.fold(0.0, (sum, i) {
                  if (i.totalUsd != null && i.totalUsd! > 0) {
                    return sum + i.totalUsd!;
                  } else if (i.exchangeRate != null && i.exchangeRate! > 0) {
                    return sum + (i.total / i.exchangeRate!);
                  }
                  return sum;
                });
                final paidAmount =
                    filtered.fold(0.0, (sum, i) => sum + i.paidAmount);
                final paidAmountUsd = filtered.fold(0.0, (sum, i) {
                  if (i.paidAmountUsd != null && i.paidAmountUsd! > 0) {
                    return sum + i.paidAmountUsd!;
                  } else if (i.exchangeRate != null && i.exchangeRate! > 0) {
                    return sum + (i.paidAmount / i.exchangeRate!);
                  }
                  return sum;
                });
                final pendingAmount = totalAmount - paidAmount;

                return InvoicesStatsHeader(
                  totalAmount: totalAmount,
                  totalAmountUsd: totalAmountUsd,
                  paidAmount: paidAmount,
                  paidAmountUsd: paidAmountUsd,
                  pendingAmount: pendingAmount,
                  overdueAmount:
                      0, // لا يوجد حقل dueDate في قاعدة البيانات حالياً
                  isSales: isSales,
                );
              },
            ),

            // ═══════════════════════════════════════════════════════════════
            // Search & Filters
            // ═══════════════════════════════════════════════════════════════
            _buildSearchAndFilters(),

            // ═══════════════════════════════════════════════════════════════
            // Tabs
            // ═══════════════════════════════════════════════════════════════
            _buildTabs(),

            // ═══════════════════════════════════════════════════════════════
            // Invoices List
            // ═══════════════════════════════════════════════════════════════
            Expanded(
              child: invoicesAsync.when(
                loading: () => ProLoadingState.list(),
                error: (error, _) => ProEmptyState.error(
                  error: error.toString(),
                  onRetry: () => ref.invalidate(invoicesStreamProvider),
                ),
                data: (invoices) {
                  final filtered = _filterInvoicesLocal(invoices);

                  if (filtered.isEmpty) {
                    return ProEmptyState.list(
                      itemName: 'فاتورة',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(invoicesStreamProvider);
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.all(AppSpacing.screenPadding.w),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppSpacing.xs.h),
                      itemBuilder: (context, index) {
                        final invoice = filtered[index];
                        final isSelected =
                            _selectedInvoices.contains(invoice.id);

                        // استخدام PartyNameResolver لجلب اسم العميل/المورد
                        return FutureBuilder<String>(
                          future: _getPartyName(invoice),
                          builder: (context, snapshot) {
                            return GestureDetector(
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _selectedInvoices.add(invoice.id);
                                  });
                                }
                              },
                              child: Stack(
                                children: [
                                  InvoiceCardPro(
                                    invoice: _invoiceToMap(
                                      invoice,
                                      partyName: snapshot.data,
                                    ),
                                    onTap: _isSelectionMode
                                        ? () => _toggleSelection(invoice.id)
                                        : () => context
                                            .push('/invoices/${invoice.id}'),
                                    isSales: invoice.type == 'sale',
                                  ),
                                  if (_isSelectionMode)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        width: 24.w,
                                        height: 24.w,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.surface,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.border,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: isSelected
                                            ? Icon(Icons.check,
                                                size: 16.sp,
                                                color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  context.push(isSales ? '/sales/add' : '/purchases/add'),
              backgroundColor: isSales ? AppColors.income : AppColors.purchases,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                isSales ? 'فاتورة بيع' : 'فاتورة شراء',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final invoicesAsync = ref.watch(invoicesStreamProvider);

    return ProHeader(
      title: _isSelectionMode
          ? '${_selectedInvoices.length} محدد'
          : (isSales ? 'فواتير المبيعات' : 'فواتير المشتريات'),
      subtitle: _isSelectionMode ? 'اضغط للتحديد' : 'إدارة الفواتير والمدفوعات',
      onBack: _isSelectionMode
          ? () => setState(() {
                _isSelectionMode = false;
                _selectedInvoices.clear();
              })
          : () => context.go('/'),
      actions: [
        if (_isSelectionMode) ...[
          // حذف المحدد
          IconButton(
            onPressed:
                _selectedInvoices.isEmpty ? null : _deleteSelectedInvoices,
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'حذف المحدد',
          ),
          // إلغاء التحديد
          IconButton(
            onPressed: () => setState(() {
              _isSelectionMode = false;
              _selectedInvoices.clear();
            }),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'إلغاء',
          ),
        ] else ...[
          // زر التصدير
          invoicesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (invoices) => ExportMenuButton(
              onExport: (type) =>
                  _handleExport(type, _filterInvoicesLocal(invoices)),
              isLoading: _isExporting,
              enabledOptions: const {
                ExportType.excel,
                ExportType.pdf,
                ExportType.sharePdf,
                ExportType.shareExcel,
              },
              tooltip: 'تصدير الفواتير',
            ),
          ),
          // زر التحديد المتعدد
          IconButton(
            onPressed: () => setState(() => _isSelectionMode = true),
            icon: const Icon(Icons.checklist_rounded),
            tooltip: 'تحديد متعدد',
          ),
          // زر الفلاتر
          IconButton(
            onPressed: _showFilterSheet,
            icon: Badge(
              isLabelVisible: _hasActiveFilters,
              child: const Icon(Icons.filter_list_rounded),
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceMuted,
            ),
          ),
        ],
      ],
    );
  }

  bool get _hasActiveFilters =>
      _dateRange != null ||
      _filterCustomerId != null ||
      _filterSupplierId != null ||
      _filterPaymentMethod != null;

  Widget _buildStatsLoading() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding.w),
      height: 100.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding.w),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'بحث برقم الفاتورة...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.md.h,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: AppSpacing.md.h),

          // Date Range Chip
          if (_dateRange != null)
            Wrap(
              spacing: AppSpacing.sm.w,
              children: [
                Chip(
                  label: Text(
                    '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}',
                  ),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => setState(() => _dateRange = null),
                  backgroundColor: AppColors.secondaryMuted,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding.w,
        vertical: AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _filterStatus = 'all';
                break;
              case 1:
                _filterStatus = 'completed';
                break;
              case 2:
                _filterStatus = 'pending';
                break;
              case 3:
                _filterStatus = 'cancelled';
                break;
            }
          });
        },
        labelColor: AppColors.textOnPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'الكل'),
          Tab(text: 'مكتملة'),
          Tab(text: 'معلقة'),
          Tab(text: 'ملغية'),
        ],
      ),
    );
  }

  // استخدام PartyNameResolver للحصول على اسم العميل/المورد مع التخزين المؤقت
  Future<String> _getPartyName(Invoice invoice) async {
    final resolver = ref.read(partyNameResolverProvider);
    return resolver.getPartyName(invoice);
  }

  Map<String, dynamic> _invoiceToMap(Invoice invoice, {String? partyName}) {
    String statusText = 'مكتملة';
    if (invoice.status == 'pending') statusText = 'معلقة';
    if (invoice.status == 'cancelled') statusText = 'ملغية';
    if (invoice.paidAmount < invoice.total && invoice.status != 'cancelled') {
      statusText = 'جزئي';
    }

    // استخدام الاسم المُحمّل أو القيمة الافتراضية
    final defaultParty = invoice.type == 'sale' ? 'عميل نقدي' : 'مورد';
    final resolvedName = partyName ?? defaultParty;

    return {
      'id': invoice.invoiceNumber,
      'customer': resolvedName,
      'supplier': resolvedName,
      'date': DateFormat('yyyy-MM-dd').format(invoice.invoiceDate),
      'total': invoice.total,
      'paid': invoice.paidAmount,
      'status': statusText,
      'items': 0, // Will be loaded separately
      'paymentMethod': invoice.paymentMethod,
      // سعر الصرف المحفوظ وقت إنشاء الفاتورة
      'exchangeRate': invoice.exchangeRate,
      'totalUsd': invoice.totalUsd,
      'paidAmountUsd': invoice.paidAmountUsd,
    };
  }

  void _showFilterSheet() {
    final customersAsync = ref.watch(customersStreamProvider);
    final suppliersAsync = ref.watch(suppliersStreamProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(AppSpacing.screenPadding.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.sheet,
          ),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),

              Text('تصفية النتائج', style: AppTypography.titleLarge),
              SizedBox(height: AppSpacing.lg.h),

              // Date Range Picker
              ListTile(
                leading: Icon(Icons.date_range,
                    color: _dateRange != null ? AppColors.primary : null),
                title: const Text('فترة زمنية'),
                subtitle: _dateRange != null
                    ? Text(
                        '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}',
                        style: TextStyle(color: AppColors.primary),
                      )
                    : const Text('اختر فترة'),
                trailing: _dateRange != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dateRange = null),
                      )
                    : null,
                onTap: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    locale: const Locale('ar'),
                    initialDateRange: _dateRange,
                  );
                  if (range != null && mounted) {
                    setState(() => _dateRange = range);
                  }
                },
              ),
              const Divider(),

              // فلتر طريقة الدفع
              ListTile(
                leading: Icon(Icons.payment,
                    color: _filterPaymentMethod != null
                        ? AppColors.primary
                        : null),
                title: const Text('طريقة الدفع'),
                subtitle: Text(
                  _filterPaymentMethod == 'cash'
                      ? 'نقدي'
                      : _filterPaymentMethod == 'credit'
                          ? 'آجل'
                          : 'الكل',
                  style: _filterPaymentMethod != null
                      ? TextStyle(color: AppColors.primary)
                      : null,
                ),
                trailing: _filterPaymentMethod != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _filterPaymentMethod = null),
                      )
                    : null,
                onTap: () => _showPaymentMethodPicker(),
              ),
              const Divider(),

              // فلتر العميل (للمبيعات)
              if (isSales) ...[
                customersAsync.when(
                  loading: () => const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('جاري تحميل العملاء...'),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (customers) => ListTile(
                    leading: Icon(Icons.person,
                        color: _filterCustomerId != null
                            ? AppColors.primary
                            : null),
                    title: const Text('العميل'),
                    subtitle: Text(
                      _filterCustomerId != null
                          ? customers
                              .firstWhere((c) => c.id == _filterCustomerId,
                                  orElse: () => customers.first)
                              .name
                          : 'جميع العملاء',
                      style: _filterCustomerId != null
                          ? TextStyle(color: AppColors.primary)
                          : null,
                    ),
                    trailing: _filterCustomerId != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _filterCustomerId = null),
                          )
                        : null,
                    onTap: () => _showCustomerPicker(customers),
                  ),
                ),
                const Divider(),
              ],

              // فلتر المورد (للمشتريات)
              if (!isSales) ...[
                suppliersAsync.when(
                  loading: () => const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('جاري تحميل الموردين...'),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (suppliers) => ListTile(
                    leading: Icon(Icons.business,
                        color: _filterSupplierId != null
                            ? AppColors.primary
                            : null),
                    title: const Text('المورد'),
                    subtitle: Text(
                      _filterSupplierId != null
                          ? suppliers
                              .firstWhere((s) => s.id == _filterSupplierId,
                                  orElse: () => suppliers.first)
                              .name
                          : 'جميع الموردين',
                      style: _filterSupplierId != null
                          ? TextStyle(color: AppColors.primary)
                          : null,
                    ),
                    trailing: _filterSupplierId != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _filterSupplierId = null),
                          )
                        : null,
                    onTap: () => _showSupplierPicker(suppliers),
                  ),
                ),
                const Divider(),
              ],

              SizedBox(height: AppSpacing.lg.h),

              // Clear Filters
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _filterStatus = 'all';
                      _dateRange = null;
                      _filterCustomerId = null;
                      _filterSupplierId = null;
                      _filterPaymentMethod = null;
                      _searchController.clear();
                    });
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('مسح جميع الفلاتر'),
                ),
              ),
              SizedBox(height: AppSpacing.md.h),

              // Apply
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('تطبيق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('الكل'),
              selected: _filterPaymentMethod == null,
              onTap: () {
                setState(() => _filterPaymentMethod = null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('نقدي'),
              selected: _filterPaymentMethod == 'cash',
              onTap: () {
                setState(() => _filterPaymentMethod = 'cash');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('آجل'),
              selected: _filterPaymentMethod == 'credit',
              onTap: () {
                setState(() => _filterPaymentMethod = 'credit');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerPicker(List<Customer> customers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Text('اختر العميل', style: AppTypography.titleMedium),
              SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: customers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: const Icon(Icons.all_inclusive),
                        title: const Text('جميع العملاء'),
                        selected: _filterCustomerId == null,
                        onTap: () {
                          setState(() => _filterCustomerId = null);
                          Navigator.pop(context);
                        },
                      );
                    }
                    final customer = customers[index - 1];
                    return ListTile(
                      leading: CircleAvatar(child: Text(customer.name[0])),
                      title: Text(customer.name),
                      subtitle: Text(customer.phone ?? ''),
                      selected: _filterCustomerId == customer.id,
                      onTap: () {
                        setState(() => _filterCustomerId = customer.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupplierPicker(List<Supplier> suppliers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Text('اختر المورد', style: AppTypography.titleMedium),
              SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: suppliers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: const Icon(Icons.all_inclusive),
                        title: const Text('جميع الموردين'),
                        selected: _filterSupplierId == null,
                        onTap: () {
                          setState(() => _filterSupplierId = null);
                          Navigator.pop(context);
                        },
                      );
                    }
                    final supplier = suppliers[index - 1];
                    return ListTile(
                      leading: CircleAvatar(child: Text(supplier.name[0])),
                      title: Text(supplier.name),
                      subtitle: Text(supplier.phone ?? ''),
                      selected: _filterSupplierId == supplier.id,
                      onTap: () {
                        setState(() => _filterSupplierId = supplier.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSelection(String invoiceId) {
    setState(() {
      if (_selectedInvoices.contains(invoiceId)) {
        _selectedInvoices.remove(invoiceId);
        if (_selectedInvoices.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedInvoices.add(invoiceId);
      }
    });
  }

  Future<void> _deleteSelectedInvoices() async {
    final confirm = await showProDeleteDialog(
      context: context,
      itemName: '${_selectedInvoices.length} فاتورة',
      message:
          'سيتم حذف الفواتير المحددة نهائياً وعكس تأثيراتها على المخزون والأرصدة. هل أنت متأكد؟',
    );

    if (confirm != true) return;

    try {
      final invoiceRepo = ref.read(invoiceRepositoryProvider);
      for (final id in _selectedInvoices) {
        await invoiceRepo.deleteInvoiceWithReverse(id);
      }

      if (mounted) {
        ProSnackbar.success(
            context, 'تم حذف ${_selectedInvoices.length} فاتورة');
        setState(() {
          _isSelectionMode = false;
          _selectedInvoices.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ: $e');
      }
    }
  }

  Future<void> _handleExport(ExportType type, List<Invoice> invoices) async {
    if (invoices.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد فواتير للتصدير');
      return;
    }

    setState(() => _isExporting = true);
    final typeName = isSales ? 'المبيعات' : 'المشتريات';
    final typeCode = isSales ? 'sale' : 'purchase';
    final fileName =
        'فواتير_${typeName}_${DateFormat('yyyyMMdd').format(DateTime.now())}';

    try {
      switch (type) {
        case ExportType.excel:
          await ExcelExportService.exportInvoices(
            invoices: invoices,
            fileName: fileName,
          );
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.pdf:
          final pdfBytes = await PdfExportService.generateInvoicesList(
            invoices: invoices,
            type: typeCode,
          );
          await PdfExportService.savePdfFile(pdfBytes, fileName);
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.sharePdf:
          final pdfBytes = await PdfExportService.generateInvoicesList(
            invoices: invoices,
            type: typeCode,
          );
          await PdfExportService.sharePdfBytes(pdfBytes,
              fileName: fileName, subject: 'فواتير $typeName');
          break;
        case ExportType.shareExcel:
          final filePath = await ExcelExportService.exportInvoices(
            invoices: invoices,
            fileName: fileName,
          );
          await ExcelExportService.shareFile(filePath,
              subject: 'فواتير $typeName');
          break;
      }
    } catch (e) {
      if (mounted) ProSnackbar.error(context, 'حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
