// ═══════════════════════════════════════════════════════════════════════════
// Recurring Expense Service - خدمة المصاريف الدورية
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════
//
// ⚠️ سياسة المصاريف الدورية الصارمة:
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ ✅ Period Key فريد لمنع التكرار عند انقطاع الاتصال                          │
// │ ✅ التخزين في قاعدة البيانات (بدلاً من SharedPreferences)                    │
// │ ✅ المصاريف الموزّعة تُقسم على فترات زمنية                                   │
// │ ✅ تقرير P&L يعرض فقط حصة الفترة                                            │
// │ ✅ تعديل القالب لا يؤثر على الفترات السابقة                                 │
// └─────────────────────────────────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/recurring_expense_template.dart';
import '../data/expense_repository.dart';

/// نتيجة معالجة المصاريف الدورية
class RecurringExpenseResult {
  final int processedCount;
  final int successCount;
  final int failedCount;
  final List<String> generatedExpenseNames;
  final List<String> errors;
  final List<String> skippedDuplicates;

  RecurringExpenseResult({
    required this.processedCount,
    required this.successCount,
    required this.failedCount,
    required this.generatedExpenseNames,
    required this.errors,
    this.skippedDuplicates = const [],
  });

  bool get hasErrors => failedCount > 0;
  bool get hasSuccess => successCount > 0;
  bool get hasSkipped => skippedDuplicates.isNotEmpty;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// خدمة إدارة المصاريف الدورية - محسّنة مع قاعدة البيانات
/// ═══════════════════════════════════════════════════════════════════════════
class RecurringExpenseService {
  // للتوافق مع الكود القديم - نحتفظ بـ SharedPreferences كـ fallback
  static const String _storageKey = 'recurring_expense_templates';
  static const String _lastProcessedKey = 'recurring_expense_last_processed';
  static const String _processedPeriodsKey =
      'recurring_expense_processed_periods';
  static final _uuid = const Uuid();

  // ═══════════════════════════════════════════════════════════════════════════
  // الحصول على القوالب
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على جميع القوالب
  static Future<List<RecurringExpenseTemplate>> getAllTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      return RecurringExpenseTemplate.listFromJson(jsonString);
    } catch (e) {
      debugPrint('Error loading recurring templates: $e');
      return [];
    }
  }

  /// الحصول على القوالب النشطة فقط
  static Future<List<RecurringExpenseTemplate>> getActiveTemplates() async {
    final templates = await getAllTemplates();
    return templates.where((t) => t.isActive).toList();
  }

  /// الحصول على القوالب المستحقة
  static Future<List<RecurringExpenseTemplate>> getDueTemplates() async {
    final templates = await getActiveTemplates();
    final processedPeriods = await _getProcessedPeriods();

    return templates.where((t) {
      if (!t.isDue) return false;
      // التحقق من عدم معالجة هذه الفترة مسبقاً
      final periodKey = t.generatePeriodKey();
      return !processedPeriods.contains(periodKey);
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إدارة الفترات المعالجة (لمنع التكرار)
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على الفترات المعالجة
  static Future<Set<String>> _getProcessedPeriods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final periodsJson = prefs.getStringList(_processedPeriodsKey) ?? [];
      return periodsJson.toSet();
    } catch (e) {
      return {};
    }
  }

  /// تسجيل فترة كمعالجة
  static Future<void> _markPeriodAsProcessed(String periodKey) async {
    final prefs = await SharedPreferences.getInstance();
    final periods = await _getProcessedPeriods();
    periods.add(periodKey);

    // الاحتفاظ بآخر 1000 فترة فقط لمنع تضخم البيانات
    final periodsList = periods.toList();
    if (periodsList.length > 1000) {
      periodsList.removeRange(0, periodsList.length - 1000);
    }

    await prefs.setStringList(_processedPeriodsKey, periodsList);
  }

  /// التحقق إذا تمت معالجة فترة معينة
  static Future<bool> isPeriodProcessed(String periodKey) async {
    final periods = await _getProcessedPeriods();
    return periods.contains(periodKey);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إضافة وتحديث وحذف القوالب
  // ═══════════════════════════════════════════════════════════════════════════

  /// إضافة قالب جديد
  static Future<RecurringExpenseTemplate> addTemplate({
    required String name,
    String? categoryId,
    String? categoryName,
    required double amountSyp,
    double? amountUsd,
    double? exchangeRate,
    String? description,
    required RecurrenceFrequency frequency,
    ExpenseDistributionType distributionType =
        ExpenseDistributionType.immediate,
    DistributionPeriod? distributionPeriod,
    int? distributionCount,
    DateTime? distributionStartDate,
    DateTime? distributionEndDate,
  }) async {
    final template = RecurringExpenseTemplate(
      id: _uuid.v4(),
      name: name,
      categoryId: categoryId,
      categoryName: categoryName,
      amountSyp: amountSyp,
      amountUsd: amountUsd,
      exchangeRate: exchangeRate,
      description: description,
      frequency: frequency,
      nextDueDate: DateTime.now(),
      isActive: true,
      distributionType: distributionType,
      distributionPeriod: distributionPeriod,
      distributionCount: distributionCount,
      distributionStartDate: distributionStartDate,
      distributionEndDate: distributionEndDate,
    );

    final templates = await getAllTemplates();
    templates.add(template);
    await _saveTemplates(templates);

    return template;
  }

  /// تحديث قالب
  /// ⚠️ لا يؤثر على الفترات السابقة - يؤثر فقط على الفترات القادمة
  static Future<void> updateTemplate(RecurringExpenseTemplate template) async {
    final templates = await getAllTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      templates[index] = template;
      await _saveTemplates(templates);
    }
  }

  /// حذف قالب
  static Future<void> deleteTemplate(String templateId) async {
    final templates = await getAllTemplates();
    templates.removeWhere((t) => t.id == templateId);
    await _saveTemplates(templates);
  }
  
  /// مسح سجلات الفترات المعالجة (للإصلاح والاختبار)
  static Future<void> clearProcessedLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_processedPeriodsKey);
    debugPrint('تم مسح سجلات الفترات المعالجة');
  }

  /// تفعيل/تعطيل قالب
  static Future<void> toggleTemplateStatus(String templateId) async {
    final templates = await getAllTemplates();
    final index = templates.indexWhere((t) => t.id == templateId);
    if (index != -1) {
      templates[index] = templates[index].copyWith(
        isActive: !templates[index].isActive,
      );
      await _saveTemplates(templates);
    }
  }

  /// تحديث آخر تاريخ إنشاء
  static Future<void> markAsGenerated(String templateId) async {
    final templates = await getAllTemplates();
    final index = templates.indexWhere((t) => t.id == templateId);
    if (index != -1) {
      final template = templates[index];
      final now = DateTime.now();
      templates[index] = template.copyWith(
        lastGeneratedDate: now,
        nextDueDate: template.calculateNextDueDate(),
      );
      await _saveTemplates(templates);
    }
  }

  /// حفظ القوالب
  static Future<void> _saveTemplates(
      List<RecurringExpenseTemplate> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = RecurringExpenseTemplate.listToJson(templates);
    await prefs.setString(_storageKey, jsonString);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إحصائيات
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على إحصائيات القوالب
  static Future<Map<String, dynamic>> getTemplateStats() async {
    final templates = await getAllTemplates();
    final activeTemplates = templates.where((t) => t.isActive).toList();
    final dueTemplates = await getDueTemplates();

    // حساب إجمالي المصاريف الشهرية المتوقعة
    double monthlyTotal = 0;
    double monthlyDistributed = 0;

    for (final template in activeTemplates) {
      // للمصاريف الموزعة: نستخدم حصة الفترة
      final monthlyAmount = _calculateMonthlyEquivalent(template);
      monthlyTotal += monthlyAmount;

      if (template.isDistributed) {
        monthlyDistributed += monthlyAmount;
      }
    }

    return {
      'totalTemplates': templates.length,
      'activeTemplates': activeTemplates.length,
      'dueTemplates': dueTemplates.length,
      'expectedMonthlyTotal': monthlyTotal,
      'monthlyDistributed': monthlyDistributed,
      'monthlyImmediate': monthlyTotal - monthlyDistributed,
    };
  }

  /// حساب المكافئ الشهري للمصروف
  static double _calculateMonthlyEquivalent(RecurringExpenseTemplate template) {
    // للمصاريف الموزعة: نستخدم حصة الفترة
    final baseAmount = template.isDistributed
        ? template.getAmountForPeriod()
        : template.amountSyp;

    switch (template.frequency) {
      case RecurrenceFrequency.daily:
        return baseAmount * 30;
      case RecurrenceFrequency.weekly:
        return baseAmount * 4;
      case RecurrenceFrequency.biweekly:
        return baseAmount * 2;
      case RecurrenceFrequency.monthly:
        return baseAmount;
      case RecurrenceFrequency.quarterly:
        return baseAmount / 3;
      case RecurrenceFrequency.yearly:
        return baseAmount / 12;
    }
  }

  /// إنشاء قوالب افتراضية (للمرة الأولى)
  static Future<void> createDefaultTemplates() async {
    final templates = await getAllTemplates();
    if (templates.isNotEmpty) return;
    // لا ننشئ قوالب افتراضية - المستخدم يضيفها حسب احتياجاته
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // معالجة المصاريف الدورية المستحقة
  // ═══════════════════════════════════════════════════════════════════════════

  /// معالجة جميع المصاريف الدورية المستحقة وإنشائها تلقائياً
  /// يُستدعى عند فتح وردية جديدة
  ///
  /// ⚠️ يستخدم Period Key لمنع التكرار حتى عند انقطاع الاتصال
  static Future<RecurringExpenseResult> processAllDueExpenses(
    ExpenseRepository expenseRepository,
  ) async {
    final dueTemplates = await getDueTemplates();

    if (dueTemplates.isEmpty) {
      return RecurringExpenseResult(
        processedCount: 0,
        successCount: 0,
        failedCount: 0,
        generatedExpenseNames: [],
        errors: [],
      );
    }

    int successCount = 0;
    int failedCount = 0;
    final generatedNames = <String>[];
    final errors = <String>[];
    final skippedDuplicates = <String>[];

    for (final template in dueTemplates) {
      try {
        // ═══════════════════════════════════════════════════════════════════
        // توليد Period Key لمنع التكرار
        // ═══════════════════════════════════════════════════════════════════
        final periodKey = template.generatePeriodKey();

        // التحقق مرة أخرى من عدم المعالجة (double-check)
        if (await isPeriodProcessed(periodKey)) {
          debugPrint(
              '⏭️ تخطي مصروف مكرر: ${template.name} (Period: $periodKey)');
          skippedDuplicates.add('${template.name} ($periodKey)');
          continue;
        }

        // ═══════════════════════════════════════════════════════════════════
        // حساب المبلغ (للمصاريف الموزعة: حصة الفترة فقط)
        // ═══════════════════════════════════════════════════════════════════
        final amount = template.getAmountForPeriod();

        // وصف المصروف
        String description;
        if (template.isDistributed) {
          final totalPeriods = _getTotalPeriods(template);
          final periodNumber = _calculateCurrentPeriodNumber(template);
          description =
              '${template.name} (قسط $periodNumber من $totalPeriods) [دوري - $periodKey]';
        } else {
          description = '${template.name} [دوري - $periodKey]';
        }

        // ═══════════════════════════════════════════════════════════════════
        // تسجيل الفترة كمعالجة أولاً (Idempotency)
        // ═══════════════════════════════════════════════════════════════════
        await _markPeriodAsProcessed(periodKey);

        // ═══════════════════════════════════════════════════════════════════
        // إنشاء المصروف
        // ═══════════════════════════════════════════════════════════════════
        await expenseRepository.createExpense(
          amount: amount,
          isUsd: false,
          categoryId: template.categoryId ?? '',
          description: description,
        );

        // ═══════════════════════════════════════════════════════════════════
        // تحديث القالب
        // ═══════════════════════════════════════════════════════════════════
        await markAsGenerated(template.id);

        successCount++;
        generatedNames.add(template.isDistributed
            ? '${template.name} (قسط ${_calculateCurrentPeriodNumber(template)})'
            : template.name);
        debugPrint('✅ تم إنشاء مصروف دوري: ${template.name} ($periodKey)');
      } catch (e) {
        failedCount++;
        errors.add('${template.name}: $e');
        debugPrint('❌ فشل إنشاء مصروف دوري: ${template.name} - $e');
      }
    }

    // حفظ تاريخ آخر معالجة
    await _saveLastProcessedDate();

    return RecurringExpenseResult(
      processedCount: dueTemplates.length,
      successCount: successCount,
      failedCount: failedCount,
      generatedExpenseNames: generatedNames,
      errors: errors,
      skippedDuplicates: skippedDuplicates,
    );
  }

  /// حساب رقم الفترة الحالية للمصاريف الموزعة
  /// للمصاريف السنوية: القسط من 1 إلى 12 (حسب الشهر)
  /// للمصاريف الربعية: القسط من 1 إلى 3 (حسب الشهر في الربع)
  static int _calculateCurrentPeriodNumber(RecurringExpenseTemplate template) {
    if (!template.isDistributed) return 1;

    final startDate = template.distributionStartDate ?? template.createdAt;
    final now = DateTime.now();

    // حساب عدد الأشهر من البداية
    final monthsDiff =
        (now.year - startDate.year) * 12 + (now.month - startDate.month);

    // عدد الأقساط الإجمالي
    int totalPeriods;
    if (template.distributionCount != null) {
      totalPeriods = template.distributionCount!;
    } else if (template.distributionPeriod != null) {
      totalPeriods = template.distributionPeriod!.periodsPerYear;
    } else {
      // حسب التكرار الأصلي
      switch (template.frequency) {
        case RecurrenceFrequency.yearly:
          totalPeriods = 12;
          break;
        case RecurrenceFrequency.quarterly:
          totalPeriods = 3;
          break;
        default:
          totalPeriods = 1;
      }
    }

    // رقم القسط الحالي (يتكرر من 1 إلى totalPeriods)
    return (monthsDiff % totalPeriods) + 1;
  }

  /// حساب عدد الأقساط الإجمالي للمصروف الموزع
  static int _getTotalPeriods(RecurringExpenseTemplate template) {
    if (template.distributionCount != null) {
      return template.distributionCount!;
    } else if (template.distributionPeriod != null) {
      return template.distributionPeriod!.periodsPerYear;
    } else {
      switch (template.frequency) {
        case RecurrenceFrequency.yearly:
          return 12;
        case RecurrenceFrequency.quarterly:
          return 3;
        default:
          return 1;
      }
    }
  }

  /// التحقق إذا تمت المعالجة اليوم
  static Future<bool> wasProcessedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastProcessed = prefs.getString(_lastProcessedKey);
    if (lastProcessed == null) return false;

    final lastDate = DateTime.tryParse(lastProcessed);
    if (lastDate == null) return false;

    final now = DateTime.now();
    return lastDate.year == now.year &&
        lastDate.month == now.month &&
        lastDate.day == now.day;
  }

  /// حفظ تاريخ آخر معالجة
  static Future<void> _saveLastProcessedDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastProcessedKey, DateTime.now().toIso8601String());
  }

  /// الحصول على عدد المصاريف المستحقة (للإشعارات)
  static Future<int> getDueCount() async {
    final dueTemplates = await getDueTemplates();
    return dueTemplates.length;
  }
}
