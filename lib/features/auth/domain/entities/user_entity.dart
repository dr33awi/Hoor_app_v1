/// كيان المستخدم
class UserEntity {
  final int id;
  final String name;
  final String username;
  final UserRole role;
  final String? phone;
  final String? email;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.phone,
    this.email,
    this.isActive = true,
    this.createdAt,
    this.lastLoginAt,
  });

  /// التحقق من صلاحية معينة
  bool hasPermission(String permission) {
    return role.permissions.contains(permission);
  }

  /// هل يمكنه الوصول لنقطة البيع؟
  bool get canAccessPos => hasPermission(Permissions.posAccess);

  /// هل يمكنه إدارة المنتجات؟
  bool get canManageProducts => hasPermission(Permissions.manageProducts);

  /// هل يمكنه عرض التقارير؟
  bool get canViewReports => hasPermission(Permissions.viewReports);

  /// هل يمكنه إدارة المستخدمين؟
  bool get canManageUsers => hasPermission(Permissions.manageUsers);
}

/// أدوار المستخدمين
enum UserRole {
  manager,
  cashier,
  accountant;

  String get displayName {
    switch (this) {
      case UserRole.manager:
        return 'مدير';
      case UserRole.cashier:
        return 'كاشير';
      case UserRole.accountant:
        return 'محاسب';
    }
  }

  List<String> get permissions {
    switch (this) {
      case UserRole.manager:
        return Permissions.all;
      case UserRole.cashier:
        return Permissions.cashierPermissions;
      case UserRole.accountant:
        return Permissions.accountantPermissions;
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'manager':
        return UserRole.manager;
      case 'cashier':
        return UserRole.cashier;
      case 'accountant':
        return UserRole.accountant;
      default:
        return UserRole.cashier;
    }
  }
}

/// الصلاحيات
class Permissions {
  // نقطة البيع
  static const String posAccess = 'pos_access';
  static const String posDiscount = 'pos_discount';
  static const String posCancelInvoice = 'pos_cancel_invoice';

  // المنتجات
  static const String viewProducts = 'view_products';
  static const String manageProducts = 'manage_products';
  static const String deleteProducts = 'delete_products';

  // الفئات
  static const String viewCategories = 'view_categories';
  static const String manageCategories = 'manage_categories';

  // الفواتير
  static const String viewInvoices = 'view_invoices';
  static const String manageInvoices = 'manage_invoices';
  static const String deleteInvoices = 'delete_invoices';

  // المخزون
  static const String viewInventory = 'view_inventory';
  static const String manageInventory = 'manage_inventory';
  static const String stockAdjustment = 'stock_adjustment';

  // العملاء والموردين
  static const String viewCustomers = 'view_customers';
  static const String manageCustomers = 'manage_customers';
  static const String viewSuppliers = 'view_suppliers';
  static const String manageSuppliers = 'manage_suppliers';

  // المالية
  static const String viewCash = 'view_cash';
  static const String manageCash = 'manage_cash';
  static const String viewShifts = 'view_shifts';
  static const String manageShifts = 'manage_shifts';

  // التقارير
  static const String viewReports = 'view_reports';
  static const String exportReports = 'export_reports';

  // الإعدادات
  static const String viewSettings = 'view_settings';
  static const String manageSettings = 'manage_settings';
  static const String manageUsers = 'manage_users';
  static const String manageBackup = 'manage_backup';

  /// جميع الصلاحيات
  static const List<String> all = [
    posAccess,
    posDiscount,
    posCancelInvoice,
    viewProducts,
    manageProducts,
    deleteProducts,
    viewCategories,
    manageCategories,
    viewInvoices,
    manageInvoices,
    deleteInvoices,
    viewInventory,
    manageInventory,
    stockAdjustment,
    viewCustomers,
    manageCustomers,
    viewSuppliers,
    manageSuppliers,
    viewCash,
    manageCash,
    viewShifts,
    manageShifts,
    viewReports,
    exportReports,
    viewSettings,
    manageSettings,
    manageUsers,
    manageBackup,
  ];

  /// صلاحيات الكاشير
  static const List<String> cashierPermissions = [
    posAccess,
    viewProducts,
    viewCategories,
    viewInvoices,
    viewCustomers,
    viewShifts,
  ];

  /// صلاحيات المحاسب
  static const List<String> accountantPermissions = [
    posAccess,
    posDiscount,
    viewProducts,
    manageProducts,
    viewCategories,
    manageCategories,
    viewInvoices,
    manageInvoices,
    viewInventory,
    manageInventory,
    viewCustomers,
    manageCustomers,
    viewSuppliers,
    manageSuppliers,
    viewCash,
    manageCash,
    viewShifts,
    manageShifts,
    viewReports,
    exportReports,
    viewSettings,
  ];
}
