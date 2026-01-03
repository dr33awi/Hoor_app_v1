import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/daos/suppliers_dao.dart';
import '../../../../core/database/database.dart';

/// عنصر مورد
class SupplierItem {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final double balance;

  SupplierItem({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    required this.balance,
  });
}

/// حالة الموردين
class SuppliersState {
  final bool isLoading;
  final List<SupplierItem> suppliers;
  final String searchQuery;

  const SuppliersState({
    this.isLoading = false,
    this.suppliers = const [],
    this.searchQuery = '',
  });

  List<SupplierItem> get filteredSuppliers {
    if (searchQuery.isEmpty) return suppliers;

    return suppliers.where((s) {
      return s.name.contains(searchQuery) ||
          (s.phone?.contains(searchQuery) ?? false) ||
          (s.email?.contains(searchQuery) ?? false);
    }).toList();
  }

  double get totalDue {
    return suppliers.fold(0, (sum, s) => sum + (s.balance > 0 ? s.balance : 0));
  }

  SuppliersState copyWith({
    bool? isLoading,
    List<SupplierItem>? suppliers,
    String? searchQuery,
  }) {
    return SuppliersState(
      isLoading: isLoading ?? this.isLoading,
      suppliers: suppliers ?? this.suppliers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// مدير الموردين
class SuppliersNotifier extends StateNotifier<SuppliersState> {
  final SuppliersDao _supplierDao;

  SuppliersNotifier(this._supplierDao) : super(const SuppliersState());

  Future<void> loadSuppliers() async {
    state = state.copyWith(isLoading: true);

    try {
      final suppliers = await _supplierDao.getAllSuppliers();
      final items = suppliers
          .map((s) => SupplierItem(
                id: s.id,
                name: s.name,
                phone: s.phone,
                email: s.email,
                address: s.address,
                notes: s.notes,
                balance: s.balance,
              ))
          .toList();

      state = state.copyWith(
        suppliers: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> addSupplier({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    try {
      await _supplierDao.insertSupplier(
        SuppliersCompanion.insert(
          name: name,
          phone: Value(phone?.isNotEmpty == true ? phone : null),
          email: Value(email?.isNotEmpty == true ? email : null),
          address: Value(address?.isNotEmpty == true ? address : null),
          notes: Value(notes?.isNotEmpty == true ? notes : null),
          balance: const Value(0),
        ),
      );

      await loadSuppliers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSupplier({
    required int id,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    try {
      final existing = await _supplierDao.getSupplierById(id);
      if (existing != null) {
        await _supplierDao.updateSupplier(
          existing.copyWith(
            name: name,
            phone: Value(phone?.isNotEmpty == true ? phone : null),
            email: Value(email?.isNotEmpty == true ? email : null),
            address: Value(address?.isNotEmpty == true ? address : null),
            notes: Value(notes?.isNotEmpty == true ? notes : null),
          ),
        );
        await loadSuppliers();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await _supplierDao.deleteSupplier(id);
      await loadSuppliers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPayment({
    required int supplierId,
    required double amount,
    String? note,
  }) async {
    try {
      final supplier = await _supplierDao.getSupplierById(supplierId);
      if (supplier != null) {
        final newBalance = supplier.balance - amount;
        await _supplierDao.updateSupplier(
          supplier.copyWith(balance: newBalance),
        );

        // TODO: تسجيل الدفعة في جدول المعاملات المالية

        await loadSuppliers();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPurchase({
    required int supplierId,
    required double amount,
    String? note,
  }) async {
    try {
      final supplier = await _supplierDao.getSupplierById(supplierId);
      if (supplier != null) {
        // إضافة للرصيد المستحق
        final newBalance = supplier.balance + amount;

        await _supplierDao.updateSupplier(
          supplier.copyWith(
            balance: newBalance,
          ),
        );

        // TODO: تسجيل عملية الشراء في جدول المشتريات

        await loadSuppliers();
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// مزود الموردين
final suppliersProvider =
    StateNotifierProvider<SuppliersNotifier, SuppliersState>((ref) {
  final supplierDao = GetIt.instance<SuppliersDao>();
  return SuppliersNotifier(supplierDao);
});

/// مزود قائمة الموردين للاختيار
final supplierListProvider = FutureProvider<List<SupplierItem>>((ref) async {
  final supplierDao = GetIt.instance<SuppliersDao>();

  final suppliers = await supplierDao.getAllSuppliers();

  return suppliers
      .map((s) => SupplierItem(
            id: s.id,
            name: s.name,
            phone: s.phone,
            balance: s.balance,
          ))
      .toList();
});
