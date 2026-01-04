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
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();
    final typeName = type != null
        ? ExportFormatters.getInvoiceTypeLabel(type)
        : 'جميع الفواتير';

    // حساب الإحصائيات
    double totalAmount = 0;
    double totalDiscount = 0;
    for (final inv in invoices) {
      totalAmount += inv.total;
      totalDiscount += inv.discountAmount;
    }

    final template = PdfReportTemplate(
      title: typeName,
      reportDate: now,
      headerColor: type != null
          ? ExportColors.getInvoiceTypeColor(type)
          : ExportColors.primary,
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
              StatItem(label: 'عدد الفواتير', value: '${invoices.length}'),
              StatItem(
                label: 'إجمالي المبلغ',
                value: ExportFormatters.formatPrice(totalAmount),
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

          // جدول الفواتير
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildTable(
              headers: [
                'الإجمالي',
                'الخصم',
                'طريقة الدفع',
                'النوع',
                'التاريخ',
                'رقم الفاتورة',
                '#',
              ],
              data: List.generate(invoices.length, (index) {
                final inv = invoices[index];
                return [
                  ExportFormatters.formatPrice(inv.total, showCurrency: false),
                  ExportFormatters.formatPrice(inv.discountAmount,
                      showCurrency: false),
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
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: ExportColors.success),
            ),
            child: pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'الربح المتوقع:',
                    style: pw.TextStyle(
                      font: PdfFonts.bold,
                      fontSize: 12,
                      color: ExportColors.success,
                    ),
                  ),
                  pw.Text(
                    ExportFormatters.formatPrice(
                        totalSaleValue - totalCostValue),
                    style: pw.TextStyle(
                      font: PdfFonts.bold,
                      fontSize: 14,
                      color: ExportColors.success,
                    ),
                  ),
                ],
              ),
            ),
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

          // جدول السندات
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildTable(
              headers: [
                'المبلغ',
                'الوصف',
                'النوع',
                'التاريخ',
                'رقم السند',
                '#',
              ],
              data: List.generate(vouchers.length, (index) {
                final voucher = vouchers[index];
                return [
                  ExportFormatters.formatPrice(voucher.amount,
                      showCurrency: false),
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
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    final template = PdfReportTemplate(
      title: 'قائمة التصنيفات',
      reportDate: now,
      headerColor: ExportColors.primary,
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
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'عدد التصنيفات: ${categories.length}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.Text(
                        'تاريخ التصدير: ${ExportFormatters.formatDate(now)}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // الجدول
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#2196F3'),
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(8),
                      topRight: pw.Radius.circular(8),
                    ),
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellPadding: const pw.EdgeInsets.all(8),
                  cellAlignments: {
                    0: pw.Alignment.center,
                    1: pw.Alignment.centerRight,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.center,
                  },
                  headers: ['#', 'الاسم', 'الوصف', 'تاريخ الإنشاء'],
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
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    // حساب الإحصائيات
    double totalIncome = 0;
    double totalExpense = 0;
    for (final m in movements) {
      final isIncome = m.type == 'income' ||
          m.type == 'sale' ||
          m.type == 'deposit' ||
          m.type == 'opening';
      if (isIncome) {
        totalIncome += m.amount;
      } else {
        totalExpense += m.amount;
      }
    }

    final template = PdfReportTemplate(
      title: 'حركات الصندوق',
      reportDate: now,
      headerColor: ExportColors.primary,
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
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'عدد الحركات: ${movements.length}',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'الصافي: ${(totalIncome - totalExpense).toStringAsFixed(2)} ل.س',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                              color: totalIncome >= totalExpense
                                  ? PdfColors.green
                                  : PdfColors.red,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'الإيرادات: ${totalIncome.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              color: PdfColors.green,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'المصروفات: ${totalExpense.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              color: PdfColors.red,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // الجدول
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#2196F3'),
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(8),
                      topRight: pw.Radius.circular(8),
                    ),
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellPadding: const pw.EdgeInsets.all(8),
                  cellAlignments: {
                    0: pw.Alignment.center,
                    1: pw.Alignment.center,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.center,
                    4: pw.Alignment.center,
                  },
                  headers: ['#', 'التاريخ', 'الوصف', 'النوع', 'المبلغ'],
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
                      '${isIncome ? '+' : '-'}${movement.amount.toStringAsFixed(0)}',
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
  }) async {
    await _ensureFontsInitialized();

    final doc = pw.Document();
    final now = DateTime.now();

    // حساب الإحصائيات
    double totalSales = 0;
    double totalExpenses = 0;
    for (final s in shifts) {
      totalSales += s.totalSales;
      totalExpenses += s.totalExpenses;
    }

    final template = PdfReportTemplate(
      title: 'قائمة الورديات',
      reportDate: now,
      headerColor: ExportColors.primary,
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
              StatItem(label: 'عدد الورديات', value: '${shifts.length}'),
              StatItem(
                label: 'إجمالي المبيعات',
                value: ExportFormatters.formatPrice(totalSales),
                color: ExportColors.success,
              ),
              StatItem(
                label: 'إجمالي المصاريف',
                value: ExportFormatters.formatPrice(totalExpenses),
                color: ExportColors.error,
              ),
              StatItem(
                label: 'الصافي',
                value: ExportFormatters.formatPrice(totalSales - totalExpenses),
                color: totalSales >= totalExpenses
                    ? ExportColors.success
                    : ExportColors.error,
              ),
            ]),
          ),
          pw.SizedBox(height: 16),

          // جدول الورديات
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: template.buildTable(
              headers: [
                '#',
                'رقم الوردية',
                'التاريخ',
                'المبيعات',
                'المصاريف',
                'الحالة',
              ],
              data: List.generate(shifts.length, (index) {
                final shift = shifts[index];
                return [
                  '${index + 1}',
                  '#${shift.shiftNumber}',
                  ExportFormatters.formatDateTime(shift.openedAt),
                  ExportFormatters.formatPrice(shift.totalSales,
                      showCurrency: false),
                  ExportFormatters.formatPrice(shift.totalExpenses,
                      showCurrency: false),
                  shift.status == 'open' ? 'مفتوحة' : 'مغلقة',
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
  // تقرير Z (تقرير إغلاق الوردية)
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateZReport({
    required Shift shift,
    List<Invoice>? invoices,
    List<CashMovement>? cashMovements,
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
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    children: [
                      _buildZReportRow('رقم الوردية', '#${shift.shiftNumber}'),
                      pw.Divider(color: PdfColors.grey200),
                      _buildZReportRow('تاريخ الافتتاح',
                          ExportFormatters.formatDateTime(shift.openedAt)),
                      pw.Divider(color: PdfColors.grey200),
                      _buildZReportRow(
                          'تاريخ الإغلاق',
                          shift.closedAt != null
                              ? ExportFormatters.formatDateTime(shift.closedAt!)
                              : 'لم تغلق بعد'),
                      pw.Divider(color: PdfColors.grey200),
                      _buildZReportRow('الحالة',
                          shift.status == 'open' ? 'مفتوحة' : 'مغلقة'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // ملخص المبيعات
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E8F5E9'),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ملخص المبيعات',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#2E7D32'),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      _buildZReportRow(
                          'عدد فواتير البيع', '$salesCount فاتورة'),
                      _buildZReportRow('مبيعات نقدية',
                          '${cashSales.toStringAsFixed(2)} ل.س'),
                      _buildZReportRow('مبيعات آجلة',
                          '${creditSales.toStringAsFixed(2)} ل.س'),
                      pw.Divider(color: PdfColors.green200),
                      _buildZReportRow('إجمالي المبيعات',
                          '${shift.totalSales.toStringAsFixed(2)} ل.س',
                          isBold: true),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // المصروفات
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFEBEE'),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'المصروفات',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#C62828'),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      _buildZReportRow(
                          'عدد فواتير الشراء', '$purchasesCount فاتورة'),
                      _buildZReportRow('عدد المرتجعات', '$returnsCount فاتورة'),
                      pw.Divider(color: PdfColors.red200),
                      _buildZReportRow('إجمالي المصروفات',
                          '${shift.totalExpenses.toStringAsFixed(2)} ل.س',
                          isBold: true),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // ملخص النقدية
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E3F2FD'),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ملخص النقدية',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1565C0'),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      _buildZReportRow('الرصيد الافتتاحي',
                          '${shift.openingBalance.toStringAsFixed(2)} ل.س'),
                      _buildZReportRow('+ المبيعات النقدية',
                          '${shift.totalSales.toStringAsFixed(2)} ل.س',
                          color: PdfColors.green),
                      _buildZReportRow('- المصروفات',
                          '${shift.totalExpenses.toStringAsFixed(2)} ل.س',
                          color: PdfColors.red),
                      pw.Divider(color: PdfColors.blue200, thickness: 2),
                      _buildZReportRow('= صافي النقدية المتوقع',
                          '${netCash.toStringAsFixed(2)} ل.س',
                          isBold: true, fontSize: 14),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // التوقيع
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text('توقيع الكاشير',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 24),
                          pw.Container(
                            width: 120,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey400)),
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text('توقيع المدير',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 24),
                          pw.Container(
                            width: 120,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.grey400)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildZReportRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 11,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
