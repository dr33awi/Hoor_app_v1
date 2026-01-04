import 'currency_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Price Locking Service - خدمة تثبيت الأسعار
/// ═══════════════════════════════════════════════════════════════════════════
///
/// هذه الخدمة مسؤولة عن:
/// 1. حساب وتثبيت الأسعار عند إنشاء العمليات
/// 2. ضمان عدم تغيير الأسعار بعد الحفظ
/// 3. توفير الأسعار بالعملتين (SYP + USD)
///
/// ⚠️ قواعد صارمة:
/// - كل عملية جديدة تحفظ سعر الصرف الحالي
/// - لا يُعاد حساب الأسعار القديمة عند تغيير سعر الصرف
/// - العرض يستخدم الأسعار المحفوظة فقط
/// ═══════════════════════════════════════════════════════════════════════════
class PriceLockingService {
  final CurrencyService _currencyService;

  PriceLockingService(this._currencyService);

  // ═══════════════════════════════════════════════════════════════════════════
  // سعر الصرف الحالي (للعمليات الجديدة فقط)
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على سعر الصرف الحالي للعمليات الجديدة
  double get currentExchangeRate => _currencyService.exchangeRate;

  /// هل العملة الأساسية هي الدولار؟
  bool get isBaseUsd => _currencyService.isBaseUsd;

  // ═══════════════════════════════════════════════════════════════════════════
  // تثبيت الأسعار (للعمليات الجديدة)
  // ═══════════════════════════════════════════════════════════════════════════

  /// تثبيت سعر جديد - يُنشئ سجل سعر مثبت
  ///
  /// [priceUsd] السعر بالدولار (المرجع الأساسي)
  /// يُرجع [LockedPrice] يحتوي على السعر بالعملتين وسعر الصرف
  LockedPrice lockPriceFromUsd(double priceUsd) {
    final rate = currentExchangeRate;
    return LockedPrice(
      usd: priceUsd,
      syp: priceUsd * rate,
      exchangeRate: rate,
      lockedAt: DateTime.now(),
    );
  }

  /// تثبيت سعر من الليرة السورية
  ///
  /// [priceSyp] السعر بالليرة
  /// يُحسب السعر بالدولار ويُثبت
  LockedPrice lockPriceFromSyp(double priceSyp) {
    final rate = currentExchangeRate;
    return LockedPrice(
      usd: rate > 0 ? priceSyp / rate : 0,
      syp: priceSyp,
      exchangeRate: rate,
      lockedAt: DateTime.now(),
    );
  }

  /// تثبيت سعر من أي عملة (يحدد تلقائياً حسب الإعداد)
  LockedPrice lockPrice(double price, {bool? isUsd}) {
    final useUsd = isUsd ?? isBaseUsd;
    return useUsd ? lockPriceFromUsd(price) : lockPriceFromSyp(price);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // استرجاع الأسعار المثبتة (للعرض)
  // ═══════════════════════════════════════════════════════════════════════════

  /// إنشاء سعر مثبت من قيم محفوظة في قاعدة البيانات
  ///
  /// ⚠️ هذا للعرض فقط - لا يُستخدم للحسابات الجديدة
  LockedPrice restoreLockedPrice({
    required double syp,
    double? usd,
    double? exchangeRate,
    DateTime? lockedAt,
  }) {
    // إذا لم يكن لدينا USD محفوظ، نحسبه من سعر الصرف المحفوظ
    final actualUsd = usd ??
        (exchangeRate != null && exchangeRate > 0 ? syp / exchangeRate : 0);

    return LockedPrice(
      syp: syp,
      usd: actualUsd,
      exchangeRate: exchangeRate ?? currentExchangeRate,
      lockedAt: lockedAt ?? DateTime.now(),
      isHistorical: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // حسابات مجمعة
  // ═══════════════════════════════════════════════════════════════════════════

  /// حساب إجمالي من قائمة أسعار مثبتة
  LockedPrice calculateTotal(List<LockedPrice> prices) {
    if (prices.isEmpty) {
      return LockedPrice.zero();
    }

    double totalSyp = 0;
    double totalUsd = 0;

    for (final price in prices) {
      totalSyp += price.syp;
      totalUsd += price.usd;
    }

    // نستخدم سعر الصرف المرجح
    final avgRate = totalUsd > 0 ? totalSyp / totalUsd : currentExchangeRate;

    return LockedPrice(
      syp: totalSyp,
      usd: totalUsd,
      exchangeRate: avgRate,
      lockedAt: DateTime.now(),
    );
  }

  /// حساب الفرق بين سعرين مثبتين
  LockedPrice calculateDifference(LockedPrice a, LockedPrice b) {
    return LockedPrice(
      syp: a.syp - b.syp,
      usd: a.usd - b.usd,
      exchangeRate: a.exchangeRate, // نستخدم سعر الصرف الأول
      lockedAt: DateTime.now(),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Locked Price - سعر مثبت
/// ═══════════════════════════════════════════════════════════════════════════
///
/// يمثل سعراً مثبتاً في لحظة معينة
/// يحتوي على:
/// - السعر بالليرة السورية
/// - السعر بالدولار
/// - سعر الصرف وقت التثبيت
/// - تاريخ التثبيت
/// ═══════════════════════════════════════════════════════════════════════════
class LockedPrice {
  /// السعر بالليرة السورية
  final double syp;

  /// السعر بالدولار
  final double usd;

  /// سعر الصرف وقت التثبيت
  final double exchangeRate;

  /// تاريخ التثبيت
  final DateTime lockedAt;

  /// هل هذا سعر تاريخي (من قاعدة البيانات)؟
  final bool isHistorical;

  const LockedPrice({
    required this.syp,
    required this.usd,
    required this.exchangeRate,
    required this.lockedAt,
    this.isHistorical = false,
  });

  /// سعر مثبت بقيمة صفر
  factory LockedPrice.zero() {
    return LockedPrice(
      syp: 0,
      usd: 0,
      exchangeRate: 1,
      lockedAt: DateTime.now(),
    );
  }

  /// نسخ مع تعديل
  LockedPrice copyWith({
    double? syp,
    double? usd,
    double? exchangeRate,
    DateTime? lockedAt,
    bool? isHistorical,
  }) {
    return LockedPrice(
      syp: syp ?? this.syp,
      usd: usd ?? this.usd,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      lockedAt: lockedAt ?? this.lockedAt,
      isHistorical: isHistorical ?? this.isHistorical,
    );
  }

  /// ضرب السعر في كمية
  LockedPrice multiply(int quantity) {
    return LockedPrice(
      syp: syp * quantity,
      usd: usd * quantity,
      exchangeRate: exchangeRate,
      lockedAt: lockedAt,
      isHistorical: isHistorical,
    );
  }

  /// هل السعر موجب؟
  bool get isPositive => syp > 0;

  /// هل السعر سالب؟
  bool get isNegative => syp < 0;

  /// هل السعر صفر؟
  bool get isZero => syp == 0 && usd == 0;

  /// القيمة المطلقة
  LockedPrice get abs {
    return LockedPrice(
      syp: syp.abs(),
      usd: usd.abs(),
      exchangeRate: exchangeRate,
      lockedAt: lockedAt,
      isHistorical: isHistorical,
    );
  }

  /// عكس الإشارة
  LockedPrice get negate {
    return LockedPrice(
      syp: -syp,
      usd: -usd,
      exchangeRate: exchangeRate,
      lockedAt: lockedAt,
      isHistorical: isHistorical,
    );
  }

  @override
  String toString() {
    return 'LockedPrice(syp: $syp, usd: $usd, rate: $exchangeRate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LockedPrice &&
        other.syp == syp &&
        other.usd == usd &&
        other.exchangeRate == exchangeRate;
  }

  @override
  int get hashCode => Object.hash(syp, usd, exchangeRate);
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Extension methods للتعامل مع الأسعار المثبتة
/// ═══════════════════════════════════════════════════════════════════════════
extension LockedPriceListExtension on List<LockedPrice> {
  /// حساب المجموع
  LockedPrice get total {
    if (isEmpty) return LockedPrice.zero();

    double totalSyp = 0;
    double totalUsd = 0;

    for (final price in this) {
      totalSyp += price.syp;
      totalUsd += price.usd;
    }

    final avgRate = totalUsd > 0 ? totalSyp / totalUsd : first.exchangeRate;

    return LockedPrice(
      syp: totalSyp,
      usd: totalUsd,
      exchangeRate: avgRate,
      lockedAt: DateTime.now(),
    );
  }
}
