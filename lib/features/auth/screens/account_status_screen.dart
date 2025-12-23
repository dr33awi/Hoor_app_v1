// lib/features/auth/screens/account_status_screen.dart
// شاشة حالة الحساب - تصميم محسّن

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum AccountStatusType { rejected, disabled, pending }

class AccountStatusScreen extends StatelessWidget {
  final AccountStatusType status;
  final String email;
  final String message;
  final VoidCallback onBackToLogin;

  const AccountStatusScreen({
    super.key,
    required this.status,
    required this.email,
    required this.message,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getColor().withValues(alpha: 0.05),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getColor().withValues(alpha: 0.15),
                              _getColor().withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: _getColor().withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(_getIcon(), size: 48, color: _getColor()),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      _getTitle(),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: _getColor(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Message Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getColor(),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getStatusLabel(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            message,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Email
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 16,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textDirection: TextDirection.ltr,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.info.withValues(alpha: 0.1),
                            AppColors.info.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _getInfoMessage(),
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.info.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    _buildActionButtons(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onBackToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back_rounded, size: 20),
                SizedBox(width: 10),
                Text(
                  'العودة لتسجيل الدخول',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),

        if (status == AccountStatusType.rejected) ...[
          const SizedBox(height: 12),
          // Contact support button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                // Contact support action
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent_rounded,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'تواصل مع الدعم',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getColor() {
    switch (status) {
      case AccountStatusType.rejected:
        return AppColors.error;
      case AccountStatusType.disabled:
        return AppColors.warning;
      case AccountStatusType.pending:
        return AppColors.info;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case AccountStatusType.rejected:
        return Icons.cancel_rounded;
      case AccountStatusType.disabled:
        return Icons.block_rounded;
      case AccountStatusType.pending:
        return Icons.hourglass_top_rounded;
    }
  }

  String _getTitle() {
    switch (status) {
      case AccountStatusType.rejected:
        return 'تم رفض الحساب';
      case AccountStatusType.disabled:
        return 'الحساب معطل';
      case AccountStatusType.pending:
        return 'في انتظار الموافقة';
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case AccountStatusType.rejected:
        return 'مرفوض';
      case AccountStatusType.disabled:
        return 'معطل';
      case AccountStatusType.pending:
        return 'قيد المراجعة';
    }
  }

  String _getInfoMessage() {
    switch (status) {
      case AccountStatusType.rejected:
        return 'إذا كنت تعتقد أن هذا خطأ، يمكنك التواصل مع مدير النظام لمراجعة طلبك.';
      case AccountStatusType.disabled:
        return 'تم تعطيل حسابك من قبل المدير. تواصل مع الدعم الفني للمساعدة.';
      case AccountStatusType.pending:
        return 'طلبك قيد المراجعة من قبل الإدارة. سيتم إعلامك عبر البريد عند الموافقة.';
    }
  }
}
