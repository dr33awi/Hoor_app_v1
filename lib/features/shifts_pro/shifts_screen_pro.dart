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
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
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
                // عرض الرصيد الحالي والفرق
                Row(
                  children: [
                    Text(
                      'الرصيد الحالي: ',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(shift.openingBalance + shift.totalSales - shift.totalExpenses).toStringAsFixed(0)} ل.س',
                      style: AppTypography.labelMedium.copyWith(
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
    final totalSales = shifts.fold<double>(0.0, (sum, s) => sum + s.totalSales);
    final totalExpenses =
        shifts.fold<double>(0.0, (sum, s) => sum + s.totalExpenses);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          Expanded(
            child: ProStatCard.horizontal(
              label: 'إجمالي المبيعات',
              amount: totalSales,
              icon: Icons.trending_up_rounded,
              color: AppColors.success,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: ProStatCard.horizontal(
              label: 'إجمالي المصاريف',
              amount: totalExpenses,
              icon: Icons.trending_down_rounded,
              color: AppColors.error,
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
    final confirm = await showProConfirmDialog(
      context: context,
      title: 'فتح وردية جديدة',
      message: 'هل تريد فتح وردية جديدة؟',
      icon: Icons.play_arrow_rounded,
      iconColor: AppColors.success,
      confirmText: 'فتح',
    );

    if (confirm == true && context.mounted) {
      try {
        final shiftRepo = ref.read(shiftRepositoryProvider);
        await shiftRepo.openShift(openingBalance: 0);
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
    final confirm = await showProConfirmDialog(
      context: context,
      title: 'إغلاق الوردية',
      message: 'رصيد الافتتاح: ${shift.openingBalance.toStringAsFixed(0)} ل.س\n'
          'المبيعات: ${shift.totalSales.toStringAsFixed(0)} ل.س\n'
          'المصاريف: ${shift.totalExpenses.toStringAsFixed(0)} ل.س\n\n'
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');
    final isOpen = shift.status == 'open';
    final statusColor = isOpen ? AppColors.success : AppColors.textSecondary;

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
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'المبيعات',
                  value: '${shift.totalSales.toStringAsFixed(0)} ل.س',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'المصاريف',
                  value: '${shift.totalExpenses.toStringAsFixed(0)} ل.س',
                  color: AppColors.error,
                ),
              ),
              if (!isOpen && shift.closingBalance != null)
                Expanded(
                  child: _InfoItem(
                    label: 'الإغلاق',
                    value: '${shift.closingBalance!.toStringAsFixed(0)} ل.س',
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
  final Color? color;

  const _InfoItem({
    required this.label,
    required this.value,
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
      ],
    );
  }
}
