import 'package:flutter/material.dart';

import 'price_locking_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ██╗░░██╗░█████╗░░█████╗░██████╗░  ███████╗██╗███╗░░██╗░█████╗░███╗░░██╗░█████╗░███████╗
// ██║░░██║██╔══██╗██╔══██╗██╔══██╗  ██╔════╝██║████╗░██║██╔══██╗████╗░██║██╔══██╗██╔════╝
// ███████║██║░░██║██║░░██║██████╔╝  █████╗░░██║██╔██╗██║███████║██╔██╗██║██║░░╚═╝█████╗░░
// ██╔══██║██║░░██║██║░░██║██╔══██╗  ██╔══╝░░██║██║╚████║██╔══██║██║╚████║██║░░██╗██╔══╝░░
// ██║░░██║╚█████╔╝╚█████╔╝██║░░██║  ██║░░░░░██║██║░╚███║██║░░██║██║░╚███║╚█████╔╝███████╗
// ╚═╝░░╚═╝░╚════╝░░╚════╝░╚═╝░░╚═╝  ╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░╚═╝╚═╝░░╚══╝░╚════╝░╚══════╝
// ═══════════════════════════════════════════════════════════════════════════════
//                        خدمة التقارير المحاسبية
//                    Accounting Report Service
// ═══════════════════════════════════════════════════════════════════════════════
//
// ⚠️ السياسة المحاسبية الصارمة - STRICT ACCOUNTING POLICY ⚠️
//
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ القاعدة الذهبية: التقارير المحاسبية تستخدم الأسعار المثبتة (LockedPrice)     │
// │                  فقط ولا تتأثر بتغيير سعر الصرف الحالي أبداً                 │
// └─────────────────────────────────────────────────────────────────────────────┘
//
// ═══════════════════════════════════════════════════════════════════════════════
// الممنوعات (PROHIBITED):
// ═══════════════════════════════════════════════════════════════════════════════
// ❌ استخدام CurrencyService لتحويل الأسعار في التقارير
// ❌ إعادة حساب USD ↔ SYP عند عرض التقارير
// ❌ تعديل البيانات القديمة عند تغيير سعر الصرف
// ❌ استخدام currentExchangeRate في حسابات التقارير المحاسبية
// ❌ جمع SYP + USD عبر تحويل بسعر الصرف الحالي
//
// ═══════════════════════════════════════════════════════════════════════════════
// المسموحات (ALLOWED):
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ جمع lockedPrice.syp + lockedPrice.syp = totalSyp
// ✅ جمع lockedPrice.usd + lockedPrice.usd = totalUsd
// ✅ عرض كلا القيمتين (العملة المزدوجة)
// ✅ التقارير التحليلية (مع تمييزها بوضوح)
//
// ═══════════════════════════════════════════════════════════════════════════════
// سؤال: إذا تغير سعر الصرف اليوم، هل تتغير تقارير الشهر الماضي؟
// جواب: ❌ لا - لأن التقارير تستخدم القيم المحفوظة في LockedPrice وليس سعر الصرف الحالي
// ═══════════════════════════════════════════════════════════════════════════════

/// نوع التقرير
enum ReportType {
  /// تقرير محاسبي رسمي - يستخدم LockedPrice فقط
  accounting,

  /// تقرير تحليلي - يمكن استخدام سعر الصرف الحالي (مع تحذير)
  analytical,
}

/// ═══════════════════════════════════════════════════════════════════════════
/// نتيجة التقرير - Report Result
/// ═══════════════════════════════════════════════════════════════════════════
///
/// تحتوي على:
/// - إجمالي بالليرة السورية (من القيم المثبتة)
/// - إجمالي بالدولار (من القيم المثبتة)
/// - عدد العناصر
/// - نوع التقرير
/// ═══════════════════════════════════════════════════════════════════════════
class ReportResult {
  /// الإجمالي بالليرة السورية (مجموع lockedPrice.syp)
  final double totalSyp;

  /// الإجمالي بالدولار (مجموع lockedPrice.usd)
  final double totalUsd;

  /// عدد العناصر في التقرير
  final int itemCount;

  /// نوع التقرير (محاسبي / تحليلي)
  final ReportType reportType;

  /// تاريخ إنشاء التقرير
  final DateTime generatedAt;

  /// الفترة الزمنية للتقرير
  final DateTimeRange? dateRange;

  /// بيانات إضافية (للتقارير المتقدمة)
  final Map<String, dynamic>? metadata;

  const ReportResult({
    required this.totalSyp,
    required this.totalUsd,
    required this.itemCount,
    required this.reportType,
    required this.generatedAt,
    this.dateRange,
    this.metadata,
  });

  /// إنشاء تقرير فارغ
  factory ReportResult.empty({
    ReportType type = ReportType.accounting,
    DateTimeRange? dateRange,
  }) {
    return ReportResult(
      totalSyp: 0,
      totalUsd: 0,
      itemCount: 0,
      reportType: type,
      generatedAt: DateTime.now(),
      dateRange: dateRange,
    );
  }

  /// إنشاء تقرير من قائمة أسعار مثبتة
  ///
  /// ⚠️ هذا هو الأسلوب الصحيح الوحيد لحساب التقارير المحاسبية
  factory ReportResult.fromLockedPrices({
    required List<LockedPrice> prices,
    ReportType type = ReportType.accounting,
    DateTimeRange? dateRange,
    Map<String, dynamic>? metadata,
  }) {
    double totalSyp = 0;
    double totalUsd = 0;

    // ═══════════════════════════════════════════════════════════════════════
    // ⚠️ الجمع المباشر للقيم المثبتة - بدون أي تحويل
    // ═══════════════════════════════════════════════════════════════════════
    for (final price in prices) {
      totalSyp += price.syp;
      totalUsd += price.usd;
    }

    return ReportResult(
      totalSyp: totalSyp,
      totalUsd: totalUsd,
      itemCount: prices.length,
      reportType: type,
      generatedAt: DateTime.now(),
      dateRange: dateRange,
      metadata: metadata,
    );
  }

  /// هل هذا تقرير محاسبي رسمي؟
  bool get isAccountingReport => reportType == ReportType.accounting;

  /// هل هذا تقرير تحليلي؟
  bool get isAnalyticalReport => reportType == ReportType.analytical;

  /// تحويل إلى LockedPrice (للتوافق)
  LockedPrice toLockedPrice() {
    return LockedPrice(
      syp: totalSyp,
      usd: totalUsd,
      exchangeRate: totalUsd > 0 ? totalSyp / totalUsd : 0,
      lockedAt: generatedAt,
      isHistorical: true,
    );
  }

  @override
  String toString() {
    return 'ReportResult('
        'type: ${reportType.name}, '
        'syp: $totalSyp, '
        'usd: $totalUsd, '
        'items: $itemCount, '
        'at: $generatedAt'
        ')';
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// تقرير الأرباح والخسائر - Profit & Loss Report
/// ═══════════════════════════════════════════════════════════════════════════
class ProfitLossReport {
  /// إجمالي المبيعات
  final ReportResult sales;

  /// إجمالي المشتريات / تكلفة البضاعة المباعة
  final ReportResult purchases;

  /// إجمالي المصاريف
  final ReportResult expenses;

  /// إجمالي الإيرادات الأخرى
  final ReportResult otherIncome;

  /// نوع التقرير
  final ReportType reportType;

  /// تاريخ الإنشاء
  final DateTime generatedAt;

  /// الفترة الزمنية
  final DateTimeRange? dateRange;

  const ProfitLossReport({
    required this.sales,
    required this.purchases,
    required this.expenses,
    required this.otherIncome,
    required this.reportType,
    required this.generatedAt,
    this.dateRange,
  });

  /// إجمالي الربح بالليرة = المبيعات - المشتريات
  double get grossProfitSyp => sales.totalSyp - purchases.totalSyp;

  /// إجمالي الربح بالدولار = المبيعات - المشتريات
  double get grossProfitUsd => sales.totalUsd - purchases.totalUsd;

  /// صافي الربح بالليرة = إجمالي الربح - المصاريف + الإيرادات الأخرى
  double get netProfitSyp =>
      grossProfitSyp - expenses.totalSyp + otherIncome.totalSyp;

  /// صافي الربح بالدولار = إجمالي الربح - المصاريف + الإيرادات الأخرى
  double get netProfitUsd =>
      grossProfitUsd - expenses.totalUsd + otherIncome.totalUsd;

  /// هامش الربح الإجمالي (%)
  double get grossProfitMargin =>
      sales.totalSyp > 0 ? (grossProfitSyp / sales.totalSyp) * 100 : 0;

  /// هامش صافي الربح (%)
  double get netProfitMargin =>
      sales.totalSyp > 0 ? (netProfitSyp / sales.totalSyp) * 100 : 0;

  /// هل الشركة رابحة؟
  bool get isProfitable => netProfitSyp > 0;

  /// تحويل الربح الإجمالي إلى LockedPrice
  LockedPrice get grossProfitLocked => LockedPrice(
        syp: grossProfitSyp,
        usd: grossProfitUsd,
        exchangeRate: grossProfitUsd > 0 ? grossProfitSyp / grossProfitUsd : 0,
        lockedAt: generatedAt,
        isHistorical: true,
      );

  /// تحويل صافي الربح إلى LockedPrice
  LockedPrice get netProfitLocked => LockedPrice(
        syp: netProfitSyp,
        usd: netProfitUsd,
        exchangeRate: netProfitUsd > 0 ? netProfitSyp / netProfitUsd : 0,
        lockedAt: generatedAt,
        isHistorical: true,
      );
}

/// ═══════════════════════════════════════════════════════════════════════════
/// تقرير الذمم - Receivables/Payables Report
/// ═══════════════════════════════════════════════════════════════════════════
class BalanceReport {
  /// قائمة الأرصدة
  final List<BalanceItem> items;

  /// نوع التقرير
  final ReportType reportType;

  /// تاريخ الإنشاء
  final DateTime generatedAt;

  const BalanceReport({
    required this.items,
    required this.reportType,
    required this.generatedAt,
  });

  /// الإجمالي بالليرة السورية
  double get totalSyp => items.fold(0.0, (sum, item) => sum + item.balanceSyp);

  /// الإجمالي بالدولار
  double get totalUsd => items.fold(0.0, (sum, item) => sum + item.balanceUsd);

  /// عدد العناصر
  int get itemCount => items.length;

  /// العناصر التي لها رصيد موجب
  List<BalanceItem> get positiveBalances =>
      items.where((i) => i.balanceSyp > 0).toList();

  /// العناصر التي لها رصيد سالب
  List<BalanceItem> get negativeBalances =>
      items.where((i) => i.balanceSyp < 0).toList();
}

/// عنصر رصيد (عميل أو مورد)
class BalanceItem {
  final String id;
  final String name;
  final double balanceSyp;
  final double balanceUsd;
  final DateTime? lastTransactionDate;

  const BalanceItem({
    required this.id,
    required this.name,
    required this.balanceSyp,
    required this.balanceUsd,
    this.lastTransactionDate,
  });

  /// تحويل إلى LockedPrice
  LockedPrice toLockedPrice(double exchangeRate) => LockedPrice(
        syp: balanceSyp,
        usd: balanceUsd,
        exchangeRate: exchangeRate,
        lockedAt: lastTransactionDate ?? DateTime.now(),
        isHistorical: true,
      );
}

/// ═══════════════════════════════════════════════════════════════════════════
/// خدمة التقارير - Report Service
/// ═══════════════════════════════════════════════════════════════════════════
///
/// ⚠️ قواعد استخدام هذه الخدمة:
/// 1. جميع الحسابات تستخدم LockedPrice فقط
/// 2. لا يُستخدم CurrencyService لتحويل الأسعار
/// 3. تغيير سعر الصرف لا يؤثر على التقارير السابقة
/// ═══════════════════════════════════════════════════════════════════════════
class ReportService {
  /// ═══════════════════════════════════════════════════════════════════════
  /// حساب إجمالي من قائمة أسعار مثبتة
  /// ═══════════════════════════════════════════════════════════════════════
  ///
  /// ✅ الاستخدام الصحيح:
  /// ```dart
  /// final total = reportService.calculateTotal(lockedPrices);
  /// // total.totalSyp = مجموع syp
  /// // total.totalUsd = مجموع usd
  /// ```
  ///
  /// ❌ الاستخدام الخاطئ:
  /// ```dart
  /// final total = prices.fold(0, (sum, p) => sum + p.syp);
  /// final usd = total / currentExchangeRate; // ممنوع!
  /// ```
  ReportResult calculateTotal(
    List<LockedPrice> prices, {
    DateTimeRange? dateRange,
  }) {
    return ReportResult.fromLockedPrices(
      prices: prices,
      type: ReportType.accounting,
      dateRange: dateRange,
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// حساب الفرق بين مجموعتين (مثل: المبيعات - المشتريات)
  /// ═══════════════════════════════════════════════════════════════════════
  ReportResult calculateDifference(
    ReportResult a,
    ReportResult b, {
    DateTimeRange? dateRange,
  }) {
    return ReportResult(
      totalSyp: a.totalSyp - b.totalSyp,
      totalUsd: a.totalUsd - b.totalUsd,
      itemCount: a.itemCount + b.itemCount,
      reportType: ReportType.accounting,
      generatedAt: DateTime.now(),
      dateRange: dateRange,
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// دمج عدة تقارير في تقرير واحد
  /// ═══════════════════════════════════════════════════════════════════════
  ReportResult mergeReports(
    List<ReportResult> reports, {
    DateTimeRange? dateRange,
  }) {
    double totalSyp = 0;
    double totalUsd = 0;
    int totalItems = 0;

    for (final report in reports) {
      totalSyp += report.totalSyp;
      totalUsd += report.totalUsd;
      totalItems += report.itemCount;
    }

    return ReportResult(
      totalSyp: totalSyp,
      totalUsd: totalUsd,
      itemCount: totalItems,
      reportType: ReportType.accounting,
      generatedAt: DateTime.now(),
      dateRange: dateRange,
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// إنشاء تقرير الأرباح والخسائر
  /// ═══════════════════════════════════════════════════════════════════════
  ///
  /// المعادلة:
  /// إجمالي الربح = المبيعات - المشتريات
  /// صافي الربح = إجمالي الربح - المصاريف + الإيرادات الأخرى
  ///
  /// ⚠️ جميع القيم من LockedPrice - لا تحويل
  ProfitLossReport createProfitLossReport({
    required List<LockedPrice> salesPrices,
    required List<LockedPrice> purchasesPrices,
    required List<LockedPrice> expensesPrices,
    List<LockedPrice>? otherIncomePrices,
    DateTimeRange? dateRange,
  }) {
    return ProfitLossReport(
      sales: ReportResult.fromLockedPrices(
        prices: salesPrices,
        dateRange: dateRange,
      ),
      purchases: ReportResult.fromLockedPrices(
        prices: purchasesPrices,
        dateRange: dateRange,
      ),
      expenses: ReportResult.fromLockedPrices(
        prices: expensesPrices,
        dateRange: dateRange,
      ),
      otherIncome: ReportResult.fromLockedPrices(
        prices: otherIncomePrices ?? [],
        dateRange: dateRange,
      ),
      reportType: ReportType.accounting,
      generatedAt: DateTime.now(),
      dateRange: dateRange,
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// إنشاء تقرير تحليلي (استثنائي)
  /// ═══════════════════════════════════════════════════════════════════════
  ///
  /// ⚠️ تحذير: هذا تقرير تحليلي وليس محاسبي
  /// يُستخدم فقط لأغراض المقارنة والتحليل
  /// لا يُعتمد للأغراض المحاسبية الرسمية
  ReportResult createAnalyticalReport({
    required List<LockedPrice> prices,
    required double currentExchangeRate,
    DateTimeRange? dateRange,
    Map<String, dynamic>? metadata,
  }) {
    // حتى في التقارير التحليلية، نجمع القيم المثبتة
    // لكن نضيف معلومات إضافية للمقارنة
    final result = ReportResult.fromLockedPrices(
      prices: prices,
      type: ReportType.analytical,
      dateRange: dateRange,
      metadata: {
        ...?metadata,
        'currentExchangeRate': currentExchangeRate,
        'analyticalUsdEquivalent':
            prices.fold(0.0, (sum, p) => sum + p.syp) / currentExchangeRate,
        'warning':
            'هذا تقرير تحليلي - القيم المحسوبة بسعر الصرف الحالي للمقارنة فقط',
      },
    );

    return result;
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// استخراج LockedPrice من بيانات الفاتورة المحفوظة
  /// ═══════════════════════════════════════════════════════════════════════
  ///
  /// يُستخدم لتحويل بيانات قاعدة البيانات إلى LockedPrice
  /// بدون أي حسابات جديدة
  LockedPrice extractLockedPriceFromInvoice({
    required double total,
    double? totalUsd,
    double? exchangeRate,
    DateTime? invoiceDate,
  }) {
    // استخدام القيم المحفوظة كما هي
    return LockedPrice(
      syp: total,
      usd: totalUsd ??
          (exchangeRate != null && exchangeRate > 0 ? total / exchangeRate : 0),
      exchangeRate: exchangeRate ?? 0,
      lockedAt: invoiceDate ?? DateTime.now(),
      isHistorical: true,
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// استخراج LockedPrice من بيانات السند المحفوظة
  /// ═══════════════════════════════════════════════════════════════════════
  LockedPrice extractLockedPriceFromVoucher({
    required double amount,
    double? amountUsd,
    double? exchangeRate,
    DateTime? voucherDate,
  }) {
    return LockedPrice(
      syp: amount,
      usd: amountUsd ??
          (exchangeRate != null && exchangeRate > 0
              ? amount / exchangeRate
              : 0),
      exchangeRate: exchangeRate ?? 0,
      lockedAt: voucherDate ?? DateTime.now(),
      isHistorical: true,
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// استخراج LockedPrice من بيانات المصروف المحفوظة
  /// ═══════════════════════════════════════════════════════════════════════
  LockedPrice extractLockedPriceFromExpense({
    required double amount,
    double? amountUsd,
    double? exchangeRate,
    DateTime? expenseDate,
  }) {
    return LockedPrice(
      syp: amount,
      usd: amountUsd ??
          (exchangeRate != null && exchangeRate > 0
              ? amount / exchangeRate
              : 0),
      exchangeRate: exchangeRate ?? 0,
      lockedAt: expenseDate ?? DateTime.now(),
      isHistorical: true,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Extension لتسهيل العمل مع قوائم الفواتير
/// ═══════════════════════════════════════════════════════════════════════════
extension InvoiceListReportExtension<T> on List<T> {
  /// تحويل قائمة إلى تقرير باستخدام LockedPrice extractor
  ///
  /// مثال:
  /// ```dart
  /// final report = invoices.toReport(
  ///   (inv) => LockedPrice(
  ///     syp: inv.total,
  ///     usd: inv.totalUsd ?? 0,
  ///     exchangeRate: inv.exchangeRate ?? 0,
  ///     lockedAt: inv.invoiceDate,
  ///   ),
  /// );
  /// ```
  ReportResult toReport(
    LockedPrice Function(T item) extractPrice, {
    DateTimeRange? dateRange,
  }) {
    final prices = map(extractPrice).toList();
    return ReportResult.fromLockedPrices(
      prices: prices,
      dateRange: dateRange,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ملاحظات التوثيق
/// ═══════════════════════════════════════════════════════════════════════════
///
/// س: إذا تغير سعر الصرف اليوم، هل ستتغير تقارير الشهر الماضي؟
/// ج: ❌ لا، وذلك للأسباب التالية:
///
/// 1. جميع الفواتير تحفظ:
///    - total (بالليرة السورية)
///    - totalUsd (بالدولار)
///    - exchangeRate (سعر الصرف وقت الإنشاء)
///
/// 2. عند حساب التقارير:
///    - نجمع total + total = totalSyp (بدون تحويل)
///    - نجمع totalUsd + totalUsd = totalUsd (بدون تحويل)
///
/// 3. لا نستخدم CurrencyService.currentExchangeRate في:
///    - حساب إجماليات التقارير
///    - تحويل العملات عند العرض
///    - أي حسابات على بيانات قديمة
///
/// 4. الاستثناء الوحيد:
///    - التقارير التحليلية (للمقارنة فقط)
///    - يجب تمييزها بوضوح كتقارير غير محاسبية
///
/// ═══════════════════════════════════════════════════════════════════════════
