import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/pos_widgets.dart';
import '../providers/pos_provider.dart';
import '../widgets/cart_bottom_sheet.dart';
import '../widgets/checkout_dialog.dart';
import '../widgets/barcode_scanner_widget.dart';

/// شاشة نقطة البيع الرئيسية
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isGridView = true;
  bool _showScanner = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: _buildAppBar(context, ref, posState),
      body: Row(
        children: [
          // قسم المنتجات
          Expanded(
            flex: isDesktop ? 2 : 1,
            child: Column(
              children: [
                // شريط البحث والفلاتر
                _buildSearchBar(context, ref),

                // شريط الفئات
                _buildCategoriesBar(context, ref, posState),

                // ماسح الباركود
                if (_showScanner)
                  BarcodeScannerWidget(
                    onBarcodeScanned: (barcode) {
                      ref.read(posProvider.notifier).searchByBarcode(barcode);
                      setState(() => _showScanner = false);
                    },
                    onClose: () => setState(() => _showScanner = false),
                  ),

                // شبكة المنتجات
                Expanded(
                  child: _buildProductsGrid(context, ref, posState),
                ),
              ],
            ),
          ),

          // قسم السلة (للشاشات الكبيرة)
          if (isDesktop)
            Container(
              width: 350.w,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: AppColors.border),
                ),
              ),
              child: _buildCartSection(context, ref, posState),
            ),
        ],
      ),

      // زر السلة العائم (للشاشات الصغيرة)
      floatingActionButton: !isDesktop && posState.cart.isNotEmpty
          ? _buildCartFab(context, ref, posState)
          : null,

      // شريط الدفع السفلي (للشاشات الصغيرة)
      bottomNavigationBar: !isDesktop && posState.cart.isNotEmpty
          ? _buildBottomCheckoutBar(context, ref, posState)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, PosState state) {
    return AppBar(
      title: const Text('نقطة البيع'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        // إعلاق الوردية
        if (state.currentShift != null)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 16.sp, color: AppColors.success),
                SizedBox(width: 4.w),
                Text(
                  'وردية مفتوحة',
                  style: TextStyle(color: AppColors.success, fontSize: 12.sp),
                ),
              ],
            ),
          )
        else
          TextButton.icon(
            onPressed: () => _openShift(context, ref),
            icon: const Icon(Icons.play_arrow),
            label: const Text('فتح وردية'),
          ),

        // تبديل العرض
        IconButton(
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          onPressed: () => setState(() => _isGridView = !_isGridView),
          tooltip: _isGridView ? 'عرض قائمة' : 'عرض شبكة',
        ),

        // الماسح
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () => setState(() => _showScanner = !_showScanner),
          tooltip: 'مسح باركود',
        ),

        // تعليق الفاتورة
        if (state.cart.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.pause_circle_outline),
            onPressed: () => _holdInvoice(context, ref),
            tooltip: 'تعليق الفاتورة',
          ),

        // الفواتير المعلقة
        if (state.heldInvoices.isNotEmpty)
          Badge(
            label: Text('${state.heldInvoices.length}'),
            child: IconButton(
              icon: const Icon(Icons.receipt_long),
              onPressed: () => _showHeldInvoices(context, ref),
              tooltip: 'الفواتير المعلقة',
            ),
          ),

        // المزيد
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, ref, value),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'customer', child: Text('اختيار عميل')),
            const PopupMenuItem(
                value: 'discount', child: Text('خصم على الفاتورة')),
            const PopupMenuItem(value: 'clear', child: Text('مسح السلة')),
            const PopupMenuDivider(),
            const PopupMenuItem(
                value: 'close_shift', child: Text('إغلاق الوردية')),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hint: 'بحث بالاسم أو الباركود...',
              prefixIcon: Icons.search,
              suffixIcon:
                  _searchController.text.isNotEmpty ? Icons.clear : null,
              onSuffixTap: () {
                _searchController.clear();
                ref.read(posProvider.notifier).clearSearch();
              },
              onChanged: (value) {
                ref.read(posProvider.notifier).searchProducts(value);
              },
              onSubmitted: (value) {
                // البحث بالباركود عند الضغط على Enter
                if (value.isNotEmpty) {
                  ref.read(posProvider.notifier).searchByBarcode(value);
                  _searchController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesBar(
      BuildContext context, WidgetRef ref, PosState state) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: state.categories.isEmpty
          ? const SizedBox.shrink()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length + 1, // +1 للكل
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: CategoryChip(
                      name: 'الكل',
                      isSelected: state.selectedCategoryId == null,
                      onTap: () =>
                          ref.read(posProvider.notifier).selectCategory(null),
                    ),
                  );
                }

                final category = state.categories[index - 1];
                return Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: CategoryChip(
                    name: category.name,
                    isSelected: state.selectedCategoryId == category.id,
                    onTap: () => ref
                        .read(posProvider.notifier)
                        .selectCategory(category.id),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProductsGrid(
      BuildContext context, WidgetRef ref, PosState state) {
    if (state.isLoading) {
      return const LoadingView(message: 'جاري تحميل المنتجات...');
    }

    if (state.filteredProducts.isEmpty) {
      return EmptyView(
        icon: Icons.inventory_2_outlined,
        message: state.searchQuery.isNotEmpty
            ? 'لا توجد نتائج للبحث "${state.searchQuery}"'
            : 'لا توجد منتجات',
        actionLabel: state.searchQuery.isNotEmpty ? 'مسح البحث' : null,
        onAction: state.searchQuery.isNotEmpty
            ? () {
                _searchController.clear();
                ref.read(posProvider.notifier).clearSearch();
              }
            : null,
      );
    }

    if (_isGridView) {
      return GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: state.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = state.filteredProducts[index];
          return ProductCard(
            name: product.name,
            price: product.salePrice,
            imageUrl: product.imageUrl,
            stock: product.currentStock,
            onTap: () => _addToCart(ref, product),
            onLongPress: () => _showProductDetails(context, product),
          );
        },
      );
    }

    // عرض القائمة
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: state.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    ),
                  )
                : _buildPlaceholder(),
            title: Text(product.name),
            subtitle: Text(
              'المخزون: ${product.currentStock.toInt()}',
              style: TextStyle(
                color: product.currentStock <= product.minStock
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
            trailing: PriceText(price: product.salePrice),
            onTap: () => _addToCart(ref, product),
            onLongPress: () => _showProductDetails(context, product),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.inventory_2, color: AppColors.textSecondary),
    );
  }

  Widget _buildCartSection(
      BuildContext context, WidgetRef ref, PosState state) {
    return Column(
      children: [
        // رأس السلة
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السلة (${state.cart.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (state.cart.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _clearCart(context, ref),
                  color: AppColors.error,
                ),
            ],
          ),
        ),

        // العميل المختار
        if (state.selectedCustomer != null)
          Container(
            margin: EdgeInsets.all(8.w),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: AppColors.info, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    state.selectedCustomer!.name,
                    style: TextStyle(color: AppColors.info),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: 18.sp,
                  onPressed: () =>
                      ref.read(posProvider.notifier).clearCustomer(),
                  color: AppColors.info,
                ),
              ],
            ),
          ),

        // قائمة عناصر السلة
        Expanded(
          child: state.cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'السلة فارغة',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'اختر منتجات لإضافتها',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(8.w),
                  itemCount: state.cart.length,
                  itemBuilder: (context, index) {
                    final item = state.cart[index];
                    return CartItemWidget(
                      name: item.productName,
                      price: item.unitPrice,
                      quantity: item.quantity.toDouble(),
                      total: item.total,
                      discount: item.discount,
                      onIncrement: () => ref
                          .read(posProvider.notifier)
                          .incrementQuantity(item.productId),
                      onDecrement: () => ref
                          .read(posProvider.notifier)
                          .decrementQuantity(item.productId),
                      onRemove: () => ref
                          .read(posProvider.notifier)
                          .removeFromCart(item.productId),
                      onQuantityChanged: (qty) => ref
                          .read(posProvider.notifier)
                          .updateQuantity(item.productId, qty),
                      onDiscountChanged: (discount) => ref
                          .read(posProvider.notifier)
                          .updateItemDiscount(item.productId, discount),
                    );
                  },
                ),
        ),

        // ملخص الفاتورة
        if (state.cart.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                // خصم على الفاتورة
                if (state.invoiceDiscount > 0)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الخصم'),
                        Text(
                          '- ${state.invoiceDiscount.toStringAsFixed(2)}',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),

                InvoiceSummary(
                  subtotal: state.subtotal,
                  tax: state.tax,
                  discount: state.totalDiscount,
                  total: state.total,
                ),

                SizedBox(height: 16.h),

                // زر الدفع
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'دفع ${state.total.toStringAsFixed(2)}',
                    onPressed: () => _checkout(context, ref, state),
                    icon: Icons.payment,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCartFab(BuildContext context, WidgetRef ref, PosState state) {
    return FloatingActionButton.extended(
      onPressed: () => _showCartBottomSheet(context, ref, state),
      icon: Badge(
        label: Text('${state.cart.length}'),
        child: const Icon(Icons.shopping_cart),
      ),
      label: PriceText(
        price: state.total,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBottomCheckoutBar(
      BuildContext context, WidgetRef ref, PosState state) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // معلومات السلة
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.cart.length} عناصر',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  PriceText(
                    price: state.total,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),

            // زر عرض السلة
            OutlinedButton(
              onPressed: () => _showCartBottomSheet(context, ref, state),
              child: const Text('عرض السلة'),
            ),

            SizedBox(width: 8.w),

            // زر الدفع
            AppButton(
              text: 'دفع',
              onPressed: () => _checkout(context, ref, state),
              icon: Icons.payment,
            ),
          ],
        ),
      ),
    );
  }

  // === الوظائف ===

  void _addToCart(WidgetRef ref, PosProduct product) {
    if (product.currentStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('المنتج غير متوفر في المخزون'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref.read(posProvider.notifier).addToCart(product);

    // تأثير صوتي/اهتزاز
    HapticFeedback.lightImpact();
  }

  void _showProductDetails(BuildContext context, PosProduct product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8.h),
            if (product.barcode != null) Text('الباركود: ${product.barcode}'),
            Text('المخزون: ${product.currentStock.toInt()}'),
            Text('الحد الأدنى: ${product.minStock.toInt()}'),
            SizedBox(height: 16.h),
            Row(
              children: [
                const Text('سعر البيع: '),
                PriceText(price: product.salePrice),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'إضافة للسلة',
                onPressed: () {
                  Navigator.pop(context);
                  _addToCart(ref, product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartBottomSheet(
      BuildContext context, WidgetRef ref, PosState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CartBottomSheet(
        cart: state.cart,
        subtotal: state.subtotal,
        tax: state.tax,
        discount: state.totalDiscount,
        total: state.total,
        selectedCustomer: state.selectedCustomer,
        onCheckout: () {
          Navigator.pop(context);
          _checkout(context, ref, state);
        },
      ),
    );
  }

  Future<void> _checkout(
      BuildContext context, WidgetRef ref, PosState state) async {
    if (state.currentShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يجب فتح وردية أولاً'),
          backgroundColor: AppColors.warning,
          action: SnackBarAction(
            label: 'فتح وردية',
            onPressed: () => _openShift(context, ref),
          ),
        ),
      );
      return;
    }

    final result = await showDialog<CheckoutResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CheckoutDialog(
        total: state.total,
        customerId: state.selectedCustomer?.id,
      ),
    );

    if (result != null && result.success) {
      // إتمام عملية البيع
      await ref.read(posProvider.notifier).completeSale(
            paymentMethod: result.paymentMethod,
            receivedAmount: result.receivedAmount,
            notes: result.notes,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إتمام عملية البيع بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _clearCart(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السلة'),
        content: const Text('هل تريد مسح جميع العناصر من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(posProvider.notifier).clearCart();
            },
            child: Text('مسح', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _holdInvoice(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final noteController = TextEditingController();
        return AlertDialog(
          title: const Text('تعليق الفاتورة'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'ملاحظة (اختياري)',
              hintText: 'مثال: اسم العميل',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(posProvider.notifier).holdInvoice(noteController.text);
              },
              child: const Text('تعليق'),
            ),
          ],
        );
      },
    );
  }

  void _showHeldInvoices(BuildContext context, WidgetRef ref) {
    final state = ref.read(posProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الفواتير المعلقة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            ...state.heldInvoices.map((held) => ListTile(
                  leading: const Icon(Icons.receipt),
                  title:
                      Text(held.note.isNotEmpty ? held.note : 'فاتورة معلقة'),
                  subtitle: Text(
                      '${held.items.length} عناصر - ${held.total.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(posProvider.notifier).deleteHeldInvoice(held.id);
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(posProvider.notifier).resumeHeldInvoice(held.id);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _openShift(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final openingCashController = TextEditingController(text: '0');
        return AlertDialog(
          title: const Text('فتح وردية جديدة'),
          content: TextField(
            controller: openingCashController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'الرصيد الافتتاحي',
              suffixText: 'ر.س',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                final openingCash =
                    double.tryParse(openingCashController.text) ?? 0;
                Navigator.pop(context);
                ref.read(posProvider.notifier).openShift(openingCash);
              },
              child: const Text('فتح'),
            ),
          ],
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'customer':
        _selectCustomer(context, ref);
        break;
      case 'discount':
        _applyInvoiceDiscount(context, ref);
        break;
      case 'clear':
        _clearCart(context, ref);
        break;
      case 'close_shift':
        _closeShift(context, ref);
        break;
    }
  }

  void _selectCustomer(BuildContext context, WidgetRef ref) {
    // TODO: عرض قائمة العملاء
    context.push('/customers/select').then((customer) {
      if (customer != null) {
        ref.read(posProvider.notifier).selectCustomer(customer as PosCustomer);
      }
    });
  }

  void _applyInvoiceDiscount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final discountController = TextEditingController();
        bool isPercentage = false;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('خصم على الفاتورة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'قيمة الخصم',
                    suffixText: isPercentage ? '%' : 'ر.س',
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    const Text('نسبة مئوية'),
                    Switch(
                      value: isPercentage,
                      onChanged: (v) => setState(() => isPercentage = v),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  final value = double.tryParse(discountController.text) ?? 0;
                  Navigator.pop(context);
                  ref
                      .read(posProvider.notifier)
                      .applyInvoiceDiscount(value, isPercentage);
                },
                child: const Text('تطبيق'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _closeShift(BuildContext context, WidgetRef ref) {
    // TODO: تنفيذ إغلاق الوردية
    context.push('/shifts/close');
  }
}
