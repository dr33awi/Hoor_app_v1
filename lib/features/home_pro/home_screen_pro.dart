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
import 'package:hoor_manager/features/home_pro/widgets/alerts_widget.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
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

                  // 3. Quick Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xl.h),
                      child: _buildQuickActionsSection(),
                    ),
                  ),

                  // 4. Main Operations Grid
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

                  // 5. Management & Reports
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding.w,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('الإدارة والتقارير'),
                          SizedBox(height: AppSpacing.md.h),
                          _buildManagementGrid(),
                          SizedBox(height: AppSpacing.huge.h),
                        ],
                      ),
                    ),
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
    final alertsAsync = ref.watch(dashboardAlertsProvider);
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
                  '${shift.totalSales.toStringAsFixed(2)} ل.س',
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 28.sp,
                    fontFeatures: const [FontFeature.tabularFigures()],
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
  // QUICK ACTIONS - Enterprise Style
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickActionsSection() {
    return SizedBox(
      height: 88.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding.w),
        children: [
          _QuickActionItem(
            icon: Icons.add_shopping_cart_rounded,
            label: 'بيع جديد',
            color: AppColors.sales,
            onTap: () => context.push('/sales/add'),
          ),
          _QuickActionItem(
            icon: Icons.inventory_2_rounded,
            label: 'شراء جديد',
            color: AppColors.purchases,
            onTap: () => context.push('/purchases/add'),
          ),
          _QuickActionItem(
            icon: Icons.add_box_rounded,
            label: 'إضافة منتج',
            color: AppColors.inventory,
            onTap: () => context.push('/products/add'),
          ),
          _QuickActionItem(
            icon: Icons.person_add_rounded,
            label: 'عميل جديد',
            color: AppColors.customers,
            onTap: () => context.push('/customers/add'),
          ),
        ],
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
          title: 'فواتير البيع',
          subtitle: 'إدارة المبيعات',
          icon: Icons.receipt_long_rounded,
          color: AppColors.sales,
          onTap: () => context.push('/invoices'),
        ),
        _ModernMenuCard(
          title: 'المشتريات',
          subtitle: 'فواتير الشراء',
          icon: Icons.shopping_bag_outlined,
          color: AppColors.purchases,
          onTap: () => context.push('/purchases'),
        ),
        _ModernMenuCard(
          title: 'المنتجات',
          subtitle: 'المخزون والأسعار',
          icon: Icons.qr_code_rounded,
          color: AppColors.inventory,
          onTap: () => context.push('/products'),
        ),
        _ModernMenuCard(
          title: 'المرتجعات',
          subtitle: 'مبيعات ومشتريات',
          icon: Icons.assignment_return_outlined,
          color: AppColors.error,
          onTap: () => context.push('/returns/sales'),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MANAGEMENT GRID - Enterprise Style
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildManagementGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: AppSpacing.xs.h,
      crossAxisSpacing: AppSpacing.xs.w,
      childAspectRatio: 0.85,
      children: [
        _SmallMenuCard(
          icon: Icons.people_alt_rounded,
          label: 'العملاء',
          color: AppColors.customers,
          onTap: () => context.push('/customers'),
        ),
        _SmallMenuCard(
          icon: Icons.local_shipping_rounded,
          label: 'الموردين',
          color: AppColors.suppliers,
          onTap: () => context.push('/suppliers'),
        ),
        _SmallMenuCard(
          icon: Icons.warehouse_rounded,
          label: 'المخازن',
          color: AppColors.inventory,
          onTap: () => context.push('/inventory'),
        ),
        _SmallMenuCard(
          icon: Icons.category_rounded,
          label: 'الأقسام',
          color: AppColors.inventory,
          onTap: () => context.push('/categories'),
        ),
        _SmallMenuCard(
          icon: Icons.bar_chart_rounded,
          label: 'التقارير',
          color: AppColors.primary,
          onTap: () => context.push('/reports'),
        ),
        _SmallMenuCard(
          icon: Icons.account_balance_wallet_rounded,
          label: 'الصندوق',
          color: AppColors.success,
          onTap: () => context.push('/cash'),
        ),
        _SmallMenuCard(
          icon: Icons.receipt_rounded,
          label: 'السندات',
          color: AppColors.secondary,
          onTap: () => context.push('/vouchers'),
        ),
        _SmallMenuCard(
          icon: Icons.settings_rounded,
          label: 'الإعدادات',
          color: AppColors.neutral,
          onTap: () => context.push('/settings'),
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

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
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
        margin: EdgeInsets.only(left: AppSpacing.sm.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              label,
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
