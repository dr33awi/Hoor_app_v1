// ═══════════════════════════════════════════════════════════════════════════
// Shifts Screen Pro - Enterprise Design System
// Shift Management Interface
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/services/printing/invoice_pdf_generator.dart';
import '../../core/services/currency_service.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/dual_price_display.dart';
import '../../core/services/export/export_button.dart';
import '../../core/services/export/export_services.dart';
import '../../core/services/printing/print_menu_button.dart';
import '../../data/database/app_database.dart';

class ShiftsScreenPro extends ConsumerStatefulWidget {
  const ShiftsScreenPro({super.key});

  @override
  ConsumerState<ShiftsScreenPro> createState() => _ShiftsScreenProState();
}

class _ShiftsScreenProState extends ConsumerState<ShiftsScreenPro> {
  DateTimeRange? _dateRange;
  bool _isExporting = false;
  // ignore: unused_field - Reserved for print state
  bool _isPrinting = false;

  List<Shift> _filterShifts(List<Shift> shifts) {
    if (_dateRange == null) return shifts;

    return shifts.where((s) {
      return s.openedAt
              .isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
          s.openedAt.isBefore(_dateRange!.end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final shiftsAsync = ref.watch(shiftsStreamProvider);
    final openShiftAsync = ref.watch(openShiftStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: shiftsAsync.when(
          loading: () => ProLoadingState.list(),
          error: (error, stack) => ProEmptyState.error(error: error.toString()),
          data: (shifts) {
            final openShift = openShiftAsync.asData?.value;
            final filteredShifts = _filterShifts(shifts);

            return Column(
              children: [
                _buildHeader(context, filteredShifts),
                if (openShift != null)
                  _buildOpenShiftBanner(context, ref, openShift),
                _buildStatsSummary(filteredShifts),
                Expanded(child: _buildShiftsList(filteredShifts)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: openShiftAsync.asData?.value == null
          ? FloatingActionButton.extended(
              onPressed: () => _openNewShift(context, ref),
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                'فتح وردية',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, List<Shift> shifts) {
    return ProHeader(
      title: 'الورديات',
      subtitle: '${shifts.length} وردية${_dateRange != null ? ' (مصفى)' : ''}',
      onBack: () => context.go('/'),
      actions: [
        // فلتر التاريخ
        Badge(
          isLabelVisible: _dateRange != null,
          child: IconButton(
            onPressed: () => _showDateFilter(),
            icon: const Icon(Icons.date_range_rounded),
            tooltip: 'تصفية حسب التاريخ',
          ),
        ),
        // زر الطباعة الموحد
        PrintMenuButton(
          onPrint: (type, [size]) => _handlePrint(type, size, shifts),
          showSizeSelector: true,
          enabledOptions: const {
            PrintType.print,
            PrintType.share,
            PrintType.save,
            PrintType.preview,
          },
          tooltip: 'طباعة',
        ),
        // زر التصدير الموحد
        ExportMenuButton(
          onExport: (type) => _handleExport(type, shifts),
          isLoading: _isExporting,
          icon: Icons.ios_share_rounded,
          tooltip: 'تصدير',
          enabledOptions: const {
            ExportType.excel,
            ExportType.pdf,
            ExportType.sharePdf,
            ExportType.shareExcel,
          },
        ),
      ],
    );
  }

  Widget _buildOpenShiftBanner(
      BuildContext context, WidgetRef ref, Shift shift) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');

    return Container(
      margin: EdgeInsets.all(AppSpacing.screenPadding),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: AppColors.success,
              size: 20.sp,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وردية مفتوحة #${shift.shiftNumber}',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'منذ ${dateFormat.format(shift.openedAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                // عرض الرصيد الحالي والفرق - باستخدام سعر الصرف المحفوظ
                Row(
                  children: [
                    Text(
                      'الرصيد الحالي: ',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    CompactDualPrice(
                      amountSyp: shift.openingBalance +
                          shift.totalSales -
                          shift.totalExpenses,
                      // استخدام سعر الصرف المحفوظ مع الوردية
                      exchangeRate:
                          shift.exchangeRate ?? CurrencyService.currentRate,
                      sypStyle: AppTypography.labelMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _closeShift(context, ref, shift),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
            ),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showDateFilter() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      initialDateRange: _dateRange,
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  Future<void> _handlePrint(
      PrintType type, InvoicePrintSize? size, List<Shift> shifts) async {
    if (shifts.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد ورديات للطباعة');
      return;
    }

    setState(() => _isPrinting = true);
    final fileName =
        'الورديات_${DateFormat('yyyyMMdd').format(DateTime.now())}';

    try {
      final pdfBytes =
          await PdfExportService.generateShiftsList(shifts: shifts);

      switch (type) {
        case PrintType.print:
          await Printing.layoutPdf(
            onLayout: (format) async => pdfBytes,
            name: fileName,
          );
          break;
        case PrintType.share:
          await PdfExportService.sharePdfBytes(
            pdfBytes,
            fileName: fileName,
            subject: 'قائمة الورديات',
          );
          break;
        case PrintType.save:
          await PdfExportService.savePdfFile(pdfBytes, fileName);
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case PrintType.preview:
          break;
      }
    } catch (e) {
      if (mounted) ProSnackbar.error(context, 'حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Future<void> _handleExport(ExportType type, List<Shift> shifts) async {
    if (shifts.isEmpty) {
      ProSnackbar.warning(context, 'لا توجد ورديات للتصدير');
      return;
    }

    setState(() => _isExporting = true);
    final fileName =
        'الورديات_${DateFormat('yyyyMMdd').format(DateTime.now())}';

    try {
      switch (type) {
        case ExportType.excel:
          await ExcelExportService.exportShifts(
            shifts: shifts,
            fileName: fileName,
          );
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.pdf:
          final pdfBytes = await PdfExportService.generateShiftsList(
            shifts: shifts,
          );
          await PdfExportService.savePdfFile(pdfBytes, fileName);
          if (mounted) ProSnackbar.success(context, 'تم حفظ الملف بنجاح');
          break;
        case ExportType.sharePdf:
          final pdfBytes = await PdfExportService.generateShiftsList(
            shifts: shifts,
          );
          await PdfExportService.sharePdfBytes(
            pdfBytes,
            fileName: fileName,
            subject: 'قائمة الورديات',
          );
          break;
        case ExportType.shareExcel:
          final filePath = await ExcelExportService.exportShifts(
            shifts: shifts,
            fileName: fileName,
          );
          await ExcelExportService.shareFile(filePath,
              subject: 'قائمة الورديات');
          break;
      }
    } catch (e) {
      if (mounted) ProSnackbar.error(context, 'حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildStatsSummary(List<Shift> shifts) {
    // إجماليات بالليرة
    final totalSales = shifts.fold<double>(0.0, (sum, s) => sum + s.totalSales);
    final totalIncome =
        shifts.fold<double>(0.0, (sum, s) => sum + s.totalIncome);
    final totalExpenses =
        shifts.fold<double>(0.0, (sum, s) => sum + s.totalExpenses);
    final totalReturns =
        shifts.fold<double>(0.0, (sum, s) => sum + s.totalReturns);

    // صافي الربح = المبيعات + الإيرادات - المصروفات - المرتجعات
    final netProfit = totalSales + totalIncome - totalExpenses - totalReturns;

    // إجماليات بالدولار
    final totalSalesUsd = shifts.fold<double>(0.0, (sum, s) {
      if (s.totalSalesUsd > 0) return sum + s.totalSalesUsd;
      if (s.exchangeRate != null && s.exchangeRate! > 0) {
        return sum + (s.totalSales / s.exchangeRate!);
      }
      return sum;
    });

    final totalIncomeUsd = shifts.fold<double>(0.0, (sum, s) {
      if (s.totalIncomeUsd > 0) return sum + s.totalIncomeUsd;
      if (s.exchangeRate != null && s.exchangeRate! > 0) {
        return sum + (s.totalIncome / s.exchangeRate!);
      }
      return sum;
    });

    final totalExpensesUsd = shifts.fold<double>(0.0, (sum, s) {
      if (s.totalExpensesUsd > 0) return sum + s.totalExpensesUsd;
      if (s.exchangeRate != null && s.exchangeRate! > 0) {
        return sum + (s.totalExpenses / s.exchangeRate!);
      }
      return sum;
    });

    final totalReturnsUsd = shifts.fold<double>(0.0, (sum, s) {
      if (s.totalReturnsUsd > 0) return sum + s.totalReturnsUsd;
      if (s.exchangeRate != null && s.exchangeRate! > 0) {
        return sum + (s.totalReturns / s.exchangeRate!);
      }
      return sum;
    });

    final netProfitUsd =
        totalSalesUsd + totalIncomeUsd - totalExpensesUsd - totalReturnsUsd;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          // الصف الأول: المبيعات والإيرادات
          Row(
            children: [
              Expanded(
                child: ProStatCard.horizontal(
                  label: 'المبيعات',
                  amount: totalSales,
                  amountUsd: totalSalesUsd > 0 ? totalSalesUsd : null,
                  icon: Icons.point_of_sale_rounded,
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: ProStatCard.horizontal(
                  label: 'الإيرادات',
                  amount: totalIncome,
                  amountUsd: totalIncomeUsd > 0 ? totalIncomeUsd : null,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          // الصف الثاني: المصروفات والمرتجعات
          Row(
            children: [
              Expanded(
                child: ProStatCard.horizontal(
                  label: 'المصروفات',
                  amount: totalExpenses,
                  amountUsd: totalExpensesUsd > 0 ? totalExpensesUsd : null,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: ProStatCard.horizontal(
                  label: 'المرتجعات',
                  amount: totalReturns,
                  amountUsd: totalReturnsUsd > 0 ? totalReturnsUsd : null,
                  icon: Icons.undo_rounded,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          // صافي الربح
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: netProfit >= 0
                  ? AppColors.success.soft
                  : AppColors.error.soft,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: netProfit >= 0
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      netProfit >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color:
                          netProfit >= 0 ? AppColors.success : AppColors.error,
                      size: 20.sp,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'صافي الربح',
                      style: AppTypography.titleSmall.copyWith(
                        color: netProfit >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${netProfit.toStringAsFixed(0)} ل.س',
                      style: AppTypography.titleMedium.copyWith(
                        color: netProfit >= 0
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (netProfitUsd != 0)
                      Text(
                        '\$${netProfitUsd.toStringAsFixed(2)}',
                        style: AppTypography.labelSmall.copyWith(
                          color: (netProfit >= 0
                                  ? AppColors.success
                                  : AppColors.error)
                              .withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsList(List<Shift> shifts) {
    if (shifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 80.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'لا يوجد ورديات',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Sort by date descending
    final sortedShifts = List<Shift>.from(shifts)
      ..sort((a, b) => b.openedAt.compareTo(a.openedAt));

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: sortedShifts.length,
      itemBuilder: (context, index) {
        final shift = sortedShifts[index];
        return _ShiftCard(shift: shift);
      },
    );
  }

  void _openNewShift(BuildContext context, WidgetRef ref) async {
    // الحصول على الرصيد الافتتاحي الافتراضي من آخر وردية مغلقة
    final shiftRepo = ref.read(shiftRepositoryProvider);
    final shifts = await shiftRepo.getAllShifts();
    final closedShifts = shifts.where((s) => s.status == 'closed').toList()
      ..sort((a, b) =>
          (b.closedAt ?? b.openedAt).compareTo(a.closedAt ?? a.openedAt));
    final lastClosingBalance = closedShifts.isNotEmpty
        ? (closedShifts.first.closingBalance ?? 0)
        : 0.0;

    // إظهار ديالوغ إدخال الرصيد الافتتاحي
    if (!context.mounted) return;

    final balanceController = TextEditingController(
      text: lastClosingBalance > 0 ? lastClosingBalance.toStringAsFixed(0) : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.soft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.play_arrow_rounded, color: AppColors.success),
            ),
            SizedBox(width: AppSpacing.sm),
            const Text('فتح وردية جديدة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lastClosingBalance > 0) ...[
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.info.soft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.info, size: 18.sp),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'رصيد إغلاق الوردية السابقة: ${lastClosingBalance.toStringAsFixed(0)} ل.س',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
            ],
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الرصيد الافتتاحي',
                hintText: 'أدخل الرصيد الافتتاحي',
                suffixText: 'ل.س',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final balance = double.tryParse(balanceController.text) ?? 0;
              Navigator.pop(context, balance);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('فتح الوردية'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      try {
        await shiftRepo.openShift(openingBalance: result);
        if (context.mounted) {
          ProSnackbar.success(context, 'تم فتح الوردية بنجاح');
        }
      } catch (e) {
        if (context.mounted) {
          ProSnackbar.error(context, 'خطأ: $e');
        }
      }
    }
  }

  void _closeShift(BuildContext context, WidgetRef ref, Shift shift) async {
    // استخدام القيم المحفوظة بالدولار
    final openingUsd = shift.openingBalanceUsd ??
        (shift.openingBalance /
            (shift.exchangeRate ?? CurrencyService.currentRate));
    final salesUsd = shift.totalSalesUsd;
    final expensesUsd = shift.totalExpensesUsd;

    final confirm = await showProConfirmDialog(
      context: context,
      title: 'إغلاق الوردية',
      message:
          'رصيد الافتتاح: ${shift.openingBalance.toStringAsFixed(0)} ل.س (\$${openingUsd.toStringAsFixed(2)})\n'
          'المبيعات: ${shift.totalSales.toStringAsFixed(0)} ل.س (\$${salesUsd.toStringAsFixed(2)})\n'
          'المصاريف: ${shift.totalExpenses.toStringAsFixed(0)} ل.س (\$${expensesUsd.toStringAsFixed(2)})\n\n'
          'هل تريد إغلاق الوردية؟',
      icon: Icons.stop_rounded,
      isDanger: true,
      confirmText: 'إغلاق',
    );

    if (confirm == true && context.mounted) {
      try {
        final shiftRepo = ref.read(shiftRepositoryProvider);
        final closingBalance =
            shift.openingBalance + shift.totalSales - shift.totalExpenses;
        await shiftRepo.closeShift(
          shiftId: shift.id,
          closingBalance: closingBalance,
        );
        if (context.mounted) {
          ProSnackbar.success(context, 'تم إغلاق الوردية بنجاح');
        }
      } catch (e) {
        if (context.mounted) {
          ProSnackbar.error(context, 'خطأ: $e');
        }
      }
    }
  }
}

class _ShiftCard extends StatelessWidget {
  final Shift shift;

  const _ShiftCard({required this.shift});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours س $minutes د';
    }
    return '$minutes دقيقة';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd HH:mm', 'ar');
    final isOpen = shift.status == 'open';
    final statusColor = isOpen ? AppColors.success : AppColors.textSecondary;
    // استخدام سعر الصرف المحفوظ مع الوردية أو الحالي كـ fallback
    final rate = shift.exchangeRate ?? CurrencyService.currentRate;

    // حساب مدة الوردية
    final endTime = shift.closedAt ?? DateTime.now();
    final duration = endTime.difference(shift.openedAt);

    // حساب صافي الوردية
    final netBalance = shift.totalSales +
        shift.totalIncome -
        shift.totalExpenses -
        shift.totalReturns;
    final netBalanceUsd = shift.totalSalesUsd +
        shift.totalIncomeUsd -
        shift.totalExpensesUsd -
        shift.totalReturnsUsd;

    return ProCard(
      onTap: () => context.push('/shifts/${shift.id}'),
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: statusColor.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  isOpen
                      ? Icons.access_time_rounded
                      : Icons.check_circle_rounded,
                  color: statusColor,
                  size: AppIconSize.sm,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${shift.shiftNumber}',
                          style: AppTypography.titleSmall
                              .copyWith(
                                color: AppColors.textPrimary,
                              )
                              .monoSemibold,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        ProStatusBadge.fromShiftStatus(shift.status,
                            small: true),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          dateFormat.format(shift.openedAt),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Icon(Icons.schedule,
                            size: 12.sp, color: AppColors.textTertiary),
                        SizedBox(width: 2.w),
                        Text(
                          _formatDuration(duration),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (shift.transactionCount > 0) ...[
                          SizedBox(width: AppSpacing.sm),
                          Icon(Icons.receipt_long,
                              size: 12.sp, color: AppColors.textTertiary),
                          SizedBox(width: 2.w),
                          Text(
                            '${shift.transactionCount}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // صافي الوردية
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${netBalance >= 0 ? "+" : ""}${netBalance.toStringAsFixed(0)}',
                    style: AppTypography.titleSmall.copyWith(
                      color:
                          netBalance >= 0 ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${netBalanceUsd.toStringAsFixed(1)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: (netBalance >= 0
                              ? AppColors.success
                              : AppColors.error)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          // شريط تفصيلي مختصر
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                _MiniStat('افتتاح', shift.openingBalance, null),
                _MiniStat('مبيعات', shift.totalSales, AppColors.success),
                _MiniStat('إيرادات', shift.totalIncome, AppColors.info),
                _MiniStat('مصروفات', shift.totalExpenses, AppColors.warning),
                _MiniStat('مرتجعات', shift.totalReturns, AppColors.error),
                if (!isOpen && shift.closingBalance != null)
                  _MiniStat('إغلاق', shift.closingBalance!, null),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;

  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 8.sp,
            ),
          ),
          Text(
            value.toStringAsFixed(0),
            style: AppTypography.labelSmall.copyWith(
              color: color ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftCardOld extends StatelessWidget {
  final Shift shift;

  const _ShiftCardOld({required this.shift});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');
    final isOpen = shift.status == 'open';
    final statusColor = isOpen ? AppColors.success : AppColors.textSecondary;
    // استخدام سعر الصرف المحفوظ مع الوردية أو الحالي كـ fallback
    final rate = shift.exchangeRate ?? CurrencyService.currentRate;

    return ProCard(
      onTap: () => context.push('/shifts/${shift.id}'),
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: statusColor.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  isOpen
                      ? Icons.access_time_rounded
                      : Icons.check_circle_rounded,
                  color: statusColor,
                  size: AppIconSize.sm,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${shift.shiftNumber}',
                          style: AppTypography.titleSmall
                              .copyWith(
                                color: AppColors.textPrimary,
                              )
                              .monoSemibold,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        ProStatusBadge.fromShiftStatus(shift.status,
                            small: true),
                      ],
                    ),
                    Text(
                      dateFormat.format(shift.openedAt),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'الافتتاح',
                  value: '${shift.openingBalance.toStringAsFixed(0)} ل.س',
                  usdValue: shift.openingBalanceUsd != null
                      ? '\$${shift.openingBalanceUsd!.toStringAsFixed(2)}'
                      : '\$${(shift.openingBalance / rate).toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'المبيعات',
                  value: '${shift.totalSales.toStringAsFixed(0)} ل.س',
                  usdValue: shift.totalSalesUsd > 0
                      ? '\$${shift.totalSalesUsd.toStringAsFixed(2)}'
                      : '\$${(shift.totalSales / rate).toStringAsFixed(2)}',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'المصاريف',
                  value: '${shift.totalExpenses.toStringAsFixed(0)} ل.س',
                  usdValue: shift.totalExpensesUsd > 0
                      ? '\$${shift.totalExpensesUsd.toStringAsFixed(2)}'
                      : '\$${(shift.totalExpenses / rate).toStringAsFixed(2)}',
                  color: AppColors.error,
                ),
              ),
              if (!isOpen && shift.closingBalance != null)
                Expanded(
                  child: _InfoItem(
                    label: 'الإغلاق',
                    value: '${shift.closingBalance!.toStringAsFixed(0)} ل.س',
                    usdValue: shift.closingBalanceUsd != null
                        ? '\$${shift.closingBalanceUsd!.toStringAsFixed(2)}'
                        : '\$${(shift.closingBalance! / rate).toStringAsFixed(2)}',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final String? usdValue;
  final Color? color;

  const _InfoItem({
    required this.label,
    required this.value,
    this.usdValue,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelMedium
              .copyWith(
                color: color ?? AppColors.textPrimary,
              )
              .mono,
        ),
        if (usdValue != null)
          Text(
            usdValue!,
            style: AppTypography.labelSmall.copyWith(
              color: (color ?? AppColors.textPrimary).withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }
}
