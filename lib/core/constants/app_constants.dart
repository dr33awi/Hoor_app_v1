// lib/core/constants/app_constants.dart
// ثوابت التطبيق - محسنة

class AppConstants {
  // منع إنشاء instance
  AppConstants._();

  // ==================== معلومات التطبيق ====================
  static const String appName = 'مدير المبيعات';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ==================== Firebase Collections ====================
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String salesCollection = 'sales';
  static const String categoriesCollection = 'categories';
  static const String settingsCollection = 'settings';
  static const String auditLogsCollection = 'audit_logs';
  static const String notificationsCollection = 'notifications';

  // ==================== Firebase Storage Paths ====================
  static const String productsImagesPath = 'products';
  static const String usersImagesPath = 'users';
  static const String receiptsPath = 'receipts';

  // ==================== Shared Preferences Keys ====================
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userNameKey = 'user_name';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String lastSyncKey = 'last_sync';
  static const String offlineModeKey = 'offline_mode';

  // ==================== Hive Box Names ====================
  static const String productsBox = 'products_cache';
  static const String salesBox = 'sales_cache';
  static const String categoriesBox = 'categories_cache';
  static const String settingsBox = 'settings_cache';
  static const String pendingSalesBox = 'pending_sales';

  // ==================== User Roles ====================
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';
  static const String roleCashier = 'cashier';
  static const String roleManager = 'manager';

  // ==================== Account Status ====================
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusSuspended = 'suspended';

  // ==================== Sale Status ====================
  static const String saleStatusCompleted = 'مكتمل';
  static const String saleStatusPending = 'معلق';
  static const String saleStatusCancelled = 'ملغي';
  static const String saleStatusRefunded = 'مسترجع';
  static const String saleStatusPartialRefund = 'استرجاع جزئي';

  // ==================== Payment Methods ====================
  static const String paymentCash = 'نقدي';
  static const String paymentCard = 'بطاقة';
  static const String paymentCredit = 'آجل';
  static const String paymentTransfer = 'تحويل';
  static const String paymentMixed = 'مختلط';

  // ==================== Default Values ====================
  static const double defaultTaxRate = 0.15; // 15% VAT
  static const int lowStockThreshold = 5;
  static const int criticalStockThreshold = 2;
  static const int maxDiscountPercent = 50;
  static const int invoiceNumberLength = 4;
  static const int maxCartItems = 100;
  static const int maxQuantityPerItem = 99;

  // ==================== Pagination ====================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int productsPageSize = 30;
  static const int salesPageSize = 25;

  // ==================== Timeouts ====================
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds
  static const int cacheExpiry = 60; // minutes

  // ==================== UI Constants ====================
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 20.0;
  static const double buttonHeight = 50.0;
  static const double inputHeight = 56.0;
  static const double cardElevation = 2.0;

  // ==================== Animation Durations ====================
  static const int shortAnimationDuration = 200; // ms
  static const int normalAnimationDuration = 300; // ms
  static const int longAnimationDuration = 500; // ms

  // ==================== Validation ====================
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 32;
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  static const int phoneLength = 10;
  static const int maxNotesLength = 500;

  // ==================== Currency ====================
  static const String currencyCode = 'SAR';
  static const String currencySymbol = 'ر.س';
  static const String currencyName = 'ريال سعودي';
  static const int currencyDecimalPlaces = 2;

  // ==================== Date Formats ====================
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd/MM/yyyy - hh:mm a';
  static const String invoiceDateFormat = 'dd MMMM yyyy';

  // ==================== Regex Patterns ====================
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(r'^(05|5)[0-9]{8}$');
  static final RegExp arabicRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
  static final RegExp priceRegex = RegExp(r'^\d+\.?\d{0,2}$');

  // ==================== Error Messages ====================
  static const String networkError = 'تحقق من اتصالك بالإنترنت';
  static const String serverError = 'حدث خطأ في الخادم';
  static const String unknownError = 'حدث خطأ غير متوقع';
  static const String sessionExpired = 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً';
  static const String permissionDenied = 'ليس لديك صلاحية لهذه العملية';
  static const String dataNotFound = 'البيانات غير موجودة';

  // ==================== Success Messages ====================
  static const String saveSuccess = 'تم الحفظ بنجاح';
  static const String deleteSuccess = 'تم الحذف بنجاح';
  static const String updateSuccess = 'تم التحديث بنجاح';
  static const String saleSuccess = 'تمت عملية البيع بنجاح';
  static const String loginSuccess = 'تم تسجيل الدخول بنجاح';
  static const String logoutSuccess = 'تم تسجيل الخروج بنجاح';
}

/// أنواع سجلات التدقيق
class AuditAction {
  AuditAction._();

  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String sale = 'sale';
  static const String refund = 'refund';
  static const String cancelSale = 'cancel_sale';
  static const String updateStock = 'update_stock';
  static const String approveUser = 'approve_user';
  static const String rejectUser = 'reject_user';
}

/// أنواع الإشعارات
class NotificationType {
  NotificationType._();

  static const String lowStock = 'low_stock';
  static const String outOfStock = 'out_of_stock';
  static const String newSale = 'new_sale';
  static const String newUser = 'new_user';
  static const String accountApproved = 'account_approved';
  static const String accountRejected = 'account_rejected';
  static const String systemAlert = 'system_alert';
}

class BarcodeConstants {
  BarcodeConstants._();

  // ==================== إعدادات الباركود ====================
  static const String defaultStoreCode = 'SHO';
  static const int barcodeLength = 12;
  static const int variantBarcodeMaxLength = 20;

  // ==================== ألوان افتراضية للأحذية ====================
  static const List<String> defaultColors = [
    'أسود',
    'أبيض',
    'بني',
    'رمادي',
    'كحلي',
    'بيج',
    'أحمر',
    'أزرق',
    'عنابي',
    'ذهبي',
    'فضي',
  ];

  // ==================== أكواد الألوان للباركود ====================
  static const Map<String, String> colorCodes = {
    'أسود': 'BK',
    'أبيض': 'WH',
    'أحمر': 'RD',
    'أزرق': 'BL',
    'أخضر': 'GR',
    'بني': 'BR',
    'رمادي': 'GY',
    'بيج': 'BG',
    'كحلي': 'NV',
    'عنابي': 'MR',
    'ذهبي': 'GD',
    'فضي': 'SL',
  };

  // ==================== مقاسات افتراضية ====================
  static const List<int> menSizes = [40, 41, 42, 43, 44, 45, 46];
  static const List<int> womenSizes = [36, 37, 38, 39, 40, 41];
  static const List<int> childrenSizes = [
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
  ];

  // ==================== فئات افتراضية للأحذية ====================
  static const List<String> defaultCategories = [
    'رياضي',
    'رسمي',
    'كاجوال',
    'أطفال',
    'نسائي',
    'صنادل',
    'شتوي',
    'صيفي',
  ];
}

/// سجل حركات المخزون
class InventoryLogCollection {
  static const String collectionName = 'inventory_log';
}

/// أنواع حركات المخزون
class InventoryAction {
  InventoryAction._();

  static const String add = 'add';
  static const String remove = 'remove';
  static const String sale = 'sale';
  static const String refund = 'refund';
  static const String adjustment = 'adjustment';
  static const String transfer = 'transfer';
}
