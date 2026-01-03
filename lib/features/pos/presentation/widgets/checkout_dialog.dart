import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/pos_provider.dart';

/// حوار الدفع
class CheckoutDialog extends StatefulWidget {
  final double total;
  final int? customerId;

  const CheckoutDialog({
    super.key,
    required this.total,
    this.customerId,
  });

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  String _paymentMethod = 'cash';
  final _receivedController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isProcessing = false;

  double get _receivedAmount => double.tryParse(_receivedController.text) ?? 0;
  double get _change => _receivedAmount - widget.total;

  @override
  void initState() {
    super.initState();
    _receivedController.text = widget.total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxWidth: 400.w),
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Row(
                children: [
                  Icon(Icons.payment, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Text(
                    'إتمام الدفع',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              Divider(height: 24.h),

              // المبلغ المطلوب
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'المبلغ المطلوب',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${widget.total.toStringAsFixed(2)} ر.س',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // طريقة الدفع
              Text(
                'طريقة الدفع',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _PaymentMethodButton(
                    icon: Icons.payments,
                    label: 'نقدي',
                    isSelected: _paymentMethod == 'cash',
                    onTap: () => setState(() => _paymentMethod = 'cash'),
                  ),
                  SizedBox(width: 8.w),
                  _PaymentMethodButton(
                    icon: Icons.credit_card,
                    label: 'بطاقة',
                    isSelected: _paymentMethod == 'card',
                    onTap: () => setState(() => _paymentMethod = 'card'),
                  ),
                  SizedBox(width: 8.w),
                  _PaymentMethodButton(
                    icon: Icons.account_balance_wallet,
                    label: 'تحويل',
                    isSelected: _paymentMethod == 'transfer',
                    onTap: () => setState(() => _paymentMethod = 'transfer'),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // المبلغ المستلم (للدفع النقدي)
              if (_paymentMethod == 'cash') ...[
                Text(
                  'المبلغ المستلم',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _receivedController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    suffixText: 'ر.س',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                SizedBox(height: 16.h),

                // الأزرار السريعة
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _QuickAmountButton(
                      amount: widget.total,
                      onTap: () => _setReceivedAmount(widget.total),
                    ),
                    _QuickAmountButton(
                      amount: (widget.total / 10).ceil() * 10,
                      onTap: () =>
                          _setReceivedAmount((widget.total / 10).ceil() * 10),
                    ),
                    _QuickAmountButton(
                      amount: (widget.total / 50).ceil() * 50,
                      onTap: () =>
                          _setReceivedAmount((widget.total / 50).ceil() * 50),
                    ),
                    _QuickAmountButton(
                      amount: (widget.total / 100).ceil() * 100,
                      onTap: () =>
                          _setReceivedAmount((widget.total / 100).ceil() * 100),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // الباقي
                if (_change >= 0)
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الباقي',
                          style: TextStyle(color: AppColors.success),
                        ),
                        Text(
                          '${_change.toStringAsFixed(2)} ر.س',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المتبقي',
                          style: TextStyle(color: AppColors.error),
                        ),
                        Text(
                          '${(-_change).toStringAsFixed(2)} ر.س',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              SizedBox(height: 16.h),

              // ملاحظات
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // أزرار الإجراءات
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: _isProcessing ? 'جاري المعالجة...' : 'إتمام الدفع',
                      onPressed: _canCheckout() ? _checkout : null,
                      icon: Icons.check,
                      isLoading: _isProcessing,
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

  bool _canCheckout() {
    if (_isProcessing) return false;
    if (_paymentMethod == 'cash' && _receivedAmount < widget.total) {
      return false;
    }
    return true;
  }

  void _setReceivedAmount(double amount) {
    _receivedController.text = amount.toStringAsFixed(2);
    setState(() {});
  }

  Future<void> _checkout() async {
    setState(() => _isProcessing = true);

    // محاكاة وقت المعالجة
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pop(
        context,
        CheckoutResult(
          success: true,
          paymentMethod: _paymentMethod,
          receivedAmount:
              _paymentMethod == 'cash' ? _receivedAmount : widget.total,
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
        ),
      );
    }
  }
}

/// زر طريقة الدفع
class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر المبلغ السريع
class _QuickAmountButton extends StatelessWidget {
  final double amount;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${amount.toStringAsFixed(0)} ر.س',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}
