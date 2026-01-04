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
  // MODERN HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildModernHeader() {
    final alertsAsync = ref.watch(dashboardAlertsProvider);
    final alertsCount =
        alertsAsync.whenOrNull(data: (alerts) => alerts.length) ?? 0;

    return Row(
      children: [
        // Profile / Menu
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.menu_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md.w),

        // Welcome Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك 👋',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Hoor Manager',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),

        // Actions
        Row(
          children: [
            _HeaderActionButton(
              icon: Icons.notifications_outlined,
              badgeCount: alertsCount,
              onTap: () => context.push('/alerts'),
            ),
            SizedBox(width: AppSpacing.sm.w),
            _HeaderActionButton(
              icon: Icons.settings_outlined,
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO SECTION (SHIFT STATUS)
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
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOpen
                  ? [const Color(0xFF0F172A), const Color(0xFF334155)]
                  : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: (isOpen ? AppColors.primary : AppColors.warning)
                    .withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOpen
                              ? Icons.check_circle_rounded
                              : Icons.access_time_filled_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          isOpen ? 'الوردية مفتوحة' : 'الوردية مغلقة',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.storefront_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 28.sp,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              if (isOpen) ...[
                Text(
                  'مبيعات الوردية الحالية',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${shift.totalSales.toStringAsFixed(2)} ر.س',
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        color: Colors.white70, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'بدأت منذ: ${shift.openedAt.hour}:${shift.openedAt.minute.toString().padLeft(2, '0')}',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  'لا توجد وردية نشطة حالياً',
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'ابدأ وردية جديدة لتتمكن من إجراء عمليات البيع وتسجيل الحركات المالية',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: () => context.push('/shifts'),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('فتح وردية جديدة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.warning,
                    elevation: 0,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
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
      height: 180.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24.r),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUICK ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickActionsSection() {
    return SizedBox(
      height: 110.h,
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
  // OPERATIONS GRID
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildOperationsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 1.5,
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
  // MANAGEMENT GRID
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildManagementGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 0.8,
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
          onTap: () => context.push('/warehouses'),
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
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
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
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22.sp),
            if (badgeCount > 0)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  width: 8.w,
                  height: 8.w,
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
        margin: EdgeInsets.only(left: 16.w),
        child: Column(
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
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
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11.sp,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
