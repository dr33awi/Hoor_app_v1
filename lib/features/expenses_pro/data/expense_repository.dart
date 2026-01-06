// ═══════════════════════════════════════════════════════════════════════════
// Expense Repository - مستودع المصاريف
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════
//
// ⚠️ التأثير المحاسبي للمصاريف:
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ ✅ يتم خصم المبلغ من الصندوق                                                │
// │ ✅ يتم تحديث إجماليات الوردية                                                │
// │ ✅ يتم تثبيت سعر الصرف وقت التسجيل                                          │
// │ ❌ لا يتم تعديل المخزون                                                      │
// │ ❌ لا يتم إنشاء فاتورة شراء                                                  │
// │ ❌ لا يتم إعادة حساب القيم بسعر صرف جديد                                    │
// └─────────────────────────────────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/services/price_locking_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/cash_repository.dart';
import '../../../data/repositories/shift_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Expense Repository
/// ═══════════════════════════════════════════════════════════════════════════
/// مسؤول عن:
/// - إنشاء وتحديث وحذف المصاريف
/// - التكامل مع الصندوق والورديات
/// - تثبيت الأسعار
/// - المزامنة مع Firestore
/// ═══════════════════════════════════════════════════════════════════════════
class ExpenseRepository {
  final AppDatabase database;
  final FirebaseFirestore firestore;
  final CurrencyService currencyService;
  final PriceLockingService priceLockingService;

  final _uuid = const Uuid();
  StreamSubscription? _expenseFirestoreSubscription;
  StreamSubscription? _categoryFirestoreSubscription;

  // Lazy loaded repositories
  CashRepository? _cashRepo;
  ShiftRepository? _shiftRepo;

  ExpenseRepository({
    required this.database,
    required this.firestore,
    required this.currencyService,
    required this.priceLockingService,
  });

  /// تعيين الـ Repositories للتكامل
  void setIntegrationRepositories({
    CashRepository? cashRepo,
    ShiftRepository? shiftRepo,
  }) {
    _cashRepo = cashRepo;
    _shiftRepo = shiftRepo;
  }

  // Lazy getters للـ Repositories
  CashRepository get cashRepo => _cashRepo ?? getIt<CashRepository>();
  ShiftRepository get shiftRepo => _shiftRepo ?? getIt<ShiftRepository>();

  /// Collection للمصاريف
  CollectionReference get expenseCollection => firestore.collection('expenses');

  /// Collection للتصنيفات
  CollectionReference get categoryCollection =>
      firestore.collection('expense_categories');

  // ═══════════════════════════════════════════════════════════════════════════
  // تصنيفات المصاريف
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على جميع تصنيفات المصاريف
  Future<List<VoucherCategory>> getAllCategories() async {
    return database.getVoucherCategoriesByType('expense');
  }

  /// مراقبة تصنيفات المصاريف
  Stream<List<VoucherCategory>> watchCategories() {
    // استخدام watchAllVoucherCategories مع فلترة
    return database.watchAllVoucherCategories().map(
          (categories) => categories.where((c) => c.type == 'expense').toList(),
        );
  }

  /// الحصول على تصنيف بالمعرف
  Future<VoucherCategory?> getCategoryById(String id) {
    return database.getVoucherCategoryById(id);
  }

  /// إنشاء تصنيف جديد
  Future<String> createCategory({
    required String name,
    bool isActive = true,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await database.insertVoucherCategory(VoucherCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: const Value('expense'),
      isActive: Value(isActive),
      syncStatus: const Value('pending'),
      createdAt: Value(now),
    ));

    _syncCategoryToFirestore(id);
    return id;
  }

  /// تحديث تصنيف
  Future<void> updateCategory({
    required String id,
    String? name,
    bool? isActive,
  }) async {
    final category = await getCategoryById(id);
    if (category == null) return;

    await database.updateVoucherCategory(VoucherCategoriesCompanion(
      id: Value(id),
      name: Value(name ?? category.name),
      type: const Value('expense'),
      isActive: Value(isActive ?? category.isActive),
      syncStatus: const Value('pending'),
      createdAt: Value(category.createdAt),
    ));

    _syncCategoryToFirestore(id);
  }

  /// حذف تصنيف
  Future<void> deleteCategory(String id) async {
    await database.deleteVoucherCategory(id);
    try {
      await categoryCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting category from Firestore: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // المصاريف - CRUD Operations
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على جميع المصاريف (نستخدم جدول السندات مع نوع expense)
  Future<List<Voucher>> getAllExpenses() async {
    return database.getVouchersByType('expense');
  }

  /// مراقبة جميع المصاريف
  Stream<List<Voucher>> watchAllExpenses() {
    return database.watchVouchersByType('expense');
  }

  /// الحصول على المصاريف حسب نطاق التاريخ
  Future<List<Voucher>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    final allExpenses = await getAllExpenses();
    return allExpenses.where((e) {
      return e.voucherDate.isAfter(start.subtract(const Duration(days: 1))) &&
          e.voucherDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// مراقبة المصاريف حسب نطاق التاريخ
  Stream<List<Voucher>> watchExpensesByDateRange(DateTime start, DateTime end) {
    return watchAllExpenses().map((expenses) {
      return expenses.where((e) {
        return e.voucherDate.isAfter(start.subtract(const Duration(days: 1))) &&
            e.voucherDate.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    });
  }

  /// الحصول على المصاريف حسب التصنيف
  Future<List<Voucher>> getExpensesByCategory(String categoryId) async {
    final allExpenses = await getAllExpenses();
    return allExpenses.where((e) => e.categoryId == categoryId).toList();
  }

  /// الحصول على المصاريف حسب الوردية
  Future<List<Voucher>> getExpensesByShift(String shiftId) async {
    final allExpenses = await getAllExpenses();
    return allExpenses.where((e) => e.shiftId == shiftId).toList();
  }

  /// الحصول على مصروف بالمعرف
  Future<Voucher?> getExpenseById(String id) {
    return database.getVoucherById(id);
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// إنشاء مصروف جديد
  /// ═══════════════════════════════════════════════════════════════════════════
  ///
  /// التأثير المحاسبي:
  /// 1. ✅ تثبيت سعر الصرف الحالي
  /// 2. ✅ حفظ المبلغ بالليرة والدولار
  /// 3. ✅ خصم المبلغ من الصندوق (إذا كانت طريقة الدفع cash)
  /// 4. ✅ تحديث إجماليات الوردية
  /// 5. ❌ لا يتم تعديل المخزون
  ///
  /// @param amount المبلغ (بالعملة المحددة)
  /// @param isUsd هل المبلغ بالدولار؟
  /// @param categoryId معرف التصنيف
  /// @param description الوصف
  /// @param expenseDate تاريخ المصروف (افتراضياً الآن)
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<String> createExpense({
    required double amount,
    bool isUsd = false,
    required String categoryId,
    String? description,
    DateTime? expenseDate,
  }) async {
    // 1. التحقق من وجود وردية مفتوحة
    final openShift = await shiftRepo.getOpenShift();
    if (openShift == null) {
      throw Exception('لا توجد وردية مفتوحة. يجب فتح وردية أولاً.');
    }

    // 2. تثبيت السعر باستخدام PriceLockingService
    final lockedPrice = priceLockingService.lockPrice(amount, isUsd: isUsd);

    // 3. إنشاء المصروف
    final id = _uuid.v4();
    final expenseNumber = await _generateExpenseNumber();
    final now = DateTime.now();

    await database.insertVoucher(VouchersCompanion(
      id: Value(id),
      voucherNumber: Value(expenseNumber),
      type: const Value('expense'),
      categoryId: Value(categoryId),
      amount: Value(lockedPrice.syp),
      amountUsd: Value(lockedPrice.usd),
      exchangeRate: Value(lockedPrice.exchangeRate),
      description: Value(description),
      shiftId: Value(openShift.id),
      syncStatus: const Value('pending'),
      voucherDate: Value(expenseDate ?? now),
      createdAt: Value(now),
    ));

    // 4. خصم من الصندوق وتحديث الوردية
    await _recordCashMovement(
      shiftId: openShift.id,
      amount: lockedPrice.syp,
      amountUsd: lockedPrice.usd,
      exchangeRate: lockedPrice.exchangeRate,
      description: description ?? 'مصروف',
      expenseId: id,
    );

    // 5. المزامنة مع Firestore
    _syncExpenseToFirestore(id);

    return id;
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// تحديث مصروف (قبل الإقفال فقط)
  /// ═══════════════════════════════════════════════════════════════════════════
  ///
  /// ⚠️ ملاحظة: تحديث المصروف يتطلب:
  /// 1. عكس الحركة القديمة
  /// 2. إنشاء حركة جديدة
  /// 3. إعادة حساب إجماليات الوردية
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<void> updateExpense({
    required String id,
    double? amount,
    bool? isUsd,
    String? categoryId,
    String? description,
    DateTime? expenseDate,
  }) async {
    final expense = await getExpenseById(id);
    if (expense == null) {
      throw Exception('المصروف غير موجود');
    }

    // التحقق من أن الوردية لا تزال مفتوحة
    if (expense.shiftId != null) {
      final shift = await shiftRepo.getShiftById(expense.shiftId!);
      if (shift != null && shift.status == 'closed') {
        throw Exception('لا يمكن تعديل مصروف في وردية مغلقة');
      }
    }

    // حساب المبالغ الجديدة إذا تغير المبلغ
    double newAmountSyp = expense.amount;
    double newAmountUsd = expense.amountUsd ?? 0;
    double newExchangeRate = expense.exchangeRate;

    if (amount != null) {
      final lockedPrice =
          priceLockingService.lockPrice(amount, isUsd: isUsd ?? false);
      newAmountSyp = lockedPrice.syp;
      newAmountUsd = lockedPrice.usd;
      newExchangeRate = lockedPrice.exchangeRate;

      // عكس الحركة القديمة وإضافة الجديدة
      if (expense.shiftId != null) {
        await _adjustCashMovement(
          shiftId: expense.shiftId!,
          oldAmountSyp: expense.amount,
          oldAmountUsd: expense.amountUsd ?? 0,
          newAmountSyp: newAmountSyp,
          newAmountUsd: newAmountUsd,
          exchangeRate: newExchangeRate,
          description: description ?? expense.description ?? 'مصروف معدل',
          expenseId: id,
        );
      }
    }

    // تحديث المصروف
    await database.updateVoucher(VouchersCompanion(
      id: Value(id),
      voucherNumber: Value(expense.voucherNumber),
      type: const Value('expense'),
      categoryId: Value(categoryId ?? expense.categoryId),
      amount: Value(newAmountSyp),
      amountUsd: Value(newAmountUsd),
      exchangeRate: Value(newExchangeRate),
      description: Value(description ?? expense.description),
      customerId: Value(expense.customerId),
      supplierId: Value(expense.supplierId),
      shiftId: Value(expense.shiftId),
      syncStatus: const Value('pending'),
      voucherDate: Value(expenseDate ?? expense.voucherDate),
      createdAt: Value(expense.createdAt),
    ));

    _syncExpenseToFirestore(id);
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// حذف مصروف
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<void> deleteExpense(String id) async {
    final expense = await getExpenseById(id);
    if (expense == null) return;

    // التحقق من أن الوردية لا تزال مفتوحة
    if (expense.shiftId != null) {
      final shift = await shiftRepo.getShiftById(expense.shiftId!);
      if (shift != null && shift.status == 'closed') {
        throw Exception('لا يمكن حذف مصروف في وردية مغلقة');
      }

      // عكس حركة الصندوق
      await _reverseCashMovement(
        shiftId: expense.shiftId!,
        amountSyp: expense.amount,
        amountUsd: expense.amountUsd ?? 0,
        description:
            'إلغاء مصروف: ${expense.description ?? expense.voucherNumber}',
        expenseId: id,
      );
    }

    await database.deleteVoucher(id);

    try {
      await expenseCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting expense from Firestore: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // حركات الصندوق
  // ═══════════════════════════════════════════════════════════════════════════

  /// تسجيل حركة خصم من الصندوق
  Future<void> _recordCashMovement({
    required String shiftId,
    required double amount,
    required double amountUsd,
    required double exchangeRate,
    required String description,
    required String expenseId,
  }) async {
    final movementId = _uuid.v4();

    await database.insertCashMovement(CashMovementsCompanion(
      id: Value(movementId),
      shiftId: Value(shiftId),
      type: const Value('expense'),
      amount: Value(amount),
      amountUsd: Value(amountUsd),
      exchangeRate: Value(exchangeRate),
      description: Value(description),
      category: const Value('expense'),
      referenceId: Value(expenseId),
      referenceType: const Value('expense'),
      paymentMethod: const Value('cash'),
      syncStatus: const Value('pending'),
      createdAt: Value(DateTime.now()),
    ));

    // تحديث إجماليات الوردية
    final shift = await database.getShiftById(shiftId);
    if (shift != null) {
      await database.updateShift(ShiftsCompanion(
        id: Value(shiftId),
        totalExpenses: Value(shift.totalExpenses + amount),
        totalExpensesUsd: Value(shift.totalExpensesUsd + amountUsd),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }

  /// تعديل حركة الصندوق (عكس القديمة + إضافة الجديدة)
  Future<void> _adjustCashMovement({
    required String shiftId,
    required double oldAmountSyp,
    required double oldAmountUsd,
    required double newAmountSyp,
    required double newAmountUsd,
    required double exchangeRate,
    required String description,
    required String expenseId,
  }) async {
    final shift = await database.getShiftById(shiftId);
    if (shift == null) return;

    // حساب الفرق
    final diffSyp = newAmountSyp - oldAmountSyp;
    final diffUsd = newAmountUsd - oldAmountUsd;

    // تحديث إجماليات الوردية
    await database.updateShift(ShiftsCompanion(
      id: Value(shiftId),
      totalExpenses: Value(shift.totalExpenses + diffSyp),
      totalExpensesUsd: Value(shift.totalExpensesUsd + diffUsd),
      updatedAt: Value(DateTime.now()),
    ));

    // تسجيل حركة تعديل إذا كان هناك فرق
    if (diffSyp != 0) {
      final movementId = _uuid.v4();
      await database.insertCashMovement(CashMovementsCompanion(
        id: Value(movementId),
        shiftId: Value(shiftId),
        type: Value(diffSyp > 0 ? 'expense' : 'income'),
        amount: Value(diffSyp.abs()),
        amountUsd: Value(diffUsd.abs()),
        exchangeRate: Value(exchangeRate),
        description: Value('تعديل مصروف: $description'),
        category: const Value('expense_adjustment'),
        referenceId: Value(expenseId),
        referenceType: const Value('expense'),
        paymentMethod: const Value('cash'),
        syncStatus: const Value('pending'),
        createdAt: Value(DateTime.now()),
      ));
    }
  }

  /// عكس حركة الصندوق عند الحذف
  Future<void> _reverseCashMovement({
    required String shiftId,
    required double amountSyp,
    required double amountUsd,
    required String description,
    required String expenseId,
  }) async {
    final movementId = _uuid.v4();
    final rate = currencyService.exchangeRate;

    // إضافة حركة عكسية (إيرادات لإلغاء المصروف)
    await database.insertCashMovement(CashMovementsCompanion(
      id: Value(movementId),
      shiftId: Value(shiftId),
      type: const Value('income'),
      amount: Value(amountSyp),
      amountUsd: Value(amountUsd),
      exchangeRate: Value(rate),
      description: Value(description),
      category: const Value('expense_reversal'),
      referenceId: Value(expenseId),
      referenceType: const Value('expense'),
      paymentMethod: const Value('cash'),
      syncStatus: const Value('pending'),
      createdAt: Value(DateTime.now()),
    ));

    // تحديث إجماليات الوردية
    final shift = await database.getShiftById(shiftId);
    if (shift != null) {
      await database.updateShift(ShiftsCompanion(
        id: Value(shiftId),
        totalExpenses: Value(shift.totalExpenses - amountSyp),
        totalExpensesUsd: Value(shift.totalExpensesUsd - amountUsd),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // توليد رقم المصروف
  // ═══════════════════════════════════════════════════════════════════════════

  Future<String> _generateExpenseNumber() async {
    final now = DateTime.now();
    final prefix = 'EXP-${now.year}${now.month.toString().padLeft(2, '0')}';

    final expenses = await getAllExpenses();
    final todayExpenses = expenses.where((e) {
      return e.voucherNumber.startsWith(prefix);
    }).toList();

    final nextNumber = todayExpenses.length + 1;
    return '$prefix-${nextNumber.toString().padLeft(4, '0')}';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // المزامنة مع Firestore
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _syncExpenseToFirestore(String id) async {
    try {
      final expense = await getExpenseById(id);
      if (expense == null) return;

      await expenseCollection.doc(id).set({
        'id': expense.id,
        'voucherNumber': expense.voucherNumber,
        'type': expense.type,
        'categoryId': expense.categoryId,
        'amount': expense.amount,
        'amountUsd': expense.amountUsd,
        'exchangeRate': expense.exchangeRate,
        'description': expense.description,
        'shiftId': expense.shiftId,
        'voucherDate': Timestamp.fromDate(expense.voucherDate),
        'createdAt': Timestamp.fromDate(expense.createdAt),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await database.updateVoucher(VouchersCompanion(
        id: Value(id),
        voucherNumber: Value(expense.voucherNumber),
        type: Value(expense.type),
        categoryId: Value(expense.categoryId),
        amount: Value(expense.amount),
        amountUsd: Value(expense.amountUsd),
        exchangeRate: Value(expense.exchangeRate),
        description: Value(expense.description),
        customerId: Value(expense.customerId),
        supplierId: Value(expense.supplierId),
        shiftId: Value(expense.shiftId),
        syncStatus: const Value('synced'),
        voucherDate: Value(expense.voucherDate),
        createdAt: Value(expense.createdAt),
      ));
    } catch (e) {
      debugPrint('Error syncing expense to Firestore: $e');
    }
  }

  Future<void> _syncCategoryToFirestore(String id) async {
    try {
      final category = await getCategoryById(id);
      if (category == null) return;

      await categoryCollection.doc(id).set({
        'id': category.id,
        'name': category.name,
        'type': category.type,
        'isActive': category.isActive,
        'createdAt': Timestamp.fromDate(category.createdAt),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await database.updateVoucherCategory(VoucherCategoriesCompanion(
        id: Value(id),
        name: Value(category.name),
        type: Value(category.type),
        isActive: Value(category.isActive),
        syncStatus: const Value('synced'),
        createdAt: Value(category.createdAt),
      ));
    } catch (e) {
      debugPrint('Error syncing category to Firestore: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إحصائيات المصاريف
  // ═══════════════════════════════════════════════════════════════════════════

  /// إجمالي المصاريف (بالقيم المثبتة)
  Future<LockedPrice> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) async {
    List<Voucher> expenses;

    if (startDate != null && endDate != null) {
      expenses = await getExpensesByDateRange(startDate, endDate);
    } else {
      expenses = await getAllExpenses();
    }

    if (categoryId != null) {
      expenses = expenses.where((e) => e.categoryId == categoryId).toList();
    }

    // جمع القيم المثبتة (بدون إعادة حساب)
    double totalSyp = 0;
    double totalUsd = 0;

    for (final expense in expenses) {
      totalSyp += expense.amount;
      totalUsd += expense.amountUsd ?? 0;
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

  /// إجمالي المصاريف حسب التصنيف
  Future<Map<String, LockedPrice>> getExpensesByCategories({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<Voucher> expenses;

    if (startDate != null && endDate != null) {
      expenses = await getExpensesByDateRange(startDate, endDate);
    } else {
      expenses = await getAllExpenses();
    }

    final Map<String, List<Voucher>> grouped = {};
    for (final expense in expenses) {
      final catId = expense.categoryId ?? 'uncategorized';
      grouped.putIfAbsent(catId, () => []).add(expense);
    }

    final Map<String, LockedPrice> result = {};
    for (final entry in grouped.entries) {
      double totalSyp = 0;
      double totalUsd = 0;
      for (final expense in entry.value) {
        totalSyp += expense.amount;
        totalUsd += expense.amountUsd ?? 0;
      }
      final avgRate = totalUsd > 0 ? totalSyp / totalUsd : 0.0;
      result[entry.key] = LockedPrice(
        syp: totalSyp,
        usd: totalUsd,
        exchangeRate: avgRate,
        lockedAt: DateTime.now(),
        isHistorical: true,
      );
    }

    return result;
  }

  /// تنظيف الموارد
  void dispose() {
    _expenseFirestoreSubscription?.cancel();
    _categoryFirestoreSubscription?.cancel();
  }
}
