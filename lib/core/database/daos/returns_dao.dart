import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/returns_table.dart';
import '../tables/return_items_table.dart';
import '../tables/customers_table.dart';
import '../tables/products_table.dart';

part 'returns_dao.g.dart';

/// نموذج المرتجع مع التفاصيل
class ReturnWithDetails {
  final Return returnData;
  final Customer? customer;
  final List<ReturnItemWithProduct> items;

  ReturnWithDetails({
    required this.returnData,
    this.customer,
    this.items = const [],
  });
}

class ReturnItemWithProduct {
  final ReturnItem item;
  final Product? product;

  ReturnItemWithProduct({required this.item, this.product});
}

@DriftAccessor(tables: [Returns, ReturnItems, Customers, Products])
class ReturnsDao extends DatabaseAccessor<AppDatabase> with _$ReturnsDaoMixin {
  ReturnsDao(super.db);

  // توليد رقم مرتجع جديد
  Future<String> generateReturnNumber(String type) async {
    final prefix = type == 'sale_return' ? 'SRT' : 'PRT';
    final today = DateTime.now();
    final dateStr =
        '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    final query = selectOnly(returns)
      ..where(returns.returnNumber.like('$prefix-$dateStr%'))
      ..addColumns([returns.returnNumber.count()]);
    final result = await query.getSingle();
    final count = (result.read(returns.returnNumber.count()) ?? 0) + 1;

    return '$prefix-$dateStr-${count.toString().padLeft(4, '0')}';
  }

  // الحصول على جميع المرتجعات
  Future<List<Return>> getAllReturns() {
    return (select(returns)
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على المرتجعات حسب النوع
  Future<List<Return>> getReturnsByType(String type) {
    return (select(returns)
          ..where((r) => r.type.equals(type))
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على مرتجع بواسطة المعرف
  Future<Return?> getReturnById(int id) {
    return (select(returns)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  // الحصول على مرتجع مع التفاصيل
  Future<ReturnWithDetails?> getReturnWithDetails(int id) async {
    final returnData = await getReturnById(id);
    if (returnData == null) return null;

    Customer? customer;
    if (returnData.customerId != null) {
      customer = await (select(customers)
            ..where((c) => c.id.equals(returnData.customerId!)))
          .getSingleOrNull();
    }

    final items = await getReturnItems(id);

    return ReturnWithDetails(
      returnData: returnData,
      customer: customer,
      items: items,
    );
  }

  // الحصول على بنود المرتجع
  Future<List<ReturnItemWithProduct>> getReturnItems(int returnId) async {
    final query = select(returnItems).join([
      leftOuterJoin(products, products.id.equalsExp(returnItems.productId)),
    ])
      ..where(returnItems.returnId.equals(returnId));

    final results = await query.get();
    return results.map((row) {
      return ReturnItemWithProduct(
        item: row.readTable(returnItems),
        product: row.readTableOrNull(products),
      );
    }).toList();
  }

  // إضافة مرتجع جديد
  Future<int> insertReturn(ReturnsCompanion returnData) {
    return into(returns).insert(returnData);
  }

  // إضافة بند مرتجع
  Future<int> insertReturnItem(ReturnItemsCompanion item) {
    return into(returnItems).insert(item);
  }

  // إضافة مرتجع كامل مع بنوده
  Future<int> insertReturnWithItems(
      ReturnsCompanion returnData, List<ReturnItemsCompanion> items) async {
    return await transaction(() async {
      final returnId = await into(returns).insert(returnData);
      for (final item in items) {
        await into(returnItems)
            .insert(item.copyWith(returnId: Value(returnId)));
      }
      return returnId;
    });
  }

  // الحصول على مرتجعات فترة معينة
  Future<List<Return>> getReturnsByDateRange(DateTime start, DateTime end) {
    return (select(returns)
          ..where((r) => r.returnDate.isBetweenValues(start, end))
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // الحصول على مرتجعات عميل
  Future<List<Return>> getCustomerReturns(int customerId) {
    return (select(returns)
          ..where((r) => r.customerId.equals(customerId))
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // إحصائيات المرتجعات
  Future<double> getTotalReturns(
      String type, DateTime start, DateTime end) async {
    final query = selectOnly(returns)
      ..where(returns.type.equals(type) &
          returns.returnDate.isBetweenValues(start, end))
      ..addColumns([returns.total.sum()]);
    final result = await query.getSingle();
    return result.read(returns.total.sum()) ?? 0;
  }

  Future<int> getReturnsCount(String type, DateTime start, DateTime end) async {
    final query = selectOnly(returns)
      ..where(returns.type.equals(type) &
          returns.returnDate.isBetweenValues(start, end))
      ..addColumns([returns.id.count()]);
    final result = await query.getSingle();
    return result.read(returns.id.count()) ?? 0;
  }

  // مراقبة المرتجعات
  Stream<List<Return>> watchReturns() {
    return (select(returns)
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }
}
