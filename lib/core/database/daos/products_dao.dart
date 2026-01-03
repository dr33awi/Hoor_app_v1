import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/products_table.dart';
import '../tables/categories_table.dart';
import '../tables/inventory_table.dart';
import '../tables/warehouses_table.dart';

part 'products_dao.g.dart';

/// نموذج المنتج مع بيانات إضافية
class ProductWithDetails {
  final Product product;
  final Category? category;
  final double totalStock;

  ProductWithDetails({
    required this.product,
    this.category,
    this.totalStock = 0,
  });
}

@DriftAccessor(tables: [Products, Categories, Inventory, Warehouses])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.db);

  // الحصول على جميع المنتجات
  Future<List<Product>> getAllProducts() {
    return (select(products)
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .get();
  }

  // الحصول على المنتجات النشطة
  Future<List<Product>> getActiveProducts() {
    return (select(products)
          ..where((p) => p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .get();
  }

  // الحصول على منتج بواسطة المعرف
  Future<Product?> getProductById(int id) {
    return (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  // الحصول على منتج بواسطة الباركود
  Future<Product?> getProductByBarcode(String barcode) {
    return (select(products)..where((p) => p.barcode.equals(barcode)))
        .getSingleOrNull();
  }

  // الحصول على منتجات حسب الفئة
  Future<List<Product>> getProductsByCategory(int categoryId) {
    return (select(products)
          ..where(
              (p) => p.categoryId.equals(categoryId) & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .get();
  }

  // البحث عن منتجات
  Future<List<Product>> searchProducts(String query) {
    return (select(products)
          ..where((p) =>
              (p.name.like('%$query%') |
                  p.barcode.like('%$query%') |
                  p.sku.like('%$query%')) &
              p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .get();
  }

  // إضافة منتج جديد
  Future<int> insertProduct(ProductsCompanion product) {
    return into(products).insert(product);
  }

  // تحديث منتج
  Future<bool> updateProduct(Product product) {
    return update(products).replace(product);
  }

  // تحديث منتج جزئياً
  Future<int> updateProductPartial(int id, ProductsCompanion companion) {
    return (update(products)..where((p) => p.id.equals(id))).write(companion);
  }

  // تحديث سعر المنتج
  Future<int> updateProductPrice(int id, double newPrice) {
    return (update(products)..where((p) => p.id.equals(id))).write(
        ProductsCompanion(
            salePrice: Value(newPrice), updatedAt: Value(DateTime.now())));
  }

  // تعطيل/تفعيل منتج
  Future<int> toggleProductStatus(int id, bool isActive) {
    return (update(products)..where((p) => p.id.equals(id))).write(
        ProductsCompanion(
            isActive: Value(isActive), updatedAt: Value(DateTime.now())));
  }

  // حذف منتج
  Future<int> deleteProduct(int id) {
    return (delete(products)..where((p) => p.id.equals(id))).go();
  }

  // الحصول على المنتجات مع المخزون المنخفض
  Future<List<Product>> getLowStockProducts() async {
    final query = select(products).join([
      leftOuterJoin(inventory, inventory.productId.equalsExp(products.id)),
    ])
      ..where(
          products.isActive.equals(true) & products.trackInventory.equals(true))
      ..groupBy([products.id]);

    final results = await query.get();
    final lowStockProducts = <Product>[];

    for (final row in results) {
      final product = row.readTable(products);
      final inv = row.readTableOrNull(inventory);
      final stock = inv?.quantity ?? 0;

      if (stock <= product.lowStockAlert) {
        lowStockProducts.add(product);
      }
    }

    return lowStockProducts;
  }

  // الحصول على إجمالي مخزون منتج
  Future<double> getProductTotalStock(int productId) async {
    final query = select(inventory)
      ..where((i) => i.productId.equals(productId));
    final results = await query.get();
    return results.fold<double>(0.0, (sum, inv) => sum + inv.quantity);
  }

  // مراقبة المنتجات
  Stream<List<Product>> watchActiveProducts() {
    return (select(products)
          ..where((p) => p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .watch();
  }

  // مراقبة منتجات فئة معينة
  Stream<List<Product>> watchProductsByCategory(int categoryId) {
    return (select(products)
          ..where(
              (p) => p.categoryId.equals(categoryId) & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .watch();
  }

  // التحقق من وجود باركود
  Future<bool> isBarcodeExists(String barcode, {int? excludeProductId}) async {
    var query = select(products)..where((p) => p.barcode.equals(barcode));
    if (excludeProductId != null) {
      query = query..where((p) => p.id.equals(excludeProductId).not());
    }
    final result = await query.getSingleOrNull();
    return result != null;
  }

  // الحصول على عدد المنتجات
  Future<int> getProductsCount() async {
    final query = selectOnly(products)..addColumns([products.id.count()]);
    final result = await query.getSingle();
    return result.read(products.id.count()) ?? 0;
  }
}
