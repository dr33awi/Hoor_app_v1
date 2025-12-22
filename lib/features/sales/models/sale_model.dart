// lib/features/sales/models/sale_model.dart
// نموذج المبيعات - محسن

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
  double get profitPercentage => totalCost > 0 ? (profit / totalCost) * 100 : 0;

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

/// نموذج الفاتورة
class SaleModel {
  final String id;
  final String invoiceNumber;
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double discountPercent;
  final double tax;
  final double total;
  final String paymentMethod;
  final String status;
  final String? buyerName;
  final String? buyerPhone;
  final String? notes;
  final String userId;
  final String userName;
  final DateTime saleDate;
  final DateTime createdAt;
  final double? amountPaid;
  final double? changeGiven;
  final String? refundReason;
  final DateTime? refundedAt;
  final String? refundedBy;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.discountPercent = 0,
    this.tax = 0,
    required this.total,
    this.paymentMethod = AppConstants.paymentCash,
    this.status = AppConstants.saleStatusCompleted,
    this.buyerName,
    this.buyerPhone,
    this.notes,
    required this.userId,
    required this.userName,
    required this.saleDate,
    required this.createdAt,
    this.amountPaid,
    this.changeGiven,
    this.refundReason,
    this.refundedAt,
    this.refundedBy,
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
      tax: (map['tax'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? AppConstants.paymentCash,
      status: map['status'] ?? AppConstants.saleStatusCompleted,
      buyerName: map['buyerName'],
      buyerPhone: map['buyerPhone'],
      notes: map['notes'],
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      saleDate: _parseDateTime(map['saleDate']),
      createdAt: _parseDateTime(map['createdAt']),
      amountPaid: (map['amountPaid'] as num?)?.toDouble(),
      changeGiven: (map['changeGiven'] as num?)?.toDouble(),
      refundReason: map['refundReason'],
      refundedAt: _parseDateTimeNullable(map['refundedAt']),
      refundedBy: map['refundedBy'],
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
      'tax': tax,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'notes': notes,
      'userId': userId,
      'userName': userName,
      'saleDate': Timestamp.fromDate(saleDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'amountPaid': amountPaid,
      'changeGiven': changeGiven,
      'refundReason': refundReason,
      'refundedAt': refundedAt != null ? Timestamp.fromDate(refundedAt!) : null,
      'refundedBy': refundedBy,
    };
  }

  SaleModel copyWith({
    String? id,
    String? invoiceNumber,
    List<SaleItem>? items,
    double? subtotal,
    double? discount,
    double? discountPercent,
    double? tax,
    double? total,
    String? paymentMethod,
    String? status,
    String? buyerName,
    String? buyerPhone,
    String? notes,
    String? userId,
    String? userName,
    DateTime? saleDate,
    DateTime? createdAt,
    double? amountPaid,
    double? changeGiven,
    String? refundReason,
    DateTime? refundedAt,
    String? refundedBy,
  }) {
    return SaleModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      discountPercent: discountPercent ?? this.discountPercent,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      saleDate: saleDate ?? this.saleDate,
      createdAt: createdAt ?? this.createdAt,
      amountPaid: amountPaid ?? this.amountPaid,
      changeGiven: changeGiven ?? this.changeGiven,
      refundReason: refundReason ?? this.refundReason,
      refundedAt: refundedAt ?? this.refundedAt,
      refundedBy: refundedBy ?? this.refundedBy,
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
  bool get isRefunded => status == AppConstants.saleStatusRefunded;

  bool get isCash => paymentMethod == AppConstants.paymentCash;
  bool get isCard => paymentMethod == AppConstants.paymentCard;
  bool get isCredit => paymentMethod == AppConstants.paymentCredit;

  /// هل يمكن إلغاء الفاتورة
  bool get canBeCancelled => isCompleted && !isRefunded;

  /// هل يمكن استرجاع الفاتورة
  bool get canBeRefunded => isCompleted && !isRefunded;

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
