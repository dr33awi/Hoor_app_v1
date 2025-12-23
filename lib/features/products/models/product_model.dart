// lib/features/products/models/product_model.dart
// نموذج المنتج - مع دعم الباركود المحسّن

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final double price;
  final double costPrice;
  final String barcode; // باركود المنتج الأساسي
  final List<String> colors;
  final List<int> sizes;
  final Map<String, int> inventory; // {"أسود-42": 5, "أبيض-43": 3}
  final Map<String, String> variantBarcodes; // {"أسود-42": "SHO2506...", ...}
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
    required this.barcode,
    required this.colors,
    required this.sizes,
    required this.inventory,
    this.variantBarcodes = const {},
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
      barcode: data['barcode'] ?? '',
      colors: List<String>.from(data['colors'] ?? []),
      sizes: List<int>.from((data['sizes'] ?? []).map((e) => e as int)),
      inventory: Map<String, int>.from(
        (data['inventory'] ?? {}).map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        ),
      ),
      variantBarcodes: Map<String, String>.from(
        (data['variantBarcodes'] ?? {}).map(
          (key, value) => MapEntry(key.toString(), value.toString()),
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
      'barcode': barcode,
      'colors': colors,
      'sizes': sizes,
      'inventory': inventory,
      'variantBarcodes': variantBarcodes,
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
    String? barcode,
    List<String>? colors,
    List<int>? sizes,
    Map<String, int>? inventory,
    Map<String, String>? variantBarcodes,
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
      barcode: barcode ?? this.barcode,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      inventory: inventory ?? this.inventory,
      variantBarcodes: variantBarcodes ?? this.variantBarcodes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// الكمية الإجمالية
  int get totalQuantity => inventory.values.fold(0, (sum, qty) => sum + qty);

  /// هل نفذ المخزون؟
  bool get isOutOfStock => totalQuantity == 0;

  /// هل المخزون منخفض؟
  bool get isLowStock => totalQuantity > 0 && totalQuantity <= 5;

  /// الحصول على كمية محددة
  int getQuantity(String color, int size) {
    final key = inventoryKey(color, size);
    return inventory[key] ?? 0;
  }

  /// الحصول على باركود متغير
  String? getVariantBarcode(String color, int size) {
    final key = inventoryKey(color, size);
    return variantBarcodes[key];
  }

  /// مفتاح المخزون
  static String inventoryKey(String color, int size) => '$color-$size';

  /// هامش الربح
  double get profitMargin => price - costPrice;

  /// نسبة الربح
  double get profitPercentage =>
      costPrice > 0 ? ((price - costPrice) / costPrice) * 100 : 0;

  /// البحث عن متغير بالباركود
  VariantInfo? findVariantByBarcode(String searchBarcode) {
    // البحث في باركودات المتغيرات
    for (final entry in variantBarcodes.entries) {
      if (entry.value == searchBarcode) {
        final parts = entry.key.split('-');
        if (parts.length >= 2) {
          final color = parts.sublist(0, parts.length - 1).join('-');
          final size = int.tryParse(parts.last);
          if (size != null) {
            return VariantInfo(
              color: color,
              size: size,
              quantity: getQuantity(color, size),
              barcode: entry.value,
            );
          }
        }
      }
    }
    
    // البحث في الباركود الأساسي
    if (barcode == searchBarcode) {
      if (colors.isNotEmpty && sizes.isNotEmpty) {
        return VariantInfo(
          color: colors.first,
          size: sizes.first,
          quantity: getQuantity(colors.first, sizes.first),
          barcode: barcode,
        );
      }
    }
    
    return null;
  }

  /// جميع المتغيرات المتوفرة
  List<VariantInfo> get availableVariants {
    final variants = <VariantInfo>[];
    for (final color in colors) {
      for (final size in sizes) {
        final qty = getQuantity(color, size);
        if (qty > 0) {
          variants.add(VariantInfo(
            color: color,
            size: size,
            quantity: qty,
            barcode: getVariantBarcode(color, size),
          ));
        }
      }
    }
    return variants;
  }

  @override
  String toString() => 'ProductModel(id: $id, name: $name, barcode: $barcode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// معلومات المتغير
class VariantInfo {
  final String color;
  final int size;
  final int quantity;
  final String? barcode;

  VariantInfo({
    required this.color,
    required this.size,
    required this.quantity,
    this.barcode,
  });

  String get key => '$color-$size';
  String get displayName => '$color - مقاس $size';
}
