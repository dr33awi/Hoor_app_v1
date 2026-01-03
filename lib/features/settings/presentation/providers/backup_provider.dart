import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/database/database.dart';

/// ملف نسخة احتياطية
class BackupFile {
  final String path;
  final String name;
  final DateTime date;
  final String size;

  BackupFile({
    required this.path,
    required this.name,
    required this.date,
    required this.size,
  });
}

/// حالة النسخ الاحتياطي
class BackupState {
  final bool isLoading;
  final DateTime? lastBackupDate;
  final String? lastBackupSize;
  final List<BackupFile> backups;
  final bool autoBackupEnabled;
  final String? autoBackupTime;
  final int keepBackupsCount;

  const BackupState({
    this.isLoading = false,
    this.lastBackupDate,
    this.lastBackupSize,
    this.backups = const [],
    this.autoBackupEnabled = false,
    this.autoBackupTime,
    this.keepBackupsCount = 7,
  });

  BackupState copyWith({
    bool? isLoading,
    DateTime? lastBackupDate,
    String? lastBackupSize,
    List<BackupFile>? backups,
    bool? autoBackupEnabled,
    String? autoBackupTime,
    int? keepBackupsCount,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      lastBackupSize: lastBackupSize ?? this.lastBackupSize,
      backups: backups ?? this.backups,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupTime: autoBackupTime ?? this.autoBackupTime,
      keepBackupsCount: keepBackupsCount ?? this.keepBackupsCount,
    );
  }
}

/// مدير النسخ الاحتياطي
class BackupNotifier extends StateNotifier<BackupState> {
  final AppDatabase _database;
  SharedPreferences? _prefs;

  BackupNotifier(this._database) : super(const BackupState()) {
    _loadBackups();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    final lastBackupStr = _prefs?.getString('lastBackupDate');
    final lastBackupDate =
        lastBackupStr != null ? DateTime.tryParse(lastBackupStr) : null;

    state = state.copyWith(
      lastBackupDate: lastBackupDate,
      lastBackupSize: _prefs?.getString('lastBackupSize'),
      autoBackupEnabled: _prefs?.getBool('autoBackupEnabled') ?? false,
      autoBackupTime: _prefs?.getString('autoBackupTime'),
      keepBackupsCount: _prefs?.getInt('keepBackupsCount') ?? 7,
    );
  }

  Future<void> _loadBackups() async {
    state = state.copyWith(isLoading: true);

    try {
      final dir = await _getBackupDirectory();
      final backupDir = Directory(dir);

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final files = await backupDir
          .list()
          .where((e) => e.path.endsWith('.hoor'))
          .toList();

      final backups = <BackupFile>[];

      for (final file in files) {
        final stat = await file.stat();
        final name = file.path.split(Platform.pathSeparator).last;

        // استخراج التاريخ من اسم الملف
        final dateStr =
            name.replaceAll('hoor_backup_', '').replaceAll('.hoor', '');
        final date = DateTime.tryParse(dateStr.replaceAll('_', 'T'));

        backups.add(BackupFile(
          path: file.path,
          name: name,
          date: date ?? stat.modified,
          size: _formatFileSize(stat.size),
        ));
      }

      // ترتيب حسب التاريخ (الأحدث أولاً)
      backups.sort((a, b) => b.date.compareTo(a.date));

      state = state.copyWith(
        backups: backups,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String?> createBackup() async {
    state = state.copyWith(isLoading: true);

    try {
      final dir = await _getBackupDirectory();
      final timestamp =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final backupPath =
          '$dir${Platform.pathSeparator}hoor_backup_$timestamp.hoor';

      // تصدير قاعدة البيانات
      await _exportDatabase(backupPath);

      // تحديث الحالة
      final file = File(backupPath);
      final stat = await file.stat();
      final size = _formatFileSize(stat.size);

      await _prefs?.setString(
          'lastBackupDate', DateTime.now().toIso8601String());
      await _prefs?.setString('lastBackupSize', size);

      await _loadBackups();

      // حذف النسخ القديمة إذا تجاوزت الحد
      await _cleanOldBackups();

      state = state.copyWith(
        lastBackupDate: DateTime.now(),
        lastBackupSize: size,
        isLoading: false,
      );

      return backupPath;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> restoreFromFile(String? path) async {
    if (path == null) return;

    state = state.copyWith(isLoading: true);

    try {
      await _importDatabase(path);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteBackup(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      await _loadBackups();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setAutoBackup(bool enabled) async {
    await _prefs?.setBool('autoBackupEnabled', enabled);
    state = state.copyWith(autoBackupEnabled: enabled);
  }

  Future<void> setAutoBackupTime(String time) async {
    await _prefs?.setString('autoBackupTime', time);
    state = state.copyWith(autoBackupTime: time);
  }

  Future<void> setKeepBackupsCount(int count) async {
    await _prefs?.setInt('keepBackupsCount', count);
    state = state.copyWith(keepBackupsCount: count);
    await _cleanOldBackups();
  }

  Future<void> _cleanOldBackups() async {
    if (state.backups.length > state.keepBackupsCount) {
      final toDelete = state.backups.sublist(state.keepBackupsCount);
      for (final backup in toDelete) {
        await deleteBackup(backup.path);
      }
    }
  }

  Future<String> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}${Platform.pathSeparator}hoor_backups';
  }

  Future<void> _exportDatabase(String path) async {
    // الحصول على ملف قاعدة البيانات
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile =
        File('${dbFolder.path}${Platform.pathSeparator}hoor_manager.db');

    if (await dbFile.exists()) {
      // إغلاق الاتصال مؤقتاً
      await _database.close();

      // نسخ الملف
      await dbFile.copy(path);

      // إعادة فتح الاتصال
      // سيتم إعادة الاتصال تلقائياً عند الاستخدام
    }
  }

  Future<void> _importDatabase(String path) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile =
        File('${dbFolder.path}${Platform.pathSeparator}hoor_manager.db');
    final backupFile = File(path);

    if (await backupFile.exists()) {
      // إغلاق الاتصال
      await _database.close();

      // حذف الملف القديم
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      // نسخ ملف النسخة الاحتياطية
      await backupFile.copy(dbFile.path);

      // إعادة تهيئة قاعدة البيانات
      // يجب إعادة تشغيل التطبيق
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// مزود النسخ الاحتياطي
final backupProvider =
    StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  final database = GetIt.instance<AppDatabase>();
  return BackupNotifier(database);
});
