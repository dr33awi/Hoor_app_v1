// lib/core/services/local_storage_service.dart
// خدمة التخزين المحلي باستخدام SharedPreferences و Hive

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import 'base_service.dart';
import 'logger_service.dart';

/// خدمة التخزين المحلي
class LocalStorageService extends BaseService {
  // Singleton
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// تهيئة الخدمة
  Future<ServiceResult<void>> initialize() async {
    if (_initialized) return ServiceResult.success();

    try {
      AppLogger.startOperation('تهيئة LocalStorage');

      // تهيئة SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // تهيئة Hive
      await Hive.initFlutter();

      // فتح الصناديق المطلوبة
      await _openBoxes();

      _initialized = true;
      AppLogger.endOperation('تهيئة LocalStorage', success: true);
      return ServiceResult.success();
    } catch (e, stackTrace) {
      AppLogger.e('فشل تهيئة LocalStorage', error: e, stackTrace: stackTrace);
      return ServiceResult.failure(handleError(e));
    }
  }

  /// فتح صناديق Hive
  Future<void> _openBoxes() async {
    await Hive.openBox<String>(AppConstants.productsBox);
    await Hive.openBox<String>(AppConstants.salesBox);
    await Hive.openBox<String>(AppConstants.categoriesBox);
    await Hive.openBox<String>(AppConstants.settingsBox);
    await Hive.openBox<String>(AppConstants.pendingSalesBox);
  }

  // ==================== SharedPreferences Operations ====================

  /// حفظ قيمة String
  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  /// قراءة قيمة String
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// حفظ قيمة int
  Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  /// قراءة قيمة int
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// حفظ قيمة bool
  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  /// قراءة قيمة bool
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// حفظ قيمة double
  Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  /// قراءة قيمة double
  double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  /// حفظ قائمة String
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  /// قراءة قائمة String
  List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  /// حفظ كائن JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await setString(key, jsonEncode(value));
  }

  /// قراءة كائن JSON
  Map<String, dynamic>? getJson(String key) {
    final value = getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.e('خطأ في قراءة JSON', error: e);
      return null;
    }
  }

  /// حذف قيمة
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  /// مسح كل البيانات
  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  /// التحقق من وجود مفتاح
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // ==================== Hive Operations ====================

  /// الحصول على صندوق
  Box<String>? _getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      AppLogger.w('الصندوق $boxName غير مفتوح');
      return null;
    }
    return Hive.box<String>(boxName);
  }

  /// حفظ في Hive
  Future<void> hiveSet(String boxName, String key, dynamic value) async {
    final box = _getBox(boxName);
    if (box != null) {
      await box.put(key, jsonEncode(value));
    }
  }

  /// قراءة من Hive
  T? hiveGet<T>(
    String boxName,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final box = _getBox(boxName);
    if (box == null) return null;

    final value = box.get(key);
    if (value == null) return null;

    try {
      return fromJson(jsonDecode(value) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.e('خطأ في قراءة من Hive', error: e);
      return null;
    }
  }

  /// قراءة كل القيم من صندوق
  List<T> hiveGetAll<T>(
    String boxName,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final box = _getBox(boxName);
    if (box == null) return [];

    final results = <T>[];
    for (final value in box.values) {
      try {
        results.add(fromJson(jsonDecode(value) as Map<String, dynamic>));
      } catch (e) {
        AppLogger.e('خطأ في قراءة عنصر', error: e);
      }
    }
    return results;
  }

  /// حذف من Hive
  Future<void> hiveDelete(String boxName, String key) async {
    final box = _getBox(boxName);
    await box?.delete(key);
  }

  /// مسح صندوق
  Future<void> hiveClear(String boxName) async {
    final box = _getBox(boxName);
    await box?.clear();
  }

  /// عدد العناصر في صندوق
  int hiveCount(String boxName) {
    final box = _getBox(boxName);
    return box?.length ?? 0;
  }

  // ==================== Cache Operations ====================

  /// حفظ مع تاريخ انتهاء
  Future<void> setWithExpiry(String key, dynamic value, Duration expiry) async {
    final data = {
      'value': value,
      'expiry': DateTime.now().add(expiry).toIso8601String(),
    };
    await setJson(key, data);
  }

  /// قراءة مع التحقق من الانتهاء
  T? getWithExpiry<T>(String key) {
    final data = getJson(key);
    if (data == null) return null;

    final expiry = DateTime.tryParse(data['expiry'] as String? ?? '');
    if (expiry == null || expiry.isBefore(DateTime.now())) {
      remove(key);
      return null;
    }

    return data['value'] as T?;
  }

  // ==================== User Session ====================

  /// حفظ بيانات الجلسة
  Future<void> saveSession({
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    await setString(AppConstants.userIdKey, userId);
    await setString(AppConstants.userNameKey, userName);
    await setString(AppConstants.userRoleKey, userRole);
  }

  /// قراءة بيانات الجلسة
  Map<String, String?> getSession() {
    return {
      'userId': getString(AppConstants.userIdKey),
      'userName': getString(AppConstants.userNameKey),
      'userRole': getString(AppConstants.userRoleKey),
    };
  }

  /// مسح الجلسة
  Future<void> clearSession() async {
    await remove(AppConstants.userIdKey);
    await remove(AppConstants.userNameKey);
    await remove(AppConstants.userRoleKey);
  }

  /// التحقق من وجود جلسة
  bool hasSession() {
    return containsKey(AppConstants.userIdKey);
  }

  // ==================== Cleanup ====================

  /// تنظيف الموارد
  Future<void> dispose() async {
    await Hive.close();
    AppLogger.d('تم تنظيف LocalStorageService');
  }
}
