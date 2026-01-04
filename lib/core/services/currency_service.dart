import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Currency Service - Production Ready
/// Single Responsibility: Currency conversion & settings ONLY
/// ═══════════════════════════════════════════════════════════════════════════
class CurrencyService extends ChangeNotifier {
  static const _exchangeRateKey = 'exchange_rate_usd_syp';
  static const _baseCurrencyUsdKey = 'base_currency_usd';

  static const double defaultExchangeRate = 14500.0;

  /// Instance singleton للوصول السريع من getIt
  static CurrencyService? _instance;

  /// الوصول السريع لسعر الصرف الحالي من أي مكان
  static double get currentRate =>
      _instance?.exchangeRate ?? defaultExchangeRate;

  /// تعيين الـ instance (يُستدعى من injection)
  static void setInstance(CurrencyService service) {
    _instance = service;
  }

  final SharedPreferences _prefs;

  late double _exchangeRate;
  late bool _isBaseUsd;

  CurrencyService(this._prefs) {
    _load();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Getters
  // ═══════════════════════════════════════════════════════════════════════════

  /// سعر الصرف الحالي (دولار → ليرة)
  double get exchangeRate => _exchangeRate;

  /// هل العملة الأساسية للأسعار هي الدولار؟
  bool get isBaseUsd => _isBaseUsd;

  // ═══════════════════════════════════════════════════════════════════════════
  // Load Settings
  // ═══════════════════════════════════════════════════════════════════════════

  void _load() {
    _exchangeRate = _prefs.getDouble(_exchangeRateKey) ?? defaultExchangeRate;
    _isBaseUsd = _prefs.getBool(_baseCurrencyUsdKey) ?? true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Settings
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحديث سعر الصرف
  Future<void> setExchangeRate(double value) async {
    if (value <= 0) return;
    _exchangeRate = value;
    await _prefs.setDouble(_exchangeRateKey, value);
    notifyListeners();
  }

  /// تحديث العملة الأساسية
  Future<void> setBaseCurrencyUsd(bool value) async {
    _isBaseUsd = value;
    await _prefs.setBool(_baseCurrencyUsdKey, value);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Core Conversions
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحويل من دولار إلى ليرة سورية
  double usdToSyp(double usd) => usd * _exchangeRate;

  /// تحويل من ليرة سورية إلى دولار
  double sypToUsd(double syp) => _exchangeRate == 0 ? 0 : syp / _exchangeRate;

  // ═══════════════════════════════════════════════════════════════════════════
  // Normalization (للاستخدام في POS و Reports)
  // ═══════════════════════════════════════════════════════════════════════════

  /// يحوّل القيمة إلى ليرة سورية حسب العملة الأساسية
  /// إذا كانت الأسعار بالدولار → يحوّل للّيرة
  /// إذا كانت بالليرة → يُرجعها كما هي
  double normalizeToSyp(double value) {
    return _isBaseUsd ? usdToSyp(value) : value;
  }

  /// يحوّل القيمة إلى دولار حسب العملة الأساسية
  /// إذا كانت الأسعار بالدولار → يُرجعها كما هي
  /// إذا كانت بالليرة → يحوّلها للدولار
  double normalizeToUsd(double value) {
    return _isBaseUsd ? value : sypToUsd(value);
  }
}
