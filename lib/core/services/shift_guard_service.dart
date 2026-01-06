// ═══════════════════════════════════════════════════════════════════════════
// Shift Guard Service
// يتحقق من وجود ورديات مفتوحة من اليوم السابق وينبه المستخدم
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/design_tokens.dart';
import '../constants/app_constants.dart';
import '../widgets/widgets.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/shift_repository.dart';
import 'currency_service.dart';

class ShiftGuardService {
  final ShiftRepository _shiftRepository;

  ShiftGuardService(this._shiftRepository);

  /// التحقق من وجود وردية مفتوحة من يوم سابق
  Future<Shift?> checkOverdueShift() async {
    final openShift = await _shiftRepository.getOpenShift();
    if (openShift == null) return null;

    final today = DateTime.now();
    final shiftDate = openShift.openedAt;

    // التحقق إذا كانت الوردية من يوم سابق
    final isOverdue = shiftDate.year < today.year ||
        shiftDate.month < today.month ||
        shiftDate.day < today.day;

    return isOverdue ? openShift : null;
  }

  /// عرض تنبيه بوجود وردية متأخرة
  static Future<ShiftGuardAction?> showOverdueShiftDialog(
    BuildContext context,
    Shift shift,
  ) async {
    final rate = shift.exchangeRate ?? AppConstants.defaultExchangeRate;
    final currentBalance =
        shift.openingBalance + shift.totalSales - shift.totalExpenses;
    final currentBalanceUsd = (shift.openingBalanceUsd ?? 0) +
        (shift.totalSalesUsd) -
        (shift.totalExpensesUsd);

    return showDialog<ShiftGuardAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.soft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 24.sp,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وردية متأخرة',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '#${shift.shiftNumber}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.soft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: AppColors.warning, size: 18.sp),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'هذه الوردية مفتوحة منذ يوم سابق ويجب إغلاقها',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _buildInfoRow('تاريخ الفتح', _formatDateTime(shift.openedAt)),
            _buildInfoRow('الرصيد الافتتاحي',
                '${shift.openingBalance.toStringAsFixed(0)} ل.س'),
            _buildInfoRow('إجمالي المبيعات',
                '${shift.totalSales.toStringAsFixed(0)} ل.س'),
            _buildInfoRow('إجمالي المصروفات',
                '${shift.totalExpenses.toStringAsFixed(0)} ل.س'),
            Divider(color: AppColors.border, height: AppSpacing.lg),
            _buildInfoRow(
              'الرصيد الحالي',
              '${currentBalance.toStringAsFixed(0)} ل.س',
              isHighlighted: true,
            ),
            _buildInfoRow(
              'بالدولار',
              '\$${currentBalanceUsd.toStringAsFixed(2)}',
              isHighlighted: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ShiftGuardAction.later),
            child: Text(
              'لاحقاً',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ShiftGuardAction.closeNow),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('إغلاق الآن'),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: isHighlighted
                ? AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  )
                : AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

enum ShiftGuardAction {
  closeNow,
  later,
}
