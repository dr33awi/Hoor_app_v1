// ═══════════════════════════════════════════════════════════════════════════
// Recurring Expense Service - خدمة المصاريف الدورية
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/recurring_expense_template.dart';

/// خدمة إدارة قوالب المصاريف الدورية
class RecurringExpenseService {
  static const String _storageKey = 'recurring_expense_templates';
  static final _uuid = const Uuid();

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
      print('Error loading recurring templates: $e');
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
    return templates.where((t) => t.isDue).toList();
  }

  /// إضافة قالب جديد
  static Future<RecurringExpenseTemplate> addTemplate({
    required String name,
    String? categoryId,
    String? categoryName,
    required double amountSyp,
    double? amountUsd,
    String? description,
    required RecurrenceFrequency frequency,
  }) async {
    final template = RecurringExpenseTemplate(
      id: _uuid.v4(),
      name: name,
      categoryId: categoryId,
      categoryName: categoryName,
      amountSyp: amountSyp,
      amountUsd: amountUsd,
      description: description,
      frequency: frequency,
      nextDueDate: DateTime.now(),
      isActive: true,
    );

    final templates = await getAllTemplates();
    templates.add(template);
    await _saveTemplates(templates);

    return template;
  }

  /// تحديث قالب
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

  /// الحصول على إحصائيات القوالب
  static Future<Map<String, dynamic>> getTemplateStats() async {
    final templates = await getAllTemplates();
    final activeTemplates = templates.where((t) => t.isActive).toList();
    final dueTemplates = activeTemplates.where((t) => t.isDue).toList();

    // حساب إجمالي المصاريف الشهرية المتوقعة
    double monthlyTotal = 0;
    for (final template in activeTemplates) {
      switch (template.frequency) {
        case RecurrenceFrequency.daily:
          monthlyTotal += template.amountSyp * 30;
          break;
        case RecurrenceFrequency.weekly:
          monthlyTotal += template.amountSyp * 4;
          break;
        case RecurrenceFrequency.biweekly:
          monthlyTotal += template.amountSyp * 2;
          break;
        case RecurrenceFrequency.monthly:
          monthlyTotal += template.amountSyp;
          break;
        case RecurrenceFrequency.quarterly:
          monthlyTotal += template.amountSyp / 3;
          break;
        case RecurrenceFrequency.yearly:
          monthlyTotal += template.amountSyp / 12;
          break;
      }
    }

    return {
      'totalTemplates': templates.length,
      'activeTemplates': activeTemplates.length,
      'dueTemplates': dueTemplates.length,
      'expectedMonthlyTotal': monthlyTotal,
    };
  }

  /// إنشاء قوالب افتراضية (للمرة الأولى)
  static Future<void> createDefaultTemplates() async {
    final templates = await getAllTemplates();
    if (templates.isNotEmpty) return;

    // لا ننشئ قوالب افتراضية - المستخدم يضيفها حسب احتياجاته
  }
}
