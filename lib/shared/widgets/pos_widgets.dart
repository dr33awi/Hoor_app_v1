import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/config/app_config.dart';

/// عرض السعر بالعملة
class PriceText extends StatelessWidget {
  final double price;
  final String? currency;
  final TextStyle? style;
  final Color? color;
  final bool showCurrency;
  final bool compact;

  const PriceText({
    super.key,
    required this.price,
    this.currency,
    this.style,
    this.color,
    this.showCurrency = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol = currency ?? AppConfig.defaultCurrency;
    final formattedPrice = _formatPrice(price);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formattedPrice,
          style: style ??
              (compact
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      )
                  : Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      )),
        ),
        if (showCurrency) ...[
          SizedBox(width: 4.w),
          Text(
            currencySymbol,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color ?? AppColors.textSecondary,
                ),
          ),
        ],
      ],
    );
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return price
        .toStringAsFixed(AppConfig.defaultDecimalPlaces)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// بطاقة منتج للـ POS
class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final String? imageUrl;
  final double? stock;
  final bool isLowStock;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    this.stock,
    this.isLowStock = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة المنتج
            Expanded(
              flex: 3,
              child: Container(
                color: AppColors.surfaceVariant,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            // معلومات المنتج
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PriceText(price: price, compact: true),
                        if (stock != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isLowStock
                                  ? AppColors.errorLight
                                  : AppColors.successLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${stock!.toInt()}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: isLowStock
                                        ? AppColors.error
                                        : AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
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

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 32.sp,
        color: AppColors.textHint,
      ),
    );
  }
}

/// عنصر سلة التسوق
class CartItemWidget extends StatelessWidget {
  final String name;
  final double price;
  final double quantity;
  final double total;
  final double? discount;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final Function(int)? onQuantityChanged;
  final Function(double)? onDiscountChanged;

  const CartItemWidget({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    this.discount,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
    this.onTap,
    this.onQuantityChanged,
    this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // الكمية وأزرار التحكم
              Column(
                children: [
                  InkWell(
                    onTap: onIncrement,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.add,
                          size: 18.sp, color: AppColors.primary),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Text(
                      quantity.toInt().toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  InkWell(
                    onTap: onDecrement,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.remove, size: 18.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              // معلومات المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        PriceText(price: price, compact: true),
                        if (discount != null && discount! > 0) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${discount!.toStringAsFixed(0)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.error,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // الإجمالي وزر الحذف
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriceText(
                    price: total,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: onRemove,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18.sp,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ملخص الفاتورة
class InvoiceSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String? currency;

  const InvoiceSummary({
    super.key,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRow(context, 'المجموع', subtotal),
          if (discount > 0) ...[
            SizedBox(height: 8.h),
            _buildRow(context, 'الخصم', -discount, color: AppColors.error),
          ],
          if (tax > 0) ...[
            SizedBox(height: 8.h),
            _buildRow(context, 'الضريبة', tax),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Divider(),
          ),
          _buildRow(
            context,
            'الإجمالي',
            total,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, double value,
      {Color? color, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyMedium,
        ),
        PriceText(
          price: value,
          currency: currency,
          color: color ?? (isTotal ? AppColors.primary : null),
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  )
              : null,
        ),
      ],
    );
  }
}

/// شريحة الفئة
class CategoryChip extends StatelessWidget {
  final String name;
  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;
  final int? count;

  const CategoryChip({
    super.key,
    required this.name,
    this.color,
    this.isSelected = false,
    this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chipColor,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : chipColor,
                  ),
            ),
            if (count != null) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : chipColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected ? Colors.white : chipColor,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// شريط تقدم المخزون
class StockProgressBar extends StatelessWidget {
  final double current;
  final double max;
  final double lowThreshold;

  const StockProgressBar({
    super.key,
    required this.current,
    required this.max,
    this.lowThreshold = 10,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final color = current <= lowThreshold
        ? AppColors.stockLow
        : current <= lowThreshold * 2
            ? AppColors.stockMedium
            : AppColors.stockGood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المخزون',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              '${current.toInt()} / ${max.toInt()}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6.h,
          ),
        ),
      ],
    );
  }
}
