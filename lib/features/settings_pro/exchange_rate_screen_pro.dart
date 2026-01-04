// ═══════════════════════════════════════════════════════════════════════════
// Exchange Rate Screen Pro
// Currency & Exchange Rate Management
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';

/// Provider لتتبع تغييرات سعر الصرف
final exchangeRateValueProvider = Provider<double>((ref) {
  final currencyService = ref.watch(currencyServiceProvider);
  return currencyService.exchangeRate;
});

/// سجل تغييرات سعر الصرف
class ExchangeRateEntry {
  final double rate;
  final DateTime timestamp;

  ExchangeRateEntry({
    required this.rate,
    required this.timestamp,
  });
}

class ExchangeRateHistoryNotifier extends Notifier<List<ExchangeRateEntry>> {
  @override
  List<ExchangeRateEntry> build() => [];

  void addEntry(double rate) {
    state = [
      ExchangeRateEntry(
        rate: rate,
        timestamp: DateTime.now(),
      ),
      ...state.take(49), // Keep last 50 entries
    ];
  }
}

final exchangeRateHistoryProvider =
    NotifierProvider<ExchangeRateHistoryNotifier, List<ExchangeRateEntry>>(
        ExchangeRateHistoryNotifier.new);

class ExchangeRateScreenPro extends ConsumerStatefulWidget {
  const ExchangeRateScreenPro({super.key});

  @override
  ConsumerState<ExchangeRateScreenPro> createState() =>
      _ExchangeRateScreenProState();
}

class _ExchangeRateScreenProState extends ConsumerState<ExchangeRateScreenPro> {
  final _rateController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentRate();
  }

  void _loadCurrentRate() {
    final currencyService = ref.read(currencyServiceProvider);
    _rateController.text = currencyService.exchangeRate.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyService = ref.watch(currencyServiceProvider);
    final currentRate = currencyService.exchangeRate;
    final history = ref.watch(exchangeRateHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProAppBar.simple(title: 'سعر الصرف'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Update Rate Section
            _buildUpdateSection(currentRate),
            SizedBox(height: AppSpacing.lg),

            // Rate History
            if (history.isNotEmpty) ...[
              _buildHistorySection(history),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateSection(double currentRate) {
    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProIconBox(
                icon: Icons.currency_exchange_rounded,
                color: AppColors.secondary,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سعر الصرف الحالي',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '1 \$ = ${NumberFormat('#,###').format(currentRate)} ل.س',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          ProTextField(
            controller: _rateController,
            label: 'سعر الدولار بالليرة السورية',
            hint: 'أدخل السعر الجديد',
            prefixIcon: Icons.attach_money_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ProButton(
              label: 'حفظ السعر الجديد',
              icon: Icons.save_rounded,
              isLoading: _isSaving,
              onPressed: _saveNewRate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List<ExchangeRateEntry> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'سجل التغييرات',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${history.length} تغيير',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        ...history.take(10).map((entry) => _buildHistoryItem(entry)),
      ],
    );
  }

  Widget _buildHistoryItem(ExchangeRateEntry entry) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.secondary.soft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.history_rounded,
              color: AppColors.secondary,
              size: 16.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '${NumberFormat('#,###').format(entry.rate)} ل.س',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            DateFormat('MM/dd HH:mm', 'ar').format(entry.timestamp),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNewRate() async {
    final rateText = _rateController.text.trim();
    if (rateText.isEmpty) {
      ProSnackbar.warning(context, 'الرجاء إدخال سعر الصرف');
      return;
    }

    final rate = double.tryParse(rateText);
    if (rate == null || rate <= 0) {
      ProSnackbar.warning(context, 'الرجاء إدخال سعر صحيح');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currencyService = ref.read(currencyServiceProvider);
      await currencyService.setExchangeRate(rate);

      // Add to history
      ref.read(exchangeRateHistoryProvider.notifier).addEntry(rate);

      if (mounted) {
        ProSnackbar.success(context, 'تم تحديث سعر الصرف بنجاح');
      }
    } catch (e) {
      if (mounted) {
        ProSnackbar.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
