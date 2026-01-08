// ═══════════════════════════════════════════════════════════════════════════
// Returns Screen Pro - Enterprise Accounting Design
// Unified Returns Management with Ledger Precision
// Handles both Sales Returns and Purchase Returns
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hoor_manager/core/widgets/pro_tab_scaffold.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../core/widgets/dual_price_display.dart';

/// نوع المرتجع
enum ReturnType {
  sales,
  purchase,
}

extension ReturnTypeExtension on ReturnType {
  String get title =>
      this == ReturnType.sales ? 'مرتجعات المبيعات' : 'مرتجعات المشتريات';
  String get subtitle => this == ReturnType.sales
      ? 'إدارة مرتجعات العملاء'
      : 'إدارة مرتجعات الموردين';
  String get invoiceType =>
      this == ReturnType.sales ? 'sale_return' : 'purchase_return';
  String get originalInvoiceType =>
      this == ReturnType.sales ? 'sale' : 'purchase';
  String get newReturnTitle =>
      this == ReturnType.sales ? 'مرتجع مبيعات جديد' : 'مرتجع مشتريات جديد';
  String get selectInvoiceLabel => this == ReturnType.sales
      ? 'اختر فاتورة المبيعات'
      : 'اختر فاتورة المشتريات';
  String get partyField =>
      this == ReturnType.sales ? 'customerId' : 'supplierId';
  String get searchHint => this == ReturnType.sales
      ? 'بحث برقم الفاتورة أو العميل...'
      : 'بحث برقم الفاتورة أو المورد...';
  Color get accentColor =>
      this == ReturnType.sales ? AppColors.error : AppColors.warning;
}

class ReturnsScreenPro extends ConsumerStatefulWidget {
  final ReturnType type;

  const ReturnsScreenPro({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ReturnsScreenPro> createState() => _ReturnsScreenProState();
}

class _ReturnsScreenProState extends ConsumerState<ReturnsScreenPro> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Data Provider based on type
  // ═══════════════════════════════════════════════════════════════════════════

  StreamProvider<List<Invoice>> get _returnsProvider =>
      widget.type == ReturnType.sales
          ? salesReturnsStreamProvider
          : purchaseReturnsStreamProvider;

  // ═══════════════════════════════════════════════════════════════════════════
  // Filter Logic
  // ═══════════════════════════════════════════════════════════════════════════

  List<Invoice> _filterReturns(List<Invoice> returns) {
    var filtered = returns;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final partyId =
            widget.type == ReturnType.sales ? r.customerId : r.supplierId;
        return r.invoiceNumber.contains(_searchQuery) ||
            (partyId?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    if (_dateRange != null) {
      filtered = filtered.where((r) {
        return r.createdAt.isAfter(_dateRange!.start) &&
            r.createdAt.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by date descending
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Build UI
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final returnsAsync = ref.watch(_returnsProvider);

    return ProSimpleScaffold(
      header: _buildHeader(returnsAsync),
      searchWidget: _buildFilters(),
      body: returnsAsync.when(
        loading: () => const ProLoadingState(),
        error: (error, _) => ProErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(_returnsProvider),
        ),
        data: (returns) {
          final filtered = _filterReturns(returns);
          return filtered.isEmpty
              ? ProEmptyState.returns(isSales: widget.type == ReturnType.sales)
              : _buildReturnsList(filtered);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          widget.type == ReturnType.sales
              ? '/returns/sales/add'
              : '/returns/purchases/add',
        ),
        backgroundColor: widget.type.accentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          widget.type == ReturnType.sales ? 'مرتجع بيع' : 'مرتجع شراء',
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<List<Invoice>> returnsAsync) {
    return ProHeader(
      title: widget.type.title,
      subtitle: widget.type.subtitle,
      onBack: () => context.go('/'),
      actions: [
        returnsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (returns) {
            // ═══════════════════════════════════════════════════════════════
            // ⚠️ السياسة المحاسبية: جمع القيم المحفوظة
            // ═══════════════════════════════════════════════════════════════
            final totalSyp = returns.fold<double>(0, (sum, r) => sum + r.total);
            final totalUsd =
                returns.fold<double>(0, (sum, r) => sum + (r.totalUsd ?? 0));
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${returns.length} مرتجع',
                  style: AppTypography.labelSmall.copyWith(
                    color: widget.type.accentColor,
                  ),
                ),
                CompactDualPrice(
                  amountSyp: totalSyp,
                  amountUsd: totalUsd,
                  sypStyle: AppTypography.titleSmall.copyWith(
                    color: widget.type.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return ProSearchBarWithDateRange(
      controller: _searchController,
      hintText: widget.type.searchHint,
      onChanged: (value) => setState(() => _searchQuery = value),
      dateRange: _dateRange,
      onDateRangeTap: _selectDateRange,
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      locale: const Locale('ar'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: widget.type.accentColor),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Widget _buildReturnsList(List<Invoice> returns) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_returnsProvider),
      child: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: returns.length,
        itemBuilder: (context, index) => _ReturnCard(
          returnInvoice: returns[index],
          type: widget.type,
          onTap: () => context.push('/invoices/${returns[index].id}'),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // New Return Sheet
  // ═══════════════════════════════════════════════════════════════════════════

  // ignore: unused_element
  void _showNewReturnSheet() {
    Invoice? selectedInvoice;
    final reasonController = TextEditingController();
    final invoicesAsync = ref.read(invoicesStreamProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
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
                SizedBox(height: AppSpacing.lg),

                // Title
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: widget.type.accentColor.soft,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.assignment_return_rounded,
                        color: widget.type.accentColor,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      widget.type.newReturnTitle,
                      style: AppTypography.titleLarge
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),

                // Select Invoice
                Text(widget.type.selectInvoiceLabel,
                    style: AppTypography.labelLarge),
                SizedBox(height: AppSpacing.sm),
                invoicesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('خطأ في تحميل الفواتير'),
                  data: (invoices) {
                    final filteredInvoices = invoices
                        .where((i) =>
                            i.type == widget.type.originalInvoiceType &&
                            i.status != 'returned')
                        .toList();
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Invoice>(
                          isExpanded: true,
                          value: selectedInvoice,
                          hint: const Text('اختر الفاتورة'),
                          items: filteredInvoices
                              .map((i) => DropdownMenuItem(
                                    value: i,
                                    child: Text(
                                      // استخدام القيم المحفوظة فقط
                                      '${i.invoiceNumber} - ${NumberFormat('#,###').format(i.total)} ل.س (\$${(i.totalUsd ?? (i.exchangeRate != null && i.exchangeRate! > 0 ? i.total / i.exchangeRate! : 0)).toStringAsFixed(2)})',
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setSheetState(() => selectedInvoice = value),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: AppSpacing.md),

                // Reason
                Text('سبب الإرجاع', style: AppTypography.labelLarge),
                SizedBox(height: AppSpacing.sm),
                ProTextField(
                  controller: reasonController,
                  label: '',
                  maxLines: 3,
                  hint: widget.type == ReturnType.sales
                      ? 'أدخل سبب إرجاع المنتجات'
                      : 'أدخل سبب إرجاع المنتجات للمورد',
                  prefixIcon: Icons.notes,
                ),
                SizedBox(height: AppSpacing.xl),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.all(AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: selectedInvoice != null
                            ? () => _createReturn(
                                  invoice: selectedInvoice!,
                                  reason: reasonController.text,
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.type.accentColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: const Text('إنشاء المرتجع'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createReturn({
    required Invoice invoice,
    required String reason,
  }) async {
    try {
      final invoiceRepo = ref.read(invoiceRepositoryProvider);
      // Get original invoice items
      final items = await invoiceRepo.getInvoiceItems(invoice.id);

      // ═══════════════════════════════════════════════════════════════════
      // ⚠️ السياسة المحاسبية: استخدام سعر الصرف من الفاتورة الأصلية
      // ═══════════════════════════════════════════════════════════════════
      final Map<String, dynamic> invoiceData = {
        'type': widget.type.invoiceType,
        'items': items
            .map((item) => {
                  'productId': item.productId,
                  'productName': item.productName,
                  'quantity': item.quantity,
                  'unitPrice': item.unitPrice,
                  'purchasePrice': item.purchasePrice,
                  // ⚠️ تمرير خصم العنصر من الفاتورة الأصلية
                  'discount': item.discountAmount,
                  // حفظ القيم المحفوظة من الفاتورة الأصلية
                  'unitPriceUsd': item.unitPriceUsd,
                  'exchangeRate': item.exchangeRate ?? invoice.exchangeRate,
                })
            .toList(),
        'paymentMethod': invoice.paymentMethod,
        // ⚠️ تمرير خصم الفاتورة من الفاتورة الأصلية
        'discountAmount': invoice.discountAmount,
        'notes': reason.isEmpty
            ? 'مرتجع ${widget.type == ReturnType.sales ? "مبيعات" : "مشتريات"} - فاتورة رقم: ${invoice.invoiceNumber}'
            : reason,
      };

      // Add customer or supplier based on type
      if (widget.type == ReturnType.sales) {
        invoiceData['customerId'] = invoice.customerId;
      } else {
        invoiceData['supplierId'] = invoice.supplierId;
      }

      // ═══════════════════════════════════════════════════════════════════
      // ⚠️ السياسة المحاسبية: تمرير سعر الصرف والخصم من الفاتورة الأصلية
      // ═══════════════════════════════════════════════════════════════════
      await invoiceRepo.createInvoice(
        type: invoiceData['type'],
        customerId: invoiceData['customerId'],
        supplierId: invoiceData['supplierId'],
        items: invoiceData['items'],
        discountAmount: invoice.discountAmount, // خصم الفاتورة الأصلية
        paymentMethod: invoiceData['paymentMethod'],
        notes: invoiceData['notes'],
        originalExchangeRate:
            invoice.exchangeRate, // سعر الصرف من الفاتورة الأصلية
      );

      if (mounted) {
        Navigator.pop(context);
        ProSnackbar.success(context, 'تم إنشاء المرتجع بنجاح');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.showError(context, e);
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Return Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _ReturnCard extends StatelessWidget {
  final Invoice returnInvoice;
  final ReturnType type;
  final VoidCallback onTap;

  const _ReturnCard({
    required this.returnInvoice,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');
    final partyId = type == ReturnType.sales
        ? returnInvoice.customerId
        : returnInvoice.supplierId;

    return ProCard(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      borderColor: type.accentColor.border,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: type.accentColor.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.assignment_return_rounded,
                  color: type.accentColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      returnInvoice.invoiceNumber,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dateFormat.format(returnInvoice.createdAt),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              CompactDualPrice(
                amountSyp: returnInvoice.total,
                // استخدام سعر الصرف المحفوظ مع الفاتورة
                amountUsd: returnInvoice.totalUsd ??
                    (returnInvoice.exchangeRate != null &&
                            returnInvoice.exchangeRate! > 0
                        ? returnInvoice.total / returnInvoice.exchangeRate!
                        : 0),
                sypStyle: AppTypography.titleMedium.copyWith(
                  color: type.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (partyId != null) ...[
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    type == ReturnType.sales
                        ? Icons.person_outline
                        : Icons.business_outlined,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    partyId,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSpacing.sm),
          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 14.sp, color: AppColors.textTertiary),
                  SizedBox(width: 4.w),
                  Text(
                    returnInvoice.status,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ],
      ),
    );
  }
}
