import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/pos_widgets.dart';
import '../providers/pos_provider.dart';

/// ورقة السلة السفلية
class CartBottomSheet extends ConsumerWidget {
  final List<CartItem> cart;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final PosCustomer? selectedCustomer;
  final VoidCallback onCheckout;

  const CartBottomSheet({
    super.key,
    required this.cart,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    this.selectedCustomer,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // مقبض السحب
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // رأس السلة
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'السلة (${cart.length} عناصر)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(posProvider.notifier).clearCart();
                    },
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: AppColors.border),

            // العميل المختار
            if (selectedCustomer != null)
              Container(
                margin: EdgeInsets.all(16.w),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedCustomer!.name,
                            style: TextStyle(
                              color: AppColors.info,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (selectedCustomer!.phone != null)
                            Text(
                              selectedCustomer!.phone!,
                              style: TextStyle(
                                color: AppColors.info,
                                fontSize: 12.sp,
                              ),
                            ),
                        ],
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

            // قائمة العناصر
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return _CartItemCard(
                    item: item,
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
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // تفاصيل المبالغ
                    _SummaryRow(label: 'المجموع الفرعي', value: subtotal),
                    if (discount > 0)
                      _SummaryRow(
                          label: 'الخصم', value: -discount, isDiscount: true),
                    _SummaryRow(label: 'الضريبة', value: tax),
                    Divider(height: 16.h),
                    _SummaryRow(label: 'الإجمالي', value: total, isTotal: true),
                    SizedBox(height: 16.h),

                    // زر الدفع
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: 'متابعة للدفع (${total.toStringAsFixed(2)})',
                        onPressed: onCheckout,
                        icon: Icons.payment,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة عنصر السلة
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;
  final Function(double) onDiscountChanged;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onQuantityChanged,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // اسم المنتج
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: 4.h),
                      PriceText(
                        price: item.unitPrice,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // زر الحذف
                IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: 20.sp,
                  color: AppColors.error,
                  onPressed: onRemove,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                // التحكم بالكمية
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onDecrement,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(Icons.remove, size: 18.sp),
                        ),
                      ),
                      InkWell(
                        onTap: () => _showQuantityDialog(context),
                        child: Container(
                          constraints: BoxConstraints(minWidth: 40.w),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onIncrement,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(Icons.add, size: 18.sp),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                // زر الخصم
                if (item.discount > 0)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '-${item.discount.toStringAsFixed(0)}',
                      style:
                          TextStyle(color: AppColors.warning, fontSize: 12.sp),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => _showDiscountDialog(context),
                    child: const Text('خصم'),
                  ),

                const Spacer(),

                // الإجمالي
                PriceText(
                  price: item.total,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context) {
    final controller = TextEditingController(text: '${item.quantity}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير الكمية'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'الكمية',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final qty = int.tryParse(controller.text) ?? item.quantity;
              Navigator.pop(context);
              onQuantityChanged(qty);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خصم على المنتج'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'قيمة الخصم',
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
              final discount = double.tryParse(controller.text) ?? 0;
              Navigator.pop(context);
              onDiscountChanged(discount);
            },
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }
}

/// صف الملخص
class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${isDiscount ? '-' : ''}${value.abs().toStringAsFixed(2)} ر.س',
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDiscount ? AppColors.error : null,
                    ),
          ),
        ],
      ),
    );
  }
}
