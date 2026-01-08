// ═══════════════════════════════════════════════════════════════════════════
// Recurring Expenses Screen - شاشة المصاريف الدورية
// Hoor Enterprise Design System 2026
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/services/currency_formatter.dart';
import '../../../core/providers/app_providers.dart';
import '../models/recurring_expense_template.dart';
import '../services/recurring_expense_service.dart';

/// شاشة إدارة المصاريف الدورية
class RecurringExpensesScreen extends ConsumerStatefulWidget {
  const RecurringExpensesScreen({super.key});

  @override
  ConsumerState<RecurringExpensesScreen> createState() =>
      _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState
    extends ConsumerState<RecurringExpensesScreen> {
  List<RecurringExpenseTemplate> _templates = [];
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final templates = await RecurringExpenseService.getAllTemplates();
      final stats = await RecurringExpenseService.getTemplateStats();
      setState(() {
        _templates = templates;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ProSnackbar.error(context, 'خطأ في تحميل القوالب: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (!_isLoading) _buildStats(),
            Expanded(
              child: _isLoading
                  ? ProLoadingState.list()
                  : _templates.isEmpty
                      ? _buildEmptyState()
                      : _buildTemplatesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTemplateDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة قالب', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader() {
    return ProHeader(
      title: 'المصاريف الدورية',
      subtitle: 'قوالب المصاريف المتكررة',
      onBack: () => context.pop(),
      actions: [
        // زر تحويل القوالب القديمة إلى موزّعة
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'خيارات',
          onSelected: (value) {
            if (value == 'convert_to_distributed') {
              _showConvertToDistributedDialog();
            } else if (value == 'refresh') {
              _loadTemplates();
            } else if (value == 'clear_processed_periods') {
              _showClearProcessedPeriodsDialog();
            } else if (value == 'process_now') {
              _processExpensesNow();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('تحديث'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'convert_to_distributed',
              child: Row(
                children: [
                  Icon(Icons.transform, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('تحويل السنوية لموزّعة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_processed_periods',
              child: Row(
                children: [
                  Icon(Icons.restart_alt, color: Colors.red),
                  SizedBox(width: 8),
                  Text('إعادة تعيين السجلات'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'process_now',
              child: Row(
                children: [
                  Icon(Icons.play_arrow, color: Colors.green),
                  SizedBox(width: 8),
                  Text('معالجة المستحقات الآن'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// معالجة المصاريف المستحقة يدوياً
  Future<void> _processExpensesNow() async {
    try {
      // عرض مؤشر تحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('جاري معالجة المصاريف الدورية...'),
            ],
          ),
        ),
      );

      final expenseRepo = ref.read(expenseRepositoryProvider);
      final result =
          await RecurringExpenseService.processAllDueExpenses(expenseRepo);

      if (mounted) Navigator.pop(context); // إغلاق مؤشر التحميل

      if (!mounted) return;

      String message = '';
      if (result.successCount > 0) {
        message +=
            'تم إنشاء ${result.successCount} مصروف:\n${result.generatedExpenseNames.join("\n")}';
      }
      if (result.skippedDuplicates.isNotEmpty) {
        if (message.isNotEmpty) message += '\n\n';
        message += 'تم تخطي ${result.skippedDuplicates.length} مصروف مكرر';
      }
      if (result.failedCount > 0) {
        if (message.isNotEmpty) message += '\n\n';
        message += 'فشل ${result.failedCount}: ${result.errors.join(", ")}';
      }
      if (message.isEmpty) {
        message = 'لا توجد مصاريف مستحقة للمعالجة';
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('نتيجة المعالجة'),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );

      _loadTemplates();
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ProSnackbar.error(context, 'خطأ: $e');
      }
    }
  }

  /// تحويل القوالب السنوية/الربعية إلى موزّعة
  void _showConvertToDistributedDialog() {
    final yearlyTemplates = _templates
        .where((t) =>
            t.frequency == RecurrenceFrequency.yearly &&
            t.distributionType != ExpenseDistributionType.distributed)
        .toList();

    final quarterlyTemplates = _templates
        .where((t) =>
            t.frequency == RecurrenceFrequency.quarterly &&
            t.distributionType != ExpenseDistributionType.distributed)
        .toList();

    if (yearlyTemplates.isEmpty && quarterlyTemplates.isEmpty) {
      ProSnackbar.info(context, 'لا توجد قوالب سنوية أو ربعية للتحويل');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحويل إلى مصاريف موزّعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'سيتم تحويل المصاريف التالية إلى موزّعة:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (yearlyTemplates.isNotEmpty) ...[
              Text('📅 سنوية (تُقسم على 12 شهر):',
                  style: TextStyle(color: AppColors.info)),
              ...yearlyTemplates.map((t) => Padding(
                    padding: const EdgeInsets.only(right: 16, top: 4),
                    child: Text('• ${t.name}'),
                  )),
              const SizedBox(height: 8),
            ],
            if (quarterlyTemplates.isNotEmpty) ...[
              Text('📆 ربعية (تُقسم على 3 أشهر):',
                  style: TextStyle(color: AppColors.info)),
              ...quarterlyTemplates.map((t) => Padding(
                    padding: const EdgeInsets.only(right: 16, top: 4),
                    child: Text('• ${t.name}'),
                  )),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⚠️ ملاحظة: هذا سيؤثر على الأقساط الجديدة فقط.\n'
                'المصاريف المسجلة سابقاً ستبقى كما هي.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _convertTemplatesToDistributed(
                  [...yearlyTemplates, ...quarterlyTemplates]);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('تحويل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _convertTemplatesToDistributed(
      List<RecurringExpenseTemplate> templates) async {
    int converted = 0;
    for (final template in templates) {
      try {
        await RecurringExpenseService.updateTemplate(
          template.copyWith(
            distributionType: ExpenseDistributionType.distributed,
          ),
        );
        converted++;
      } catch (e) {
        debugPrint('خطأ في تحويل ${template.name}: $e');
      }
    }

    _loadTemplates();
    if (mounted) {
      ProSnackbar.success(context, 'تم تحويل $converted قالب إلى موزّع');
    }
  }

  // دالة إعادة تعيين سجلات المعالجة
  void _showClearProcessedPeriodsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('إعادة تعيين السجلات'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هذا سيحذف سجلات المعالجة للمصاريف الدورية.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'عند المعالجة التالية، سيتم إنشاء أقساط جديدة لجميع القوالب الموزّعة.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              '⚠️ تحذير: قد يؤدي هذا لإنشاء مصاريف مكررة.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearProcessedPeriods();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('إعادة تعيين',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearProcessedPeriods() async {
    try {
      // حذف سجلات المعالجة من قاعدة البيانات
      await RecurringExpenseService.clearProcessedLogs();

      if (mounted) {
        ProSnackbar.success(context, 'تم إعادة تعيين سجلات المعالجة');
        _loadTemplates();
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ: $e');
      }
    }
  }

  Widget _buildStats() {
    final dueCount = _stats['dueTemplates'] ?? 0;
    final monthlyTotal = _stats['expectedMonthlyTotal'] ?? 0.0;

    // إحصائيات القوالب الموزّعة
    final distributedCount = _templates
        .where((t) => t.distributionType == ExpenseDistributionType.distributed)
        .length;
    final immediateYearlyCount = _templates
        .where((t) =>
            t.frequency == RecurrenceFrequency.yearly &&
            t.distributionType == ExpenseDistributionType.immediate)
        .length;

    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05)
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.repeat, color: AppColors.primary, size: 20),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'قوالب نشطة: ${_stats['activeTemplates'] ?? 0}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'المتوقع شهرياً: ${CurrencyFormatter.formatSyp(monthlyTotal)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (dueCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_active,
                          color: AppColors.warning, size: 16),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        '$dueCount مستحق',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // تحذير للقوالب السنوية غير الموزّعة
          if (immediateYearlyCount > 0) ...[
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: Colors.orange, size: 18),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '$immediateYearlyCount قالب سنوي غير موزّع! استخدم القائمة ← "تحويل السنوية لموزّعة"',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // معلومات الموزّع
          if (distributedCount > 0) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              '✓ $distributedCount قالب موزّع (أقساط شهرية)',
              style: TextStyle(fontSize: 11, color: AppColors.success),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.repeat,
              size: 80, color: AppColors.textTertiary.withOpacity(0.3)),
          SizedBox(height: AppSpacing.md),
          Text(
            'لا توجد مصاريف دورية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'أضف قوالب للمصاريف المتكررة مثل الإيجار والفواتير',
            style: TextStyle(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => _showAddTemplateDialog(),
            icon: const Icon(Icons.add),
            label: const Text('إضافة قالب'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesList() {
    // ترتيب: المستحقة أولاً
    final sortedTemplates = List<RecurringExpenseTemplate>.from(_templates)
      ..sort((a, b) {
        if (a.isDue && !b.isDue) return -1;
        if (!a.isDue && b.isDue) return 1;
        if (!a.isActive && b.isActive) return 1;
        if (a.isActive && !b.isActive) return -1;
        return a.name.compareTo(b.name);
      });

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: sortedTemplates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(sortedTemplates[index]);
      },
    );
  }

  Widget _buildTemplateCard(RecurringExpenseTemplate template) {
    final isDue = template.isDue && template.isActive;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDue ? AppColors.warning : AppColors.border,
          width: isDue ? 2 : 1,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => _showTemplateOptions(template),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // أيقونة الحالة
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isDue ? AppColors.warning : AppColors.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    isDue ? Icons.notifications_active : Icons.repeat,
                    color: isDue ? AppColors.warning : AppColors.primary,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                // المعلومات
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              template.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: template.isActive
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                                decoration: template.isActive
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          if (!template.isActive)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.textTertiary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'معطل',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textTertiary),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            template.frequency.arabicName,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          // عرض نوع التوزيع
                          if (template.isDistributed) ...[
                            Text(' • ',
                                style:
                                    TextStyle(color: AppColors.textTertiary)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'موزّع',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.info,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (template.categoryName != null) ...[
                            Text(' • ',
                                style:
                                    TextStyle(color: AppColors.textTertiary)),
                            Text(
                              template.categoryName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (template.nextDueDate != null &&
                          template.isActive) ...[
                        SizedBox(height: 4),
                        Text(
                          isDue
                              ? '⚠️ مستحق الآن'
                              : 'التالي: ${_formatDate(template.nextDueDate!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDue
                                ? AppColors.warning
                                : AppColors.textTertiary,
                            fontWeight:
                                isDue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // المبلغ
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // للمصاريف الموزعة: عرض القسط
                    if (template.isDistributed) ...[
                      Text(
                        CurrencyFormatter.formatSyp(
                            template.getAmountForPeriod()),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.expense,
                        ),
                      ),
                      Text(
                        'قسط شهري',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.info,
                        ),
                      ),
                      Text(
                        'الإجمالي: ${CurrencyFormatter.formatSyp(template.amountSyp)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ] else ...[
                      Text(
                        CurrencyFormatter.formatSyp(template.amountSyp),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.expense,
                        ),
                      ),
                      if (template.amountUsd != null)
                        Text(
                          CurrencyFormatter.formatUsd(template.amountUsd!),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ],
                ),
                SizedBox(width: AppSpacing.sm),
                // زر إنشاء سريع
                if (template.isActive)
                  IconButton(
                    onPressed: () => _generateExpense(template),
                    icon: Icon(
                      Icons.add_circle,
                      color: isDue ? AppColors.warning : AppColors.success,
                    ),
                    tooltip: 'إنشاء مصروف',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'غداً';
    if (diff < 7) return 'بعد $diff أيام';
    if (diff < 30) return 'بعد ${(diff / 7).round()} أسابيع';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showTemplateOptions(RecurringExpenseTemplate template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              template.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            ListTile(
              leading: Icon(Icons.add_circle, color: AppColors.success),
              title: const Text('إنشاء مصروف'),
              onTap: () {
                Navigator.pop(context);
                _generateExpense(template);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primary),
              title: const Text('تعديل القالب'),
              onTap: () {
                Navigator.pop(context);
                _showEditTemplateDialog(template);
              },
            ),
            ListTile(
              leading: Icon(
                template.isActive ? Icons.pause_circle : Icons.play_circle,
                color:
                    template.isActive ? AppColors.warning : AppColors.success,
              ),
              title: Text(template.isActive ? 'تعطيل القالب' : 'تفعيل القالب'),
              onTap: () async {
                Navigator.pop(context);
                await RecurringExpenseService.toggleTemplateStatus(template.id);
                _loadTemplates();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: const Text('حذف القالب'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(template);
              },
            ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _generateExpense(RecurringExpenseTemplate template) async {
    try {
      final repo = ref.read(expenseRepositoryProvider);

      await repo.createExpense(
        amount: template.amountSyp,
        isUsd: false,
        categoryId: template.categoryId ?? '',
        description: '${template.name} (دوري)',
      );

      await RecurringExpenseService.markAsGenerated(template.id);

      if (mounted) {
        ProSnackbar.success(context, 'تم إنشاء المصروف بنجاح');
        _loadTemplates();
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.error(context, 'خطأ: $e');
      }
    }
  }

  void _showDeleteConfirmation(RecurringExpenseTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف القالب'),
        content: Text('هل أنت متأكد من حذف قالب "${template.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await RecurringExpenseService.deleteTemplate(template.id);
              _loadTemplates();
              if (mounted) {
                ProSnackbar.success(context, 'تم حذف القالب');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddTemplateDialog() {
    _showTemplateFormDialog(null);
  }

  void _showEditTemplateDialog(RecurringExpenseTemplate template) {
    _showTemplateFormDialog(template);
  }

  void _showTemplateFormDialog(RecurringExpenseTemplate? template) {
    final isEditing = template != null;
    final nameController = TextEditingController(text: template?.name ?? '');
    final amountController = TextEditingController();
    final descController =
        TextEditingController(text: template?.description ?? '');

    // تحديد العملة الأساسية
    bool isUsd = template?.amountUsd != null && template!.amountUsd! > 0;

    // ضبط المبلغ الأولي
    if (isEditing) {
      if (isUsd && template.amountUsd != null && template.amountUsd! > 0) {
        amountController.text = template.amountUsd!.toStringAsFixed(2);
      } else if (template.amountSyp > 0) {
        amountController.text = template.amountSyp.toStringAsFixed(0);
      }
    }

    RecurrenceFrequency selectedFrequency =
        template?.frequency ?? RecurrenceFrequency.monthly;
    String? selectedCategoryId = template?.categoryId;
    String? selectedCategoryName = template?.categoryName;

    // ═══════════════════════════════════════════════════════════════════════
    // نوع التوزيع المحاسبي
    // ═══════════════════════════════════════════════════════════════════════
    ExpenseDistributionType distributionType =
        template?.distributionType ?? ExpenseDistributionType.immediate;
    DistributionPeriod? distributionPeriod = template?.distributionPeriod;
    int distributionCount = template?.distributionCount ?? 12;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final categoriesAsync = ref.watch(expenseCategoriesStreamProvider);
          final currencyService = ref.watch(currencyServiceProvider);

          // حساب المعاينة
          final amountText = amountController.text.replaceAll(',', '');
          final amount = double.tryParse(amountText);
          double? previewSyp;
          double? previewUsd;

          if (amount != null && amount > 0) {
            final rate = currencyService.exchangeRate;
            if (isUsd) {
              previewUsd = amount;
              previewSyp = amount * rate;
            } else {
              previewSyp = amount;
              previewUsd = rate > 0 ? amount / rate : 0;
            }
          }

          return AlertDialog(
            title: Text(isEditing ? 'تعديل القالب' : 'قالب جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ═══════════════════════════════════════════════════════════
                  // سعر الصرف الحالي
                  // ═══════════════════════════════════════════════════════════
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.infoSurface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border:
                          Border.all(color: AppColors.info.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.currency_exchange,
                            color: AppColors.info, size: 20.sp),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سعر الصرف الحالي',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                              Text(
                                '${CurrencyFormatter.formatNumber(currencyService.exchangeRate)} ل.س / \$',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'سيُثبّت',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ═══════════════════════════════════════════════════════════
                  // اسم المصروف
                  // ═══════════════════════════════════════════════════════════
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المصروف *',
                      hintText: 'مثال: إيجار المحل',
                      prefixIcon: Icon(Icons.label),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ═══════════════════════════════════════════════════════════
                  // المبلغ مع تبديل العملة
                  // ═══════════════════════════════════════════════════════════
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // حقل المبلغ
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d.,]')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'المبلغ *',
                            hintText: '0',
                            prefixIcon: Icon(
                              isUsd ? Icons.attach_money : Icons.money,
                              color: AppColors.expense,
                            ),
                            suffixText: isUsd ? 'USD' : 'SYP',
                          ),
                          onChanged: (_) => setDialogState(() {}),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      // تبديل العملة
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _TemplateDialogCurrencyButton(
                                  label: 'ل.س',
                                  isSelected: !isUsd,
                                  onTap: () {
                                    setDialogState(() => isUsd = false);
                                  },
                                ),
                              ),
                              Expanded(
                                child: _TemplateDialogCurrencyButton(
                                  label: '\$',
                                  isSelected: isUsd,
                                  onTap: () {
                                    setDialogState(() => isUsd = true);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ═══════════════════════════════════════════════════════════
                  // معاينة المبلغ المحسوب
                  // ═══════════════════════════════════════════════════════════
                  if (previewSyp != null && previewUsd != null) ...[
                    SizedBox(height: AppSpacing.md),
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.expense.withOpacity(0.1),
                            AppColors.expenseSurface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                            color: AppColors.expense.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'سيتم تسجيل',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.expense,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    CurrencyFormatter.formatSyp(previewSyp),
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.expense,
                                    ),
                                  ),
                                  Text(
                                    'ل.س',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 30.h,
                                width: 1,
                                color: AppColors.border,
                              ),
                              Column(
                                children: [
                                  Text(
                                    CurrencyFormatter.formatUsd(previewUsd),
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '\$',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: AppSpacing.md),

                  // ═══════════════════════════════════════════════════════════
                  // اختيار التكرار
                  // ═══════════════════════════════════════════════════════════
                  DropdownButtonFormField<RecurrenceFrequency>(
                    value: selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'التكرار',
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    items: RecurrenceFrequency.values.map((f) {
                      return DropdownMenuItem(
                        value: f,
                        child: Text(f.arabicName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedFrequency = value);
                      }
                    },
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ═══════════════════════════════════════════════════════════
                  // نوع التوزيع المحاسبي (فوري/موزّع)
                  // ═══════════════════════════════════════════════════════════
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التوزيع المحاسبي',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: _DistributionTypeButton(
                                title: 'فوري',
                                subtitle: 'يُسجل كاملاً',
                                icon: Icons.flash_on,
                                isSelected: distributionType ==
                                    ExpenseDistributionType.immediate,
                                onTap: () {
                                  setDialogState(() {
                                    distributionType =
                                        ExpenseDistributionType.immediate;
                                    distributionPeriod = null;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _DistributionTypeButton(
                                title: 'موزّع',
                                subtitle: 'يُقسم على فترات',
                                icon: Icons.pie_chart,
                                isSelected: distributionType ==
                                    ExpenseDistributionType.distributed,
                                onTap: () {
                                  setDialogState(() {
                                    distributionType =
                                        ExpenseDistributionType.distributed;
                                    distributionPeriod =
                                        DistributionPeriod.monthly;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        // خيارات التوزيع إذا كان موزّعاً
                        if (distributionType ==
                            ExpenseDistributionType.distributed) ...[
                          SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child:
                                    DropdownButtonFormField<DistributionPeriod>(
                                  value: distributionPeriod ??
                                      DistributionPeriod.monthly,
                                  decoration: InputDecoration(
                                    labelText: 'فترة التوزيع',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                  ),
                                  items: DistributionPeriod.values.map((p) {
                                    return DropdownMenuItem(
                                      value: p,
                                      child: Text(p.arabicName,
                                          style: TextStyle(fontSize: 12)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      distributionPeriod = value;
                                      distributionCount =
                                          value?.periodsPerYear ?? 12;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'عدد الأقساط',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(
                                    text: distributionCount.toString(),
                                  ),
                                  onChanged: (v) {
                                    final count = int.tryParse(v);
                                    if (count != null && count > 0) {
                                      distributionCount = count;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.xs),
                          // معاينة التوزيع
                          if (previewSyp != null)
                            Container(
                              padding: EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: AppColors.infoSurface,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 14, color: AppColors.info),
                                  SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      'كل ${distributionPeriod?.arabicName ?? 'شهر'}: ${CurrencyFormatter.formatSyp(previewSyp / distributionCount)}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  // اختيار التصنيف
                  categoriesAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('خطأ في تحميل التصنيفات'),
                    data: (categories) {
                      return DropdownButtonFormField<String>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'التصنيف (اختياري)',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('بدون تصنيف'),
                          ),
                          ...categories.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategoryId = value;
                            selectedCategoryName = value != null
                                ? categories
                                    .firstWhere((c) => c.id == value)
                                    .name
                                : null;
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  // قوالب شائعة
                  if (!isEditing) ...[
                    const Divider(),
                    Text(
                      'قوالب شائعة:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          CommonRecurringExpenses.templates.take(6).map((t) {
                        return ActionChip(
                          avatar: Text(t['icon'] as String),
                          label: Text(
                            t['name'] as String,
                            style: const TextStyle(fontSize: 11),
                          ),
                          onPressed: () {
                            nameController.text = t['name'] as String;
                            setDialogState(() {
                              selectedFrequency =
                                  t['frequency'] as RecurrenceFrequency;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final amountText =
                      amountController.text.trim().replaceAll(',', '');

                  if (name.isEmpty) {
                    ProSnackbar.warning(context, 'يرجى إدخال اسم المصروف');
                    return;
                  }

                  final amount = double.tryParse(amountText);
                  if (amount == null || amount <= 0) {
                    ProSnackbar.warning(context, 'يرجى إدخال مبلغ صحيح');
                    return;
                  }

                  // حساب المبالغ بناءً على العملة والسعر
                  final rate = currencyService.exchangeRate;
                  double amountSyp;
                  double? amountUsd;

                  if (isUsd) {
                    amountUsd = amount;
                    amountSyp = amount * rate;
                  } else {
                    amountSyp = amount;
                    amountUsd = rate > 0 ? amount / rate : null;
                  }

                  Navigator.pop(context);

                  if (isEditing) {
                    await RecurringExpenseService.updateTemplate(
                      template.copyWith(
                        name: name,
                        amountSyp: amountSyp,
                        amountUsd: amountUsd,
                        exchangeRate: rate,
                        categoryId: selectedCategoryId,
                        categoryName: selectedCategoryName,
                        description: descController.text.trim(),
                        frequency: selectedFrequency,
                        distributionType: distributionType,
                        distributionPeriod: distributionPeriod,
                        distributionCount: distributionType ==
                                ExpenseDistributionType.distributed
                            ? distributionCount
                            : null,
                      ),
                    );
                  } else {
                    await RecurringExpenseService.addTemplate(
                      name: name,
                      amountSyp: amountSyp,
                      amountUsd: amountUsd,
                      exchangeRate: rate,
                      categoryId: selectedCategoryId,
                      categoryName: selectedCategoryName,
                      description: descController.text.trim(),
                      frequency: selectedFrequency,
                      distributionType: distributionType,
                      distributionPeriod: distributionPeriod,
                      distributionCount: distributionType ==
                              ExpenseDistributionType.distributed
                          ? distributionCount
                          : null,
                    );
                  }

                  _loadTemplates();
                  if (mounted) {
                    ProSnackbar.success(
                      context,
                      isEditing ? 'تم تحديث القالب' : 'تم إضافة القالب',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: Text(
                  isEditing ? 'حفظ' : 'إضافة',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// زر تبديل العملة داخل نافذة الحوار
class _TemplateDialogCurrencyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateDialogCurrencyButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.expense : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md - 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md - 1),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// زر اختيار نوع التوزيع المحاسبي
class _DistributionTypeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DistributionTypeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
              SizedBox(height: 2),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
