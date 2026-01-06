// ═══════════════════════════════════════════════════════════════════════════
// Expense Model - نموذج المصروف
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════
//
// ⚠️ السياسة المحاسبية الصارمة - STRICT ACCOUNTING POLICY ⚠️
//
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ 1. المصاريف ليست مشتريات - لا تؤثر على المخزون                               │
// │ 2. المصاريف تؤثر على الأرباح والخسائر مباشرة                                  │
// │ 3. السعر يُثبّت وقت التسجيل ولا يتغير لاحقاً                                 │
// │ 4. تغيير سعر الصرف لاحقًا لا يؤثر على المصاريف القديمة                        │
// └─────────────────────────────────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

import '../../../core/services/price_locking_service.dart';

/// تصنيفات المصاريف الافتراضية
class ExpenseCategoryDefaults {
  static const List<Map<String, String>> defaultCategories = [
    {'id': 'rent', 'name': 'إيجار', 'icon': 'home'},
    {
      'id': 'utilities',
      'name': 'فواتير (كهرباء، ماء، غاز)',
      'icon': 'flash_on'
    },
    {'id': 'salaries', 'name': 'رواتب', 'icon': 'people'},
    {'id': 'transport', 'name': 'نقل ومواصلات', 'icon': 'directions_car'},
    {'id': 'maintenance', 'name': 'صيانة', 'icon': 'build'},
    {'id': 'office_supplies', 'name': 'قرطاسية ومستلزمات', 'icon': 'edit'},
    {'id': 'marketing', 'name': 'تسويق وإعلان', 'icon': 'campaign'},
    {'id': 'communication', 'name': 'اتصالات وإنترنت', 'icon': 'phone'},
    {'id': 'taxes', 'name': 'ضرائب ورسوم', 'icon': 'receipt'},
    {'id': 'insurance', 'name': 'تأمين', 'icon': 'security'},
    {'id': 'cleaning', 'name': 'نظافة', 'icon': 'cleaning_services'},
    {'id': 'food', 'name': 'طعام وضيافة', 'icon': 'restaurant'},
    {'id': 'travel', 'name': 'سفر', 'icon': 'flight'},
    {'id': 'training', 'name': 'تدريب', 'icon': 'school'},
    {'id': 'bank_fees', 'name': 'عمولات بنكية', 'icon': 'account_balance'},
    {'id': 'other', 'name': 'أخرى', 'icon': 'more_horiz'},
  ];
}

/// نموذج المصروف للعرض والتعامل
/// ═══════════════════════════════════════════════════════════════════════════
/// هذا النموذج يستخدم لعرض بيانات المصروف بطريقة أسهل
/// مع ضمان تثبيت الأسعار
/// ═══════════════════════════════════════════════════════════════════════════
class ExpenseModel {
  final String id;
  final String expenseNumber;
  final String categoryId;
  final String? categoryName;

  // ═══════════════════════════════════════════════════════════════════════════
  // المبالغ المثبتة (لا تتغير بعد الحفظ)
  // ═══════════════════════════════════════════════════════════════════════════
  final double amountSyp; // المبلغ بالليرة السورية
  final double amountUsd; // المبلغ بالدولار
  final double exchangeRate; // سعر الصرف وقت التسجيل

  final String paymentMethod; // طريقة الدفع (cash فقط للصندوق)
  final String? description;
  final String? shiftId;
  final DateTime expenseDate;
  final DateTime createdAt;
  final String syncStatus;

  /// العملة الأساسية المستخدمة عند الإدخال
  final bool enteredInUsd;

  ExpenseModel({
    required this.id,
    required this.expenseNumber,
    required this.categoryId,
    this.categoryName,
    required this.amountSyp,
    required this.amountUsd,
    required this.exchangeRate,
    this.paymentMethod = 'cash',
    this.description,
    this.shiftId,
    required this.expenseDate,
    required this.createdAt,
    this.syncStatus = 'pending',
    this.enteredInUsd = false,
  });

  /// إنشاء سعر مثبت من بيانات المصروف
  /// ⚠️ يستخدم القيم المحفوظة فقط - لا يُعيد الحساب
  LockedPrice get lockedPrice => LockedPrice(
        syp: amountSyp,
        usd: amountUsd,
        exchangeRate: exchangeRate,
        lockedAt: createdAt,
        isHistorical: true,
      );

  /// نسخة معدلة من المصروف
  ExpenseModel copyWith({
    String? id,
    String? expenseNumber,
    String? categoryId,
    String? categoryName,
    double? amountSyp,
    double? amountUsd,
    double? exchangeRate,
    String? paymentMethod,
    String? description,
    String? shiftId,
    DateTime? expenseDate,
    DateTime? createdAt,
    String? syncStatus,
    bool? enteredInUsd,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      expenseNumber: expenseNumber ?? this.expenseNumber,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amountSyp: amountSyp ?? this.amountSyp,
      amountUsd: amountUsd ?? this.amountUsd,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      shiftId: shiftId ?? this.shiftId,
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      enteredInUsd: enteredInUsd ?? this.enteredInUsd,
    );
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, number: $expenseNumber, category: $categoryId, '
        'amountSyp: $amountSyp, amountUsd: $amountUsd, rate: $exchangeRate)';
  }
}

/// نموذج تصنيف المصروف
class ExpenseCategoryModel {
  final String id;
  final String name;
  final String? icon;
  final bool isActive;
  final bool isDefault; // تصنيف افتراضي من النظام
  final DateTime createdAt;
  final String syncStatus;

  ExpenseCategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.isActive = true,
    this.isDefault = false,
    required this.createdAt,
    this.syncStatus = 'pending',
  });

  ExpenseCategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return ExpenseCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

/// DTO لإنشاء مصروف جديد
class CreateExpenseDto {
  final double amount;
  final bool isUsd; // هل المبلغ بالدولار؟
  final String categoryId;
  final String? description;
  final DateTime? expenseDate;

  CreateExpenseDto({
    required this.amount,
    this.isUsd = false,
    required this.categoryId,
    this.description,
    this.expenseDate,
  });
}

/// DTO لتحديث مصروف
class UpdateExpenseDto {
  final String id;
  final double? amount;
  final bool? isUsd;
  final String? categoryId;
  final String? description;
  final DateTime? expenseDate;

  UpdateExpenseDto({
    required this.id,
    this.amount,
    this.isUsd,
    this.categoryId,
    this.description,
    this.expenseDate,
  });
}
