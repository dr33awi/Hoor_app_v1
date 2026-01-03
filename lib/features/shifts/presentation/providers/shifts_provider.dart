import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/shifts_dao.dart';
import '../../../../core/database/daos/invoices_dao.dart';
import '../../../../core/database/database.dart';

/// عنصر وردية
class ShiftItem {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final double openingBalance;
  final double? closingBalance;
  final double cashSales;
  final double cardSales;
  final double cashIn;
  final double cashOut;
  final int invoicesCount;
  final String? notes;
  final int userId;

  ShiftItem({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.openingBalance,
    this.closingBalance,
    required this.cashSales,
    required this.cardSales,
    required this.cashIn,
    required this.cashOut,
    required this.invoicesCount,
    this.notes,
    required this.userId,
  });

  double get totalSales => cashSales + cardSales;

  double get expectedCash => openingBalance + cashSales + cashIn - cashOut;

  double get difference {
    if (closingBalance == null) return 0;
    return closingBalance! - expectedCash;
  }

  bool get isOpen => endTime == null;
}

/// حالة الورديات
class ShiftsState {
  final bool isLoading;
  final List<ShiftItem> shifts;
  final ShiftItem? currentShift;

  const ShiftsState({
    this.isLoading = false,
    this.shifts = const [],
    this.currentShift,
  });

  ShiftsState copyWith({
    bool? isLoading,
    List<ShiftItem>? shifts,
    ShiftItem? currentShift,
    bool clearCurrentShift = false,
  }) {
    return ShiftsState(
      isLoading: isLoading ?? this.isLoading,
      shifts: shifts ?? this.shifts,
      currentShift:
          clearCurrentShift ? null : (currentShift ?? this.currentShift),
    );
  }
}

/// مدير الورديات
class ShiftsNotifier extends StateNotifier<ShiftsState> {
  final ShiftsDao _shiftDao;
  final InvoicesDao _invoiceDao;

  ShiftsNotifier(this._shiftDao, this._invoiceDao) : super(const ShiftsState());

  Future<void> loadShifts() async {
    state = state.copyWith(isLoading: true);

    try {
      // جلب ورديات آخر 30 يوم
      final endDate = DateTime.now().add(const Duration(days: 1));
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final shiftsWithUsers =
          await _shiftDao.getShiftsByDateRange(startDate, endDate);
      final items = <ShiftItem>[];

      for (final shiftWithUser in shiftsWithUsers) {
        final shift = shiftWithUser.shift;
        // حساب مبيعات الوردية
        final invoices = await _invoiceDao.getInvoicesByDateRange(
          shift.startTime,
          shift.endTime ?? DateTime.now(),
        );

        double cashSales = 0;
        double cardSales = 0;
        int invoicesCount = 0;

        for (final invoice in invoices) {
          if (invoice.status == 'completed') {
            invoicesCount++;
            switch (invoice.paymentMethod) {
              case 'cash':
                cashSales += invoice.total;
                break;
              case 'card':
                cardSales += invoice.total;
                break;
            }
          }
        }

        items.add(ShiftItem(
          id: shift.id,
          startTime: shift.startTime,
          endTime: shift.endTime,
          openingBalance: shift.openingBalance,
          closingBalance: shift.closingBalance,
          cashSales: cashSales,
          cardSales: cardSales,
          cashIn: shift.totalCashIn,
          cashOut: shift.totalCashOut,
          invoicesCount: invoicesCount,
          notes: shift.notes,
          userId: shift.userId,
        ));
      }

      // ترتيب حسب التاريخ (الأحدث أولاً)
      items.sort((a, b) => b.startTime.compareTo(a.startTime));

      // البحث عن الوردية المفتوحة
      final openShift = items.firstWhere(
        (s) => s.isOpen,
        orElse: () => ShiftItem(
          id: 0,
          startTime: DateTime.now(),
          openingBalance: 0,
          cashSales: 0,
          cardSales: 0,
          cashIn: 0,
          cashOut: 0,
          invoicesCount: 0,
          userId: 0,
        ),
      );

      state = state.copyWith(
        shifts: items,
        currentShift: openShift.id != 0 ? openShift : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> openShift({
    required double openingBalance,
    int userId = 1,
  }) async {
    try {
      await _shiftDao.openShift(userId, openingBalance);
      await loadShifts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeShift({
    required double closingBalance,
    String? note,
  }) async {
    if (state.currentShift == null) return;

    try {
      await _shiftDao.closeShift(
        state.currentShift!.id,
        closingBalance,
        notes: note,
      );
      await loadShifts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addCash({
    required double amount,
    String? note,
  }) async {
    if (state.currentShift == null) return;

    try {
      await _shiftDao.updateShiftStats(
        state.currentShift!.id,
        cashInAmount: amount,
      );
      await loadShifts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> withdrawCash({
    required double amount,
    String? note,
  }) async {
    if (state.currentShift == null) return;

    try {
      await _shiftDao.updateShiftStats(
        state.currentShift!.id,
        cashOutAmount: amount,
      );
      await loadShifts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSaleToShift({
    required double amount,
    required String paymentMethod,
  }) async {
    // يتم استدعاء هذه الدالة عند إتمام عملية بيع
    // لتحديث إحصائيات الوردية الحالية
    await loadShifts();
  }
}

/// مزود الورديات
final shiftsProvider =
    StateNotifierProvider<ShiftsNotifier, ShiftsState>((ref) {
  final shiftDao = GetIt.instance<ShiftsDao>();
  final invoiceDao = GetIt.instance<InvoicesDao>();
  return ShiftsNotifier(shiftDao, invoiceDao);
});

/// مزود الوردية الحالية
final currentShiftProvider = Provider<ShiftItem?>((ref) {
  return ref.watch(shiftsProvider).currentShift;
});

/// مزود حالة فتح الوردية
final isShiftOpenProvider = Provider<bool>((ref) {
  return ref.watch(shiftsProvider).currentShift != null;
});
