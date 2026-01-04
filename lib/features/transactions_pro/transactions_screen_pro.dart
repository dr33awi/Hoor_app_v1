// ═══════════════════════════════════════════════════════════════════════════
// Unified Transactions Screen Pro - Enterprise Accounting Design
// Sales & Purchase Invoices with Ledger Precision
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/currency_service.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/dual_price_display.dart';
import '../../core/mixins/invoice_filter_mixin.dart';
import '../../core/services/party_name_resolver.dart';
import '../../data/database/app_database.dart';
import '../home_pro/widgets/pro_navigation_drawer.dart';

/// نوع المعاملة
enum TransactionType {
  sales,
  purchase;

  String get label => this == TransactionType.sales ? 'المبيعات' : 'المشتريات';
  String get invoiceType => this == TransactionType.sales ? 'sale' : 'purchase';
  String get singularLabel =>
      this == TransactionType.sales ? 'فاتورة بيع' : 'فاتورة شراء';
  String get partyLabel => this == TransactionType.sales ? 'العميل' : 'المورد';
  String get route =>
      this == TransactionType.sales ? '/sales/add' : '/purchases/add';
  String get newRoute =>
      this == TransactionType.sales ? '/sales/add' : '/purchases/add';
  Color get color =>
      this == TransactionType.sales ? AppColors.income : AppColors.purchases;
  IconData get icon => this == TransactionType.sales
      ? Icons.point_of_sale_rounded
      : Icons.shopping_cart_rounded;
}

class TransactionsScreenPro extends ConsumerStatefulWidget {
  final TransactionType type;

  const TransactionsScreenPro({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<TransactionsScreenPro> createState() =>
      _TransactionsScreenProState();
}

class _TransactionsScreenProState extends ConsumerState<TransactionsScreenPro>
    with SingleTickerProviderStateMixin, InvoiceFilterMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _filterStatus = 'all';
  DateTimeRange? _dateRange;

  bool get isSales => widget.type == TransactionType.sales;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Filter Logic - Using InvoiceFilterMixin
  // ═══════════════════════════════════════════════════════════════════════════

  List<Invoice> _filterInvoicesLocal(List<Invoice> invoices) {
    // استخدام الـ mixin للفلترة الموحدة
    return filterInvoices(
      invoices,
      type: widget.type.invoiceType,
      status: _filterStatus,
      searchQuery: _searchController.text,
      dateRange: _dateRange,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Build UI
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: ProNavigationDrawer(currentRoute: widget.type.route),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            invoicesAsync.when(
              loading: () => _buildStatsLoading(),
              error: (_, __) => const SizedBox.shrink(),
              data: (invoices) => _buildStatsRow(
                invoices
                    .where((i) => i.type == widget.type.invoiceType)
                    .toList(),
              ),
            ),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: invoicesAsync.when(
                loading: () => const ProLoadingState(),
                error: (error, _) => ProEmptyState(
                  icon: Icons.error_outline,
                  title: 'حدث خطأ',
                  message: error.toString(),
                  actionLabel: 'إعادة المحاولة',
                  onAction: () => ref.invalidate(invoicesStreamProvider),
                ),
                data: (invoices) => _buildInvoicesList(invoices),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(widget.type.newRoute),
        backgroundColor: widget.type.color,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          widget.type.singularLabel,
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ProHeader(
      title: widget.type.label,
      subtitle: 'إدارة ${widget.type.singularLabel}ات',
      showBackButton: true,
      showDrawerButton: false,
      onBack: () => context.go('/'),
      icon: widget.type.icon,
      iconColor: widget.type.color,
      actions: [
        IconButton(
          onPressed: _showFilterSheet,
          icon: Badge(
            isLabelVisible: _dateRange != null,
            child: const Icon(Icons.filter_list_rounded),
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsLoading() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    );
  }

  Widget _buildStatsRow(List<Invoice> invoices) {
    final total = invoices.fold(0.0, (sum, inv) => sum + inv.total);
    final paid = invoices.fold(0.0, (sum, inv) => sum + inv.paidAmount);
    final pending = total - paid;
    final thisMonth = invoices.where((inv) {
      final now = DateTime.now();
      return inv.invoiceDate.month == now.month &&
          inv.invoiceDate.year == now.year;
    }).fold(0.0, (sum, inv) => sum + inv.total);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: ProStatCard(
              label: 'الإجمالي',
              amount: total,
              icon: Icons.account_balance_wallet_rounded,
              color: widget.type.color,
              compact: true,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ProStatCard(
              label: 'هذا الشهر',
              amount: thisMonth,
              icon: Icons.calendar_month_rounded,
              color: AppColors.info,
              compact: true,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ProStatCard(
              label: isSales ? 'المستحق' : 'المتبقي',
              amount: pending,
              icon: Icons.pending_actions_rounded,
              color: pending > 0 ? AppColors.warning : AppColors.success,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ProSearchBar(
      controller: _searchController,
      hintText: 'بحث برقم الفاتورة أو ${widget.type.partyLabel}...',
      onChanged: (value) => setState(() {}),
      onClear: () => setState(() {}),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _filterStatus = 'all';
                break;
              case 1:
                _filterStatus = 'completed';
                break;
              case 2:
                _filterStatus = 'pending';
                break;
              case 3:
                _filterStatus = 'cancelled';
                break;
            }
          });
        },
        labelColor: AppColors.textOnPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: widget.type.color,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle:
            AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'الكل'),
          Tab(text: 'مكتملة'),
          Tab(text: 'معلقة'),
          Tab(text: 'ملغية'),
        ],
      ),
    );
  }

  Widget _buildInvoicesList(List<Invoice> invoices) {
    final filtered = _filterInvoicesLocal(invoices);

    if (filtered.isEmpty) {
      return ProEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'لا توجد فواتير',
        message: 'أنشئ ${widget.type.singularLabel} جديدة للبدء',
        actionLabel: widget.type.singularLabel,
        onAction: () => context.push(widget.type.newRoute),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(invoicesStreamProvider),
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final invoice = filtered[index];
          return _InvoiceCard(
            invoice: invoice,
            type: widget.type,
            partyNameFuture: _getPartyName(invoice),
            onTap: () => context.push('/invoices/${invoice.id}'),
          );
        },
      ),
    );
  }

  // استخدام PartyNameResolver للحصول على اسم العميل/المورد مع التخزين المؤقت
  Future<String> _getPartyName(Invoice invoice) async {
    final resolver = ref.read(partyNameResolverProvider);
    return resolver.getPartyName(invoice);
  }

  void _showFilterSheet() {
    showProBottomSheet(
      context: context,
      title: 'تصفية النتائج',
      titleIcon: Icons.filter_list_rounded,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.date_range_rounded),
              title: const Text('فترة زمنية'),
              subtitle: _dateRange != null
                  ? Text(
                      '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}')
                  : const Text('اختر فترة'),
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  locale: const Locale('ar'),
                );
                if (range != null) {
                  setState(() => _dateRange = range);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
            SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ProButton(
                label: 'مسح الفلاتر',
                type: ProButtonType.outlined,
                onPressed: () {
                  setState(() {
                    _filterStatus = 'all';
                    _dateRange = null;
                    _searchController.clear();
                    _tabController.animateTo(0);
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// تم نقل _StatCard إلى ProStatCard في core/widgets/pro_stats_card.dart

// ═══════════════════════════════════════════════════════════════════════════
// Invoice Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final TransactionType type;
  final Future<String> partyNameFuture;
  final VoidCallback onTap;

  const _InvoiceCard({
    required this.invoice,
    required this.type,
    required this.partyNameFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return ProCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              // Type Icon
              ProIconBox(icon: type.icon, color: type.color),
              SizedBox(width: AppSpacing.md),
              // Invoice Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: AppTypography.titleSmall.mono,
                    ),
                    FutureBuilder<String>(
                      future: partyNameFuture,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? '...',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Status Badge
              ProStatusBadge.fromInvoiceStatus(invoice.status, small: true),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: AppColors.border),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                dateFormat.format(invoice.invoiceDate),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Icon(
                invoice.paymentMethod == 'cash'
                    ? Icons.payments_rounded
                    : Icons.credit_card_rounded,
                size: 14.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                invoice.paymentMethod == 'cash' ? 'نقدي' : 'آجل',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              CompactDualPrice(
                amountSyp: invoice.total,
                exchangeRate: CurrencyService.currentRate,
                sypStyle: AppTypography.titleMedium
                    .copyWith(
                      color: type.color,
                    )
                    .monoBold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
