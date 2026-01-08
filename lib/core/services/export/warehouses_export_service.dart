import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import 'export_templates.dart';
import '../printing/pdf_theme.dart';
import '../../../data/database/app_database.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Warehouses Export Service - خدمة تصدير المستودعات الموحدة
/// تدعم تصدير جميع المستودعات مع مخزونها إلى Excel و PDF
/// يستخدم PdfFonts من pdf_theme.dart لدعم العربية و RTL
/// ═══════════════════════════════════════════════════════════════════════════
class WarehousesExportService {
  /// تهيئة الخطوط العربية من PdfFonts
  static Future<void> _ensureFontsInitialized() async {
    await PdfFonts.init();
  }

  /// الخط العربي العادي
  static pw.Font get _font => PdfFonts.regular;

  /// الخط العربي العريض
  static pw.Font get _fontBold => PdfFonts.bold;

  // ══════════════════════════════════════════════════════════════════════════
  // البيانات المطلوبة للتصدير
  // ══════════════════════════════════════════════════════════════════════════

  /// بيانات مستودع واحد مع مخزونه
  static Future<WarehouseExportData> getWarehouseData(
    AppDatabase db,
    Warehouse warehouse,
    Map<String, Product> productMap,
  ) async {
    final stock = await db.getWarehouseStockByWarehouse(warehouse.id);
    final totalQuantity =
        stock.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalValue = stock.fold<double>(0, (sum, item) {
      final product = productMap[item.productId];
      return sum + (product?.purchasePrice ?? 0) * item.quantity;
    });

    return WarehouseExportData(
      warehouse: warehouse,
      stock: stock,
      totalQuantity: totalQuantity,
      totalValue: totalValue,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // تصدير Excel
  // ══════════════════════════════════════════════════════════════════════════

  /// تصدير جميع المستودعات إلى ملف Excel
  static Future<String> exportToExcel({
    required List<Warehouse> warehouses,
    required AppDatabase db,
    String? fileName,
  }) async {
    final products = await db.getAllProducts();
    final productMap = {for (var p in products) p.id: p};

    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    // ═══════════════════════════════════════════════════════════════════════
    // تنسيقات مشتركة
    // ═══════════════════════════════════════════════════════════════════════
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1565C0'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
    );

    final evenRowStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#F5F5F5'),
    );

    final lowStockStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#FFEBEE'),
      fontColorHex: ExcelColor.fromHexString('#C62828'),
    );

    // ═══════════════════════════════════════════════════════════════════════
    // 1. ورقة ملخص المستودعات
    // ═══════════════════════════════════════════════════════════════════════
    final summarySheet = excel['ملخص المستودعات'];

    // العنوان
    summarySheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = TextCellValue('تقرير المستودعات الموحد');
    summarySheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .cellStyle = titleStyle;
    summarySheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0),
    );

    // تاريخ التصدير
    summarySheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
            .value =
        TextCellValue(
            'تاريخ التصدير: ${DateFormat('yyyy/MM/dd - HH:mm').format(DateTime.now())}');

    // رؤوس الجدول
    final summaryHeaders = [
      'اسم المستودع',
      'الكود',
      'العنوان',
      'الهاتف',
      'عدد المنتجات',
      'إجمالي المخزون',
      'قيمة المخزون',
      'الحالة',
    ];

    for (var i = 0; i < summaryHeaders.length; i++) {
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3))
        ..value = TextCellValue(summaryHeaders[i])
        ..cellStyle = headerStyle;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // 2. إضافة بيانات كل مستودع
    // ═══════════════════════════════════════════════════════════════════════
    int summaryRow = 4;
    double grandTotalValue = 0;
    int grandTotalQuantity = 0;

    for (final warehouse in warehouses) {
      final data = await getWarehouseData(db, warehouse, productMap);
      grandTotalValue += data.totalValue;
      grandTotalQuantity += data.totalQuantity;

      // إضافة للملخص
      summarySheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRow))
          .value = TextCellValue(warehouse.name);
      summarySheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: summaryRow))
          .value = TextCellValue(warehouse.code ?? '-');
      summarySheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: summaryRow))
          .value = TextCellValue(warehouse.address ?? '-');
      summarySheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: summaryRow))
          .value = TextCellValue(warehouse.phone ?? '-');
      summarySheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: summaryRow))
          .value = IntCellValue(data.stock.length);
      summarySheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: summaryRow))
          .value = IntCellValue(data.totalQuantity);
      summarySheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: summaryRow))
          .value = DoubleCellValue(data.totalValue);
      summarySheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: summaryRow))
          .value = TextCellValue(warehouse.isActive ? 'نشط' : 'غير نشط');

      // تنسيق الصف الزوجي
      if ((summaryRow - 4).isEven) {
        for (var col = 0; col < summaryHeaders.length; col++) {
          summarySheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: col, rowIndex: summaryRow))
              .cellStyle = evenRowStyle;
        }
      }

      summaryRow++;

      // ═══════════════════════════════════════════════════════════════════════
      // 3. إنشاء ورقة تفصيلية لكل مستودع
      // ═══════════════════════════════════════════════════════════════════════
      if (data.stock.isNotEmpty) {
        // تنظيف اسم المستودع من الأحرف غير المسموحة
        final sheetName = _sanitizeSheetName(warehouse.name);
        final warehouseSheet = excel[sheetName];

        // العنوان
        warehouseSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
            .value = TextCellValue('مخزون مستودع: ${warehouse.name}');
        warehouseSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
            .cellStyle = titleStyle;
        warehouseSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0),
        );

        // إحصائيات
        warehouseSheet
                .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
                .value =
            TextCellValue(
                'عدد المنتجات: ${data.stock.length} | الكمية: ${data.totalQuantity} | القيمة: ${_formatNumber(data.totalValue)} ل.س');

        // رؤوس الجدول - مع السعر بالدولار
        final detailHeaders = [
          'اسم المنتج',
          'الباركود',
          'الكمية',
          'الحد الأدنى',
          'الموقع',
          'سعر الشراء (ل.س / \$)',
          'سعر البيع (ل.س / \$)',
          'قيمة المخزون',
        ];

        for (var i = 0; i < detailHeaders.length; i++) {
          warehouseSheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3))
            ..value = TextCellValue(detailHeaders[i])
            ..cellStyle = headerStyle;
        }

        // بيانات المخزون
        int detailRow = 4;
        for (final item in data.stock) {
          final product = productMap[item.productId];
          final stockValue = (product?.purchasePrice ?? 0) * item.quantity;
          final isLowStock = item.quantity <= item.minQuantity;

          warehouseSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: detailRow))
              .value = TextCellValue(product?.name ?? 'منتج غير معروف');
          warehouseSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 1, rowIndex: detailRow))
              .value = TextCellValue(product?.barcode ?? '-');

          final qtyCell = warehouseSheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: detailRow));
          qtyCell.value = IntCellValue(item.quantity);
          if (isLowStock) {
            qtyCell.cellStyle = lowStockStyle;
          }

          warehouseSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 3, rowIndex: detailRow))
              .value = IntCellValue(item.minQuantity);
          warehouseSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 4, rowIndex: detailRow))
              .value = TextCellValue(item.location ?? '-');

          // سعر الشراء (ليرة + دولار)
          final purchasePriceSyp = product?.purchasePrice ?? 0;
          final purchasePriceUsd = product?.purchasePriceUsd;
          warehouseSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 5, rowIndex: detailRow))
                  .value =
              TextCellValue(
                  '${_formatNumber(purchasePriceSyp)} (\$${purchasePriceUsd?.toStringAsFixed(2) ?? "-"})');

          // سعر البيع (ليرة + دولار)
          final salePriceSyp = product?.salePrice ?? 0;
          final salePriceUsd = product?.salePriceUsd;
          warehouseSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 6, rowIndex: detailRow))
                  .value =
              TextCellValue(
                  '${_formatNumber(salePriceSyp)} (\$${salePriceUsd?.toStringAsFixed(2) ?? "-"})');

          warehouseSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 7, rowIndex: detailRow))
              .value = DoubleCellValue(stockValue);

          // تنسيق الصف الزوجي
          if ((detailRow - 4).isEven && !isLowStock) {
            for (var col = 0; col < detailHeaders.length; col++) {
              if (col != 2) {
                warehouseSheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: col, rowIndex: detailRow))
                    .cellStyle = evenRowStyle;
              }
            }
          }

          detailRow++;
        }
      }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // إضافة صف الإجمالي في الملخص
    // ═══════════════════════════════════════════════════════════════════════
    final totalStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
    );

    summarySheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRow))
      ..value = TextCellValue('الإجمالي')
      ..cellStyle = totalStyle;
    summarySheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: summaryRow))
      ..value = IntCellValue(warehouses.length)
      ..cellStyle = totalStyle;
    summarySheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: summaryRow))
      ..value = IntCellValue(grandTotalQuantity)
      ..cellStyle = totalStyle;
    summarySheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: summaryRow))
      ..value = DoubleCellValue(grandTotalValue)
      ..cellStyle = totalStyle;

    // ═══════════════════════════════════════════════════════════════════════
    // حفظ الملف
    // ═══════════════════════════════════════════════════════════════════════
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath =
        '${directory.path}/${fileName ?? 'warehouses_export_$timestamp'}.xlsx';
    final file = File(filePath);

    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }

    return filePath;
  }

  /// مشاركة ملف Excel
  static Future<void> shareExcel({
    required List<Warehouse> warehouses,
    required AppDatabase db,
    String? fileName,
  }) async {
    final filePath = await exportToExcel(
      warehouses: warehouses,
      db: db,
      fileName: fileName,
    );

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'تقرير المستودعات',
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // تصدير PDF
  // ══════════════════════════════════════════════════════════════════════════

  /// إنشاء ملف PDF للمستودعات مع دعم RTL والعربية
  static Future<Uint8List> generatePdf({
    required List<Warehouse> warehouses,
    required AppDatabase db,
    ExportSettings? settings,
  }) async {
    // تهيئة الخطوط العربية من PdfFonts
    await _ensureFontsInitialized();

    final products = await db.getAllProducts();
    final productMap = {for (var p in products) p.id: p};
    final numberFormat = NumberFormat('#,##0', 'ar');

    final doc = pw.Document();
    final now = DateTime.now();

    // ═══════════════════════════════════════════════════════════════════════
    // 1. صفحة الملخص
    // ═══════════════════════════════════════════════════════════════════════
    // تجميع البيانات
    final warehouseDataList = <WarehouseExportData>[];
    double grandTotalValue = 0;
    int grandTotalQuantity = 0;

    for (final warehouse in warehouses) {
      final data = await getWarehouseData(db, warehouse, productMap);
      warehouseDataList.add(data);
      grandTotalValue += data.totalValue;
      grandTotalQuantity += data.totalQuantity;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildPdfHeader(settings, now),
        footer: (context) => _buildPdfFooter(context, settings),
        build: (context) => [
          // العنوان
          pw.Center(
            child: pw.Text(
              'تقرير المستودعات الموحد',
              style: pw.TextStyle(
                font: _fontBold,
                fontSize: 22,
                color: ExportColors.primary,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // إحصائيات عامة
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('عدد المستودعات', '${warehouses.length}'),
                _buildStatItem('إجمالي المنتجات',
                    '${warehouseDataList.fold<int>(0, (sum, d) => sum + d.stock.length)}'),
                _buildStatItem(
                    'إجمالي الكمية', numberFormat.format(grandTotalQuantity)),
                _buildStatItem(
                  'إجمالي القيمة',
                  '${numberFormat.format(grandTotalValue)} ل.س',
                  color: ExportColors.success,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // جدول الملخص مع دعم RTL
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(
                font: _fontBold,
                fontSize: 10,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: ExportColors.primary,
              ),
              cellStyle: pw.TextStyle(font: _font, fontSize: 9),
              cellAlignment: pw.Alignment.center,
              headers: ['الحالة', 'القيمة', 'الكمية', 'المنتجات', 'المستودع'],
              data: warehouseDataList.map((data) {
                return [
                  data.warehouse.isActive ? 'نشط' : 'غير نشط',
                  '${numberFormat.format(data.totalValue)} ل.س',
                  numberFormat.format(data.totalQuantity),
                  '${data.stock.length}',
                  data.warehouse.name,
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );

    // ═══════════════════════════════════════════════════════════════════════
    // 2. صفحة تفصيلية لكل مستودع
    // ═══════════════════════════════════════════════════════════════════════
    for (final data in warehouseDataList) {
      if (data.stock.isEmpty) continue;

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 15),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'مستودع: ${data.warehouse.name}',
                  style: pw.TextStyle(
                    font: _fontBold,
                    fontSize: 16,
                    color: ExportColors.primary,
                  ),
                ),
                pw.Text(
                  'صفحة ${context.pageNumber}',
                  style: pw.TextStyle(
                    font: _font,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          footer: (context) => _buildPdfFooter(context, settings),
          build: (context) => [
            // معلومات المستودع
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('عدد المنتجات', '${data.stock.length}'),
                  _buildStatItem(
                      'إجمالي الكمية', numberFormat.format(data.totalQuantity)),
                  _buildStatItem(
                    'قيمة المخزون',
                    '${numberFormat.format(data.totalValue)} ل.س',
                    color: ExportColors.success,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 15),

            // جدول المخزون مع دعم RTL
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(
                  font: _fontBold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: ExportColors.primary,
                ),
                cellStyle: pw.TextStyle(font: _font, fontSize: 8),
                cellAlignment: pw.Alignment.center,
                headers: [
                  'القيمة',
                  'سعر البيع (ل.س/\$)',
                  'سعر الشراء (ل.س/\$)',
                  'الموقع',
                  'الحد الأدنى',
                  'الكمية',
                  'الباركود',
                  'المنتج',
                ],
                data: data.stock.map((item) {
                  final product = productMap[item.productId];
                  final value = (product?.purchasePrice ?? 0) * item.quantity;

                  // الأسعار بالليرة والدولار
                  final purchaseSyp =
                      numberFormat.format(product?.purchasePrice ?? 0);
                  final purchaseUsd =
                      product?.purchasePriceUsd?.toStringAsFixed(2) ?? '-';
                  final saleSyp = numberFormat.format(product?.salePrice ?? 0);
                  final saleUsd =
                      product?.salePriceUsd?.toStringAsFixed(2) ?? '-';

                  return [
                    numberFormat.format(value),
                    '$saleSyp (\$$saleUsd)',
                    '$purchaseSyp (\$$purchaseUsd)',
                    item.location ?? '-',
                    '${item.minQuantity}',
                    '${item.quantity}',
                    product?.barcode ?? '-',
                    product?.name ?? 'غير معروف',
                  ];
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

    return doc.save();
  }

  /// حفظ ملف PDF
  static Future<String> savePdf({
    required List<Warehouse> warehouses,
    required AppDatabase db,
    ExportSettings? settings,
    String? fileName,
  }) async {
    final bytes = await generatePdf(
      warehouses: warehouses,
      db: db,
      settings: settings,
    );

    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath =
        '${directory.path}/${fileName ?? 'warehouses_report_$timestamp'}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  /// مشاركة ملف PDF
  static Future<void> sharePdf({
    required List<Warehouse> warehouses,
    required AppDatabase db,
    ExportSettings? settings,
    String? fileName,
  }) async {
    final filePath = await savePdf(
      warehouses: warehouses,
      db: db,
      settings: settings,
      fileName: fileName,
    );

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'تقرير المستودعات',
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // مساعدات البناء
  // ══════════════════════════════════════════════════════════════════════════

  static pw.Widget _buildPdfHeader(ExportSettings? settings, DateTime now) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        children: [
          if (settings?.companyName != null)
            pw.Text(
              settings!.companyName!,
              style: pw.TextStyle(font: _fontBold, fontSize: 14),
            ),
          if (settings?.companyAddress != null)
            pw.Text(
              settings!.companyAddress!,
              style: pw.TextStyle(
                  font: _font, fontSize: 10, color: PdfColors.grey700),
            ),
          pw.Text(
            DateFormat('yyyy/MM/dd - HH:mm').format(now),
            style: pw.TextStyle(
                font: _font, fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(
      pw.Context context, ExportSettings? settings) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            settings?.footerMessage ?? 'Hoor',
            style: pw.TextStyle(
                font: _font, fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'صفحة ${context.pageNumber} من ${context.pagesCount}',
            style: pw.TextStyle(
                font: _font, fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatItem(String label, String value,
      {PdfColor? color}) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style:
              pw.TextStyle(font: _font, fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: _fontBold,
            fontSize: 12,
            color: color ?? PdfColors.grey800,
          ),
        ),
      ],
    );
  }

  /// تنظيف اسم الورقة من الأحرف غير المسموحة
  static String _sanitizeSheetName(String name) {
    // إزالة الأحرف غير المسموحة في أسماء أوراق Excel
    var sanitized = name.replaceAll(RegExp(r'[\[\]\*\?\/\\:]'), '');
    // اقتصاص الاسم إلى 31 حرف كحد أقصى
    if (sanitized.length > 31) {
      sanitized = sanitized.substring(0, 31);
    }
    return sanitized.isEmpty ? 'مستودع' : sanitized;
  }

  static String _formatNumber(double value) {
    return NumberFormat('#,##0', 'ar').format(value);
  }
}

/// بيانات مستودع للتصدير
class WarehouseExportData {
  final Warehouse warehouse;
  final List<WarehouseStockData> stock;
  final int totalQuantity;
  final double totalValue;

  WarehouseExportData({
    required this.warehouse,
    required this.stock,
    required this.totalQuantity,
    required this.totalValue,
  });
}
