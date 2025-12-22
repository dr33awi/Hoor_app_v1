// lib/features/products/services/product_service.dart
// خدمة المنتجات

import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/base_service.dart';
import '../../../core/services/firebase_service.dart';
import '../models/product_model.dart';

class ProductService extends BaseService {
  final FirebaseService _firebase = FirebaseService();
  final String _collection = AppConstants.productsCollection;

  // Singleton
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  /// إضافة منتج جديد
  Future<ServiceResult<ProductModel>> addProduct(ProductModel product) async {
    try {
      final id = const Uuid().v4();
      final newProduct = product.copyWith(
        id: id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _firebase.set(_collection, id, newProduct.toMap());
      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      return ServiceResult.success(newProduct);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تحديث منتج
  Future<ServiceResult<void>> updateProduct(ProductModel product) async {
    try {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      return await _firebase.update(
        _collection,
        product.id,
        updatedProduct.toMap(),
      );
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// حذف منتج (حذف منطقي)
  Future<ServiceResult<void>> deleteProduct(String productId) async {
    try {
      return await _firebase.update(_collection, productId, {
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// حذف منتج نهائياً
  Future<ServiceResult<void>> permanentDelete(String productId) async {
    try {
      return await _firebase.delete(_collection, productId);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// الحصول على منتج واحد
  Future<ServiceResult<ProductModel>> getProduct(String productId) async {
    try {
      final result = await _firebase.get(_collection, productId);
      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      return ServiceResult.success(ProductModel.fromFirestore(result.data!));
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// الحصول على جميع المنتجات
  Future<ServiceResult<List<ProductModel>>> getAllProducts({
    bool activeOnly = true,
  }) async {
    try {
      final result = await _firebase.getAll(
        _collection,
        queryBuilder: (ref) {
          var query = ref.orderBy('createdAt', descending: true);
          if (activeOnly) {
            query = query.where('isActive', isEqualTo: true);
          }
          return query;
        },
      );

      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      final products = result.data!.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      return ServiceResult.success(products);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// Stream للمنتجات
  Stream<List<ProductModel>> streamProducts({bool activeOnly = true}) {
    return _firebase
        .streamCollection(
          _collection,
          queryBuilder: (ref) {
            var query = ref.orderBy('createdAt', descending: true);
            if (activeOnly) {
              query = query.where('isActive', isEqualTo: true);
            }
            return query;
          },
        )
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// البحث عن منتجات
  Future<ServiceResult<List<ProductModel>>> searchProducts(String query) async {
    try {
      // Firebase لا يدعم البحث النصي الكامل، لذلك نجلب الكل ونفلتر
      final result = await getAllProducts();
      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      final lowerQuery = query.toLowerCase();
      final filtered = result.data!.where((product) {
        return product.name.toLowerCase().contains(lowerQuery) ||
            product.brand.toLowerCase().contains(lowerQuery) ||
            product.category.toLowerCase().contains(lowerQuery);
      }).toList();

      return ServiceResult.success(filtered);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// الحصول على منتجات حسب الفئة
  Future<ServiceResult<List<ProductModel>>> getProductsByCategory(
    String category,
  ) async {
    try {
      final result = await _firebase.getAll(
        _collection,
        queryBuilder: (ref) => ref
            .where('category', isEqualTo: category)
            .where('isActive', isEqualTo: true)
            .orderBy('name'),
      );

      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      final products = result.data!.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      return ServiceResult.success(products);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// الحصول على المنتجات منخفضة المخزون
  Future<ServiceResult<List<ProductModel>>> getLowStockProducts([
    int threshold = AppConstants.lowStockThreshold,
  ]) async {
    try {
      final result = await getAllProducts();
      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      final lowStock = result.data!
          .where((product) => product.totalQuantity <= threshold)
          .toList();

      return ServiceResult.success(lowStock);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تحديث المخزون
  Future<ServiceResult<void>> updateInventory(
    String productId,
    String color,
    int size,
    int quantity,
  ) async {
    try {
      final key = ProductModel.inventoryKey(color, size);
      return await _firebase.update(_collection, productId, {
        'inventory.$key': quantity,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تقليل المخزون (بعد البيع)
  Future<ServiceResult<void>> decreaseInventory(
    String productId,
    String color,
    int size,
    int quantity,
  ) async {
    try {
      // استخدام Transaction لضمان الاتساق
      final result = await _firebase.runTransaction((transaction) async {
        final docRef = _firebase.document(_collection, productId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('المنتج غير موجود');
        }

        final product = ProductModel.fromFirestore(snapshot);
        final currentQty = product.getQuantity(color, size);

        if (currentQty < quantity) {
          throw Exception('الكمية المتوفرة غير كافية');
        }

        final key = ProductModel.inventoryKey(color, size);
        transaction.update(docRef, {
          'inventory.$key': currentQty - quantity,
          'updatedAt': DateTime.now(),
        });
      });

      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// زيادة المخزون (إرجاع أو استلام)
  Future<ServiceResult<void>> increaseInventory(
    String productId,
    String color,
    int size,
    int quantity,
  ) async {
    try {
      final result = await _firebase.runTransaction((transaction) async {
        final docRef = _firebase.document(_collection, productId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('المنتج غير موجود');
        }

        final product = ProductModel.fromFirestore(snapshot);
        final currentQty = product.getQuantity(color, size);
        final key = ProductModel.inventoryKey(color, size);

        transaction.update(docRef, {
          'inventory.$key': currentQty + quantity,
          'updatedAt': DateTime.now(),
        });
      });

      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// رفع صورة المنتج
  Future<ServiceResult<String>> uploadProductImage(
    String productId,
    File imageFile,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final path =
          '${AppConstants.productsImagesPath}/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await _firebase.uploadFile(path, bytes, 'image/jpeg');
      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      // تحديث رابط الصورة في المنتج
      await _firebase.update(_collection, productId, {
        'imageUrl': result.data,
        'updatedAt': DateTime.now(),
      });

      return result;
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// رفع صورة من Bytes
  Future<ServiceResult<String>> uploadProductImageBytes(
    String productId,
    Uint8List bytes,
  ) async {
    try {
      final path =
          '${AppConstants.productsImagesPath}/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await _firebase.uploadFile(path, bytes, 'image/jpeg');
      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      // تحديث رابط الصورة في المنتج
      await _firebase.update(_collection, productId, {
        'imageUrl': result.data,
        'updatedAt': DateTime.now(),
      });

      return result;
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }
}
