// lib/features/sales/providers/sale_provider.dart
// مزود حالة المبيعات

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../models/sale_model.dart';
import '../services/sale_service.dart';

class SaleProvider with ChangeNotifier {
  final SaleService _saleService = SaleService();

  List<SaleModel> _sales = [];
  List<SaleItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterStatus;

  // بيانات الفاتورة الحالية
  String? _buyerName;
  String? _buyerPhone;
  String? _notes;
  String _paymentMethod = AppConstants.paymentCash;
  double _discountPercent = 0;
  double _discountAmount = 0;
  bool _applyTax = true;

  // Getters
  List<SaleModel> get sales => _getFilteredSales();
  List<SaleModel> get allSales => _sales;
  List<SaleItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get buyerName => _buyerName;
  String? get buyerPhone => _buyerPhone;
  String? get notes => _notes;
  String get paymentMethod => _paymentMethod;
  double get discountPercent => _discountPercent;
  double get discountAmount => _discountAmount;
  bool get applyTax => _applyTax;

  /// المجموع الفرعي (قبل الخصم والضريبة)
  double get subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// قيمة الخصم
  double get discount {
    if (_discountAmount > 0) {
      return _discountAmount;
    }
    return subtotal * (_discountPercent / 100);
  }

  /// قيمة الضريبة
  double get tax {
    if (!_applyTax) return 0;
    return (subtotal - discount) * AppConstants.defaultTaxRate;
  }

  /// الإجمالي النهائي
  double get total {
    return subtotal - discount + tax;
  }

  /// عدد العناصر في السلة
  int get cartItemsCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// هل السلة فارغة
  bool get isCartEmpty => _cartItems.isEmpty;

  /// المبيعات المفلترة
  List<SaleModel> _getFilteredSales() {
    var filtered = _sales;

    // فلترة حسب البحث
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.invoiceNumber.toLowerCase().contains(query) ||
            (s.buyerName?.toLowerCase().contains(query) ?? false) ||
            (s.buyerPhone?.contains(query) ?? false);
      }).toList();
    }

    // فلترة حسب الحالة
    if (_filterStatus != null) {
      filtered = filtered.where((s) => s.status == _filterStatus).toList();
    }

    return filtered;
  }

  /// مبيعات اليوم
  List<SaleModel> get todaySales {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _sales.where((s) {
      return s.saleDate.isAfter(startOfDay) &&
          s.status == AppConstants.saleStatusCompleted;
    }).toList();
  }

  /// إجمالي مبيعات اليوم
  double get todayTotal {
    return todaySales.fold(0, (sum, s) => sum + s.total);
  }

  /// عدد فواتير اليوم
  int get todayOrdersCount => todaySales.length;

  /// تحميل المبيعات
  Future<void> loadSales({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _saleService.getAllSales(
      startDate: startDate,
      endDate: endDate,
    );

    if (result.success) {
      _sales = result.data!;
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// إضافة عنصر للسلة
  void addToCart(SaleItem item) {
    // التحقق من وجود نفس المنتج بنفس اللون والمقاس
    final existingIndex = _cartItems.indexWhere(
      (i) =>
          i.productId == item.productId &&
          i.color == item.color &&
          i.size == item.size,
    );

    if (existingIndex >= 0) {
      // تحديث الكمية
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    } else {
      _cartItems.add(item);
    }

    notifyListeners();
  }

  /// تحديث كمية عنصر في السلة
  void updateCartItemQuantity(int index, int quantity) {
    if (index < 0 || index >= _cartItems.length) return;

    if (quantity <= 0) {
      _cartItems.removeAt(index);
    } else {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
    }

    notifyListeners();
  }

  /// حذف عنصر من السلة
  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  /// مسح السلة
  void clearCart() {
    _cartItems.clear();
    _buyerName = null;
    _buyerPhone = null;
    _notes = null;
    _paymentMethod = AppConstants.paymentCash;
    _discountPercent = 0;
    _discountAmount = 0;
    _applyTax = true;
    notifyListeners();
  }

  /// تحديث بيانات المشتري
  void setBuyerInfo({String? name, String? phone}) {
    _buyerName = name;
    _buyerPhone = phone;
    notifyListeners();
  }

  /// تحديث الملاحظات
  void setNotes(String? notes) {
    _notes = notes;
    notifyListeners();
  }

  /// تحديث طريقة الدفع
  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  /// تحديث الخصم (نسبة مئوية)
  void setDiscountPercent(double percent) {
    _discountPercent = percent;
    _discountAmount = 0;
    notifyListeners();
  }

  /// تحديث الخصم (قيمة ثابتة)
  void setDiscountAmount(double amount) {
    _discountAmount = amount;
    _discountPercent = 0;
    notifyListeners();
  }

  /// تفعيل/تعطيل الضريبة
  void setApplyTax(bool apply) {
    _applyTax = apply;
    notifyListeners();
  }

  /// إنشاء الفاتورة
  Future<SaleModel?> createSale() async {
    if (_cartItems.isEmpty) {
      _error = 'السلة فارغة';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final sale = SaleModel(
      id: '',
      invoiceNumber: '',
      items: List.from(_cartItems),
      subtotal: subtotal,
      discount: discount,
      discountPercent: _discountPercent,
      tax: tax,
      total: total,
      paymentMethod: _paymentMethod,
      status: AppConstants.saleStatusCompleted,
      buyerName: _buyerName,
      buyerPhone: _buyerPhone,
      notes: _notes,
      userId: '',
      userName: '',
      saleDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final result = await _saleService.createSale(sale);

    _isLoading = false;

    if (result.success) {
      clearCart();
      await loadSales();
      notifyListeners();
      return result.data;
    } else {
      _error = result.error;
      notifyListeners();
      return null;
    }
  }

  /// إلغاء فاتورة
  Future<bool> cancelSale(String saleId) async {
    _error = null;

    final result = await _saleService.cancelSale(saleId);

    if (result.success) {
      await loadSales();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  /// الحصول على فاتورة بالـ ID
  SaleModel? getSaleById(String id) {
    try {
      return _sales.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// البحث
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// تعيين فلتر الحالة
  void setFilterStatus(String? status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// مسح الفلاتر
  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterStartDate = null;
    _filterEndDate = null;
    notifyListeners();
  }

  /// الحصول على تقرير المبيعات
  Future<SalesReport?> getSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await _saleService.getSalesReport(
      startDate: startDate,
      endDate: endDate,
    );

    if (result.success) {
      return result.data;
    } else {
      _error = result.error;
      notifyListeners();
      return null;
    }
  }

  /// مسح الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Stream للمبيعات
  void startListening() {
    _saleService.streamSales().listen((sales) {
      _sales = sales;
      notifyListeners();
    });
  }
}
