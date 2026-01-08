import 'dart:convert';
import 'dart:typed_data';

import '../printing/print_settings.dart';
import '../printing/print_settings_service.dart';
import 'export_templates.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Export Service - خدمة التصدير الموحدة
/// توفر إعدادات التصدير من إعدادات الطباعة
/// ═══════════════════════════════════════════════════════════════════════════
class ExportService {
  static PrintSettingsService? _printSettingsService;

  // Cache للإعدادات
  static ExportSettings? _cachedSettings;

  ExportService._();

  /// تهيئة الخدمة
  static void init(PrintSettingsService printSettingsService) {
    _printSettingsService = printSettingsService;
  }

  /// الحصول على إعدادات التصدير (static للاستخدام السهل)
  static Future<ExportSettings> getExportSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    if (_printSettingsService == null) {
      // إذا لم يتم تهيئة الخدمة، أعد إعدادات افتراضية
      return const ExportSettings();
    }

    final printSettings = await _printSettingsService!.getSettings();
    _cachedSettings = _convertToExportSettings(printSettings);
    return _cachedSettings!;
  }

  /// تحويل إعدادات الطباعة إلى إعدادات التصدير
  static ExportSettings _convertToExportSettings(PrintSettings printSettings) {
    Uint8List? logoBytes;
    if (printSettings.logoBase64 != null &&
        printSettings.logoBase64!.isNotEmpty) {
      try {
        logoBytes = base64Decode(printSettings.logoBase64!);
      } catch (_) {
        // تجاهل الخطأ إذا كان الـ Base64 غير صالح
      }
    }

    return ExportSettings(
      companyName: printSettings.companyName,
      companyAddress: printSettings.companyAddress,
      companyPhone: printSettings.companyPhone,
      companyTaxNumber: printSettings.companyTaxNumber,
      logoBytes: logoBytes,
      showLogo: printSettings.showLogo,
      footerMessage: printSettings.footerMessage,
    );
  }

  /// مسح الـ cache
  static void clearCache() {
    _cachedSettings = null;
  }

  /// الاستماع لتغييرات الإعدادات
  static void listenToSettingsChanges() {
    _printSettingsService?.settingsStream.listen((_) {
      clearCache();
    });
  }
}
