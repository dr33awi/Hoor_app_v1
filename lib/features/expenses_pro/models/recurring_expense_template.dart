// ═══════════════════════════════════════════════════════════════════════════
// Recurring Expense Template - قوالب المصاريف الدورية
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════
//
// هذا الملف يحتوي على قوالب المصاريف المتكررة التي يمكن إنشاءها بسرعة
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';

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
}

/// قالب المصروف الدوري
class RecurringExpenseTemplate {
  final String id;
  final String name;
  final String? categoryId;
  final String? categoryName;
  final double amountSyp;
  final double? amountUsd;
  final String? description;
  final RecurrenceFrequency frequency;
  final DateTime? lastGeneratedDate;
  final DateTime? nextDueDate;
  final bool isActive;
  final DateTime createdAt;

  RecurringExpenseTemplate({
    required this.id,
    required this.name,
    this.categoryId,
    this.categoryName,
    required this.amountSyp,
    this.amountUsd,
    this.description,
    required this.frequency,
    this.lastGeneratedDate,
    this.nextDueDate,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// هل حان موعد الإنشاء؟
  bool get isDue {
    if (nextDueDate == null) return true;
    return DateTime.now().isAfter(nextDueDate!) ||
        DateTime.now().day == nextDueDate!.day;
  }

  /// أيام متبقية للموعد القادم
  int get daysUntilDue {
    if (nextDueDate == null) return 0;
    return nextDueDate!.difference(DateTime.now()).inDays;
  }

  /// نسخة مع تحديث
  RecurringExpenseTemplate copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? categoryName,
    double? amountSyp,
    double? amountUsd,
    String? description,
    RecurrenceFrequency? frequency,
    DateTime? lastGeneratedDate,
    DateTime? nextDueDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringExpenseTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amountSyp: amountSyp ?? this.amountSyp,
      amountUsd: amountUsd ?? this.amountUsd,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
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
      'description': description,
      'frequency': frequency.name,
      'lastGeneratedDate': lastGeneratedDate?.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
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
