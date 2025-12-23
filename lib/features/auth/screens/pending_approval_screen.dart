// lib/features/auth/screens/pending_approval_screen.dart
// شاشة انتظار موافقة المدير المحسنة - مع تسجيل دخول تلقائي عند الموافقة

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/logger_service.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';

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
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  StreamSubscription<QuerySnapshot>? _approvalSubscription;
  bool _isCheckingApproval = false;
  Timer? _periodicCheckTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startListeningForApproval();
    _startPeriodicCheck();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _animationController.repeat();
  }

  /// بدء مراقبة حالة الموافقة في الوقت الفعلي
  void _startListeningForApproval() {
    AppLogger.i('👂 بدء مراقبة حالة الموافقة للبريد: ${widget.email}');

    _approvalSubscription = FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .limit(1)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final userData = snapshot.docs.first.data();
              final status = userData['status'] as String?;
              final isActive = userData['isActive'] as bool? ?? true;

              AppLogger.d(
                '📊 تحديث حالة المستخدم: status=$status, isActive=$isActive',
              );

              // التحقق من الموافقة
              if ((status == 'approved' || status == 'active') && isActive) {
                AppLogger.i('✅ تمت الموافقة على الحساب!');
                _onApprovalReceived();
              }
            }
          },
          onError: (error) {
            AppLogger.e('❌ خطأ في مراقبة الموافقة', error: error);
          },
        );
  }

  /// فحص دوري كل 10 ثوانٍ (احتياطي)
  void _startPeriodicCheck() {
    _periodicCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkApprovalManually(),
    );
  }

  /// فحص يدوي لحالة الموافقة
  Future<void> _checkApprovalManually() async {
    if (_isCheckingApproval || !mounted) return;

    _isCheckingApproval = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty && mounted) {
        final userData = snapshot.docs.first.data();
        final status = userData['status'] as String?;
        final isActive = userData['isActive'] as bool? ?? true;

        if ((status == 'approved' || status == 'active') && isActive) {
          AppLogger.i('✅ تمت الموافقة (فحص يدوي)!');
          _onApprovalReceived();
        }
      }
    } catch (e) {
      AppLogger.e('❌ خطأ في الفحص اليدوي', error: e);
    } finally {
      _isCheckingApproval = false;
    }
  }

  /// عند استلام الموافقة
  void _onApprovalReceived() {
    // إيقاف المراقبة والمؤقتات
    _approvalSubscription?.cancel();
    _periodicCheckTimer?.cancel();

    if (!mounted) return;

    // عرض رسالة نجاح
    _showApprovalSuccessDialog();
  }

  /// عرض dialog النجاح والانتقال للشاشة الرئيسية
  void _showApprovalSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة النجاح المتحركة
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.successColor,
                        size: 64,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'تمت الموافقة! 🎉',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'تم قبول حسابك بنجاح.\nجاري تسجيل الدخول...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.grey600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );

    // الانتظار قليلاً ثم تسجيل الدخول
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _proceedToLogin();
      }
    });
  }

  /// تسجيل الدخول والانتقال للشاشة الرئيسية
  Future<void> _proceedToLogin() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // تحديث حالة المصادقة
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    // إغلاق الـ dialog
    Navigator.of(context).pop();

    // الانتقال للشاشة الرئيسية
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  /// زر التحقق اليدوي
  Future<void> _onManualCheckPressed() async {
    if (_isCheckingApproval) return;

    setState(() => _isCheckingApproval = true);

    // حفظ المراجع
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        final status = userData['status'] as String?;
        final isActive = userData['isActive'] as bool? ?? true;

        if ((status == 'approved' || status == 'active') && isActive) {
          _onApprovalReceived();
          return;
        } else if (status == 'rejected') {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('تم رفض طلبك. تواصل مع المدير.')),
                ],
              ),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
      }

      // لا يزال في الانتظار
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.hourglass_empty, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('طلبك لا يزال قيد المراجعة')),
            ],
          ),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('خطأ في الاتصال. حاول مرة أخرى.')),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingApproval = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _approvalSubscription?.cancel();
    _periodicCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    // خطوات التسجيل
                    _buildProgressSteps(),

                    const SizedBox(height: 24),

                    // البطاقة الرئيسية
                    _buildMainCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildStep(1, 'إنشاء الحساب', false, true),
          _buildStepLine(true),
          _buildStep(2, 'تفعيل البريد', false, true),
          _buildStepLine(true),
          _buildStep(3, 'موافقة المدير', true, false),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.successColor
                  : isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '$number',
                      style: TextStyle(
                        color: isActive
                            ? AppTheme.primaryColor
                            : Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive ? AppTheme.successColor : Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // أيقونة الساعة المتحركة
          RotationTransition(
            turns: _rotationAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.warningColor.withOpacity(0.15),
                    AppTheme.warningColor.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                size: 56,
                color: AppTheme.warningColor,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // العنوان
          Text(
            widget.isNewAccount
                ? 'تم إنشاء حسابك بنجاح!'
                : 'حسابك قيد المراجعة',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            'طلب تسجيلك قيد المراجعة من قبل المدير.\nسيتم تسجيل دخولك تلقائياً عند الموافقة.',
            style: TextStyle(
              color: AppTheme.grey600,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // البريد الإلكتروني
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    widget.email,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textDirection: TextDirection.ltr,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // مؤشر المراقبة النشطة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'نراقب حالة طلبك...',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ماذا يحدث الآن؟
          _buildInfoSection(),

          const SizedBox(height: 28),

          // زر التحقق اليدوي
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isCheckingApproval ? null : _onManualCheckPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
              ),
              icon: _isCheckingApproval
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: Text(
                _isCheckingApproval ? 'جاري التحقق...' : 'تحقق الآن',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // زر العودة
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: widget.onBackToLogin ?? () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.grey400, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text(
                'العودة لتسجيل الدخول',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ملاحظة التواصل
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.grey200.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: AppTheme.grey600,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'إذا كان لديك استفسار، تواصل مع المدير',
                    style: TextStyle(color: AppTheme.grey600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.infoColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.infoColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'ماذا يحدث الآن؟',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.infoColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.person_search_rounded,
            'سيراجع المدير طلب تسجيلك',
          ),
          _buildInfoItem(
            Icons.auto_awesome_rounded,
            'سيتم تسجيل دخولك تلقائياً عند الموافقة',
          ),
          _buildInfoItem(
            Icons.notifications_active_rounded,
            'يمكنك الانتظار أو العودة لاحقاً',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
