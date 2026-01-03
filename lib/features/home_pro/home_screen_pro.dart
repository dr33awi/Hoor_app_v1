// ═══════════════════════════════════════════════════════════════════════════
// Hoor Manager Pro - Home Screen
// A welcoming and professional home page with quick navigation
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hoor_manager/features/dashboard_pro/widgets/alerts_widget.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../dashboard_pro/widgets/pro_navigation_drawer.dart';
import 'widgets/welcome_header.dart';
import 'widgets/feature_card.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/business_overview_card.dart';

class HomeScreenPro extends ConsumerStatefulWidget {
  const HomeScreenPro({super.key});

  @override
  ConsumerState<HomeScreenPro> createState() => _HomeScreenProState();
}

class _HomeScreenProState extends ConsumerState<HomeScreenPro>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.enter,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Refresh providers
    ref.invalidate(dashboardStatsProvider);
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
        drawer: const ProNavigationDrawer(currentRoute: '/home'),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: AppColors.secondary,
                backgroundColor: AppColors.surface,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Welcome Header
                    SliverToBoxAdapter(child: _buildHeader()),

                    SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.lg.h)),

                    // Quick Stats
                    SliverToBoxAdapter(child: _buildQuickStats()),

                    SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xl.h)),

                    // Main Features Section
                    SliverToBoxAdapter(child: _buildMainFeaturesSection()),

                    SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xl.h)),

                    // Business Overview
                    SliverToBoxAdapter(child: _buildBusinessOverview()),

                    SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xl.h)),

                    // Secondary Features
                    SliverToBoxAdapter(child: _buildSecondaryFeaturesSection()),

                    // Bottom padding
                    SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.huge.h)),
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
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    final alertsAsync = ref.watch(dashboardAlertsProvider);
    final alertsCount =
        alertsAsync.whenOrNull(data: (alerts) => alerts.length) ?? 0;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.screenPadding.w),
      child: Row(
        children: [
          // Menu Button
          _buildHeaderAction(
            icon: Icons.menu_rounded,
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          SizedBox(width: AppSpacing.sm.w),

          // Welcome Header
          Expanded(
            child: WelcomeHeader(
              title: 'مرحباً بك',
              subtitle: 'في نظام Hoor Manager',
            ),
          ),

          // Action Buttons
          Row(
            children: [
              _buildHeaderAction(
                icon: Icons.notifications_outlined,
                badge: alertsCount,
                onTap: () => context.push('/alerts'),
              ),
              SizedBox(width: AppSpacing.xs.w),
              _buildHeaderAction(
                icon: Icons.settings_outlined,
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    int badge = 0,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: badge > 0
              ? Badge(
                  label: Text(badge.toString()),
                  child: Icon(
                    icon,
                    color: AppColors.textSecondary,
                    size: AppIconSize.md,
                  ),
                )
              : Icon(
                  icon,
                  color: AppColors.textSecondary,
                  size: AppIconSize.md,
                ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUICK STATS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickStats() {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding.w),
      child: statsAsync.when(
        loading: () => QuickStatsRow.loading(),
        error: (e, _) => QuickStatsRow.error(),
        data: (stats) => QuickStatsRow(
          sales: stats.todaySales,
          profit: stats.todayProfit,
          products: stats.totalProducts,
          customers: stats.totalCustomers,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN FEATURES SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMainFeaturesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'الوظائف الرئيسية',
            icon: Icons.apps_rounded,
          ),
          SizedBox(height: AppSpacing.md.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md.h,
            crossAxisSpacing: AppSpacing.md.w,
            childAspectRatio: 1.1,
            children: [
              FeatureCard(
                icon: Icons.dashboard_rounded,
                title: 'لوحة التحكم',
                subtitle: 'نظرة عامة',
                gradient: AppColors.premiumGradient,
                onTap: () => context.go('/'),
              ),
              FeatureCard(
                icon: Icons.receipt_long_rounded,
                title: 'الفواتير',
                subtitle: 'البيع والشراء',
                gradient: AppColors.incomeGradient,
                onTap: () => context.push('/invoices'),
              ),
              FeatureCard(
                icon: Icons.inventory_2_rounded,
                title: 'المنتجات',
                subtitle: 'إدارة المخزون',
                gradient: LinearGradient(
                  colors: [
                    AppColors.inventory,
                    AppColors.inventory.withValues(alpha: 0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => context.push('/products'),
              ),
              FeatureCard(
                icon: Icons.people_rounded,
                title: 'الأطراف',
                subtitle: 'العملاء والموردين',
                gradient: LinearGradient(
                  colors: [
                    AppColors.customers,
                    AppColors.customers.withValues(alpha: 0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => context.push('/parties'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUSINESS OVERVIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBusinessOverview() {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'ملخص العمل',
            icon: Icons.insights_rounded,
            action: TextButton(
              onPressed: () => context.push('/reports'),
              child: Text(
                'التقارير',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          statsAsync.when(
            loading: () => BusinessOverviewCard.loading(),
            error: (e, _) => BusinessOverviewCard.error(),
            data: (stats) => BusinessOverviewCard(
              todaySales: stats.todaySales,
              todayPurchases: stats.todayPurchases,
              todayProfit: stats.todayProfit,
              lowStockCount: stats.lowStockCount,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECONDARY FEATURES SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSecondaryFeaturesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'المزيد من الوظائف',
            icon: Icons.more_horiz_rounded,
          ),
          SizedBox(height: AppSpacing.md.h),
          _buildFeatureList(),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      _FeatureItem(
        icon: Icons.category_rounded,
        title: 'التصنيفات',
        subtitle: 'تنظيم المنتجات',
        color: AppColors.purchases,
        route: '/categories',
      ),
      _FeatureItem(
        icon: Icons.warehouse_rounded,
        title: 'المخازن',
        subtitle: 'إدارة المستودعات',
        color: AppColors.inventory,
        route: '/inventory',
      ),
      _FeatureItem(
        icon: Icons.account_balance_wallet_rounded,
        title: 'الصندوق',
        subtitle: 'المعاملات المالية',
        color: AppColors.cash,
        route: '/cash',
      ),
      _FeatureItem(
        icon: Icons.assignment_return_rounded,
        title: 'المرتجعات',
        subtitle: 'إدارة المرتجعات',
        color: AppColors.warning,
        route: '/returns',
      ),
      _FeatureItem(
        icon: Icons.access_time_rounded,
        title: 'الورديات',
        subtitle: 'جدولة العمل',
        color: AppColors.info,
        route: '/shifts',
      ),
      _FeatureItem(
        icon: Icons.backup_rounded,
        title: 'النسخ الاحتياطي',
        subtitle: 'حماية البيانات',
        color: AppColors.neutral,
        route: '/backup',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          final isLast = index == features.length - 1;

          return Column(
            children: [
              _buildFeatureListTile(feature),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: AppSpacing.lg.w + 40.w,
                  endIndent: AppSpacing.lg.w,
                  color: AppColors.border,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeatureListTile(_FeatureItem feature) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(feature.route),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg.w,
            vertical: AppSpacing.md.h,
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: feature.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  feature.icon,
                  color: feature.color,
                  size: AppIconSize.md,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: AppTypography.titleSmall,
                    ),
                    Text(
                      feature.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textTertiary,
                size: AppIconSize.md,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    Widget? action,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.xs.w),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: AppColors.secondary,
            size: AppIconSize.sm,
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/sales/add'),
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'فاتورة جديدة',
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER CLASSES
// ═══════════════════════════════════════════════════════════════════════════

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}
