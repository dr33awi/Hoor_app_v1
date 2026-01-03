import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  // الحصول على جميع الفئات
  Future<List<Category>> getAllCategories() {
    return (select(categories)
          ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
        .get();
  }

  // الحصول على الفئات النشطة
  Future<List<Category>> getActiveCategories() {
    return (select(categories)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
        .get();
  }

  // الحصول على الفئات الرئيسية (بدون أب)
  Future<List<Category>> getRootCategories() {
    return (select(categories)
          ..where((c) => c.parentId.isNull() & c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
        .get();
  }

  // الحصول على الفئات الفرعية
  Future<List<Category>> getSubCategories(int parentId) {
    return (select(categories)
          ..where((c) => c.parentId.equals(parentId) & c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
        .get();
  }

  // الحصول على فئة بواسطة المعرف
  Future<Category?> getCategoryById(int id) {
    return (select(categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  // إضافة فئة جديدة
  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  // تحديث فئة
  Future<bool> updateCategory(Category category) {
    return update(categories).replace(category);
  }

  // تحديث ترتيب الفئات
  Future<void> updateCategoriesOrder(List<int> categoryIds) async {
    await transaction(() async {
      for (var i = 0; i < categoryIds.length; i++) {
        await (update(categories)..where((c) => c.id.equals(categoryIds[i])))
            .write(CategoriesCompanion(sortOrder: Value(i)));
      }
    });
  }

  // تعطيل/تفعيل فئة
  Future<int> toggleCategoryStatus(int id, bool isActive) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
            isActive: Value(isActive), updatedAt: Value(DateTime.now())));
  }

  // حذف فئة
  Future<int> deleteCategory(int id) {
    return (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  // البحث عن فئات
  Future<List<Category>> searchCategories(String query) {
    return (select(categories)..where((c) => c.name.like('%$query%'))).get();
  }

  // مراقبة الفئات
  Stream<List<Category>> watchActiveCategories() {
    return (select(categories)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
        .watch();
  }
}
