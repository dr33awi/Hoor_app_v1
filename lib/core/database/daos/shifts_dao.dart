import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/shifts_table.dart';
import '../tables/users_table.dart';

part 'shifts_dao.g.dart';

/// نموذج الوردية مع بيانات المستخدم
class ShiftWithUser {
  final Shift shift;
  final User user;

  ShiftWithUser({required this.shift, required this.user});
}

@DriftAccessor(tables: [Shifts, Users])
class ShiftsDao extends DatabaseAccessor<AppDatabase> with _$ShiftsDaoMixin {
  ShiftsDao(super.db);

  // الحصول على الوردية المفتوحة للمستخدم
  Future<Shift?> getOpenShift(int userId) {
    return (select(shifts)
          ..where((s) => s.userId.equals(userId) & s.status.equals('open')))
        .getSingleOrNull();
  }

  // الحصول على أي وردية مفتوحة
  Future<Shift?> getAnyOpenShift() {
    return (select(shifts)..where((s) => s.status.equals('open')))
        .getSingleOrNull();
  }

  // التحقق من وجود وردية مفتوحة
  Future<bool> hasOpenShift(int userId) async {
    final shift = await getOpenShift(userId);
    return shift != null;
  }

  // الحصول على وردية بواسطة المعرف
  Future<Shift?> getShiftById(int id) {
    return (select(shifts)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  // الحصول على وردية مع بيانات المستخدم
  Future<ShiftWithUser?> getShiftWithUser(int id) async {
    final query = select(shifts).join([
      innerJoin(users, users.id.equalsExp(shifts.userId)),
    ])
      ..where(shifts.id.equals(id));

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    return ShiftWithUser(
      shift: result.readTable(shifts),
      user: result.readTable(users),
    );
  }

  // فتح وردية جديدة
  Future<int> openShift(int userId, double openingBalance) async {
    // التأكد من عدم وجود وردية مفتوحة
    final existingShift = await getOpenShift(userId);
    if (existingShift != null) {
      throw Exception('يوجد وردية مفتوحة بالفعل');
    }

    return into(shifts).insert(ShiftsCompanion.insert(
      userId: userId,
      startTime: DateTime.now(),
      openingBalance: openingBalance,
      createdAt: Value(DateTime.now()),
    ));
  }

  // إغلاق وردية
  Future<void> closeShift(
    int shiftId,
    double closingBalance, {
    String? notes,
  }) async {
    final shift = await getShiftById(shiftId);
    if (shift == null) throw Exception('الوردية غير موجودة');
    if (shift.status == 'closed') throw Exception('الوردية مغلقة بالفعل');

    final expectedBalance = shift.openingBalance +
        shift.totalSales -
        shift.totalReturns +
        shift.totalCashIn -
        shift.totalCashOut;
    final difference = closingBalance - expectedBalance;

    await (update(shifts)..where((s) => s.id.equals(shiftId)))
        .write(ShiftsCompanion(
      endTime: Value(DateTime.now()),
      closingBalance: Value(closingBalance),
      expectedBalance: Value(expectedBalance),
      difference: Value(difference),
      status: const Value('closed'),
      notes: Value(notes),
    ));
  }

  // تحديث إحصائيات الوردية
  Future<void> updateShiftStats(
    int shiftId, {
    double? salesAmount,
    double? returnsAmount,
    double? cashInAmount,
    double? cashOutAmount,
    bool incrementTransactions = false,
  }) async {
    final shift = await getShiftById(shiftId);
    if (shift == null) return;

    await (update(shifts)..where((s) => s.id.equals(shiftId)))
        .write(ShiftsCompanion(
      totalSales: Value(shift.totalSales + (salesAmount ?? 0)),
      totalReturns: Value(shift.totalReturns + (returnsAmount ?? 0)),
      totalCashIn: Value(shift.totalCashIn + (cashInAmount ?? 0)),
      totalCashOut: Value(shift.totalCashOut + (cashOutAmount ?? 0)),
      transactionsCount:
          Value(shift.transactionsCount + (incrementTransactions ? 1 : 0)),
    ));
  }

  // الحصول على ورديات اليوم
  Future<List<ShiftWithUser>> getTodayShifts() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = select(shifts).join([
      innerJoin(users, users.id.equalsExp(shifts.userId)),
    ])
      ..where(shifts.startTime.isBetweenValues(startOfDay, endOfDay))
      ..orderBy([
        OrderingTerm(expression: shifts.startTime, mode: OrderingMode.desc)
      ]);

    final results = await query.get();
    return results.map((row) {
      return ShiftWithUser(
        shift: row.readTable(shifts),
        user: row.readTable(users),
      );
    }).toList();
  }

  // الحصول على ورديات فترة معينة
  Future<List<ShiftWithUser>> getShiftsByDateRange(
      DateTime start, DateTime end) async {
    final query = select(shifts).join([
      innerJoin(users, users.id.equalsExp(shifts.userId)),
    ])
      ..where(shifts.startTime.isBetweenValues(start, end))
      ..orderBy([
        OrderingTerm(expression: shifts.startTime, mode: OrderingMode.desc)
      ]);

    final results = await query.get();
    return results.map((row) {
      return ShiftWithUser(
        shift: row.readTable(shifts),
        user: row.readTable(users),
      );
    }).toList();
  }

  // الحصول على ورديات مستخدم
  Future<List<Shift>> getUserShifts(int userId, {int limit = 50}) {
    return (select(shifts)
          ..where((s) => s.userId.equals(userId))
          ..orderBy([
            (s) =>
                OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
  }

  // إحصائيات الورديات
  Future<double> getTotalSalesInShift(int shiftId) async {
    final shift = await getShiftById(shiftId);
    return shift?.totalSales ?? 0;
  }

  // مراقبة الوردية المفتوحة
  Stream<Shift?> watchOpenShift(int userId) {
    return (select(shifts)
          ..where((s) => s.userId.equals(userId) & s.status.equals('open')))
        .watchSingleOrNull();
  }
}
