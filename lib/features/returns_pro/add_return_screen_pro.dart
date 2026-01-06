// ═══════════════════════════════════════════════════════════════════════════
// Add Return Screen Pro - Enterprise Accounting Design
// Full Screen for Creating New Returns
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import 'returns_screen_pro.dart';

class AddReturnScreenPro extends ConsumerStatefulWidget {
  final ReturnType type;

  const AddReturnScreenPro({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<AddReturnScreenPro> createState() => _AddReturnScreenProState();
}

class _AddReturnScreenProState extends ConsumerState<AddReturnScreenPro> {
  Invoice? _selectedInvoice;
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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
            ProHeader(
              title: widget.type.newReturnTitle,
              subtitle: widget.type == ReturnType.sales
                  ? 'إرجاع منتجات من العميل'
                  : 'إرجاع منتجات للمورد',
              onBack: () => context.pop(),
            ),

            // ═══════════════════════════════════════════════════════════════
            // Content
            // ═══════════════════════════════════════════════════════════════
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.screenPadding.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ═══════════════════════════════════════════════════════
                    // Select Invoice Card
                    // ═══════════════════════════════════════════════════════
                    ProCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color:
                                      widget.type.accentColor.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: widget.type.accentColor,
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.type.selectInvoiceLabel,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'اختر الفاتورة التي تريد إرجاعها',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.lg),
                          invoicesAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, _) => Center(
                              child: Text(
                                'خطأ في تحميل الفواتير',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                            data: (invoices) {
                              final filteredInvoices = invoices
                                  .where((i) =>
                                      i.type ==
                                          widget.type.originalInvoiceType &&
                                      i.status != 'returned' &&
                                      i.status != 'cancelled')
                                  .toList();

                              if (filteredInvoices.isEmpty) {
                                return Container(
                                  padding: EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 48.sp,
                                        color: AppColors.textTertiary,
                                      ),
                                      SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'لا توجد فواتير متاحة للإرجاع',
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Invoice>(
                                    isExpanded: true,
                                    value: _selectedInvoice,
                                    hint: const Text('اختر الفاتورة'),
                                    items: filteredInvoices
                                        .map((i) => DropdownMenuItem(
                                              value: i,
                                              child: Text(
                                                '${i.invoiceNumber} - ${NumberFormat('#,###').format(i.total)} ل.س',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) => setState(
                                        () => _selectedInvoice = value),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSpacing.lg),

                    // ═══════════════════════════════════════════════════════
                    // Selected Invoice Details
                    // ═══════════════════════════════════════════════════════
                    if (_selectedInvoice != null) ...[
                      ProCard(
                        borderColor: widget.type.accentColor.withOpacity(0.3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفاصيل الفاتورة',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppSpacing.md),
                            _buildDetailRow(
                              'رقم الفاتورة',
                              _selectedInvoice!.invoiceNumber,
                            ),
                            _buildDetailRow(
                              'التاريخ',
                              DateFormat('yyyy/MM/dd')
                                  .format(_selectedInvoice!.invoiceDate),
                            ),
                            _buildDetailRow(
                              'المبلغ',
                              '${NumberFormat('#,###').format(_selectedInvoice!.total)} ل.س',
                              valueColor: widget.type.accentColor,
                            ),
                            if (_selectedInvoice!.totalUsd != null ||
                                (_selectedInvoice!.exchangeRate != null &&
                                    _selectedInvoice!.exchangeRate! > 0))
                              _buildDetailRow(
                                'المبلغ بالدولار',
                                '\$${(_selectedInvoice!.totalUsd ?? (_selectedInvoice!.total / _selectedInvoice!.exchangeRate!)).toStringAsFixed(2)}',
                              ),
                            _buildDetailRow(
                              'طريقة الدفع',
                              _selectedInvoice!.paymentMethod == 'cash'
                                  ? 'نقدي'
                                  : 'آجل',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                    ],

                    // ═══════════════════════════════════════════════════════
                    // Reason Card
                    // ═══════════════════════════════════════════════════════
                    ProCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(
                                  Icons.notes_rounded,
                                  color: AppColors.warning,
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              Text(
                                'سبب الإرجاع',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.lg),
                          TextField(
                            controller: _reasonController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: widget.type == ReturnType.sales
                                  ? 'أدخل سبب إرجاع المنتجات من العميل...'
                                  : 'أدخل سبب إرجاع المنتجات للمورد...',
                              filled: true,
                              fillColor: AppColors.surfaceMuted,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.all(AppSpacing.md),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSpacing.xl * 2),
                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // Bottom Action Button
            // ═══════════════════════════════════════════════════════════════
            Container(
              padding: EdgeInsets.all(AppSpacing.screenPadding.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedInvoice != null && !_isLoading
                        ? _createReturn
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.type.accentColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                'إنشاء المرتجع',
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createReturn() async {
    if (_selectedInvoice == null) return;

    setState(() => _isLoading = true);

    try {
      final invoiceRepo = ref.read(invoiceRepositoryProvider);
      final invoice = _selectedInvoice!;

      // Get original invoice items
      final items = await invoiceRepo.getInvoiceItems(invoice.id);

      // ═══════════════════════════════════════════════════════════════════
      // ⚠️ السياسة المحاسبية: استخدام سعر الصرف من الفاتورة الأصلية
      // ═══════════════════════════════════════════════════════════════════
      final invoiceType =
          widget.type == ReturnType.sales ? 'sale_return' : 'purchase_return';

      final itemsData = items
          .map((item) => {
                'productId': item.productId,
                'productName': item.productName,
                'quantity': item.quantity,
                'unitPrice': item.unitPrice,
                'purchasePrice': item.purchasePrice,
                'discount': item.discountAmount,
                'unitPriceUsd': item.unitPriceUsd,
                'exchangeRate': item.exchangeRate ?? invoice.exchangeRate,
              })
          .toList();

      final reason = _reasonController.text.isEmpty
          ? 'مرتجع ${widget.type == ReturnType.sales ? "مبيعات" : "مشتريات"} - فاتورة رقم: ${invoice.invoiceNumber}'
          : _reasonController.text;

      await invoiceRepo.createInvoice(
        type: invoiceType,
        customerId: widget.type == ReturnType.sales ? invoice.customerId : null,
        supplierId:
            widget.type == ReturnType.purchase ? invoice.supplierId : null,
        items: itemsData,
        discountAmount: invoice.discountAmount,
        paymentMethod: invoice.paymentMethod,
        notes: reason,
        originalExchangeRate: invoice.exchangeRate,
      );

      if (mounted) {
        ProSnackbar.success(context, 'تم إنشاء المرتجع بنجاح');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'حدث خطأ: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
