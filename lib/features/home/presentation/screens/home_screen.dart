import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// الشاشة الرئيسية (Shell)
class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'الرئيسية',
      route: AppRoutes.dashboard,
    ),
    NavItem(
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale,
      label: 'نقطة البيع',
      route: AppRoutes.pos,
    ),
    NavItem(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'المنتجات',
      route: AppRoutes.products,
    ),
    NavItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'الفواتير',
      route: AppRoutes.invoices,
    ),
    NavItem(
      icon: Icons.more_horiz,
      selectedIcon: Icons.more_horiz,
      label: 'المزيد',
      route: '',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).uri.path;

    for (var i = 0; i < _navItems.length - 1; i++) {
      if (location.startsWith(_navItems[i].route)) {
        if (_selectedIndex != i) {
          setState(() => _selectedIndex = i);
        }
        return;
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _navItems.length - 1) {
      _showMoreMenu();
      return;
    }

    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      context.go(_navItems[index].route);
    }
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _MoreMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail للشاشات العريضة
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              extended: MediaQuery.of(context).size.width > 1200,
              backgroundColor: AppColors.surface,
              leading: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (MediaQuery.of(context).size.width > 1200)
                      Text(
                        'Hoor',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                      ),
                  ],
                ),
              ),
              destinations: [
                ..._navItems
                    .take(_navItems.length - 1)
                    .map((item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        )),
                const NavigationRailDestination(
                  icon: Icon(Icons.more_horiz),
                  label: Text('المزيد'),
                ),
              ],
            ),

          // المحتوى الرئيسي
          Expanded(child: widget.child),
        ],
      ),

      // Bottom Navigation للشاشات الصغيرة
      bottomNavigationBar: isWide
          ? null
          : Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _navItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = _selectedIndex == index;

                      return _NavBarItem(
                        icon: isSelected ? item.selectedIcon : item.icon,
                        label: item.label,
                        isSelected: isSelected,
                        onTap: () => _onItemTapped(index),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}

/// عنصر شريط التنقل
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.w : 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// قائمة المزيد
class _MoreMenuSheet extends ConsumerWidget {
  const _MoreMenuSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16.h),

          // معلومات المستخدم
          if (user != null)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.name.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          user.role.displayName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 16.h),

          // قائمة الخيارات
          _MoreMenuItem(
            icon: Icons.category_outlined,
            label: 'الفئات',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.categories);
            },
          ),
          _MoreMenuItem(
            icon: Icons.warehouse_outlined,
            label: 'المخزون',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.inventory);
            },
          ),
          _MoreMenuItem(
            icon: Icons.people_outline,
            label: 'العملاء',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.customers);
            },
          ),
          _MoreMenuItem(
            icon: Icons.local_shipping_outlined,
            label: 'الموردين',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.suppliers);
            },
          ),
          _MoreMenuItem(
            icon: Icons.access_time_outlined,
            label: 'الورديات',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.shifts);
            },
          ),
          _MoreMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'الصندوق',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.cash);
            },
          ),
          _MoreMenuItem(
            icon: Icons.assignment_return_outlined,
            label: 'المرتجعات',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.returns);
            },
          ),
          _MoreMenuItem(
            icon: Icons.bar_chart_outlined,
            label: 'التقارير',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.reports);
            },
          ),
          _MoreMenuItem(
            icon: Icons.admin_panel_settings_outlined,
            label: 'المستخدمين',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.users);
            },
          ),
          _MoreMenuItem(
            icon: Icons.settings_outlined,
            label: 'الإعدادات',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.settings);
            },
          ),

          const Divider(),

          // تسجيل الخروج
          _MoreMenuItem(
            icon: Icons.logout,
            label: 'تسجيل الخروج',
            color: AppColors.error,
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

/// عنصر قائمة المزيد
class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MoreMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textPrimary;

    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        label,
        style:
            Theme.of(context).textTheme.titleSmall?.copyWith(color: itemColor),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

/// عنصر التنقل
class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
