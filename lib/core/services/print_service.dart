import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';

/// خدمة الطباعة
class PrintService {
  pw.Font? _arabicFont;

  /// تهيئة الخط العربي
  Future<void> _initFont() async {
    if (_arabicFont != null) return;

    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      _arabicFont = pw.Font.ttf(fontData);
    } catch (e) {
      // استخدام الخط الافتراضي في حالة الفشل
    }
  }

  /// طباعة فاتورة
  Future<bool> printInvoice({
    required String invoiceNumber,
    required DateTime date,
    required String? customerName,
    required List<PrintInvoiceItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required double paidAmount,
    required double remainingAmount,
    String? businessName,
    String? businessPhone,
    String? businessAddress,
    String? notes,
  }) async {
    await _initFont();

    final pdf = pw.Document();

    final textStyle = pw.TextStyle(font: _arabicFont, fontSize: 10);
    final titleStyle = pw.TextStyle(
        font: _arabicFont, fontSize: 14, fontWeight: pw.FontWeight.bold);
    final headerStyle = pw.TextStyle(
        font: _arabicFont, fontSize: 12, fontWeight: pw.FontWeight.bold);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // رأس الفاتورة
              if (businessName != null)
                pw.Center(
                  child: pw.Text(businessName, style: titleStyle),
                ),
              if (businessPhone != null)
                pw.Center(
                  child: pw.Text(businessPhone, style: textStyle),
                ),
              if (businessAddress != null)
                pw.Center(
                  child: pw.Text(businessAddress, style: textStyle),
                ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              // معلومات الفاتورة
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('رقم الفاتورة:', style: textStyle),
                  pw.Text(invoiceNumber, style: textStyle),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('التاريخ:', style: textStyle),
                  pw.Text(_formatDate(date), style: textStyle),
                ],
              ),
              if (customerName != null)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('العميل:', style: textStyle),
                    pw.Text(customerName, style: textStyle),
                  ],
                ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              // رأس الجدول
              pw.Row(
                children: [
                  pw.Expanded(
                      flex: 3, child: pw.Text('المنتج', style: headerStyle)),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text('الكمية',
                          style: headerStyle, textAlign: pw.TextAlign.center)),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('السعر',
                          style: headerStyle, textAlign: pw.TextAlign.left)),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('الإجمالي',
                          style: headerStyle, textAlign: pw.TextAlign.left)),
                ],
              ),
              pw.Divider(),

              // بنود الفاتورة
              ...items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                            flex: 3,
                            child: pw.Text(item.name, style: textStyle)),
                        pw.Expanded(
                            flex: 1,
                            child: pw.Text('${item.quantity.toInt()}',
                                style: textStyle,
                                textAlign: pw.TextAlign.center)),
                        pw.Expanded(
                            flex: 2,
                            child: pw.Text(_formatPrice(item.price),
                                style: textStyle,
                                textAlign: pw.TextAlign.left)),
                        pw.Expanded(
                            flex: 2,
                            child: pw.Text(_formatPrice(item.total),
                                style: textStyle,
                                textAlign: pw.TextAlign.left)),
                      ],
                    ),
                  )),

              pw.Divider(),

              // الملخص
              _buildSummaryRow('المجموع', subtotal, textStyle),
              if (discount > 0) _buildSummaryRow('الخصم', -discount, textStyle),
              if (tax > 0) _buildSummaryRow('الضريبة', tax, textStyle),
              pw.Divider(),
              _buildSummaryRow('الإجمالي', total, headerStyle),
              _buildSummaryRow('المدفوع', paidAmount, textStyle),
              if (remainingAmount > 0)
                _buildSummaryRow('المتبقي', remainingAmount, textStyle),

              pw.SizedBox(height: 10),

              // الملاحظات
              if (notes != null && notes.isNotEmpty) ...[
                pw.Text('ملاحظات:', style: textStyle),
                pw.Text(notes, style: textStyle),
                pw.SizedBox(height: 10),
              ],

              // تذييل
              pw.Divider(),
              pw.Center(
                child: pw.Text('شكراً لتسوقكم معنا', style: textStyle),
              ),
              pw.Center(
                child: pw.Text(AppConfig.appNameAr, style: textStyle),
              ),
            ],
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'فاتورة_$invoiceNumber',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// طباعة باركود
  Future<bool> printBarcode({
    required String barcode,
    required String? productName,
    int copies = 1,
    bool showName = false,
    bool showPrice = false,
    double? price,
  }) async {
    final pdf = pw.Document();

    for (var i = 0; i < copies; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat:
              const PdfPageFormat(50 * PdfPageFormat.mm, 25 * PdfPageFormat.mm),
          build: (context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: barcode,
                  width: 45 * PdfPageFormat.mm,
                  height: 15 * PdfPageFormat.mm,
                  textStyle: const pw.TextStyle(fontSize: 8),
                ),
                if (showName && productName != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    productName,
                    style: pw.TextStyle(font: _arabicFont, fontSize: 6),
                    maxLines: 1,
                  ),
                ],
                if (showPrice && price != null) ...[
                  pw.SizedBox(height: 1),
                  pw.Text(
                    '${_formatPrice(price)} ${AppConfig.defaultCurrency}',
                    style: pw.TextStyle(
                        font: _arabicFont,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ],
            );
          },
        ),
      );
    }

    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'barcode_$barcode',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// تصدير الفاتورة كـ PDF
  Future<Uint8List> generateInvoicePdf({
    required String invoiceNumber,
    required DateTime date,
    required String? customerName,
    required List<PrintInvoiceItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required double paidAmount,
    required double remainingAmount,
    String? businessName,
    String? notes,
  }) async {
    await _initFont();

    final pdf = pw.Document();

    final textStyle = pw.TextStyle(font: _arabicFont, fontSize: 12);
    final titleStyle = pw.TextStyle(
        font: _arabicFont, fontSize: 18, fontWeight: pw.FontWeight.bold);
    final headerStyle = pw.TextStyle(
        font: _arabicFont, fontSize: 12, fontWeight: pw.FontWeight.bold);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // رأس الفاتورة
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(businessName ?? AppConfig.appNameAr,
                          style: titleStyle),
                      pw.SizedBox(height: 5),
                      pw.Text('فاتورة مبيعات', style: headerStyle),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('رقم الفاتورة: $invoiceNumber', style: textStyle),
                      pw.Text('التاريخ: ${_formatDate(date)}',
                          style: textStyle),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // معلومات العميل
              if (customerName != null)
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Text('العميل: $customerName', style: textStyle),
                ),

              pw.SizedBox(height: 20),

              // جدول البنود
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // رأس الجدول
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('المنتج', style: headerStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('الكمية',
                            style: headerStyle, textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('السعر',
                            style: headerStyle, textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('الإجمالي',
                            style: headerStyle, textAlign: pw.TextAlign.center),
                      ),
                    ],
                  ),
                  // البنود
                  ...items.map((item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(item.name, style: textStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('${item.quantity.toInt()}',
                                style: textStyle,
                                textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(_formatPrice(item.price),
                                style: textStyle,
                                textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(_formatPrice(item.total),
                                style: textStyle,
                                textAlign: pw.TextAlign.center),
                          ),
                        ],
                      )),
                ],
              ),

              pw.SizedBox(height: 20),

              // الملخص
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      _buildSummaryRow('المجموع', subtotal, textStyle),
                      if (discount > 0)
                        _buildSummaryRow('الخصم', -discount, textStyle),
                      if (tax > 0) _buildSummaryRow('الضريبة', tax, textStyle),
                      pw.Divider(),
                      _buildSummaryRow('الإجمالي', total, headerStyle),
                      _buildSummaryRow('المدفوع', paidAmount, textStyle),
                      if (remainingAmount > 0)
                        _buildSummaryRow('المتبقي', remainingAmount, textStyle),
                    ],
                  ),
                ),
              ),

              // الملاحظات
              if (notes != null && notes.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text('ملاحظات:', style: headerStyle),
                pw.Text(notes, style: textStyle),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSummaryRow(String label, double value, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(_formatPrice(value), style: style),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(AppConfig.defaultDecimalPlaces);
  }
}

/// بند فاتورة للطباعة
class PrintInvoiceItem {
  final String name;
  final double quantity;
  final double price;
  final double total;

  PrintInvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });
}
