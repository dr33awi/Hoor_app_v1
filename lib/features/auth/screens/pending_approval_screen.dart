// lib/features/auth/screens/pending_approval_screen.dart
// شاشة انتظار الموافقة - تصميم محسّن

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/theme/app_theme.dart';

class PendingApprovalScreen extends StatefulWidget {
  final String email;
  final bool isNewAccount;
  final VoidCallback? onBackToLogin;

  const PendingApprovalScreen({
    super.key,
    required this.email,
    this.isNewAccount = false,
    this.onBackToLogin,
  });

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<QuerySnapshot>? _approvalSubscription;
  bool _isChecking = false;
  Timer? _periodicCheckTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _startListeningForApproval();
    _startPeriodicCheck();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startListeningForApproval() {
    _approvalSubscription = FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final data = snapshot.docs.first.data();
            final status = data['status'] as String?;
            final isActive = data['isActive'] as bool? ?? true;
            if ((status == 'approved' || status == 'active') && isActive) {
              _onApprovalReceived();
            }
          }
        });
  }

  void _startPeriodicCheck() {
    _periodicCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkManually(),
    );
  }

  Future<void> _checkManually() async {
    if (_isChecking || !mounted) return;
    _isChecking = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty && mounted) {
        final data = snapshot.docs.first.data();
        final status = data['status'] as String?;
        final isActive = data['isActive'] as bool? ?? true;
        if ((status == 'approved' || status == 'active') && isActive) {
          _onApprovalReceived();
        }
      }
    } catch (_) {}
    _isChecking = false;
  }

  void _onApprovalReceived() {
    _approvalSubscription?.cancel();
    _periodicCheckTimer?.cancel();
    if (!mounted) return;
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (_, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.success, Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'تمت الموافقة! 🎉',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'مرحباً بك في مدير هور',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'جاري تسجيل الدخول...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _proceedToHome();
    });
  }

  Future<void> _proceedToHome() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _onCheckPressed() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final status = data['status'] as String?;
        final isActive = data['isActive'] as bool? ?? true;

        if ((status == 'approved' || status == 'active') && isActive) {
          _onApprovalReceived();
          return;
        } else if (status == 'rejected') {
          _showSnackBar(messenger, 'تم رفض طلبك', isSuccess: false);
          return;
        }
      }

      _showSnackBar(messenger, 'لا يزال قيد المراجعة', isSuccess: false);
    } catch (_) {
      if (mounted) _showSnackBar(messenger, 'خطأ في الاتصال', isSuccess: false);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
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
                isSuccess ? Icons.check_rounded : Icons.info_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.warning,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  void dispose() {
    _approvalSubscription?.cancel();
    _periodicCheckTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
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
              AppColors.success.withValues(alpha: 0.05),
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
            onPressed: widget.onBackToLogin ?? () => Navigator.pop(context),
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
          _buildStepItem(2, 'التحقق', Icons.email_outlined, done: true),
          _buildStepLine(true),
          _buildStepItem(3, 'الموافقة', Icons.verified_outlined, active: true),
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
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: (!done && !active) ? Colors.grey.shade100 : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: (done || active)
                  ? [
                      BoxShadow(
                        color: (done ? AppColors.success : AppColors.primary)
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
                  ? AppColors.primary
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
        // Animated Icon
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
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 42,
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 32),

        Text(
          widget.isNewAccount
              ? 'تم إنشاء حسابك بنجاح! 🎉'
              : 'حسابك قيد المراجعة',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          'طلبك قيد المراجعة من قبل الإدارة',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),

        const SizedBox(height: 18),

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

        const SizedBox(height: 24),

        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'نراقب حالة طلبك تلقائياً',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Info Card
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'ماذا يحدث الآن؟',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildInfoItem(
                Icons.admin_panel_settings_outlined,
                'سيراجع المدير طلبك',
              ),
              const SizedBox(height: 12),
              _buildInfoItem(Icons.login_rounded, 'سيتم تسجيل دخولك تلقائياً'),
              const SizedBox(height: 12),
              _buildInfoItem(
                Icons.schedule_outlined,
                'يمكنك الانتظار أو العودة لاحقاً',
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
            onPressed: _isChecking ? null : _onCheckPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
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
                        Icon(Icons.refresh_rounded, size: 20),
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

        const SizedBox(height: 14),

        // Back Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: widget.onBackToLogin ?? () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'العودة لتسجيل الدخول',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 12),
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
