import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../printing/pdf_theme.dart';
import './export_templates.dart';
import '../../../data/database/app_database.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// خدمة تصدير التقارير - Reports Export Service
/// تستخدم PdfFonts لدعم اللغة العربية و export_templates للقوالب الموحدة
/// ═══════════════════════════════════════════════════════════════════════════
class ReportsExportService {
  // ══════════════════════════════════════════════════════════════════════════
  // تصدير تقرير المبيعات
  // ══════════════════════════════════════════════════════════════════════════

  /// تصدير تقرير المبيعات إلى Excel
  static Future<String> exportSalesReportToExcel({
    required List<Invoice> invoices,
    DateTimeRange? dateRange,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير المبيعات'];
    excel.delete('Sheet1');

    // استخدام ألوان موحدة من ExcelStyles
    final headerStyle = CellStyle(
      backgroundColorHex:
          ExcelColor.fromHexString('#${ExcelStyles.successColor.substring(2)}'),
      fontColorHex: ExcelColor.fromHexString(
          '#${ExcelStyles.headerTextColor.substring(2)}'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    final headers = [
      '#',
      'رقم الفاتورة',
      'التاريخ',
      'العميل',
      'الإجمالي',
      'المدفوع',
      'المتبقي',
      'حالة الدفع'
    ];
    _writeExcelHeaders(sheet, headers, headerStyle);

    // ═══════════════════════════════════════════════════════════════════════
    // السياسة المحاسبية: استخدام القيم المحفوظة (SYP + USD) بدون تحويل
    // ═══════════════════════════════════════════════════════════════════════
    double totalSalesSyp = 0;
    double totalSalesUsd = 0;
    double totalPaidSyp = 0;
    double totalPaidUsd = 0;

    for (var i = 0; i < invoices.length; i++) {
      final inv = invoices[i];
      totalSalesSyp += inv.total;
      totalSalesUsd += inv.totalUsd ?? 0;
      totalPaidSyp += inv.paidAmount;
      totalPaidUsd += inv.paidAmountUsd ?? 0;

      _writeExcelRow(sheet, i + 1, [
        (i + 1).toString(),
        inv.invoiceNumber,
        ExportFormatters.formatDate(inv.invoiceDate),
        inv.customerId ?? 'نقدي',
        // استخدام القيم المحفوظة مباشرة
        ExportFormatters.formatDualPriceFromLocked(inv.total, inv.totalUsd ?? 0,
            showCurrency: false),
        ExportFormatters.formatDualPriceFromLocked(
            inv.paidAmount, inv.paidAmountUsd ?? 0,
            showCurrency: false),
        ExportFormatters.formatDualPriceFromLocked(inv.total - inv.paidAmount,
            (inv.totalUsd ?? 0) - (inv.paidAmountUsd ?? 0),
            showCurrency: false),
        _getPaymentStatusText(inv.total, inv.paidAmount),
      ]);
    }

    // Summary row - استخدام القيم المحفوظة
    _writeExcelSummary(
        sheet,
        invoices.length + 2,
        3,
        'الإجمالي:',
        [
          ExportFormatters.formatDualPriceFromLocked(
              totalSalesSyp, totalSalesUsd,
              showCurrency: false),
          ExportFormatters.formatDualPriceFromLocked(totalPaidSyp, totalPaidUsd,
              showCurrency: false),
          ExportFormatters.formatDualPriceFromLocked(
              totalSalesSyp - totalPaidSyp, totalSalesUsd - totalPaidUsd,
              showCurrency: false),
        ],
        ExcelStyles.successColor);

    _setExcelColumnWidths(sheet, [5, 20, 15, 20, 20, 20, 20, 12]);

    return await _saveExcelFile(excel, fileName ?? 'sales_report');
  }

  /// تصدير تقرير المبيعات إلى PDF
  static Future<Uint8List> generateSalesReportPdf({
    required List<Invoice> invoices,
    DateTimeRange? dateRange,
  }) async {
    await PdfFonts.init();

    final template = PdfReportTemplate(
      title: 'تقرير المبيعات',
      subtitle: dateRange != null
          ? ExportFormatters.formatDateRange(dateRange.start, dateRange.end)
          : null,
      reportDate: DateTime.now(),
      headerColor: ExportColors.success,
    );

    // ═══════════════════════════════════════════════════════════════════════
    // السياسة المحاسبية: استخدام القيم المحفوظة (SYP + USD) بدون تحويل
    // ═══════════════════════════════════════════════════════════════════════
    double totalSalesSyp = invoices.fold(0.0, (sum, inv) => sum + inv.total);
    double totalSalesUsd =
        invoices.fold(0.0, (sum, inv) => sum + (inv.totalUsd ?? 0));
    double totalPaidSyp =
        invoices.fold(0.0, (sum, inv) => sum + inv.paidAmount);
    double totalPaidUsd =
        invoices.fold(0.0, (sum, inv) => sum + (inv.paidAmountUsd ?? 0));

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => template.buildHeader(),
        footer: (context) => template.buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          // Statistics Box - استخدام القيم المحفوظة
          template.buildStatsBox([
            StatItem(
              label: 'إجمالي المبيعات',
              value: ExportFormatters.formatDualPriceFromLocked(
                  totalSalesSyp, totalSalesUsd),
              color: ExportColors.success,
            ),
            StatItem(
              label: 'المدفوع',
              value: ExportFormatters.formatDualPriceFromLocked(
                  totalPaidSyp, totalPaidUsd),
              color: ExportColors.info,
            ),
            StatItem(
              label: 'المتبقي',
              value: ExportFormatters.formatDualPriceFromLocked(
                  totalSalesSyp - totalPaidSyp, totalSalesUsd - totalPaidUsd),
              color: ExportColors.warning,
            ),
            StatItem(
              label: 'عدد الفواتير',
              value: '${invoices.length}',
            ),
          ]),
          pw.SizedBox(height: 20),

          // Table - استخدام القيم المحفوظة
          template.buildTable(
            headers: ['#', 'رقم الفاتورة', 'التاريخ', 'الإجمالي', 'حالة الدفع'],
            data: List.generate(invoices.length, (i) {
              final inv = invoices[i];
              return [
                '${i + 1}',
                inv.invoiceNumber,
                ExportFormatters.formatDate(inv.invoiceDate),
                ExportFormatters.formatDualPriceFromLocked(
                    inv.total, inv.totalUsd ?? 0),
                _getPaymentStatusText(inv.total, inv.paidAmount),
              ];
            }),
            headerBgColor: ExportColors.success,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // تصدير تقرير المشتريات
  // ══════════════════════════════════════════════════════════════════════════

  /// تصدير تقرير المشتريات إلى Excel
  static Future<String> exportPurchasesReportToExcel({
    required List<Invoice> invoices,
    DateTimeRange? dateRange,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير المشتريات'];
    excel.delete('Sheet1');

    final headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString(
          '#${ExcelStyles.purchaseColor.substring(2)}'),
      fontColorHex: ExcelColor.fromHexString(
          '#${ExcelStyles.headerTextColor.substring(2)}'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    final headers = [
      '#',
      'رقم الفاتورة',
      'التاريخ',
      'المورد',
      'الإجمالي',
      'المدفوع',
      'المتبقي',
      'حالة الدفع'
    ];
    _writeExcelHeaders(sheet, headers, headerStyle);

    // ═══════════════════════════════════════════════════════════════════════
    // السياسة المحاسبية: استخدام القيم المحفوظة (SYP + USD) بدون تحويل
    // ═══════════════════════════════════════════════════════════════════════
    double totalPurchasesSyp = 0;
    double totalPurchasesUsd = 0;
    double totalPaidSyp = 0;
    double totalPaidUsd = 0;

    for (var i = 0; i < invoices.length; i++) {
      final inv = invoices[i];
      totalPurchasesSyp += inv.total;
      totalPurchasesUsd += inv.totalUsd ?? 0;
      totalPaidSyp += inv.paidAmount;
      totalPaidUsd += inv.paidAmountUsd ?? 0;

      _writeExcelRow(sheet, i + 1, [
        (i + 1).toString(),
        inv.invoiceNumber,
        ExportFormatters.formatDate(inv.invoiceDate),
        inv.supplierId ?? '-',
        ExportFormatters.formatDualPriceFromLocked(inv.total, inv.totalUsd ?? 0,
            showCurrency: false),
        ExportFormatters.formatDualPriceFromLocked(
            inv.paidAmount, inv.paidAmountUsd ?? 0,
            showCurrency: false),
        ExportFormatters.formatDualPriceFromLocked(inv.total - inv.paidAmount,
            (inv.totalUsd ?? 0) - (inv.paidAmountUsd ?? 0),
            showCurrency: false),
        _getPaymentStatusText(inv.total, inv.paidAmount),
      ]);
    }

    _writeExcelSummary(
        sheet,
        invoices.length + 2,
        3,
        'الإجمالي:',
        [
          ExportFormatters.formatDualPriceFromLocked(
              totalPurchasesSyp, totalPurchasesUsd,
              showCurrency: false),
          ExportFormatters.formatDualPriceFromLocked(totalPaidSyp, totalPaidUsd,
              showCurrency: false),
          ExportFormatters.formatDualPriceFromLocked(
              totalPurchasesSyp - totalPaidSyp,
              totalPurchasesUsd - totalPaidUsd,
              showCurrency: false),
        ],
        ExcelStyles.purchaseColor);

    _setExcelColumnWidths(sheet, [5, 20, 15, 20, 20, 20, 20, 12]);

    return await _saveExcelFile(excel, fileName ?? 'purchases_report');
  }

  /// تصدير تقرير المشتريات إلى PDF
  static Future<Uint8List> generatePurchasesReportPdf({
    required List<Invoice> invoices,
    DateTimeRange? dateRange,
  }) async {
    await PdfFonts.init();

    final template = PdfReportTemplate(
      title: 'تقرير المشتريات',
      subtitle: dateRange != null
          ? ExportFormatters.formatDateRange(dateRange.start, dateRange.end)
          : null,
      reportDate: DateTime.now(),
      headerColor: ExportColors.purchase,
    );

    // ═══════════════════════════════════════════════════════════════════════
    // السياسة المحاسبية: استخدام القيم المحفوظة (SYP + USD) بدون تحويل
    // ═══════════════════════════════════════════════════════════════════════
    double totalPurchasesSyp =
        invoices.fold(0.0, (sum, inv) => sum + inv.total);
    double totalPurchasesUsd =
        invoices.fold(0.0, (sum, inv) => sum + (inv.totalUsd ?? 0));
    double totalPaidSyp =
        invoices.fold(0.0, (sum, inv) => sum + inv.paidAmount);
    double totalPaidUsd =
        invoices.fold(0.0, (sum, inv) => sum + (inv.paidAmountUsd ?? 0));

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => template.buildHeader(),
        footer: (context) => template.buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          template.buildStatsBox([
            StatItem(
              label: 'إجمالي المشتريات',
              value: ExportFormatters.formatDualPriceFromLocked(
                  totalPurchasesSyp, totalPurchasesUsd),
              color: ExportColors.purchase,
            ),
            StatItem(
              label: 'المدفوع',
              value: ExportFormatters.formatDualPriceFromLocked(
                  totalPaidSyp, totalPaidUsd),
              color: ExportColors.success,
            ),
            StatItem(
              label: 'عدد الفواتير',
              value: '${invoices.length}',
            ),
          ]),
          pw.SizedBox(height: 20),
          template.buildTable(
            headers: ['#', 'رقم الفاتورة', 'التاريخ', 'الإجمالي', 'حالة الدفع'],
            data: List.generate(invoices.length, (i) {
              final inv = invoices[i];
              return [
                '${i + 1}',
                inv.invoiceNumber,
                ExportFormatters.formatDate(inv.invoiceDate),
                ExportFormatters.formatDualPriceFromLocked(
                    inv.total, inv.totalUsd ?? 0),
                _getPaymentStatusText(inv.total, inv.paidAmount),
              ];
            }),
            headerBgColor: ExportColors.purchase,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // تصدير تقرير الأرباح والخسائر
  // ══════════════════════════════════════════════════════════════════════════

  /// تصدير تقرير الأرباح والخسائر إلى Excel
  static Future<String> exportProfitReportToExcel({
    required List<Invoice> sales,
    required List<Invoice> purchases,
    DateTimeRange? dateRange,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير الأرباح والخسائر'];
    excel.delete('Sheet1');

    double totalSales = sales.fold(0, (sum, inv) => sum + inv.total);
    double totalPurchases = purchases.fold(0, (sum, inv) => sum + inv.total);
    double profit = totalSales - totalPurchases;

    // Title
    final headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#9C27B0'),
      fontColorHex: ExcelColor.white,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Set sheet RTL direction
    sheet.isRTL = true;

    sheet.cell(CellIndex.indexByString('A1'))
      ..value = TextCellValue('تقرير الأرباح والخسائر')
      ..cellStyle = headerStyle;
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('C1'));

    // Data
    final labels = ['إجمالي المبيعات', 'إجمالي المشتريات', 'صافي الربح'];
    final values = [totalSales, totalPurchases, profit];
    final colors = [
      ExcelStyles.successColor,
      ExcelStyles.purchaseColor,
      profit >= 0 ? ExcelStyles.successColor : ExcelStyles.errorColor
    ];

    for (var i = 0; i < labels.length; i++) {
      final row = i + 3;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = TextCellValue(labels[i])
        ..cellStyle = CellStyle(bold: true);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        ..value = DoubleCellValue(values[i])
        ..cellStyle = CellStyle(
            fontColorHex:
                ExcelColor.fromHexString('#${colors[i].substring(2)}'));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue('ل.س');
    }

    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 20);

    return await _saveExcelFile(excel, fileName ?? 'profit_report');
  }

  /// تصدير تقرير الأرباح والخسائر إلى PDF
  static Future<Uint8List> generateProfitReportPdf({
    required List<Invoice> sales,
    required List<Invoice> purchases,
    DateTimeRange? dateRange,
  }) async {
    await PdfFonts.init();

    // ═══════════════════════════════════════════════════════════════════════
    // السياسة المحاسبية: استخدام القيم المحفوظة (SYP + USD) بدون تحويل
    // ═══════════════════════════════════════════════════════════════════════
    double totalSalesSyp = sales.fold(0.0, (sum, inv) => sum + inv.total);
    double totalSalesUsd =
        sales.fold(0.0, (sum, inv) => sum + (inv.totalUsd ?? 0));
    double totalPurchasesSyp =
        purchases.fold(0.0, (sum, inv) => sum + inv.total);
    double totalPurchasesUsd =
        purchases.fold(0.0, (sum, inv) => sum + (inv.totalUsd ?? 0));
    double profitSyp = totalSalesSyp - totalPurchasesSyp;
    double profitUsd = totalSalesUsd - totalPurchasesUsd;

    final template = PdfReportTemplate(
      title: 'تقرير الأرباح والخسائر',
      subtitle: dateRange != null
          ? ExportFormatters.formatDateRange(dateRange.start, dateRange.end)
          : null,
      reportDate: DateTime.now(),
      headerColor: profitSyp >= 0 ? ExportColors.success : ExportColors.error,
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        build: (context) => pw.Column(
          children: [
            template.buildHeader(),
            pw.SizedBox(height: 40),

            // Sales Card - استخدام القيم المحفوظة
            _buildProfitCard(
              title: 'إجمالي المبيعات',
              value: ExportFormatters.formatDualPriceFromLocked(
                  totalSalesSyp, totalSalesUsd),
              subtitle: '${sales.length} فاتورة',
              color: ExportColors.success,
            ),
            pw.SizedBox(height: 16),

            // Purchases Card - استخدام القيم المحفوظة
            _buildProfitCard(
              title: 'إجمالي المشتريات',
              value: ExportFormatters.formatDualPriceFromLocked(
                  totalPurchasesSyp, totalPurchasesUsd),
              subtitle: '${purchases.length} فاتورة',
              color: ExportColors.purchase,
            ),
            pw.SizedBox(height: 24),

            // Profit Card
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: profitSyp >= 0
                    ? const PdfColor.fromInt(0xFFE8F5E9)
                    : const PdfColor.fromInt(0xFFFFEBEE),
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(
                  color: profitSyp >= 0
                      ? ExportColors.success
                      : ExportColors.error,
                  width: 2,
                ),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'صافي الربح',
                    style: pw.TextStyle(font: PdfFonts.bold, fontSize: 18),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.SizedBox(height: 8),
                  // استخدام القيم المحفوظة
                  pw.Text(
                    ExportFormatters.formatDualPriceFromLocked(
                        profitSyp, profitUsd),
                    style: pw.TextStyle(
                      font: PdfFonts.bold,
                      fontSize: 32,
                      color: profitSyp >= 0
                          ? ExportColors.success
                          : ExportColors.error,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // تصدير تقرير الذمم المدينة (العملاء)
  // ══════════════════════════════════════════════════════════════════════════

  /// تصدير تقرير الذمم المدينة إلى Excel
  static Future<String> exportReceivablesReportToExcel({
    required List<Customer> customers,
    String? fileName,
  }) async {
    final customersWithBalance = customers.where((c) => c.balance > 0).toList();

    final excel = Excel.createExcel();
    final sheet = excel['تقرير الذمم المدينة'];
    excel.delete('Sheet1');

    final headerStyle = CellStyle(
      backgroundColorHex:
          ExcelColor.fromHexString('#${ExcelStyles.errorColor.substring(2)}'),
      fontColorHex: ExcelColor.fromHexString(
          '#${ExcelStyles.headerTextColor.substring(2)}'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    final headers = ['#', 'اسم العميل', 'رقم الجوال', 'الرصيد المستحق'];
    _writeExcelHeaders(sheet, headers, headerStyle);

    double totalBalance = 0;
    for (var i = 0; i < customersWithBalance.length; i++) {
      final customer = customersWithBalance[i];
      totalBalance += customer.balance;

      _writeExcelRow(sheet, i + 1, [
        (i + 1).toString(),
        customer.name,
        customer.phone ?? '-',
        ExportFormatters.formatPrice(customer.balance, showCurrency: false),
      ]);
    }

    _writeExcelSummary(
        sheet,
        customersWithBalance.length + 2,
        2,
        'الإجمالي:',
        [
          ExportFormatters.formatPrice(totalBalance, showCurrency: false),
        ],
        ExcelStyles.errorColor);

    _setExcelColumnWidths(sheet, [5, 25, 15, 20]);

    return await _saveExcelFile(excel, fileName ?? 'receivables_report');
  }

  /// تصدير تقرير الذمم المدينة إلى PDF
  static Future<Uint8List> generateReceivablesReportPdf({
    required List<Customer> customers,
  }) async {
    await PdfFonts.init();

    final customersWithBalance = customers.where((c) => c.balance > 0).toList();
    final totalBalance =
        customersWithBalance.fold<double>(0, (sum, c) => sum + c.balance);

    final template = PdfReportTemplate(
      title: 'تقرير الذمم المدينة',
      subtitle: 'المبالغ المستحقة من العملاء',
      reportDate: DateTime.now(),
      headerColor: ExportColors.error,
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => template.buildHeader(),
        footer: (context) => template.buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          template.buildStatsBox([
            StatItem(
              label: 'إجمالي المستحقات',
              value: ExportFormatters.formatPrice(totalBalance),
              color: ExportColors.error,
            ),
            StatItem(
              label: 'عدد العملاء',
              value: '${customersWithBalance.length}',
            ),
          ]),
          pw.SizedBox(height: 20),
          template.buildTable(
            headers: ['#', 'اسم العميل', 'الجوال', 'المستحق'],
            data: List.generate(customersWithBalance.length, (i) {
              final c = customersWithBalance[i];
              return [
                '${i + 1}',
                c.name,
                c.phone ?? '-',
                ExportFormatters.formatPrice(c.balance),
              ];
            }),
            headerBgColor: ExportColors.error,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // تصدير تقرير الذمم الدائنة (الموردين)
  // ══════════════════════════════════════════════════════════════════════════

  /// تصدير تقرير الذمم الدائنة إلى Excel
  static Future<String> exportPayablesReportToExcel({
    required List<Supplier> suppliers,
    String? fileName,
  }) async {
    final suppliersWithBalance = suppliers.where((s) => s.balance > 0).toList();

    final excel = Excel.createExcel();
    final sheet = excel['تقرير الذمم الدائنة'];
    excel.delete('Sheet1');

    final headerStyle = CellStyle(
      backgroundColorHex:
          ExcelColor.fromHexString('#${ExcelStyles.warningColor.substring(2)}'),
      fontColorHex: ExcelColor.fromHexString(
          '#${ExcelStyles.headerTextColor.substring(2)}'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    final headers = ['#', 'اسم المورد', 'رقم الجوال', 'المستحق له'];
    _writeExcelHeaders(sheet, headers, headerStyle);

    double totalBalance = 0;
    for (var i = 0; i < suppliersWithBalance.length; i++) {
      final supplier = suppliersWithBalance[i];
      totalBalance += supplier.balance;

      _writeExcelRow(sheet, i + 1, [
        (i + 1).toString(),
        supplier.name,
        supplier.phone ?? '-',
        ExportFormatters.formatPrice(supplier.balance, showCurrency: false),
      ]);
    }

    _writeExcelSummary(
        sheet,
        suppliersWithBalance.length + 2,
        2,
        'الإجمالي:',
        [
          ExportFormatters.formatPrice(totalBalance, showCurrency: false),
        ],
        ExcelStyles.warningColor);

    _setExcelColumnWidths(sheet, [5, 25, 15, 20]);

    return await _saveExcelFile(excel, fileName ?? 'payables_report');
  }

  /// تصدير تقرير الذمم الدائنة إلى PDF
  static Future<Uint8List> generatePayablesReportPdf({
    required List<Supplier> suppliers,
  }) async {
    await PdfFonts.init();

    final suppliersWithBalance = suppliers.where((s) => s.balance > 0).toList();
    final totalBalance =
        suppliersWithBalance.fold<double>(0, (sum, s) => sum + s.balance);

    final template = PdfReportTemplate(
      title: 'تقرير الذمم الدائنة',
      subtitle: 'المبالغ المستحقة للموردين',
      reportDate: DateTime.now(),
      headerColor: ExportColors.warning,
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => template.buildHeader(),
        footer: (context) => template.buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          template.buildStatsBox([
            StatItem(
              label: 'إجمالي المستحقات للموردين',
              value: ExportFormatters.formatPrice(totalBalance),
              color: ExportColors.warning,
            ),
            StatItem(
              label: 'عدد الموردين',
              value: '${suppliersWithBalance.length}',
            ),
          ]),
          pw.SizedBox(height: 20),
          template.buildTable(
            headers: ['#', 'اسم المورد', 'الجوال', 'المستحق'],
            data: List.generate(suppliersWithBalance.length, (i) {
              final s = suppliersWithBalance[i];
              return [
                '${i + 1}',
                s.name,
                s.phone ?? '-',
                ExportFormatters.formatPrice(s.balance),
              ];
            }),
            headerBgColor: ExportColors.warning,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // تصدير تقرير المخزون
  // ══════════════════════════════════════════════════════════════════════════

  /// تصدير تقرير المخزون إلى Excel
  static Future<String> exportInventoryReportToExcel({
    required List<Product> products,
    Map<String, int>? soldQuantities,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير المخزون'];
    excel.delete('Sheet1');

    final headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#673AB7'),
      fontColorHex: ExcelColor.white,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    final headers = [
      '#',
      'اسم المنتج',
      'الباركود',
      'الكمية',
      'الكمية المباعة',
      'سعر التكلفة',
      'قيمة المخزون'
    ];

    // Set sheet RTL direction
    sheet.isRTL = true;

    _writeExcelHeaders(sheet, headers, headerStyle);

    double totalValue = 0;
    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      final stockValue = product.quantity * product.purchasePrice;
      totalValue += stockValue;
      final sold = soldQuantities?[product.id] ?? 0;

      final row = i + 1;

      _writeExcelRow(sheet, row, [
        (i + 1).toString(),
        product.name,
        product.barcode ?? '-',
        product.quantity.toString(),
        sold.toString(),
        ExportFormatters.formatPrice(product.purchasePrice,
            showCurrency: false),
        ExportFormatters.formatPrice(stockValue, showCurrency: false),
      ]);
    }

    _writeExcelSummary(
        sheet,
        products.length + 2,
        5,
        'الإجمالي:',
        [
          ExportFormatters.formatPrice(totalValue, showCurrency: false),
        ],
        '673AB7');

    _setExcelColumnWidths(sheet, [5, 30, 18, 10, 15, 15, 18]);

    return await _saveExcelFile(excel, fileName ?? 'inventory_report');
  }

  /// تصدير تقرير المخزون إلى PDF
  static Future<Uint8List> generateInventoryReportPdf({
    required List<Product> products,
    Map<String, int>? soldQuantities,
  }) async {
    await PdfFonts.init();

    final totalItems = products.fold<int>(0, (sum, p) => sum + p.quantity);
    final totalValue = products.fold<double>(
        0, (sum, p) => sum + (p.quantity * p.purchasePrice));
    final totalSold =
        soldQuantities?.values.fold<int>(0, (sum, q) => sum + q) ?? 0;

    final template = PdfReportTemplate(
      title: 'تقرير المخزون',
      subtitle: 'الكميات والقيم الحالية',
      reportDate: DateTime.now(),
      headerColor: const PdfColor.fromInt(0xFF673AB7),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: PdfTheme.create(),
        header: (context) => template.buildHeader(),
        footer: (context) => template.buildFooter(
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          template.buildStatsBox([
            StatItem(
              label: 'عدد المنتجات',
              value: '${products.length}',
              color: const PdfColor.fromInt(0xFF673AB7),
            ),
            StatItem(
              label: 'إجمالي القطع',
              value: NumberFormat('#,###').format(totalItems),
              color: ExportColors.info,
            ),
            StatItem(
              label: 'إجمالي المبيعات',
              value: NumberFormat('#,###').format(totalSold),
              color: ExportColors.success,
            ),
            StatItem(
              label: 'قيمة المخزون',
              value: ExportFormatters.formatPrice(totalValue),
              color: const PdfColor.fromInt(0xFF673AB7),
            ),
          ]),
          pw.SizedBox(height: 20),
          template.buildTable(
            headers: ['#', 'المنتج', 'الباركود', 'الكمية', 'المباع', 'القيمة'],
            data: List.generate(products.length, (i) {
              final p = products[i];
              final sold = soldQuantities?[p.id] ?? 0;
              return [
                '${i + 1}',
                p.name,
                p.barcode ?? '-',
                '${p.quantity}',
                '$sold',
                ExportFormatters.formatPrice(p.quantity * p.purchasePrice),
              ];
            }),
            headerBgColor: const PdfColor.fromInt(0xFF673AB7),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Helper Methods - دوال مساعدة
  // ══════════════════════════════════════════════════════════════════════════

  /// الحصول على نص حالة الدفع (بناءً على المبالغ)
  static String _getPaymentStatusText(double total, double paidAmount) {
    if (paidAmount >= total) {
      return 'مدفوعة';
    } else if (paidAmount > 0) {
      return 'جزئي';
    } else {
      return 'غير مدفوعة';
    }
  }

  /// كتابة رؤوس الأعمدة في Excel
  static void _writeExcelHeaders(
      Sheet sheet, List<String> headers, CellStyle style) {
    // Set sheet RTL direction
    sheet.isRTL = true;

    for (var i = 0; i < headers.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = style;
    }
  }

  /// كتابة صف بيانات في Excel
  static void _writeExcelRow(Sheet sheet, int rowIndex, List<String> values) {
    for (var i = 0; i < values.length; i++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
      cell.value = TextCellValue(values[i]);
      cell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Right);
    }
  }

  /// كتابة صف الملخص في Excel
  static void _writeExcelSummary(Sheet sheet, int rowIndex, int labelCol,
      String label, List<String> values, String color) {
    // Create lighter version of color by adjusting hex
    final hexColor = color.length == 6 ? color : color.substring(2);
    final summaryStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#$hexColor'),
    );

    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: labelCol, rowIndex: rowIndex))
      ..value = TextCellValue(label)
      ..cellStyle = summaryStyle;

    for (var i = 0; i < values.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: labelCol + 1 + i, rowIndex: rowIndex))
        ..value = TextCellValue(values[i])
        ..cellStyle = summaryStyle;
    }
  }

  /// تعيين عرض الأعمدة في Excel
  static void _setExcelColumnWidths(Sheet sheet, List<double> widths) {
    for (var i = 0; i < widths.length; i++) {
      sheet.setColumnWidth(i, widths[i]);
    }
  }

  /// بناء بطاقة الربح في PDF
  static pw.Widget _buildProfitCard({
    required String title,
    required String value,
    required String subtitle,
    required PdfColor color,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: color.shade(50),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color.shade(200)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(font: PdfFonts.bold, fontSize: 14),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                subtitle,
                style: pw.TextStyle(
                    font: PdfFonts.regular,
                    fontSize: 10,
                    color: PdfColors.grey600),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          pw.Text(
            value,
            style:
                pw.TextStyle(font: PdfFonts.bold, fontSize: 18, color: color),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  /// حفظ ملف Excel
  static Future<String> _saveExcelFile(Excel excel, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${dir.path}/${fileName}_$timestamp.xlsx';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }

    return filePath;
  }

  /// حفظ ملف PDF
  static Future<void> savePdf(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${dir.path}/${fileName}_$timestamp.pdf';

    final file = File(filePath);
    await file.writeAsBytes(bytes);
  }

  /// مشاركة ملف PDF
  static Future<void> sharePdfBytes(Uint8List bytes,
      {required String fileName, String? subject}) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${dir.path}/${fileName}_$timestamp.pdf';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
    );
  }

  /// مشاركة ملف
  static Future<void> shareFile(String filePath, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
    );
  }
}
