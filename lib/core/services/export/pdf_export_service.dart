import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../data/database/app_database.dart' hide Category;
import '../../../data/database/app_database.dart' as db show Category;
import '../printing/pdf_theme.dart';
import 'export_templates.dart';

// Type alias for clarity
typedef DbCategory = db.Category;

/// ═══════════════════════════════════════════════════════════════════════════
/// PDF Export Service - خدمة تصدير PDF الموحدة
/// ═══════════════════════════════════════════════════════════════════════════
class PdfExportService {
  PdfExportService._();

  /// تهيئة الخطوط العربية - يجب استدعاؤها قبل أي عملية تصدير
  static Future<void> _ensureFontsInitialized() async {
    await PdfFonts.init();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير قائمة الفواتير
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateInvoicesList({
    required List<Invoice> invoices,
    String? type,
    Map<String, String>? customerNames,
    Map<String, String>? supplierNames,
    ExportSettings? settings,
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();
    final typeName = type != null
        ? ExportFormatters.getInvoiceTypeLabel(type)
        : 'جميع الفواتير';

    // حساب الإحصائيات - مع القيم المحفوظة بالدولار
    double totalAmount = 0;
    double totalAmountUsd = 0;
    double totalDiscount = 0;
    for (final inv in invoices) {
      totalAmount += inv.total;
      totalAmountUsd += inv.totalUsd ?? 0;
      totalDiscount += inv.discountAmount;
    }

    final template = PdfReportTemplate(
      title: typeName,
      reportDate: now,
      headerColor: type != null
          ? ExportColors.getInvoiceTypeColor(type)
          : ExportColors.primary,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 16),
            ],
          ),
        ),
        footer: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: template.buildFooter(
            pageNumber: context.pageNumber,
            totalPages: context.pagesCount,
          ),
        ),
        build: (context) => [
          // ملخص الإحصائيات - مع القيم بالدولار
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildStatsBox([
              StatItem(label: 'عدد الفواتير', value: '${invoices.length}'),
              StatItem(
                label: 'إجمالي المبلغ',
                value: ExportFormatters.formatDualPriceFromLocked(
                    totalAmount, totalAmountUsd),
                color: ExportColors.success,
              ),
              StatItem(
                label: 'إجمالي الخصومات',
                value: ExportFormatters.formatPrice(totalDiscount),
                color: ExportColors.error,
              ),
            ]),
          ),
          pw.SizedBox(height: 16),

          // جدول الفواتير - مع الطرف والقيم بالدولار
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildTable(
              headers: [
                'الإجمالي (\$)',
                'الإجمالي (ل.س)',
                'الطرف',
                'طريقة الدفع',
                'النوع',
                'التاريخ',
                'رقم الفاتورة',
                '#',
              ],
              data: List.generate(invoices.length, (index) {
                final inv = invoices[index];
                // تحديد اسم الطرف
                String partyName = '-';
                if (inv.customerId != null) {
                  partyName = customerNames?[inv.customerId!] ?? 'عميل';
                } else if (inv.supplierId != null) {
                  partyName = supplierNames?[inv.supplierId!] ?? 'مورد';
                }
                return [
                  // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة
                  inv.totalUsd != null
                      ? '\$${inv.totalUsd!.toStringAsFixed(2)}'
                      : '-',
                  ExportFormatters.formatPrice(inv.total, showCurrency: false),
                  partyName,
                  ExportFormatters.getPaymentMethodLabel(inv.paymentMethod),
                  ExportFormatters.getInvoiceTypeLabel(inv.type),
                  ExportFormatters.formatDateTime(inv.invoiceDate),
                  inv.invoiceNumber,
                  '${index + 1}',
                ];
              }),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير تقرير المبيعات
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateSalesReport({
    required List<Invoice> invoices,
    required Map<String, double> summary,
    required DateTime startDate,
    required DateTime endDate,
    ExportSettings? settings,
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    // حساب الإحصائيات
    final totalSales = summary['totalSales'] ?? 0;
    final invoiceCount = (summary['invoiceCount'] ?? 0).toInt();
    final totalDiscount =
        invoices.fold(0.0, (sum, inv) => sum + inv.discountAmount);

    final template = PdfReportTemplate(
      title: 'تقرير المبيعات',
      subtitle: ExportFormatters.formatDateRange(startDate, endDate),
      reportDate: now,
      headerColor: ExportColors.success,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 16),
            ],
          ),
        ),
        footer: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: template.buildFooter(
            pageNumber: context.pageNumber,
            totalPages: context.pagesCount,
          ),
        ),
        build: (context) => [
          // ملخص الإحصائيات
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildStatsBox([
              StatItem(label: 'عدد الفواتير', value: '$invoiceCount'),
              StatItem(
                label: 'إجمالي المبيعات',
                value: ExportFormatters.formatPrice(totalSales),
                color: ExportColors.success,
              ),
              StatItem(
                label: 'إجمالي الخصومات',
                value: ExportFormatters.formatPrice(totalDiscount),
                color: ExportColors.error,
              ),
            ]),
          ),
          pw.SizedBox(height: 16),

          template.buildSectionDivider('تفاصيل الفواتير'),

          // جدول الفواتير
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildTable(
              headers: [
                'الإجمالي',
                'الخصم',
                'طريقة الدفع',
                'التاريخ',
                'رقم الفاتورة',
                '#',
              ],
              headerBgColor: ExportColors.success,
              data: List.generate(invoices.length, (index) {
                final inv = invoices[index];
                return [
                  ExportFormatters.formatPrice(inv.total, showCurrency: false),
                  ExportFormatters.formatPrice(inv.discountAmount,
                      showCurrency: false),
                  ExportFormatters.getPaymentMethodLabel(inv.paymentMethod),
                  ExportFormatters.formatDateTime(inv.invoiceDate),
                  inv.invoiceNumber,
                  '${index + 1}',
                ];
              }),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير تقرير المخزون
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateInventoryReport({
    required List<Product> products,
    Map<String, int>? soldQuantities,
    ExportSettings? settings,
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    // حساب الإحصائيات
    double totalCostValue = 0;
    double totalSaleValue = 0;
    int totalQuantity = 0;

    for (final p in products) {
      totalCostValue += p.purchasePrice * p.quantity;
      totalSaleValue += p.salePrice * p.quantity;
      totalQuantity += p.quantity;
    }

    final template = PdfReportTemplate(
      title: 'تقرير المخزون',
      reportDate: now,
      headerColor: ExportColors.warning,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 16),
            ],
          ),
        ),
        footer: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: template.buildFooter(
            pageNumber: context.pageNumber,
            totalPages: context.pagesCount,
          ),
        ),
        build: (context) => [
          // ملخص الإحصائيات
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildStatsBox([
              StatItem(label: 'عدد المنتجات', value: '${products.length}'),
              StatItem(label: 'إجمالي الكميات', value: '$totalQuantity'),
              StatItem(
                label: 'قيمة المخزون',
                value: ExportFormatters.formatPrice(totalCostValue),
                color: ExportColors.primary,
              ),
            ]),
          ),
          pw.SizedBox(height: 8),

          // صندوق الربح المتوقع
          ExportTheme.highlightBox(
            label: 'الربح المتوقع:',
            value:
                ExportFormatters.formatPrice(totalSaleValue - totalCostValue),
            bgColor: AppPdfColors.bgGreen,
            textColor: AppPdfColors.success,
          ),
          pw.SizedBox(height: 16),

          template.buildSectionDivider('تفاصيل المنتجات'),

          // جدول المنتجات
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildTable(
              headers: [
                'القيمة',
                'سعر البيع',
                'سعر الشراء',
                'الكمية',
                'اسم المنتج',
                '#',
              ],
              headerBgColor: ExportColors.warning,
              data: List.generate(products.length, (index) {
                final p = products[index];
                final value = p.quantity * p.purchasePrice;
                return [
                  ExportFormatters.formatPrice(value, showCurrency: false),
                  ExportFormatters.formatPrice(p.salePrice,
                      showCurrency: false),
                  ExportFormatters.formatPrice(p.purchasePrice,
                      showCurrency: false),
                  '${p.quantity}',
                  p.name,
                  '${index + 1}',
                ];
              }),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير قائمة المنتجات
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateProductsList({
    required List<Product> products,
    Map<String, int>? soldQuantities,
    ExportSettings? settings,
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();

    // حساب الإحصائيات
    double totalCostValue = 0;
    int totalQuantity = 0;

    for (final p in products) {
      totalCostValue += p.purchasePrice * p.quantity;
      totalQuantity += p.quantity;
    }

    final template = PdfReportTemplate(
      title: 'قائمة المنتجات',
      reportDate: now,
      headerColor: ExportColors.primary,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 16),
            ],
          ),
        ),
        footer: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: template.buildFooter(
            pageNumber: context.pageNumber,
            totalPages: context.pagesCount,
          ),
        ),
        build: (context) => [
          // ملخص الإحصائيات
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildStatsBox([
              StatItem(label: 'عدد المنتجات', value: '${products.length}'),
              StatItem(label: 'إجمالي الكميات', value: '$totalQuantity'),
              StatItem(
                label: 'قيمة المخزون',
                value: ExportFormatters.formatPrice(totalCostValue),
              ),
            ]),
          ),
          pw.SizedBox(height: 16),

          // جدول المنتجات
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildTable(
              headers: [
                'سعر البيع',
                'سعر الشراء',
                'الكمية',
                'اسم المنتج',
                '#',
              ],
              data: List.generate(products.length, (index) {
                final p = products[index];
                return [
                  ExportFormatters.formatPrice(p.salePrice,
                      showCurrency: false),
                  ExportFormatters.formatPrice(p.purchasePrice,
                      showCurrency: false),
                  '${p.quantity}',
                  p.name,
                  '${index + 1}',
                ];
              }),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // دوال مساعدة
  // ═══════════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير قائمة السندات
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateVouchersList({
    required List<Voucher> vouchers,
    String? type,
    Map<String, String>? customerNames,
    Map<String, String>? supplierNames,
    ExportSettings? settings,
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final typeName = type != null ? _getVoucherTypeLabel(type) : 'جميع السندات';

    // حساب الإحصائيات
    double totalAmount = 0;
    for (final voucher in vouchers) {
      totalAmount += voucher.amount;
    }

    final template = PdfReportTemplate(
      title: typeName,
      reportDate: now,
      headerColor:
          type != null ? _getVoucherTypeColor(type) : ExportColors.primary,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 16),
            ],
          ),
        ),
        footer: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: template.buildFooter(
            pageNumber: context.pageNumber,
            totalPages: context.pagesCount,
          ),
        ),
        build: (context) => [
          // ملخص الإحصائيات
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildStatsBox([
              StatItem(label: 'عدد السندات', value: '${vouchers.length}'),
              StatItem(
                label: 'إجمالي المبلغ',
                value: ExportFormatters.formatPrice(totalAmount),
                color: ExportColors.success,
              ),
              StatItem(
                label: 'المتوسط',
                value: ExportFormatters.formatPrice(
                    vouchers.isNotEmpty ? totalAmount / vouchers.length : 0),
              ),
            ]),
          ),
          pw.SizedBox(height: 16),

          // جدول السندات - مع إضافة الطرف وسعر الصرف
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildTable(
              headers: [
                'المبلغ (\$)',
                'المبلغ (ل.س)',
                'الطرف',
                'الوصف',
                'النوع',
                'التاريخ',
                'رقم السند',
                '#',
              ],
              data: List.generate(vouchers.length, (index) {
                final voucher = vouchers[index];
                // تحديد اسم الطرف
                String partyName = '-';
                if (voucher.customerId != null) {
                  partyName = customerNames?[voucher.customerId!] ?? 'عميل';
                } else if (voucher.supplierId != null) {
                  partyName = supplierNames?[voucher.supplierId!] ?? 'مورد';
                }
                return [
                  // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة
                  voucher.amountUsd != null
                      ? '\$${voucher.amountUsd!.toStringAsFixed(2)}'
                      : '-',
                  ExportFormatters.formatPrice(voucher.amount,
                      showCurrency: false),
                  partyName,
                  voucher.description ?? '-',
                  _getVoucherTypeLabel(voucher.type),
                  ExportFormatters.formatDateTime(voucher.voucherDate),
                  voucher.voucherNumber,
                  '${index + 1}',
                ];
              }),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static String _getVoucherTypeLabel(String type) {
    switch (type) {
      case 'receipt':
        return 'سند قبض';
      case 'payment':
        return 'سند دفع';
      case 'expense':
        return 'مصاريف';
      default:
        return type;
    }
  }

  static PdfColor _getVoucherTypeColor(String type) {
    switch (type) {
      case 'receipt':
        return ExportColors.success;
      case 'payment':
        return ExportColors.primary;
      case 'expense':
        return ExportColors.warning;
      default:
        return ExportColors.primary;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير قائمة التصنيفات
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateCategoriesList({
    required List<DbCategory> categories,
    ExportSettings? settings,
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    final template = PdfReportTemplate(
      title: 'قائمة التصنيفات',
      reportDate: now,
      headerColor: ExportColors.primary,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 16),
            ],
          ),
        ),
        footer: (context) => template.buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // إحصائيات
                ExportTheme.infoBox(
                  title: 'عدد التصنيفات: ${categories.length}',
                  subtitle: '',
                  trailing:
                      'تاريخ التصدير: ${ExportFormatters.formatDate(now)}',
                ),
                pw.SizedBox(height: 16),

                // الجدول
                ExportTheme.tableHelper(
                  headers: ['#', 'الاسم', 'الوصف', 'تاريخ الإنشاء'],
                  headerColor: ExportTheme.headerPrimary,
                  data: categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    return [
                      (index + 1).toString(),
                      category.name,
                      category.description ?? '-',
                      ExportFormatters.formatDate(category.createdAt),
                    ];
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  /// حفظ PDF كملف
  static Future<String> savePdfFile(Uint8List bytes, String fileName) async {
    final timestamp =
        '${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}_${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}';

    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final filePath = '${exportDir.path}/${fileName}_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    debugPrint('PDF file saved: $filePath');
    return filePath;
  }

  /// مشاركة ملف PDF
  static Future<void> shareFile(String filePath, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject ?? 'تقرير PDF',
    );
  }

  /// مشاركة PDF مباشرة من bytes
  static Future<void> sharePdfBytes(
    Uint8List bytes, {
    required String fileName,
    String? subject,
  }) async {
    final filePath = await savePdfFile(bytes, fileName);
    await shareFile(filePath, subject: subject);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير حركات الصندوق
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateCashMovementsList({
    required List<CashMovement> movements,
    ExportSettings? settings,
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    // حساب الإحصائيات - مع USD
    double totalIncome = 0;
    double totalIncomeUsd = 0;
    double totalExpense = 0;
    double totalExpenseUsd = 0;
    for (final m in movements) {
      final isIncome = m.type == 'income' ||
          m.type == 'sale' ||
          m.type == 'deposit' ||
          m.type == 'opening';
      if (isIncome) {
        totalIncome += m.amount;
        totalIncomeUsd += m.amountUsd ?? 0;
      } else {
        totalExpense += m.amount;
        totalExpenseUsd += m.amountUsd ?? 0;
      }
    }

    final template = PdfReportTemplate(
      title: 'حركات الصندوق',
      reportDate: now,
      headerColor: ExportColors.primary,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 16),
            ],
          ),
        ),
        footer: (context) => template.buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // إحصائيات - مع USD
                CashMovementTheme.summaryBox(
                  movementCount: 'عدد الحركات: ${movements.length}',
                  netValue:
                      'الصافي: ${ExportFormatters.formatDualPriceFromLocked(totalIncome - totalExpense, totalIncomeUsd - totalExpenseUsd)}',
                  isPositive: totalIncome >= totalExpense,
                  incomeValue:
                      'الإيرادات: ${ExportFormatters.formatDualPriceFromLocked(totalIncome, totalIncomeUsd)}',
                  expenseValue:
                      'المصروفات: ${ExportFormatters.formatDualPriceFromLocked(totalExpense, totalExpenseUsd)}',
                ),
                pw.SizedBox(height: 16),

                // الجدول - مع USD
                ExportTheme.tableHelper(
                  headers: [
                    '#',
                    'التاريخ',
                    'الوصف',
                    'النوع',
                    'المبلغ (ل.س)',
                    'المبلغ (\$)'
                  ],
                  headerColor: ExportTheme.headerPrimary,
                  data: movements.asMap().entries.map((entry) {
                    final index = entry.key;
                    final movement = entry.value;
                    final isIncome = movement.type == 'income' ||
                        movement.type == 'sale' ||
                        movement.type == 'deposit' ||
                        movement.type == 'opening';
                    return [
                      (index + 1).toString(),
                      ExportFormatters.formatDateTime(movement.createdAt),
                      movement.description,
                      isIncome ? 'إيراد' : 'مصروف',
                      '${isIncome ? '+' : '-'}${ExportFormatters.formatPrice(movement.amount, showCurrency: false)}',
                      // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة
                      movement.amountUsd != null
                          ? '${isIncome ? '+' : '-'}\$${movement.amountUsd!.toStringAsFixed(2)}'
                          : '-',
                    ];
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // قائمة الورديات
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateShiftsList({
    required List<Shift> shifts,
    ExportSettings? settings,
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    // حساب الإحصائيات - مع USD
    double totalSales = 0;
    double totalSalesUsd = 0;
    double totalExpenses = 0;
    double totalExpensesUsd = 0;
    for (final s in shifts) {
      totalSales += s.totalSales;
      totalSalesUsd += s.totalSalesUsd;
      totalExpenses += s.totalExpenses;
      totalExpensesUsd += s.totalExpensesUsd;
    }

    final template = PdfReportTemplate(
      title: 'قائمة الورديات',
      reportDate: now,
      headerColor: ExportColors.primary,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 16),
            ],
          ),
        ),
        footer: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: template.buildFooter(
            pageNumber: context.pageNumber,
            totalPages: context.pagesCount,
          ),
        ),
        build: (context) => [
          // ملخص الإحصائيات - مع USD
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildStatsBox([
              StatItem(label: 'عدد الورديات', value: '${shifts.length}'),
              StatItem(
                label: 'إجمالي المبيعات',
                value: ExportFormatters.formatDualPriceFromLocked(
                    totalSales, totalSalesUsd),
                color: ExportColors.success,
              ),
              StatItem(
                label: 'إجمالي المصاريف',
                value: ExportFormatters.formatDualPriceFromLocked(
                    totalExpenses, totalExpensesUsd),
                color: ExportColors.error,
              ),
              StatItem(
                label: 'الصافي',
                value: ExportFormatters.formatDualPriceFromLocked(
                    totalSales - totalExpenses,
                    totalSalesUsd - totalExpensesUsd),
                color: totalSales >= totalExpenses
                    ? ExportColors.success
                    : ExportColors.error,
              ),
            ]),
          ),
          pw.SizedBox(height: 16),

          // جدول الورديات - مع USD
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildTable(
              headers: [
                'المبيعات (\$)',
                'المبيعات (ل.س)',
                'التاريخ',
                'رقم الوردية',
                '#',
              ],
              data: List.generate(shifts.length, (index) {
                final shift = shifts[index];
                return [
                  // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة
                  '\$${shift.totalSalesUsd.toStringAsFixed(2)}',
                  ExportFormatters.formatPrice(shift.totalSales,
                      showCurrency: false),
                  ExportFormatters.formatDateTime(shift.openedAt),
                  '#${shift.shiftNumber}',
                  '${index + 1}',
                ];
              }),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // كشف حساب العميل PDF
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateCustomerStatement({
    required Customer customer,
    required List<Invoice> invoices,
    required List<Voucher> vouchers,
    ExportSettings? settings,
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    // دمج وترتيب البيانات
    final List<Map<String, dynamic>> entries = [];

    // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة (SYP + USD) بدون تحويل
    for (final invoice in invoices) {
      entries.add({
        'date': invoice.createdAt,
        'description': 'فاتورة بيع #${invoice.invoiceNumber}',
        'debit': invoice.total,
        'debitUsd': invoice.totalUsd ?? 0.0,
        'credit': 0.0,
        'creditUsd': 0.0,
      });
    }

    for (final voucher in vouchers) {
      entries.add({
        'date': voucher.voucherDate,
        'description': 'سند قبض #${voucher.voucherNumber}',
        'debit': 0.0,
        'debitUsd': 0.0,
        'credit': voucher.amount,
        'creditUsd': voucher.amountUsd ?? 0.0,
      });
    }

    entries.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // حساب الرصيد التراكمي (بالليرة والدولار)
    double runningBalance = 0;
    double runningBalanceUsd = 0;
    for (final entry in entries) {
      runningBalance +=
          (entry['debit'] as double) - (entry['credit'] as double);
      runningBalanceUsd +=
          (entry['debitUsd'] as double) - (entry['creditUsd'] as double);
      entry['balance'] = runningBalance;
      entry['balanceUsd'] = runningBalanceUsd;
    }

    // حساب الإجماليات (بالليرة والدولار)
    final totalDebit =
        entries.fold(0.0, (sum, e) => sum + (e['debit'] as double));
    final totalDebitUsd =
        entries.fold(0.0, (sum, e) => sum + (e['debitUsd'] as double));
    final totalCredit =
        entries.fold(0.0, (sum, e) => sum + (e['credit'] as double));
    final totalCreditUsd =
        entries.fold(0.0, (sum, e) => sum + (e['creditUsd'] as double));

    final template = PdfReportTemplate(
      title: 'كشف حساب العميل',
      subtitle: customer.name,
      reportDate: now,
      headerColor: ExportColors.primary,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 8),
              // معلومات العميل
              StatementTheme.partyInfoBox(
                phone: 'الهاتف: ${customer.phone ?? "غير محدد"}',
                balance:
                    'الرصيد الحالي: ${customer.balance.toStringAsFixed(0)} ل.س${customer.balanceUsd != null && customer.balanceUsd != 0 ? " (\$${customer.balanceUsd!.toStringAsFixed(2)})" : ""}',
                isPositive: customer.balance > 0,
              ),
              pw.SizedBox(height: 12),
            ],
          ),
        ),
        footer: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: template.buildFooter(
            pageNumber: context.pageNumber,
            totalPages: context.pagesCount,
          ),
        ),
        build: (context) => [
          if (entries.isEmpty)
            StatementTheme.emptyMessage()
          else ...[
            // جدول كشف الحساب - مع قيم USD
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: template.buildTable(
                headers: [
                  'الرصيد (\$)',
                  'الرصيد (ل.س)',
                  'دائن',
                  'مدين',
                  'البيان',
                  'التاريخ',
                  '#'
                ],
                data: List.generate(entries.length, (index) {
                  final entry = entries[index];
                  final debit = entry['debit'] as double;
                  final debitUsd = entry['debitUsd'] as double;
                  final credit = entry['credit'] as double;
                  final creditUsd = entry['creditUsd'] as double;
                  return [
                    '\$${(entry['balanceUsd'] as double).toStringAsFixed(2)}',
                    (entry['balance'] as double).toStringAsFixed(0),
                    credit > 0
                        ? '${credit.toStringAsFixed(0)}${creditUsd > 0 ? ' (\$${creditUsd.toStringAsFixed(2)})' : ''}'
                        : '-',
                    debit > 0
                        ? '${debit.toStringAsFixed(0)}${debitUsd > 0 ? ' (\$${debitUsd.toStringAsFixed(2)})' : ''}'
                        : '-',
                    entry['description'] as String,
                    ExportFormatters.formatDate(entry['date'] as DateTime),
                    '${index + 1}',
                  ];
                }),
              ),
            ),
            pw.SizedBox(height: 16),
            // صف الإجماليات - مع قيم USD
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: StatementTheme.totalsBox(
                totalDebit:
                    'إجمالي المدين: ${totalDebit.toStringAsFixed(0)} ل.س (\$${totalDebitUsd.toStringAsFixed(2)})',
                totalCredit:
                    'إجمالي الدائن: ${totalCredit.toStringAsFixed(0)} ل.س (\$${totalCreditUsd.toStringAsFixed(2)})',
                finalBalance:
                    'الرصيد النهائي: ${(totalDebit - totalCredit).toStringAsFixed(0)} ل.س (\$${(totalDebitUsd - totalCreditUsd).toStringAsFixed(2)})',
              ),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // كشف حساب المورد PDF
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateSupplierStatement({
    required Supplier supplier,
    required List<Invoice> invoices,
    required List<Voucher> vouchers,
    ExportSettings? settings,
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    // دمج وترتيب البيانات
    final List<Map<String, dynamic>> entries = [];

    // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة (SYP + USD) بدون تحويل
    for (final invoice in invoices) {
      entries.add({
        'date': invoice.createdAt,
        'description': 'فاتورة مشتريات #${invoice.invoiceNumber}',
        'debit': invoice.total,
        'debitUsd': invoice.totalUsd ?? 0.0,
        'credit': 0.0,
        'creditUsd': 0.0,
      });
    }

    for (final voucher in vouchers) {
      entries.add({
        'date': voucher.voucherDate,
        'description': 'سند صرف #${voucher.voucherNumber}',
        'debit': 0.0,
        'debitUsd': 0.0,
        'credit': voucher.amount,
        'creditUsd': voucher.amountUsd ?? 0.0,
      });
    }

    entries.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // حساب الرصيد التراكمي (بالليرة والدولار)
    double runningBalance = 0;
    double runningBalanceUsd = 0;
    for (final entry in entries) {
      runningBalance +=
          (entry['debit'] as double) - (entry['credit'] as double);
      runningBalanceUsd +=
          (entry['debitUsd'] as double) - (entry['creditUsd'] as double);
      entry['balance'] = runningBalance;
      entry['balanceUsd'] = runningBalanceUsd;
    }

    // حساب الإجماليات (بالليرة والدولار)
    final totalDebit =
        entries.fold(0.0, (sum, e) => sum + (e['debit'] as double));
    final totalDebitUsd =
        entries.fold(0.0, (sum, e) => sum + (e['debitUsd'] as double));
    final totalCredit =
        entries.fold(0.0, (sum, e) => sum + (e['credit'] as double));
    final totalCreditUsd =
        entries.fold(0.0, (sum, e) => sum + (e['creditUsd'] as double));

    final template = PdfReportTemplate(
      title: 'كشف حساب المورد',
      subtitle: supplier.name,
      reportDate: now,
      headerColor: ExportColors.purchase,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 8),
              // معلومات المورد
              StatementTheme.partyInfoBox(
                phone: 'الهاتف: ${supplier.phone ?? "غير محدد"}',
                balance:
                    'الرصيد الحالي: ${supplier.balance.toStringAsFixed(0)} ل.س${supplier.balanceUsd != null && supplier.balanceUsd != 0 ? " (\$${supplier.balanceUsd!.toStringAsFixed(2)})" : ""}',
                isPositive: supplier.balance > 0,
              ),
              pw.SizedBox(height: 12),
            ],
          ),
        ),
        footer: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: template.buildFooter(
            pageNumber: context.pageNumber,
            totalPages: context.pagesCount,
          ),
        ),
        build: (context) => [
          if (entries.isEmpty)
            StatementTheme.emptyMessage()
          else ...[
            // جدول كشف الحساب
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: template.buildTable(
                headers: [
                  'الرصيد \$',
                  'الرصيد ل.س',
                  'دائن \$',
                  'دائن ل.س',
                  'مدين \$',
                  'مدين ل.س',
                  'البيان',
                  'التاريخ',
                  '#'
                ],
                headerBgColor: ExportColors.purchase,
                data: List.generate(entries.length, (index) {
                  final entry = entries[index];
                  return [
                    (entry['balanceUsd'] as double).toStringAsFixed(2),
                    (entry['balance'] as double).toStringAsFixed(0),
                    (entry['creditUsd'] as double) > 0
                        ? (entry['creditUsd'] as double).toStringAsFixed(2)
                        : '-',
                    (entry['credit'] as double) > 0
                        ? (entry['credit'] as double).toStringAsFixed(0)
                        : '-',
                    (entry['debitUsd'] as double) > 0
                        ? (entry['debitUsd'] as double).toStringAsFixed(2)
                        : '-',
                    (entry['debit'] as double) > 0
                        ? (entry['debit'] as double).toStringAsFixed(0)
                        : '-',
                    entry['description'] as String,
                    ExportFormatters.formatDate(entry['date'] as DateTime),
                    '${index + 1}',
                  ];
                }),
              ),
            ),
            pw.SizedBox(height: 16),
            // صف الإجماليات
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: StatementTheme.totalsBox(
                totalDebit:
                    'إجمالي المدين: ${totalDebit.toStringAsFixed(0)} ل.س (\$${totalDebitUsd.toStringAsFixed(2)})',
                totalCredit:
                    'إجمالي الدائن: ${totalCredit.toStringAsFixed(0)} ل.س (\$${totalCreditUsd.toStringAsFixed(2)})',
                finalBalance:
                    'الرصيد: ${(totalDebit - totalCredit).toStringAsFixed(0)} ل.س (\$${(totalDebitUsd - totalCreditUsd).toStringAsFixed(2)})',
              ),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تقرير Z (تقرير إغلاق الوردية)
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateZReport({
    required Shift shift,
    List<Invoice>? invoices,
    List<CashMovement>? cashMovements,
    ExportSettings? settings,
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    // حساب صافي النقدية
    final netCash =
        shift.openingBalance + shift.totalSales - shift.totalExpenses;

    // تصنيف الفواتير حسب النوع
    int salesCount = 0;
    int purchasesCount = 0;
    int returnsCount = 0;
    double cashSales = 0;
    double creditSales = 0;

    if (invoices != null) {
      for (final inv in invoices) {
        if (inv.type == 'sale') {
          salesCount++;
          if (inv.paymentMethod == 'cash') {
            cashSales += inv.total;
          } else {
            creditSales += inv.total;
          }
        } else if (inv.type == 'purchase') {
          purchasesCount++;
        } else if (inv.type == 'return') {
          returnsCount++;
        }
      }
    }

    final template = PdfReportTemplate(
      title: 'تقرير Z - إغلاق الوردية',
      subtitle: '#${shift.shiftNumber}',
      reportDate: now,
      headerColor: ExportColors.primary,
      settings: settings,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              template.buildHeader(),
              pw.SizedBox(height: 16),
            ],
          ),
        ),
        footer: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: template.buildFooter(
            pageNumber: context.pageNumber,
            totalPages: context.pagesCount,
          ),
        ),
        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // معلومات الوردية
                ZReportTheme.shiftInfoBox([
                  ZReportRow(
                      label: 'رقم الوردية', value: '#${shift.shiftNumber}'),
                  ZReportRow(
                      label: 'تاريخ الافتتاح',
                      value: ExportFormatters.formatDateTime(shift.openedAt)),
                  ZReportRow(
                      label: 'تاريخ الإغلاق',
                      value: shift.closedAt != null
                          ? ExportFormatters.formatDateTime(shift.closedAt!)
                          : 'لم تغلق بعد'),
                  ZReportRow(
                      label: 'الحالة',
                      value: shift.status == 'open' ? 'مفتوحة' : 'مغلقة'),
                ]),
                pw.SizedBox(height: 20),

                // ملخص المبيعات
                ZReportTheme.salesBox(
                  title: 'ملخص المبيعات',
                  rows: [
                    ZReportRow(
                        label: 'عدد فواتير البيع', value: '$salesCount فاتورة'),
                    ZReportRow(
                        label: 'مبيعات نقدية',
                        value: '${cashSales.toStringAsFixed(0)} ل.س'),
                    ZReportRow(
                        label: 'مبيعات آجلة',
                        value: '${creditSales.toStringAsFixed(0)} ل.س'),
                  ],
                  total: ZReportRow(
                    label: 'إجمالي المبيعات',
                    value:
                        '${shift.totalSales.toStringAsFixed(0)} ل.س${shift.totalSalesUsd > 0 ? " (\$${shift.totalSalesUsd.toStringAsFixed(2)})" : ""}',
                    isBold: true,
                  ),
                ),
                pw.SizedBox(height: 16),

                // المصروفات
                ZReportTheme.expenseBox(
                  title: 'المصروفات',
                  rows: [
                    ZReportRow(
                        label: 'عدد فواتير الشراء',
                        value: '$purchasesCount فاتورة'),
                    ZReportRow(
                        label: 'عدد المرتجعات', value: '$returnsCount فاتورة'),
                  ],
                  total: ZReportRow(
                    label: 'إجمالي المصروفات',
                    value:
                        '${shift.totalExpenses.toStringAsFixed(0)} ل.س${shift.totalExpensesUsd > 0 ? " (\$${shift.totalExpensesUsd.toStringAsFixed(2)})" : ""}',
                    isBold: true,
                  ),
                ),
                pw.SizedBox(height: 20),

                // ملخص النقدية
                ZReportTheme.cashBox(
                  title: 'ملخص النقدية',
                  rows: [
                    ZReportRow(
                        label: 'الرصيد الافتتاحي',
                        value:
                            '${shift.openingBalance.toStringAsFixed(0)} ل.س${(shift.openingBalanceUsd ?? 0) > 0 ? " (\$${shift.openingBalanceUsd!.toStringAsFixed(2)})" : ""}'),
                    ZReportRow(
                        label: '+ المبيعات النقدية',
                        value:
                            '${shift.totalSales.toStringAsFixed(0)} ل.س${shift.totalSalesUsd > 0 ? " (\$${shift.totalSalesUsd.toStringAsFixed(2)})" : ""}',
                        color: AppPdfColors.success),
                    ZReportRow(
                        label: '- المصروفات',
                        value:
                            '${shift.totalExpenses.toStringAsFixed(0)} ل.س${shift.totalExpensesUsd > 0 ? " (\$${shift.totalExpensesUsd.toStringAsFixed(2)})" : ""}',
                        color: AppPdfColors.error),
                  ],
                  total: ZReportRow(
                    label: '= صافي النقدية المتوقع',
                    value:
                        '${netCash.toStringAsFixed(0)} ل.س${_calculateNetCashUsd(shift) != null ? " (\$${_calculateNetCashUsd(shift)!.toStringAsFixed(2)})" : ""}',
                    isBold: true,
                  ),
                ),
                pw.SizedBox(height: 20),

                // التوقيع
                ZReportTheme.signaturesSection(),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  /// حساب صافي النقدية بالدولار
  static double? _calculateNetCashUsd(Shift shift) {
    final openingUsd = shift.openingBalanceUsd ?? 0.0;
    final salesUsd = shift.totalSalesUsd;
    final expensesUsd = shift.totalExpensesUsd;

    // إذا كانت جميع القيم صفر، نرجع null
    if (openingUsd == 0 && salesUsd == 0 && expensesUsd == 0) {
      return null;
    }

    return openingUsd + salesUsd - expensesUsd;
  }
}
