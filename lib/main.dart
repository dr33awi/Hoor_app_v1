// lib/main.dart
// نقطة البداية للتطبيق

import 'package:device_preview/device_preview.dart';
import 'package:hoor_manager/features/sales/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/services/firebase_service.dart';
import 'core/services/logger_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/products/providers/product_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.i('🚀 بدء تشغيل التطبيق...');

  // تهيئة Firebase
  AppLogger.startOperation('تهيئة Firebase');
  final firebaseService = FirebaseService();
  final result = await firebaseService.initialize();

  if (result.success) {
    AppLogger.endOperation('تهيئة Firebase', success: true);
  } else {
    AppLogger.e('فشل في تهيئة Firebase', error: result.error);
  }

  AppLogger.i('✅ التطبيق جاهز للتشغيل');

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // تفعيل فقط في وضع التطوير
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        // إعدادات DevicePreview
        useInheritedMediaQuery: true,
        builder: DevicePreview.appBuilder,

        // إعدادات اللغة العربية
        locale: DevicePreview.locale(context) ?? const Locale('ar', 'SA'),
        supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // الثيم
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // الشاشة الرئيسية
        home: const AuthWrapper(),
      ),
    );
  }
}

/// غلاف المصادقة - يحدد الشاشة بناءً على حالة تسجيل الدخول
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // جاري التحميل
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري التحميل...'),
                ],
              ),
            ),
          );
        }

        // مسجل الدخول
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        // غير مسجل الدخول
        return const LoginScreen();
      },
    );
  }
}
