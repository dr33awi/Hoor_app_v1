import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/database/app_database.dart' hide Category;
import '../../../data/database/app_database.dart' as db show Category;
import 'export_templates.dart';

// Type alias for clarity
typedef DbCategory = db.Category;

/// ═══════════════════════════════════════════════════════════════════════════
/// Excel Export Service - خدمة تصدير Excel الموحدة
/// ═══════════════════════════════════════════════════════════════════════════
class ExcelExportService {
  ExcelExportService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // الأنماط المشتركة
  // ═══════════════════════════════════════════════════════════════════════════

  static CellStyle _headerStyle({String? bgColor}) => CellStyle(
        bold: true,
        backgroundColorHex:
            ExcelColor.fromHexString(bgColor ?? ExcelStyles.headerBgColor),
        fontColorHex: ExcelColor.white,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

  static CellStyle _titleStyle() => CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
      );

  static CellStyle _summaryLabelStyle() => CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Right,
      );

  static CellStyle _summaryValueStyle({String? fontColor}) {
    if (fontColor != null) {
      return CellStyle(
        bold: true,
        fontColorHex: ExcelColor.fromHexString(fontColor),
      );
    }
    return CellStyle(bold: true);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير قائمة الفواتير
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> exportInvoices({
    required List<Invoice> invoices,
    String? type,
    String? fileName,
    Map<String, String>? customerNames,
    Map<String, String>? supplierNames,
  }) async {
    final excel = Excel.createExcel();
    final typeName = type != null
        ? ExportFormatters.getInvoiceTypeLabel(type)
        : 'جميع الفواتير';
    final sheet = excel[typeName];
    excel.delete('Sheet1');

    // حساب الإحصائيات
    double totalAmount = 0;
    double totalDiscount = 0;
    for (final inv in invoices) {
      totalAmount += inv.total;
      totalDiscount += inv.discountAmount;
    }

    int row = 0;

    // ═══════════════════════════════════════════════════════════════════════
    // الترويسة
    // ═══════════════════════════════════════════════════════════════════════
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue(typeName)
      ..cellStyle = _titleStyle();
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row),
    );
    row++;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'تاريخ التصدير: ${ExportFormatters.formatDateTime(DateTime.now())}');
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // ملخص الإحصائيات
    // ═══════════════════════════════════════════════════════════════════════
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('عدد الفواتير:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = IntCellValue(invoices.length)
      ..cellStyle = _summaryValueStyle();
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('إجمالي المبلغ:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(ExportFormatters.formatPrice(totalAmount))
      ..cellStyle = _summaryValueStyle(fontColor: ExcelStyles.successColor);
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('إجمالي الخصومات:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(ExportFormatters.formatPrice(totalDiscount))
      ..cellStyle = _summaryValueStyle(fontColor: ExcelStyles.errorColor);
    row += 2;

    // ═══════════════════════════════════════════════════════════════════════
    // رأس الجدول - مع إضافة سعر الصرف والقيم بالدولار
    // ═══════════════════════════════════════════════════════════════════════
    final headers = [
      '#',
      'رقم الفاتورة',
      'التاريخ',
      'الطرف',
      'النوع',
      'طريقة الدفع',
      'المجموع الفرعي',
      'الخصم',
      'الإجمالي (ل.س)',
      'الإجمالي (\$)',
      'سعر الصرف',
      'الحالة',
    ];

    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
        ..value = TextCellValue(headers[i])
        ..cellStyle = _headerStyle();
    }
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // البيانات - مع القيم المحفوظة بالدولار وسعر الصرف
    // ═══════════════════════════════════════════════════════════════════════
    for (var i = 0; i < invoices.length; i++) {
      final inv = invoices[i];
      // تحديد اسم الطرف - استخدام الاسم الفعلي إن توفر
      String partyName = '-';
      if (inv.customerId != null) {
        partyName = customerNames?[inv.customerId!] ?? 'عميل';
      } else if (inv.supplierId != null) {
        partyName = supplierNames?[inv.supplierId!] ?? 'مورد';
      }
      final rowData = [
        '${i + 1}',
        inv.invoiceNumber,
        ExportFormatters.formatDateTime(inv.invoiceDate),
        partyName,
        ExportFormatters.getInvoiceTypeLabel(inv.type),
        ExportFormatters.getPaymentMethodLabel(inv.paymentMethod),
        ExportFormatters.formatPrice(inv.subtotal, showCurrency: false),
        ExportFormatters.formatPrice(inv.discountAmount, showCurrency: false),
        ExportFormatters.formatPrice(inv.total, showCurrency: false),
        // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة
        inv.totalUsd != null ? '\$${inv.totalUsd!.toStringAsFixed(2)}' : '-',
        inv.exchangeRate != null && inv.exchangeRate! > 0
            ? inv.exchangeRate!.toStringAsFixed(0)
            : '-',
        ExportFormatters.getInvoiceStatusLabel(inv.status),
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
            .value = TextCellValue(rowData[j]);
      }
      row++;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ضبط عرض الأعمدة
    // ═══════════════════════════════════════════════════════════════════════
    sheet.setColumnWidth(0, 5); // #
    sheet.setColumnWidth(1, 20); // رقم الفاتورة
    sheet.setColumnWidth(2, 18); // التاريخ
    sheet.setColumnWidth(3, 18); // الطرف
    sheet.setColumnWidth(4, 12); // النوع
    sheet.setColumnWidth(5, 12); // طريقة الدفع
    sheet.setColumnWidth(6, 14); // المجموع الفرعي
    sheet.setColumnWidth(7, 10); // الخصم
    sheet.setColumnWidth(8, 14); // الإجمالي (ل.س)
    sheet.setColumnWidth(9, 12); // الإجمالي ($)
    sheet.setColumnWidth(10, 12); // سعر الصرف
    sheet.setColumnWidth(11, 10); // الحالة

    return await _saveExcelFile(excel, fileName ?? 'invoices_list');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير تقرير المبيعات
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> exportSalesReport({
    required List<Invoice> invoices,
    required DateTime startDate,
    required DateTime endDate,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير المبيعات'];
    excel.delete('Sheet1');

    // حساب الإحصائيات
    double totalSales = 0;
    double totalReturns = 0;
    double totalDiscount = 0;

    for (final inv in invoices) {
      if (inv.type == 'sale') {
        totalSales += inv.total;
      } else if (inv.type == 'sale_return') {
        totalReturns += inv.total;
      }
      totalDiscount += inv.discountAmount;
    }

    int row = 0;

    // ═══════════════════════════════════════════════════════════════════════
    // الترويسة
    // ═══════════════════════════════════════════════════════════════════════
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('تقرير المبيعات')
      ..cellStyle = _titleStyle();
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row),
    );
    row++;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'الفترة: ${ExportFormatters.formatDateRange(startDate, endDate)}');
    row++;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'تاريخ التصدير: ${ExportFormatters.formatDateTime(DateTime.now())}');
    row += 2;

    // ═══════════════════════════════════════════════════════════════════════
    // ملخص الإحصائيات
    // ═══════════════════════════════════════════════════════════════════════
    _addSummaryRow(
        sheet, row++, 'إجمالي المبيعات:', totalSales, ExcelStyles.successColor);
    _addSummaryRow(sheet, row++, 'إجمالي المرتجعات:', totalReturns,
        ExcelStyles.errorColor);
    _addSummaryRow(sheet, row++, 'إجمالي الخصومات:', totalDiscount,
        ExcelStyles.warningColor);
    _addSummaryRow(sheet, row++, 'صافي المبيعات:', totalSales - totalReturns,
        ExcelStyles.successColor);
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // رأس الجدول
    // ═══════════════════════════════════════════════════════════════════════
    final headers = [
      'رقم الفاتورة',
      'التاريخ',
      'النوع',
      'طريقة الدفع',
      'المجموع الفرعي',
      'الخصم',
      'الإجمالي',
    ];

    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
        ..value = TextCellValue(headers[i])
        ..cellStyle = _headerStyle(bgColor: ExcelStyles.successColor);
    }
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // البيانات
    // ═══════════════════════════════════════════════════════════════════════
    for (final inv in invoices) {
      final rowData = [
        inv.invoiceNumber,
        ExportFormatters.formatDateTime(inv.invoiceDate),
        ExportFormatters.getInvoiceTypeLabel(inv.type),
        ExportFormatters.getPaymentMethodLabel(inv.paymentMethod),
        ExportFormatters.formatPrice(inv.subtotal, showCurrency: false),
        ExportFormatters.formatPrice(inv.discountAmount, showCurrency: false),
        ExportFormatters.formatPrice(inv.total, showCurrency: false),
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
            .value = TextCellValue(rowData[j]);
      }
      row++;
    }

    // ضبط عرض الأعمدة
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 18);
    }

    return await _saveExcelFile(excel, fileName ?? 'sales_report');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير تقرير المخزون
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> exportInventoryReport({
    required List<Product> products,
    Map<String, int>? soldQuantities,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير المخزون'];
    excel.delete('Sheet1');

    // حساب الإحصائيات
    double totalCostValue = 0;
    double totalSaleValue = 0;
    int totalQuantity = 0;
    int lowStockCount = 0;
    int outOfStockCount = 0;

    for (final p in products) {
      totalCostValue += p.purchasePrice * p.quantity;
      totalSaleValue += p.salePrice * p.quantity;
      totalQuantity += p.quantity;
      if (p.quantity <= 0) {
        outOfStockCount++;
      } else if (p.quantity <= p.minQuantity) {
        lowStockCount++;
      }
    }

    int row = 0;

    // ═══════════════════════════════════════════════════════════════════════
    // الترويسة
    // ═══════════════════════════════════════════════════════════════════════
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('تقرير المخزون')
      ..cellStyle = _titleStyle();
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row),
    );
    row++;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'تاريخ التقرير: ${ExportFormatters.formatDateTime(DateTime.now())}');
    row += 2;

    // ═══════════════════════════════════════════════════════════════════════
    // ملخص الإحصائيات
    // ═══════════════════════════════════════════════════════════════════════
    _addSummaryRow(
        sheet, row++, 'عدد المنتجات:', products.length.toDouble(), null);
    _addSummaryRow(
        sheet, row++, 'إجمالي الكميات:', totalQuantity.toDouble(), null);
    _addSummaryRow(sheet, row++, 'قيمة التكلفة:', totalCostValue,
        ExcelStyles.headerBgColor);
    _addSummaryRow(
        sheet, row++, 'قيمة البيع:', totalSaleValue, ExcelStyles.successColor);
    _addSummaryRow(sheet, row++, 'الربح المتوقع:',
        totalSaleValue - totalCostValue, ExcelStyles.successColor);
    _addSummaryRow(sheet, row++, 'نقص مخزون:', lowStockCount.toDouble(),
        ExcelStyles.warningColor);
    _addSummaryRow(sheet, row++, 'نفذ المخزون:', outOfStockCount.toDouble(),
        ExcelStyles.errorColor);
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // رأس الجدول
    // ═══════════════════════════════════════════════════════════════════════
    final headers = [
      'اسم المنتج',
      'الباركود',
      'الكمية',
      'المباع',
      'الحد الأدنى',
      'سعر الشراء',
      'سعر البيع',
      'قيمة المخزون',
      'الحالة',
    ];

    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
        ..value = TextCellValue(headers[i])
        ..cellStyle = _headerStyle(bgColor: ExcelStyles.warningColor);
    }
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // البيانات
    // ═══════════════════════════════════════════════════════════════════════
    for (final p in products) {
      String status;
      if (p.quantity <= 0) {
        status = 'نفذ المخزون';
      } else if (p.quantity <= p.minQuantity) {
        status = 'نقص مخزون';
      } else {
        status = 'متوفر';
      }

      final soldQty = soldQuantities?[p.id] ?? 0;
      final inventoryValue = p.purchasePrice * p.quantity;
      final rowData = [
        p.name,
        p.barcode ?? '-',
        '${p.quantity}',
        '$soldQty',
        '${p.minQuantity}',
        ExportFormatters.formatPrice(p.purchasePrice, showCurrency: false),
        ExportFormatters.formatPrice(p.salePrice, showCurrency: false),
        ExportFormatters.formatPrice(inventoryValue, showCurrency: false),
        status,
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
            .value = TextCellValue(rowData[j]);
      }
      row++;
    }

    // ضبط عرض الأعمدة
    sheet.setColumnWidth(0, 30);
    for (var i = 1; i < headers.length; i++) {
      sheet.setColumnWidth(i, 16);
    }

    return await _saveExcelFile(excel, fileName ?? 'inventory_report');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير قائمة المنتجات
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> exportProducts({
    required List<Product> products,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['قائمة المنتجات'];
    excel.delete('Sheet1');

    int row = 0;

    // الترويسة
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('قائمة المنتجات')
      ..cellStyle = _titleStyle();
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row),
    );
    row++;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'تاريخ التصدير: ${ExportFormatters.formatDateTime(DateTime.now())}');
    row++;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('إجمالي المنتجات: ${products.length}');
    row += 2;

    // رأس الجدول
    final headers = [
      '#',
      'اسم المنتج',
      'الباركود',
      'سعر الشراء',
      'سعر البيع',
      'الكمية',
      'الحد الأدنى',
      'الحالة',
    ];

    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
        ..value = TextCellValue(headers[i])
        ..cellStyle = _headerStyle();
    }
    row++;

    // البيانات
    for (var i = 0; i < products.length; i++) {
      final p = products[i];
      String status;
      if (p.quantity <= 0) {
        status = 'نفذ المخزون';
      } else if (p.quantity <= p.minQuantity) {
        status = 'نقص مخزون';
      } else {
        status = 'متوفر';
      }

      final rowData = [
        '${i + 1}',
        p.name,
        p.barcode ?? '-',
        ExportFormatters.formatPrice(p.purchasePrice, showCurrency: false),
        ExportFormatters.formatPrice(p.salePrice, showCurrency: false),
        '${p.quantity}',
        '${p.minQuantity}',
        status,
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
            .value = TextCellValue(rowData[j]);
      }
      row++;
    }

    // ضبط عرض الأعمدة
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 30);
    for (var i = 2; i < headers.length; i++) {
      sheet.setColumnWidth(i, 15);
    }

    return await _saveExcelFile(excel, fileName ?? 'products_list');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير السندات
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> exportVouchers({
    required List<Voucher> vouchers,
    String? type,
    String? fileName,
    Map<String, String>? customerNames,
    Map<String, String>? supplierNames,
  }) async {
    final excel = Excel.createExcel();
    final typeName = type != null ? _getVoucherTypeLabel(type) : 'جميع السندات';
    final sheet = excel[typeName];
    excel.delete('Sheet1');

    // حساب الإحصائيات
    double totalAmount = 0;
    for (final v in vouchers) {
      totalAmount += v.amount;
    }

    int row = 0;

    // الترويسة
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue(typeName)
      ..cellStyle = _titleStyle();
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row),
    );
    row++;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'تاريخ التصدير: ${ExportFormatters.formatDateTime(DateTime.now())}');
    row++;

    // ملخص
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('عدد السندات:')
      ..cellStyle = _summaryLabelStyle();
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = IntCellValue(vouchers.length);
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('المجموع:')
      ..cellStyle = _summaryLabelStyle();
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(ExportFormatters.formatPrice(totalAmount));
    row += 2;

    // رأس الجدول - مع إضافة الطرف وسعر الصرف
    final headers = [
      '#',
      'رقم السند',
      'النوع',
      'الطرف',
      'التاريخ',
      'المبلغ (ل.س)',
      'المبلغ (\$)',
      'سعر الصرف',
      'الوصف',
    ];

    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
        ..value = TextCellValue(headers[i])
        ..cellStyle = _headerStyle();
    }
    row++;

    // البيانات - مع القيم المحفوظة
    for (var i = 0; i < vouchers.length; i++) {
      final v = vouchers[i];
      // تحديد اسم الطرف - استخدام الاسم الفعلي إن توفر
      String partyName = '-';
      if (v.customerId != null) {
        partyName = customerNames?[v.customerId!] ?? 'عميل #${v.customerId}';
      } else if (v.supplierId != null) {
        partyName = supplierNames?[v.supplierId!] ?? 'مورد #${v.supplierId}';
      }

      final rowData = [
        '${i + 1}',
        v.voucherNumber,
        _getVoucherTypeLabel(v.type),
        partyName,
        ExportFormatters.formatDate(v.voucherDate),
        ExportFormatters.formatPrice(v.amount, showCurrency: false),
        // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة
        v.amountUsd != null ? '\$${v.amountUsd!.toStringAsFixed(2)}' : '-',
        v.exchangeRate > 0 ? v.exchangeRate.toStringAsFixed(0) : '-',
        v.description ?? '',
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
            .value = TextCellValue(rowData[j]);
      }
      row++;
    }

    // ضبط عرض الأعمدة
    sheet.setColumnWidth(0, 5); // #
    sheet.setColumnWidth(1, 15); // رقم السند
    sheet.setColumnWidth(2, 12); // النوع
    sheet.setColumnWidth(3, 12); // الطرف
    sheet.setColumnWidth(4, 15); // التاريخ
    sheet.setColumnWidth(5, 15); // المبلغ (ل.س)
    sheet.setColumnWidth(6, 12); // المبلغ ($)
    sheet.setColumnWidth(7, 12); // سعر الصرف
    sheet.setColumnWidth(8, 28); // الوصف

    return await _saveExcelFile(excel, fileName ?? 'vouchers_list');
  }

  static String _getVoucherTypeLabel(String type) {
    switch (type) {
      case 'receipt':
        return 'سند قبض';
      case 'payment':
        return 'سند دفع';
      case 'expense':
        return 'سند مصاريف';
      default:
        return type;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // دوال مساعدة
  // ═══════════════════════════════════════════════════════════════════════════

  static void _addSummaryRow(
      Sheet sheet, int row, String label, double value, String? color,
      {String? prefix}) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue(label)
      ..cellStyle = _summaryLabelStyle();
    final valueText = prefix != null
        ? '$prefix${value.toStringAsFixed(2)}'
        : ExportFormatters.formatPrice(value);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(valueText)
      ..cellStyle = _summaryValueStyle(fontColor: color);
  }

  static Future<String> _saveExcelFile(Excel excel, String fileName) async {
    final timestamp =
        '${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}_${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}';

    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final filePath = '${exportDir.path}/${fileName}_$timestamp.xlsx';
    final fileBytes = excel.save();

    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      debugPrint('Excel file saved: $filePath');
      return filePath;
    }

    throw Exception('فشل في إنشاء ملف Excel');
  }

  /// مشاركة ملف Excel
  static Future<void> shareFile(String filePath, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject ?? 'تقرير Excel',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير كشف حساب العميل
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> exportCustomerStatement({
    required dynamic customer,
    required List<dynamic> invoices,
    required List<dynamic> vouchers,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['كشف حساب'];
    excel.delete('Sheet1');

    int row = 0;

    // العنوان
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('كشف حساب العميل: ${customer.name}')
      ..cellStyle = _titleStyle();
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row),
    );
    row += 2;

    // معلومات العميل
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('الهاتف: ${customer.phone ?? "غير محدد"}');
    row++;
    // ⚠️ السياسة المحاسبية: عرض الرصيد بالليرة فقط أو استخدام balanceUsd المحفوظ
    final customerBalanceUsdText = customer.balanceUsd != null
        ? ' (\$${customer.balanceUsd.toStringAsFixed(2)})'
        : '';
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'الرصيد الحالي: ${customer.balance.toStringAsFixed(0)} ل.س$customerBalanceUsdText');
    row += 2;

    // رأس الجدول
    final headers = ['التاريخ', 'البيان', 'مدين', 'دائن', 'الرصيد'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
        ..value = TextCellValue(headers[i])
        ..cellStyle = _headerStyle();
    }
    row++;

    // دمج البيانات
    final List<Map<String, dynamic>> entries = [];

    for (final invoice in invoices) {
      entries.add({
        'date': invoice.createdAt,
        'description': 'فاتورة #${invoice.invoiceNumber}',
        'debit': invoice.total,
        'credit': 0.0,
      });
    }

    for (final voucher in vouchers) {
      entries.add({
        'date': voucher.voucherDate,
        'description': 'سند قبض #${voucher.voucherNumber}',
        'debit': 0.0,
        'credit': voucher.amount,
      });
    }

    // ترتيب حسب التاريخ
    entries.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // حساب الرصيد التراكمي
    double runningBalance = 0;
    for (final entry in entries) {
      runningBalance +=
          (entry['debit'] as double) - (entry['credit'] as double);

      final rowData = [
        ExportFormatters.formatDate(entry['date'] as DateTime),
        entry['description'] as String,
        (entry['debit'] as double) > 0
            ? (entry['debit'] as double).toStringAsFixed(0)
            : '-',
        (entry['credit'] as double) > 0
            ? (entry['credit'] as double).toStringAsFixed(0)
            : '-',
        runningBalance.toStringAsFixed(0),
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
            .value = TextCellValue(rowData[j]);
      }
      row++;
    }

    // ضبط عرض الأعمدة
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 25);
    sheet.setColumnWidth(2, 12);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 12);

    return await _saveExcelFile(excel, fileName ?? 'customer_statement');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير كشف حساب المورد
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> exportSupplierStatement({
    required dynamic supplier,
    required List<dynamic> invoices,
    required List<dynamic> vouchers,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['كشف حساب'];
    excel.delete('Sheet1');

    int row = 0;

    // العنوان
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('كشف حساب المورد: ${supplier.name}')
      ..cellStyle = _titleStyle();
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row),
    );
    row += 2;

    // معلومات المورد
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('الهاتف: ${supplier.phone ?? "غير محدد"}');
    row++;
    // ⚠️ السياسة المحاسبية: عرض الرصيد بالليرة فقط أو استخدام balanceUsd المحفوظ
    final supplierBalanceUsdText = supplier.balanceUsd != null
        ? ' (\$${supplier.balanceUsd.toStringAsFixed(2)})'
        : '';
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'الرصيد الحالي: ${supplier.balance.toStringAsFixed(0)} ل.س$supplierBalanceUsdText');
    row += 2;

    // رأس الجدول
    final headers = ['التاريخ', 'البيان', 'مدين', 'دائن', 'الرصيد'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
        ..value = TextCellValue(headers[i])
        ..cellStyle = _headerStyle();
    }
    row++;

    // دمج البيانات
    final List<Map<String, dynamic>> entries = [];

    for (final invoice in invoices) {
      entries.add({
        'date': invoice.createdAt,
        'description': 'فاتورة مشتريات #${invoice.invoiceNumber}',
        'debit': invoice.total,
        'credit': 0.0,
      });
    }

    for (final voucher in vouchers) {
      entries.add({
        'date': voucher.voucherDate,
        'description': 'سند صرف #${voucher.voucherNumber}',
        'debit': 0.0,
        'credit': voucher.amount,
      });
    }

    // ترتيب حسب التاريخ
    entries.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // حساب الرصيد التراكمي
    double runningBalance = 0;
    for (final entry in entries) {
      runningBalance +=
          (entry['debit'] as double) - (entry['credit'] as double);

      final rowData = [
        ExportFormatters.formatDate(entry['date'] as DateTime),
        entry['description'] as String,
        (entry['debit'] as double) > 0
            ? (entry['debit'] as double).toStringAsFixed(0)
            : '-',
        (entry['credit'] as double) > 0
            ? (entry['credit'] as double).toStringAsFixed(0)
            : '-',
        runningBalance.toStringAsFixed(0),
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
            .value = TextCellValue(rowData[j]);
      }
      row++;
    }

    // ضبط عرض الأعمدة
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 25);
    sheet.setColumnWidth(2, 12);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 12);

    return await _saveExcelFile(excel, fileName ?? 'supplier_statement');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير التصنيفات
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> exportCategories({
    required List<DbCategory> categories,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['التصنيفات'];
    excel.delete('Sheet1');

    int row = 0;

    // ═══════════════════════════════════════════════════════════════════════
    // الترويسة
    // ═══════════════════════════════════════════════════════════════════════
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('قائمة التصنيفات')
      ..cellStyle = _titleStyle();
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row),
    );
    row++;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'تاريخ التصدير: ${ExportFormatters.formatDateTime(DateTime.now())}');
    row++;

    // ملخص
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('عدد التصنيفات:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(categories.length.toString())
      ..cellStyle = _summaryValueStyle();
    row += 2;

    // ═══════════════════════════════════════════════════════════════════════
    // عناوين الأعمدة
    // ═══════════════════════════════════════════════════════════════════════
    final headers = ['#', 'الاسم', 'الوصف', 'تاريخ الإنشاء'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
        ..value = TextCellValue(headers[i])
        ..cellStyle = _headerStyle();
    }
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // البيانات
    // ═══════════════════════════════════════════════════════════════════════
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      final rowData = [
        (i + 1).toString(),
        category.name,
        category.description ?? '-',
        ExportFormatters.formatDate(category.createdAt),
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
            .value = TextCellValue(rowData[j]);
      }
      row++;
    }

    // ضبط عرض الأعمدة
    sheet.setColumnWidth(0, 5);
    sheet.setColumnWidth(1, 25);
    sheet.setColumnWidth(2, 35);
    sheet.setColumnWidth(3, 15);

    return await _saveExcelFile(excel, fileName ?? 'categories');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير حركات الصندوق
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> exportCashMovements({
    required List<CashMovement> movements,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['حركات الصندوق'];
    excel.delete('Sheet1');

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

    int row = 0;

    // ═══════════════════════════════════════════════════════════════════════
    // الترويسة
    // ═══════════════════════════════════════════════════════════════════════
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('حركات الصندوق')
      ..cellStyle = _titleStyle();
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row),
    );
    row++;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'تاريخ التصدير: ${ExportFormatters.formatDateTime(DateTime.now())}');
    row++;

    // ملخص - مع USD
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('عدد الحركات:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(movements.length.toString())
      ..cellStyle = _summaryValueStyle();
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('إجمالي الإيرادات:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(
          '${ExportFormatters.formatPrice(totalIncome, showCurrency: false)} | \$${totalIncomeUsd.toStringAsFixed(2)}')
      ..cellStyle = _summaryValueStyle(fontColor: ExcelStyles.successColor);
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('إجمالي المصروفات:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(
          '${ExportFormatters.formatPrice(totalExpense, showCurrency: false)} | \$${totalExpenseUsd.toStringAsFixed(2)}')
      ..cellStyle = _summaryValueStyle(fontColor: ExcelStyles.errorColor);
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('الصافي:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(
          '${ExportFormatters.formatPrice(totalIncome - totalExpense, showCurrency: false)} | \$${(totalIncomeUsd - totalExpenseUsd).toStringAsFixed(2)}')
      ..cellStyle = _summaryValueStyle(
        fontColor: totalIncome >= totalExpense
            ? ExcelStyles.successColor
            : ExcelStyles.errorColor,
      );
    row += 2;

    // ═══════════════════════════════════════════════════════════════════════
    // عناوين الأعمدة - مع USD
    // ═══════════════════════════════════════════════════════════════════════
    final headers = [
      '#',
      'التاريخ',
      'الوصف',
      'النوع',
      'المبلغ (ل.س)',
      'المبلغ (\$)',
      'سعر الصرف'
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
        ..value = TextCellValue(headers[i])
        ..cellStyle = _headerStyle();
    }
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // البيانات - مع القيم المحفوظة بالدولار
    // ═══════════════════════════════════════════════════════════════════════
    for (var i = 0; i < movements.length; i++) {
      final movement = movements[i];
      final isIncome = movement.type == 'income' ||
          movement.type == 'sale' ||
          movement.type == 'deposit' ||
          movement.type == 'opening';

      final rowData = [
        (i + 1).toString(),
        ExportFormatters.formatDateTime(movement.createdAt),
        movement.description,
        isIncome ? 'إيراد' : 'مصروف',
        '${isIncome ? '+' : '-'}${ExportFormatters.formatPrice(movement.amount, showCurrency: false)}',
        // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة
        movement.amountUsd != null
            ? '${isIncome ? '+' : '-'}\$${movement.amountUsd!.toStringAsFixed(2)}'
            : '-',
        movement.exchangeRate != null && movement.exchangeRate! > 0
            ? movement.exchangeRate!.toStringAsFixed(0)
            : '-',
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
            .value = TextCellValue(rowData[j]);
      }
      row++;
    }

    // ضبط عرض الأعمدة
    sheet.setColumnWidth(0, 5); // #
    sheet.setColumnWidth(1, 18); // التاريخ
    sheet.setColumnWidth(2, 28); // الوصف
    sheet.setColumnWidth(3, 10); // النوع
    sheet.setColumnWidth(4, 14); // المبلغ (ل.س)
    sheet.setColumnWidth(5, 12); // المبلغ ($)
    sheet.setColumnWidth(6, 12); // سعر الصرف

    return await _saveExcelFile(excel, fileName ?? 'cash_movements');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تصدير الورديات
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> exportShifts({
    required List<Shift> shifts,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['الورديات'];
    excel.delete('Sheet1');

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

    int row = 0;

    // ═══════════════════════════════════════════════════════════════════════
    // الترويسة
    // ═══════════════════════════════════════════════════════════════════════
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('قائمة الورديات')
      ..cellStyle = _titleStyle();
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row),
    );
    row++;

    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value =
        TextCellValue(
            'تاريخ التصدير: ${ExportFormatters.formatDateTime(DateTime.now())}');
    row++;

    // ملخص - مع USD
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('عدد الورديات:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(shifts.length.toString())
      ..cellStyle = _summaryValueStyle();
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('إجمالي المبيعات:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(
          '${ExportFormatters.formatPrice(totalSales, showCurrency: false)} | \$${totalSalesUsd.toStringAsFixed(2)}')
      ..cellStyle = _summaryValueStyle(fontColor: ExcelStyles.successColor);
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('إجمالي المصروفات:')
      ..cellStyle = _summaryLabelStyle();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = TextCellValue(
          '${ExportFormatters.formatPrice(totalExpenses, showCurrency: false)} | \$${totalExpensesUsd.toStringAsFixed(2)}')
      ..cellStyle = _summaryValueStyle(fontColor: ExcelStyles.errorColor);
    row += 2;

    // ═══════════════════════════════════════════════════════════════════════
    // عناوين الأعمدة - مع USD
    // ═══════════════════════════════════════════════════════════════════════
    final headers = [
      '#',
      'رقم الوردية',
      'تاريخ الافتتاح',
      'الرصيد الافتتاحي',
      'المبيعات (ل.س)',
      'المبيعات (\$)',
      'المصروفات (ل.س)',
      'المصروفات (\$)',
      'سعر الصرف',
      'الحالة'
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
        ..value = TextCellValue(headers[i])
        ..cellStyle = _headerStyle();
    }
    row++;

    // ═══════════════════════════════════════════════════════════════════════
    // البيانات - مع القيم المحفوظة بالدولار
    // ═══════════════════════════════════════════════════════════════════════
    for (var i = 0; i < shifts.length; i++) {
      final shift = shifts[i];

      final rowData = [
        (i + 1).toString(),
        '#${shift.shiftNumber}',
        ExportFormatters.formatDateTime(shift.openedAt),
        ExportFormatters.formatPrice(shift.openingBalance, showCurrency: false),
        ExportFormatters.formatPrice(shift.totalSales, showCurrency: false),
        // ⚠️ السياسة المحاسبية: استخدام القيم المحفوظة
        '\$${shift.totalSalesUsd.toStringAsFixed(2)}',
        ExportFormatters.formatPrice(shift.totalExpenses, showCurrency: false),
        '\$${shift.totalExpensesUsd.toStringAsFixed(2)}',
        shift.exchangeRate != null && shift.exchangeRate! > 0
            ? shift.exchangeRate!.toStringAsFixed(0)
            : '-',
        shift.status == 'open' ? 'مفتوحة' : 'مغلقة',
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row))
            .value = TextCellValue(rowData[j]);
      }
      row++;
    }

    // ضبط عرض الأعمدة
    sheet.setColumnWidth(0, 5); // #
    sheet.setColumnWidth(1, 12); // رقم الوردية
    sheet.setColumnWidth(2, 18); // تاريخ الافتتاح
    sheet.setColumnWidth(3, 15); // الرصيد الافتتاحي
    sheet.setColumnWidth(4, 14); // المبيعات (ل.س)
    sheet.setColumnWidth(5, 12); // المبيعات ($)
    sheet.setColumnWidth(6, 14); // المصروفات (ل.س)
    sheet.setColumnWidth(7, 12); // المصروفات ($)
    sheet.setColumnWidth(8, 12); // سعر الصرف
    sheet.setColumnWidth(9, 10); // الحالة

    return await _saveExcelFile(excel, fileName ?? 'shifts');
  }
}
