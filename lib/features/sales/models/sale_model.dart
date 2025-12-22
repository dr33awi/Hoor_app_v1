// lib/features/sales/models/sale_model.dart
// نموذج المبيعات

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

  SaleItem({
    required this.productId,
    required this.productName,
    required this.color,
    required this.size,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
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
    };
  }

  /// الإجمالي للعنصر
  double get totalPrice => unitPrice * quantity;

  /// إجمالي التكلفة
  double get totalCost => costPrice * quantity;

  /// الربح
  double get profit => totalPrice - totalCost;

  SaleItem copyWith({
    String? productId,
    String? productName,
    String? color,
    int? size,
    int? quantity,
    double? unitPrice,
    double? costPrice,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      color: color ?? this.color,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
    );
  }
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
  });

  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleModel(
      id: doc.id,
      invoiceNumber: data['invoiceNumber'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => SaleItem.fromMap(item))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      discountPercent: (data['discountPercent'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? AppConstants.paymentCash,
      status: data['status'] ?? AppConstants.saleStatusCompleted,
      buyerName: data['buyerName'],
      buyerPhone: data['buyerPhone'],
      notes: data['notes'],
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      saleDate: (data['saleDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
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
    );
  }

  /// عدد العناصر
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// إجمالي التكلفة
  double get totalCost => items.fold(0, (sum, item) => sum + item.totalCost);

  /// إجمالي الربح
  double get totalProfit => total - totalCost;

  /// هل الفاتورة مكتملة
  bool get isCompleted => status == AppConstants.saleStatusCompleted;

  /// هل الفاتورة ملغية
  bool get isCancelled => status == AppConstants.saleStatusCancelled;

  /// هل الفاتورة معلقة
  bool get isPending => status == AppConstants.saleStatusPending;
}
