import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/widgets/invoice_widgets.dart';
import '../../../core/widgets/invoice_actions_sheet.dart';
import '../../../core/services/printing/printing_services.dart';
import '../../../core/services/print_settings_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/repositories/shift_repository.dart';
import '../../../data/repositories/cash_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/supplier_repository.dart';

class InvoiceFormScreen extends ConsumerStatefulWidget {
  final String type;
  final String? invoiceId; // للتعديل - اختياري

  const InvoiceFormScreen({super.key, required this.type, this.invoiceId});

  bool get isEditMode => invoiceId != null;

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _productRepo = getIt<ProductRepository>();
  final _invoiceRepo = getIt<InvoiceRepository>();
  final _shiftRepo = getIt<ShiftRepository>();
  final _cashRepo = getIt<CashRepository>();
  final _customerRepo = getIt<CustomerRepository>();
  final _supplierRepo = getIt<SupplierRepository>();
  final _printSettingsService = getIt<PrintSettingsService>();
  final _currencyService = getIt<CurrencyService>();

  final _searchController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _paidAmountController = TextEditingController();
  final _notesController = TextEditingController();

  final List<Map<String, dynamic>> _items = [];
  final Map<String, int> _productStock = {}; // لتخزين كميات المخزون
  String _paymentMethod = 'cash';
  bool _isLoading = false;
  bool _isLoadingInvoice = false; // للتحميل أثناء التعديل
  Shift? _currentShift;
  Invoice? _existingInvoice; // الفاتورة الموجودة عند التعديل

  // العميل والمورد (اختياري)
  Customer? _selectedCustomer;
  Supplier? _selectedSupplier;
  List<Customer> _customers = [];
  List<Supplier> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentShift();
    _loadCustomersAndSuppliers();
    if (widget.isEditMode) {
      _loadExistingInvoice();
    }
  }

  /// تحميل بيانات الفاتورة الموجودة للتعديل
  Future<void> _loadExistingInvoice() async {
    setState(() => _isLoadingInvoice = true);
    try {
      final invoice = await _invoiceRepo.getInvoiceById(widget.invoiceId!);
      if (invoice == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الفاتورة غير موجودة'),
              backgroundColor: AppColors.error,
            ),
          );
          context.pop();
        }
        return;
      }

      _existingInvoice = invoice;

      // تحميل عناصر الفاتورة
      final items = await _invoiceRepo.getInvoiceItems(widget.invoiceId!);

      // تحويل العناصر إلى الشكل المطلوب
      for (final item in items) {
        final product = await _productRepo.getProductById(item.productId);
        _productStock[item.productId] = product?.quantity ?? 0;

        _items.add({
          'productId': item.productId,
          'productName': item.productName,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'purchasePrice': item.purchasePrice,
          'salePrice': product?.salePrice ?? item.unitPrice,
          'availableStock': (product?.quantity ?? 0) +
              item.quantity, // إضافة الكمية الموجودة في الفاتورة
        });
      }

      // تحميل العميل أو المورد
      if (invoice.customerId != null) {
        _selectedCustomer =
            await _customerRepo.getCustomerById(invoice.customerId!);
      }
      if (invoice.supplierId != null) {
        _selectedSupplier =
            await _supplierRepo.getSupplierById(invoice.supplierId!);
      }

      // تعبئة البيانات
      _discountController.text = invoice.discountAmount.toStringAsFixed(0);
      _paymentMethod = invoice.paymentMethod;
      _paidAmountController.text = invoice.paidAmount.toStringAsFixed(0);
      _notesController.text = invoice.notes ?? '';

      setState(() => _isLoadingInvoice = false);
    } catch (e) {
      setState(() => _isLoadingInvoice = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الفاتورة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadCurrentShift() async {
    final shift = await _shiftRepo.getOpenShift();
    setState(() => _currentShift = shift);
  }

  Future<void> _loadCustomersAndSuppliers() async {
    final customers = await _customerRepo.getAllCustomers();
    final suppliers = await _supplierRepo.getAllSuppliers();
    setState(() {
      _customers = customers.where((c) => c.isActive).toList();
      _suppliers = suppliers.where((s) => s.isActive).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _typeTitle {
    final prefix = widget.isEditMode ? 'تعديل' : 'جديدة';
    switch (widget.type) {
      case 'sale':
        return widget.isEditMode
            ? 'تعديل فاتورة مبيعات'
            : 'فاتورة مبيعات جديدة';
      case 'purchase':
        return widget.isEditMode
            ? 'تعديل فاتورة مشتريات'
            : 'فاتورة مشتريات جديدة';
      case 'sale_return':
        return widget.isEditMode ? 'تعديل مرتجع مبيعات' : 'مرتجع مبيعات';
      case 'purchase_return':
        return widget.isEditMode ? 'تعديل مرتجع مشتريات' : 'مرتجع مشتريات';
      default:
        return widget.isEditMode ? 'تعديل فاتورة' : 'فاتورة جديدة';
    }
  }

  double get _subtotal => _items.fold(
      0,
      (sum, item) =>
          sum + (item['quantity'] as int) * (item['unitPrice'] as double));

  double get _discount => double.tryParse(_discountController.text) ?? 0;

  double get _total => _subtotal - _discount;

  double get _paidAmount {
    if (_paymentMethod == 'credit' || _paymentMethod == 'partial') {
      return double.tryParse(_paidAmountController.text) ?? 0;
    }
    return _total;
  }

  double get _remainingAmount => _total - _paidAmount;

  @override
  Widget build(BuildContext context) {
    // عرض مؤشر التحميل أثناء تحميل بيانات الفاتورة
    if (_isLoadingInvoice) {
      return Scaffold(
        appBar: AppBar(title: Text(_typeTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_typeTitle),
        actions: [
          if (!widget.isEditMode && _currentShift == null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Chip(
                label: const Text('لا توجد وردية'),
                backgroundColor: AppColors.warning.withOpacity(0.2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Add Product
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'بحث عن منتج...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanBarcode,
                      ),
                    ),
                    onSubmitted: _searchProduct,
                  ),
                ),
                Gap(8.w),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                  iconSize: 40.sp,
                  onPressed: () => _showProductsDialog(),
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_basket_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        Gap(16.h),
                        Text(
                          'أضف منتجات إلى الفاتورة',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isSale = widget.type == 'sale' ||
                          widget.type == 'purchase_return';
                      return _InvoiceItemCard(
                        item: item,
                        isPurchase: widget.type == 'purchase',
                        isSale: isSale,
                        currencyService: _currencyService,
                        onQuantityChanged: (qty) {
                          if (isSale) {
                            final availableStock =
                                item['availableStock'] as int? ??
                                    _productStock[item['productId']] ??
                                    999;
                            if (qty > availableStock) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'الكمية المطلوبة ($qty) أكبر من المتاح ($availableStock)'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                              return;
                            }
                          }
                          setState(() => item['quantity'] = qty);
                        },
                        onPriceChanged: (price) {
                          setState(() => item['unitPrice'] = price);
                        },
                        onRemove: () {
                          setState(() => _items.removeAt(index));
                        },
                      );
                    },
                  ),
          ),

          // Summary & Submit
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Customer/Supplier Selection (optional)
                  if (widget.type == 'sale' ||
                      widget.type == 'sale_return') ...[
                    DropdownButtonFormField<Customer?>(
                      value: _selectedCustomer,
                      decoration: InputDecoration(
                        labelText: 'العميل (اختياري)',
                        prefixIcon: const Icon(Icons.person),
                        isDense: true,
                        suffixIcon: _selectedCustomer != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () =>
                                    setState(() => _selectedCustomer = null),
                              )
                            : null,
                      ),
                      items: [
                        const DropdownMenuItem<Customer?>(
                          value: null,
                          child: Text('بدون عميل'),
                        ),
                        ..._customers.map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name),
                            )),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedCustomer = value),
                    ),
                    Gap(8.h),
                  ],
                  if (widget.type == 'purchase' ||
                      widget.type == 'purchase_return') ...[
                    DropdownButtonFormField<Supplier?>(
                      value: _selectedSupplier,
                      decoration: InputDecoration(
                        labelText: 'المورد (اختياري)',
                        prefixIcon: const Icon(Icons.business),
                        isDense: true,
                        suffixIcon: _selectedSupplier != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () =>
                                    setState(() => _selectedSupplier = null),
                              )
                            : null,
                      ),
                      items: [
                        const DropdownMenuItem<Supplier?>(
                          value: null,
                          child: Text('بدون مورد'),
                        ),
                        ..._suppliers.map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name),
                            )),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedSupplier = value),
                    ),
                    Gap(8.h),
                  ],
                  // Discount
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'الخصم',
                            prefixIcon: Icon(Icons.discount),
                            suffixText: 'ل.س',
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      Gap(16.w),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'طريقة الدفع',
                            prefixIcon: Icon(Icons.payment),
                            isDense: true,
                          ),
                          items: PaymentMethod.values
                              .map((p) => DropdownMenuItem(
                                    value: p.value,
                                    child: Text(p.label),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value!;
                              // تحديث المبلغ المدفوع عند تغيير طريقة الدفع
                              if (value == 'partial') {
                                // الدفع الجزئي - يبقى الحقل فارغاً للإدخال
                                _paidAmountController.text = '';
                              } else {
                                // الدفع الكامل (نقدي، بطاقة، تحويل، آجل)
                                _paidAmountController.text =
                                    _total.toStringAsFixed(0);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  // حقل المبلغ المدفوع (يظهر للدفع الجزئي فقط)
                  if (_paymentMethod == 'partial') ...[
                    Gap(12.h),
                    TextField(
                      controller: _paidAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'المبلغ المدفوع',
                        prefixIcon: const Icon(Icons.attach_money),
                        suffixText: 'ل.س',
                        isDense: true,
                        hintText: 'أدخل المبلغ المدفوع',
                        helperText: 'الحد الأقصى: ${formatPrice(_total)}',
                      ),
                      onChanged: (value) {
                        final paid = double.tryParse(value) ?? 0;
                        if (paid > _total) {
                          _paidAmountController.text =
                              _total.toStringAsFixed(0);
                        }
                        setState(() {});
                      },
                    ),
                  ],
                  Gap(12.h),

                  // Totals
                  if (_discount > 0) ...[
                    Gap(4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الخصم:',
                            style: TextStyle(
                                fontSize: 14.sp, color: AppColors.error)),
                        Text(
                            '-${formatPrice(_discount, showCurrency: false)} ل.س',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ],
                  Gap(8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي:',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatPrice(_total),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '\$${_currencyService.sypToUsd(_total).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // المبلغ المدفوع والمتبقي (للدفع الجزئي فقط)
                  if (_paymentMethod == 'partial') ...[
                    Gap(8.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: _remainingAmount > 0
                            ? AppColors.warning.withOpacity(0.1)
                            : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: _remainingAmount > 0
                              ? AppColors.warning
                              : AppColors.success,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'المبلغ المدفوع:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.success,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatPrice(_paidAmount),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    '\$${_currencyService.sypToUsd(_paidAmount).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Gap(4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _remainingAmount > 0
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle,
                                    size: 18.sp,
                                    color: _remainingAmount > 0
                                        ? AppColors.warning
                                        : AppColors.success,
                                  ),
                                  Gap(4.w),
                                  Text(
                                    'المبلغ المتبقي:',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _remainingAmount > 0
                                          ? AppColors.warning
                                          : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatPrice(_remainingAmount),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _remainingAmount > 0
                                          ? AppColors.warning
                                          : AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    '\$${_currencyService.sypToUsd(_remainingAmount).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  Gap(12.h),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed:
                          _items.isEmpty || _isLoading ? null : _submitInvoice,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.isEditMode
                                  ? 'تحديث الفاتورة'
                                  : 'حفظ الفاتورة',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode() async {
    final barcode = await showDialog<String>(
      context: context,
      builder: (context) => _BarcodeScannerDialog(),
    );

    if (barcode != null) {
      final product = await _productRepo.getProductByBarcode(barcode);
      if (product != null) {
        _addProduct(product);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('المنتج غير موجود')),
          );
        }
      }
    }
  }

  Future<void> _searchProduct(String query) async {
    if (query.isEmpty) return;

    // Try barcode first
    var product = await _productRepo.getProductByBarcode(query);

    if (product == null) {
      // Show search results
      await _showProductsDialog(searchQuery: query);
    } else {
      _addProduct(product);
    }

    _searchController.clear();
  }

  Future<void> _showProductsDialog({String? searchQuery}) async {
    final products = await _productRepo.getAllProducts();
    var filtered = products.where((p) => p.isActive).toList();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              (p.sku?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    if (!mounted) return;

    final selected = await showDialog<Product>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر منتج'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final product = filtered[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text(formatPrice(product.salePrice)),
                trailing: Text('الكمية: ${product.quantity}'),
                onTap: () => Navigator.pop(context, product),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );

    if (selected != null) {
      _addProduct(selected);
    }
  }

  void _addProduct(Product product) {
    // For sales, check stock availability
    final isSale = widget.type == 'sale' || widget.type == 'purchase_return';

    if (isSale && product.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('المنتج "${product.name}" غير متوفر في المخزون'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if already in list
    final existingIndex =
        _items.indexWhere((i) => i['productId'] == product.id);

    if (existingIndex >= 0) {
      final currentQty = _items[existingIndex]['quantity'] as int;
      final availableStock = _productStock[product.id] ?? product.quantity;

      if (isSale && currentQty >= availableStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('لا يمكن إضافة المزيد. الكمية المتاحة: $availableStock'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() {
        _items[existingIndex]['quantity']++;
      });
    } else {
      // Store the original stock for this product
      _productStock[product.id] = product.quantity;

      final isPurchase = widget.type == 'purchase';
      setState(() {
        _items.add({
          'productId': product.id,
          'productName': product.name,
          'quantity': 1,
          'unitPrice': isPurchase ? product.purchasePrice : product.salePrice,
          'purchasePrice': product.purchasePrice,
          'salePrice': product.salePrice, // وسطي سعر المبيع
          'availableStock': product.quantity, // تخزين الكمية المتاحة
        });
      });
    }
  }

  Future<bool?> _showPrintAfterSaveDialog(Invoice invoice) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        icon: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 48.sp,
          ),
        ),
        title: const Text('تم حفظ الفاتورة بنجاح'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'فاتورة رقم ${invoice.invoiceNumber}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Gap(8.h),
            Text(
              'هل تريد طباعة الفاتورة الآن؟',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.print, size: 18),
            label: const Text('طباعة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitInvoice() async {
    if (_items.isEmpty) return;

    // التحقق من وجود وردية مفتوحة (فقط للفواتير الجديدة)
    if (!widget.isEditMode && _currentShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب فتح وردية أولاً'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String invoiceId;

      if (widget.isEditMode) {
        // تعديل فاتورة موجودة
        await _invoiceRepo.updateInvoice(
          invoiceId: widget.invoiceId!,
          items: _items,
          discountAmount: _discount,
          paymentMethod: _paymentMethod,
          paidAmount: _paidAmount,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          customerId: _selectedCustomer?.id,
          supplierId: _selectedSupplier?.id,
        );
        invoiceId = widget.invoiceId!;
      } else {
        // إنشاء فاتورة جديدة
        invoiceId = await _invoiceRepo.createInvoice(
          type: widget.type,
          items: _items,
          discountAmount: _discount,
          paymentMethod: _paymentMethod,
          paidAmount: _paidAmount,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          shiftId: _currentShift?.id,
          customerId: _selectedCustomer?.id,
          supplierId: _selectedSupplier?.id,
        );

        // تسجيل حركة الصندوق فقط للفواتير الجديدة
        if (_currentShift != null) {
          if (widget.type == 'sale') {
            await _cashRepo.recordSale(
              shiftId: _currentShift!.id,
              amount: _paidAmount,
              invoiceId: invoiceId,
              paymentMethod: _paymentMethod,
            );
          } else if (widget.type == 'purchase') {
            await _cashRepo.recordPurchase(
              shiftId: _currentShift!.id,
              amount: _paidAmount,
              invoiceId: invoiceId,
              paymentMethod: _paymentMethod,
            );
          }
        }
      }

      if (mounted) {
        // جلب الفاتورة المحفوظة
        final savedInvoice = await _invoiceRepo.getInvoiceById(invoiceId);

        if (savedInvoice != null && mounted) {
          // عرض dialog للطباعة
          final shouldPrint = await _showPrintAfterSaveDialog(savedInvoice);

          if (shouldPrint == true && mounted) {
            await InvoiceActionsSheet.showPrintDialog(context, savedInvoice);
          }
        }

        if (mounted) {
          context.pop(true); // إرجاع true للإشارة إلى نجاح العملية
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _InvoiceItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isPurchase;
  final bool isSale;
  final Function(int) onQuantityChanged;
  final Function(double) onPriceChanged;
  final VoidCallback onRemove;
  final CurrencyService currencyService;

  const _InvoiceItemCard({
    required this.item,
    required this.isPurchase,
    this.isSale = false,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onRemove,
    required this.currencyService,
  });

  @override
  State<_InvoiceItemCard> createState() => _InvoiceItemCardState();
}

class _InvoiceItemCardState extends State<_InvoiceItemCard> {
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final unitPrice = widget.item['unitPrice'] as double;
    _priceController = TextEditingController(
        text: formatPrice(unitPrice, showCurrency: false));
  }

  @override
  void didUpdateWidget(_InvoiceItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPrice = widget.item['unitPrice'] as double;
    final oldPrice = oldWidget.item['unitPrice'] as double;
    if (newPrice != oldPrice) {
      _priceController.text = formatPrice(newPrice, showCurrency: false);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quantity = widget.item['quantity'] as int;
    final unitPrice = widget.item['unitPrice'] as double;
    final total = quantity * unitPrice;
    final availableStock = widget.item['availableStock'] as int? ?? 999;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row - Product name and delete
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item['productName'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.isSale)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: quantity >= availableStock
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'متاح: $availableStock',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: quantity >= availableStock
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.error,
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            Gap(8.h),
            // Controls Row
            Row(
              children: [
                // Quantity Control
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: quantity > 1
                            ? () => widget.onQuantityChanged(quantity - 1)
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          child: Icon(
                            Icons.remove,
                            size: 18.sp,
                            color:
                                quantity > 1 ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => widget.onQuantityChanged(quantity + 1),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          child: Icon(
                            Icons.add,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(8.w),
                // Price Input
                Expanded(
                  child: SizedBox(
                    height: 36.h,
                    child: TextField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.sp),
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                        suffixText: 'ل.س',
                        suffixStyle: TextStyle(fontSize: 11.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onChanged: (value) {
                        final price = double.tryParse(value);
                        if (price != null) widget.onPriceChanged(price);
                      },
                    ),
                  ),
                ),
                Gap(8.w),
                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'الإجمالي',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatPrice(total),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '\$${widget.currencyService.sypToUsd(total).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BarcodeScannerDialog extends StatefulWidget {
  @override
  State<_BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<_BarcodeScannerDialog> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('مسح الباركود'),
      content: SizedBox(
        width: 300.w,
        height: 300.h,
        child: MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            if (_scanned) return;
            final barcode = capture.barcodes.firstOrNull?.rawValue;
            if (barcode != null) {
              _scanned = true;
              Navigator.pop(context, barcode);
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }
}
