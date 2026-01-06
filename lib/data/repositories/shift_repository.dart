import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/currency_service.dart';
import 'base_repository.dart';

class ShiftRepository extends BaseRepository<Shift, ShiftsCompanion> {
  StreamSubscription? _shiftFirestoreSubscription;

  ShiftRepository({
    required super.database,
    required super.firestore,
  }) : super(collectionName: AppConstants.shiftsCollection);

  // ==================== Local Operations ====================

  Future<List<Shift>> getAllShifts() => database.getAllShifts();

  Stream<List<Shift>> watchAllShifts() => database.watchAllShifts();

  Future<Shift?> getOpenShift() => database.getOpenShift();

  Stream<Shift?> watchOpenShift() => database.watchOpenShift();

  Future<Shift?> getShiftById(String id) => database.getShiftById(id);

  /// Check if there's an open shift
  Future<bool> hasOpenShift() async {
    final shift = await database.getOpenShift();
    return shift != null;
  }

  /// Open a new shift
  Future<String> openShift({
    required double openingBalance,
    double? openingBalanceUsd,
    double? exchangeRate,
    String? notes,
  }) async {
    // Check if there's already an open shift
    final existingShift = await database.getOpenShift();
    if (existingShift != null) {
      throw Exception('يوجد وردية مفتوحة بالفعل. يرجى إغلاقها أولاً.');
    }

    final id = generateId();
    final now = DateTime.now();
    final shiftNumber = await _generateShiftNumber();

    // تثبيت سعر الصرف وقت فتح الوردية
    final rate = exchangeRate ?? CurrencyService.currentRate;
    final balanceUsd = openingBalanceUsd ?? (openingBalance / rate);

    await database.insertShift(ShiftsCompanion(
      id: Value(id),
      shiftNumber: Value(shiftNumber),
      openingBalance: Value(openingBalance),
      openingBalanceUsd: Value(balanceUsd),
      exchangeRate: Value(rate),
      status: const Value('open'),
      notes: Value(notes),
      syncStatus: const Value('pending'),
      openedAt: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // Record opening balance as cash movement
    await database.insertCashMovement(CashMovementsCompanion(
      id: Value(generateId()),
      shiftId: Value(id),
      type: const Value('opening'),
      amount: Value(openingBalance),
      amountUsd: Value(balanceUsd),
      exchangeRate: Value(rate),
      description: const Value('رصيد افتتاحي'),
      paymentMethod: const Value('cash'),
      syncStatus: const Value('pending'),
      createdAt: Value(now),
    ));

    // Sync immediately to Firestore
    _syncShiftToFirestore(id);

    return id;
  }

  /// Close the current shift
  Future<void> closeShift({
    required String shiftId,
    required double closingBalance,
    double? closingBalanceUsd,
    String? notes,
  }) async {
    final shift = await database.getShiftById(shiftId);
    if (shift == null) {
      throw Exception('الوردية غير موجودة');
    }
    if (shift.status == 'closed') {
      throw Exception('الوردية مغلقة بالفعل');
    }

    // استخدام سعر الصرف المحفوظ مع الوردية
    final rate = shift.exchangeRate ?? CurrencyService.currentRate;

    // Calculate expected balance (يشمل جميع أنواع الحركات)
    final movements = await database.getCashMovementsByShift(shiftId);
    double expectedBalance = shift.openingBalance;
    double expectedBalanceUsd =
        shift.openingBalanceUsd ?? (shift.openingBalance / rate);
    double totalSales = 0;
    double totalSalesUsd = 0;
    double totalReturns = 0;
    double totalReturnsUsd = 0;
    double totalExpenses = 0;
    double totalExpensesUsd = 0;
    double totalIncome = 0;
    double totalIncomeUsd = 0;
    // ignore: unused_local_variable
    double totalVoucherReceipts = 0;
    // ignore: unused_local_variable
    double totalVoucherPayments = 0;
    // ignore: unused_local_variable
    double totalPurchases = 0;

    for (final movement in movements) {
      // حساب المبلغ بالدولار من الحركة أو من سعر الصرف
      final movementRate = movement.exchangeRate ?? rate;
      final movementUsd =
          movement.amountUsd ?? (movement.amount / movementRate);

      switch (movement.type) {
        // ═══════════════════════════════════════════════════════════════════════════
        // الإيرادات (تضاف للرصيد)
        // ═══════════════════════════════════════════════════════════════════════════
        case 'sale':
          expectedBalance += movement.amount;
          expectedBalanceUsd += movementUsd;
          totalSales += movement.amount;
          totalSalesUsd += movementUsd;
          break;
        case 'income':
          expectedBalance += movement.amount;
          expectedBalanceUsd += movementUsd;
          totalIncome += movement.amount;
          totalIncomeUsd += movementUsd;
          break;
        case 'voucher_receipt':
          // سند قبض = إيراد (يضاف للصندوق)
          expectedBalance += movement.amount;
          expectedBalanceUsd += movementUsd;
          totalVoucherReceipts += movement.amount;
          totalIncome += movement.amount;
          totalIncomeUsd += movementUsd;
          break;
        case 'purchase_return':
          // مرتجع مشتريات = إيراد (يعود للصندوق)
          expectedBalance += movement.amount;
          expectedBalanceUsd += movementUsd;
          totalIncome += movement.amount;
          totalIncomeUsd += movementUsd;
          break;

        // ═══════════════════════════════════════════════════════════════════════════
        // المصروفات (تخصم من الرصيد)
        // ═══════════════════════════════════════════════════════════════════════════
        case 'purchase':
          expectedBalance -= movement.amount;
          expectedBalanceUsd -= movementUsd;
          totalPurchases += movement.amount;
          totalExpenses += movement.amount;
          totalExpensesUsd += movementUsd;
          break;
        case 'expense':
          expectedBalance -= movement.amount;
          expectedBalanceUsd -= movementUsd;
          totalExpenses += movement.amount;
          totalExpensesUsd += movementUsd;
          break;
        case 'voucher_payment':
          // سند دفع = مصروف (يخصم من الصندوق)
          expectedBalance -= movement.amount;
          expectedBalanceUsd -= movementUsd;
          totalVoucherPayments += movement.amount;
          totalExpenses += movement.amount;
          totalExpensesUsd += movementUsd;
          break;
        case 'sale_return':
        case 'return':
          // مرتجع مبيعات = مصروف (يرد للعميل)
          expectedBalance -= movement.amount;
          expectedBalanceUsd -= movementUsd;
          totalReturns += movement.amount;
          totalReturnsUsd += movementUsd;
          break;

        // ═══════════════════════════════════════════════════════════════════════════
        // حالات أخرى (لا تؤثر على الحساب)
        // ═══════════════════════════════════════════════════════════════════════════
        case 'opening':
        case 'closing':
          // رصيد افتتاحي/إغلاق - لا يؤثر على الحساب
          break;
        default:
          // أي نوع غير معروف - نفترض أنه مصروف للأمان
          if (movement.amount > 0) {
            expectedBalance -= movement.amount;
            expectedBalanceUsd -= movementUsd;
            totalExpenses += movement.amount;
            totalExpensesUsd += movementUsd;
          }
          break;
      }
    }

    final difference = closingBalance - expectedBalance;
    final closingUsd = closingBalanceUsd ?? (closingBalance / rate);
    final now = DateTime.now();

    await database.updateShift(ShiftsCompanion(
      id: Value(shiftId),
      shiftNumber: Value(shift.shiftNumber),
      openingBalance: Value(shift.openingBalance),
      openingBalanceUsd: Value(shift.openingBalanceUsd),
      exchangeRate: Value(shift.exchangeRate),
      closingBalance: Value(closingBalance),
      closingBalanceUsd: Value(closingUsd),
      expectedBalance: Value(expectedBalance),
      expectedBalanceUsd: Value(expectedBalanceUsd),
      difference: Value(difference),
      totalSales: Value(totalSales),
      totalSalesUsd: Value(totalSalesUsd),
      totalReturns: Value(totalReturns),
      totalReturnsUsd: Value(totalReturnsUsd),
      totalExpenses: Value(totalExpenses),
      totalExpensesUsd: Value(totalExpensesUsd),
      totalIncome: Value(totalIncome),
      totalIncomeUsd: Value(totalIncomeUsd),
      transactionCount: Value(movements.length),
      status: const Value('closed'),
      notes: Value(notes ?? shift.notes),
      syncStatus: const Value('pending'),
      openedAt: Value(shift.openedAt),
      closedAt: Value(now),
      createdAt: Value(shift.createdAt),
      updatedAt: Value(now),
    ));

    // Record closing balance
    await database.insertCashMovement(CashMovementsCompanion(
      id: Value(generateId()),
      shiftId: Value(shiftId),
      type: const Value('closing'),
      amount: Value(closingBalance),
      amountUsd: Value(closingUsd),
      exchangeRate: Value(rate),
      description: const Value('رصيد إغلاق'),
      paymentMethod: const Value('cash'),
      syncStatus: const Value('pending'),
      createdAt: Value(now),
    ));

    // Sync immediately to Firestore
    _syncShiftToFirestore(shiftId);
  }

  Future<String> _generateShiftNumber() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    final shifts = await database.getAllShifts();
    final todayShifts = shifts
        .where((s) =>
            s.openedAt.year == today.year &&
            s.openedAt.month == today.month &&
            s.openedAt.day == today.day)
        .length;

    return 'SH-$dateStr-${(todayShifts + 1).toString().padLeft(2, '0')}';
  }

  /// Get shift summary with detailed breakdown
  Future<Map<String, dynamic>> getShiftSummary(String shiftId) async {
    final shift = await database.getShiftById(shiftId);
    if (shift == null) {
      throw Exception('الوردية غير موجودة');
    }

    final movements = await database.getCashMovementsByShift(shiftId);
    final invoices = await database.getInvoicesByShift(shiftId);
    final vouchers = await database.getVouchersByShift(shiftId);

    // تصنيف الفواتير
    final sales = invoices.where((i) => i.type == 'sale').toList();
    final purchases = invoices.where((i) => i.type == 'purchase').toList();
    final saleReturns = invoices.where((i) => i.type == 'sale_return').toList();
    final purchaseReturns =
        invoices.where((i) => i.type == 'purchase_return').toList();

    // تصنيف السندات
    final receipts = vouchers.where((v) => v.type == 'receipt').toList();
    final payments = vouchers.where((v) => v.type == 'payment').toList();
    final expenses = vouchers.where((v) => v.type == 'expense').toList();

    // إجماليات الفواتير
    double totalSalesAmount = 0;
    double totalSalesUsd = 0;
    double totalPurchasesAmount = 0;
    double totalPurchasesUsd = 0;
    double totalSaleReturnsAmount = 0;
    double totalSaleReturnsUsd = 0;
    double totalPurchaseReturnsAmount = 0;
    double totalPurchaseReturnsUsd = 0;

    for (final inv in sales) {
      totalSalesAmount += inv.paidAmount;
      totalSalesUsd += inv.paidAmountUsd ??
          (inv.paidAmount / (inv.exchangeRate ?? CurrencyService.currentRate));
    }
    for (final inv in purchases) {
      totalPurchasesAmount += inv.paidAmount;
      totalPurchasesUsd += inv.paidAmountUsd ??
          (inv.paidAmount / (inv.exchangeRate ?? CurrencyService.currentRate));
    }
    for (final inv in saleReturns) {
      totalSaleReturnsAmount += inv.total;
      totalSaleReturnsUsd += inv.totalUsd ??
          (inv.total / (inv.exchangeRate ?? CurrencyService.currentRate));
    }
    for (final inv in purchaseReturns) {
      totalPurchaseReturnsAmount += inv.total;
      totalPurchaseReturnsUsd += inv.totalUsd ??
          (inv.total / (inv.exchangeRate ?? CurrencyService.currentRate));
    }

    // إجماليات السندات
    double totalReceiptsAmount = 0;
    double totalReceiptsUsd = 0;
    double totalPaymentsAmount = 0;
    double totalPaymentsUsd = 0;
    double totalExpensesAmount = 0;
    double totalExpensesUsd = 0;

    for (final v in receipts) {
      totalReceiptsAmount += v.amount;
      totalReceiptsUsd += v.amountUsd ??
          (v.amount / (v.exchangeRate ?? CurrencyService.currentRate));
    }
    for (final v in payments) {
      totalPaymentsAmount += v.amount;
      totalPaymentsUsd += v.amountUsd ??
          (v.amount / (v.exchangeRate ?? CurrencyService.currentRate));
    }
    for (final v in expenses) {
      totalExpensesAmount += v.amount;
      totalExpensesUsd += v.amountUsd ??
          (v.amount / (v.exchangeRate ?? CurrencyService.currentRate));
    }

    return {
      'shift': shift,
      'movements': movements,
      'invoices': invoices,
      'vouchers': vouchers,
      // تفاصيل الفواتير
      'sales': sales,
      'salesCount': sales.length,
      'totalSalesAmount': totalSalesAmount,
      'totalSalesUsd': totalSalesUsd,
      'purchases': purchases,
      'purchasesCount': purchases.length,
      'totalPurchasesAmount': totalPurchasesAmount,
      'totalPurchasesUsd': totalPurchasesUsd,
      'saleReturns': saleReturns,
      'returnsCount': saleReturns.length,
      'totalSaleReturnsAmount': totalSaleReturnsAmount,
      'totalSaleReturnsUsd': totalSaleReturnsUsd,
      'purchaseReturns': purchaseReturns,
      'purchaseReturnsCount': purchaseReturns.length,
      'totalPurchaseReturnsAmount': totalPurchaseReturnsAmount,
      'totalPurchaseReturnsUsd': totalPurchaseReturnsUsd,
      // تفاصيل السندات
      'receipts': receipts,
      'receiptsCount': receipts.length,
      'totalReceiptsAmount': totalReceiptsAmount,
      'totalReceiptsUsd': totalReceiptsUsd,
      'payments': payments,
      'paymentsCount': payments.length,
      'totalPaymentsAmount': totalPaymentsAmount,
      'totalPaymentsUsd': totalPaymentsUsd,
      'expenses': expenses,
      'expensesCount': expenses.length,
      'totalExpensesAmount': totalExpensesAmount,
      'totalExpensesUsd': totalExpensesUsd,
      // تحليل المبيعات حسب طريقة الدفع
      'paymentMethodAnalysis': _analyzePaymentMethods(sales),
      // تحليل المبيعات حسب الساعة
      'hourlyAnalysis': _analyzeHourlySales(sales, shift),
    };
  }

  /// تحليل المبيعات حسب طريقة الدفع
  Map<String, dynamic> _analyzePaymentMethods(List<Invoice> sales) {
    double cashTotal = 0;
    double cashTotalUsd = 0;
    int cashCount = 0;
    double creditTotal = 0;
    double creditTotalUsd = 0;
    int creditCount = 0;

    for (final inv in sales) {
      final amountUsd = inv.paidAmountUsd ??
          (inv.paidAmount / (inv.exchangeRate ?? CurrencyService.currentRate));

      // التحقق من طريقة الدفع: cash = نقدي، credit = آجل
      if (inv.paymentMethod == 'cash') {
        cashTotal += inv.paidAmount;
        cashTotalUsd += amountUsd;
        cashCount++;
      } else {
        creditTotal += inv.paidAmount;
        creditTotalUsd += amountUsd;
        creditCount++;
      }
    }

    final total = cashTotal + creditTotal;
    return {
      'cashTotal': cashTotal,
      'cashTotalUsd': cashTotalUsd,
      'cashCount': cashCount,
      'cashPercentage': total > 0 ? (cashTotal / total * 100) : 0,
      'creditTotal': creditTotal,
      'creditTotalUsd': creditTotalUsd,
      'creditCount': creditCount,
      'creditPercentage': total > 0 ? (creditTotal / total * 100) : 0,
    };
  }

  /// تحليل المبيعات حسب الساعة
  Map<int, Map<String, dynamic>> _analyzeHourlySales(
      List<Invoice> sales, Shift shift) {
    final hourlyData = <int, Map<String, dynamic>>{};

    // تحديد نطاق الساعات للوردية
    final startHour = shift.openedAt.hour;
    final endHour = shift.closedAt?.hour ?? DateTime.now().hour;

    // تهيئة البيانات لكل ساعة
    for (int h = startHour; h <= endHour; h++) {
      hourlyData[h] = {
        'count': 0,
        'total': 0.0,
        'totalUsd': 0.0,
      };
    }

    // تجميع المبيعات حسب الساعة
    for (final inv in sales) {
      final hour = inv.createdAt.hour;
      if (hourlyData.containsKey(hour)) {
        hourlyData[hour]!['count'] = (hourlyData[hour]!['count'] as int) + 1;
        hourlyData[hour]!['total'] =
            (hourlyData[hour]!['total'] as double) + inv.paidAmount;
        hourlyData[hour]!['totalUsd'] =
            (hourlyData[hour]!['totalUsd'] as double) +
                (inv.paidAmountUsd ??
                    (inv.paidAmount /
                        (inv.exchangeRate ?? CurrencyService.currentRate)));
      }
    }

    return hourlyData;
  }

  // ==================== Analytics & Reports ====================

  /// الحصول على أكثر المنتجات مبيعاً خلال الوردية
  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    String? shiftId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  }) async {
    return database.getTopSellingProducts(
      shiftId: shiftId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  /// الحصول على تقرير الأرباح
  Future<Map<String, dynamic>> getProfitReport({
    String? shiftId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return database.getProfitReport(
      shiftId: shiftId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// الحصول على بيانات المبيعات اليومية للرسوم البيانية
  Future<List<Map<String, dynamic>>> getDailySalesData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return database.getDailySalesData(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== Cloud Sync ====================

  /// Sync a specific shift to Firestore immediately
  Future<void> _syncShiftToFirestore(String shiftId) async {
    try {
      final shift = await database.getShiftById(shiftId);
      if (shift == null) return;

      await collection.doc(shiftId).set(toFirestore(shift));

      await database.updateShift(ShiftsCompanion(
        id: Value(shift.id),
        shiftNumber: Value(shift.shiftNumber),
        openingBalance: Value(shift.openingBalance),
        openingBalanceUsd: Value(shift.openingBalanceUsd),
        exchangeRate: Value(shift.exchangeRate),
        closingBalance: Value(shift.closingBalance),
        closingBalanceUsd: Value(shift.closingBalanceUsd),
        expectedBalance: Value(shift.expectedBalance),
        expectedBalanceUsd: Value(shift.expectedBalanceUsd),
        difference: Value(shift.difference),
        totalSales: Value(shift.totalSales),
        totalSalesUsd: Value(shift.totalSalesUsd),
        totalReturns: Value(shift.totalReturns),
        totalReturnsUsd: Value(shift.totalReturnsUsd),
        totalExpenses: Value(shift.totalExpenses),
        totalExpensesUsd: Value(shift.totalExpensesUsd),
        totalIncome: Value(shift.totalIncome),
        totalIncomeUsd: Value(shift.totalIncomeUsd),
        transactionCount: Value(shift.transactionCount),
        status: Value(shift.status),
        notes: Value(shift.notes),
        syncStatus: const Value('synced'),
        openedAt: Value(shift.openedAt),
        closedAt: Value(shift.closedAt),
        createdAt: Value(shift.createdAt),
        updatedAt: Value(shift.updatedAt),
      ));

      debugPrint('Shift $shiftId synced to Firestore');
    } catch (e) {
      debugPrint('Error syncing shift $shiftId to Firestore: $e');
    }
  }

  @override
  Future<void> syncPendingChanges() async {
    final pending = await database.getPendingShifts();

    for (final shift in pending) {
      try {
        await collection.doc(shift.id).set(toFirestore(shift));

        await database.updateShift(ShiftsCompanion(
          id: Value(shift.id),
          shiftNumber: Value(shift.shiftNumber),
          openingBalance: Value(shift.openingBalance),
          openingBalanceUsd: Value(shift.openingBalanceUsd),
          exchangeRate: Value(shift.exchangeRate),
          closingBalance: Value(shift.closingBalance),
          closingBalanceUsd: Value(shift.closingBalanceUsd),
          expectedBalance: Value(shift.expectedBalance),
          expectedBalanceUsd: Value(shift.expectedBalanceUsd),
          difference: Value(shift.difference),
          totalSales: Value(shift.totalSales),
          totalSalesUsd: Value(shift.totalSalesUsd),
          totalReturns: Value(shift.totalReturns),
          totalReturnsUsd: Value(shift.totalReturnsUsd),
          totalExpenses: Value(shift.totalExpenses),
          totalExpensesUsd: Value(shift.totalExpensesUsd),
          totalIncome: Value(shift.totalIncome),
          totalIncomeUsd: Value(shift.totalIncomeUsd),
          transactionCount: Value(shift.transactionCount),
          status: Value(shift.status),
          notes: Value(shift.notes),
          syncStatus: const Value('synced'),
          openedAt: Value(shift.openedAt),
          closedAt: Value(shift.closedAt),
          createdAt: Value(shift.createdAt),
          updatedAt: Value(shift.updatedAt),
        ));
      } catch (e) {
        debugPrint('Error syncing shift ${shift.id}: $e');
      }
    }
  }

  @override
  Future<void> pullFromCloud() async {
    try {
      final snapshot = await collection
          .orderBy('openedAt', descending: true)
          .limit(100)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final companion = fromFirestore(data, doc.id);

        final existing = await database.getShiftById(doc.id);
        if (existing == null) {
          await database.insertShift(companion);
        }
      }
    } catch (e) {
      debugPrint('Error pulling shifts from cloud: $e');
    }
  }

  @override
  Map<String, dynamic> toFirestore(Shift entity) {
    return {
      'shiftNumber': entity.shiftNumber,
      'openingBalance': entity.openingBalance,
      'openingBalanceUsd': entity.openingBalanceUsd,
      'exchangeRate': entity.exchangeRate,
      'closingBalance': entity.closingBalance,
      'closingBalanceUsd': entity.closingBalanceUsd,
      'expectedBalance': entity.expectedBalance,
      'expectedBalanceUsd': entity.expectedBalanceUsd,
      'difference': entity.difference,
      'totalSales': entity.totalSales,
      'totalSalesUsd': entity.totalSalesUsd,
      'totalReturns': entity.totalReturns,
      'totalReturnsUsd': entity.totalReturnsUsd,
      'totalExpenses': entity.totalExpenses,
      'totalExpensesUsd': entity.totalExpensesUsd,
      'totalIncome': entity.totalIncome,
      'totalIncomeUsd': entity.totalIncomeUsd,
      'transactionCount': entity.transactionCount,
      'status': entity.status,
      'notes': entity.notes,
      'openedAt': Timestamp.fromDate(entity.openedAt),
      'closedAt':
          entity.closedAt != null ? Timestamp.fromDate(entity.closedAt!) : null,
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': Timestamp.fromDate(entity.updatedAt),
    };
  }

  @override
  ShiftsCompanion fromFirestore(Map<String, dynamic> data, String id) {
    return ShiftsCompanion(
      id: Value(id),
      shiftNumber: Value(data['shiftNumber'] as String),
      openingBalance: Value((data['openingBalance'] as num).toDouble()),
      openingBalanceUsd: Value((data['openingBalanceUsd'] as num?)?.toDouble()),
      exchangeRate: Value((data['exchangeRate'] as num?)?.toDouble()),
      closingBalance: Value((data['closingBalance'] as num?)?.toDouble()),
      closingBalanceUsd: Value((data['closingBalanceUsd'] as num?)?.toDouble()),
      expectedBalance: Value((data['expectedBalance'] as num?)?.toDouble()),
      expectedBalanceUsd:
          Value((data['expectedBalanceUsd'] as num?)?.toDouble()),
      difference: Value((data['difference'] as num?)?.toDouble()),
      totalSales: Value((data['totalSales'] as num?)?.toDouble() ?? 0),
      totalSalesUsd: Value((data['totalSalesUsd'] as num?)?.toDouble() ?? 0),
      totalReturns: Value((data['totalReturns'] as num?)?.toDouble() ?? 0),
      totalReturnsUsd:
          Value((data['totalReturnsUsd'] as num?)?.toDouble() ?? 0),
      totalExpenses: Value((data['totalExpenses'] as num?)?.toDouble() ?? 0),
      totalExpensesUsd:
          Value((data['totalExpensesUsd'] as num?)?.toDouble() ?? 0),
      totalIncome: Value((data['totalIncome'] as num?)?.toDouble() ?? 0),
      totalIncomeUsd: Value((data['totalIncomeUsd'] as num?)?.toDouble() ?? 0),
      transactionCount: Value(data['transactionCount'] as int? ?? 0),
      status: Value(data['status'] as String),
      notes: Value(data['notes'] as String?),
      syncStatus: const Value('synced'),
      openedAt: Value((data['openedAt'] as Timestamp).toDate()),
      closedAt: Value(data['closedAt'] != null
          ? (data['closedAt'] as Timestamp).toDate()
          : null),
      createdAt: Value((data['createdAt'] as Timestamp).toDate()),
      updatedAt: Value((data['updatedAt'] as Timestamp).toDate()),
    );
  }

  @override
  void startRealtimeSync() {
    _shiftFirestoreSubscription?.cancel();
    _shiftFirestoreSubscription = collection.snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            final data = change.doc.data() as Map<String, dynamic>?;
            if (data == null) continue;
            _handleRemoteChange(data, change.doc.id);
            break;
          case DocumentChangeType.removed:
            _handleRemoteDelete(change.doc.id);
            break;
        }
      }
    });
  }

  @override
  void stopRealtimeSync() {
    _shiftFirestoreSubscription?.cancel();
    _shiftFirestoreSubscription = null;
  }

  Future<void> _handleRemoteChange(Map<String, dynamic> data, String id) async {
    try {
      final existing = await database.getShiftById(id);
      final companion = fromFirestore(data, id);

      if (existing == null) {
        await database.insertShift(companion);
      } else if (existing.syncStatus == 'synced') {
        final cloudUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
        if (cloudUpdatedAt.isAfter(existing.updatedAt)) {
          await database.updateShift(companion);
        }
      }
    } catch (e) {
      debugPrint('Error handling remote shift change: $e');
    }
  }

  Future<void> _handleRemoteDelete(String id) async {
    try {
      final existing = await database.getShiftById(id);
      if (existing != null) {
        // Delete cash movements for this shift first
        await database.deleteCashMovementsByShift(id);
        // Then delete the shift
        await database.deleteShift(id);
        debugPrint('Deleted shift from remote: $id');
      }
    } catch (e) {
      debugPrint('Error handling remote shift delete: $e');
    }
  }
}
