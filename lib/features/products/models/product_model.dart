// lib/features/products/models/product_model.dart
// نموذج المنتج - بدون صور

import 'package:cloud_firestore/cloud_firestore.dart';

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
  final Map<String, int> inventory; // {"أسود-42": 5, "أبيض-43": 3}
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    this.brand = '',
    required this.price,
    required this.costPrice,
    required this.colors,
    required this.sizes,
    required this.inventory,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// إنشاء من Firestore
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      colors: List<String>.from(data['colors'] ?? []),
      sizes: List<int>.from((data['sizes'] ?? []).map((e) => e as int)),
      inventory: Map<String, int>.from(
        (data['inventory'] ?? {}).map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        ),
      ),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// تحويل إلى Map
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
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// نسخة معدلة
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
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// الكمية الإجمالية
  int get totalQuantity => inventory.values.fold(0, (sum, qty) => sum + qty);

  /// هل نفذ المخزون؟
  bool get isOutOfStock => totalQuantity == 0;

  /// هل المخزون منخفض؟ (property not method)
  bool get isLowStock => totalQuantity > 0 && totalQuantity <= 5;

  /// الحصول على كمية محددة
  int getQuantity(String color, int size) {
    final key = inventoryKey(color, size);
    return inventory[key] ?? 0;
  }

  /// مفتاح المخزون
  static String inventoryKey(String color, int size) => '$color-$size';

  /// هامش الربح
  double get profitMargin => price - costPrice;

  /// نسبة الربح
  double get profitPercentage =>
      costPrice > 0 ? ((price - costPrice) / costPrice) * 100 : 0;

  @override
  String toString() => 'ProductModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
