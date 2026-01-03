import 'dart:math';

/// خدمة الباركود
class BarcodeService {
  final Random _random = Random();

  /// توليد باركود عشوائي
  String generateBarcode({int length = 13}) {
    // توليد باركود EAN-13
    if (length == 13) {
      return _generateEAN13();
    }

    // توليد باركود عشوائي
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }

  /// توليد باركود EAN-13
  String _generateEAN13() {
    // توليد أول 12 رقم
    final buffer = StringBuffer();
    for (var i = 0; i < 12; i++) {
      buffer.write(_random.nextInt(10));
    }

    // حساب رقم التحقق
    final digits = buffer.toString();
    final checkDigit = _calculateEAN13CheckDigit(digits);

    return '$digits$checkDigit';
  }

  /// حساب رقم التحقق لـ EAN-13
  int _calculateEAN13CheckDigit(String digits) {
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final digit = int.parse(digits[i]);
      sum += i.isEven ? digit : digit * 3;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit;
  }

  /// التحقق من صحة باركود EAN-13
  bool validateEAN13(String barcode) {
    if (barcode.length != 13) return false;
    if (!RegExp(r'^\d{13}$').hasMatch(barcode)) return false;

    final digits = barcode.substring(0, 12);
    final providedCheckDigit = int.parse(barcode[12]);
    final calculatedCheckDigit = _calculateEAN13CheckDigit(digits);

    return providedCheckDigit == calculatedCheckDigit;
  }

  /// التحقق من صحة أي باركود
  bool validateBarcode(String barcode) {
    // تحقق بسيط - يجب أن يكون أرقام فقط
    if (!RegExp(r'^\d+$').hasMatch(barcode)) return false;

    // EAN-13
    if (barcode.length == 13) return validateEAN13(barcode);

    // EAN-8
    if (barcode.length == 8) return _validateEAN8(barcode);

    // UPC-A
    if (barcode.length == 12) return _validateUPCA(barcode);

    // أي طول آخر مقبول
    return barcode.length >= 4 && barcode.length <= 20;
  }

  /// التحقق من صحة باركود EAN-8
  bool _validateEAN8(String barcode) {
    if (barcode.length != 8) return false;

    var sum = 0;
    for (var i = 0; i < 7; i++) {
      final digit = int.parse(barcode[i]);
      sum += i.isEven ? digit * 3 : digit;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(barcode[7]);
  }

  /// التحقق من صحة باركود UPC-A
  bool _validateUPCA(String barcode) {
    if (barcode.length != 12) return false;

    var sum = 0;
    for (var i = 0; i < 11; i++) {
      final digit = int.parse(barcode[i]);
      sum += i.isEven ? digit * 3 : digit;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(barcode[11]);
  }

  /// تنظيف الباركود من المسافات والأحرف الخاصة
  String cleanBarcode(String barcode) {
    return barcode.replaceAll(RegExp(r'\s+'), '').trim();
  }
}
