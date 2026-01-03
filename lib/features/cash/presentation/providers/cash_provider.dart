import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/cash_dao.dart';
import '../../../../core/database/database.dart';

/// نوع المعاملة
enum CashTransactionType { income, expense }

/// فلتر المعاملات
enum CashFilter { all, income, expense }

/// معاملة مالية للعرض
class CashTransactionItem {
  final int id;
  final CashTransactionType type;
  final String category;
  final double amount;
  final String? description;
  final DateTime date;

  CashTransactionItem({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
  });
}

/// حالة الصندوق
class CashState {
  final List<CashTransactionItem> transactions;
  final bool isLoading;
  final CashFilter filter;
  final double openingBalance;

  CashState({
    this.transactions = const [],
    this.isLoading = false,
    this.filter = CashFilter.all,
    this.openingBalance = 0,
  });

  CashState copyWith({
    List<CashTransactionItem>? transactions,
    bool? isLoading,
    CashFilter? filter,
    double? openingBalance,
  }) {
    return CashState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
      openingBalance: openingBalance ?? this.openingBalance,
    );
  }

  List<CashTransactionItem> get filteredTransactions {
    switch (filter) {
      case CashFilter.income:
        return transactions
            .where((t) => t.type == CashTransactionType.income)
            .toList();
      case CashFilter.expense:
        return transactions
            .where((t) => t.type == CashTransactionType.expense)
            .toList();
      case CashFilter.all:
      default:
        return transactions;
    }
  }

  double get totalIncome => transactions
      .where((t) => t.type == CashTransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => transactions
      .where((t) => t.type == CashTransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get currentBalance => openingBalance + totalIncome - totalExpenses;

  double get todaySales {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == CashTransactionType.income &&
            t.category == 'مبيعات' &&
            _isSameDay(t.date, now))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get todayPurchases {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == CashTransactionType.expense &&
            t.category == 'مشتريات' &&
            _isSameDay(t.date, now))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  int get todayTransactionsCount {
    final now = DateTime.now();
    return transactions.where((t) => _isSameDay(t.date, now)).length;
  }

  double get todayNet {
    final now = DateTime.now();
    final todayIncome = transactions
        .where((t) =>
            t.type == CashTransactionType.income && _isSameDay(t.date, now))
        .fold(0.0, (sum, t) => sum + t.amount);
    final todayExpense = transactions
        .where((t) =>
            t.type == CashTransactionType.expense && _isSameDay(t.date, now))
        .fold(0.0, (sum, t) => sum + t.amount);
    return todayIncome - todayExpense;
  }

  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (final t in transactions) {
      if (t.type == CashTransactionType.expense) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  Map<String, double> get incomeByCategory {
    final map = <String, double>{};
    for (final t in transactions) {
      if (t.type == CashTransactionType.income) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// مزود الصندوق
class CashNotifier extends StateNotifier<CashState> {
  final CashDao _dao;

  CashNotifier(this._dao) : super(CashState());

  Future<void> loadCashData() async {
    state = state.copyWith(isLoading: true);

    try {
      final dbTransactions = await _dao.getAllTransactions();
      final transactions = dbTransactions.map(_mapDbTransaction).toList();

      // ترتيب بالتاريخ (الأحدث أولاً)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setFilter(CashFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> addTransaction({
    required CashTransactionType type,
    required String category,
    required double amount,
    String? description,
  }) async {
    try {
      int id;

      if (type == CashTransactionType.income) {
        id = await _dao.insertReceipt(
          amount: amount,
          userId: 1, // TODO: استخدام المستخدم الحالي
          category: category,
          description: description,
        );
      } else {
        id = await _dao.insertPayment(
          amount: amount,
          userId: 1, // TODO: استخدام المستخدم الحالي
          category: category,
          description: description,
        );
      }

      final newTransaction = CashTransactionItem(
        id: id,
        type: type,
        category: category,
        amount: amount,
        description: description,
        date: DateTime.now(),
      );

      state = state.copyWith(
        transactions: [newTransaction, ...state.transactions],
      );
    } catch (e) {
      // معالجة الخطأ
    }
  }

  Future<void> deleteTransaction(int id) async {
    // حذف من القائمة فقط حالياً
    state = state.copyWith(
      transactions: state.transactions.where((t) => t.id != id).toList(),
    );
  }

  CashTransactionItem _mapDbTransaction(CashTransaction t) {
    return CashTransactionItem(
      id: t.id,
      type: t.type == 'receipt'
          ? CashTransactionType.income
          : CashTransactionType.expense,
      category: t.category ?? 'عام',
      amount: t.amount,
      description: t.description,
      date: t.createdAt ?? DateTime.now(),
    );
  }
}

/// مزود الصندوق
final cashProvider = StateNotifierProvider<CashNotifier, CashState>((ref) {
  final dao = GetIt.instance<CashDao>();
  return CashNotifier(dao);
});
