// ═══════════════════════════════════════════════════════════════════════════
// Hoor Manager Pro - Home Screen
// Modern accounting app home page with clean professional design
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hoor_manager/features/home_pro/widgets/alerts_widget.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import 'widgets/pro_navigation_drawer.dart';
import 'widgets/shift_status_banner.dart';

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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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
        backgroundColor: AppColors.background,
        drawer: const ProNavigationDrawer(currentRoute: '/'),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.secondary,
              backgroundColor: AppColors.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSpacing.screenPadding.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    SizedBox(height: AppSpacing.lg.h),

                    // Shift Status
                    _buildShiftStatusBanner(),
                    SizedBox(height: AppSpacing.xl.h),

                    // Quick Actions
                    _buildQuickActions(),
                    SizedBox(height: AppSpacing.xl.h),

                    // Main Menu Grid
                    _buildMainMenuSection(),
                    SizedBox(height: AppSpacing.xl.h),

                    // Secondary Menu
                    _buildSecondaryMenuSection(),
                    SizedBox(height: AppSpacing.huge.h),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER - Clean & Simple
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    final alertsAsync = ref.watch(dashboardAlertsProvider);
    final alertsCount =
        alertsAsync.whenOrNull(data: (alerts) => alerts.length) ?? 0;

    return Row(
      children: [
        // Menu Button
        _HeaderIconButton(
          icon: Icons.menu_rounded,
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        SizedBox(width: AppSpacing.md.w),

        // Logo & Title
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.store_rounded,
            color: Colors.white,
            size: 22.sp,
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Text(
            'Hoor Manager',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Notifications
        _HeaderIconButton(
          icon: Icons.notifications_outlined,
          badge: alertsCount,
          onTap: () => context.push('/alerts'),
        ),
        SizedBox(width: AppSpacing.xs.w),
        // Settings
        _HeaderIconButton(
          icon: Icons.settings_outlined,
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHIFT STATUS BANNER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildShiftStatusBanner() {
    final shiftAsync = ref.watch(openShiftStreamProvider);

    return shiftAsync.when(
      loading: () => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (shift) => ShiftStatusBanner(
        isOpen: shift != null,
        startTime: shift != null
            ? '${shift.openedAt.hour}:${shift.openedAt.minute.toString().padLeft(2, '0')}'
            : null,
        totalSales: shift?.totalSales,
        onTap: () => context.push('/shifts'),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUICK ACTIONS - Horizontal Row
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.point_of_sale_rounded,
                label: 'نقطة البيع',
                color: AppColors.sales,
                onTap: () => context.push('/sales'),
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.receipt_long_rounded,
                label: 'فاتورة جديدة',
                color: AppColors.info,
                onTap: () => context.push('/sales/add'),
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.shopping_cart_rounded,
                label: 'مشتريات',
                color: AppColors.purchases,
                onTap: () => context.push('/purchases/add'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN MENU SECTION - All Pages Organized by Tasks
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMainMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─────────────────────────────────────────────────────────────────────
        // المبيعات والمشتريات
        // ─────────────────────────────────────────────────────────────────────
        _buildSectionTitle(
            'المبيعات والمشتريات', Icons.shopping_bag_rounded, AppColors.sales),
        SizedBox(height: AppSpacing.md.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: AppSpacing.sm.h,
          crossAxisSpacing: AppSpacing.sm.w,
          childAspectRatio: 0.85,
          children: [
            _MenuCard(
              icon: Icons.point_of_sale_rounded,
              label: 'نقطة البيع',
              color: AppColors.sales,
              onTap: () => context.push('/sales'),
            ),
            _MenuCard(
              icon: Icons.receipt_long_rounded,
              label: 'فواتير البيع',
              color: AppColors.sales,
              onTap: () => context.push('/invoices'),
            ),
            _MenuCard(
              icon: Icons.shopping_cart_rounded,
              label: 'المشتريات',
              color: AppColors.purchases,
              onTap: () => context.push('/purchases'),
            ),
            _MenuCard(
              icon: Icons.assignment_return_rounded,
              label: 'مرتجع مبيعات',
              color: AppColors.error,
              onTap: () => context.push('/returns/sales'),
            ),
            _MenuCard(
              icon: Icons.assignment_return_rounded,
              label: 'مرتجع مشتريات',
              color: AppColors.warning,
              onTap: () => context.push('/returns/purchases'),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl.h),

        // ─────────────────────────────────────────────────────────────────────
        // المخزون والمنتجات
        // ─────────────────────────────────────────────────────────────────────
        _buildSectionTitle('المخزون والمنتجات', Icons.inventory_2_rounded,
            AppColors.inventory),
        SizedBox(height: AppSpacing.md.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: AppSpacing.sm.h,
          crossAxisSpacing: AppSpacing.sm.w,
          childAspectRatio: 0.85,
          children: [
            _MenuCard(
              icon: Icons.inventory_rounded,
              label: 'المنتجات',
              color: AppColors.inventory,
              onTap: () => context.push('/products'),
            ),
            _MenuCard(
              icon: Icons.category_rounded,
              label: 'التصنيفات',
              color: AppColors.purchases,
              onTap: () => context.push('/categories'),
            ),
            _MenuCard(
              icon: Icons.warehouse_rounded,
              label: 'المخازن',
              color: AppColors.info,
              onTap: () => context.push('/inventory'),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl.h),

        // ─────────────────────────────────────────────────────────────────────
        // المالية والحسابات
        // ─────────────────────────────────────────────────────────────────────
        _buildSectionTitle('المالية والحسابات',
            Icons.account_balance_wallet_rounded, AppColors.cash),
        SizedBox(height: AppSpacing.md.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: AppSpacing.sm.h,
          crossAxisSpacing: AppSpacing.sm.w,
          childAspectRatio: 0.85,
          children: [
            _MenuCard(
              icon: Icons.payments_rounded,
              label: 'الصندوق',
              color: AppColors.cash,
              onTap: () => context.push('/cash'),
            ),
            _MenuCard(
              icon: Icons.description_rounded,
              label: 'السندات',
              color: AppColors.secondary,
              onTap: () => context.push('/vouchers'),
            ),
            _MenuCard(
              icon: Icons.people_alt_rounded,
              label: 'العملاء',
              color: AppColors.customers,
              onTap: () => context.push('/customers'),
            ),
            _MenuCard(
              icon: Icons.local_shipping_rounded,
              label: 'الموردين',
              color: AppColors.purchases,
              onTap: () => context.push('/suppliers'),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl.h),

        // ─────────────────────────────────────────────────────────────────────
        // التقارير والإدارة
        // ─────────────────────────────────────────────────────────────────────
        _buildSectionTitle(
            'التقارير والإدارة', Icons.insights_rounded, AppColors.accent),
        SizedBox(height: AppSpacing.md.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: AppSpacing.sm.h,
          crossAxisSpacing: AppSpacing.sm.w,
          childAspectRatio: 0.85,
          children: [
            _MenuCard(
              icon: Icons.bar_chart_rounded,
              label: 'التقارير',
              color: AppColors.accent,
              onTap: () => context.push('/reports'),
            ),
            _MenuCard(
              icon: Icons.access_time_rounded,
              label: 'الورديات',
              color: AppColors.info,
              onTap: () => context.push('/shifts'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECONDARY MENU SECTION - Removed (all pages now in main menu)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSecondaryMenuSection() {
    return const SizedBox.shrink();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FLOATING ACTION BUTTON
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showQuickAddMenu,
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      elevation: 4,
      child: Icon(Icons.add_rounded, size: AppIconSize.lg),
    );
  }

  void _showQuickAddMenu() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => const _QuickAddBottomSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: badge > 0
              ? Badge(
                  label: Text(badge.toString()),
                  backgroundColor: AppColors.error,
                  child:
                      Icon(icon, color: AppColors.textSecondary, size: 20.sp),
                )
              : Icon(icon, color: AppColors.textSecondary, size: 20.sp),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28.sp),
              SizedBox(height: 8.h),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryMenuItem extends StatelessWidget {
  const _SecondaryMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textTertiary,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// QUICK ADD BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _QuickAddBottomSheet extends StatelessWidget {
  const _QuickAddBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                'إنشاء جديد',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 24.h),

              // Options
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 1.0,
                children: [
                  _QuickAddItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'فاتورة بيع',
                    color: AppColors.sales,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/sales/add');
                    },
                  ),
                  _QuickAddItem(
                    icon: Icons.shopping_cart_outlined,
                    label: 'فاتورة شراء',
                    color: AppColors.purchases,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/purchases/add');
                    },
                  ),
                  _QuickAddItem(
                    icon: Icons.payments_outlined,
                    label: 'سند قبض',
                    color: AppColors.income,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/vouchers/receipt/add');
                    },
                  ),
                  _QuickAddItem(
                    icon: Icons.money_off_outlined,
                    label: 'سند صرف',
                    color: AppColors.expense,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/vouchers/payment/add');
                    },
                  ),
                  _QuickAddItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'منتج جديد',
                    color: AppColors.inventory,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/products/add');
                    },
                  ),
                  _QuickAddItem(
                    icon: Icons.person_add_outlined,
                    label: 'عميل جديد',
                    color: AppColors.customers,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/customers/add');
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddItem extends StatelessWidget {
  const _QuickAddItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28.sp),
              SizedBox(height: 8.h),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
