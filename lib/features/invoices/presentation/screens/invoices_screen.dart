import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/pos_widgets.dart';
import '../providers/invoices_provider.dart';

/// شاشة الفواتير
class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filterByTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterByTab(int index) {
    final notifier = ref.read(invoicesProvider.notifier);
    switch (index) {
      case 0:
        notifier.filterByStatus(null);
        break;
      case 1:
        notifier.filterByStatus('closed');
        break;
      case 2:
        notifier.filterByStatus('pending');
        break;
      case 3:
        notifier.filterByStatus('cancelled');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesState = ref.watch(invoicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفواتير'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'الكل (${invoicesState.totalCount})'),
            Tab(text: 'مكتملة (${invoicesState.closedCount})'),
            Tab(text: 'معلقة (${invoicesState.pendingCount})'),
            Tab(text: 'ملغاة (${invoicesState.cancelledCount})'),
          ],
        ),
        actions: [
          // فلتر التاريخ
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDateFilter(context, ref),
          ),
          // المزيد
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'export', child: Text('تصدير الفواتير')),
              const PopupMenuItem(value: 'print', child: Text('طباعة التقرير')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: EdgeInsets.all(16.w),
            child: AppTextField(
              controller: _searchController,
              hint: 'بحث برقم الفاتورة أو اسم العميل...',
              prefixIcon: Icons.search,
              suffixIcon:
                  _searchController.text.isNotEmpty ? Icons.clear : null,
              onSuffixTap: () {
                _searchController.clear();
                ref.read(invoicesProvider.notifier).search('');
              },
              onChanged: (value) {
                ref.read(invoicesProvider.notifier).search(value);
              },
            ),
          ),

          // معلومات الفترة
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16.sp, color: AppColors.textSecondary),
                SizedBox(width: 8.w),
                Text(
                  _getDateRangeText(invoicesState),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  'الإجمالي: ${invoicesState.totalAmount.toStringAsFixed(2)} ر.س',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // قائمة الفواتير
          Expanded(
            child: _buildInvoicesList(context, ref, invoicesState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.pos),
        icon: const Icon(Icons.add),
        label: const Text('فاتورة جديدة'),
      ),
    );
  }

  String _getDateRangeText(InvoicesState state) {
    if (state.startDate != null && state.endDate != null) {
      return '${_formatDate(state.startDate!)} - ${_formatDate(state.endDate!)}';
    }
    return 'اليوم';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInvoicesList(
      BuildContext context, WidgetRef ref, InvoicesState state) {
    if (state.isLoading) {
      return const LoadingView(message: 'جاري تحميل الفواتير...');
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(invoicesProvider.notifier).refresh(),
      );
    }

    if (state.filteredInvoices.isEmpty) {
      return EmptyView(
        icon: Icons.receipt_long_outlined,
        message: state.searchQuery.isNotEmpty
            ? 'لا توجد نتائج للبحث'
            : 'لا توجد فواتير',
        actionLabel: 'إنشاء فاتورة',
        onAction: () => context.go(AppRoutes.pos),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(invoicesProvider.notifier).refresh(),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: state.filteredInvoices.length,
        itemBuilder: (context, index) {
          final invoice = state.filteredInvoices[index];
          return _InvoiceCard(
            invoice: invoice,
            onTap: () =>
                context.push('${AppRoutes.invoices}/details/${invoice.id}'),
          );
        },
      ),
    );
  }

  void _showDateFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DateFilterSheet(
        onApply: (start, end) {
          ref.read(invoicesProvider.notifier).setDateRange(start, end);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'export':
        // TODO: تصدير الفواتير
        break;
      case 'print':
        // TODO: طباعة التقرير
        break;
    }
  }
}

/// بطاقة الفاتورة
class _InvoiceCard extends StatelessWidget {
  final InvoiceItem invoice;
  final VoidCallback onTap;

  const _InvoiceCard({
    required this.invoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // أيقونة الحالة
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _getStatusColor(invoice.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(invoice.status),
                      color: _getStatusColor(invoice.status),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // رقم الفاتورة والعميل
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          invoice.customerName ?? 'عميل نقدي',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // المبلغ
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PriceText(
                        price: invoice.totalAmount,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      _StatusBadge(status: invoice.status),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),
              Divider(height: 1, color: AppColors.border),
              SizedBox(height: 12.h),

              // معلومات إضافية
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 14.sp, color: AppColors.textSecondary),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDateTime(invoice.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.person,
                      size: 14.sp, color: AppColors.textSecondary),
                  SizedBox(width: 4.w),
                  Text(
                    invoice.userName ?? 'مستخدم',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(Icons.payment,
                      size: 14.sp, color: AppColors.textSecondary),
                  SizedBox(width: 4.w),
                  Text(
                    _getPaymentMethodText(invoice.paymentMethod),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'closed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'closed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة';
      case 'transfer':
        return 'تحويل';
      default:
        return method;
    }
  }
}

/// شارة الحالة
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'closed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'closed':
        return 'مكتملة';
      case 'pending':
        return 'معلقة';
      case 'cancelled':
        return 'ملغاة';
      default:
        return status;
    }
  }
}

/// ورقة فلتر التاريخ
class _DateFilterSheet extends StatefulWidget {
  final Function(DateTime?, DateTime?) onApply;

  const _DateFilterSheet({required this.onApply});

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  int _selectedOption = 0;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('فلتر التاريخ', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16.h),

          // خيارات سريعة
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _DateOptionChip(
                label: 'اليوم',
                isSelected: _selectedOption == 0,
                onTap: () => setState(() => _selectedOption = 0),
              ),
              _DateOptionChip(
                label: 'أمس',
                isSelected: _selectedOption == 1,
                onTap: () => setState(() => _selectedOption = 1),
              ),
              _DateOptionChip(
                label: 'آخر 7 أيام',
                isSelected: _selectedOption == 2,
                onTap: () => setState(() => _selectedOption = 2),
              ),
              _DateOptionChip(
                label: 'هذا الشهر',
                isSelected: _selectedOption == 3,
                onTap: () => setState(() => _selectedOption = 3),
              ),
              _DateOptionChip(
                label: 'الشهر الماضي',
                isSelected: _selectedOption == 4,
                onTap: () => setState(() => _selectedOption = 4),
              ),
              _DateOptionChip(
                label: 'مخصص',
                isSelected: _selectedOption == 5,
                onTap: () => setState(() => _selectedOption = 5),
              ),
            ],
          ),

          // اختيار تاريخ مخصص
          if (_selectedOption == 5) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'من',
                    date: _startDate,
                    onTap: () => _selectDate(true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _DatePickerField(
                    label: 'إلى',
                    date: _endDate,
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 24.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onApply(null, null);
                  },
                  child: const Text('مسح الفلتر'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton(
                  text: 'تطبيق',
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _apply() {
    DateTime? start;
    DateTime? end;
    final now = DateTime.now();

    switch (_selectedOption) {
      case 0: // اليوم
        start = DateTime(now.year, now.month, now.day);
        end = now;
        break;
      case 1: // أمس
        final yesterday = now.subtract(const Duration(days: 1));
        start = DateTime(yesterday.year, yesterday.month, yesterday.day);
        end = DateTime(
            yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;
      case 2: // آخر 7 أيام
        start = now.subtract(const Duration(days: 7));
        end = now;
        break;
      case 3: // هذا الشهر
        start = DateTime(now.year, now.month, 1);
        end = now;
        break;
      case 4: // الشهر الماضي
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        break;
      case 5: // مخصص
        start = _startDate;
        end = _endDate;
        break;
    }

    widget.onApply(start, end);
  }
}

/// شريحة خيار التاريخ
class _DateOptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateOptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// حقل اختيار التاريخ
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 18.sp, color: AppColors.textSecondary),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    date != null
                        ? '${date!.day}/${date!.month}/${date!.year}'
                        : 'اختر التاريخ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
