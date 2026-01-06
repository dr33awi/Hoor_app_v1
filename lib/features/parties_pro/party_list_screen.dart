// ═══════════════════════════════════════════════════════════════════════════
// Party List Screen Pro - Unified Customers & Suppliers Management
// Professional party management interface
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';

/// نوع الطرف (عميل/مورد)
enum PartyType {
  customer,
  supplier,
}

extension PartyTypeExtension on PartyType {
  String get title => this == PartyType.customer ? 'العملاء' : 'الموردين';
  String get singular => this == PartyType.customer ? 'عميل' : 'مورد';
  String get newPartyTitle =>
      this == PartyType.customer ? 'عميل جديد' : 'مورد جديد';
  String get searchHint => 'ابحث بالاسم أو رقم الجوال...';
  String get receivablesLabel =>
      this == PartyType.customer ? 'ديون لنا' : 'مستحقات لنا';
  String get payablesLabel =>
      this == PartyType.customer ? 'ديون علينا' : 'مستحقات لهم';
  Color get accentColor => AppColors.secondary;
  IconData get icon => this == PartyType.customer
      ? Icons.person_rounded
      : Icons.business_rounded;
  IconData get addIcon => Icons.person_add_rounded;
  String get addRoute =>
      this == PartyType.customer ? '/customers/add' : '/suppliers/add';
}

/// شاشة موحدة للعملاء والموردين
class PartyListScreen extends ConsumerStatefulWidget {
  final PartyType type;

  const PartyListScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<PartyListScreen> createState() => _PartyListScreenState();
}

class _PartyListScreenState extends ConsumerState<PartyListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Data Provider based on type
  // ═══════════════════════════════════════════════════════════════════════════

  StreamProvider get _partiesProvider => widget.type == PartyType.customer
      ? customersStreamProvider
      : suppliersStreamProvider;

  // ═══════════════════════════════════════════════════════════════════════════
  // Filter & Sort Logic
  // ═══════════════════════════════════════════════════════════════════════════

  List<T> _filterParties<T>(List<T> parties) {
    var filtered = parties.where((party) {
      final name = _getPartyName(party);
      final phone = _getPartyPhone(party);
      final matchesSearch = _searchController.text.isEmpty ||
          name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          (phone?.contains(_searchController.text) ?? false);
      return matchesSearch;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => _getPartyName(a).compareTo(_getPartyName(b)));
        break;
      case 'balance':
        filtered
            .sort((a, b) => _getPartyBalance(b).compareTo(_getPartyBalance(a)));
        break;
      case 'recent':
        filtered.sort(
            (a, b) => _getPartyUpdatedAt(b).compareTo(_getPartyUpdatedAt(a)));
        break;
    }

    return filtered;
  }

  // Generic getters for Customer/Supplier
  String _getPartyName(dynamic party) {
    if (party is Customer) return party.name;
    if (party is Supplier) return party.name;
    return '';
  }

  String? _getPartyPhone(dynamic party) {
    if (party is Customer) return party.phone;
    if (party is Supplier) return party.phone;
    return null;
  }

  double _getPartyBalance(dynamic party) {
    if (party is Customer) return party.balance;
    if (party is Supplier) return party.balance;
    return 0;
  }

  DateTime _getPartyUpdatedAt(dynamic party) {
    if (party is Customer) return party.updatedAt;
    if (party is Supplier) return party.updatedAt;
    return DateTime.now();
  }

  String _getPartyId(dynamic party) {
    if (party is Customer) return party.id;
    if (party is Supplier) return party.id;
    return '';
  }

  double _totalReceivables(List parties) => parties
      .where((p) => _getPartyBalance(p) > 0)
      .fold(0.0, (sum, p) => sum + _getPartyBalance(p));

  double _totalPayables(List parties) => parties
      .where((p) => _getPartyBalance(p) < 0)
      .fold(0.0, (sum, p) => sum + _getPartyBalance(p).abs());

  // ═══════════════════════════════════════════════════════════════════════════
  // Build UI
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(_partiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: partiesAsync.when(
          loading: () => const ProLoadingState(),
          error: (error, stack) => ProErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(_partiesProvider),
          ),
          data: (parties) {
            final filtered = _filterParties(parties as List);
            return Column(
              children: [
                _buildHeader(parties.length),
                _buildStatsSummary(parties),
                _buildSearchBar(),
                _buildTabs(parties),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPartyList(filtered),
                      _buildPartyList(filtered
                          .where((p) => _getPartyBalance(p) > 0)
                          .toList()),
                      _buildPartyList(filtered
                          .where((p) => _getPartyBalance(p) < 0)
                          .toList()),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(widget.type.addRoute),
        backgroundColor: widget.type.accentColor,
        foregroundColor: Colors.white,
        icon: Icon(widget.type.addIcon),
        label: Text(
          widget.type.newPartyTitle,
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalParties) {
    return ProHeader(
      title: widget.type.title,
      subtitle: '$totalParties ${widget.type.singular}',
      onBack: () => context.go('/'),
      actions: [
        PopupMenuButton<String>(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.filter_list_rounded,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          tooltip: 'ترتيب',
          onSelected: (value) => setState(() => _sortBy = value),
          itemBuilder: (context) => [
            const SortOption(value: 'name', label: 'الاسم'),
            const SortOption(value: 'balance', label: 'الرصيد'),
            const SortOption(value: 'recent', label: 'آخر تعامل'),
          ]
              .map((option) => PopupMenuItem(
                    value: option.value,
                    child: Row(
                      children: [
                        if (_sortBy == option.value)
                          Icon(Icons.check_rounded,
                              size: 16.sp, color: AppColors.secondary),
                        if (_sortBy != option.value) SizedBox(width: 16.sp),
                        SizedBox(width: 8.w),
                        Text(option.label),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(List parties) {
    // Adjust labels based on party type
    // For customers: receivables = they owe us, payables = we owe them
    // For suppliers: receivables = they owe us (rare), payables = we owe them
    return ProBalanceSummary(
      receivables: _totalReceivables(parties),
      payables: _totalPayables(parties),
      receivablesLabel: widget.type.receivablesLabel,
      payablesLabel: widget.type.payablesLabel,
    );
  }

  Widget _buildSearchBar() {
    return ProSearchBar(
      controller: _searchController,
      hintText: widget.type.searchHint,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildTabs(List parties) {
    final allCount = parties.length;
    final withBalanceCount =
        parties.where((p) => _getPartyBalance(p) > 0).length;
    final oweUsCount = parties.where((p) => _getPartyBalance(p) < 0).length;

    return ProTabBar(
      controller: _tabController,
      tabs: [
        ProTab(label: 'الكل', count: allCount),
        ProTab(
          label: widget.type == PartyType.customer ? 'عليهم' : 'لهم',
          count: withBalanceCount,
          badgeColor: AppColors.success,
        ),
        ProTab(
          label: widget.type == PartyType.customer ? 'لهم' : 'علينا',
          count: oweUsCount,
          badgeColor: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildPartyList(List parties) {
    if (parties.isEmpty) {
      return ProEmptyState.list(
        itemName: widget.type.singular,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_partiesProvider),
      child: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: parties.length,
        itemBuilder: (context, index) => _PartyCard(
          party: parties[index],
          type: widget.type,
          onTap: () => _showPartyDetails(parties[index]),
        ),
      ),
    );
  }

  void _showPartyDetails(dynamic party) {
    final id = _getPartyId(party);
    if (widget.type == PartyType.customer) {
      context.push('/customers/$id');
    } else {
      context.push('/suppliers/$id');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Party Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _PartyCard extends StatelessWidget {
  final dynamic party;
  final PartyType type;
  final VoidCallback onTap;

  const _PartyCard({
    required this.party,
    required this.type,
    required this.onTap,
  });

  String get _name => party is Customer ? party.name : (party as Supplier).name;
  String? get _phone =>
      party is Customer ? party.phone : (party as Supplier).phone;
  double get _balance =>
      party is Customer ? party.balance : (party as Supplier).balance;

  // الرصيد بالدولار المحفوظ (nullable)
  double get _balanceUsd => party is Customer
      ? (party.balanceUsd ?? 0)
      : ((party as Supplier).balanceUsd ?? 0);

  @override
  Widget build(BuildContext context) {
    final hasPositiveBalance = _balance > 0;
    final hasNegativeBalance = _balance < 0;
    final balanceColor = hasPositiveBalance
        ? AppColors.success
        : (hasNegativeBalance ? AppColors.error : AppColors.textTertiary);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: type.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                    style: AppTypography.titleLarge.copyWith(
                      color: type.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_phone != null && _phone!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 14.sp, color: AppColors.textTertiary),
                          SizedBox(width: 4.w),
                          Text(
                            _phone!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Balance - استخدام القيم المحفوظة
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormat('#,###').format(_balance.abs())} ل.س',
                    style: AppTypography.titleSmall.copyWith(
                      color: balanceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    // استخدام balanceUsd المحفوظ
                    '\$${(_balanceUsd.abs()).toStringAsFixed(2)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: balanceColor.withValues(alpha: 0.8),
                    ),
                  ),
                  if (_balance != 0)
                    Text(
                      hasPositiveBalance
                          ? (type == PartyType.customer ? 'عليه' : 'له')
                          : (type == PartyType.customer ? 'له' : 'علينا'),
                      style: AppTypography.labelSmall.copyWith(
                        color: balanceColor,
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
