// ═══════════════════════════════════════════════════════════════════════════
// Hoor Manager Pro - Main Entry Point
// Professional Accounting & Sales Management System
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router_pro.dart';
import 'core/di/injection.dart';
import 'core/services/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  appLogger.info('🚀 Starting Hoor Manager Pro...');

  // Initialize dependencies (Firebase, Database, Services)
  await configureDependencies();
  appLogger.info('✅ Dependencies configured');

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Preload fonts
  await _preloadFonts();
  appLogger.info('✅ Fonts preloaded');

  appLogger.info('🎉 App initialization complete!');

  runApp(
    DevicePreview(
      enabled: kDebugMode, // Only enabled in debug mode
      builder: (context) => const ProviderScope(
        child: HoorManagerPro(),
      ),
    ),
  );
}

/// Preload Google Fonts for smoother experience
Future<void> _preloadFonts() async {
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.cairo(),
      GoogleFonts.jetBrainsMono(),
    ]);
  } catch (e, stackTrace) {
    appLogger.error('Font preloading failed', e, stackTrace);
  }
}

class HoorManagerPro extends ConsumerWidget {
  const HoorManagerPro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProProvider);

    return ScreenUtilInit(
      // iPhone 13 design size
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Hoor Manager Pro',
          debugShowCheckedModeBanner: false,

          // ═══════════════════════════════════════════════════════════════════
          // Device Preview Support
          // ═══════════════════════════════════════════════════════════════════
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          supportedLocales: const [
            Locale('ar', 'SA'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ═══════════════════════════════════════════════════════════════════
          // Theme
          // ═══════════════════════════════════════════════════════════════════
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light, // TODO: Make this configurable

          // ═══════════════════════════════════════════════════════════════════
          // Router
          // ═══════════════════════════════════════════════════════════════════
          routerConfig: router,
        );
      },
    );
  }
}
