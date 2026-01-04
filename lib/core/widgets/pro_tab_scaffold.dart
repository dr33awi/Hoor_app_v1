// ═══════════════════════════════════════════════════════════════════════════
// Pro Tab Scaffold - Shared Tab Layout Widget
// Unified tab scaffold component for all screens
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Tab Bar موحد
class ProTabBar extends StatelessWidget {
  final TabController controller;
  final List<ProTab> tabs;
  final EdgeInsetsGeometry? margin;
  final bool isScrollable;

  const ProTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.margin,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        indicator: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: AppShadows.sm,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(AppSpacing.xs),
        dividerColor: Colors.transparent,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: tabs.map((tab) => _buildTab(tab)).toList(),
      ),
    );
  }

  Widget _buildTab(ProTab tab) {
    if (tab.count != null) {
      return Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tab.label),
            SizedBox(width: AppSpacing.xs),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: tab.badgeColor ?? AppColors.primary.soft,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                '${tab.count}',
                style: AppTypography.labelSmall.copyWith(
                  color: tab.badgeColor ?? AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Tab(text: tab.label);
  }
}

/// تعريف Tab
class ProTab {
  final String label;
  final int? count;
  final Color? badgeColor;

  const ProTab({
    required this.label,
    this.count,
    this.badgeColor,
  });
}

/// هيكل شاشة مع Tabs
class ProTabScaffold extends StatelessWidget {
  final Widget header;
  final Widget? statsWidget;
  final Widget? searchWidget;
  final ProTabBar tabBar;
  final List<Widget> tabViews;
  final TabController tabController;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const ProTabScaffold({
    super.key,
    required this.header,
    this.statsWidget,
    this.searchWidget,
    required this.tabBar,
    required this.tabViews,
    required this.tabController,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            header,
            if (statsWidget != null) statsWidget!,
            if (searchWidget != null) searchWidget!,
            tabBar,
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: tabViews,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// هيكل شاشة بسيط (بدون Tabs)
class ProSimpleScaffold extends StatelessWidget {
  final Widget header;
  final Widget? statsWidget;
  final Widget? searchWidget;
  final Widget body;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const ProSimpleScaffold({
    super.key,
    required this.header,
    this.statsWidget,
    this.searchWidget,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            header,
            if (statsWidget != null) statsWidget!,
            if (searchWidget != null) searchWidget!,
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
