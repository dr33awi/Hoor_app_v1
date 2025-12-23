// lib/features/sales/models/sale_model.dart
// نموذج المبيعات - مبسط (نقدي فقط، بدون ضريبة)

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

/// عنصر في الفاتورة
class SaleItem {
  final String productId;
  final String productName;
  final String color;
  final int size;
  final int quantity;
  final double unitPrice;
  final double costPrice;
  final String? barcode;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.color,
    required this.size,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
    this.barcode,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      color: map['color'] ?? '',
      size: map['size'] ?? 0,
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      barcode: map['barcode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'color': color,
      'size': size,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'costPrice': costPrice,
      'barcode': barcode,
    };
  }

  double get totalPrice => unitPrice * quantity;
  double get totalCost => costPrice * quantity;
  double get profit => totalPrice - totalCost;

  String get variant => '$color - مقاس $size';
  String get inventoryKey => '$color-$size';

  SaleItem copyWith({
    String? productId,
    String? productName,
    String? color,
    int? size,
    int? quantity,
    double? unitPrice,
    double? costPrice,
    String? barcode,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      color: color ?? this.color,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItem &&
          productId == other.productId &&
          color == other.color &&
          size == other.size;

  @override
  int get hashCode => Object.hash(productId, color, size);
}

/// نموذج الفاتورة المبسط
class SaleModel {
  final String id;
  final String invoiceNumber;
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double discountPercent;
  final double total;
  final String status; // مكتمل، ملغي، معلق
  final String? notes;
  final String userId;
  final String userName;
  final DateTime saleDate;
  final DateTime createdAt;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final String? cancelledBy;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.discountPercent = 0,
    required this.total,
    this.status = AppConstants.saleStatusCompleted,
    this.notes,
    required this.userId,
    required this.userName,
    required this.saleDate,
    required this.createdAt,
    this.cancelReason,
    this.cancelledAt,
    this.cancelledBy,
  });

  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleModel.fromMap(doc.id, data);
  }

  factory SaleModel.fromMap(String id, Map<String, dynamic> map) {
    return SaleModel(
      id: id,
      invoiceNumber: map['invoiceNumber'] ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => SaleItem.fromMap(item))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      discountPercent: (map['discountPercent'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      status: map['status'] ?? AppConstants.saleStatusCompleted,
      notes: map['notes'],
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      saleDate: _parseDateTime(map['saleDate']),
      createdAt: _parseDateTime(map['createdAt']),
      cancelReason: map['cancelReason'],
      cancelledAt: _parseDateTimeNullable(map['cancelledAt']),
      cancelledBy: map['cancelledBy'],
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }

  static DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'discountPercent': discountPercent,
      'total': total,
      'status': status,
      'notes': notes,
      'userId': userId,
      'userName': userName,
      'saleDate': Timestamp.fromDate(saleDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'cancelReason': cancelReason,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
      'cancelledBy': cancelledBy,
    };
  }

  SaleModel copyWith({
    String? id,
    String? invoiceNumber,
    List<SaleItem>? items,
    double? subtotal,
    double? discount,
    double? discountPercent,
    double? total,
    String? status,
    String? notes,
    String? userId,
    String? userName,
    DateTime? saleDate,
    DateTime? createdAt,
    String? cancelReason,
    DateTime? cancelledAt,
    String? cancelledBy,
  }) {
    return SaleModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      discountPercent: discountPercent ?? this.discountPercent,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      saleDate: saleDate ?? this.saleDate,
      createdAt: createdAt ?? this.createdAt,
      cancelReason: cancelReason ?? this.cancelReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
    );
  }

  // الخصائص المحسوبة
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalCost => items.fold(0, (sum, item) => sum + item.totalCost);
  double get totalProfit => total - totalCost;
  double get profitPercentage =>
      totalCost > 0 ? (totalProfit / totalCost) * 100 : 0;

  bool get isCompleted => status == AppConstants.saleStatusCompleted;
  bool get isCancelled => status == AppConstants.saleStatusCancelled;
  bool get isPending => status == AppConstants.saleStatusPending;

  /// هل يمكن إلغاء الفاتورة
  bool get canBeCancelled => isCompleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SaleModel(id: $id, invoice: $invoiceNumber, total: $total)';
}
