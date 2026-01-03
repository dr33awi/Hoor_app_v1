import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة الإعدادات
class SettingsState {
  // معلومات المتجر
  final String storeName;
  final String? storeAddress;
  final String? storePhone;
  final String? taxNumber;
  final String? logo;

  // إعدادات الفواتير
  final double taxRate;
  final String currency;
  final bool autoPrint;
  final bool showTax;

  // إعدادات المخزون
  final double defaultMinStock;
  final bool stockAlerts;
  final bool allowNegativeStock;

  // إعدادات العرض
  final bool darkMode;
  final double fontSize;
  final String language;

  // النسخ الاحتياطي
  final bool autoBackup;
  final String? lastBackupDate;

  // الطباعة
  final String? printerName;
  final String paperSize;

  // الأمان
  final bool appLock;
  final String? lockPin;

  const SettingsState({
    this.storeName = 'متجر حور',
    this.storeAddress,
    this.storePhone,
    this.taxNumber,
    this.logo,
    this.taxRate = 0.15,
    this.currency = 'ر.س',
    this.autoPrint = false,
    this.showTax = true,
    this.defaultMinStock = 10,
    this.stockAlerts = true,
    this.allowNegativeStock = false,
    this.darkMode = false,
    this.fontSize = 1.0,
    this.language = 'ar',
    this.autoBackup = false,
    this.lastBackupDate,
    this.printerName,
    this.paperSize = '80mm',
    this.appLock = false,
    this.lockPin,
  });

  SettingsState copyWith({
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? taxNumber,
    String? logo,
    double? taxRate,
    String? currency,
    bool? autoPrint,
    bool? showTax,
    double? defaultMinStock,
    bool? stockAlerts,
    bool? allowNegativeStock,
    bool? darkMode,
    double? fontSize,
    String? language,
    bool? autoBackup,
    String? lastBackupDate,
    String? printerName,
    String? paperSize,
    bool? appLock,
    String? lockPin,
  }) {
    return SettingsState(
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      taxNumber: taxNumber ?? this.taxNumber,
      logo: logo ?? this.logo,
      taxRate: taxRate ?? this.taxRate,
      currency: currency ?? this.currency,
      autoPrint: autoPrint ?? this.autoPrint,
      showTax: showTax ?? this.showTax,
      defaultMinStock: defaultMinStock ?? this.defaultMinStock,
      stockAlerts: stockAlerts ?? this.stockAlerts,
      allowNegativeStock: allowNegativeStock ?? this.allowNegativeStock,
      darkMode: darkMode ?? this.darkMode,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
      autoBackup: autoBackup ?? this.autoBackup,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      printerName: printerName ?? this.printerName,
      paperSize: paperSize ?? this.paperSize,
      appLock: appLock ?? this.appLock,
      lockPin: lockPin ?? this.lockPin,
    );
  }
}

/// مدير الإعدادات
class SettingsNotifier extends StateNotifier<SettingsState> {
  SharedPreferences? _prefs;

  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    state = SettingsState(
      storeName: _prefs?.getString('storeName') ?? 'متجر حور',
      storeAddress: _prefs?.getString('storeAddress'),
      storePhone: _prefs?.getString('storePhone'),
      taxNumber: _prefs?.getString('taxNumber'),
      logo: _prefs?.getString('logo'),
      taxRate: _prefs?.getDouble('taxRate') ?? 0.15,
      currency: _prefs?.getString('currency') ?? 'ر.س',
      autoPrint: _prefs?.getBool('autoPrint') ?? false,
      showTax: _prefs?.getBool('showTax') ?? true,
      defaultMinStock: _prefs?.getDouble('defaultMinStock') ?? 10,
      stockAlerts: _prefs?.getBool('stockAlerts') ?? true,
      allowNegativeStock: _prefs?.getBool('allowNegativeStock') ?? false,
      darkMode: _prefs?.getBool('darkMode') ?? false,
      fontSize: _prefs?.getDouble('fontSize') ?? 1.0,
      language: _prefs?.getString('language') ?? 'ar',
      autoBackup: _prefs?.getBool('autoBackup') ?? false,
      lastBackupDate: _prefs?.getString('lastBackupDate'),
      printerName: _prefs?.getString('printerName'),
      paperSize: _prefs?.getString('paperSize') ?? '80mm',
      appLock: _prefs?.getBool('appLock') ?? false,
      lockPin: _prefs?.getString('lockPin'),
    );
  }

  // معلومات المتجر
  Future<void> setStoreName(String value) async {
    await _prefs?.setString('storeName', value);
    state = state.copyWith(storeName: value);
  }

  Future<void> setStoreAddress(String value) async {
    await _prefs?.setString('storeAddress', value);
    state = state.copyWith(storeAddress: value);
  }

  Future<void> setStorePhone(String value) async {
    await _prefs?.setString('storePhone', value);
    state = state.copyWith(storePhone: value);
  }

  Future<void> setTaxNumber(String value) async {
    await _prefs?.setString('taxNumber', value);
    state = state.copyWith(taxNumber: value);
  }

  Future<void> setLogo(String value) async {
    await _prefs?.setString('logo', value);
    state = state.copyWith(logo: value);
  }

  // إعدادات الفواتير
  Future<void> setTaxRate(double value) async {
    await _prefs?.setDouble('taxRate', value);
    state = state.copyWith(taxRate: value);
  }

  Future<void> setCurrency(String value) async {
    await _prefs?.setString('currency', value);
    state = state.copyWith(currency: value);
  }

  Future<void> setAutoPrint(bool value) async {
    await _prefs?.setBool('autoPrint', value);
    state = state.copyWith(autoPrint: value);
  }

  Future<void> setShowTax(bool value) async {
    await _prefs?.setBool('showTax', value);
    state = state.copyWith(showTax: value);
  }

  // إعدادات المخزون
  Future<void> setDefaultMinStock(double value) async {
    await _prefs?.setDouble('defaultMinStock', value);
    state = state.copyWith(defaultMinStock: value);
  }

  Future<void> setStockAlerts(bool value) async {
    await _prefs?.setBool('stockAlerts', value);
    state = state.copyWith(stockAlerts: value);
  }

  Future<void> setAllowNegativeStock(bool value) async {
    await _prefs?.setBool('allowNegativeStock', value);
    state = state.copyWith(allowNegativeStock: value);
  }

  // إعدادات العرض
  Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool('darkMode', value);
    state = state.copyWith(darkMode: value);
  }

  Future<void> setFontSize(double value) async {
    await _prefs?.setDouble('fontSize', value);
    state = state.copyWith(fontSize: value);
  }

  Future<void> setLanguage(String value) async {
    await _prefs?.setString('language', value);
    state = state.copyWith(language: value);
  }

  // النسخ الاحتياطي
  Future<void> setAutoBackup(bool value) async {
    await _prefs?.setBool('autoBackup', value);
    state = state.copyWith(autoBackup: value);
  }

  Future<void> setLastBackupDate(String value) async {
    await _prefs?.setString('lastBackupDate', value);
    state = state.copyWith(lastBackupDate: value);
  }

  // الطباعة
  Future<void> setPrinterName(String value) async {
    await _prefs?.setString('printerName', value);
    state = state.copyWith(printerName: value);
  }

  Future<void> setPaperSize(String value) async {
    await _prefs?.setString('paperSize', value);
    state = state.copyWith(paperSize: value);
  }

  // الأمان
  Future<void> setAppLock(bool value) async {
    await _prefs?.setBool('appLock', value);
    state = state.copyWith(appLock: value);
  }

  Future<void> setLockPin(String? value) async {
    if (value != null) {
      await _prefs?.setString('lockPin', value);
    } else {
      await _prefs?.remove('lockPin');
    }
    state = state.copyWith(lockPin: value);
  }

  // إعادة تعيين الإعدادات
  Future<void> resetSettings() async {
    await _prefs?.clear();
    state = const SettingsState();
  }
}

/// مزود الإعدادات
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

/// مزودات مساعدة
final darkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).darkMode;
});

final currencyProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).currency;
});

final taxRateProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).taxRate;
});

final languageProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).language;
});
