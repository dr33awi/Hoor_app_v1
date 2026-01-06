import 'currency_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ██╗░░██╗░█████╗░░█████╗░██████╗░  ██████╗░██████╗░██╗░█████╗░███████╗
// ██║░░██║██╔══██╗██╔══██╗██╔══██╗  ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝
// ███████║██║░░██║██║░░██║██████╔╝  ██████╔╝██████╔╝██║██║░░╚═╝█████╗░░
// ██╔══██║██║░░██║██║░░██║██╔══██╗  ██╔═══╝░██╔══██╗██║██║░░██╗██╔══╝░░
// ██║░░██║╚█████╔╝╚█████╔╝██║░░██║  ██║░░░░░██║░░██║██║╚█████╔╝███████╗
// ╚═╝░░╚═╝░╚════╝░░╚════╝░╚═╝░░╚═╝  ╚═╝░░░░░╚═╝░░╚═╝╚═╝░╚════╝░╚══════╝
// ██╗░░░░░░█████╗░░█████╗░██╗░░██╗██╗███╗░░██╗░██████╗░
// ██║░░░░░██╔══██╗██╔══██╗██║░██╔╝██║████╗░██║██╔════╝░
// ██║░░░░░██║░░██║██║░░╚═╝█████═╝░██║██╔██╗██║██║░░██╗░
// ██║░░░░░██║░░██║██║░░██╗██╔═██╗░██║██║╚████║██║░░╚██╗
// ███████╗╚█████╔╝╚█████╔╝██║░╚██╗██║██║░╚███║╚██████╔╝
// ╚══════╝░╚════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░╚══╝░╚═════╝░
// ═══════════════════════════════════════════════════════════════════════════════
//                      خدمة تثبيت الأسعار
//                   Price Locking Service
// ═══════════════════════════════════════════════════════════════════════════════
//
// ⚠️ السياسة المحاسبية الصارمة - STRICT ACCOUNTING POLICY ⚠️
//
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ القاعدة الذهبية: كل عملية تحفظ سعرها بالعملتين وسعر الصرف                   │
// │                  ولا تتغير هذه القيم أبداً بعد الحفظ                         │
// └─────────────────────────────────────────────────────────────────────────────┘
//
// ═══════════════════════════════════════════════════════════════════════════════
// متى يُستخدم سعر الصرف الحالي (currentExchangeRate)؟
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ فقط عند إنشاء عملية جديدة (بيع، شراء، سند، مصروف)
// ✅ فقط في lockPrice(), lockPriceFromUsd(), lockPriceFromSyp()
//
// ═══════════════════════════════════════════════════════════════════════════════
// متى لا يُستخدم سعر الصرف الحالي؟
// ═══════════════════════════════════════════════════════════════════════════════
// ❌ في التقارير المحاسبية
// ❌ عند عرض فواتير قديمة
// ❌ عند حساب إجماليات
// ❌ في أي مكان يتعامل مع LockedPrice محفوظ
//
// ═══════════════════════════════════════════════════════════════════════════════
// ماذا يحدث عند تغيير سعر الصرف؟
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ يؤثر على: العمليات الجديدة فقط
// ❌ لا يؤثر على: أي عملية سابقة أو تقرير سابق
// ═══════════════════════════════════════════════════════════════════════════════

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
  // استرجاع الأسعار المثبتة (للعرض والتقارير)
  // ═══════════════════════════════════════════════════════════════════════════

  /// إنشاء سعر مثبت من قيم محفوظة في قاعدة البيانات
  ///
  /// ⚠️ هذا للعرض والتقارير فقط - لا يُستخدم للحسابات الجديدة
  /// ⚠️ لا تستخدم currentExchangeRate للحساب - استخدم القيم المحفوظة فقط
  ///
  /// مثال صحيح:
  /// ```dart
  /// final lockedPrice = restoreLockedPrice(
  ///   syp: invoice.total,
  ///   usd: invoice.totalUsd,
  ///   exchangeRate: invoice.exchangeRate,
  ///   lockedAt: invoice.invoiceDate,
  /// );
  /// ```
  LockedPrice restoreLockedPrice({
    required double syp,
    double? usd,
    double? exchangeRate,
    DateTime? lockedAt,
  }) {
    // ═══════════════════════════════════════════════════════════════════════
    // ⚠️ نستخدم سعر الصرف المحفوظ (القديم) وليس الحالي
    // هذا ضروري للحفاظ على دقة التقارير المحاسبية
    // ═══════════════════════════════════════════════════════════════════════
    final actualUsd = usd ??
        (exchangeRate != null && exchangeRate > 0 ? syp / exchangeRate : 0);

    return LockedPrice(
      syp: syp,
      usd: actualUsd,
      // ⚠️ نحفظ سعر الصرف القديم - ليس الحالي!
      exchangeRate: exchangeRate ?? 0,
      lockedAt: lockedAt ?? DateTime.now(),
      isHistorical: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // حسابات مجمعة (للتقارير المحاسبية)
  // ═══════════════════════════════════════════════════════════════════════════

  /// حساب إجمالي من قائمة أسعار مثبتة
  ///
  /// ⚠️ قاعدة محاسبية صارمة:
  /// - totalSyp = Σ lockedPrice.syp (جمع مباشر بدون تحويل)
  /// - totalUsd = Σ lockedPrice.usd (جمع مباشر بدون تحويل)
  /// - لا نستخدم سعر الصرف الحالي!
  LockedPrice calculateTotal(List<LockedPrice> prices) {
    if (prices.isEmpty) {
      return LockedPrice.zero();
    }

    double totalSyp = 0;
    double totalUsd = 0;

    // ═══════════════════════════════════════════════════════════════════════
    // ⚠️ الجمع المباشر للقيم المثبتة - بدون أي تحويل
    // ═══════════════════════════════════════════════════════════════════════
    for (final price in prices) {
      totalSyp += price.syp;
      totalUsd += price.usd;
    }

    // سعر الصرف المرجح (للمعلومات فقط - لا يُستخدم للحسابات)
    final avgRate = totalUsd > 0 ? totalSyp / totalUsd : 0.0;

    return LockedPrice(
      syp: totalSyp,
      usd: totalUsd,
      exchangeRate: avgRate,
      lockedAt: DateTime.now(),
      isHistorical: true, // تم حسابه من قيم تاريخية
    );
  }

  /// حساب الفرق بين سعرين مثبتين
  ///
  /// مثال: الربح = المبيعات - المشتريات
  /// - profitSyp = salesSyp - purchasesSyp
  /// - profitUsd = salesUsd - purchasesUsd
  LockedPrice calculateDifference(LockedPrice a, LockedPrice b) {
    return LockedPrice(
      syp: a.syp - b.syp,
      usd: a.usd - b.usd,
      // سعر الصرف المرجح للنتيجة
      exchangeRate:
          (a.usd - b.usd) != 0 ? (a.syp - b.syp) / (a.usd - b.usd) : 0,
      lockedAt: DateTime.now(),
      isHistorical: true,
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
/// Extension methods للتعامل مع الأسعار المثبتة (للتقارير)
/// ═══════════════════════════════════════════════════════════════════════════
extension LockedPriceListExtension on List<LockedPrice> {
  /// حساب المجموع
  ///
  /// ⚠️ قاعدة محاسبية: الجمع المباشر بدون تحويل العملات
  /// totalSyp = Σ syp
  /// totalUsd = Σ usd
  LockedPrice get total {
    if (isEmpty) return LockedPrice.zero();

    double totalSyp = 0;
    double totalUsd = 0;

    // ═══════════════════════════════════════════════════════════════════════
    // ⚠️ جمع مباشر - لا تحويل عملات
    // ═══════════════════════════════════════════════════════════════════════
    for (final price in this) {
      totalSyp += price.syp;
      totalUsd += price.usd;
    }

    // سعر الصرف المرجح (للمعلومات فقط)
    final avgRate = totalUsd > 0 ? totalSyp / totalUsd : 0.0;

    return LockedPrice(
      syp: totalSyp,
      usd: totalUsd,
      exchangeRate: avgRate,
      lockedAt: DateTime.now(),
      isHistorical: true,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ملاحظات السياسة المحاسبية
// ═══════════════════════════════════════════════════════════════════════════════
//
// س: إذا تغير سعر الصرف اليوم، هل ستتغير تقارير الشهر الماضي؟
// ج: ❌ لا، لأن:
//
// 1. كل فاتورة تحفظ:
//    - total (بالليرة)
//    - totalUsd (بالدولار)
//    - exchangeRate (سعر الصرف وقت الإنشاء)
//
// 2. التقارير تحسب:
//    - totalSyp = Σ invoice.total (بدون تحويل)
//    - totalUsd = Σ invoice.totalUsd (بدون تحويل)
//
// 3. لا نستخدم CurrencyService.currentExchangeRate في:
//    - حساب التقارير
//    - عرض البيانات القديمة
//    - أي حسابات على LockedPrice
//
// ═══════════════════════════════════════════════════════════════════════════════
