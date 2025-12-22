// lib/features/products/models/product_model.dart
// نموذج المنتج - محسن

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final double price;
  final double costPrice;
  final List<String> colors;
  final List<int> sizes;
  final Map<String, int> inventory;
  final String? imageUrl;
  final String? barcode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int lowStockThreshold;
  final String? sku;
  final Map<String, dynamic>? metadata;

  ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    this.brand = '',
    required this.price,
    required this.costPrice,
    this.colors = const [],
    this.sizes = const [],
    this.inventory = const {},
    this.imageUrl,
    this.barcode,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lowStockThreshold = AppConstants.lowStockThreshold,
    this.sku,
    this.metadata,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap(doc.id, data);
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      colors: List<String>.from(map['colors'] ?? []),
      sizes: List<int>.from(map['sizes'] ?? []),
      inventory: Map<String, int>.from(map['inventory'] ?? {}),
      imageUrl: map['imageUrl'],
      barcode: map['barcode'],
      isActive: map['isActive'] ?? true,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      lowStockThreshold:
          map['lowStockThreshold'] ?? AppConstants.lowStockThreshold,
      sku: map['sku'],
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'price': price,
      'costPrice': costPrice,
      'colors': colors,
      'sizes': sizes,
      'inventory': inventory,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lowStockThreshold': lowStockThreshold,
      'sku': sku,
      'metadata': metadata,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? brand,
    double? price,
    double? costPrice,
    List<String>? colors,
    List<int>? sizes,
    Map<String, int>? inventory,
    String? imageUrl,
    String? barcode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? lowStockThreshold,
    String? sku,
    Map<String, dynamic>? metadata,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      inventory: inventory ?? this.inventory,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      sku: sku ?? this.sku,
      metadata: metadata ?? this.metadata,
    );
  }

  /// إجمالي الكمية في المخزون
  int get totalQuantity {
    return inventory.values.fold(0, (sum, qty) => sum + qty);
  }

  /// الكمية المتاحة للون ومقاس محدد
  int getQuantity(String color, int size) {
    return inventory[inventoryKey(color, size)] ?? 0;
  }

  /// هل المنتج متوفر
  bool get isAvailable => isActive && totalQuantity > 0;

  /// هل المخزون منخفض
  bool isLowStock([int? threshold]) =>
      totalQuantity <= (threshold ?? lowStockThreshold) && totalQuantity > 0;

  /// هل نفذ من المخزون
  bool get isOutOfStock => totalQuantity == 0;

  /// هل المخزون حرج
  bool get isCriticalStock =>
      totalQuantity <= AppConstants.criticalStockThreshold;

  /// هامش الربح
  double get profitMargin => price - costPrice;

  /// نسبة الربح
  double get profitPercentage {
    if (costPrice == 0) return 0;
    return ((price - costPrice) / costPrice) * 100;
  }

  /// قيمة المخزون
  double get stockValue => costPrice * totalQuantity;

  /// قيمة البيع المتوقعة
  double get expectedSalesValue => price * totalQuantity;

  /// مفتاح المخزون
  static String inventoryKey(String color, int size) => '$color-$size';

  /// استخراج اللون والمقاس من المفتاح
  static (String color, int size)? parseInventoryKey(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return null;
    final size = int.tryParse(parts[1]);
    if (size == null) return null;
    return (parts[0], size);
  }

  /// الحصول على الألوان المتوفرة فعلياً
  List<String> get availableColors {
    final available = <String>{};
    for (final entry in inventory.entries) {
      if (entry.value > 0) {
        final parsed = parseInventoryKey(entry.key);
        if (parsed != null) available.add(parsed.$1);
      }
    }
    return available.toList();
  }

  /// الحصول على المقاسات المتوفرة للون معين
  List<int> getAvailableSizes(String color) {
    final available = <int>[];
    for (final size in sizes) {
      if (getQuantity(color, size) > 0) {
        available.add(size);
      }
    }
    return available;
  }

  /// التحقق من توفر كمية معينة
  bool hasQuantity(String color, int size, int quantity) {
    return getQuantity(color, size) >= quantity;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProductModel(id: $id, name: $name, totalQuantity: $totalQuantity)';
}
