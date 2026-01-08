import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../export/export_templates.dart';
import '../currency_formatter.dart';
import 'pdf_theme.dart';

/// أحجام الطباعة المدعومة للفواتير
enum InvoicePrintSize {
  a4, // فاتورة A4 كاملة
  thermal80mm, // طابعة حرارية 80mm
  thermal58mm, // طابعة حرارية 58mm
}

/// خيارات طباعة الفاتورة
class InvoicePrintOptions {
  final InvoicePrintSize size;
  final bool showBarcode;
  final bool showLogo;
  final bool showCustomerInfo;
  final bool showNotes;
  final bool showPaymentMethod;
  final bool showTaxDetails;
  final bool showExchangeRate; // عرض سعر الصرف والسعر بالدولار
  final Uint8List? logoBytes;
  final String? companyName;
  final String? companyAddress;
  final String? companyPhone;
  final String? companyTaxNumber;
  final String? footerMessage;
  final bool showInvoiceBarcode;

  const InvoicePrintOptions({
    this.size = InvoicePrintSize.a4,
    this.showBarcode = true,
    this.showLogo = true,
    this.showCustomerInfo = true,
    this.showNotes = true,
    this.showPaymentMethod = true,
    this.showTaxDetails = true,
    this.showExchangeRate = true,
    this.logoBytes,
    this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.companyTaxNumber,
    this.footerMessage,
    this.showInvoiceBarcode = false,
  });

  InvoicePrintOptions copyWith({
    InvoicePrintSize? size,
    bool? showBarcode,
    bool? showLogo,
    bool? showCustomerInfo,
    bool? showNotes,
    bool? showPaymentMethod,
    bool? showTaxDetails,
    bool? showExchangeRate,
    Uint8List? logoBytes,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyTaxNumber,
    String? footerMessage,
    bool? showInvoiceBarcode,
  }) {
    return InvoicePrintOptions(
      size: size ?? this.size,
      showBarcode: showBarcode ?? this.showBarcode,
      showLogo: showLogo ?? this.showLogo,
      showCustomerInfo: showCustomerInfo ?? this.showCustomerInfo,
      showNotes: showNotes ?? this.showNotes,
      showPaymentMethod: showPaymentMethod ?? this.showPaymentMethod,
      showTaxDetails: showTaxDetails ?? this.showTaxDetails,
      showExchangeRate: showExchangeRate ?? this.showExchangeRate,
      logoBytes: logoBytes ?? this.logoBytes,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyTaxNumber: companyTaxNumber ?? this.companyTaxNumber,
      footerMessage: footerMessage ?? this.footerMessage,
      showInvoiceBarcode: showInvoiceBarcode ?? this.showInvoiceBarcode,
    );
  }
}

/// بيانات عنصر الفاتورة
class InvoiceItemData {
  final String name;
  final String? barcode;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double discount;
  final double total;

  const InvoiceItemData({
    required this.name,
    this.barcode,
    required this.quantity,
    this.unit = 'قطعة',
    required this.unitPrice,
    this.discount = 0,
    required this.total,
  });
}

/// بيانات الفاتورة للطباعة
class InvoiceData {
  final String invoiceNumber;
  final String invoiceType; // sale, purchase, saleReturn, purchaseReturn
  final DateTime date;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final List<InvoiceItemData> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double? totalUsd; // الإجمالي بالدولار (محفوظ من الفاتورة)
  final double? paidAmount;
  final double? paidAmountUsd; // المدفوع بالدولار (محفوظ من الفاتورة)
  final double? remainingAmount;
  final String? paymentMethod; // cash, credit, deferred
  final String? notes;
  final String? createdBy;
  final double exchangeRate; // سعر الصرف (دولار/ليرة)

  const InvoiceData({
    required this.invoiceNumber,
    required this.invoiceType,
    required this.date,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    this.totalUsd,
    this.paidAmount,
    this.paidAmountUsd,
    this.remainingAmount,
    this.paymentMethod,
    this.notes,
    this.createdBy,
    this.exchangeRate = 0,
  });
}

/// مولد PDF للفواتير
class InvoicePdfGenerator {
  // ==================== Static Helper Methods ====================

  /// طباعة فاتورة مباشرة (static method للاستخدام المباشر)
  static Future<void> printInvoiceDirectly({
    required dynamic invoice,
    required List<dynamic> items,
    dynamic customer,
    dynamic supplier,
    InvoicePrintOptions options = const InvoicePrintOptions(),
  }) async {
    final generator = InvoicePdfGenerator();
    final invoiceData = _createInvoiceData(invoice, items, customer, supplier);
    await generator.printInvoice(invoiceData, options: options);
  }

  /// مشاركة فاتورة كـ PDF (static method للاستخدام المباشر)
  static Future<void> shareInvoiceAsPdf({
    required dynamic invoice,
    required List<dynamic> items,
    dynamic customer,
    dynamic supplier,
    InvoicePrintOptions options = const InvoicePrintOptions(),
  }) async {
    final generator = InvoicePdfGenerator();
    final invoiceData = _createInvoiceData(invoice, items, customer, supplier);
    await generator.shareInvoice(invoiceData, options: options);
  }

  /// حفظ فاتورة كـ PDF (static method للاستخدام المباشر)
  static Future<String> saveInvoiceAsPdf({
    required dynamic invoice,
    required List<dynamic> items,
    dynamic customer,
    dynamic supplier,
    InvoicePrintOptions options = const InvoicePrintOptions(),
  }) async {
    final generator = InvoicePdfGenerator();
    final invoiceData = _createInvoiceData(invoice, items, customer, supplier);
    return await generator.saveInvoicePdf(invoiceData, options: options);
  }

  /// الحصول على bytes الـ PDF للمعاينة (static method للاستخدام المباشر)
  static Future<Uint8List> generateInvoicePdfBytes({
    required dynamic invoice,
    required List<dynamic> items,
    dynamic customer,
    dynamic supplier,
    InvoicePrintOptions options = const InvoicePrintOptions(),
  }) async {
    final generator = InvoicePdfGenerator();
    final invoiceData = _createInvoiceData(invoice, items, customer, supplier);
    return await generator.generateInvoicePdf(invoiceData, options: options);
  }

  /// تحويل بيانات الفاتورة من الـ Database models إلى InvoiceData
  ///
  /// ⚠️ السياسة المحاسبية:
  /// - نستخدم القيم المحفوظة (totalUsd, paidAmountUsd, exchangeRate)
  /// - لا نحسب القيم بالدولار باستخدام سعر الصرف الحالي
  static InvoiceData _createInvoiceData(
    dynamic invoice,
    List<dynamic> items,
    dynamic customer,
    dynamic supplier,
  ) {
    // الحصول على سعر الصرف من الفاتورة إن وجد
    double exchangeRate = 0;
    double? totalUsd;
    double? paidAmountUsd;

    try {
      exchangeRate = invoice.exchangeRate ?? 0;
      totalUsd = invoice.totalUsd;
      paidAmountUsd = invoice.paidAmountUsd;
    } catch (_) {
      exchangeRate = 0;
    }

    return InvoiceData(
      invoiceNumber: invoice.invoiceNumber,
      date: invoice.invoiceDate,
      invoiceType: invoice.type,
      customerName: customer?.name ?? supplier?.name,
      customerPhone: customer?.phone ?? supplier?.phone,
      customerAddress: customer?.address ?? supplier?.address,
      items: items
          .map((item) => InvoiceItemData(
                name: item.productName,
                barcode: null,
                quantity: item.quantity.toDouble(),
                unit: 'قطعة',
                unitPrice: item.unitPrice,
                discount: item.discountAmount ?? 0.0,
                total: item.total,
              ))
          .toList(),
      subtotal: invoice.subtotal,
      discount: invoice.discountAmount,
      total: invoice.total,
      totalUsd: totalUsd,
      paidAmount: invoice.paidAmount,
      paidAmountUsd: paidAmountUsd,
      remainingAmount: invoice.total - (invoice.paidAmount ?? 0.0),
      paymentMethod: invoice.paymentMethod,
      notes: invoice.notes,
      exchangeRate: exchangeRate,
    );
  }

  // ==================== Instance Methods ====================

  /// طباعة الفاتورة مباشرة
  Future<void> printInvoice(
    InvoiceData invoice, {
    InvoicePrintOptions options = const InvoicePrintOptions(),
  }) async {
    final pdfBytes = await generateInvoicePdf(invoice, options: options);
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: 'فاتورة_${invoice.invoiceNumber}',
    );
  }

  /// إنشاء PDF للفاتورة
  Future<Uint8List> generateInvoicePdf(
    InvoiceData invoice, {
    InvoicePrintOptions options = const InvoicePrintOptions(),
  }) async {
    // ✅ تهيئة الخطوط العربية أولاً
    await PdfFonts.init();

    final pdf = pw.Document();

    switch (options.size) {
      case InvoicePrintSize.a4:
        pdf.addPage(_buildA4Invoice(invoice, options));
        break;
      case InvoicePrintSize.thermal80mm:
        pdf.addPage(_buildThermalInvoice(invoice, options, 80));
        break;
      case InvoicePrintSize.thermal58mm:
        pdf.addPage(_buildThermalInvoice(invoice, options, 58));
        break;
    }

    return pdf.save();
  }

  /// حفظ PDF للفاتورة
  Future<String> saveInvoicePdf(
    InvoiceData invoice, {
    InvoicePrintOptions options = const InvoicePrintOptions(),
  }) async {
    final pdfBytes = await generateInvoicePdf(invoice, options: options);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'فاتورة_${invoice.invoiceNumber}_$timestamp.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  /// مشاركة الفاتورة
  Future<void> shareInvoice(
    InvoiceData invoice, {
    InvoicePrintOptions options = const InvoicePrintOptions(),
  }) async {
    final filePath = await saveInvoicePdf(invoice, options: options);
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'فاتورة رقم ${invoice.invoiceNumber}',
    );
  }

  // ==================== فاتورة A4 (بتصميم بسيط ومرتب) ====================

  pw.Page _buildA4Invoice(InvoiceData invoice, InvoicePrintOptions options) {
    final invoiceColor = _getInvoiceColor(invoice.invoiceType);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      margin: const pw.EdgeInsets.all(32),
      theme: PdfTheme.create(),
      build: (context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ═══════════════ الرأس ═══════════════
              _buildSimpleHeader(invoice, options, invoiceColor),
              pw.SizedBox(height: 20),

              // ═══════════════ معلومات الشركة والعميل/المورد ═══════════════
              _buildCompanyAndCustomerRow(invoice, options, invoiceColor),
              pw.SizedBox(height: 16),

              // ═══════════════ جدول المنتجات ═══════════════
              _buildSimpleItemsTable(invoice, invoiceColor),
              pw.SizedBox(height: 16),

              // ═══════════════ ملخص الفاتورة ═══════════════
              _buildSimpleSummary(invoice, invoiceColor, options),
              pw.SizedBox(height: 16),

              // ═══════════════ معلومات إضافية ═══════════════
              if (options.showNotes && invoice.notes != null)
                _buildSimpleInfoRow(invoice, options),

              pw.Spacer(),

              // ═══════════════ التذييل ═══════════════
              _buildSimpleFooter(options),
            ],
          ),
        );
      },
    );
  }

  /// رأس الفاتورة البسيط
  pw.Widget _buildSimpleHeader(
    InvoiceData invoice,
    InvoicePrintOptions options,
    PdfColor invoiceColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: invoiceColor,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // نوع الفاتورة
          pw.Text(
            _getInvoiceTypeLabel(invoice.invoiceType),
            style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: PdfSizes.fontSizeTitle + 2,
              color: AppPdfColors.textWhite,
            ),
            textAlign: pw.TextAlign.center,
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 12),
          // رقم الفاتورة والتاريخ
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: AppPdfColors.bgWhite,
                  borderRadius: pw.BorderRadius.circular(16),
                ),
                child: pw.Text(
                  invoice.invoiceNumber,
                  style: pw.TextStyle(
                    font: PdfFonts.bold,
                    fontSize: PdfSizes.fontSizeSmall + 1,
                    color: invoiceColor,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: AppPdfColors.bgWhite,
                  borderRadius: pw.BorderRadius.circular(16),
                ),
                child: pw.Text(
                  ExportFormatters.formatDateTime(invoice.date),
                  style: pw.TextStyle(
                    font: PdfFonts.regular,
                    fontSize: PdfSizes.fontSizeSmall,
                    color: invoiceColor,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// صف معلومات الشركة والعميل/المورد
  pw.Widget _buildCompanyAndCustomerRow(
      InvoiceData invoice, InvoicePrintOptions options, PdfColor invoiceColor) {
    final hasCompanyInfo = options.companyName != null ||
        options.companyAddress != null ||
        options.companyPhone != null ||
        options.companyTaxNumber != null;

    final hasCustomerInfo =
        options.showCustomerInfo && invoice.customerName != null;

    if (!hasCompanyInfo && !hasCustomerInfo) {
      return pw.SizedBox.shrink();
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // صندوق معلومات العميل/المورد (يمين)
        if (hasCustomerInfo)
          pw.Expanded(
            child: _buildSimpleCustomerBox(invoice, invoiceColor),
          ),
        if (hasCustomerInfo && hasCompanyInfo) pw.SizedBox(width: 12),
        // صندوق معلومات الشركة (يسار)
        if (hasCompanyInfo)
          pw.Expanded(
            child: _buildCompanyInfoBox(options, invoiceColor),
          ),
      ],
    );
  }

  /// صندوق معلومات الشركة
  pw.Widget _buildCompanyInfoBox(
      InvoicePrintOptions options, PdfColor invoiceColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgLight,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: AppPdfColors.borderLight),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 4,
            height: 50,
            decoration: pw.BoxDecoration(
              color: AppPdfColors.primary,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (options.companyName != null)
                  pw.Text(
                    options.companyName!,
                    style: pw.TextStyle(
                        font: PdfFonts.bold, fontSize: PdfSizes.fontSizeMedium),
                    textDirection: pw.TextDirection.rtl,
                  ),
                if (options.companyAddress != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    options.companyAddress!,
                    style: pw.TextStyle(
                        font: PdfFonts.regular,
                        fontSize: PdfSizes.fontSizeSmall - 1,
                        color: AppPdfColors.textSecondary),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ],
                if (options.companyPhone != null ||
                    options.companyTaxNumber != null)
                  pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    if (options.companyPhone != null)
                      pw.Text(
                        'هاتف: ${options.companyPhone}',
                        style: pw.TextStyle(
                            font: PdfFonts.regular,
                            fontSize: PdfSizes.fontSizeSmall - 1,
                            color: AppPdfColors.textSecondary),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    if (options.companyPhone != null &&
                        options.companyTaxNumber != null)
                      pw.Text('  |  ',
                          style: pw.TextStyle(
                              font: PdfFonts.regular,
                              fontSize: PdfSizes.fontSizeSmall - 1,
                              color: AppPdfColors.borderMedium)),
                    if (options.companyTaxNumber != null)
                      pw.Text(
                        'الرقم الضريبي: ${options.companyTaxNumber}',
                        style: pw.TextStyle(
                            font: PdfFonts.regular,
                            fontSize: PdfSizes.fontSizeSmall - 1,
                            color: AppPdfColors.textSecondary),
                        textDirection: pw.TextDirection.rtl,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// صندوق معلومات العميل/المورد
  pw.Widget _buildSimpleCustomerBox(
      InvoiceData invoice, PdfColor invoiceColor) {
    final isSupplier = invoice.invoiceType == 'purchase' ||
        invoice.invoiceType == 'purchase_return';
    final label = isSupplier ? 'المورد' : 'العميل';

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgLight,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: AppPdfColors.borderLight),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 4,
            height: 50,
            decoration: pw.BoxDecoration(
              color: invoiceColor,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '$label: ${invoice.customerName}',
                  style: pw.TextStyle(
                      font: PdfFonts.bold, fontSize: PdfSizes.fontSizeMedium),
                  textDirection: pw.TextDirection.rtl,
                ),
                if (invoice.customerPhone != null ||
                    invoice.customerAddress != null)
                  pw.SizedBox(height: 4),
                if (invoice.customerPhone != null)
                  pw.Text(
                    'هاتف: ${invoice.customerPhone}',
                    style: pw.TextStyle(
                        font: PdfFonts.regular,
                        fontSize: PdfSizes.fontSizeSmall - 1,
                        color: AppPdfColors.textSecondary),
                    textDirection: pw.TextDirection.rtl,
                  ),
                if (invoice.customerAddress != null)
                  pw.Text(
                    'العنوان: ${invoice.customerAddress}',
                    style: pw.TextStyle(
                        font: PdfFonts.regular,
                        fontSize: PdfSizes.fontSizeSmall - 1,
                        color: AppPdfColors.textSecondary),
                    textDirection: pw.TextDirection.rtl,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// جدول المنتجات البسيط
  pw.Widget _buildSimpleItemsTable(InvoiceData invoice, PdfColor invoiceColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // عنوان الجدول
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Text(
            'تفاصيل الأصناف (${invoice.items.length} صنف)',
            style: pw.TextStyle(
                font: PdfFonts.bold,
                fontSize: PdfSizes.fontSizeSmall + 1,
                color: AppPdfColors.textSecondary),
            textDirection: pw.TextDirection.rtl,
          ),
        ),
        // الجدول - RTL (الأعمدة معكوسة)
        pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Table(
            border:
                pw.TableBorder.all(color: AppPdfColors.borderLight, width: 0.5),
            columnWidths: {
              // العرض معكوس: الإجمالي(يسار) ... #(يمين)
              0: const pw.FlexColumnWidth(1.3), // الإجمالي
              1: const pw.FlexColumnWidth(1), // الخصم
              2: const pw.FlexColumnWidth(1.2), // السعر
              3: const pw.FlexColumnWidth(1), // الكمية
              4: const pw.FlexColumnWidth(3.5), // الصنف
              5: const pw.FlexColumnWidth(0.5), // #
            },
            children: [
              // رأس الجدول - معكوس للـ RTL
              pw.TableRow(
                decoration: pw.BoxDecoration(color: invoiceColor),
                children: [
                  _simpleHeaderCell('الإجمالي'),
                  _simpleHeaderCell('الخصم'),
                  _simpleHeaderCell('السعر'),
                  _simpleHeaderCell('الكمية'),
                  _simpleHeaderCell('الصنف'),
                  _simpleHeaderCell('#'),
                ],
              ),
              // بيانات الأصناف - معكوسة للـ RTL
              ...invoice.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isEven = index.isEven;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven
                        ? AppPdfColors.tableRowEven
                        : AppPdfColors.tableRowOdd,
                  ),
                  children: [
                    _simpleDataCell(
                      ExportFormatters.formatPrice(item.total,
                          showCurrency: false),
                      bold: true,
                    ),
                    _simpleDataCell(
                      item.discount > 0
                          ? ExportFormatters.formatPrice(item.discount,
                              showCurrency: false)
                          : '-',
                      color: item.discount > 0 ? AppPdfColors.error : null,
                    ),
                    _simpleDataCell(ExportFormatters.formatPrice(item.unitPrice,
                        showCurrency: false)),
                    _simpleDataCell(
                        ExportFormatters.formatQuantity(item.quantity)),
                    _simpleDataCell(item.name, align: pw.Alignment.centerRight),
                    _simpleDataCell('${index + 1}'),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _simpleHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: PdfFonts.bold,
          fontSize: PdfSizes.fontSizeSmall,
          color: AppPdfColors.textWhite,
        ),
        textAlign: pw.TextAlign.center,
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  pw.Widget _simpleDataCell(
    String text, {
    pw.Alignment align = pw.Alignment.center,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      alignment: align,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: bold ? PdfFonts.bold : PdfFonts.regular,
          fontSize: PdfSizes.fontSizeSmall - 1,
          color: color ?? AppPdfColors.textPrimary,
        ),
        textAlign: align == pw.Alignment.centerRight
            ? pw.TextAlign.right
            : pw.TextAlign.center,
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  /// ملخص الفاتورة
  pw.Widget _buildSimpleSummary(
      InvoiceData invoice, PdfColor invoiceColor, InvoicePrintOptions options) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // إحصائيات سريعة
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: AppPdfColors.bgLight,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('عدد الأصناف', '${invoice.items.length}'),
                _buildStatColumn(
                  'إجمالي الكمية',
                  ExportFormatters.formatQuantity(
                    invoice.items.fold(0.0, (sum, item) => sum + item.quantity),
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 16),
        // ملخص المبالغ
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: AppPdfColors.bgLight,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: AppPdfColors.borderLight),
            ),
            child: pw.Column(
              children: [
                // الإجمالي
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      ExportFormatters.formatPrice(invoice.total),
                      style: pw.TextStyle(
                          font: PdfFonts.bold,
                          fontSize: PdfSizes.fontSizeXLarge,
                          color: invoiceColor),
                      textDirection: pw.TextDirection.rtl,
                    ),
                    pw.Text(
                      'الإجمالي',
                      style: pw.TextStyle(
                          font: PdfFonts.bold,
                          fontSize: PdfSizes.fontSizeLarge,
                          color: invoiceColor),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ],
                ),
                // الخصم
                if (invoice.discount > 0) ...[
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '- ${ExportFormatters.formatPrice(invoice.discount, showCurrency: false)}',
                        style: pw.TextStyle(
                            font: PdfFonts.regular,
                            fontSize: PdfSizes.fontSizeSmall,
                            color: AppPdfColors.error),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Text(
                        'الخصم',
                        style: pw.TextStyle(
                            font: PdfFonts.regular,
                            fontSize: PdfSizes.fontSizeSmall,
                            color: AppPdfColors.error),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                ],
                // المبلغ المدفوع والمتبقي (للدفع الجزئي)
                if (invoice.paidAmount != null) ...[
                  pw.SizedBox(height: 8),
                  pw.Divider(color: AppPdfColors.borderLight, thickness: 0.5),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        ExportFormatters.formatPrice(invoice.paidAmount!),
                        style: pw.TextStyle(
                            font: PdfFonts.bold,
                            fontSize: PdfSizes.fontSizeSmall + 1,
                            color: AppPdfColors.success),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Text(
                        'المبلغ المدفوع',
                        style: pw.TextStyle(
                            font: PdfFonts.regular,
                            fontSize: PdfSizes.fontSizeSmall,
                            color: AppPdfColors.success),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                  if (invoice.remainingAmount != null &&
                      invoice.remainingAmount! > 0) ...[
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          ExportFormatters.formatPrice(
                              invoice.remainingAmount!),
                          style: pw.TextStyle(
                              font: PdfFonts.bold,
                              fontSize: PdfSizes.fontSizeSmall + 1,
                              color: AppPdfColors.error),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.Text(
                          'المبلغ المتبقي',
                          style: pw.TextStyle(
                              font: PdfFonts.regular,
                              fontSize: PdfSizes.fontSizeSmall,
                              color: AppPdfColors.error),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ],
                    ),
                  ],
                ],
                // طريقة الدفع
                if (options.showPaymentMethod &&
                    invoice.paymentMethod != null) ...[
                  pw.SizedBox(height: 8),
                  pw.Divider(color: AppPdfColors.borderLight, thickness: 0.5),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        ExportFormatters.getPaymentMethodLabel(
                            invoice.paymentMethod!),
                        style: pw.TextStyle(
                            font: PdfFonts.bold,
                            fontSize: PdfSizes.fontSizeSmall,
                            color: AppPdfColors.textPrimary),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Text(
                        'طريقة الدفع',
                        style: pw.TextStyle(
                            font: PdfFonts.regular,
                            fontSize: PdfSizes.fontSizeSmall,
                            color: AppPdfColors.textSecondary),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                ],
                // سعر الصرف والإجمالي بالدولار (من القيم المحفوظة)
                if (options.showExchangeRate && invoice.exchangeRate > 0) ...[
                  pw.SizedBox(height: 8),
                  pw.Divider(color: AppPdfColors.borderLight, thickness: 0.5),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '${ExportFormatters.formatPrice(invoice.exchangeRate, showCurrency: false)} ${CurrencyFormatter.sypSymbol}/\$',
                        style: pw.TextStyle(
                            font: PdfFonts.regular,
                            fontSize: PdfSizes.fontSizeSmall,
                            color: AppPdfColors.textSecondary),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Text(
                        'سعر الصرف',
                        style: pw.TextStyle(
                            font: PdfFonts.regular,
                            fontSize: PdfSizes.fontSizeSmall,
                            color: AppPdfColors.textSecondary),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        // ✅ استخدام القيمة المحفوظة أو الحساب باستخدام سعر الصرف المثبت
                        '\$${(invoice.totalUsd ?? (invoice.total / invoice.exchangeRate)).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            font: PdfFonts.bold,
                            fontSize: PdfSizes.fontSizeMedium,
                            color: AppPdfColors.blue800),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Text(
                        'السعر بالدولار',
                        style: pw.TextStyle(
                            font: PdfFonts.bold,
                            fontSize: PdfSizes.fontSizeSmall + 1,
                            color: AppPdfColors.blue800),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildStatColumn(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
              font: PdfFonts.regular,
              fontSize: PdfSizes.fontSizeSmall - 1,
              color: AppPdfColors.textMuted),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: PdfSizes.fontSizeLarge,
              color: AppPdfColors.textPrimary),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    );
  }

  /// صف المعلومات الإضافية
  pw.Widget _buildSimpleInfoRow(
      InvoiceData invoice, InvoicePrintOptions options) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (options.showPaymentMethod && invoice.paymentMethod != null)
          pw.Expanded(
            child: _buildSimpleInfoBox(
              'طريقة الدفع',
              ExportFormatters.getPaymentMethodLabel(invoice.paymentMethod!),
              AppPdfColors.bgBlue,
              AppPdfColors.primary,
            ),
          ),
        if (options.showPaymentMethod &&
            invoice.paymentMethod != null &&
            options.showNotes &&
            invoice.notes != null)
          pw.SizedBox(width: 12),
        if (options.showNotes && invoice.notes != null)
          pw.Expanded(
            flex: 2,
            child: _buildSimpleInfoBox(
              'ملاحظات',
              invoice.notes!,
              AppPdfColors.bgAmber,
              AppPdfColors.warning,
            ),
          ),
      ],
    );
  }

  pw.Widget _buildSimpleInfoBox(
      String title, String content, PdfColor bgColor, PdfColor accentColor) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // الشريط الجانبي الملون
        pw.Container(
          width: 3,
          height: 50,
          color: accentColor,
        ),
        // المحتوى
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: bgColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                      font: PdfFonts.bold,
                      fontSize: PdfSizes.fontSizeSmall,
                      color: accentColor),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  content,
                  style: pw.TextStyle(
                      font: PdfFonts.regular,
                      fontSize: PdfSizes.fontSizeSmall,
                      color: AppPdfColors.textPrimary),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// تذييل الفاتورة
  pw.Widget _buildSimpleFooter(InvoicePrintOptions options) {
    final footerText = options.footerMessage;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: AppPdfColors.borderLight)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          if (footerText != null && footerText.isNotEmpty)
            pw.Text(
              footerText,
              style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: PdfSizes.fontSizeSmall - 1,
                  color: AppPdfColors.textMuted),
              textDirection: pw.TextDirection.rtl,
            ),
          pw.Text(
            'تم الطباعة: ${ExportFormatters.formatDateTime(DateTime.now())}',
            style: pw.TextStyle(
                font: PdfFonts.regular,
                fontSize: PdfSizes.fontSizeXSmall,
                color: AppPdfColors.textLight),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  // ==================== فاتورة حرارية ====================

  pw.Page _buildThermalInvoice(
    InvoiceData invoice,
    InvoicePrintOptions options,
    int widthMm,
  ) {
    final pageWidth = widthMm * PdfPageFormat.mm;
    final invoiceColor = _getInvoiceColor(invoice.invoiceType);

    return pw.Page(
      pageFormat: PdfPageFormat(pageWidth, double.infinity),
      textDirection: pw.TextDirection.rtl,
      margin: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      theme: PdfTheme.create(),
      build: (context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              // الرأس
              _buildThermalHeader(invoice, options, invoiceColor),
              _thermalDivider(),

              // معلومات العميل
              if (options.showCustomerInfo && invoice.customerName != null) ...[
                _buildThermalCustomerInfo(invoice),
                _thermalDivider(),
              ],

              // المنتجات
              _buildThermalItems(invoice, widthMm),
              _thermalDivider(),

              // الإجماليات
              _buildThermalTotals(invoice, options),

              // طريقة الدفع
              if (options.showPaymentMethod &&
                  invoice.paymentMethod != null) ...[
                _thermalDivider(),
                _buildThermalPayment(invoice),
              ],

              _thermalDivider(),

              // التذييل
              _buildThermalFooter(options),
            ],
          ),
        );
      },
    );
  }

  pw.Widget _buildThermalHeader(
    InvoiceData invoice,
    InvoicePrintOptions options,
    PdfColor invoiceColor,
  ) {
    return pw.Column(
      children: [
        // اسم الشركة
        if (options.companyName != null)
          pw.Text(
            options.companyName!,
            style: pw.TextStyle(
                font: PdfFonts.bold, fontSize: PdfSizes.fontSizeLarge),
            textAlign: pw.TextAlign.center,
            textDirection: pw.TextDirection.rtl,
          ),

        // العنوان
        if (options.companyAddress != null)
          pw.Text(
            options.companyAddress!,
            style: pw.TextStyle(
                font: PdfFonts.regular, fontSize: PdfSizes.fontSizeXSmall),
            textAlign: pw.TextAlign.center,
            textDirection: pw.TextDirection.rtl,
          ),

        // رقم الهاتف
        if (options.companyPhone != null)
          pw.Text(
            options.companyPhone!,
            style: pw.TextStyle(
                font: PdfFonts.regular, fontSize: PdfSizes.fontSizeXSmall),
            textAlign: pw.TextAlign.center,
            textDirection: pw.TextDirection.rtl,
          ),

        // الرقم الضريبي
        if (options.companyTaxNumber != null)
          pw.Text(
            'الرقم الضريبي: ${options.companyTaxNumber}',
            style: pw.TextStyle(
                font: PdfFonts.regular, fontSize: PdfSizes.fontSizeXSmall),
            textAlign: pw.TextAlign.center,
            textDirection: pw.TextDirection.rtl,
          ),

        pw.SizedBox(height: 8),

        // نوع الفاتورة
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: pw.BoxDecoration(
            color: invoiceColor,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            _getInvoiceTypeLabel(invoice.invoiceType),
            style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: PdfSizes.fontSizeMedium,
              color: AppPdfColors.textWhite,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ),

        pw.SizedBox(height: 6),

        // رقم الفاتورة والتاريخ
        pw.Text(
          invoice.invoiceNumber,
          style: pw.TextStyle(
              font: PdfFonts.regular, fontSize: PdfSizes.fontSizeSmall),
          textAlign: pw.TextAlign.center,
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Text(
          ExportFormatters.formatDateTime(invoice.date),
          style: pw.TextStyle(
              font: PdfFonts.regular, fontSize: PdfSizes.fontSizeSmall - 1),
          textAlign: pw.TextAlign.center,
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    );
  }

  pw.Widget _buildThermalCustomerInfo(InvoiceData invoice) {
    final isSupplier = invoice.invoiceType == 'purchase' ||
        invoice.invoiceType == 'purchaseReturn';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${isSupplier ? "المورد" : "العميل"}: ${invoice.customerName}',
          style: pw.TextStyle(
              font: PdfFonts.regular, fontSize: PdfSizes.fontSizeSmall - 1),
          textDirection: pw.TextDirection.rtl,
        ),
        if (invoice.customerPhone != null)
          pw.Text(
            'الهاتف: ${invoice.customerPhone}',
            style: pw.TextStyle(
                font: PdfFonts.regular, fontSize: PdfSizes.fontSizeXSmall),
            textDirection: pw.TextDirection.rtl,
          ),
      ],
    );
  }

  pw.Widget _buildThermalItems(InvoiceData invoice, int widthMm) {
    final fontSize = widthMm == 58 ? 7.0 : 8.0;

    return pw.Column(
      children: invoice.items.map((item) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                item.name,
                style: pw.TextStyle(font: PdfFonts.bold, fontSize: fontSize),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    ExportFormatters.formatPrice(item.total,
                        showCurrency: false),
                    style:
                        pw.TextStyle(font: PdfFonts.bold, fontSize: fontSize),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Text(
                    '${ExportFormatters.formatQuantity(item.quantity)} × ${ExportFormatters.formatPrice(item.unitPrice, showCurrency: false)}',
                    style: pw.TextStyle(
                        font: PdfFonts.regular, fontSize: fontSize - 1),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildThermalTotals(
      InvoiceData invoice, InvoicePrintOptions options) {
    return pw.Column(
      children: [
        _thermalTotalRow('المجموع', invoice.subtotal),
        if (invoice.discount > 0)
          _thermalTotalRow('الخصم', invoice.discount, isNegative: true),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: pw.BoxDecoration(
            color: AppPdfColors.bgMedium,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                ExportFormatters.formatPrice(invoice.total),
                style: pw.TextStyle(
                    font: PdfFonts.bold, fontSize: PdfSizes.fontSizeMedium),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                'الإجمالي',
                style: pw.TextStyle(
                    font: PdfFonts.bold, fontSize: PdfSizes.fontSizeMedium),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ),
        // سعر الصرف والإجمالي بالدولار للطابعة الحرارية (من القيم المحفوظة)
        if (options.showExchangeRate && invoice.exchangeRate > 0) ...[
          pw.SizedBox(height: 4),
          _thermalTotalRow('سعر الصرف', invoice.exchangeRate,
              suffix: ' ${CurrencyFormatter.sypSymbol}/\$'),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  // ✅ استخدام القيمة المحفوظة أو الحساب باستخدام سعر الصرف المثبت
                  '\$${(invoice.totalUsd ?? (invoice.total / invoice.exchangeRate)).toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      font: PdfFonts.bold,
                      fontSize: PdfSizes.fontSizeSmall,
                      color: AppPdfColors.blue800),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.Text(
                  'السعر بالدولار',
                  style: pw.TextStyle(
                      font: PdfFonts.regular,
                      fontSize: PdfSizes.fontSizeSmall - 1,
                      color: AppPdfColors.blue800),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  pw.Widget _thermalTotalRow(String label, double value,
      {bool isNegative = false, String? suffix}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${isNegative ? "-" : ""}${ExportFormatters.formatPrice(value, showCurrency: false)}${suffix ?? ""}',
            style: pw.TextStyle(
              font: PdfFonts.regular,
              fontSize: PdfSizes.fontSizeSmall - 1,
              color: isNegative ? AppPdfColors.red : AppPdfColors.textPrimary,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            label,
            style: pw.TextStyle(
                font: PdfFonts.regular, fontSize: PdfSizes.fontSizeSmall - 1),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildThermalPayment(InvoiceData invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'طريقة الدفع: ${ExportFormatters.getPaymentMethodLabel(invoice.paymentMethod!)}',
          style: pw.TextStyle(
              font: PdfFonts.regular, fontSize: PdfSizes.fontSizeSmall - 1),
          textDirection: pw.TextDirection.rtl,
        ),
        if (invoice.paidAmount != null)
          pw.Text(
            'المدفوع: ${ExportFormatters.formatPrice(invoice.paidAmount!)}',
            style: pw.TextStyle(
                font: PdfFonts.regular, fontSize: PdfSizes.fontSizeSmall - 1),
            textDirection: pw.TextDirection.rtl,
          ),
        if (invoice.remainingAmount != null && invoice.remainingAmount! > 0)
          pw.Text(
            'المتبقي: ${ExportFormatters.formatPrice(invoice.remainingAmount!)}',
            style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: PdfSizes.fontSizeSmall - 1,
              color: AppPdfColors.red,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
      ],
    );
  }

  pw.Widget _buildThermalFooter(InvoicePrintOptions options) {
    final footerText = options.footerMessage;

    return pw.Column(
      children: [
        if (footerText != null && footerText.isNotEmpty) ...[
          pw.Text(
            footerText,
            style: pw.TextStyle(
                font: PdfFonts.regular, fontSize: PdfSizes.fontSizeSmall),
            textAlign: pw.TextAlign.center,
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 4),
        ],
        pw.Text(
          'شكراً لتعاملكم معنا',
          style: pw.TextStyle(
              font: PdfFonts.bold, fontSize: PdfSizes.fontSizeSmall),
          textAlign: pw.TextAlign.center,
          textDirection: pw.TextDirection.rtl,
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Hoor',
          style: pw.TextStyle(
              font: PdfFonts.regular,
              fontSize: PdfSizes.fontSizeXSmall,
              color: AppPdfColors.textMuted),
          textAlign: pw.TextAlign.center,
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    );
  }

  pw.Widget _thermalDivider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: List.generate(
          40,
          (index) => pw.Expanded(
            child: pw.Container(
              height: 1,
              color: index.isEven
                  ? AppPdfColors.borderMedium
                  : AppPdfColors.bgWhite,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== دوال مساعدة ====================

  PdfColor _getInvoiceColor(String invoiceType) {
    return AppPdfColors.getInvoiceColor(invoiceType);
  }

  String _getInvoiceTypeLabel(String invoiceType) {
    switch (invoiceType) {
      case 'sale':
        return 'فاتورة مبيعات';
      case 'purchase':
        return 'فاتورة مشتريات';
      case 'saleReturn':
      case 'sale_return':
        return 'مرتجع مبيعات';
      case 'purchaseReturn':
      case 'purchase_return':
        return 'مرتجع مشتريات';
      default:
        return 'فاتورة';
    }
  }
}
