// lib/core/widgets/custom_bottom_nav.dart
// 🧭 شريط تنقل سفلي مخصص

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// شريط تنقل سفلي متحرك
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return _NavItem(
              icon: item.icon,
              activeIcon: item.activeIcon,
              label: item.label,
              isSelected: isSelected,
              selectedColor: selectedColor ?? AppColors.primary,
              unselectedColor: unselectedColor ?? Colors.grey.shade500,
              onTap: () => onTap(index),
              showBadge: item.showBadge,
              badgeCount: item.badgeCount,
            );
          }),
        ),
      ),
    );
  }
}

/// عنصر في شريط التنقل
class CustomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool showBadge;
  final int badgeCount;

  const CustomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.showBadge = false,
    this.badgeCount = 0,
  });
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  isSelected ? (activeIcon ?? icon) : icon,
                  color: isSelected ? selectedColor : unselectedColor,
                  size: 24,
                ),
                if (showBadge && badgeCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selectedColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// شريط تنقل بسيط مع FAB في المنتصف
class BottomNavWithFab extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabPressed;
  final List<CustomNavItem> items;
  final IconData fabIcon;
  final String? fabLabel;

  const BottomNavWithFab({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
    required this.items,
    this.fabIcon = Icons.add,
    this.fabLabel,
  });

  @override
  Widget build(BuildContext context) {
    final middleIndex = items.length ~/ 2;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Bottom Navigation
        Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length + 1, (index) {
                // Empty space for FAB
                if (index == middleIndex) {
                  return const SizedBox(width: 60);
                }

                final itemIndex = index > middleIndex ? index - 1 : index;
                final item = items[itemIndex];
                final isSelected = itemIndex == currentIndex;

                return _SimpleNavItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => onTap(itemIndex),
                );
              }),
            ),
          ),
        ),

        // FAB
        Positioned(
          bottom: 20,
          child: GestureDetector(
            onTap: onFabPressed,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(fabIcon, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}

class _SimpleNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SimpleNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
