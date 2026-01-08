import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PDF Fonts - خطوط PDF العربية (Cairo)
/// ═══════════════════════════════════════════════════════════════════════════
class PdfFonts {
  static pw.Font? _regular;
  static pw.Font? _bold;
  static bool _initialized = false;
  static String _loadedFrom = 'none';

  /// تهيئة الخطوط العربية - يجب استدعاؤها قبل إنشاء PDF
  static Future<void> init() async {
    if (_initialized && _regular != null && _bold != null) return;

    // محاولة 1: تحميل من Assets المحلية
    try {
      developer.log('PdfFonts: جاري تحميل خط Cairo من Assets...');
      final fontData = await rootBundle.load('assets/fonts/Cairo-Variable.ttf');
      _regular = pw.Font.ttf(fontData);
      _bold = pw.Font.ttf(fontData);
      _initialized = true;
      _loadedFrom = 'assets';
      developer.log('PdfFonts: ✅ تم تحميل خط Cairo من Assets بنجاح');
      return;
    } catch (e) {
      developer.log('PdfFonts: ⚠️ فشل تحميل من Assets: $e');
    }

    // محاولة 2: تحميل من Google Fonts
    try {
      developer.log('PdfFonts: جاري تحميل خط Cairo من Google Fonts...');
      _regular = await PdfGoogleFonts.cairoRegular();
      _bold = await PdfGoogleFonts.cairoBold();
      _initialized = true;
      _loadedFrom = 'google_fonts';
      developer.log('PdfFonts: ✅ تم تحميل خط Cairo من Google Fonts بنجاح');
      return;
    } catch (e) {
      developer.log('PdfFonts: ⚠️ فشل تحميل من Google Fonts: $e');
    }

    // محاولة 3: تحميل Noto Sans Arabic من Google Fonts
    try {
      developer.log('PdfFonts: جاري تحميل خط Noto Sans Arabic...');
      _regular = await PdfGoogleFonts.notoSansArabicRegular();
      _bold = await PdfGoogleFonts.notoSansArabicBold();
      _initialized = true;
      _loadedFrom = 'noto_sans_arabic';
      developer.log('PdfFonts: ✅ تم تحميل خط Noto Sans Arabic بنجاح');
      return;
    } catch (e) {
      developer.log('PdfFonts: ⚠️ فشل تحميل Noto Sans Arabic: $e');
    }

    // Fallback: استخدام Helvetica (لن يدعم العربية!)
    developer
        .log('PdfFonts: ❌ فشل تحميل جميع الخطوط العربية! استخدام Helvetica');
    _regular = pw.Font.helvetica();
    _bold = pw.Font.helveticaBold();
    _initialized = true;
    _loadedFrom = 'helvetica_fallback';
  }

  /// الخط العادي
  static pw.Font get regular {
    if (!_initialized || _regular == null) {
      developer.log('PdfFonts: ⚠️ الخطوط غير مهيأة! يرجى استدعاء init() أولاً');
      return pw.Font.helvetica();
    }
    return _regular!;
  }

  /// الخط العريض
  static pw.Font get bold {
    if (!_initialized || _bold == null) {
      developer.log('PdfFonts: ⚠️ الخطوط غير مهيأة! يرجى استدعاء init() أولاً');
      return pw.Font.helveticaBold();
    }
    return _bold!;
  }

  /// معرفة مصدر الخط المحمّل
  static String get loadedFrom => _loadedFrom;

  /// إعادة تعيين حالة التهيئة (للاختبار)
  static void reset() {
    _initialized = false;
    _regular = null;
    _bold = null;
    _loadedFrom = 'none';
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// PDF Sizes - أحجام PDF
/// ═══════════════════════════════════════════════════════════════════════════
class PdfSizes {
  // A4 dimensions
  static const a4Width = 595.0;
  static const a4Height = 842.0;

  // Thermal receipt sizes
  static const thermalWidth80mm = 226.0; // 80mm
  static const thermalWidth58mm = 164.0; // 58mm

  // Margins
  static const marginSmall = 10.0;
  static const marginMedium = 20.0;
  static const marginLarge = 30.0;

  // Font sizes
  static const fontSizeXSmall = 8.0;
  static const fontSizeSmall = 10.0;
  static const fontSizeMedium = 12.0;
  static const fontSizeLarge = 14.0;
  static const fontSizeXLarge = 16.0;
  static const fontSizeTitle = 20.0;
  static const fontSizeHeader = 24.0;

  // Thermal receipt font sizes
  static const fontSizeThermal = 9.0;
  static const fontSizeThermalSmall = 7.0;
  static const fontSizeThermalLarge = 11.0;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// PDF Styles - أنماط PDF المشتركة
/// ═══════════════════════════════════════════════════════════════════════════
class PdfStyles {
  static pw.TextStyle title() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: PdfSizes.fontSizeHeader,
        color: PdfColors.grey800,
      );

  static pw.TextStyle subtitle() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: PdfSizes.fontSizeTitle,
        color: PdfColors.grey700,
      );

  static pw.TextStyle sectionHeader() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: PdfSizes.fontSizeLarge,
        color: PdfColors.grey800,
      );

  static pw.TextStyle bodyBold() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: PdfSizes.fontSizeMedium,
        color: PdfColors.grey800,
      );

  static pw.TextStyle body() => pw.TextStyle(
        font: PdfFonts.regular,
        fontSize: PdfSizes.fontSizeMedium,
        color: PdfColors.grey800,
      );

  static pw.TextStyle bodySmall() => pw.TextStyle(
        font: PdfFonts.regular,
        fontSize: PdfSizes.fontSizeSmall,
        color: PdfColors.grey700,
      );

  static pw.TextStyle caption() => pw.TextStyle(
        font: PdfFonts.regular,
        fontSize: PdfSizes.fontSizeXSmall,
        color: PdfColors.grey600,
      );

  static pw.TextStyle tableHeader() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: PdfSizes.fontSizeSmall,
        color: PdfColors.white,
      );

  static pw.TextStyle tableCell() => pw.TextStyle(
        font: PdfFonts.regular,
        fontSize: PdfSizes.fontSizeSmall,
        color: PdfColors.grey800,
      );

  static pw.TextStyle tableCellBold() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: PdfSizes.fontSizeSmall,
        color: PdfColors.grey800,
      );

  static pw.TextStyle success() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: PdfSizes.fontSizeMedium,
        color: PdfColors.green700,
      );

  static pw.TextStyle error() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: PdfSizes.fontSizeMedium,
        color: PdfColors.red700,
      );

  static pw.TextStyle warning() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: PdfSizes.fontSizeMedium,
        color: PdfColors.orange700,
      );
}

/// ═══════════════════════════════════════════════════════════════════════════
/// PDF Theme - ثيم PDF الموحد
/// ═══════════════════════════════════════════════════════════════════════════
class PdfTheme {
  static pw.ThemeData create() {
    return pw.ThemeData.withFont(
      base: PdfFonts.regular,
      bold: PdfFonts.bold,
    );
  }

  /// إنشاء رأس الصفحة
  static pw.Widget header({
    required String title,
    String? subtitle,
    String? date,
    PdfColor color = AppPdfColors.primary,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(PdfSizes.marginMedium),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: PdfSizes.fontSizeHeader,
              color: PdfColors.white,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              subtitle,
              style: pw.TextStyle(
                font: PdfFonts.regular,
                fontSize: PdfSizes.fontSizeMedium,
                color: PdfColors.white,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
          if (date != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              date,
              style: pw.TextStyle(
                font: PdfFonts.regular,
                fontSize: PdfSizes.fontSizeSmall,
                color: PdfColors.white,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
        ],
      ),
    );
  }

  /// إنشاء صندوق ملخص
  static pw.Widget summaryBox({
    required List<MapEntry<String, String>> items,
    PdfColor borderColor = AppPdfColors.primary,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(PdfSizes.marginSmall),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          return pw.Expanded(
            child: pw.Column(
              children: [
                pw.Text(
                  item.key,
                  style: PdfStyles.bodySmall(),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  item.value,
                  style: PdfStyles.bodyBold(),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// إنشاء تذييل الصفحة
  static pw.Widget footer({String? note}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        vertical: PdfSizes.marginSmall,
      ),
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          if (note != null)
            pw.Text(
              note,
              style: PdfStyles.caption(),
              textDirection: pw.TextDirection.rtl,
            ),
        ],
      ),
    );
  }

  /// إنشاء جدول موحد
  static pw.Widget table({
    required List<String> headers,
    required List<List<String>> data,
    List<int>? columnWidths,
    PdfColor headerColor = AppPdfColors.primary,
  }) {
    final headerStyle = pw.TextStyle(
      font: PdfFonts.bold,
      fontSize: PdfSizes.fontSizeSmall,
      color: PdfColors.white,
    );

    final cellStyle = pw.TextStyle(
      font: PdfFonts.regular,
      fontSize: PdfSizes.fontSizeSmall,
      color: PdfColors.grey800,
    );

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: headerStyle,
      cellStyle: cellStyle,
      headerDecoration: pw.BoxDecoration(color: headerColor),
      cellAlignments: {
        for (int i = 0; i < headers.length; i++) i: pw.Alignment.centerRight,
      },
      cellPadding: const pw.EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      cellHeight: 30,
      headerHeight: 35,
    );
  }

  /// إنشاء فاصل بعنوان
  static pw.Widget sectionDivider(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Row(
          children: [
            pw.Expanded(child: pw.Divider(color: PdfColors.grey300)),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8),
              child: pw.Text(
                title,
                style: PdfStyles.sectionHeader(),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.Expanded(child: pw.Divider(color: PdfColors.grey300)),
          ],
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  /// إنشاء صندوق معلومات
  static pw.Widget infoBox({
    required String label,
    required String value,
    PdfColor? backgroundColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: backgroundColor ?? PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            label,
            style: PdfStyles.caption(),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: PdfStyles.bodyBold(),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Pdf Print Size - حجم الطباعة لـ PDF
/// ═══════════════════════════════════════════════════════════════════════════
enum PdfPrintSize {
  a4,
  thermal80mm,
  thermal58mm;

  PdfPageFormat get pageFormat {
    switch (this) {
      case PdfPrintSize.a4:
        return PdfPageFormat.a4;
      case PdfPrintSize.thermal80mm:
        return PdfPageFormat(
          PdfSizes.thermalWidth80mm,
          double.infinity,
          marginAll: 10,
        );
      case PdfPrintSize.thermal58mm:
        return PdfPageFormat(
          PdfSizes.thermalWidth58mm,
          double.infinity,
          marginAll: 5,
        );
    }
  }

  String get label {
    switch (this) {
      case PdfPrintSize.a4:
        return 'A4';
      case PdfPrintSize.thermal80mm:
        return '80mm';
      case PdfPrintSize.thermal58mm:
        return '58mm';
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// App PDF Colors - ألوان PDF للتطبيق (المصدر الوحيد للهوية البصرية)
/// ═══════════════════════════════════════════════════════════════════════════
class AppPdfColors {
  // ═══════ الألوان الأساسية ═══════
  static const primary = PdfColor.fromInt(0xFF2E7D32);
  static const primaryLight = PdfColor.fromInt(0xFF4CAF50);
  static const secondary = PdfColor.fromInt(0xFF757575);
  static const success = PdfColor.fromInt(0xFF4CAF50);
  static const warning = PdfColor.fromInt(0xFFFF9800);
  static const error = PdfColor.fromInt(0xFFF44336);
  static const info = PdfColor.fromInt(0xFF2196F3);

  // ═══════ ألوان الجداول ═══════
  static const tableBorder = PdfColors.grey300;
  static const tableHeader = PdfColor.fromInt(0xFF2E7D32);
  static const tableRowEven = PdfColors.grey50;
  static const tableRowOdd = PdfColors.white;

  // ═══════ ألوان النصوص ═══════
  static const textPrimary = PdfColors.grey800;
  static const textSecondary = PdfColors.grey700;
  static const textMuted = PdfColors.grey600;
  static const textLight = PdfColors.grey500;
  static const textWhite = PdfColors.white;

  // ═══════ ألوان الخلفيات ═══════
  static const bgLight = PdfColors.grey100;
  static const bgMedium = PdfColors.grey200;
  static const bgWhite = PdfColors.white;
  static const bgAmber = PdfColors.amber50;
  static const bgBlue = PdfColors.blue50;
  static const bgGreen = PdfColors.green50;
  static const bgRed = PdfColors.red50;

  // ═══════ ألوان الحدود ═══════
  static const borderLight = PdfColors.grey300;
  static const borderMedium = PdfColors.grey400;
  static const borderAmber = PdfColors.amber200;

  // ═══════ ألوان الفواتير حسب النوع ═══════
  static const invoiceSale = PdfColor.fromInt(0xFF22C55E);
  static const invoicePurchase = PdfColor.fromInt(0xFF3B82F6);
  static const invoiceSaleReturn = PdfColor.fromInt(0xFFF97316);
  static const invoicePurchaseReturn = PdfColor.fromInt(0xFFEF4444);
  static const invoiceDefault = PdfColor.fromInt(0xFF6B7280);

  // ═══════ ألوان السندات حسب النوع ═══════
  static const voucherReceipt = PdfColors.green;
  static const voucherPayment = PdfColors.blue;
  static const voucherExpense = PdfColors.orange;

  // ═══════ ألوان إضافية ═══════
  static const blue800 = PdfColors.blue800;
  static const red = PdfColors.red;

  /// الحصول على لون الفاتورة حسب النوع
  static PdfColor getInvoiceColor(String invoiceType) {
    switch (invoiceType) {
      case 'sale':
        return invoiceSale;
      case 'purchase':
        return invoicePurchase;
      case 'saleReturn':
      case 'sale_return':
        return invoiceSaleReturn;
      case 'purchaseReturn':
      case 'purchase_return':
        return invoicePurchaseReturn;
      default:
        return invoiceDefault;
    }
  }

  /// الحصول على لون السند حسب النوع
  static PdfColor getVoucherColor(String voucherType) {
    switch (voucherType.toLowerCase()) {
      case 'receipt':
        return voucherReceipt;
      case 'payment':
        return voucherPayment;
      case 'expense':
        return voucherExpense;
      default:
        return voucherExpense;
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Invoice Sizes - أحجام الخطوط والمسافات للفواتير حسب حجم الطباعة
/// ═══════════════════════════════════════════════════════════════════════════
class InvoiceSizes {
  /// أحجام الخطوط
  static const Map<String, Map<String, double>> fontSizes = {
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

  /// المسافات
  static const Map<String, Map<String, double>> spacing = {
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

  /// الحصول على أحجام الخطوط حسب حجم الطباعة
  static Map<String, double> getFontSizes(String printSize) =>
      fontSizes[printSize] ?? fontSizes['A4']!;

  /// الحصول على المسافات حسب حجم الطباعة
  static Map<String, double> getSpacing(String printSize) =>
      spacing[printSize] ?? spacing['A4']!;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Invoice Styles - أنماط الفواتير
/// ═══════════════════════════════════════════════════════════════════════════
class InvoiceStyles {
  final String printSize;
  late final Map<String, double> _fonts;
  late final Map<String, double> _spacing;

  InvoiceStyles(this.printSize) {
    _fonts = InvoiceSizes.getFontSizes(printSize);
    _spacing = InvoiceSizes.getSpacing(printSize);
  }

  /// عنوان الفاتورة (اسم المتجر)
  pw.TextStyle title() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: _fonts['title']!,
        letterSpacing: 1,
      );

  /// العنوان الفرعي
  pw.TextStyle subtitle() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: _fonts['subtitle']!,
        color: PdfColors.white,
      );

  /// رأس القسم
  pw.TextStyle header() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: _fonts['header']!,
      );

  /// النص العادي
  pw.TextStyle body() => pw.TextStyle(
        font: PdfFonts.regular,
        fontSize: _fonts['body']!,
      );

  /// النص العادي بخط عريض
  pw.TextStyle bodyBold() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: _fonts['body']!,
      );

  /// النص الصغير
  pw.TextStyle small() => pw.TextStyle(
        font: PdfFonts.regular,
        fontSize: _fonts['small']!,
        color: PdfColors.grey700,
      );

  /// نص الإجمالي
  pw.TextStyle total() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: _fonts['total']!,
      );

  /// نص رأس الجدول
  pw.TextStyle tableHeader() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: _fonts['body']!,
      );

  /// نص خلية الجدول
  pw.TextStyle tableCell() => pw.TextStyle(
        font: PdfFonts.regular,
        fontSize: _fonts['small']!,
      );

  /// الحصول على قيمة المسافة
  double get margin => _spacing['margin']!;
  double get gap => _spacing['gap']!;
  double get padding => _spacing['padding']!;
  double get divider => _spacing['divider']!;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Invoice Theme - مكونات الفاتورة الموحدة
/// ═══════════════════════════════════════════════════════════════════════════
class InvoiceTheme {
  /// إنشاء ترويسة الفاتورة
  static pw.Widget header({
    required String storeName,
    required String invoiceType,
    required PdfColor typeColor,
    required InvoiceStyles styles,
    pw.MemoryImage? logo,
  }) {
    return pw.Center(
      child: pw.Column(
        children: [
          if (logo != null) ...[
            pw.Image(logo, width: 50, height: 50),
            pw.SizedBox(height: styles.gap),
          ],
          pw.Text(
            storeName,
            style: styles.title(),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: styles.gap / 2),
          pw.Container(
            padding: pw.EdgeInsets.symmetric(
              horizontal: styles.padding * 2,
              vertical: styles.padding / 2,
            ),
            decoration: pw.BoxDecoration(
              color: typeColor,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              invoiceType,
              style: styles.subtitle(),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  /// إنشاء معلومات الفاتورة
  static pw.Widget invoiceInfo({
    required String invoiceNumber,
    required String date,
    required InvoiceStyles styles,
    String? customerName,
    String? paymentMethod,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(styles.padding),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _infoRow('رقم الفاتورة:', invoiceNumber, styles),
          pw.SizedBox(height: styles.gap / 2),
          _infoRow('التاريخ:', date, styles),
          if (customerName != null) ...[
            pw.SizedBox(height: styles.gap / 2),
            _infoRow('العميل:', customerName, styles),
          ],
          if (paymentMethod != null) ...[
            pw.SizedBox(height: styles.gap / 2),
            _infoRow('طريقة الدفع:', paymentMethod, styles),
          ],
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value, InvoiceStyles styles) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: styles.bodyBold(),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: styles.body(),
              textDirection: pw.TextDirection.rtl,
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  /// إنشاء فاصل منقط
  static pw.Widget dottedDivider({double height = 0.5}) {
    return pw.Container(
      height: height,
      child: pw.Row(
        children: List.generate(
          50,
          (index) => pw.Expanded(
            child: pw.Container(
              color: index % 2 == 0 ? PdfColors.grey400 : PdfColors.white,
              height: height,
            ),
          ),
        ),
      ),
    );
  }

  /// إنشاء صف إجمالي - يدعم RTL
  static pw.Widget totalRow({
    required String label,
    required String value,
    required InvoiceStyles styles,
    bool isMain = false,
    PdfColor? color,
  }) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        padding: pw.EdgeInsets.symmetric(vertical: styles.gap / 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: isMain ? styles.total() : styles.bodyBold(),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.Text(
              value,
              style: isMain
                  ? styles
                      .total()
                      .copyWith(color: color ?? AppPdfColors.primary)
                  : styles.bodyBold().copyWith(color: color),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  /// إنشاء صندوق الإجمالي النهائي - يدعم RTL
  static pw.Widget totalBox({
    required String total,
    required InvoiceStyles styles,
    PdfColor color = AppPdfColors.primary,
  }) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        padding: pw.EdgeInsets.all(styles.padding),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'الإجمالي',
              style: styles.total().copyWith(color: PdfColors.white),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.Text(
              total,
              style: styles.total().copyWith(color: PdfColors.white),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  /// إنشاء تذييل الفاتورة
  static pw.Widget footer({
    required InvoiceStyles styles,
    String? note,
    String? thankYouMessage,
  }) {
    return pw.Column(
      children: [
        dottedDivider(),
        pw.SizedBox(height: styles.gap),
        if (note != null) ...[
          pw.Text(
            note,
            style: styles.small(),
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: styles.gap / 2),
        ],
        pw.Text(
          thankYouMessage ?? 'شكراً لتعاملكم معنا',
          style: styles.bodyBold(),
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: styles.gap / 2),
        pw.Text(
          'Hoor',
          style: styles.small(),
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  /// إنشاء جدول عناصر الفاتورة للطابعة الحرارية - يدعم RTL
  static pw.Widget thermalItemsTable({
    required List<Map<String, dynamic>> items,
    required InvoiceStyles styles,
    bool showQuantity = true,
  }) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        children: [
          // رأس الجدول
          pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: styles.gap / 2),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text('المنتج',
                      style: styles.tableHeader(),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.right),
                ),
                if (showQuantity)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('الكمية',
                        style: styles.tableHeader(),
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.center),
                  ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text('السعر',
                      style: styles.tableHeader(),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.center),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text('الإجمالي',
                      style: styles.tableHeader(),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.left),
                ),
              ],
            ),
          ),
          // عناصر الجدول
          ...items.map((item) => pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: styles.gap / 2),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        item['name'] ?? '',
                        style: styles.tableCell(),
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    if (showQuantity)
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          item['quantity'] ?? '',
                          style: styles.tableCell(),
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        item['price'] ?? '',
                        style: styles.tableCell(),
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        item['total'] ?? '',
                        style: styles.tableCell(),
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// مكونات فاتورة A4
  /// ═══════════════════════════════════════════════════════════════════════════

  /// ترويسة A4 المحسنة
  static pw.Widget a4Header({
    required String storeName,
    required String subtitle,
    required InvoiceStyles styles,
    pw.MemoryImage? logo,
    PdfColor color = AppPdfColors.primary,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(styles.padding * 1.5),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                storeName,
                style: styles.title().copyWith(color: PdfColors.white),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                subtitle,
                style: styles.small().copyWith(color: PdfColors.grey200),
              ),
            ],
          ),
          if (logo != null)
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(30),
              ),
              padding: const pw.EdgeInsets.all(6),
              child: pw.Image(logo),
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
                  storeName.isNotEmpty ? storeName[0] : 'H',
                  style: pw.TextStyle(
                    font: PdfFonts.bold,
                    fontSize: 32,
                    color: color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// شارة نوع الفاتورة ورقمها
  static pw.Widget a4InvoiceBadge({
    required String invoiceType,
    required String invoiceNumber,
    required InvoiceStyles styles,
    required PdfColor typeColor,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(
          padding: pw.EdgeInsets.symmetric(
            horizontal: styles.padding * 1.5,
            vertical: styles.padding / 1.5,
          ),
          decoration: pw.BoxDecoration(
            color: typeColor,
            borderRadius: pw.BorderRadius.circular(20),
          ),
          child: pw.Text(
            invoiceType,
            style: styles.body().copyWith(color: PdfColors.white),
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(styles.padding),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'رقم الفاتورة',
                style: styles.small(),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                invoiceNumber,
                style: styles.header().copyWith(color: AppPdfColors.primary),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// صندوق معلومات العميل/المورد
  static pw.Widget a4CustomerInfo({
    required String title,
    required String name,
    required InvoiceStyles styles,
    String? phone,
    String? address,
    bool isCustomer = true,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(styles.padding),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Icon(
              isCustomer
                  ? const pw.IconData(0xe7fd)
                  : const pw.IconData(0xe0af),
              size: 24,
              color: AppPdfColors.primary,
            ),
          ),
          pw.SizedBox(width: styles.gap),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: styles.small(),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  name,
                  style: styles.header(),
                  textDirection: pw.TextDirection.rtl,
                ),
                if (phone != null)
                  pw.Text(
                    phone,
                    style: styles.body(),
                    textDirection: pw.TextDirection.rtl,
                  ),
              ],
            ),
          ),
          if (address != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'العنوان',
                  style: styles.small(),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  address,
                  style: styles.body(),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// صندوق الإجماليات لـ A4
  static pw.Widget a4TotalsBox({
    required int itemCount,
    required String subtotal,
    required String total,
    required InvoiceStyles styles,
    String? discount,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(styles.padding),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          _summaryRow(styles, 'عدد المنتجات', '$itemCount'),
          pw.SizedBox(height: styles.gap / 2),
          _summaryRow(styles, 'المجموع الفرعي', subtotal),
          if (discount != null) ...[
            pw.SizedBox(height: styles.gap / 2),
            _summaryRow(styles, 'الخصم', discount,
                valueColor: PdfColors.red700),
          ],
          pw.SizedBox(height: styles.gap),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: styles.gap),
          totalBox(
            total: total,
            styles: styles,
            color: AppPdfColors.primary,
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(
    InvoiceStyles styles,
    String label,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          value,
          style: styles.body().copyWith(color: valueColor),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Text(
          label,
          style: styles.body(),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    );
  }

  /// صندوق الباركود/QR
  static pw.Widget a4BarcodeBox({
    required String data,
    required InvoiceStyles styles,
    String title = 'رمز الفاتورة',
    bool useQrCode = true,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(styles.padding),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: styles.small(),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: styles.gap),
          pw.BarcodeWidget(
            barcode: useQrCode ? pw.Barcode.qrCode() : pw.Barcode.code128(),
            data: data,
            width: useQrCode ? 80 : 120,
            height: useQrCode ? 80 : 50,
          ),
        ],
      ),
    );
  }

  /// صندوق الملاحظات
  static pw.Widget notesBox({
    required String notes,
    required InvoiceStyles styles,
    String title = 'ملاحظات',
  }) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.all(styles.padding),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgAmber,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: AppPdfColors.borderAmber),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: styles.bodyBold(),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            notes,
            style: styles.body(),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Voucher Theme - مكونات السندات الموحدة
/// ═══════════════════════════════════════════════════════════════════════════
class VoucherTheme {
  /// إنشاء ترويسة السند
  static pw.Widget header({
    required String voucherType,
    required String voucherNumber,
    required String date,
    required PdfColor typeColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: typeColor,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            voucherType,
            style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: PdfSizes.fontSizeTitle + 2,
              color: AppPdfColors.textWhite,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              _badge('رقم: $voucherNumber', typeColor),
              pw.SizedBox(width: 12),
              _badge(date, typeColor),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _badge(String text, PdfColor accentColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgWhite,
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: PdfFonts.bold,
          fontSize: PdfSizes.fontSizeSmall + 1,
          color: accentColor,
        ),
      ),
    );
  }

  /// صندوق معلومات الشركة
  static pw.Widget companyInfoBox({
    String? companyName,
    String? companyAddress,
    String? companyPhone,
  }) {
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
                if (companyName != null)
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(
                        font: PdfFonts.bold, fontSize: PdfSizes.fontSizeMedium),
                  ),
                if (companyAddress != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    companyAddress,
                    style: pw.TextStyle(
                      font: PdfFonts.regular,
                      fontSize: PdfSizes.fontSizeSmall - 1,
                      color: AppPdfColors.textSecondary,
                    ),
                  ),
                ],
                if (companyPhone != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'هاتف: $companyPhone',
                    style: pw.TextStyle(
                      font: PdfFonts.regular,
                      fontSize: PdfSizes.fontSizeSmall - 1,
                      color: AppPdfColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// صندوق معلومات الطرف (العميل/المورد)
  static pw.Widget partyInfoBox({
    required String label,
    required String name,
    required PdfColor accentColor,
  }) {
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
              color: accentColor,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              '$label: $name',
              style: pw.TextStyle(
                  font: PdfFonts.bold, fontSize: PdfSizes.fontSizeMedium),
            ),
          ),
        ],
      ),
    );
  }

  /// قسم المبلغ
  static pw.Widget amountSection({
    required String amount,
    required String amountLabel,
    required PdfColor typeColor,
    String? exchangeRate,
    String? amountUsd,
    String? createdBy,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgLight,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: AppPdfColors.borderLight),
      ),
      child: pw.Column(
        children: [
          // المبلغ الإجمالي
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                amountLabel,
                style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: PdfSizes.fontSizeLarge,
                  color: typeColor,
                ),
              ),
              pw.Text(
                amount,
                style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: PdfSizes.fontSizeTitle - 2,
                  color: typeColor,
                ),
              ),
            ],
          ),
          // سعر الصرف والمبلغ بالدولار
          if (exchangeRate != null && amountUsd != null) ...[
            pw.SizedBox(height: 8),
            pw.Divider(color: AppPdfColors.borderLight, thickness: 0.5),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'سعر الصرف',
                  style: pw.TextStyle(
                    font: PdfFonts.regular,
                    fontSize: PdfSizes.fontSizeSmall,
                    color: AppPdfColors.textSecondary,
                  ),
                ),
                pw.Text(
                  exchangeRate,
                  style: pw.TextStyle(
                    font: PdfFonts.regular,
                    fontSize: PdfSizes.fontSizeSmall,
                    color: AppPdfColors.textSecondary,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'المبلغ بالدولار',
                  style: pw.TextStyle(
                    font: PdfFonts.bold,
                    fontSize: PdfSizes.fontSizeSmall + 1,
                    color: AppPdfColors.blue800,
                  ),
                ),
                pw.Text(
                  amountUsd,
                  style: pw.TextStyle(
                    font: PdfFonts.bold,
                    fontSize: PdfSizes.fontSizeMedium,
                    color: AppPdfColors.blue800,
                  ),
                ),
              ],
            ),
          ],
          // المنشئ
          if (createdBy != null) ...[
            pw.SizedBox(height: 8),
            pw.Divider(color: AppPdfColors.borderLight, thickness: 0.5),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'بواسطة',
                  style: pw.TextStyle(
                    font: PdfFonts.regular,
                    fontSize: PdfSizes.fontSizeSmall,
                    color: AppPdfColors.textSecondary,
                  ),
                ),
                pw.Text(
                  createdBy,
                  style: pw.TextStyle(
                    font: PdfFonts.bold,
                    fontSize: PdfSizes.fontSizeSmall,
                    color: AppPdfColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// صندوق الإحصائيات
  static pw.Widget statsBox({
    required List<MapEntry<String, String>> stats,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgLight,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: stats
            .map((stat) => pw.Column(
                  children: [
                    pw.Text(
                      stat.key,
                      style: pw.TextStyle(
                        font: PdfFonts.regular,
                        fontSize: PdfSizes.fontSizeSmall - 1,
                        color: AppPdfColors.textMuted,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      stat.value,
                      style: pw.TextStyle(
                        font: PdfFonts.bold,
                        fontSize: PdfSizes.fontSizeMedium,
                        color: AppPdfColors.textPrimary,
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }

  /// صندوق التفاصيل/البيان
  static pw.Widget detailsBox({
    required String description,
    required PdfColor accentColor,
    String title = 'البيان',
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 3,
          height: 60,
          color: accentColor,
        ),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: AppPdfColors.bgAmber,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: PdfFonts.bold,
                    fontSize: PdfSizes.fontSizeSmall,
                    color: AppPdfColors.warning,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  description,
                  style: pw.TextStyle(
                    font: PdfFonts.regular,
                    fontSize: PdfSizes.fontSizeSmall + 1,
                    color: AppPdfColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// تذييل السند
  static pw.Widget footer({String? footerMessage}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: AppPdfColors.borderLight)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'تم الطباعة: ${_formatDateTime(DateTime.now())}',
            style: pw.TextStyle(
              font: PdfFonts.regular,
              fontSize: PdfSizes.fontSizeXSmall,
              color: AppPdfColors.textLight,
            ),
          ),
          if (footerMessage != null && footerMessage.isNotEmpty)
            pw.Text(
              footerMessage,
              style: pw.TextStyle(
                font: PdfFonts.bold,
                fontSize: PdfSizes.fontSizeSmall - 1,
                color: AppPdfColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  /// فاصل منقط
  static pw.Widget dottedDivider() {
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

  static String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // مكونات الطابعة الحرارية
  // ═══════════════════════════════════════════════════════════════════════════

  /// ترويسة حرارية
  static pw.Widget thermalHeader({
    required String voucherType,
    required String voucherNumber,
    required String date,
    required PdfColor typeColor,
    required int widthMm,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyTaxNumber,
  }) {
    final titleSize = widthMm == 58 ? 12.0 : 14.0;
    final fontSize = widthMm == 58 ? 7.0 : 8.0;

    return pw.Column(
      children: [
        if (companyName != null)
          pw.Text(
            companyName,
            style: pw.TextStyle(font: PdfFonts.bold, fontSize: titleSize),
            textAlign: pw.TextAlign.center,
          ),
        if (companyAddress != null)
          pw.Text(
            companyAddress,
            style: pw.TextStyle(font: PdfFonts.regular, fontSize: fontSize),
            textAlign: pw.TextAlign.center,
          ),
        if (companyPhone != null)
          pw.Text(
            companyPhone,
            style: pw.TextStyle(font: PdfFonts.regular, fontSize: fontSize),
            textAlign: pw.TextAlign.center,
          ),
        if (companyTaxNumber != null)
          pw.Text(
            'الرقم الضريبي: $companyTaxNumber',
            style: pw.TextStyle(font: PdfFonts.regular, fontSize: fontSize),
            textAlign: pw.TextAlign.center,
          ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: pw.BoxDecoration(
            color: typeColor,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            voucherType,
            style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: widthMm == 58 ? 10.0 : 12.0,
              color: AppPdfColors.textWhite,
            ),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          voucherNumber,
          style: pw.TextStyle(
              font: PdfFonts.regular, fontSize: widthMm == 58 ? 9.0 : 10.0),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          date,
          style: pw.TextStyle(
              font: PdfFonts.regular, fontSize: widthMm == 58 ? 8.0 : 9.0),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  /// معلومات الطرف للحرارية
  static pw.Widget thermalPartyInfo({
    required String label,
    required String name,
    required int widthMm,
  }) {
    final fontSize = widthMm == 58 ? 8.0 : 9.0;
    return pw.Text(
      '$label: $name',
      style: pw.TextStyle(font: PdfFonts.regular, fontSize: fontSize),
    );
  }

  /// قسم المبلغ الحراري
  static pw.Widget thermalAmount({
    required String amount,
    required int widthMm,
    String? exchangeRate,
    String? amountUsd,
  }) {
    final titleSize = widthMm == 58 ? 14.0 : 16.0;
    final fontSize = widthMm == 58 ? 8.0 : 9.0;

    return pw.Column(
      children: [
        pw.Text(
          'المبلغ',
          style: pw.TextStyle(font: PdfFonts.regular, fontSize: fontSize),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: pw.BoxDecoration(
            color: AppPdfColors.bgMedium,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Center(
            child: pw.Text(
              amount,
              style: pw.TextStyle(font: PdfFonts.bold, fontSize: titleSize),
            ),
          ),
        ),
        if (exchangeRate != null && amountUsd != null) ...[
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'سعر الصرف',
                style: pw.TextStyle(
                    font: PdfFonts.regular, fontSize: fontSize - 1),
              ),
              pw.Text(
                exchangeRate,
                style: pw.TextStyle(
                    font: PdfFonts.regular, fontSize: fontSize - 1),
              ),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'بالدولار',
                style: pw.TextStyle(
                  font: PdfFonts.regular,
                  fontSize: fontSize,
                  color: AppPdfColors.blue800,
                ),
              ),
              pw.Text(
                amountUsd,
                style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: fontSize + 1,
                  color: AppPdfColors.blue800,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// وصف حراري
  static pw.Widget thermalDescription({
    required String description,
    required int widthMm,
  }) {
    final fontSize = widthMm == 58 ? 7.0 : 8.0;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'البيان:',
          style: pw.TextStyle(font: PdfFonts.bold, fontSize: fontSize),
        ),
        pw.Text(
          description,
          style: pw.TextStyle(font: PdfFonts.regular, fontSize: fontSize),
          maxLines: 3,
        ),
      ],
    );
  }

  /// تذييل حراري
  static pw.Widget thermalFooter({
    String? footerMessage,
    required int widthMm,
  }) {
    final fontSize = widthMm == 58 ? 7.0 : 8.0;
    return pw.Column(
      children: [
        if (footerMessage != null && footerMessage.isNotEmpty)
          pw.Text(
            footerMessage,
            style: pw.TextStyle(font: PdfFonts.regular, fontSize: fontSize),
            textAlign: pw.TextAlign.center,
          ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Report Theme - مكونات التقارير الموحدة
/// ═══════════════════════════════════════════════════════════════════════════
class ReportTheme {
  /// إنشاء ترويسة التقرير
  static pw.Widget header({
    required String title,
    String? subtitle,
    String? dateRange,
    PdfColor color = AppPdfColors.primary,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: PdfSizes.fontSizeHeader,
              color: AppPdfColors.textWhite,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              subtitle,
              style: pw.TextStyle(
                font: PdfFonts.regular,
                fontSize: PdfSizes.fontSizeMedium,
                color: AppPdfColors.textWhite,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
          if (dateRange != null) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: pw.BoxDecoration(
                color: AppPdfColors.bgWhite,
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Text(
                dateRange,
                style: pw.TextStyle(
                  font: PdfFonts.regular,
                  fontSize: PdfSizes.fontSizeSmall,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// صندوق الإحصائيات
  static pw.Widget statsBox({
    required List<ReportStat> stats,
    PdfColor borderColor = AppPdfColors.primary,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: stats.map((stat) {
          return pw.Expanded(
            child: pw.Column(
              children: [
                pw.Text(
                  stat.label,
                  style: pw.TextStyle(
                    font: PdfFonts.regular,
                    fontSize: PdfSizes.fontSizeSmall,
                    color: AppPdfColors.textSecondary,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  stat.value,
                  style: pw.TextStyle(
                    font: PdfFonts.bold,
                    fontSize: PdfSizes.fontSizeMedium,
                    color: stat.color ?? AppPdfColors.textPrimary,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// جدول التقرير
  static pw.Widget table({
    required List<String> headers,
    required List<List<String>> data,
    PdfColor headerColor = AppPdfColors.primary,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: AppPdfColors.borderLight, width: 0.5),
      headerStyle: pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: PdfSizes.fontSizeSmall,
        color: AppPdfColors.textWhite,
      ),
      cellStyle: pw.TextStyle(
        font: PdfFonts.regular,
        fontSize: PdfSizes.fontSizeSmall,
        color: AppPdfColors.textPrimary,
      ),
      headerDecoration: pw.BoxDecoration(color: headerColor),
      cellAlignments: {
        for (int i = 0; i < headers.length; i++) i: pw.Alignment.centerRight,
      },
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      cellHeight: 30,
      headerHeight: 35,
    );
  }

  /// فاصل بعنوان
  static pw.Widget sectionDivider(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Row(
          children: [
            pw.Expanded(child: pw.Divider(color: AppPdfColors.borderLight)),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8),
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: PdfSizes.fontSizeLarge,
                  color: AppPdfColors.textPrimary,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.Expanded(child: pw.Divider(color: AppPdfColors.borderLight)),
          ],
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  /// صندوق ملخص
  static pw.Widget summaryBox({
    required String label,
    required String value,
    PdfColor? valueColor,
    PdfColor? backgroundColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: backgroundColor ?? AppPdfColors.bgLight,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: PdfFonts.regular,
              fontSize: PdfSizes.fontSizeMedium,
              color: AppPdfColors.textPrimary,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: PdfSizes.fontSizeMedium,
              color: valueColor ?? AppPdfColors.textPrimary,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  /// تذييل التقرير
  static pw.Widget footer({
    required int pageNumber,
    required int totalPages,
    String? note,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: AppPdfColors.borderLight)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'صفحة $pageNumber من $totalPages',
            style: pw.TextStyle(
              font: PdfFonts.regular,
              fontSize: PdfSizes.fontSizeXSmall,
              color: AppPdfColors.textLight,
            ),
          ),
          if (note != null)
            pw.Text(
              note,
              style: pw.TextStyle(
                font: PdfFonts.regular,
                fontSize: PdfSizes.fontSizeXSmall,
                color: AppPdfColors.textLight,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          pw.Text(
            'Hoor',
            style: pw.TextStyle(
              font: PdfFonts.regular,
              fontSize: PdfSizes.fontSizeXSmall,
              color: AppPdfColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// إحصائية للتقرير
class ReportStat {
  final String label;
  final String value;
  final PdfColor? color;

  const ReportStat({
    required this.label,
    required this.value,
    this.color,
  });
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Export Theme - ثيم التصدير الموحد (للتقارير والقوائم)
/// ═══════════════════════════════════════════════════════════════════════════
class ExportTheme {
  ExportTheme._();

  // ═══════ الألوان الخاصة بالتصدير ═══════
  static const PdfColor headerPrimary = PdfColor.fromInt(0xFF1565C0);
  static const PdfColor headerSuccess = PdfColor.fromInt(0xFF43A047);
  static const PdfColor headerWarning = PdfColor.fromInt(0xFFFFA000);
  static const PdfColor headerError = PdfColor.fromInt(0xFFE53935);
  static const PdfColor headerPurchase = PdfColor.fromInt(0xFF1E88E5);

  // ═══════ ألوان تقرير Z ═══════
  static const PdfColor zReportSales = PdfColor.fromInt(0xFFE8F5E9);
  static const PdfColor zReportSalesText = PdfColor.fromInt(0xFF2E7D32);
  static const PdfColor zReportExpense = PdfColor.fromInt(0xFFFFEBEE);
  static const PdfColor zReportExpenseText = PdfColor.fromInt(0xFFC62828);
  static const PdfColor zReportCash = PdfColor.fromInt(0xFFE3F2FD);
  static const PdfColor zReportCashText = PdfColor.fromInt(0xFF1565C0);

  /// صندوق إحصائيات التصدير
  static pw.Widget statsBox(List<ExportStat> stats) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: AppPdfColors.bgLight,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: stats.map((stat) => _buildStatItem(stat)).toList(),
        ),
      ),
    );
  }

  static pw.Widget _buildStatItem(ExportStat stat) {
    return pw.Column(
      children: [
        pw.Text(
          stat.label,
          style: pw.TextStyle(
            font: PdfFonts.regular,
            fontSize: PdfSizes.fontSizeXSmall,
            color: AppPdfColors.textMuted,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          stat.value,
          style: pw.TextStyle(
            font: PdfFonts.bold,
            fontSize: PdfSizes.fontSizeMedium,
            color: stat.color ?? AppPdfColors.textPrimary,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    );
  }

  /// صندوق ملون (للربح المتوقع، إجماليات، إلخ)
  static pw.Widget highlightBox({
    required String label,
    required String value,
    required PdfColor bgColor,
    required PdfColor textColor,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: textColor),
      ),
      child: pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                font: PdfFonts.bold,
                fontSize: PdfSizes.fontSizeMedium,
                color: textColor,
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: PdfFonts.bold,
                fontSize: PdfSizes.fontSizeLarge,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// صندوق معلومات بسيط (للإحصائيات العامة)
  static pw.Widget infoBox({
    required String title,
    required String subtitle,
    String? trailing,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgLight,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: PdfSizes.fontSizeMedium,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(
                    font: PdfFonts.regular,
                    fontSize: PdfSizes.fontSizeSmall,
                    color: AppPdfColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
          if (trailing != null)
            pw.Text(
              trailing,
              style: pw.TextStyle(
                font: PdfFonts.regular,
                fontSize: PdfSizes.fontSizeSmall,
              ),
            ),
        ],
      ),
    );
  }

  /// جدول بنمط TableHelper - مع دعم RTL
  static pw.Widget tableHelper({
    required List<String> headers,
    required List<List<String>> data,
    PdfColor headerColor = headerPrimary,
  }) {
    // عكس ترتيب الأعمدة لدعم RTL
    final reversedHeaders = headers.reversed.toList();
    final reversedData = data.map((row) => row.reversed.toList()).toList();

    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(
          font: PdfFonts.bold,
          color: AppPdfColors.textWhite,
          fontSize: PdfSizes.fontSizeSmall,
        ),
        headerDecoration: pw.BoxDecoration(
          color: headerColor,
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(8),
            topRight: pw.Radius.circular(8),
          ),
        ),
        cellStyle: pw.TextStyle(
          font: PdfFonts.regular,
          fontSize: PdfSizes.fontSizeSmall - 1,
        ),
        cellPadding: const pw.EdgeInsets.all(8),
        cellAlignments: {
          for (int i = 0; i < headers.length; i++) i: pw.Alignment.center,
        },
        headers: reversedHeaders,
        data: reversedData,
      ),
    );
  }

  /// فاصل قسم
  static pw.Widget sectionDivider(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Row(
          children: [
            pw.Expanded(child: pw.Divider(color: AppPdfColors.borderLight)),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8),
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: PdfSizes.fontSizeMedium,
                  color: AppPdfColors.textSecondary,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.Expanded(child: pw.Divider(color: AppPdfColors.borderLight)),
          ],
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  /// صندوق ملخص (للإجماليات)
  static pw.Widget summaryBox({
    required List<SummaryItem> items,
    String? finalLabel,
    String? finalValue,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgMedium,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: items
                .map((item) => pw.Text(
                      '${item.label}: ${item.value}',
                      style: pw.TextStyle(
                        font: PdfFonts.bold,
                        fontSize: PdfSizes.fontSizeSmall - 1,
                        color: item.color ?? AppPdfColors.textPrimary,
                      ),
                    ))
                .toList(),
          ),
          if (finalLabel != null && finalValue != null) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              '$finalLabel: $finalValue',
              style: pw.TextStyle(
                font: PdfFonts.bold,
                fontSize: PdfSizes.fontSizeMedium - 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Statement Theme - ثيم كشف الحساب (العملاء/الموردين)
/// ═══════════════════════════════════════════════════════════════════════════
class StatementTheme {
  StatementTheme._();

  /// صندوق معلومات الطرف (عميل/مورد)
  static pw.Widget partyInfoBox({
    required String phone,
    required String balance,
    required bool isPositive,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgLight,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            phone,
            style: pw.TextStyle(
              font: PdfFonts.regular,
              fontSize: PdfSizes.fontSizeSmall - 1,
            ),
          ),
          pw.Text(
            balance,
            style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: PdfSizes.fontSizeSmall,
              color: isPositive ? AppPdfColors.error : AppPdfColors.success,
            ),
          ),
        ],
      ),
    );
  }

  /// رسالة لا توجد معاملات
  static pw.Widget emptyMessage() {
    return pw.Center(
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text(
          'لا توجد معاملات',
          style: pw.TextStyle(
            font: PdfFonts.regular,
            fontSize: PdfSizes.fontSizeLarge,
            color: AppPdfColors.textMuted,
          ),
        ),
      ),
    );
  }

  /// صندوق إجماليات كشف الحساب
  static pw.Widget totalsBox({
    required String totalDebit,
    required String totalCredit,
    required String finalBalance,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgMedium,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Text(
                totalDebit,
                style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: PdfSizes.fontSizeSmall - 1,
                  color: AppPdfColors.error,
                ),
              ),
              pw.Text(
                totalCredit,
                style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: PdfSizes.fontSizeSmall - 1,
                  color: AppPdfColors.success,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            finalBalance,
            style: pw.TextStyle(
              font: PdfFonts.bold,
              fontSize: PdfSizes.fontSizeMedium - 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Z Report Theme - ثيم تقرير Z (إغلاق الوردية)
/// ═══════════════════════════════════════════════════════════════════════════
class ZReportTheme {
  ZReportTheme._();

  /// صندوق معلومات الوردية
  static pw.Widget shiftInfoBox(List<ZReportRow> rows) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: AppPdfColors.borderLight),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: rows
            .map((row) => pw.Column(
                  children: [
                    _buildRow(row.label, row.value,
                        isBold: row.isBold, color: row.color),
                    if (rows.indexOf(row) < rows.length - 1)
                      pw.Divider(color: AppPdfColors.bgMedium),
                  ],
                ))
            .toList(),
      ),
    );
  }

  /// صندوق المبيعات (أخضر)
  static pw.Widget salesBox({
    required String title,
    required List<ZReportRow> rows,
    required ZReportRow total,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: ExportTheme.zReportSales,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: PdfSizes.fontSizeLarge,
              font: PdfFonts.bold,
              color: ExportTheme.zReportSalesText,
            ),
          ),
          pw.SizedBox(height: 12),
          ...rows.map((row) => _buildRow(row.label, row.value)),
          pw.Divider(color: PdfColors.green200),
          _buildRow(total.label, total.value, isBold: true),
        ],
      ),
    );
  }

  /// صندوق المصروفات (أحمر)
  static pw.Widget expenseBox({
    required String title,
    required List<ZReportRow> rows,
    required ZReportRow total,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: ExportTheme.zReportExpense,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: PdfSizes.fontSizeLarge,
              font: PdfFonts.bold,
              color: ExportTheme.zReportExpenseText,
            ),
          ),
          pw.SizedBox(height: 12),
          ...rows.map((row) => _buildRow(row.label, row.value)),
          pw.Divider(color: PdfColors.red200),
          _buildRow(total.label, total.value, isBold: true),
        ],
      ),
    );
  }

  /// صندوق النقدية (أزرق)
  static pw.Widget cashBox({
    required String title,
    required List<ZReportRow> rows,
    required ZReportRow total,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: ExportTheme.zReportCash,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: PdfSizes.fontSizeLarge,
              font: PdfFonts.bold,
              color: ExportTheme.zReportCashText,
            ),
          ),
          pw.SizedBox(height: 12),
          ...rows
              .map((row) => _buildRow(row.label, row.value, color: row.color)),
          pw.Divider(color: PdfColors.blue200, thickness: 2),
          _buildRow(total.label, total.value,
              isBold: true, fontSize: PdfSizes.fontSizeLarge),
        ],
      ),
    );
  }

  /// قسم التوقيعات
  static pw.Widget signaturesSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildSignature('توقيع الكاشير'),
          _buildSignature('توقيع المدير'),
        ],
      ),
    );
  }

  static pw.Widget _buildSignature(String label) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: PdfFonts.regular,
            fontSize: PdfSizes.fontSizeSmall,
          ),
        ),
        pw.SizedBox(height: 24),
        pw.Container(
          width: 120,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: AppPdfColors.borderMedium),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = PdfSizes.fontSizeMedium - 1,
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
              font: isBold ? PdfFonts.bold : PdfFonts.regular,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              font: isBold ? PdfFonts.bold : PdfFonts.regular,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Cash Movement Theme - ثيم حركات الصندوق
/// ═══════════════════════════════════════════════════════════════════════════
class CashMovementTheme {
  CashMovementTheme._();

  /// صندوق ملخص حركات الصندوق
  static pw.Widget summaryBox({
    required String movementCount,
    required String netValue,
    required bool isPositive,
    required String incomeValue,
    required String expenseValue,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.bgLight,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                movementCount,
                style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: PdfSizes.fontSizeMedium - 1,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                netValue,
                style: pw.TextStyle(
                  font: PdfFonts.bold,
                  fontSize: PdfSizes.fontSizeMedium - 1,
                  color: isPositive ? AppPdfColors.success : AppPdfColors.error,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                incomeValue,
                style: pw.TextStyle(
                  color: AppPdfColors.success,
                  fontSize: PdfSizes.fontSizeSmall,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                expenseValue,
                style: pw.TextStyle(
                  color: AppPdfColors.error,
                  fontSize: PdfSizes.fontSizeSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// نماذج البيانات للمكونات
/// ═══════════════════════════════════════════════════════════════════════════

/// إحصائية للتصدير
class ExportStat {
  final String label;
  final String value;
  final PdfColor? color;

  const ExportStat({
    required this.label,
    required this.value,
    this.color,
  });
}

/// عنصر ملخص
class SummaryItem {
  final String label;
  final String value;
  final PdfColor? color;

  const SummaryItem({
    required this.label,
    required this.value,
    this.color,
  });
}

/// صف تقرير Z
class ZReportRow {
  final String label;
  final String value;
  final bool isBold;
  final PdfColor? color;

  const ZReportRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });
}
