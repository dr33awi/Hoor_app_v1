// lib/features/products/models/product_model.dart
// نموذج المنتج

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
  final Map<String, int> inventory; // "اللون-المقاس": الكمية
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
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
      sizes: List<int>.from(data['sizes'] ?? []),
      inventory: Map<String, int>.from(data['inventory'] ?? {}),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// تحويل إلى Map للحفظ
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
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// إجمالي الكمية في المخزون
  int get totalQuantity {
    return inventory.values.fold(0, (sum, qty) => sum + qty);
  }

  /// الكمية المتاحة للون ومقاس محدد
  int getQuantity(String color, int size) {
    return inventory['$color-$size'] ?? 0;
  }

  /// هل المنتج متوفر
  bool get isAvailable => isActive && totalQuantity > 0;

  /// هل المخزون منخفض
  bool isLowStock([int threshold = 5]) =>
      totalQuantity <= threshold && totalQuantity > 0;

  /// هل نفذ من المخزون
  bool get isOutOfStock => totalQuantity == 0;

  /// هامش الربح
  double get profitMargin => price - costPrice;

  /// نسبة الربح
  double get profitPercentage {
    if (costPrice == 0) return 0;
    return ((price - costPrice) / costPrice) * 100;
  }

  /// مفتاح المخزون
  static String inventoryKey(String color, int size) => '$color-$size';
}
