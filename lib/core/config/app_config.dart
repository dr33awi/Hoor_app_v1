/// تكوين التطبيق الأساسي
class AppConfig {
  AppConfig._();

  // معلومات التطبيق
  static const String appName = 'Hoor Manager';
  static const String appNameAr = 'مدير هور';
  static const String version = '2.0.0';
  static const String appVersion = '2.0.0';

  // إعدادات قاعدة البيانات
  static const String dbName = 'hoor_manager.db';
  static const int dbVersion = 1;

  // إعدادات النسخ الاحتياطي
  static const String backupFolder = 'HoorManager/Backups';

  // إعدادات الطباعة الافتراضية
  static const double defaultReceiptWidth = 80.0; // mm
  static const int defaultFontSize = 12;

  // إعدادات المخزون
  static const int lowStockThreshold = 10;

  // إعدادات الوردية
  static const Duration shiftWarningBefore = Duration(hours: 1);

  // إعدادات الضريبة
  static const double defaultTaxRate = 0.0; // نسبة الضريبة الافتراضية 0%

  // تنسيقات التاريخ والوقت
  static const String dateFormat = 'yyyy/MM/dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy/MM/dd HH:mm';

  // العملة الافتراضية
  static const String defaultCurrency = 'ر.ي';
  static const String defaultCurrencyCode = 'YER';
  static const int defaultDecimalPlaces = 0;
}
