// ═══════════════════════════════════════════════════════════════════════════
// Recurring Expense Template - قوالب المصاريف الدورية
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════
//
// ⚠️ سياسة المصاريف الدورية الصارمة:
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ ✅ كل مصروف يحمل Period Key فريد لمنع التكرار                               │
// │ ✅ المصاريف الموزعة تُقسم على فترات زمنية                                   │
// │ ✅ تقرير P&L يعرض فقط نصيب الفترة من المصاريف الموزعة                       │
// │ ✅ تعديل القالب لا يؤثر على الفترات السابقة                                 │
// └─────────────────────────────────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:intl/intl.dart';

/// فترة التكرار
enum RecurrenceFrequency {
  daily('يومي', 1),
  weekly('أسبوعي', 7),
  biweekly('نصف شهري', 14),
  monthly('شهري', 30),
  quarterly('ربع سنوي', 90),
  yearly('سنوي', 365);

  final String arabicName;
  final int days;
  const RecurrenceFrequency(this.arabicName, this.days);

  /// عدد الفترات في السنة
  int get periodsPerYear {
    switch (this) {
      case RecurrenceFrequency.daily:
        return 365;
      case RecurrenceFrequency.weekly:
        return 52;
      case RecurrenceFrequency.biweekly:
        return 26;
      case RecurrenceFrequency.monthly:
        return 12;
      case RecurrenceFrequency.quarterly:
        return 4;
      case RecurrenceFrequency.yearly:
        return 1;
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// نوع توزيع المصروف - Expense Distribution Type
/// ═══════════════════════════════════════════════════════════════════════════
enum ExpenseDistributionType {
  /// مصروف فوري - يظهر كاملًا في فترة التسجيل
  immediate('فوري', 'يظهر كاملًا عند التسجيل'),

  /// مصروف موزع - يُقسم على عدة فترات
  distributed('موزّع', 'يُقسم على فترات زمنية');

  final String arabicName;
  final String description;
  const ExpenseDistributionType(this.arabicName, this.description);
}

/// ═══════════════════════════════════════════════════════════════════════════
/// فترة التوزيع - Distribution Period
/// ═══════════════════════════════════════════════════════════════════════════
enum DistributionPeriod {
  /// توزيع شهري (12 فترة للسنة)
  monthly('شهري', 12),

  /// توزيع ربع سنوي (4 فترات للسنة)
  quarterly('ربع سنوي', 4),

  /// توزيع نصف سنوي (فترتان للسنة)
  semiAnnual('نصف سنوي', 2),

  /// توزيع سنوي (فترة واحدة)
  annual('سنوي', 1);

  final String arabicName;
  final int periodsPerYear;
  const DistributionPeriod(this.arabicName, this.periodsPerYear);
}

/// ═══════════════════════════════════════════════════════════════════════════
/// قالب المصروف الدوري - Recurring Expense Template
/// ═══════════════════════════════════════════════════════════════════════════
///
/// يدعم نوعين من المصاريف:
/// 1. فوري (immediate): يظهر كاملًا في تقرير الفترة
/// 2. موزّع (distributed): يُقسم على عدة فترات
///
/// مثال: إيجار سنوي 12,000,000 ل.س
/// - فوري: يظهر 12,000,000 في شهر الدفع
/// - موزّع شهري: يظهر 1,000,000 كل شهر
/// ═══════════════════════════════════════════════════════════════════════════
class RecurringExpenseTemplate {
  final String id;
  final String name;
  final String? categoryId;
  final String? categoryName;
  final double amountSyp;
  final double? amountUsd;
  final double? exchangeRate; // سعر الصرف وقت الإنشاء
  final String? description;
  final RecurrenceFrequency frequency;
  final DateTime? lastGeneratedDate;
  final DateTime? nextDueDate;
  final bool isActive;
  final DateTime createdAt;

  // ═══════════════════════════════════════════════════════════════════════════
  // إعدادات التوزيع (للمصاريف الكبيرة)
  // ═══════════════════════════════════════════════════════════════════════════
  /// نوع التوزيع: فوري أو موزّع
  final ExpenseDistributionType distributionType;

  /// فترة التوزيع (للمصاريف الموزعة فقط)
  final DistributionPeriod? distributionPeriod;

  /// عدد فترات التوزيع (مثلاً 12 شهر)
  final int? distributionCount;

  /// تاريخ بداية التوزيع
  final DateTime? distributionStartDate;

  /// تاريخ نهاية التوزيع
  final DateTime? distributionEndDate;

  RecurringExpenseTemplate({
    required this.id,
    required this.name,
    this.categoryId,
    this.categoryName,
    required this.amountSyp,
    this.amountUsd,
    this.exchangeRate,
    this.description,
    required this.frequency,
    this.lastGeneratedDate,
    this.nextDueDate,
    this.isActive = true,
    DateTime? createdAt,
    this.distributionType = ExpenseDistributionType.immediate,
    this.distributionPeriod,
    this.distributionCount,
    this.distributionStartDate,
    this.distributionEndDate,
  }) : createdAt = createdAt ?? DateTime.now();

  /// ═══════════════════════════════════════════════════════════════════════════
  /// توليد Period Key فريد لمنع التكرار
  /// ═══════════════════════════════════════════════════════════════════════════
  /// للمصاريف الموزعة: يُولد مفتاح شهري بغض النظر عن التكرار الأصلي
  /// مثال: abc123_2026_01 (يناير 2026)
  String generatePeriodKey([DateTime? date]) {
    final targetDate = date ?? DateTime.now();

    // ═══════════════════════════════════════════════════════════════════════
    // المصاريف الموزعة: دائماً مفتاح شهري (لإنشاء قسط كل شهر)
    // ═══════════════════════════════════════════════════════════════════════
    if (distributionType == ExpenseDistributionType.distributed) {
      return '${id}_${targetDate.year}_${targetDate.month.toString().padLeft(2, '0')}';
    }

    // ═══════════════════════════════════════════════════════════════════════
    // المصاريف الفورية: حسب التكرار الأصلي
    // ═══════════════════════════════════════════════════════════════════════
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return '${id}_${DateFormat('yyyy-MM-dd').format(targetDate)}';
      case RecurrenceFrequency.weekly:
        final weekOfYear = _getWeekOfYear(targetDate);
        return '${id}_${targetDate.year}_W$weekOfYear';
      case RecurrenceFrequency.biweekly:
        final biweek = (_getWeekOfYear(targetDate) / 2).ceil();
        return '${id}_${targetDate.year}_BW$biweek';
      case RecurrenceFrequency.monthly:
        return '${id}_${targetDate.year}_${targetDate.month.toString().padLeft(2, '0')}';
      case RecurrenceFrequency.quarterly:
        final quarter = ((targetDate.month - 1) / 3).floor() + 1;
        return '${id}_${targetDate.year}_Q$quarter';
      case RecurrenceFrequency.yearly:
        return '${id}_${targetDate.year}';
    }
  }

  /// حساب رقم الأسبوع في السنة
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    return ((daysDiff + firstDayOfYear.weekday) / 7).ceil();
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// حساب المبلغ لفترة معينة (للمصاريف الموزعة)
  /// ═══════════════════════════════════════════════════════════════════════════
  /// المصروف السنوي الموزع: المبلغ ÷ 12 (قسط شهري)
  /// المصروف الربعي الموزع: المبلغ ÷ 3 (قسط شهري لـ 3 أشهر)
  double getAmountForPeriod() {
    if (distributionType == ExpenseDistributionType.immediate) {
      return amountSyp;
    }

    // المصروف موزّع - نحسب عدد الأقساط الشهرية
    int monthlyPeriods;

    if (distributionCount != null) {
      monthlyPeriods = distributionCount!;
    } else if (distributionPeriod != null) {
      monthlyPeriods = distributionPeriod!.periodsPerYear;
    } else {
      // حسب تكرار المصروف الأصلي
      switch (frequency) {
        case RecurrenceFrequency.yearly:
          monthlyPeriods = 12; // مصروف سنوي يُقسم على 12 شهر
          break;
        case RecurrenceFrequency.quarterly:
          monthlyPeriods = 3; // مصروف ربعي يُقسم على 3 أشهر
          break;
        case RecurrenceFrequency.monthly:
        case RecurrenceFrequency.biweekly:
        case RecurrenceFrequency.weekly:
        case RecurrenceFrequency.daily:
          monthlyPeriods = 1;
          break;
      }
    }

    return amountSyp / monthlyPeriods;
  }

  /// المبلغ بالدولار لفترة معينة
  double? getAmountUsdForPeriod() {
    if (amountUsd == null) return null;

    if (distributionType == ExpenseDistributionType.immediate) {
      return amountUsd;
    }

    int monthlyPeriods;

    if (distributionCount != null) {
      monthlyPeriods = distributionCount!;
    } else if (distributionPeriod != null) {
      monthlyPeriods = distributionPeriod!.periodsPerYear;
    } else {
      switch (frequency) {
        case RecurrenceFrequency.yearly:
          monthlyPeriods = 12;
          break;
        case RecurrenceFrequency.quarterly:
          monthlyPeriods = 3;
          break;
        case RecurrenceFrequency.monthly:
        case RecurrenceFrequency.biweekly:
        case RecurrenceFrequency.weekly:
        case RecurrenceFrequency.daily:
          monthlyPeriods = 1;
          break;
      }
    }

    return amountUsd! / monthlyPeriods;
  }

  /// هل حان موعد الإنشاء؟
  /// للمصاريف الموزعة: يُنشأ قسط كل شهر بغض النظر عن التكرار الأصلي
  bool get isDue {
    if (!isActive) return false;

    // ═══════════════════════════════════════════════════════════════════════
    // المصاريف الموزعة: دائماً مستحقة (الـ Period Key يمنع التكرار)
    // ═══════════════════════════════════════════════════════════════════════
    if (distributionType == ExpenseDistributionType.distributed) {
      // التحقق من أن المصروف بدأ (لم يبدأ قبل تاريخ البداية)
      if (distributionStartDate != null &&
          DateTime.now().isBefore(distributionStartDate!)) {
        return false;
      }
      // التحقق من أن المصروف لم ينتهِ
      if (distributionEndDate != null &&
          DateTime.now().isAfter(distributionEndDate!)) {
        return false;
      }
      return true; // Period Key سيمنع التكرار في نفس الشهر
    }

    // ═══════════════════════════════════════════════════════════════════════
    // المصاريف الفورية: حسب nextDueDate
    // ═══════════════════════════════════════════════════════════════════════
    if (nextDueDate == null) return true;
    final now = DateTime.now();
    return now.isAfter(nextDueDate!) ||
        (now.year == nextDueDate!.year &&
            now.month == nextDueDate!.month &&
            now.day == nextDueDate!.day);
  }

  /// أيام متبقية للموعد القادم
  int get daysUntilDue {
    if (nextDueDate == null) return 0;
    return nextDueDate!.difference(DateTime.now()).inDays;
  }

  /// هل المصروف موزّع؟
  bool get isDistributed =>
      distributionType == ExpenseDistributionType.distributed;

  /// وصف التوزيع للعرض
  String get distributionDescription {
    if (!isDistributed) return 'فوري';
    final periods =
        distributionCount ?? distributionPeriod?.periodsPerYear ?? 1;
    final periodName = distributionPeriod?.arabicName ?? 'فترة';
    return 'موزّع على $periods $periodName';
  }

  /// نسخة مع تحديث
  RecurringExpenseTemplate copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? categoryName,
    double? amountSyp,
    double? amountUsd,
    double? exchangeRate,
    String? description,
    RecurrenceFrequency? frequency,
    DateTime? lastGeneratedDate,
    DateTime? nextDueDate,
    bool? isActive,
    DateTime? createdAt,
    ExpenseDistributionType? distributionType,
    DistributionPeriod? distributionPeriod,
    int? distributionCount,
    DateTime? distributionStartDate,
    DateTime? distributionEndDate,
  }) {
    return RecurringExpenseTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amountSyp: amountSyp ?? this.amountSyp,
      amountUsd: amountUsd ?? this.amountUsd,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      distributionType: distributionType ?? this.distributionType,
      distributionPeriod: distributionPeriod ?? this.distributionPeriod,
      distributionCount: distributionCount ?? this.distributionCount,
      distributionStartDate:
          distributionStartDate ?? this.distributionStartDate,
      distributionEndDate: distributionEndDate ?? this.distributionEndDate,
    );
  }

  /// حساب الموعد القادم
  DateTime calculateNextDueDate() {
    final now = DateTime.now();
    final lastDate = lastGeneratedDate ?? now;

    switch (frequency) {
      case RecurrenceFrequency.daily:
        return lastDate.add(const Duration(days: 1));
      case RecurrenceFrequency.weekly:
        return lastDate.add(const Duration(days: 7));
      case RecurrenceFrequency.biweekly:
        return lastDate.add(const Duration(days: 14));
      case RecurrenceFrequency.monthly:
        return DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
      case RecurrenceFrequency.quarterly:
        return DateTime(lastDate.year, lastDate.month + 3, lastDate.day);
      case RecurrenceFrequency.yearly:
        return DateTime(lastDate.year + 1, lastDate.month, lastDate.day);
    }
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amountSyp': amountSyp,
      'amountUsd': amountUsd,
      'exchangeRate': exchangeRate,
      'description': description,
      'frequency': frequency.name,
      'lastGeneratedDate': lastGeneratedDate?.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      // إعدادات التوزيع
      'distributionType': distributionType.name,
      'distributionPeriod': distributionPeriod?.name,
      'distributionCount': distributionCount,
      'distributionStartDate': distributionStartDate?.toIso8601String(),
      'distributionEndDate': distributionEndDate?.toIso8601String(),
    };
  }

  /// إنشاء من JSON
  factory RecurringExpenseTemplate.fromJson(Map<String, dynamic> json) {
    return RecurringExpenseTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      amountSyp: (json['amountSyp'] as num).toDouble(),
      amountUsd: json['amountUsd'] != null
          ? (json['amountUsd'] as num).toDouble()
          : null,
      exchangeRate: json['exchangeRate'] != null
          ? (json['exchangeRate'] as num).toDouble()
          : null,
      description: json['description'] as String?,
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => RecurrenceFrequency.monthly,
      ),
      lastGeneratedDate: json['lastGeneratedDate'] != null
          ? DateTime.parse(json['lastGeneratedDate'] as String)
          : null,
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      // إعدادات التوزيع
      distributionType: json['distributionType'] != null
          ? ExpenseDistributionType.values.firstWhere(
              (e) => e.name == json['distributionType'],
              orElse: () => ExpenseDistributionType.immediate,
            )
          : ExpenseDistributionType.immediate,
      distributionPeriod: json['distributionPeriod'] != null
          ? DistributionPeriod.values.firstWhere(
              (e) => e.name == json['distributionPeriod'],
              orElse: () => DistributionPeriod.monthly,
            )
          : null,
      distributionCount: json['distributionCount'] as int?,
      distributionStartDate: json['distributionStartDate'] != null
          ? DateTime.parse(json['distributionStartDate'] as String)
          : null,
      distributionEndDate: json['distributionEndDate'] != null
          ? DateTime.parse(json['distributionEndDate'] as String)
          : null,
    );
  }

  /// تحويل قائمة إلى JSON string
  static String listToJson(List<RecurringExpenseTemplate> templates) {
    return jsonEncode(templates.map((t) => t.toJson()).toList());
  }

  /// إنشاء قائمة من JSON string
  static List<RecurringExpenseTemplate> listFromJson(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) =>
            RecurringExpenseTemplate.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() {
    return 'RecurringExpenseTemplate(id: $id, name: $name, amount: $amountSyp, '
        'frequency: ${frequency.arabicName}, distribution: ${distributionType.arabicName})';
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// نموذج المصروف الموزّع الفرعي - Distributed Expense Installment
/// ═══════════════════════════════════════════════════════════════════════════
/// يمثل حصة فترة واحدة من مصروف موزّع
class DistributedExpenseInstallment {
  /// معرف القسط
  final String id;

  /// معرف المصروف الأب (القالب أو المصروف الرئيسي)
  final String parentExpenseId;

  /// اسم المصروف
  final String name;

  /// رقم الفترة (1, 2, 3, ...)
  final int periodNumber;

  /// إجمالي عدد الفترات
  final int totalPeriods;

  /// المبلغ لهذه الفترة بالليرة
  final double amountSyp;

  /// المبلغ لهذه الفترة بالدولار
  final double? amountUsd;

  /// تاريخ بداية الفترة
  final DateTime periodStartDate;

  /// تاريخ نهاية الفترة
  final DateTime periodEndDate;

  /// المبلغ الإجمالي للمصروف الأب
  final double totalAmountSyp;

  /// Period Key لمنع التكرار
  final String periodKey;

  /// هل تم تسجيل هذا القسط؟
  final bool isRecorded;

  /// تاريخ التسجيل (إن تم)
  final DateTime? recordedAt;

  /// معرف المصروف المسجل (إن تم)
  final String? recordedExpenseId;

  DistributedExpenseInstallment({
    required this.id,
    required this.parentExpenseId,
    required this.name,
    required this.periodNumber,
    required this.totalPeriods,
    required this.amountSyp,
    this.amountUsd,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.totalAmountSyp,
    required this.periodKey,
    this.isRecorded = false,
    this.recordedAt,
    this.recordedExpenseId,
  });

  /// وصف القسط للعرض
  String get description {
    return '$name (قسط $periodNumber من $totalPeriods)';
  }

  /// نسبة الاكتمال
  double get completionPercentage => (periodNumber / totalPeriods) * 100;

  /// المبلغ المتبقي
  double get remainingAmount => totalAmountSyp - (amountSyp * periodNumber);

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentExpenseId': parentExpenseId,
      'name': name,
      'periodNumber': periodNumber,
      'totalPeriods': totalPeriods,
      'amountSyp': amountSyp,
      'amountUsd': amountUsd,
      'periodStartDate': periodStartDate.toIso8601String(),
      'periodEndDate': periodEndDate.toIso8601String(),
      'totalAmountSyp': totalAmountSyp,
      'periodKey': periodKey,
      'isRecorded': isRecorded,
      'recordedAt': recordedAt?.toIso8601String(),
      'recordedExpenseId': recordedExpenseId,
    };
  }

  /// إنشاء من JSON
  factory DistributedExpenseInstallment.fromJson(Map<String, dynamic> json) {
    return DistributedExpenseInstallment(
      id: json['id'] as String,
      parentExpenseId: json['parentExpenseId'] as String,
      name: json['name'] as String,
      periodNumber: json['periodNumber'] as int,
      totalPeriods: json['totalPeriods'] as int,
      amountSyp: (json['amountSyp'] as num).toDouble(),
      amountUsd: json['amountUsd'] != null
          ? (json['amountUsd'] as num).toDouble()
          : null,
      periodStartDate: DateTime.parse(json['periodStartDate'] as String),
      periodEndDate: DateTime.parse(json['periodEndDate'] as String),
      totalAmountSyp: (json['totalAmountSyp'] as num).toDouble(),
      periodKey: json['periodKey'] as String,
      isRecorded: json['isRecorded'] as bool? ?? false,
      recordedAt: json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'] as String)
          : null,
      recordedExpenseId: json['recordedExpenseId'] as String?,
    );
  }

  /// نسخة مع تحديث
  DistributedExpenseInstallment copyWith({
    String? id,
    String? parentExpenseId,
    String? name,
    int? periodNumber,
    int? totalPeriods,
    double? amountSyp,
    double? amountUsd,
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    double? totalAmountSyp,
    String? periodKey,
    bool? isRecorded,
    DateTime? recordedAt,
    String? recordedExpenseId,
  }) {
    return DistributedExpenseInstallment(
      id: id ?? this.id,
      parentExpenseId: parentExpenseId ?? this.parentExpenseId,
      name: name ?? this.name,
      periodNumber: periodNumber ?? this.periodNumber,
      totalPeriods: totalPeriods ?? this.totalPeriods,
      amountSyp: amountSyp ?? this.amountSyp,
      amountUsd: amountUsd ?? this.amountUsd,
      periodStartDate: periodStartDate ?? this.periodStartDate,
      periodEndDate: periodEndDate ?? this.periodEndDate,
      totalAmountSyp: totalAmountSyp ?? this.totalAmountSyp,
      periodKey: periodKey ?? this.periodKey,
      isRecorded: isRecorded ?? this.isRecorded,
      recordedAt: recordedAt ?? this.recordedAt,
      recordedExpenseId: recordedExpenseId ?? this.recordedExpenseId,
    );
  }
}

/// قوالب المصاريف الدورية الشائعة
class CommonRecurringExpenses {
  static final List<Map<String, dynamic>> templates = [
    {
      'name': 'إيجار المحل',
      'frequency': RecurrenceFrequency.monthly,
      'icon': '🏠',
    },
    {
      'name': 'فاتورة الكهرباء',
      'frequency': RecurrenceFrequency.monthly,
      'icon': '💡',
    },
    {
      'name': 'فاتورة الماء',
      'frequency': RecurrenceFrequency.monthly,
      'icon': '💧',
    },
    {
      'name': 'فاتورة الإنترنت',
      'frequency': RecurrenceFrequency.monthly,
      'icon': '🌐',
    },
    {
      'name': 'رواتب الموظفين',
      'frequency': RecurrenceFrequency.monthly,
      'icon': '👥',
    },
    {
      'name': 'اشتراك البرامج',
      'frequency': RecurrenceFrequency.monthly,
      'icon': '💻',
    },
    {
      'name': 'صيانة دورية',
      'frequency': RecurrenceFrequency.quarterly,
      'icon': '🔧',
    },
    {
      'name': 'تأمين المحل',
      'frequency': RecurrenceFrequency.yearly,
      'icon': '🛡️',
    },
    {
      'name': 'رسوم الترخيص',
      'frequency': RecurrenceFrequency.yearly,
      'icon': '📋',
    },
    {
      'name': 'مصاريف النظافة',
      'frequency': RecurrenceFrequency.weekly,
      'icon': '🧹',
    },
  ];
}
