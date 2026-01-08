// ═══════════════════════════════════════════════════════════════════════════
// Pro Navigation Drawer - Enterprise Accounting Design
// القائمة الجانبية الموحدة
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hoor_manager/core/theme/design_tokens.dart';

class ProNavigationDrawer extends StatelessWidget {
  final String? currentRoute;
  final VoidCallback? onClose;

  const ProNavigationDrawer({
    super.key,
    this.currentRoute,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // ═══════════════════════════════════════════════════════════════
            // Header - الشعار والعنوان
            // ═══════════════════════════════════════════════════════════════
            _buildHeader(context),

            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),

            // ═══════════════════════════════════════════════════════════════
            // Navigation Items - عناصر التنقل
            // ═══════════════════════════════════════════════════════════════
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ─────────────────────────────────────────────────────────
                  // الرئيسية
                  // ─────────────────────────────────────────────────────────
                  _NavSection(
                    title: 'الرئيسية',
                    children: [
                      _NavItem(
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard_rounded,
                        label: 'الشاشة الرئيسية',
                        route: '/',
                        currentRoute: currentRoute,
                      ),
                    ],
                  ),

                  // ─────────────────────────────────────────────────────────
                  // المبيعات والعملاء
                  // ─────────────────────────────────────────────────────────
                  _NavSection(
                    title: 'المبيعات',
                    children: [
                      _NavItem(
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long_rounded,
                        label: 'الفواتير',
                        route: '/invoices',
                        currentRoute: currentRoute,
                      ),
                      _NavItem(
                        icon: Icons.add_shopping_cart_outlined,
                        activeIcon: Icons.add_shopping_cart_rounded,
                        label: 'فاتورة بيع جديدة',
                        route: '/sales/add',
                        currentRoute: currentRoute,
                        highlight: true,
                      ),
                      _NavItem(
                        icon: Icons.people_outline_rounded,
                        activeIcon: Icons.people_rounded,
                        label: 'العملاء',
                        route: '/customers',
                        currentRoute: currentRoute,
                      ),
                    ],
                  ),

                  // ─────────────────────────────────────────────────────────
                  // المشتريات والموردين
                  // ─────────────────────────────────────────────────────────
                  _NavSection(
                    title: 'المشتريات',
                    children: [
                      _NavItem(
                        icon: Icons.shopping_cart_outlined,
                        activeIcon: Icons.shopping_cart_rounded,
                        label: 'فواتير المشتريات',
                        route: '/purchases',
                        currentRoute: currentRoute,
                      ),
                      _NavItem(
                        icon: Icons.local_shipping_outlined,
                        activeIcon: Icons.local_shipping_rounded,
                        label: 'الموردين',
                        route: '/suppliers',
                        currentRoute: currentRoute,
                      ),
                    ],
                  ),

                  // ─────────────────────────────────────────────────────────
                  // المرتجعات
                  // ─────────────────────────────────────────────────────────
                  _NavSection(
                    title: 'المرتجعات',
                    children: [
                      _NavItem(
                        icon: Icons.assignment_return_outlined,
                        activeIcon: Icons.assignment_return_rounded,
                        label: 'مرتجعات المبيعات',
                        route: '/returns/sales',
                        currentRoute: currentRoute,
                      ),
                      _NavItem(
                        icon: Icons.keyboard_return_outlined,
                        activeIcon: Icons.keyboard_return_rounded,
                        label: 'مرتجعات المشتريات',
                        route: '/returns/purchases',
                        currentRoute: currentRoute,
                      ),
                    ],
                  ),

                  // ─────────────────────────────────────────────────────────
                  // المخزون
                  // ─────────────────────────────────────────────────────────
                  _NavSection(
                    title: 'المخزون',
                    children: [
                      _NavItem(
                        icon: Icons.inventory_2_outlined,
                        activeIcon: Icons.inventory_2_rounded,
                        label: 'المنتجات',
                        route: '/products',
                        currentRoute: currentRoute,
                      ),
                      _NavItem(
                        icon: Icons.category_outlined,
                        activeIcon: Icons.category_rounded,
                        label: 'التصنيفات',
                        route: '/categories',
                        currentRoute: currentRoute,
                      ),
                      _NavItem(
                        icon: Icons.warehouse_outlined,
                        activeIcon: Icons.warehouse_rounded,
                        label: 'المستودعات',
                        route: '/warehouses',
                        currentRoute: currentRoute,
                      ),
                    ],
                  ),

                  // ─────────────────────────────────────────────────────────
                  // المحاسبة والمالية
                  // ─────────────────────────────────────────────────────────
                  _NavSection(
                    title: 'المحاسبة',
                    children: [
                      _NavItem(
                        icon: Icons.account_balance_wallet_outlined,
                        activeIcon: Icons.account_balance_wallet_rounded,
                        label: 'السندات',
                        route: '/vouchers',
                        currentRoute: currentRoute,
                      ),
                      _NavItem(
                        icon: Icons.payments_outlined,
                        activeIcon: Icons.payments_rounded,
                        label: 'المصروفات',
                        route: '/expenses',
                        currentRoute: currentRoute,
                      ),
                      _NavItem(
                        icon: Icons.schedule_outlined,
                        activeIcon: Icons.schedule_rounded,
                        label: 'الورديات',
                        route: '/shifts',
                        currentRoute: currentRoute,
                      ),
                    ],
                  ),

                  // ─────────────────────────────────────────────────────────
                  // التقارير
                  // ─────────────────────────────────────────────────────────
                  _NavSection(
                    title: 'التقارير',
                    children: [
                      _NavItem(
                        icon: Icons.analytics_outlined,
                        activeIcon: Icons.analytics_rounded,
                        label: 'التقارير',
                        route: '/reports',
                        currentRoute: currentRoute,
                      ),
                    ],
                  ),

                  // ─────────────────────────────────────────────────────────
                  // النسخ الاحتياطي
                  // ─────────────────────────────────────────────────────────
                  _NavSection(
                    title: 'النظام',
                    children: [
                      _NavItem(
                        icon: Icons.backup_outlined,
                        activeIcon: Icons.backup_rounded,
                        label: 'النسخ الاحتياطي',
                        route: '/backup',
                        currentRoute: currentRoute,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // Footer - معلومات الإصدار
            // ═══════════════════════════════════════════════════════════════
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.surface,
          ],
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'ح',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoor',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'نظام إدارة المبيعات',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // زر الإغلاق
          IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 14.sp,
            color: AppColors.success,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            'الإصدار 1.0.0 Pro',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Navigation Section - قسم التنقل
// ═══════════════════════════════════════════════════════════════════════════

class _NavSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _NavSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: AppSpacing.lg,
            left: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Navigation Item - عنصر التنقل
// ═══════════════════════════════════════════════════════════════════════════

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String? currentRoute;
  final String? badge;
  final Color? badgeColor;
  final bool highlight;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.currentRoute,
    this.badge,
    this.badgeColor,
    this.highlight = false,
  });

  bool get isActive => currentRoute == route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2.h,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            context.go(route);
          },
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2.h,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : highlight
                      ? AppColors.success.withValues(alpha: 0.05)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: isActive
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    )
                  : highlight
                      ? Border.all(
                          color: AppColors.success.withValues(alpha: 0.2),
                          width: 1,
                        )
                      : null,
            ),
            child: Row(
              children: [
                // أيقونة
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : highlight
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color: isActive
                        ? AppColors.primary
                        : highlight
                            ? AppColors.success
                            : AppColors.textSecondary,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                // النص
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : highlight
                              ? AppColors.success
                              : AppColors.textPrimary,
                      fontWeight: isActive || highlight
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                // Badge
                if (badge != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.error,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // سهم للعناصر النشطة
                if (isActive)
                  Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primary,
                    size: 18.sp,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
