// ═══════════════════════════════════════════════════════════════════════════
// Shift Details Screen Pro - Enterprise Accounting Design
// Shift Details View with Ledger Precision
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../data/database/app_database.dart';

class ShiftDetailsScreenPro extends ConsumerStatefulWidget {
  final String shiftId;

  const ShiftDetailsScreenPro({super.key, required this.shiftId});

  @override
  ConsumerState<ShiftDetailsScreenPro> createState() =>
      _ShiftDetailsScreenProState();
}

class _ShiftDetailsScreenProState extends ConsumerState<ShiftDetailsScreenPro> {
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>>? _topProducts;
  Map<String, dynamic>? _profitReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final shiftRepo = ref.read(shiftRepositoryProvider);

      debugPrint('Loading shift summary for: ${widget.shiftId}');
      final summary = await shiftRepo.getShiftSummary(widget.shiftId);
      debugPrint('Summary loaded successfully');

      // تحميل أكثر المنتجات مبيعاً
      List<Map<String, dynamic>> topProducts = [];
      try {
        topProducts = await shiftRepo.getTopSellingProducts(
          shiftId: widget.shiftId,
          limit: 10,
        );
        debugPrint('Top products loaded: ${topProducts.length}');
      } catch (e) {
        debugPrint('Error loading top products: $e');
      }

      // تحميل تقرير الأرباح
      Map<String, dynamic>? profitReport;
      try {
        profitReport = await shiftRepo.getProfitReport(
          shiftId: widget.shiftId,
        );
        debugPrint('Profit report loaded');
      } catch (e) {
        debugPrint('Error loading profit report: $e');
      }

      setState(() {
        _summary = summary;
        _topProducts = topProducts;
        _profitReport = profitReport;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error loading shift details: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Shift ID: ${widget.shiftId}');
      setState(() => _isLoading = false);
    }
  }

  String _formatPrice(double price, {double? priceUsd, double? rate}) {
    final syp = '${NumberFormat('#,###').format(price)} ل.س';
    // استخدام القيمة المحفوظة بالدولار إن وجدت، وإلا حسابها من سعر الصرف المحفوظ
    final shift = _summary?['shift'] as Shift?;
    final exchangeRate =
        rate ?? shift?.exchangeRate ?? AppConstants.defaultExchangeRate;
    final usdValue = priceUsd ?? (price / exchangeRate);
    final usd = '\$${usdValue.toStringAsFixed(2)}';
    return '$syp ($usd)';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ مراقبة تغييرات الفواتير والسندات للتحديث التلقائي
    ref.listen(invoicesStreamProvider, (previous, next) {
      if (previous?.value != null && next.value != null) {
        if (previous!.value!.length != next.value!.length) {
          _loadData(); // إعادة تحميل ملخص الوردية عند إضافة/حذف فاتورة
        }
      }
    });

    ref.listen(vouchersStreamProvider, (previous, next) {
      if (previous?.value != null && next.value != null) {
        if (previous!.value!.length != next.value!.length) {
          _loadData(); // إعادة تحميل ملخص الوردية عند إضافة/حذف سند
        }
      }
    });

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: ProLoadingState.card(),
      );
    }

    if (_summary == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildSimpleHeader(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 64.sp, color: AppColors.textSecondary),
                      SizedBox(height: AppSpacing.md),
                      Text('الوردية غير موجودة',
                          style: AppTypography.titleMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final shift = _summary!['shift'] as Shift;
    final movements = _summary!['movements'] as List<CashMovement>;
    final invoices = _summary!['invoices'] as List<Invoice>? ?? [];
    final vouchers = _summary!['vouchers'] as List<Voucher>? ?? [];
    final isOpen = shift.status == 'open';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(shift, isOpen),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  _buildStatsGrid(),
                  SizedBox(height: AppSpacing.md),

                  // Profit Report Card
                  if (_profitReport != null) ...[
                    _buildProfitReportCard(),
                    SizedBox(height: AppSpacing.md),
                  ],

                  // Top Selling Products
                  if (_topProducts != null && _topProducts!.isNotEmpty) ...[
                    _buildTopProductsSection(),
                    SizedBox(height: AppSpacing.md),
                  ],

                  // Payment Method Analysis
                  if (_summary!['salesCount'] > 0) ...[
                    _buildPaymentMethodAnalysis(),
                    SizedBox(height: AppSpacing.md),
                  ],

                  // Hourly Sales Analysis
                  if (_summary!['salesCount'] > 0) ...[
                    _buildHourlySalesAnalysis(),
                    SizedBox(height: AppSpacing.md),
                  ],

                  // Financial Summary
                  _buildFinancialSummary(shift),
                  SizedBox(height: AppSpacing.md),

                  // Detailed Report Sections
                  _buildDetailedReportSection(),
                  SizedBox(height: AppSpacing.md),

                  // Closing Info (if closed)
                  if (!isOpen) ...[
                    _buildClosingInfo(shift),
                    SizedBox(height: AppSpacing.md),
                  ],

                  // Invoices Section
                  if (invoices.isNotEmpty) ...[
                    _buildInvoicesSection(invoices),
                    SizedBox(height: AppSpacing.md),
                  ],

                  // Vouchers Section
                  if (vouchers.isNotEmpty) ...[
                    _buildVouchersSection(vouchers),
                    SizedBox(height: AppSpacing.md),
                  ],

                  // Cash Movements
                  _buildMovementsSection(movements),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textSecondary),
          ),
          Text('تفاصيل الوردية', style: AppTypography.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildAppBar(Shift shift, bool isOpen) {
    final statusColor = isOpen ? AppColors.success : AppColors.textSecondary;

    return SliverAppBar(
      expandedHeight: 180.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: Colors.white.light,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.overlayHeavy,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.light,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        isOpen ? 'مفتوحة' : 'مغلقة',
                        style: AppTypography.labelMedium
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.sm),

                // Shift Number
                Text(
                  shift.shiftNumber,
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),

                // Date
                Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'ar').format(shift.openedAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.overlayHeavy,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),

                // Time Chips + Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeChip(
                      icon: Icons.login_rounded,
                      label: 'فتح',
                      time: DateFormat('HH:mm').format(shift.openedAt),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    _buildTimeChip(
                      icon: Icons.schedule_rounded,
                      label: 'المدة',
                      time: _formatDuration(shift),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    if (shift.closedAt != null)
                      _buildTimeChip(
                        icon: Icons.logout_rounded,
                        label: 'إغلاق',
                        time: DateFormat('HH:mm').format(shift.closedAt!),
                      )
                    else
                      _buildTimeChip(
                        icon: Icons.receipt_long_rounded,
                        label: 'معاملات',
                        time: '${shift.transactionCount}',
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Shift shift) {
    final endTime = shift.closedAt ?? DateTime.now();
    final duration = endTime.difference(shift.openedAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hoursس $minutesد';
    }
    return '$minutes دقيقة';
  }

  Widget _buildTimeChip({
    required IconData icon,
    required String label,
    required String time,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.muted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            '$label: $time',
            style: AppTypography.labelSmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.receipt_long_rounded,
                label: 'المبيعات',
                value: '${_summary!['salesCount'] ?? 0}',
                color: AppColors.success,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.shopping_cart_rounded,
                label: 'المشتريات',
                value: '${_summary!['purchasesCount'] ?? 0}',
                color: AppColors.warning,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.assignment_return_rounded,
                label: 'المرتجعات',
                value: '${_summary!['returnsCount'] ?? 0}',
                color: AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.arrow_downward_rounded,
                label: 'سندات قبض',
                value: '${_summary!['receiptsCount'] ?? 0}',
                color: AppColors.info,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.arrow_upward_rounded,
                label: 'سندات دفع',
                value: '${_summary!['paymentsCount'] ?? 0}',
                color: AppColors.secondary,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.swap_horiz_rounded,
                label: 'الحركات',
                value: '${(_summary!['movements'] as List).length}',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.soft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// بطاقة تقرير الأرباح
  Widget _buildProfitReportCard() {
    final report = _profitReport!;
    final netProfit = report['netProfit'] as double? ?? 0;
    final grossProfit = report['grossProfit'] as double? ?? 0;
    final profitMargin = report['profitMargin'] as double? ?? 0;
    final totalRevenue = report['totalRevenue'] as double? ?? 0;
    final totalExpenses = report['totalExpenses'] as double? ?? 0;
    final totalReturns = report['totalReturns'] as double? ?? 0;

    final shift = _summary!['shift'] as Shift;
    final rate = shift.exchangeRate ?? AppConstants.defaultExchangeRate;

    final isProfit = netProfit >= 0;
    final profitColor = isProfit ? AppColors.success : AppColors.error;

    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: profitColor.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  isProfit
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: profitColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'تقرير الأرباح',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4.h),
                decoration: BoxDecoration(
                  color: profitColor.soft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${profitMargin.toStringAsFixed(1)}%',
                  style: AppTypography.labelMedium.copyWith(
                    color: profitColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // صافي الربح - بارز
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  profitColor.withOpacity(0.1),
                  profitColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: profitColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isProfit ? 'صافي الربح' : 'صافي الخسارة',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(netProfit.abs())} ل.س',
                      style: AppTypography.headlineMedium.copyWith(
                        color: profitColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${(netProfit.abs() / rate).toStringAsFixed(2)}',
                  style: AppTypography.titleLarge.copyWith(
                    color: profitColor.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // تفاصيل
          Row(
            children: [
              Expanded(
                child: _buildProfitDetailItem(
                  label: 'إجمالي الإيرادات',
                  value: totalRevenue,
                  rate: rate,
                  color: AppColors.success,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildProfitDetailItem(
                  label: 'إجمالي الربح',
                  value: grossProfit,
                  rate: rate,
                  color: AppColors.info,
                  icon: Icons.show_chart_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildProfitDetailItem(
                  label: 'المصروفات',
                  value: totalExpenses,
                  rate: rate,
                  color: AppColors.warning,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildProfitDetailItem(
                  label: 'المرتجعات',
                  value: totalReturns,
                  rate: rate,
                  color: AppColors.error,
                  icon: Icons.assignment_return_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitDetailItem({
    required String label,
    required double value,
    required double rate,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${NumberFormat('#,###').format(value)}',
                  style: AppTypography.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// قسم أكثر المنتجات مبيعاً
  Widget _buildTopProductsSection() {
    return ProCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.soft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 20.sp),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'أكثر المنتجات مبيعاً',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.soft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'أفضل ${_topProducts!.length}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _topProducts!.length,
            separatorBuilder: (_, __) =>
                Divider(color: AppColors.border, height: 1),
            itemBuilder: (context, index) {
              final product = _topProducts![index];
              return _buildTopProductItem(product, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductItem(Map<String, dynamic> product, int rank) {
    final productName = product['productName'] as String? ?? 'منتج';
    final totalQuantity = product['totalQuantity'] as int? ?? 0;
    final totalRevenue = product['totalRevenue'] as double? ?? 0;
    final totalRevenueUsd = product['totalRevenueUsd'] as double? ?? 0;
    final totalProfit = product['totalProfit'] as double? ?? 0;
    final invoiceCount = product['invoiceCount'] as int? ?? 0;

    Color rankColor;
    IconData rankIcon;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // ذهبي
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // فضي
      rankIcon = Icons.workspace_premium_rounded;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // برونزي
      rankIcon = Icons.military_tech_rounded;
    } else {
      rankColor = AppColors.textSecondary;
      rankIcon = Icons.tag_rounded;
    }

    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          // الترتيب
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color:
                  rank <= 3 ? rankColor.withOpacity(0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: rank <= 3 ? rankColor : AppColors.border,
                width: rank <= 3 ? 2 : 1,
              ),
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(rankIcon, color: rankColor, size: 18.sp)
                  : Text(
                      '$rank',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // اسم المنتج والتفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 12.sp, color: AppColors.textSecondary),
                    SizedBox(width: 2.w),
                    Text(
                      '$totalQuantity قطعة',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Icon(Icons.receipt_outlined,
                        size: 12.sp, color: AppColors.textSecondary),
                    SizedBox(width: 2.w),
                    Text(
                      '$invoiceCount فاتورة',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // الإيرادات والربح
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${NumberFormat('#,###').format(totalRevenue)}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${totalRevenueUsd.toStringAsFixed(2)}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (totalProfit > 0)
                Text(
                  'ربح: ${NumberFormat('#,###').format(totalProfit)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(Shift shift) {
    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.account_balance_wallet_rounded,
                    color: AppColors.primary, size: 20.sp),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'الملخص المالي',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildFinancialRow(
            label: 'الرصيد الافتتاحي',
            value: shift.openingBalance,
            valueUsd: shift.openingBalanceUsd,
            icon: Icons.account_balance_rounded,
            color: AppColors.primary,
          ),
          Divider(color: AppColors.border, height: AppSpacing.md),
          _buildFinancialRow(
            label: 'إجمالي المبيعات',
            value: shift.totalSales,
            valueUsd: shift.totalSalesUsd,
            icon: Icons.trending_up_rounded,
            color: AppColors.success,
            showPlus: true,
          ),
          _buildFinancialRow(
            label: 'إجمالي المرتجعات',
            value: shift.totalReturns,
            valueUsd: shift.totalReturnsUsd,
            icon: Icons.trending_down_rounded,
            color: AppColors.error,
            showMinus: true,
          ),
          _buildFinancialRow(
            label: 'الإيرادات الأخرى',
            value: shift.totalIncome,
            valueUsd: shift.totalIncomeUsd,
            icon: Icons.add_circle_rounded,
            color: AppColors.success,
            showPlus: true,
          ),
          _buildFinancialRow(
            label: 'المصروفات',
            value: shift.totalExpenses,
            valueUsd: shift.totalExpensesUsd,
            icon: Icons.remove_circle_rounded,
            color: AppColors.error,
            showMinus: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow({
    required String label,
    required double value,
    double? valueUsd,
    required IconData icon,
    required Color color,
    bool showPlus = false,
    bool showMinus = false,
  }) {
    String prefix = '';
    if (showPlus && value > 0) prefix = '+';
    if (showMinus && value > 0) prefix = '-';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label, style: AppTypography.bodyMedium),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prefix${_formatPrice(value)}',
                style: AppTypography.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (valueUsd != null && valueUsd > 0)
                Text(
                  '\$${valueUsd.toStringAsFixed(2)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClosingInfo(Shift shift) {
    final difference = shift.difference ?? 0;
    final isPositive = difference >= 0;

    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 20.sp),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'معلومات الإغلاق',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildClosingItem(
                  label: 'المتوقع',
                  value: shift.expectedBalance ?? 0,
                  valueUsd: shift.expectedBalanceUsd,
                  color: AppColors.info,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildClosingItem(
                  label: 'الفعلي',
                  value: shift.closingBalance ?? 0,
                  valueUsd: shift.closingBalanceUsd,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.success : AppColors.error).soft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive
                      ? Icons.check_circle_rounded
                      : Icons.warning_rounded,
                  color: isPositive ? AppColors.success : AppColors.error,
                  size: 20.sp,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'الفرق: ',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                ),
                Text(
                  '${isPositive && difference > 0 ? '+' : ''}${_formatPrice(difference)}',
                  style: AppTypography.titleMedium.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingItem({
    required String label,
    required double value,
    double? valueUsd,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _formatPrice(value),
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (valueUsd != null)
            Text(
              '\$${valueUsd.toStringAsFixed(2)}',
              style: AppTypography.labelSmall.copyWith(
                color: color.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMovementsSection(List<CashMovement> movements) {
    return ProCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.soft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.swap_vert_rounded,
                      color: AppColors.secondary, size: 20.sp),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'حركات الصندوق',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.soft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '${movements.length} حركة',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (movements.isEmpty)
            Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 48.sp, color: AppColors.textSecondary),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'لا توجد حركات',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Divider(color: AppColors.border, height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: movements.take(20).length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.border, height: 1),
              itemBuilder: (context, index) {
                final movement = movements[index];
                return _buildMovementItem(movement);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMovementItem(CashMovement movement) {
    final isIncome = movement.type == 'income' || movement.type == 'sale';

    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: (isIncome ? AppColors.success : AppColors.error).soft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isIncome ? AppColors.success : AppColors.error,
              size: 18.sp,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.description,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('HH:mm').format(movement.createdAt),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${_formatPrice(movement.amount)}',
            style: AppTypography.titleSmall.copyWith(
              color: isIncome ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// قسم التقرير التفصيلي
  Widget _buildDetailedReportSection() {
    final shift = _summary!['shift'] as Shift;
    final rate = shift.exchangeRate ?? AppConstants.defaultExchangeRate;

    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.info.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.analytics_rounded,
                    color: AppColors.info, size: 20.sp),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'التقرير التفصيلي',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // فواتير المبيعات
          _buildReportRow(
            label: 'فواتير المبيعات',
            count: _summary!['salesCount'] ?? 0,
            amount: _summary!['totalSalesAmount'] ?? 0.0,
            amountUsd: _summary!['totalSalesUsd'] ?? 0.0,
            color: AppColors.success,
            icon: Icons.receipt_rounded,
          ),

          // فواتير المشتريات
          _buildReportRow(
            label: 'فواتير المشتريات',
            count: _summary!['purchasesCount'] ?? 0,
            amount: _summary!['totalPurchasesAmount'] ?? 0.0,
            amountUsd: _summary!['totalPurchasesUsd'] ?? 0.0,
            color: AppColors.warning,
            icon: Icons.shopping_cart_rounded,
          ),

          // مرتجعات المبيعات
          _buildReportRow(
            label: 'مرتجعات المبيعات',
            count: _summary!['returnsCount'] ?? 0,
            amount: _summary!['totalSaleReturnsAmount'] ?? 0.0,
            amountUsd: _summary!['totalSaleReturnsUsd'] ?? 0.0,
            color: AppColors.error,
            icon: Icons.assignment_return_rounded,
          ),

          // مرتجعات المشتريات
          _buildReportRow(
            label: 'مرتجعات المشتريات',
            count: _summary!['purchaseReturnsCount'] ?? 0,
            amount: _summary!['totalPurchaseReturnsAmount'] ?? 0.0,
            amountUsd: _summary!['totalPurchaseReturnsUsd'] ?? 0.0,
            color: AppColors.secondary,
            icon: Icons.assignment_returned_rounded,
          ),

          Divider(color: AppColors.border, height: AppSpacing.lg),

          // سندات القبض
          _buildReportRow(
            label: 'سندات القبض',
            count: _summary!['receiptsCount'] ?? 0,
            amount: _summary!['totalReceiptsAmount'] ?? 0.0,
            amountUsd: _summary!['totalReceiptsUsd'] ?? 0.0,
            color: AppColors.success,
            icon: Icons.arrow_downward_rounded,
          ),

          // سندات الدفع
          _buildReportRow(
            label: 'سندات الدفع',
            count: _summary!['paymentsCount'] ?? 0,
            amount: _summary!['totalPaymentsAmount'] ?? 0.0,
            amountUsd: _summary!['totalPaymentsUsd'] ?? 0.0,
            color: AppColors.error,
            icon: Icons.arrow_upward_rounded,
          ),

          // المصروفات
          _buildReportRow(
            label: 'المصروفات',
            count: _summary!['expensesCount'] ?? 0,
            amount: _summary!['totalExpensesAmount'] ?? 0.0,
            amountUsd: _summary!['totalExpensesUsd'] ?? 0.0,
            color: AppColors.error,
            icon: Icons.money_off_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow({
    required String label,
    required int count,
    required double amount,
    required double amountUsd,
    required Color color,
    required IconData icon,
  }) {
    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: color.soft,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$label ($count)',
              style: AppTypography.bodyMedium,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${amount.toStringAsFixed(0)} ل.س',
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${amountUsd.toStringAsFixed(2)}',
                style: AppTypography.labelSmall.copyWith(
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// تحليل المبيعات حسب طريقة الدفع
  Widget _buildPaymentMethodAnalysis() {
    final analysis =
        _summary!['paymentMethodAnalysis'] as Map<String, dynamic>?;
    if (analysis == null) return const SizedBox.shrink();

    final cashTotal = analysis['cashTotal'] as double? ?? 0;
    final cashTotalUsd = analysis['cashTotalUsd'] as double? ?? 0;
    final cashCount = analysis['cashCount'] as int? ?? 0;
    final cashPercentage = analysis['cashPercentage'] as double? ?? 0;

    final creditTotal = analysis['creditTotal'] as double? ?? 0;
    final creditTotalUsd = analysis['creditTotalUsd'] as double? ?? 0;
    final creditCount = analysis['creditCount'] as int? ?? 0;
    final creditPercentage = analysis['creditPercentage'] as double? ?? 0;

    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.payments_rounded,
                    color: AppColors.success, size: 20.sp),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'تحليل طرق الدفع',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Row(
              children: [
                if (cashPercentage > 0)
                  Expanded(
                    flex: cashPercentage.round(),
                    child: Container(
                      height: 8.h,
                      color: AppColors.success,
                    ),
                  ),
                if (creditPercentage > 0)
                  Expanded(
                    flex: creditPercentage.round(),
                    child: Container(
                      height: 8.h,
                      color: AppColors.warning,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Cash vs Credit Cards
          Row(
            children: [
              Expanded(
                child: _buildPaymentMethodCard(
                  icon: Icons.attach_money_rounded,
                  label: 'نقدي',
                  count: cashCount,
                  total: cashTotal,
                  totalUsd: cashTotalUsd,
                  percentage: cashPercentage,
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPaymentMethodCard(
                  icon: Icons.credit_card_rounded,
                  label: 'آجل',
                  count: creditCount,
                  total: creditTotal,
                  totalUsd: creditTotalUsd,
                  percentage: creditPercentage,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String label,
    required int count,
    required double total,
    required double totalUsd,
    required double percentage,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: color),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            '$count فاتورة',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${NumberFormat('#,###').format(total)} ل.س',
            style: AppTypography.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$${totalUsd.toStringAsFixed(2)}',
            style: AppTypography.labelSmall.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// تحليل المبيعات حسب الساعة
  Widget _buildHourlySalesAnalysis() {
    final hourlyData =
        _summary!['hourlyAnalysis'] as Map<int, Map<String, dynamic>>?;
    if (hourlyData == null || hourlyData.isEmpty)
      return const SizedBox.shrink();

    // حساب أعلى قيمة للعرض النسبي
    double maxTotal = 0;
    hourlyData.forEach((_, data) {
      final total = data['total'] as double? ?? 0;
      if (total > maxTotal) maxTotal = total;
    });

    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.soft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.schedule_rounded,
                    color: AppColors.primary, size: 20.sp),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'توزيع المبيعات بالساعة',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // Hourly Bars
          ...hourlyData.entries.map((entry) {
            final hour = entry.key;
            final count = entry.value['count'] as int? ?? 0;
            final total = entry.value['total'] as double? ?? 0;
            final totalUsd = entry.value['totalUsd'] as double? ?? 0;
            final percentage = maxTotal > 0 ? (total / maxTotal) : 0.0;

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 40.w,
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 20.h,
                        backgroundColor: AppColors.border.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation(
                          count > 0 ? AppColors.primary : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 90.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$count فاتورة',
                          style: AppTypography.labelSmall.copyWith(
                            color: count > 0
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight:
                                count > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (total > 0)
                          Text(
                            '\$${totalUsd.toStringAsFixed(0)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// قسم الفواتير
  Widget _buildInvoicesSection(List<Invoice> invoices) {
    return ProCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.success.soft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: AppColors.success, size: 20.sp),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'الفواتير',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.soft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '${invoices.length} فاتورة',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoices.take(10).length,
            separatorBuilder: (_, __) =>
                Divider(color: AppColors.border, height: 1),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return _buildInvoiceItem(invoice);
            },
          ),
          if (invoices.length > 10)
            Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Center(
                child: Text(
                  '... و ${invoices.length - 10} فاتورة أخرى',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(Invoice invoice) {
    final rate = invoice.exchangeRate ?? AppConstants.defaultExchangeRate;
    final totalUsd = invoice.totalUsd ?? (invoice.total / rate);
    final isSale = invoice.type == 'sale';
    final isReturn = invoice.type.contains('return');

    Color typeColor;
    String typeLabel;
    if (invoice.type == 'sale') {
      typeColor = AppColors.success;
      typeLabel = 'مبيعات';
    } else if (invoice.type == 'purchase') {
      typeColor = AppColors.warning;
      typeLabel = 'مشتريات';
    } else if (invoice.type == 'sale_return') {
      typeColor = AppColors.error;
      typeLabel = 'مرتجع مبيعات';
    } else {
      typeColor = AppColors.secondary;
      typeLabel = 'مرتجع مشتريات';
    }

    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: typeColor.soft,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(
              isReturn
                  ? Icons.assignment_return_rounded
                  : Icons.receipt_rounded,
              color: typeColor,
              size: 16.sp,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${invoice.invoiceNumber}',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.soft,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: typeColor,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('HH:mm').format(invoice.createdAt),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${invoice.total.toStringAsFixed(0)} ل.س',
                style: AppTypography.labelMedium.copyWith(
                  color: typeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${totalUsd.toStringAsFixed(2)}',
                style: AppTypography.labelSmall.copyWith(
                  color: typeColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// قسم السندات
  Widget _buildVouchersSection(List<Voucher> vouchers) {
    return ProCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.soft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.description_rounded,
                      color: AppColors.warning, size: 20.sp),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'السندات',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.soft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '${vouchers.length} سند',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vouchers.take(10).length,
            separatorBuilder: (_, __) =>
                Divider(color: AppColors.border, height: 1),
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
              return _buildVoucherItem(voucher);
            },
          ),
          if (vouchers.length > 10)
            Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Center(
                child: Text(
                  '... و ${vouchers.length - 10} سند آخر',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoucherItem(Voucher voucher) {
    final rate = voucher.exchangeRate ?? AppConstants.defaultExchangeRate;
    final amountUsd = voucher.amountUsd ?? (voucher.amount / rate);

    Color typeColor;
    String typeLabel;
    IconData typeIcon;
    if (voucher.type == 'receipt') {
      typeColor = AppColors.success;
      typeLabel = 'قبض';
      typeIcon = Icons.arrow_downward_rounded;
    } else if (voucher.type == 'payment') {
      typeColor = AppColors.error;
      typeLabel = 'دفع';
      typeIcon = Icons.arrow_upward_rounded;
    } else {
      typeColor = AppColors.warning;
      typeLabel = 'مصروف';
      typeIcon = Icons.money_off_rounded;
    }

    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: typeColor.soft,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(typeIcon, color: typeColor, size: 16.sp),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${voucher.voucherNumber}',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.soft,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: typeColor,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                if (voucher.description != null &&
                    voucher.description!.isNotEmpty)
                  Text(
                    voucher.description!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${voucher.amount.toStringAsFixed(0)} ل.س',
                style: AppTypography.labelMedium.copyWith(
                  color: typeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${amountUsd.toStringAsFixed(2)}',
                style: AppTypography.labelSmall.copyWith(
                  color: typeColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
