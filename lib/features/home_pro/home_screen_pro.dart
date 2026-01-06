// ═══════════════════════════════════════════════════════════════════════════
// Hoor Manager Pro - Home Screen
// Enterprise accounting dashboard with professional design
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hoor_manager/core/providers/alerts_provider.dart';
import 'package:hoor_manager/core/services/shift_guard_service.dart';
import 'package:hoor_manager/features/home_pro/widgets/alerts_widget.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/currency_service.dart';
import 'widgets/pro_navigation_drawer.dart';

class HomeScreenPro extends ConsumerStatefulWidget {
  const HomeScreenPro({super.key});

  @override
  ConsumerState<HomeScreenPro> createState() => _HomeScreenProState();
}

class _HomeScreenProState extends ConsumerState<HomeScreenPro>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasCheckedOverdueShift = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // التحقق من الورديات المتأخرة بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverdueShift();
    });
  }

  Future<void> _checkOverdueShift() async {
    if (_hasCheckedOverdueShift) return;
    _hasCheckedOverdueShift = true;

    final shiftRepo = ref.read(shiftRepositoryProvider);
    final shiftGuard = ShiftGuardService(shiftRepo);
    final overdueShift = await shiftGuard.checkOverdueShift();

    if (overdueShift != null && mounted) {
      final action = await ShiftGuardService.showOverdueShiftDialog(
        context,
        overdueShift,
      );

      if (action == ShiftGuardAction.closeNow && mounted) {
        // الانتقال لصفحة الورديات لإغلاق الوردية
        context.push('/shifts/${overdueShift.id}');
      }
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppDurations.slower,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.enter,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(openShiftStreamProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC), // Slate 50
        drawer: const ProNavigationDrawer(currentRoute: '/'),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Modern Header
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding.w,
                      vertical: AppSpacing.md.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildModernHeader(),
                    ),
                  ),

                  // 2. Hero Section (Shift Status)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding.w,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildHeroSection(),
                    ),
                  ),

                  // 3. Main Operations Grid
                  SliverPadding(
                    padding: EdgeInsets.all(AppSpacing.screenPadding.w),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('العمليات الرئيسية'),
                          SizedBox(height: AppSpacing.md.h),
                          _buildOperationsGrid(),
                        ],
                      ),
                    ),
                  ),

                  // Spacing at bottom
                  SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.huge.h),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ENTERPRISE HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildModernHeader() {
    final alertsAsync = ref.watch(alertsProvider);
    final alertsCount =
        alertsAsync.whenOrNull(data: (alerts) => alerts.length) ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Menu Button - Enterprise Style
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),

          // Brand
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hoor Manager',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'نظام إدارة المبيعات',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Actions - Compact
          _HeaderActionButton(
            icon: Icons.notifications_none_rounded,
            badgeCount: alertsCount,
            onTap: () => context.push('/alerts'),
          ),
          SizedBox(width: AppSpacing.xs.w),
          _HeaderActionButton(
            icon: Icons.settings_outlined,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO SECTION (SHIFT STATUS) - Enterprise Style
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroSection() {
    final shiftAsync = ref.watch(openShiftStreamProvider);

    return shiftAsync.when(
      loading: () => _buildHeroLoading(),
      error: (_, __) => const SizedBox.shrink(),
      data: (shift) {
        final isOpen = shift != null;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            color: isOpen ? AppColors.primary : AppColors.warning,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm.w,
                      vertical: AppSpacing.xs.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOpen
                              ? Icons.check_circle_rounded
                              : Icons.access_time_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isOpen ? 'الوردية مفتوحة' : 'الوردية مغلقة',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.storefront_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 24.sp,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md.h),

              if (isOpen) ...[
                Text(
                  'مبيعات الوردية',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${shift.totalSales.toStringAsFixed(0)} ل.س',
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 28.sp,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                // استخدام القيمة المحفوظة بالدولار
                Text(
                  '\$${shift.totalSalesUsd.toStringAsFixed(2)}',
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: Colors.white70,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'بدأت: ${shift.openedAt.hour}:${shift.openedAt.minute.toString().padLeft(2, '0')}',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  'لا توجد وردية نشطة',
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'ابدأ وردية جديدة لتتمكن من إجراء عمليات البيع',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                TextButton.icon(
                  onPressed: () => context.push('/shifts'),
                  icon: Icon(Icons.play_arrow_rounded, size: 16.sp),
                  label: const Text('فتح وردية'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.warning,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md.w,
                      vertical: AppSpacing.xs.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroLoading() {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OPERATIONS GRID - Enterprise Style
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildOperationsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm.h,
      crossAxisSpacing: AppSpacing.sm.w,
      childAspectRatio: 1.6,
      children: [
        _ModernMenuCard(
          title: 'الفواتير',
          subtitle: 'عرض جميع الفواتير',
          icon: Icons.receipt_long_rounded,
          color: AppColors.primary,
          onTap: () => _showAllInvoicesOptions(),
        ),
        _ModernMenuCard(
          title: 'إنشاء فاتورة',
          subtitle: 'فاتورة جديدة',
          icon: Icons.add_circle_outline_rounded,
          color: AppColors.success,
          onTap: () => _showCreateInvoiceOptions(),
        ),
        _ModernMenuCard(
          title: 'الأطراف',
          subtitle: 'العملاء والموردين',
          icon: Icons.groups_rounded,
          color: AppColors.customers,
          onTap: () => _showPartiesOptions(),
        ),
        _ModernMenuCard(
          title: 'السندات',
          subtitle: 'القبض والصرف',
          icon: Icons.receipt_rounded,
          color: AppColors.secondary,
          onTap: () => _showVouchersOptions(),
        ),
        _ModernMenuCard(
          title: 'المنتجات والمخزون',
          subtitle: 'المنتجات والأقسام والمخازن',
          icon: Icons.inventory_2_rounded,
          color: AppColors.inventory,
          onTap: () => _showInventoryOptions(),
        ),
        _ModernMenuCard(
          title: 'المصاريف',
          subtitle: 'إدارة المصاريف اليومية',
          icon: Icons.receipt_long_rounded,
          color: AppColors.expense,
          onTap: () => context.push('/expenses'),
        ),
        _ModernMenuCard(
          title: 'الصندوق والورديات',
          subtitle: 'إدارة الصندوق والورديات',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.success,
          onTap: () => _showCashAndShiftsOptions(),
        ),
        _ModernMenuCard(
          title: 'التقارير',
          subtitle: 'تقارير المبيعات والأرباح',
          icon: Icons.bar_chart_rounded,
          color: AppColors.primary,
          onTap: () => context.push('/reports'),
        ),
      ],
    );
  }

  void _showAllInvoicesOptions() {
    _showOptionsSheet(
      title: 'الفواتير',
      color: AppColors.primary,
      options: [
        _OptionItem(
          icon: Icons.receipt_long,
          title: 'فواتير البيع',
          subtitle: 'عرض جميع فواتير المبيعات',
          route: '/invoices',
          color: AppColors.sales,
        ),
        _OptionItem(
          icon: Icons.shopping_bag,
          title: 'فواتير الشراء',
          subtitle: 'عرض جميع فواتير المشتريات',
          route: '/purchases',
          color: AppColors.purchases,
        ),
        _OptionItem(
          icon: Icons.assignment_return,
          title: 'مرتجعات البيع',
          subtitle: 'عرض مرتجعات فواتير البيع',
          route: '/returns/sales',
          color: AppColors.warning,
        ),
        _OptionItem(
          icon: Icons.assignment_return,
          title: 'مرتجعات الشراء',
          subtitle: 'عرض مرتجعات فواتير الشراء',
          route: '/returns/purchases',
          color: AppColors.error,
        ),
      ],
    );
  }

  void _showCreateInvoiceOptions() {
    _showOptionsSheet(
      title: 'إنشاء فاتورة',
      color: AppColors.success,
      options: [
        _OptionItem(
          icon: Icons.add_shopping_cart,
          title: 'فاتورة مبيعات',
          subtitle: 'إنشاء فاتورة بيع جديدة',
          route: '/sales/add',
          color: AppColors.sales,
        ),
        _OptionItem(
          icon: Icons.add_business,
          title: 'فاتورة مشتريات',
          subtitle: 'إنشاء فاتورة شراء جديدة',
          route: '/purchases/add',
          color: AppColors.purchases,
        ),
        _OptionItem(
          icon: Icons.remove_shopping_cart,
          title: 'مرتجع مبيعات',
          subtitle: 'إنشاء فاتورة مرتجع بيع',
          route: '/returns/sales/add',
          color: AppColors.warning,
        ),
        _OptionItem(
          icon: Icons.assignment_return,
          title: 'مرتجع مشتريات',
          subtitle: 'إنشاء فاتورة مرتجع شراء',
          route: '/returns/purchases/add',
          color: AppColors.error,
        ),
      ],
    );
  }

  void _showVouchersOptions() {
    _showOptionsSheet(
      title: 'السندات',
      color: AppColors.secondary,
      options: [
        _OptionItem(
          icon: Icons.list_alt,
          title: 'عرض السندات',
          subtitle: 'جميع سندات القبض والصرف',
          route: '/vouchers',
          color: AppColors.secondary,
        ),
        _OptionItem(
          icon: Icons.add_card,
          title: 'سند قبض',
          subtitle: 'إنشاء سند قبض جديد',
          route: '/vouchers/receipt/add',
          color: AppColors.success,
        ),
        _OptionItem(
          icon: Icons.credit_card_off,
          title: 'سند صرف',
          subtitle: 'إنشاء سند صرف جديد',
          route: '/vouchers/payment/add',
          color: AppColors.error,
        ),
      ],
    );
  }

  void _showPartiesOptions() {
    _showOptionsSheet(
      title: 'الأطراف',
      color: AppColors.customers,
      options: [
        _OptionItem(
          icon: Icons.people_alt,
          title: 'العملاء',
          subtitle: 'عرض وإدارة العملاء',
          route: '/customers',
          color: AppColors.customers,
        ),
        _OptionItem(
          icon: Icons.person_add,
          title: 'إضافة عميل',
          subtitle: 'إنشاء عميل جديد',
          route: '/customers/add',
          color: AppColors.success,
        ),
        _OptionItem(
          icon: Icons.local_shipping,
          title: 'الموردين',
          subtitle: 'عرض وإدارة الموردين',
          route: '/suppliers',
          color: AppColors.suppliers,
        ),
        _OptionItem(
          icon: Icons.person_add_alt_1,
          title: 'إضافة مورد',
          subtitle: 'إنشاء مورد جديد',
          route: '/suppliers/add',
          color: AppColors.success,
        ),
      ],
    );
  }

  void _showInventoryOptions() {
    _showOptionsSheet(
      title: 'المنتجات والمخزون',
      color: AppColors.inventory,
      options: [
        _OptionItem(
          icon: Icons.qr_code_rounded,
          title: 'المنتجات',
          subtitle: 'عرض وإدارة المنتجات',
          route: '/products',
          color: AppColors.inventory,
        ),
        _OptionItem(
          icon: Icons.add_box_rounded,
          title: 'إضافة منتج',
          subtitle: 'إنشاء منتج جديد',
          route: '/products/add',
          color: AppColors.success,
        ),
        _OptionItem(
          icon: Icons.category_rounded,
          title: 'الأقسام',
          subtitle: 'إدارة أقسام المنتجات',
          route: '/categories',
          color: AppColors.primary,
        ),
        _OptionItem(
          icon: Icons.warehouse_rounded,
          title: 'المخازن',
          subtitle: 'إدارة المخزون والمستودعات',
          route: '/inventory',
          color: AppColors.secondary,
        ),
      ],
    );
  }

  void _showCashAndShiftsOptions() {
    _showOptionsSheet(
      title: 'الصندوق والورديات',
      color: AppColors.success,
      options: [
        _OptionItem(
          icon: Icons.account_balance_wallet_rounded,
          title: 'الصندوق',
          subtitle: 'عرض رصيد الصندوق',
          route: '/cash',
          color: AppColors.success,
        ),
        _OptionItem(
          icon: Icons.schedule_rounded,
          title: 'الورديات',
          subtitle: 'عرض جميع الورديات',
          route: '/shifts',
          color: AppColors.secondary,
        ),
      ],
    );
  }

  void _showOptionsSheet({
    required String title,
    required Color color,
    required List<_OptionItem> options,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: AppSpacing.md.h),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              ...options.map((option) => ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: (option.color ?? color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(option.icon, color: option.color ?? color),
                    ),
                    title: Text(option.title),
                    subtitle: Text(option.subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      context.push(option.route);
                    },
                  )),
              SizedBox(height: AppSpacing.md.h),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MANAGEMENT GRID - Enterprise Style
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildManagementGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: AppSpacing.xs.h,
      crossAxisSpacing: AppSpacing.xs.w,
      childAspectRatio: 1.1,
      children: [
        _SmallMenuCard(
          icon: Icons.bar_chart_rounded,
          label: 'التقارير',
          color: AppColors.primary,
          onTap: () => context.push('/reports'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(1.5.r),
          ),
        ),
        SizedBox(width: AppSpacing.xs.w),
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS - Enterprise Style
// ═══════════════════════════════════════════════════════════════════════════

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 18.sp),
            if (badgeCount > 0)
              Positioned(
                top: 6.h,
                right: 6.w,
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModernMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModernMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmallMenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color? color;

  const _OptionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    this.color,
  });
}
