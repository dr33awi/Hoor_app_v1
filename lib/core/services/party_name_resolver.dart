// ═══════════════════════════════════════════════════════════════════════════
// Party Name Resolver Service - توحيد جلب أسماء الأطراف
// Replaces duplicated party name fetching logic
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../providers/app_providers.dart';

/// خدمة جلب أسماء العملاء والموردين
class PartyNameResolver {
  final Ref ref;

  // Cache للأسماء لتجنب الاستعلامات المتكررة
  final Map<String, String> _customerCache = {};
  final Map<String, String> _supplierCache = {};

  PartyNameResolver(this.ref);

  /// جلب اسم العميل
  Future<String> getCustomerName(String? customerId) async {
    if (customerId == null || customerId.isEmpty) return 'عميل نقدي';

    // تحقق من الـ cache
    if (_customerCache.containsKey(customerId)) {
      return _customerCache[customerId]!;
    }

    try {
      final customerRepo = ref.read(customerRepositoryProvider);
      final customer = await customerRepo.getCustomerById(customerId);
      final name = customer?.name ?? 'غير محدد';
      _customerCache[customerId] = name;
      return name;
    } catch (_) {
      return 'غير محدد';
    }
  }

  /// جلب اسم المورد
  Future<String> getSupplierName(String? supplierId) async {
    if (supplierId == null || supplierId.isEmpty) return 'غير محدد';

    // تحقق من الـ cache
    if (_supplierCache.containsKey(supplierId)) {
      return _supplierCache[supplierId]!;
    }

    try {
      final supplierRepo = ref.read(supplierRepositoryProvider);
      final supplier = await supplierRepo.getSupplierById(supplierId);
      final name = supplier?.name ?? 'غير محدد';
      _supplierCache[supplierId] = name;
      return name;
    } catch (_) {
      return 'غير محدد';
    }
  }

  /// جلب اسم الطرف حسب نوع الفاتورة
  Future<String> getPartyName(Invoice invoice) async {
    if (invoice.type == 'sale' || invoice.type == 'sale_return') {
      return getCustomerName(invoice.customerId);
    } else {
      return getSupplierName(invoice.supplierId);
    }
  }

  /// جلب أسماء أطراف متعددة (للقوائم)
  Future<Map<String, String>> getPartyNames(List<Invoice> invoices) async {
    final Map<String, String> names = {};

    for (final invoice in invoices) {
      final key = invoice.id;
      names[key] = await getPartyName(invoice);
    }

    return names;
  }

  /// مسح الـ cache
  void clearCache() {
    _customerCache.clear();
    _supplierCache.clear();
  }
}

/// Provider للـ PartyNameResolver
final partyNameResolverProvider =
    Provider.autoDispose<PartyNameResolver>((ref) {
  return PartyNameResolver(ref);
});
