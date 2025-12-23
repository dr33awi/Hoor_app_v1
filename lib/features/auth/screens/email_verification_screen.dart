// lib/features/auth/screens/email_verification_screen.dart
// شاشة التحقق من البريد - تصميم محسّن

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'pending_approval_screen.dart';
import '../../../core/theme/app_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isResending = false;
  bool _isChecking = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _startAutoCheck();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startAutoCheck() {
    final authProvider = context.read<AuthProvider>();
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_isChecking && mounted) {
        _checkVerificationSilently(authProvider);
      }
    });
  }

  Future<void> _checkVerificationSilently(AuthProvider authProvider) async {
    if (!mounted) return;
    final isVerified = await authProvider.checkEmailVerificationOnly();
    if (isVerified && mounted) {
      _autoCheckTimer?.cancel();
      _navigateToPendingApproval();
    }
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        if (mounted) setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;

    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isResending = true);
    final success = await authProvider.resendVerificationEmail();

    if (mounted) {
      setState(() => _isResending = false);
      if (success) {
        _startCooldown();
        _showSnackBar(messenger, 'تم إرسال الرابط بنجاح', isSuccess: true);
      } else {
        _showSnackBar(
          messenger,
          authProvider.error ?? 'حدث خطأ',
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _checkVerification() async {
    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isChecking = true);
    final isVerified = await authProvider.checkEmailVerificationOnly();

    if (mounted) {
      setState(() => _isChecking = false);
      if (isVerified) {
        _showSnackBar(messenger, 'تم التفعيل بنجاح! 🎉', isSuccess: true);
        _autoCheckTimer?.cancel();
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) _navigateToPendingApproval();
      } else {
        _showSnackBar(messenger, 'لم يتم التفعيل بعد', isSuccess: false);
      }
    }
  }

  void _navigateToPendingApproval() {
    final navigator = Navigator.of(context);
    final authProvider = context.read<AuthProvider>();
    authProvider.signOutAfterVerification();
    navigator.pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PendingApprovalScreen(
          email: widget.email,
          isNewAccount: true,
          onBackToLogin: () => navigator.popUntil((route) => route.isFirst),
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showSnackBar(
    ScaffoldMessengerState messenger,
    String message, {
    required bool isSuccess,
  }) {
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSuccess ? Icons.check_rounded : Icons.error_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.warning.withValues(alpha: 0.05),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildSteps(),
                        const SizedBox(height: 40),
                        _buildContent(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.grey.shade700,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSteps() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepItem(1, 'البيانات', Icons.person_outline, done: true),
          _buildStepLine(true),
          _buildStepItem(2, 'التحقق', Icons.email_outlined, active: true),
          _buildStepLine(false),
          _buildStepItem(3, 'الموافقة', Icons.verified_outlined),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    int step,
    String label,
    IconData icon, {
    bool active = false,
    bool done = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: done
                  ? const LinearGradient(
                      colors: [AppColors.success, Color(0xFF2E7D32)],
                    )
                  : active
                  ? LinearGradient(
                      colors: [
                        AppColors.warning,
                        AppColors.warning.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: (!done && !active) ? Colors.grey.shade100 : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: (done || active)
                  ? [
                      BoxShadow(
                        color: (done ? AppColors.success : AppColors.warning)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
                : Icon(
                    icon,
                    size: 20,
                    color: active ? Colors.white : Colors.grey.shade400,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: (active || done) ? FontWeight.w600 : FontWeight.w500,
              color: done
                  ? AppColors.success
                  : active
                  ? AppColors.warning
                  : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool active) {
    return Container(
      width: 30,
      height: 3,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: active ? AppColors.success : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Animated Email Icon
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.warning.withValues(alpha: 0.15),
                  AppColors.warning.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.mark_email_unread_rounded,
              size: 42,
              color: AppColors.warning,
            ),
          ),
        ),

        const SizedBox(height: 32),

        const Text(
          'تحقق من بريدك الإلكتروني',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'أرسلنا رابط التحقق إلى بريدك',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),

        const SizedBox(height: 16),

        // Email container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.email_outlined,
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 10),
              Text(
                widget.email,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Instructions Card
        Container(
          padding: const EdgeInsets.all(20),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.checklist_rounded,
                      size: 18,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'خطوات التفعيل',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildInstructionItem(
                1,
                'افتح بريدك الإلكتروني',
                Icons.inbox_rounded,
              ),
              const SizedBox(height: 12),
              _buildInstructionItem(
                2,
                'اضغط على رابط التفعيل',
                Icons.link_rounded,
              ),
              const SizedBox(height: 12),
              _buildInstructionItem(
                3,
                'عد هنا واضغط "تحقق الآن"',
                Icons.refresh_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Check Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isChecking ? null : _checkVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              disabledBackgroundColor: AppColors.success.withValues(alpha: 0.5),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isChecking
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_rounded, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'تحقق الآن',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Resend section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'لم تصلك الرسالة؟',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: (_isResending || _resendCooldown > 0)
                    ? null
                    : _resendEmail,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (_isResending || _resendCooldown > 0)
                        ? Colors.grey.shade200
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isResending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(
                          _resendCooldown > 0
                              ? 'إعادة الإرسال ($_resendCooldown)'
                              : 'إعادة الإرسال',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _resendCooldown > 0
                                ? Colors.grey.shade500
                                : AppColors.primary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tip
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: AppColors.info,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تحقق من مجلد Spam أو البريد غير الهام',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildInstructionItem(int num, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF1A1A2E)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$num',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.gray700),
          ),
        ),
      ],
    );
  }
}
