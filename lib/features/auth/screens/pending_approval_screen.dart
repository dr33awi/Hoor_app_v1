// lib/features/auth/screens/pending_approval_screen.dart
// شاشة انتظار الموافقة - تصميم حديث

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

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  StreamSubscription<QuerySnapshot>? _approvalSubscription;
  bool _isChecking = false;
  Timer? _periodicCheckTimer;

  @override
  void initState() {
    super.initState();
    _startListeningForApproval();
    _startPeriodicCheck();
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تمت الموافقة! 🎉',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'جاري تسجيل الدخول...',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.success,
                  ),
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
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? AppColors.success
            : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _approvalSubscription?.cancel();
    _periodicCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onBackToLogin ?? () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey.shade700,
            size: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                children: [
                  _buildSteps(),
                  const SizedBox(height: 48),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepDot(1, false, true),
        _stepLine(true),
        _stepDot(2, false, true),
        _stepLine(true),
        _stepDot(3, true, false),
      ],
    );
  }

  Widget _stepDot(int num, bool active, bool done) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: done
            ? AppColors.success
            : active
            ? AppColors.primary
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '$num',
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }

  Widget _stepLine(bool active) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: active ? AppColors.success : Colors.grey.shade200,
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.hourglass_top_rounded,
            size: 36,
            color: AppColors.warning,
          ),
        ),

        const SizedBox(height: 28),

        Text(
          widget.isNewAccount ? 'تم إنشاء حسابك!' : 'حسابك قيد المراجعة',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'طلبك قيد المراجعة من قبل المدير',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.email,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.primary,
            ),
            textDirection: TextDirection.ltr,
          ),
        ),

        const SizedBox(height: 24),

        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'نراقب حالة طلبك',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // Info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.skyBlueLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.skyBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ماذا يحدث الآن؟',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.skyBlue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _infoItem('سيراجع المدير طلبك'),
              const SizedBox(height: 8),
              _infoItem('سيتم تسجيل دخولك تلقائياً'),
              const SizedBox(height: 8),
              _infoItem('يمكنك الانتظار أو العودة لاحقاً'),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Check Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isChecking ? null : _onCheckPressed,
            icon: _isChecking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              _isChecking ? 'جاري التحقق' : 'تحقق الآن',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'العودة لتسجيل الدخول',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoItem(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.skyBlue,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.gray700),
        ),
      ],
    );
  }
}



