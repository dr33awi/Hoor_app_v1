// ═══════════════════════════════════════════════════════════════════════════
// Party Repository - Abstract Base for Customers & Suppliers
// Eliminates code duplication between CustomerRepository and SupplierRepository
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/accounting_exceptions.dart';
import 'base_repository.dart';

/// Abstract Party Repository
/// موحد لإدارة العملاء والموردين
abstract class PartyRepository<T, C> extends BaseRepository<T, C> {
  StreamSubscription? _partyFirestoreSubscription;

  PartyRepository({
    required super.database,
    required super.firestore,
    required super.collectionName,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Abstract Methods - Must be implemented by subclasses
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all parties from database
  Future<List<T>> getAll();

  /// Watch all parties as stream
  Stream<List<T>> watchAll();

  /// Get party by ID
  Future<T?> getById(String id);

  /// Insert party into database
  Future<void> insert(C companion);

  /// Update party in database
  Future<void> update(C companion);

  /// Delete party from database
  Future<void> deleteFromDb(String id);

  /// Get party name from entity
  String getName(T entity);

  /// Get party balance from entity
  double getBalance(T entity);

  /// Get party sync status from entity
  String getSyncStatus(T entity);

  /// Get party created at from entity
  DateTime getCreatedAt(T entity);

  /// Get party updated at from entity
  DateTime getUpdatedAt(T entity);

  /// Get party ID from entity
  String getId(T entity);

  /// Get entity type name for exceptions
  String get entityTypeName;

  /// Create companion for update
  C createUpdateCompanion({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
    required double balance,
    String? notes,
    required bool isActive,
    required String syncStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
  });

  /// Create companion for insert
  C createInsertCompanion({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    required DateTime now,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Shared Implementation
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create a new party
  Future<String> create({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    final id = generateId();
    final now = DateTime.now();

    final companion = createInsertCompanion(
      id: id,
      name: name,
      phone: phone,
      email: email,
      address: address,
      notes: notes,
      now: now,
    );

    await insert(companion);
    return id;
  }

  /// Update balance
  Future<void> updateBalance(String partyId, double amount) async {
    final party = await getById(partyId);
    if (party == null) return;

    final newBalance = getBalance(party) + amount;

    final companion = createUpdateCompanion(
      id: partyId,
      name: getName(party),
      balance: newBalance,
      isActive: true,
      syncStatus: 'pending',
      createdAt: getCreatedAt(party),
      updatedAt: DateTime.now(),
    );

    await update(companion);
  }

  /// Delete party (prevents deletion if balance is not zero)
  Future<void> delete(String id) async {
    final party = await getById(id);
    if (party != null && getBalance(party) != 0) {
      throw NonZeroBalanceException(
        entityType: entityTypeName,
        entityId: id,
        entityName: getName(party),
        balance: getBalance(party),
      );
    }

    await deleteFromDb(id);

    // Delete from Cloud
    try {
      await collection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting $entityTypeName from cloud: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Cloud Sync Implementation
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> syncPendingChanges() async {
    final allParties = await getAll();
    final pending =
        allParties.where((p) => getSyncStatus(p) == 'pending').toList();

    for (final party in pending) {
      try {
        await collection.doc(getId(party)).set(toFirestore(party));

        final companion = createUpdateCompanion(
          id: getId(party),
          name: getName(party),
          balance: getBalance(party),
          isActive: true,
          syncStatus: 'synced',
          createdAt: getCreatedAt(party),
          updatedAt: getUpdatedAt(party),
        );

        await update(companion);
      } catch (e) {
        debugPrint('Error syncing $entityTypeName ${getId(party)}: $e');
      }
    }
  }

  @override
  Future<void> pullFromCloud() async {
    try {
      final snapshot = await collection.get();

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final companion = fromFirestore(data, doc.id);

        final existing = await getById(doc.id);
        if (existing == null) {
          await insert(companion);
        } else if (getSyncStatus(existing) == 'synced') {
          final cloudUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
          if (cloudUpdatedAt.isAfter(getUpdatedAt(existing))) {
            await update(companion);
          }
        }
      }
    } catch (e) {
      debugPrint('Error pulling ${entityTypeName}s from cloud: $e');
    }
  }

  @override
  void startRealtimeSync() {
    _partyFirestoreSubscription?.cancel();
    _partyFirestoreSubscription = collection.snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        _handleFirestoreChange(change);
      }
    });
  }

  @override
  void stopRealtimeSync() {
    _partyFirestoreSubscription?.cancel();
    _partyFirestoreSubscription = null;
  }

  Future<void> _handleFirestoreChange(DocumentChange change) async {
    final id = change.doc.id;
    final data = change.doc.data() as Map<String, dynamic>?;

    if (data == null) return;

    switch (change.type) {
      case DocumentChangeType.added:
      case DocumentChangeType.modified:
        final existing = await getById(id);
        final companion = fromFirestore(data, id);

        if (existing == null) {
          await insert(companion);
        } else if (getSyncStatus(existing) == 'synced') {
          await update(companion);
        }
        break;
      case DocumentChangeType.removed:
        await deleteFromDb(id);
        break;
    }
  }
}
