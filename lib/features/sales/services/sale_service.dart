// lib/features/sales/services/sale_service.dart
// خدمة المبيعات

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/base_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/auth_service.dart';
import '../../products/services/product_service.dart';
import '../models/sale_model.dart';

class SaleService extends BaseService {
  final FirebaseService _firebase = FirebaseService();
  final AuthService _auth = AuthService();
  final ProductService _productService = ProductService();
  final String _collection = AppConstants.salesCollection;

  // Singleton
  static final SaleService _instance = SaleService._internal();
  factory SaleService() => _instance;
  SaleService._internal();

  /// إنشاء فاتورة جديدة
  Future<ServiceResult<SaleModel>> createSale(SaleModel sale) async {
    try {
      // توليد ID ورقم الفاتورة
      final id = const Uuid().v4();
      final invoiceNumber = await _generateInvoiceNumber();

      final newSale = sale.copyWith(
        id: id,
        invoiceNumber: invoiceNumber,
        userId: _auth.currentUserId ?? '',
        userName: _auth.currentUser?.name ?? '',
        createdAt: DateTime.now(),
      );

      // استخدام Transaction لضمان الاتساق
      final result = await _firebase.runTransaction((transaction) async {
        // 1. تقليل المخزون لكل عنصر
        for (final item in newSale.items) {
          final productRef = _firebase.document(
            AppConstants.productsCollection,
            item.productId,
          );

          final productSnapshot = await transaction.get(productRef);
          if (!productSnapshot.exists) {
            throw Exception('المنتج ${item.productName} غير موجود');
          }

          final productData = productSnapshot.data()!;
          final inventoryKey = '${item.color}-${item.size}';
          final currentQty =
              (productData['inventory']
                  as Map<String, dynamic>?)?[inventoryKey] ??
              0;

          if (currentQty < item.quantity) {
            throw Exception(
              'الكمية غير كافية للمنتج ${item.productName} (${item.color} - ${item.size})',
            );
          }

          transaction.update(productRef, {
            'inventory.$inventoryKey': currentQty - item.quantity,
            'updatedAt': DateTime.now(),
          });
        }

        // 2. حفظ الفاتورة
        final saleRef = _firebase.document(_collection, id);
        transaction.set(saleRef, newSale.toMap());
      });

      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      return ServiceResult.success(newSale);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تحديث حالة الفاتورة
  Future<ServiceResult<void>> updateSaleStatus(
    String saleId,
    String newStatus,
  ) async {
    try {
      return await _firebase.update(_collection, saleId, {'status': newStatus});
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// إلغاء فاتورة (مع إرجاع المخزون)
  Future<ServiceResult<void>> cancelSale(String saleId) async {
    try {
      final result = await _firebase.runTransaction((transaction) async {
        // جلب الفاتورة
        final saleRef = _firebase.document(_collection, saleId);
        final saleSnapshot = await transaction.get(saleRef);

        if (!saleSnapshot.exists) {
          throw Exception('الفاتورة غير موجودة');
        }

        final sale = SaleModel.fromFirestore(saleSnapshot);

        if (sale.isCancelled) {
          throw Exception('الفاتورة ملغية بالفعل');
        }

        // إرجاع المخزون
        for (final item in sale.items) {
          final productRef = _firebase.document(
            AppConstants.productsCollection,
            item.productId,
          );

          final productSnapshot = await transaction.get(productRef);
          if (productSnapshot.exists) {
            final productData = productSnapshot.data()!;
            final inventoryKey = '${item.color}-${item.size}';
            final currentQty =
                (productData['inventory']
                    as Map<String, dynamic>?)?[inventoryKey] ??
                0;

            transaction.update(productRef, {
              'inventory.$inventoryKey': currentQty + item.quantity,
              'updatedAt': DateTime.now(),
            });
          }
        }

        // تحديث حالة الفاتورة
        transaction.update(saleRef, {
          'status': AppConstants.saleStatusCancelled,
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

  /// الحصول على فاتورة واحدة
  Future<ServiceResult<SaleModel>> getSale(String saleId) async {
    try {
      final result = await _firebase.get(_collection, saleId);
      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      return ServiceResult.success(SaleModel.fromFirestore(result.data!));
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// الحصول على جميع المبيعات
  Future<ServiceResult<List<SaleModel>>> getAllSales({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int? limit,
  }) async {
    try {
      final result = await _firebase.getAll(
        _collection,
        queryBuilder: (ref) {
          Query<Map<String, dynamic>> query = ref.orderBy(
            'saleDate',
            descending: true,
          );

          if (startDate != null) {
            query = query.where(
              'saleDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            );
          }

          if (endDate != null) {
            query = query.where(
              'saleDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate),
            );
          }

          if (status != null) {
            query = query.where('status', isEqualTo: status);
          }

          if (limit != null) {
            query = query.limit(limit);
          }

          return query;
        },
      );

      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      final sales = result.data!.docs
          .map((doc) => SaleModel.fromFirestore(doc))
          .toList();

      return ServiceResult.success(sales);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// Stream للمبيعات
  Stream<List<SaleModel>> streamSales({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _firebase
        .streamCollection(
          _collection,
          queryBuilder: (ref) {
            Query<Map<String, dynamic>> query = ref.orderBy(
              'saleDate',
              descending: true,
            );

            if (startDate != null) {
              query = query.where(
                'saleDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              );
            }

            if (endDate != null) {
              query = query.where(
                'saleDate',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              );
            }

            return query;
          },
        )
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => SaleModel.fromFirestore(doc)).toList(),
        );
  }

  /// مبيعات اليوم
  Future<ServiceResult<List<SaleModel>>> getTodaySales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getAllSales(
      startDate: startOfDay,
      endDate: endOfDay,
      status: AppConstants.saleStatusCompleted,
    );
  }

  /// مبيعات الشهر الحالي
  Future<ServiceResult<List<SaleModel>>> getMonthSales() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getAllSales(
      startDate: startOfMonth,
      endDate: endOfMonth,
      status: AppConstants.saleStatusCompleted,
    );
  }

  /// البحث في المبيعات
  Future<ServiceResult<List<SaleModel>>> searchSales(String query) async {
    try {
      final result = await getAllSales();
      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      final lowerQuery = query.toLowerCase();
      final filtered = result.data!.where((sale) {
        return sale.invoiceNumber.toLowerCase().contains(lowerQuery) ||
            (sale.buyerName?.toLowerCase().contains(lowerQuery) ?? false) ||
            (sale.buyerPhone?.contains(query) ?? false);
      }).toList();

      return ServiceResult.success(filtered);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تقرير المبيعات
  Future<ServiceResult<SalesReport>> getSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await getAllSales(
        startDate: startDate,
        endDate: endDate,
        status: AppConstants.saleStatusCompleted,
      );

      if (!result.success) {
        return ServiceResult.failure(result.error!);
      }

      final sales = result.data!;
      final report = SalesReport.fromSales(sales);

      return ServiceResult.success(report);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// توليد رقم فاتورة جديد
  Future<String> _generateInvoiceNumber() async {
    final now = DateTime.now();
    final prefix = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}';

    try {
      final result = await _firebase.getAll(
        _collection,
        queryBuilder: (ref) =>
            ref.orderBy('createdAt', descending: true).limit(1),
      );

      if (!result.success || result.data!.docs.isEmpty) {
        return '$prefix-0001';
      }

      final lastSale = SaleModel.fromFirestore(result.data!.docs.first);
      final lastNumber = lastSale.invoiceNumber.split('-').last;
      final nextNumber = int.parse(lastNumber) + 1;

      return '$prefix-${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      return '$prefix-${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}

/// تقرير المبيعات
class SalesReport {
  final int totalOrders;
  final int totalItems;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double totalDiscount;
  final double totalTax;
  final double averageOrderValue;
  final Map<String, int> topProducts;
  final Map<String, double> salesByPaymentMethod;

  SalesReport({
    required this.totalOrders,
    required this.totalItems,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.totalDiscount,
    required this.totalTax,
    required this.averageOrderValue,
    required this.topProducts,
    required this.salesByPaymentMethod,
  });

  factory SalesReport.fromSales(List<SaleModel> sales) {
    if (sales.isEmpty) {
      return SalesReport(
        totalOrders: 0,
        totalItems: 0,
        totalRevenue: 0,
        totalCost: 0,
        totalProfit: 0,
        totalDiscount: 0,
        totalTax: 0,
        averageOrderValue: 0,
        topProducts: {},
        salesByPaymentMethod: {},
      );
    }

    int totalItems = 0;
    double totalRevenue = 0;
    double totalCost = 0;
    double totalDiscount = 0;
    double totalTax = 0;
    Map<String, int> productCount = {};
    Map<String, double> paymentMethods = {};

    for (final sale in sales) {
      totalItems += sale.itemsCount;
      totalRevenue += sale.total;
      totalCost += sale.totalCost;
      totalDiscount += sale.discount;
      totalTax += sale.tax;

      // حساب المنتجات الأكثر مبيعاً
      for (final item in sale.items) {
        productCount[item.productName] =
            (productCount[item.productName] ?? 0) + item.quantity;
      }

      // حساب المبيعات حسب طريقة الدفع
      paymentMethods[sale.paymentMethod] =
          (paymentMethods[sale.paymentMethod] ?? 0) + sale.total;
    }

    // ترتيب المنتجات الأكثر مبيعاً
    final sortedProducts = productCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProducts = Map.fromEntries(sortedProducts.take(10));

    return SalesReport(
      totalOrders: sales.length,
      totalItems: totalItems,
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      totalProfit: totalRevenue - totalCost,
      totalDiscount: totalDiscount,
      totalTax: totalTax,
      averageOrderValue: totalRevenue / sales.length,
      topProducts: topProducts,
      salesByPaymentMethod: paymentMethods,
    );
  }
}
