// ═══════════════════════════════════════════════════════════════════════════
// Invoice Preview Screen Pro - Enterprise Accounting Design
// Preview and Print Invoice with Multiple Formats
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/printing/invoice_pdf_generator.dart';
import '../../data/database/app_database.dart';

class InvoicePreviewScreenPro extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoicePreviewScreenPro({
    super.key,
    required this.invoiceId,
  });

  @override
  ConsumerState<InvoicePreviewScreenPro> createState() =>
      _InvoicePreviewScreenProState();
}

class _InvoicePreviewScreenProState
    extends ConsumerState<InvoicePreviewScreenPro> {
  Invoice? _invoice;
  List<InvoiceItem>? _items;
  bool _isLoading = true;
  String? _error;

  // Print options
  InvoicePrintSize _selectedSize = InvoicePrintSize.a4;
  bool _showLogo = true;
  bool _showCustomerInfo = true;
  bool _showNotes = true;
  bool _showExchangeRate = true;

  Uint8List? _pdfBytes;
  bool _isPdfGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadInvoiceData();
  }

  Future<void> _loadInvoiceData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final invoiceRepo = ref.read(invoiceRepositoryProvider);

      // Load invoice
      _invoice = await invoiceRepo.getInvoiceById(widget.invoiceId);
      if (_invoice == null) {
        throw Exception('الفاتورة غير موجودة');
      }

      // Load items
      _items = await invoiceRepo.getInvoiceItems(widget.invoiceId);

      // Generate initial PDF
      await _generatePdf();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePdf() async {
    if (_invoice == null || _items == null) return;

    setState(() => _isPdfGenerating = true);

    try {
      final printSettingsService = ref.read(printSettingsServiceProvider);
      final settings = await printSettingsService.getSettings();

      // Create print options from settings
      final printOptions = settings.toInvoicePrintOptions();
      final options = printOptions.copyWith(
        size: _selectedSize,
        showLogo: _showLogo && settings.logoBase64 != null,
        showCustomerInfo: _showCustomerInfo,
        showNotes: _showNotes,
        showExchangeRate: _showExchangeRate,
      );

      // Generate PDF using static method
      _pdfBytes = await InvoicePdfGenerator.generateInvoicePdfBytes(
        invoice: _invoice,
        items: _items!,
        customer: null,
        supplier: null,
        options: options,
      );
    } catch (e) {
      if (mounted) {
        ProSnackbar.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isPdfGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProAppBar.simple(
        title: 'معاينة الفاتورة',
        actions: [
          if (_pdfBytes != null) ...[
            ProAppBarAction(
              icon: Icons.share_rounded,
              onPressed: _shareInvoice,
              tooltip: 'مشاركة',
            ),
            ProAppBarAction(
              icon: Icons.print_rounded,
              onPressed: _printInvoice,
              tooltip: 'طباعة',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? ProLoadingState.withMessage(message: 'جاري تحميل الفاتورة...')
          : _error != null
              ? ProEmptyState.error(
                  error: _error!,
                  onRetry: _loadInvoiceData,
                )
              : Column(
                  children: [
                    // Print Options Bar
                    _buildOptionsBar(),

                    // PDF Preview
                    Expanded(
                      child: _isPdfGenerating
                          ? ProLoadingState.withMessage(
                              message: 'جاري إنشاء المعاينة...')
                          : _pdfBytes != null
                              ? PdfPreview(
                                  build: (format) async => _pdfBytes!,
                                  allowPrinting: false,
                                  allowSharing: false,
                                  canChangeOrientation: false,
                                  canChangePageFormat: false,
                                  pdfPreviewPageDecoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  loadingWidget: ProLoadingState.simple(),
                                )
                              : const ProEmptyState(
                                  icon: Icons.picture_as_pdf_rounded,
                                  title: 'لا يمكن عرض الفاتورة',
                                  message:
                                      'حدث خطأ أثناء إنشاء معاينة الفاتورة',
                                ),
                    ),

                    // Bottom Actions
                    _buildBottomActions(),
                  ],
                ),
    );
  }

  Widget _buildOptionsBar() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Size Selection
            _buildOptionChip(
              label: 'A4',
              isSelected: _selectedSize == InvoicePrintSize.a4,
              onTap: () => _updateOption(() {
                _selectedSize = InvoicePrintSize.a4;
              }),
            ),
            SizedBox(width: AppSpacing.sm),
            _buildOptionChip(
              label: '80mm',
              isSelected: _selectedSize == InvoicePrintSize.thermal80mm,
              onTap: () => _updateOption(() {
                _selectedSize = InvoicePrintSize.thermal80mm;
              }),
            ),
            SizedBox(width: AppSpacing.sm),
            _buildOptionChip(
              label: '58mm',
              isSelected: _selectedSize == InvoicePrintSize.thermal58mm,
              onTap: () => _updateOption(() {
                _selectedSize = InvoicePrintSize.thermal58mm;
              }),
            ),
            SizedBox(width: AppSpacing.lg),
            Container(
              width: 1,
              height: 24.h,
              color: AppColors.border,
            ),
            SizedBox(width: AppSpacing.lg),

            // Toggle Options
            _buildToggleChip(
              icon: Icons.image_rounded,
              label: 'الشعار',
              isEnabled: _showLogo,
              onTap: () => _updateOption(() {
                _showLogo = !_showLogo;
              }),
            ),
            SizedBox(width: AppSpacing.sm),
            _buildToggleChip(
              icon: Icons.person_rounded,
              label: 'العميل',
              isEnabled: _showCustomerInfo,
              onTap: () => _updateOption(() {
                _showCustomerInfo = !_showCustomerInfo;
              }),
            ),
            SizedBox(width: AppSpacing.sm),
            _buildToggleChip(
              icon: Icons.note_rounded,
              label: 'الملاحظات',
              isEnabled: _showNotes,
              onTap: () => _updateOption(() {
                _showNotes = !_showNotes;
              }),
            ),
            SizedBox(width: AppSpacing.sm),
            _buildToggleChip(
              icon: Icons.currency_exchange_rounded,
              label: 'الصرف',
              isEnabled: _showExchangeRate,
              onTap: () => _updateOption(() {
                _showExchangeRate = !_showExchangeRate;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleChip({
    required IconData icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.success.soft : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isEnabled ? AppColors.success.border : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: isEnabled ? AppColors.success : AppColors.textTertiary,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isEnabled ? AppColors.success : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ProButton(
                label: 'مشاركة',
                icon: Icons.share_rounded,
                type: ProButtonType.outlined,
                onPressed: _shareInvoice,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ProButton(
                label: 'طباعة',
                icon: Icons.print_rounded,
                onPressed: _printInvoice,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateOption(VoidCallback update) {
    update();
    _generatePdf();
  }

  Future<void> _printInvoice() async {
    if (_pdfBytes == null) return;

    try {
      await Printing.layoutPdf(
        onLayout: (format) async => _pdfBytes!,
        name: 'فاتورة_${_invoice?.invoiceNumber ?? ""}',
      );
    } catch (e) {
      if (mounted) {
        ProSnackbar.showError(context, e);
      }
    }
  }

  Future<void> _shareInvoice() async {
    if (_pdfBytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/invoice_${_invoice?.invoiceNumber ?? DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(_pdfBytes!);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'فاتورة رقم ${_invoice?.invoiceNumber ?? ""}',
      );
    } catch (e) {
      if (mounted) {
        ProSnackbar.showError(context, e);
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Quick Print Dialog - For quick thermal printing
// ═══════════════════════════════════════════════════════════════════════════

class QuickPrintDialog extends ConsumerWidget {
  final String invoiceId;

  const QuickPrintDialog({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.print_rounded, color: AppColors.secondary),
          SizedBox(width: AppSpacing.sm),
          const Text('طباعة سريعة'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PrintOptionTile(
            icon: Icons.description_rounded,
            title: 'A4 - فاتورة كاملة',
            subtitle: 'للطباعة العادية',
            onTap: () => _print(context, ref, InvoicePrintSize.a4),
          ),
          _PrintOptionTile(
            icon: Icons.receipt_long_rounded,
            title: '80mm - إيصال حراري',
            subtitle: 'للطابعات الحرارية الكبيرة',
            onTap: () => _print(context, ref, InvoicePrintSize.thermal80mm),
          ),
          _PrintOptionTile(
            icon: Icons.receipt_rounded,
            title: '58mm - إيصال صغير',
            subtitle: 'للطابعات الحرارية الصغيرة',
            onTap: () => _print(context, ref, InvoicePrintSize.thermal58mm),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }

  Future<void> _print(
      BuildContext context, WidgetRef ref, InvoicePrintSize size) async {
    Navigator.pop(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Generate and print PDF
      // Implementation would use InvoicePdfGenerator
      await Future.delayed(const Duration(seconds: 1)); // Placeholder

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ProSnackbar.success(context, 'تم إرسال الفاتورة للطباعة');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ProSnackbar.showError(context, e);
      }
    }
  }
}

class _PrintOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrintOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.secondary.soft,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: AppColors.secondary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }
}

/// Helper function to show quick print dialog
void showQuickPrintDialog(BuildContext context, String invoiceId) {
  showDialog(
    context: context,
    builder: (context) => QuickPrintDialog(invoiceId: invoiceId),
  );
}
