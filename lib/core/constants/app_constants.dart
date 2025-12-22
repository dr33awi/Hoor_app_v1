// lib/core/constants/app_constants.dart
// ثوابت التطبيق

class AppConstants {
  // اسم التطبيق
  static const String appName = 'مدير المبيعات';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String salesCollection = 'sales';
  static const String categoriesCollection = 'categories';
  static const String settingsCollection = 'settings';

  // Firebase Storage Paths
  static const String productsImagesPath = 'products';

  // Shared Preferences Keys
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userNameKey = 'user_name';
  static const String themeKey = 'theme_mode';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';

  // Sale Status
  static const String saleStatusCompleted = 'مكتمل';
  static const String saleStatusPending = 'معلق';
  static const String saleStatusCancelled = 'ملغي';

  // Payment Methods
  static const String paymentCash = 'نقدي';
  static const String paymentCard = 'بطاقة';
  static const String paymentCredit = 'آجل';

  // Default Values
  static const double defaultTaxRate = 0.15; // 15% VAT
  static const int lowStockThreshold = 5;
}
