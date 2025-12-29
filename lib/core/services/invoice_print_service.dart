import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/database/app_database.dart';
import '../widgets/invoice_widgets.dart';

/// خدمة طباعة الفواتير مع تصاميم محسنة لجميع أحجام الطباعة
class InvoicePrintService {
  // أحجام الخطوط حسب حجم الطباعة
  static const Map<String, Map<String, double>> _fontSizes = {
    '58mm': {
      'title': 12,
      'subtitle': 8,
      'header': 10,
      'body': 7,
      'small': 6,
      'total': 10,
    },
    '80mm': {
      'title': 16,
      'subtitle': 10,
      'header': 11,
      'body': 9,
      'small': 7,
      'total': 12,
    },
    'A4': {
      'title': 24,
      'subtitle': 12,
      'header': 14,
      'body': 11,
      'small': 9,
      'total': 16,
    },
  };

  // المسافات حسب حجم الطباعة
  static const Map<String, Map<String, double>> _spacing = {
    '58mm': {
      'margin': 6,
      'gap': 3,
      'padding': 4,
      'divider': 0.5,
    },
    '80mm': {
      'margin': 10,
      'gap': 5,
      'padding': 6,
      'divider': 0.5,
    },
    'A4': {
      'margin': 32,
      'gap': 12,
      'padding': 16,
      'divider': 1,
    },
  };

  /// طباعة الفاتورة
  static Future<void> printInvoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
    required String printSize,
    Customer? customer,
    Supplier? supplier,
    bool showBarcode = true,
    bool showLogo = true,
    bool showCustomerInfo = true,
    bool showNotes = true,
    bool showPaymentMethod = true,
  }) async {
    final pdfBytes = await generateInvoicePdf(
      invoice: invoice,
      items: items,
      printSize: printSize,
      customer: customer,
      supplier: supplier,
      showBarcode: showBarcode,
      showLogo: showLogo,
      showCustomerInfo: showCustomerInfo,
      showNotes: showNotes,
      showPaymentMethod: showPaymentMethod,
    );

    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }

  /// إنشاء PDF للفاتورة
  static Future<Uint8List> generateInvoicePdf({
    required Invoice invoice,
    required List<InvoiceItem> items,
    required String printSize,
    Customer? customer,
    Supplier? supplier,
    bool showBarcode = true,
    bool showLogo = true,
    bool showCustomerInfo = true,
    bool showNotes = true,
    bool showPaymentMethod = true,
  }) async {
    final doc = pw.Document();

    // تحميل الخطوط العربية
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();
    final arabicFontLight = await PdfGoogleFonts.cairoLight();

    // تحميل الشعار
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/Hoor-icons.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // الشعار غير متاح
    }

    // تحديد حجم الورق
    final pageFormat = _getPageFormat(printSize);
    final margin = pw.EdgeInsets.all(_spacing[printSize]!['margin']!);
    final fonts = _fontSizes[printSize]!;
    final space = _spacing[printSize]!;

    final typeLabel = _getTypeLabel(invoice.type);
    final typeColor = _getTypeColor(invoice.type);

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        textDirection: pw.TextDirection.rtl,
        margin: margin,
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicFontBold,
        ),
        build: (context) {
          if (printSize == 'A4') {
            return _buildA4Invoice(
              invoice: invoice,
              items: items,
              customer: customer,
              supplier: supplier,
              fonts: fonts,
              space: space,
              arabicFont: arabicFont,
              arabicFontBold: arabicFontBold,
              arabicFontLight: arabicFontLight,
              logoImage: showLogo ? logoImage : null,
              typeLabel: typeLabel,
              typeColor: typeColor,
              showBarcode: showBarcode,
              showCustomerInfo: showCustomerInfo,
              showNotes: showNotes,
              showPaymentMethod: showPaymentMethod,
            );
          } else {
            return _buildThermalInvoice(
              invoice: invoice,
              items: items,
              customer: customer,
              supplier: supplier,
              fonts: fonts,
              space: space,
              arabicFont: arabicFont,
              arabicFontBold: arabicFontBold,
              arabicFontLight: arabicFontLight,
              typeLabel: typeLabel,
              typeColor: typeColor,
              is58mm: printSize == '58mm',
              showBarcode: showBarcode,
              showCustomerInfo: showCustomerInfo,
              showNotes: showNotes,
              showPaymentMethod: showPaymentMethod,
            );
          }
        },
      ),
    );

    return doc.save();
  }

  /// تصميم الفاتورة للطابعات الحرارية (58mm و 80mm)
  static pw.Widget _buildThermalInvoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
    required Map<String, double> fonts,
    required Map<String, double> space,
    required pw.Font arabicFont,
    required pw.Font arabicFontBold,
    required pw.Font arabicFontLight,
    required String typeLabel,
    required PdfColor typeColor,
    required bool is58mm,
    Customer? customer,
    Supplier? supplier,
    bool showBarcode = true,
    bool showCustomerInfo = true,
    bool showNotes = true,
    bool showPaymentMethod = true,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // ═══════════════════════════════════════════════════════════════
        // الترويسة
        // ═══════════════════════════════════════════════════════════════
        pw.Center(
          child: pw.Column(
            children: [
              // اسم المتجر
              pw.Text(
                'Hoor Manager',
                style: pw.TextStyle(
                  font: arabicFontBold,
                  fontSize: fonts['title']!,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: space['gap']! / 2),
              // نوع الفاتورة
              pw.Container(
                padding: pw.EdgeInsets.symmetric(
                  horizontal: space['padding']! * 2,
                  vertical: space['padding']! / 2,
                ),
                decoration: pw.BoxDecoration(
                  color: typeColor,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  typeLabel,
                  style: pw.TextStyle(
                    font: arabicFontBold,
                    fontSize: fonts['subtitle']!,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: space['gap']!),
        _thermalDivider(space['divider']!),

        // ═══════════════════════════════════════════════════════════════
        // معلومات الفاتورة
        // ═══════════════════════════════════════════════════════════════
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: space['gap']! / 2),
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'رقم: ${invoice.invoiceNumber}',
                    style: pw.TextStyle(
                        font: arabicFontBold, fontSize: fonts['body']!),
                  ),
                  pw.Text(
                    DateFormat('dd/MM/yyyy').format(invoice.invoiceDate),
                    style: pw.TextStyle(
                        font: arabicFont, fontSize: fonts['body']!),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    getPaymentMethodLabel(invoice.paymentMethod),
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: fonts['small']!,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    DateFormat('HH:mm').format(invoice.invoiceDate),
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: fonts['small']!,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // معلومات العميل/المورد
        // ═══════════════════════════════════════════════════════════════
        if (showCustomerInfo && (customer != null || supplier != null)) ...[
          _thermalDivider(space['divider']!, dashed: true),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(vertical: space['gap']! / 2),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      customer != null ? 'العميل: ' : 'المورد: ',
                      style: pw.TextStyle(
                          font: arabicFont, fontSize: fonts['small']!),
                    ),
                    pw.Text(
                      customer?.name ?? supplier?.name ?? '',
                      style: pw.TextStyle(
                          font: arabicFontBold, fontSize: fonts['body']!),
                    ),
                  ],
                ),
                if ((customer?.phone ?? supplier?.phone) != null)
                  pw.Text(
                    customer?.phone ?? supplier?.phone ?? '',
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: fonts['small']!,
                      color: PdfColors.grey600,
                    ),
                  ),
              ],
            ),
          ),
        ],

        _thermalDivider(space['divider']!),
        pw.SizedBox(height: space['gap']! / 2),

        // ═══════════════════════════════════════════════════════════════
        // رأس جدول المنتجات
        // ═══════════════════════════════════════════════════════════════
        pw.Container(
          padding: pw.EdgeInsets.symmetric(
            vertical: space['padding']! / 2,
            horizontal: space['padding']! / 2,
          ),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: is58mm ? 5 : 4,
                child: pw.Text(
                  'المنتج',
                  style: pw.TextStyle(
                      font: arabicFontBold, fontSize: fonts['small']!),
                ),
              ),
              pw.Expanded(
                flex: is58mm ? 2 : 2,
                child: pw.Text(
                  'الكمية',
                  style: pw.TextStyle(
                      font: arabicFontBold, fontSize: fonts['small']!),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              if (!is58mm)
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'السعر',
                    style: pw.TextStyle(
                        font: arabicFontBold, fontSize: fonts['small']!),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              pw.Expanded(
                flex: is58mm ? 3 : 2,
                child: pw.Text(
                  'الإجمالي',
                  style: pw.TextStyle(
                      font: arabicFontBold, fontSize: fonts['small']!),
                  textAlign: pw.TextAlign.left,
                ),
              ),
            ],
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // المنتجات
        // ═══════════════════════════════════════════════════════════════
        ...items.map((item) => pw.Container(
              padding: pw.EdgeInsets.symmetric(
                vertical: space['gap']! / 2,
                horizontal: space['padding']! / 2,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.3),
                ),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: is58mm ? 5 : 4,
                    child: pw.Text(
                      item.productName,
                      style: pw.TextStyle(
                          font: arabicFont, fontSize: fonts['body']!),
                      maxLines: 2,
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                  pw.Expanded(
                    flex: is58mm ? 2 : 2,
                    child: pw.Text(
                      '${item.quantity}',
                      style: pw.TextStyle(
                          font: arabicFont, fontSize: fonts['body']!),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  if (!is58mm)
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        _formatPrice(item.unitPrice),
                        style: pw.TextStyle(
                            font: arabicFont, fontSize: fonts['body']!),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  pw.Expanded(
                    flex: is58mm ? 3 : 2,
                    child: pw.Text(
                      _formatPrice(item.total),
                      style: pw.TextStyle(
                          font: arabicFontBold, fontSize: fonts['body']!),
                      textAlign: pw.TextAlign.left,
                    ),
                  ),
                ],
              ),
            )),

        pw.SizedBox(height: space['gap']!),
        _thermalDivider(space['divider']! * 2),

        // ═══════════════════════════════════════════════════════════════
        // الإجماليات
        // ═══════════════════════════════════════════════════════════════
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: space['gap']! / 2),
          child: pw.Column(
            children: [
              if (invoice.discountAmount > 0) ...[
                _thermalSummaryRow(
                  arabicFont,
                  fonts['body']!,
                  'المجموع الفرعي',
                  '${_formatPrice(invoice.subtotal)} ل.س',
                ),
                pw.SizedBox(height: 2),
                _thermalSummaryRow(
                  arabicFont,
                  fonts['body']!,
                  'الخصم',
                  '- ${_formatPrice(invoice.discountAmount)} ل.س',
                  valueColor: PdfColors.red700,
                ),
                pw.SizedBox(height: space['gap']! / 2),
              ],

              // الإجمالي النهائي
              pw.Container(
                padding: pw.EdgeInsets.symmetric(
                  horizontal: space['padding']!,
                  vertical: space['padding']!,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey900,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'الإجمالي',
                      style: pw.TextStyle(
                        font: arabicFontBold,
                        fontSize: fonts['total']!,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      '${_formatPrice(invoice.total)} ل.س',
                      style: pw.TextStyle(
                        font: arabicFontBold,
                        fontSize: fonts['total']!,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: space['gap']!),
        _thermalDivider(space['divider']!, dashed: true),

        // ═══════════════════════════════════════════════════════════════
        // الباركود
        // ═══════════════════════════════════════════════════════════════
        if (showBarcode) ...[
          pw.SizedBox(height: space['gap']!),
          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: invoice.invoiceNumber,
              width: is58mm ? 120 : 160,
              height: is58mm ? 35 : 45,
              drawText: true,
              textStyle: pw.TextStyle(
                font: arabicFont,
                fontSize: fonts['small']!,
              ),
            ),
          ),
          pw.SizedBox(height: space['gap']!),
          _thermalDivider(space['divider']!, dashed: true),
        ],

        // ═══════════════════════════════════════════════════════════════
        // التذييل
        // ═══════════════════════════════════════════════════════════════
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: space['gap']!),
          child: pw.Column(
            children: [
              pw.Center(
                child: pw.Text(
                  'شكراً لتعاملكم معنا',
                  style: pw.TextStyle(
                    font: arabicFontBold,
                    fontSize: fonts['subtitle']!,
                  ),
                ),
              ),
              pw.SizedBox(height: space['gap']! / 2),
              pw.Center(
                child: pw.Text(
                  '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(
                    font: arabicFontLight,
                    fontSize: fonts['small']!,
                    color: PdfColors.grey500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// تصميم الفاتورة لـ A4
  static pw.Widget _buildA4Invoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
    required Map<String, double> fonts,
    required Map<String, double> space,
    required pw.Font arabicFont,
    required pw.Font arabicFontBold,
    required pw.Font arabicFontLight,
    required String typeLabel,
    required PdfColor typeColor,
    pw.MemoryImage? logoImage,
    Customer? customer,
    Supplier? supplier,
    bool showBarcode = true,
    bool showCustomerInfo = true,
    bool showNotes = true,
    bool showPaymentMethod = true,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // ═══════════════════════════════════════════════════════════════
        // الترويسة
        // ═══════════════════════════════════════════════════════════════
        pw.Container(
          padding: pw.EdgeInsets.all(space['padding']! * 1.5),
          decoration: pw.BoxDecoration(
            gradient: const pw.LinearGradient(
              colors: [PdfColors.blue900, PdfColors.blue700],
              begin: pw.Alignment.topRight,
              end: pw.Alignment.bottomLeft,
            ),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Hoor Manager',
                    style: pw.TextStyle(
                      font: arabicFontBold,
                      fontSize: fonts['title']! + 4,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'نظام إدارة المبيعات والمخزون',
                    style: pw.TextStyle(
                      font: arabicFontLight,
                      fontSize: fonts['small']! + 2,
                      color: PdfColors.blue100,
                    ),
                  ),
                ],
              ),
              if (logoImage != null)
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(30),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Image(logoImage),
                )
              else
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(30),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'H',
                      style: pw.TextStyle(
                        font: arabicFontBold,
                        fontSize: 32,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        pw.SizedBox(height: space['gap']! * 2),

        // ═══════════════════════════════════════════════════════════════
        // نوع الفاتورة ورقمها
        // ═══════════════════════════════════════════════════════════════
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Container(
              padding: pw.EdgeInsets.symmetric(
                horizontal: space['padding']! * 1.5,
                vertical: space['padding']! / 1.5,
              ),
              decoration: pw.BoxDecoration(
                color: typeColor,
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Text(
                typeLabel,
                style: pw.TextStyle(
                  font: arabicFontBold,
                  fontSize: fonts['body']! + 2,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(space['padding']!),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'رقم الفاتورة',
                    style: pw.TextStyle(
                      font: arabicFontLight,
                      fontSize: fonts['small']!,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    invoice.invoiceNumber,
                    style: pw.TextStyle(
                      font: arabicFontBold,
                      fontSize: fonts['header']!,
                      color: PdfColors.blue900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: space['gap']! * 1.5),

        // ═══════════════════════════════════════════════════════════════
        // معلومات الفاتورة
        // ═══════════════════════════════════════════════════════════════
        pw.Container(
          padding: pw.EdgeInsets.all(space['padding']!),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _a4InfoColumn(arabicFontBold, arabicFontLight, fonts, 'التاريخ',
                  DateFormat('dd/MM/yyyy').format(invoice.invoiceDate)),
              _a4VerticalDivider(),
              _a4InfoColumn(arabicFontBold, arabicFontLight, fonts, 'الوقت',
                  DateFormat('HH:mm').format(invoice.invoiceDate)),
              _a4VerticalDivider(),
              _a4InfoColumn(arabicFontBold, arabicFontLight, fonts,
                  'طريقة الدفع', getPaymentMethodLabel(invoice.paymentMethod)),
              _a4VerticalDivider(),
              _a4InfoColumn(arabicFontBold, arabicFontLight, fonts, 'الحالة',
                  invoice.status == 'completed' ? 'مكتملة' : 'معلقة'),
            ],
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // معلومات العميل/المورد
        // ═══════════════════════════════════════════════════════════════
        if (showCustomerInfo && (customer != null || supplier != null)) ...[
          pw.SizedBox(height: space['gap']!),
          pw.Container(
            padding: pw.EdgeInsets.all(space['padding']!),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Icon(
                    customer != null
                        ? const pw.IconData(0xe7fd)
                        : const pw.IconData(0xe0af),
                    size: 24,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(width: space['gap']!),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        customer != null ? 'معلومات العميل' : 'معلومات المورد',
                        style: pw.TextStyle(
                          font: arabicFontLight,
                          fontSize: fonts['small']!,
                          color: PdfColors.blue600,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        customer?.name ?? supplier?.name ?? '',
                        style: pw.TextStyle(
                          font: arabicFontBold,
                          fontSize: fonts['header']! - 2,
                          color: PdfColors.blue900,
                        ),
                      ),
                      if ((customer?.phone ?? supplier?.phone) != null)
                        pw.Text(
                          customer?.phone ?? supplier?.phone ?? '',
                          style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: fonts['body']! - 1,
                            color: PdfColors.grey700,
                          ),
                        ),
                    ],
                  ),
                ),
                if ((customer?.address ?? supplier?.address) != null)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'العنوان',
                        style: pw.TextStyle(
                          font: arabicFontLight,
                          fontSize: fonts['small']!,
                          color: PdfColors.blue600,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        customer?.address ?? supplier?.address ?? '',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: fonts['body']! - 1,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],

        pw.SizedBox(height: space['gap']! * 2),

        // ═══════════════════════════════════════════════════════════════
        // جدول المنتجات
        // ═══════════════════════════════════════════════════════════════
        pw.Container(
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            children: [
              // عنوان الجدول
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(space['padding']! / 1.5),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(9),
                    topRight: pw.Radius.circular(9),
                  ),
                ),
                child: pw.Text(
                  'تفاصيل المنتجات',
                  style: pw.TextStyle(
                    font: arabicFontBold,
                    fontSize: fonts['body']!,
                    color: PdfColors.grey800,
                  ),
                ),
              ),

              // رأس الجدول
              pw.Container(
                padding: pw.EdgeInsets.symmetric(
                  horizontal: space['padding']!,
                  vertical: space['padding']! / 1.5,
                ),
                decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('#',
                          style: pw.TextStyle(
                            font: arabicFontBold,
                            fontSize: fonts['body']!,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('اسم المنتج',
                          style: pw.TextStyle(
                            font: arabicFontBold,
                            fontSize: fonts['body']!,
                            color: PdfColors.white,
                          )),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('الكمية',
                          style: pw.TextStyle(
                            font: arabicFontBold,
                            fontSize: fonts['body']!,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('السعر',
                          style: pw.TextStyle(
                            font: arabicFontBold,
                            fontSize: fonts['body']!,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('الإجمالي',
                          style: pw.TextStyle(
                            font: arabicFontBold,
                            fontSize: fonts['body']!,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                  ],
                ),
              ),

              // صفوف المنتجات
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isEven = index % 2 == 0;
                final isLast = index == items.length - 1;

                return pw.Container(
                  padding: pw.EdgeInsets.symmetric(
                    horizontal: space['padding']!,
                    vertical: space['padding']! / 1.5,
                  ),
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : PdfColors.grey50,
                    borderRadius: isLast
                        ? const pw.BorderRadius.only(
                            bottomLeft: pw.Radius.circular(9),
                            bottomRight: pw.Radius.circular(9),
                          )
                        : null,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue100,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text('${index + 1}',
                              style: pw.TextStyle(
                                font: arabicFontBold,
                                fontSize: fonts['small']!,
                                color: PdfColors.blue900,
                              ),
                              textAlign: pw.TextAlign.center),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        flex: 5,
                        child: pw.Text(item.productName,
                            style: pw.TextStyle(
                                font: arabicFont, fontSize: fonts['body']!)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('${item.quantity}',
                            style: pw.TextStyle(
                                font: arabicFontBold, fontSize: fonts['body']!),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(_formatPrice(item.unitPrice),
                            style: pw.TextStyle(
                                font: arabicFont, fontSize: fonts['body']!),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(_formatPrice(item.total),
                            style: pw.TextStyle(
                              font: arabicFontBold,
                              fontSize: fonts['body']!,
                              color: PdfColors.blue900,
                            ),
                            textAlign: pw.TextAlign.center),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        pw.SizedBox(height: space['gap']! * 2),

        // ═══════════════════════════════════════════════════════════════
        // الإجماليات
        // ═══════════════════════════════════════════════════════════════
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ملاحظات
            if (invoice.notes != null && invoice.notes!.isNotEmpty)
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: pw.EdgeInsets.all(space['padding']!),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ملاحظات',
                        style: pw.TextStyle(
                          font: arabicFontBold,
                          fontSize: fonts['small']!,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.notes!,
                        style: pw.TextStyle(
                            font: arabicFont, fontSize: fonts['body']!),
                      ),
                    ],
                  ),
                ),
              )
            else
              pw.Expanded(flex: 3, child: pw.SizedBox()),

            pw.SizedBox(width: space['gap']!),

            // المجاميع
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                padding: pw.EdgeInsets.all(space['padding']!),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  children: [
                    _a4SummaryRow(arabicFont, fonts, 'المجموع الفرعي',
                        '${_formatPrice(invoice.subtotal)} ل.س'),
                    pw.SizedBox(height: 8),
                    if (invoice.discountAmount > 0) ...[
                      _a4SummaryRow(arabicFont, fonts, 'الخصم',
                          '- ${_formatPrice(invoice.discountAmount)} ل.س',
                          valueColor: PdfColors.red700),
                      pw.SizedBox(height: 8),
                    ],
                    pw.Container(height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('الإجمالي',
                            style: pw.TextStyle(
                              font: arabicFontBold,
                              fontSize: fonts['header']!,
                            )),
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(
                            horizontal: space['padding']!,
                            vertical: space['padding']! / 2,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue900,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text('${_formatPrice(invoice.total)} ل.س',
                              style: pw.TextStyle(
                                font: arabicFontBold,
                                fontSize: fonts['header']!,
                                color: PdfColors.white,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        pw.Spacer(),

        // ═══════════════════════════════════════════════════════════════
        // الباركود
        // ═══════════════════════════════════════════════════════════════
        if (showBarcode) ...[
          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: invoice.invoiceNumber,
              width: 200,
              height: 50,
              drawText: true,
              textStyle: pw.TextStyle(
                font: arabicFont,
                fontSize: fonts['small']!,
              ),
            ),
          ),
          pw.SizedBox(height: space['gap']!),
        ],

        // ═══════════════════════════════════════════════════════════════
        // التذييل
        // ═══════════════════════════════════════════════════════════════
        pw.Container(
          padding: pw.EdgeInsets.only(top: space['gap']! * 1.5),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 2)),
          ),
          child: pw.Column(
            children: [
              pw.Container(
                padding: pw.EdgeInsets.symmetric(
                  horizontal: space['padding']! * 2,
                  vertical: space['padding']! / 1.5,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  'شكراً لتعاملكم معنا',
                  style: pw.TextStyle(
                    font: arabicFontBold,
                    fontSize: fonts['body']! + 2,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(height: space['gap']!),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('تم الإنشاء بواسطة ',
                      style: pw.TextStyle(
                        font: arabicFontLight,
                        fontSize: fonts['small']!,
                        color: PdfColors.grey500,
                      )),
                  pw.Text('Hoor Manager',
                      style: pw.TextStyle(
                        font: arabicFontBold,
                        fontSize: fonts['small']!,
                        color: PdfColors.blue700,
                      )),
                  pw.Text(' | ',
                      style: pw.TextStyle(
                        font: arabicFontLight,
                        fontSize: fonts['small']!,
                        color: PdfColors.grey400,
                      )),
                  pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                      style: pw.TextStyle(
                        font: arabicFontLight,
                        fontSize: fonts['small']!,
                        color: PdfColors.grey500,
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // دوال مساعدة
  // ═══════════════════════════════════════════════════════════════════════════

  static PdfPageFormat _getPageFormat(String printSize) {
    switch (printSize) {
      case '58mm':
        return PdfPageFormat.roll57;
      case 'A4':
        return PdfPageFormat.a4;
      default:
        return PdfPageFormat.roll80;
    }
  }

  static String _getTypeLabel(String type) {
    switch (type) {
      case 'sale':
        return 'فاتورة مبيعات';
      case 'purchase':
        return 'فاتورة مشتريات';
      case 'sale_return':
        return 'مرتجع مبيعات';
      case 'purchase_return':
        return 'مرتجع مشتريات';
      case 'opening_balance':
        return 'فاتورة أول المدة';
      default:
        return 'فاتورة';
    }
  }

  static PdfColor _getTypeColor(String type) {
    switch (type) {
      case 'sale':
        return PdfColors.green700;
      case 'purchase':
        return PdfColors.blue700;
      case 'sale_return':
        return PdfColors.orange700;
      case 'purchase_return':
        return PdfColors.orange700;
      case 'opening_balance':
        return PdfColors.purple700;
      default:
        return PdfColors.blue700;
    }
  }

  static String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toStringAsFixed(0);
    }
    String formatted = price.toStringAsFixed(2);
    if (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }

  static pw.Widget _thermalDivider(double thickness, {bool dashed = false}) {
    if (dashed) {
      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          children: List.generate(
            40,
            (index) => pw.Expanded(
              child: pw.Container(
                height: thickness,
                margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                color: index % 2 == 0 ? PdfColors.grey400 : PdfColors.white,
              ),
            ),
          ),
        ),
      );
    }
    return pw.Divider(thickness: thickness, color: PdfColors.grey400);
  }

  static pw.Widget _thermalSummaryRow(
    pw.Font font,
    double fontSize,
    String label,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: fontSize)),
        pw.Text(value,
            style: pw.TextStyle(
              font: font,
              fontSize: fontSize,
              color: valueColor,
            )),
      ],
    );
  }

  static pw.Widget _a4InfoColumn(
    pw.Font boldFont,
    pw.Font lightFont,
    Map<String, double> fonts,
    String label,
    String value,
  ) {
    return pw.Column(
      children: [
        pw.Text(label,
            style: pw.TextStyle(
              font: lightFont,
              fontSize: fonts['small']!,
              color: PdfColors.grey600,
            )),
        pw.SizedBox(height: 4),
        pw.Text(value,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: fonts['body']!,
              color: PdfColors.grey900,
            )),
      ],
    );
  }

  static pw.Widget _a4VerticalDivider() {
    return pw.Container(width: 1, height: 35, color: PdfColors.grey300);
  }

  static pw.Widget _a4SummaryRow(
    pw.Font font,
    Map<String, double> fonts,
    String label,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
              font: font,
              fontSize: fonts['body']!,
              color: PdfColors.grey700,
            )),
        pw.Text(value,
            style: pw.TextStyle(
              font: font,
              fontSize: fonts['body']!,
              color: valueColor,
            )),
      ],
    );
  }
}
