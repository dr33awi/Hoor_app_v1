import 'dart:convert';
import 'dart:typed_data';

import '../export/export_templates.dart';
import 'invoice_pdf_generator.dart';
import 'voucher_pdf_generator.dart';

/// إعدادات الطباعة الموحدة
/// تستخدم في جميع صفحات التطبيق التي تدعم الطباعة
class PrintSettings {
  /// حجم الطباعة الافتراضي
  final InvoicePrintSize defaultSize;

  /// طباعة تلقائية بعد حفظ الفاتورة
  final bool autoPrintAfterSave;

  /// إظهار الباركود في الفاتورة
  final bool showBarcode;

  /// إظهار شعار الشركة
  final bool showLogo;

  /// إظهار معلومات العميل
  final bool showCustomerInfo;

  /// إظهار الملاحظات
  final bool showNotes;

  /// إظهار طريقة الدفع
  final bool showPaymentMethod;

  /// إظهار تفاصيل الضريبة
  final bool showTaxDetails;

  /// اسم الشركة
  final String? companyName;

  /// عنوان الشركة
  final String? companyAddress;

  /// هاتف الشركة
  final String? companyPhone;

  /// الرقم الضريبي
  final String? companyTaxNumber;

  /// شعار الشركة (Base64)
  final String? logoBase64;

  /// عدد نسخ الطباعة
  final int copies;

  /// رسالة شكر أسفل الفاتورة
  final String? footerMessage;

  /// إظهار تفاصيل المنتج (الوصف)
  final bool showProductDetails;

  /// إظهار رقم الفاتورة كباركود
  final bool showInvoiceBarcode;

  const PrintSettings({
    this.defaultSize = InvoicePrintSize.a4,
    this.autoPrintAfterSave = false,
    this.showBarcode = true,
    this.showLogo = true,
    this.showCustomerInfo = true,
    this.showNotes = true,
    this.showPaymentMethod = true,
    this.showTaxDetails = true,
    this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.companyTaxNumber,
    this.logoBase64,
    this.copies = 1,
    this.footerMessage,
    this.showProductDetails = false,
    this.showInvoiceBarcode = false,
  });

  /// إعدادات افتراضية
  static const PrintSettings defaultSettings = PrintSettings();

  /// تحويل إلى InvoicePrintOptions
  InvoicePrintOptions toInvoicePrintOptions() {
    Uint8List? logoBytes;
    if (logoBase64 != null && logoBase64!.isNotEmpty) {
      try {
        logoBytes = base64Decode(logoBase64!);
      } catch (_) {
        // تجاهل الخطأ إذا كان الـ Base64 غير صالح
      }
    }

    return InvoicePrintOptions(
      size: defaultSize,
      showBarcode: showBarcode,
      showLogo: showLogo,
      showCustomerInfo: showCustomerInfo,
      showNotes: showNotes,
      showPaymentMethod: showPaymentMethod,
      showTaxDetails: showTaxDetails,
      logoBytes: logoBytes,
      companyName: companyName,
      companyAddress: companyAddress,
      companyPhone: companyPhone,
      companyTaxNumber: companyTaxNumber,
      footerMessage: footerMessage,
      showInvoiceBarcode: showInvoiceBarcode,
    );
  }

  /// تحويل إلى VoucherPrintOptions
  VoucherPrintOptions toVoucherPrintOptions({
    VoucherPrintSize? size,
  }) {
    Uint8List? logoBytes;
    if (logoBase64 != null && logoBase64!.isNotEmpty) {
      try {
        logoBytes = base64Decode(logoBase64!);
      } catch (_) {
        // تجاهل الخطأ إذا كان الـ Base64 غير صالح
      }
    }

    // تحويل حجم الفاتورة إلى حجم السند
    VoucherPrintSize voucherSize;
    if (size != null) {
      voucherSize = size;
    } else {
      switch (defaultSize) {
        case InvoicePrintSize.a4:
          voucherSize = VoucherPrintSize.a4;
          break;
        case InvoicePrintSize.thermal80mm:
          voucherSize = VoucherPrintSize.thermal80mm;
          break;
        case InvoicePrintSize.thermal58mm:
          voucherSize = VoucherPrintSize.thermal58mm;
          break;
      }
    }

    return VoucherPrintOptions(
      size: voucherSize,
      showLogo: showLogo,
      showExchangeRate: true,
      logoBytes: logoBytes,
      companyName: companyName,
      companyAddress: companyAddress,
      companyPhone: companyPhone,
      companyTaxNumber: companyTaxNumber,
      footerMessage: footerMessage,
    );
  }

  /// تحويل إلى ExportSettings (للتقارير والتصديرات)
  ExportSettings toExportSettings() {
    Uint8List? logoBytes;
    if (logoBase64 != null && logoBase64!.isNotEmpty) {
      try {
        logoBytes = base64Decode(logoBase64!);
      } catch (_) {
        // تجاهل الخطأ إذا كان الـ Base64 غير صالح
      }
    }

    return ExportSettings(
      companyName: companyName,
      companyAddress: companyAddress,
      companyPhone: companyPhone,
      companyTaxNumber: companyTaxNumber,
      logoBytes: logoBytes,
      showLogo: showLogo,
      footerMessage: footerMessage,
    );
  }

  /// نسخ مع تعديلات
  PrintSettings copyWith({
    InvoicePrintSize? defaultSize,
    bool? autoPrintAfterSave,
    bool? showBarcode,
    bool? showLogo,
    bool? showCustomerInfo,
    bool? showNotes,
    bool? showPaymentMethod,
    bool? showTaxDetails,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyTaxNumber,
    String? logoBase64,
    int? copies,
    String? footerMessage,
    bool? showProductDetails,
    bool? showInvoiceBarcode,
  }) {
    return PrintSettings(
      defaultSize: defaultSize ?? this.defaultSize,
      autoPrintAfterSave: autoPrintAfterSave ?? this.autoPrintAfterSave,
      showBarcode: showBarcode ?? this.showBarcode,
      showLogo: showLogo ?? this.showLogo,
      showCustomerInfo: showCustomerInfo ?? this.showCustomerInfo,
      showNotes: showNotes ?? this.showNotes,
      showPaymentMethod: showPaymentMethod ?? this.showPaymentMethod,
      showTaxDetails: showTaxDetails ?? this.showTaxDetails,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyTaxNumber: companyTaxNumber ?? this.companyTaxNumber,
      logoBase64: logoBase64 ?? this.logoBase64,
      copies: copies ?? this.copies,
      footerMessage: footerMessage ?? this.footerMessage,
      showProductDetails: showProductDetails ?? this.showProductDetails,
      showInvoiceBarcode: showInvoiceBarcode ?? this.showInvoiceBarcode,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'defaultSize': defaultSize.index,
      'autoPrintAfterSave': autoPrintAfterSave,
      'showBarcode': showBarcode,
      'showLogo': showLogo,
      'showCustomerInfo': showCustomerInfo,
      'showNotes': showNotes,
      'showPaymentMethod': showPaymentMethod,
      'showTaxDetails': showTaxDetails,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'companyTaxNumber': companyTaxNumber,
      'logoBase64': logoBase64,
      'copies': copies,
      'footerMessage': footerMessage,
      'showProductDetails': showProductDetails,
      'showInvoiceBarcode': showInvoiceBarcode,
    };
  }

  /// إنشاء من JSON
  factory PrintSettings.fromJson(Map<String, dynamic> json) {
    return PrintSettings(
      defaultSize: InvoicePrintSize.values[json['defaultSize'] as int? ?? 0],
      autoPrintAfterSave: json['autoPrintAfterSave'] as bool? ?? false,
      showBarcode: json['showBarcode'] as bool? ?? true,
      showLogo: json['showLogo'] as bool? ?? true,
      showCustomerInfo: json['showCustomerInfo'] as bool? ?? true,
      showNotes: json['showNotes'] as bool? ?? true,
      showPaymentMethod: json['showPaymentMethod'] as bool? ?? true,
      showTaxDetails: json['showTaxDetails'] as bool? ?? true,
      companyName: json['companyName'] as String?,
      companyAddress: json['companyAddress'] as String?,
      companyPhone: json['companyPhone'] as String?,
      companyTaxNumber: json['companyTaxNumber'] as String?,
      logoBase64: json['logoBase64'] as String?,
      copies: json['copies'] as int? ?? 1,
      footerMessage: json['footerMessage'] as String?,
      showProductDetails: json['showProductDetails'] as bool? ?? false,
      showInvoiceBarcode: json['showInvoiceBarcode'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintSettings &&
          runtimeType == other.runtimeType &&
          defaultSize == other.defaultSize &&
          autoPrintAfterSave == other.autoPrintAfterSave &&
          showBarcode == other.showBarcode &&
          showLogo == other.showLogo &&
          showCustomerInfo == other.showCustomerInfo &&
          showNotes == other.showNotes &&
          showPaymentMethod == other.showPaymentMethod &&
          showTaxDetails == other.showTaxDetails &&
          companyName == other.companyName &&
          companyAddress == other.companyAddress &&
          companyPhone == other.companyPhone &&
          companyTaxNumber == other.companyTaxNumber &&
          logoBase64 == other.logoBase64 &&
          copies == other.copies &&
          footerMessage == other.footerMessage &&
          showProductDetails == other.showProductDetails &&
          showInvoiceBarcode == other.showInvoiceBarcode;

  @override
  int get hashCode =>
      defaultSize.hashCode ^
      autoPrintAfterSave.hashCode ^
      showBarcode.hashCode ^
      showLogo.hashCode ^
      showCustomerInfo.hashCode ^
      showNotes.hashCode ^
      showPaymentMethod.hashCode ^
      showTaxDetails.hashCode ^
      companyName.hashCode ^
      companyAddress.hashCode ^
      companyPhone.hashCode ^
      companyTaxNumber.hashCode ^
      logoBase64.hashCode ^
      copies.hashCode ^
      footerMessage.hashCode ^
      showProductDetails.hashCode ^
      showInvoiceBarcode.hashCode;
}
