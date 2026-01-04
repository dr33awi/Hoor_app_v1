// ═══════════════════════════════════════════════════════════════════════════
// Offline Sync Widget - Professional Sync Status & Management
// Shows sync status and allows manual sync control
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/sync_service.dart';
import '../../core/widgets/widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Sync Status Provider
// ═══════════════════════════════════════════════════════════════════════════

final syncStatusProvider =
    NotifierProvider<SyncStatusNotifier, SyncStatusState>(
        SyncStatusNotifier.new);

class SyncStatusState {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int pendingCount;
  final String? errorMessage;
  final SyncStatus status;

  SyncStatusState({
    this.isOnline = true,
    this.isSyncing = false,
    this.lastSyncTime,
    this.pendingCount = 0,
    this.errorMessage,
    this.status = SyncStatus.idle,
  });

  SyncStatusState copyWith({
    bool? isOnline,
    bool? isSyncing,
    DateTime? lastSyncTime,
    int? pendingCount,
    String? errorMessage,
    SyncStatus? status,
  }) {
    return SyncStatusState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingCount: pendingCount ?? this.pendingCount,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }
}

class SyncStatusNotifier extends Notifier<SyncStatusState> {
  @override
  SyncStatusState build() {
    final syncService = ref.watch(syncServiceProvider);
    final connectivityService = ref.watch(connectivityServiceProvider);

    // Initial state
    return SyncStatusState(
      isOnline: connectivityService.isOnline,
      isSyncing: syncService.isSyncing,
      lastSyncTime: syncService.lastSyncTime,
      status: syncService.status,
      errorMessage: syncService.lastError,
    );
  }

  void updateState() {
    final syncService = ref.read(syncServiceProvider);
    final connectivityService = ref.read(connectivityServiceProvider);

    state = state.copyWith(
      isOnline: connectivityService.isOnline,
      isSyncing: syncService.isSyncing,
      lastSyncTime: syncService.lastSyncTime,
      status: syncService.status,
      errorMessage: syncService.lastError,
    );
  }

  Future<void> syncNow() async {
    final syncService = ref.read(syncServiceProvider);
    await syncService.syncAll();
    updateState();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sync Status Bar Widget - Compact status indicator
// ═══════════════════════════════════════════════════════════════════════════

class SyncStatusBar extends ConsumerWidget {
  final bool showLabel;
  final bool compact;

  const SyncStatusBar({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);

    return GestureDetector(
      onTap: () => _showSyncDetails(context, ref),
      child: AnimatedContainer(
        duration: AppDurations.normal,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : AppSpacing.md,
          vertical: compact ? AppSpacing.xs : AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(syncState),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: _getBorderColor(syncState)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(syncState),
            if (showLabel) ...[
              SizedBox(width: AppSpacing.xs),
              Text(
                _getStatusText(syncState),
                style: AppTypography.labelSmall.copyWith(
                  color: _getTextColor(syncState),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(SyncStatusState state) {
    if (state.isSyncing) {
      return SizedBox(
        width: 14.sp,
        height: 14.sp,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(_getIconColor(state)),
        ),
      );
    }

    return Icon(
      _getStatusIcon(state),
      size: 14.sp,
      color: _getIconColor(state),
    );
  }

  IconData _getStatusIcon(SyncStatusState state) {
    if (!state.isOnline) return Icons.cloud_off_rounded;
    if (state.status == SyncStatus.error) return Icons.sync_problem_rounded;
    if (state.pendingCount > 0) return Icons.sync_rounded;
    return Icons.cloud_done_rounded;
  }

  Color _getBackgroundColor(SyncStatusState state) {
    if (!state.isOnline) return AppColors.warning.soft;
    if (state.status == SyncStatus.error) return AppColors.error.soft;
    if (state.isSyncing) return AppColors.info.soft;
    return AppColors.success.soft;
  }

  Color _getBorderColor(SyncStatusState state) {
    if (!state.isOnline) return AppColors.warning.border;
    if (state.status == SyncStatus.error) return AppColors.error.border;
    if (state.isSyncing) return AppColors.info.border;
    return AppColors.success.border;
  }

  Color _getTextColor(SyncStatusState state) {
    if (!state.isOnline) return AppColors.warning;
    if (state.status == SyncStatus.error) return AppColors.error;
    if (state.isSyncing) return AppColors.info;
    return AppColors.success;
  }

  Color _getIconColor(SyncStatusState state) {
    return _getTextColor(state);
  }

  String _getStatusText(SyncStatusState state) {
    if (!state.isOnline) return 'غير متصل';
    if (state.isSyncing) return 'جاري المزامنة...';
    if (state.status == SyncStatus.error) return 'خطأ';
    if (state.pendingCount > 0) return '${state.pendingCount} معلق';
    return 'متصل';
  }

  void _showSyncDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SyncDetailsSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sync Details Sheet - Full sync information and controls
// ═══════════════════════════════════════════════════════════════════════════

class SyncDetailsSheet extends ConsumerWidget {
  const SyncDetailsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: AppSpacing.sm),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    ProIconBox(
                      icon: syncState.isOnline
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                      color: syncState.isOnline
                          ? AppColors.success
                          : AppColors.warning,
                      size: 56.w,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حالة المزامنة',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            syncState.isOnline
                                ? 'متصل بالإنترنت'
                                : 'وضع عدم الاتصال',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(syncState),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),

                // Status Cards
                _buildStatusCards(syncState),
                SizedBox(height: AppSpacing.lg),

                // Error Message
                if (syncState.errorMessage != null) ...[
                  _buildErrorCard(syncState.errorMessage!),
                  SizedBox(height: AppSpacing.lg),
                ],

                // Actions
                _buildActions(context, ref, syncState),
                SizedBox(height: AppSpacing.md),

                // Info Text
                Center(
                  child: Text(
                    'المزامنة التلقائية مفعّلة',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SyncStatusState state) {
    final color = state.isOnline ? AppColors.success : AppColors.warning;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.soft,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            state.isOnline ? 'متصل' : 'غير متصل',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards(SyncStatusState state) {
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            icon: Icons.access_time_rounded,
            label: 'آخر مزامنة',
            value: state.lastSyncTime != null
                ? _formatTime(state.lastSyncTime!)
                : 'لم تتم بعد',
            color: AppColors.info,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatusCard(
            icon: Icons.pending_actions_rounded,
            label: 'معاملات معلقة',
            value: '${state.pendingCount}',
            color:
                state.pendingCount > 0 ? AppColors.warning : AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.border),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
      BuildContext context, WidgetRef ref, SyncStatusState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ProButton(
            label: state.isSyncing ? 'جاري المزامنة...' : 'مزامنة الآن',
            icon: Icons.sync_rounded,
            isLoading: state.isSyncing,
            onPressed: state.isOnline
                ? () {
                    ref.read(syncStatusProvider.notifier).syncNow();
                  }
                : null,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: ProButton(
            label: 'إغلاق',
            type: ProButtonType.outlined,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: AppColors.textTertiary),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Offline Indicator Widget - Shows when app is offline
// ═══════════════════════════════════════════════════════════════════════════

class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);

    if (syncState.isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.warning,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16.sp),
          SizedBox(width: AppSpacing.sm),
          Text(
            'أنت غير متصل بالإنترنت - البيانات ستُزامن تلقائياً عند الاتصال',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sync Floating Action Button - Quick sync button
// ═══════════════════════════════════════════════════════════════════════════

class SyncFAB extends ConsumerWidget {
  final bool mini;

  const SyncFAB({super.key, this.mini = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);

    return FloatingActionButton(
      mini: mini,
      backgroundColor:
          syncState.isOnline ? AppColors.secondary : AppColors.warning,
      foregroundColor: Colors.white,
      onPressed: syncState.isOnline && !syncState.isSyncing
          ? () => ref.read(syncStatusProvider.notifier).syncNow()
          : null,
      child: syncState.isSyncing
          ? SizedBox(
              width: 20.sp,
              height: 20.sp,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Icon(
              syncState.isOnline ? Icons.sync_rounded : Icons.cloud_off_rounded,
            ),
    );
  }
}
