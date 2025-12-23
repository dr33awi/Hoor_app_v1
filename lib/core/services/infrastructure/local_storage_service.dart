// lib/core/services/infrastructure/local_storage_service.dart
// خدمة التخزين المحلي - SharedPreferences و Hive

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import '../../constants/app_constants.dart';
import '../base/base_service.dart';
import '../base/logger_service.dart';

/// خدمة التخزين المحلي
class LocalStorageService extends BaseService {
  // Singleton
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;
  String? _encryptionKey;

  bool get isInitialized => _initialized;

  /// تهيئة الخدمة
  Future<ServiceResult<void>> initialize() async {
    if (_initialized) return ServiceResult.success();

    try {
      AppLogger.startOperation('تهيئة LocalStorage');

      _prefs = await SharedPreferences.getInstance();
      await Hive.initFlutter();
      await _initEncryptionKey();
      await _openBoxes();

      _initialized = true;
      AppLogger.endOperation('تهيئة LocalStorage', success: true);
      return ServiceResult.success();
    } catch (e, stackTrace) {
      AppLogger.e('فشل تهيئة LocalStorage', error: e, stackTrace: stackTrace);
      return ServiceResult.failure(handleError(e));
    }
  }

  /// تهيئة مفتاح التشفير
  Future<void> _initEncryptionKey() async {
    const keyName = 'encryption_key_v1';
    _encryptionKey = _prefs?.getString(keyName);

    if (_encryptionKey == null) {
      _encryptionKey = _generateSecureKey(32);
      await _prefs?.setString(keyName, _encryptionKey!);
      AppLogger.d('تم إنشاء مفتاح تشفير جديد');
    }
  }

  String _generateSecureKey(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Encode(values);
  }

  String _encrypt(String plainText) {
    if (_encryptionKey == null) return plainText;
    try {
      final keyBytes = utf8.encode(_encryptionKey!);
      final textBytes = utf8.encode(plainText);
      final encryptedBytes = <int>[];
      for (int i = 0; i < textBytes.length; i++) {
        encryptedBytes.add(textBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      return base64Encode(encryptedBytes);
    } catch (e) {
      return plainText;
    }
  }

  String _decrypt(String encryptedText) {
    if (_encryptionKey == null) return encryptedText;
    try {
      final keyBytes = utf8.encode(_encryptionKey!);
      final encryptedBytes = base64Decode(encryptedText);
      final decryptedBytes = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      return utf8.decode(decryptedBytes);
    } catch (e) {
      return encryptedText;
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<String>(AppConstants.productsBox);
    await Hive.openBox<String>(AppConstants.salesBox);
    await Hive.openBox<String>(AppConstants.categoriesBox);
    await Hive.openBox<String>(AppConstants.settingsBox);
    await Hive.openBox<String>(AppConstants.pendingSalesBox);
  }

  // ==================== SharedPreferences ====================

  Future<bool> setString(String key, String value) async =>
      await _prefs?.setString(key, value) ?? false;

  String? getString(String key) => _prefs?.getString(key);

  Future<bool> setSecureString(String key, String value) async {
    final encrypted = _encrypt(value);
    return await _prefs?.setString('secure_$key', encrypted) ?? false;
  }

  String? getSecureString(String key) {
    final encrypted = _prefs?.getString('secure_$key');
    if (encrypted == null) return null;
    return _decrypt(encrypted);
  }

  Future<bool> setInt(String key, int value) async =>
      await _prefs?.setInt(key, value) ?? false;

  int? getInt(String key) => _prefs?.getInt(key);

  Future<bool> setBool(String key, bool value) async =>
      await _prefs?.setBool(key, value) ?? false;

  bool? getBool(String key) => _prefs?.getBool(key);

  Future<bool> setDouble(String key, double value) async =>
      await _prefs?.setDouble(key, value) ?? false;

  double? getDouble(String key) => _prefs?.getDouble(key);

  Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs?.setStringList(key, value) ?? false;

  List<String>? getStringList(String key) => _prefs?.getStringList(key);

  Future<bool> setJson(String key, Map<String, dynamic> value) async =>
      await setString(key, jsonEncode(value));

  Map<String, dynamic>? getJson(String key) {
    final value = getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<bool> setSecureJson(String key, Map<String, dynamic> value) async =>
      await setSecureString(key, jsonEncode(value));

  Map<String, dynamic>? getSecureJson(String key) {
    final value = getSecureString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<bool> remove(String key) async => await _prefs?.remove(key) ?? false;
  Future<bool> clear() async => await _prefs?.clear() ?? false;
  bool containsKey(String key) => _prefs?.containsKey(key) ?? false;

  // ==================== Hive ====================

  Box<String>? _getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) return null;
    return Hive.box<String>(boxName);
  }

  Future<void> hiveSet(String boxName, String key, dynamic value) async {
    final box = _getBox(boxName);
    if (box != null) {
      await box.put(key, jsonEncode(value));
    }
  }

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
      return null;
    }
  }

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
        // Skip invalid entries
      }
    }
    return results;
  }

  Future<void> hiveDelete(String boxName, String key) async {
    final box = _getBox(boxName);
    await box?.delete(key);
  }

  Future<void> hiveClear(String boxName) async {
    final box = _getBox(boxName);
    await box?.clear();
  }

  int hiveCount(String boxName) => _getBox(boxName)?.length ?? 0;

  // ==================== Cache ====================

  Future<void> setWithExpiry(String key, dynamic value, Duration expiry) async {
    final data = {
      'value': value,
      'expiry': DateTime.now().add(expiry).toIso8601String(),
    };
    await setJson(key, data);
  }

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

  // ==================== Session ====================

  Future<void> saveSession({
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    final sessionData = {
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await setSecureJson('session_data', sessionData);
    await setString(AppConstants.userIdKey, userId);
    await setString(AppConstants.userNameKey, userName);
    await setString(AppConstants.userRoleKey, userRole);
  }

  Map<String, String?> getSession() {
    final secureSession = getSecureJson('session_data');
    if (secureSession != null) {
      return {
        'userId': secureSession['userId'] as String?,
        'userName': secureSession['userName'] as String?,
        'userRole': secureSession['userRole'] as String?,
      };
    }
    return {
      'userId': getString(AppConstants.userIdKey),
      'userName': getString(AppConstants.userNameKey),
      'userRole': getString(AppConstants.userRoleKey),
    };
  }

  Future<void> clearSession() async {
    await remove('secure_session_data');
    await remove(AppConstants.userIdKey);
    await remove(AppConstants.userNameKey);
    await remove(AppConstants.userRoleKey);
  }

  bool hasSession() =>
      containsKey(AppConstants.userIdKey) || containsKey('secure_session_data');

  bool isSessionValid() {
    final secureSession = getSecureJson('session_data');
    if (secureSession == null) return false;
    final timestamp = DateTime.tryParse(
      secureSession['timestamp'] as String? ?? '',
    );
    if (timestamp == null) return false;
    const maxAge = Duration(days: 30);
    return DateTime.now().difference(timestamp) < maxAge;
  }

  Future<void> dispose() async {
    await Hive.close();
  }
}
