import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/invoices/presentation/screens/invoices_screen.dart';
import '../../features/invoices/presentation/screens/invoice_details_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/inventory/presentation/screens/stock_count_screen.dart';
import '../../features/customers/presentation/screens/customers_screen.dart';
import '../../features/customers/presentation/screens/customer_form_screen.dart';
import '../../features/suppliers/presentation/screens/suppliers_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_form_screen.dart';
import '../../features/shifts/presentation/screens/shifts_screen.dart';
import '../../features/cash/presentation/screens/cash_screen.dart';
import '../../features/returns/presentation/screens/returns_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/backup_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

/// مسارات التطبيق
class AppRoutes {
  static const String home = '/home';
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String pos = '/pos';
  static const String products = '/products';
  static const String productForm = '/products/form';
  static const String categories = '/categories';
  static const String invoices = '/invoices';
  static const String invoiceDetails = '/invoices/details';
  static const String inventory = '/inventory';
  static const String stockCount = '/inventory/count';
  static const String customers = '/customers';
  static const String customerForm = '/customers/form';
  static const String suppliers = '/suppliers';
  static const String supplierForm = '/suppliers/form';
  static const String shifts = '/shifts';
  static const String cash = '/cash';
  static const String returns = '/returns';
  static const String reports = '/reports';
  static const String users = '/users';
  static const String settings = '/settings';
  static const String backup = '/settings/backup';
}

/// مزود Router
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // شاشة البداية
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // تسجيل الدخول
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // الشاشة الرئيسية (Shell)
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          // لوحة التحكم
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // نقطة البيع
          GoRoute(
            path: AppRoutes.pos,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const PosScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // المنتجات
          GoRoute(
            path: AppRoutes.products,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProductsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'form',
                builder: (context, state) {
                  final productId = state.uri.queryParameters['id'];
                  return ProductFormScreen(
                      productId:
                          productId != null ? int.parse(productId) : null);
                },
              ),
            ],
          ),

          // الفئات
          GoRoute(
            path: AppRoutes.categories,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CategoriesScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // الفواتير
          GoRoute(
            path: AppRoutes.invoices,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const InvoicesScreen(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'details/:id',
                builder: (context, state) {
                  final invoiceId = int.parse(state.pathParameters['id']!);
                  return InvoiceDetailsScreen(invoiceId: invoiceId);
                },
              ),
            ],
          ),

          // المخزون
          GoRoute(
            path: AppRoutes.inventory,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const InventoryScreen(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'count',
                builder: (context, state) => const StockCountScreen(),
              ),
            ],
          ),

          // العملاء
          GoRoute(
            path: AppRoutes.customers,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CustomersScreen(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'form',
                builder: (context, state) {
                  final customerId = state.uri.queryParameters['id'];
                  return CustomerFormScreen(
                      customerId:
                          customerId != null ? int.parse(customerId) : null);
                },
              ),
            ],
          ),

          // الموردين
          GoRoute(
            path: AppRoutes.suppliers,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SuppliersScreen(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'form',
                builder: (context, state) {
                  final supplierId = state.uri.queryParameters['id'];
                  return SupplierFormScreen(
                      supplierId:
                          supplierId != null ? int.parse(supplierId) : null);
                },
              ),
            ],
          ),

          // الورديات
          GoRoute(
            path: AppRoutes.shifts,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ShiftsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // الصندوق
          GoRoute(
            path: AppRoutes.cash,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CashScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // المرتجعات
          GoRoute(
            path: AppRoutes.returns,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ReturnsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // التقارير
          GoRoute(
            path: AppRoutes.reports,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ReportsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // المستخدمين
          GoRoute(
            path: AppRoutes.users,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const UsersScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // الإعدادات
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'backup',
                builder: (context, state) => const BackupScreen(),
              ),
            ],
          ),
        ],
      ),
    ],

    // معالجة الأخطاء
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('الصفحة غير موجودة',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
});

// تأثير الانتقال
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}
