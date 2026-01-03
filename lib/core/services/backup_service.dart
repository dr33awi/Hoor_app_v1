import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import '../config/app_config.dart';
import '../database/database.dart';

/// خدمة النسخ الاحتياطي والاستعادة
class BackupService {
  final AppDatabase _database;

  BackupService(this._database);

  /// إنشاء نسخة احتياطية
  Future<File> createBackup() async {
    final dbFile = await _database.exportDatabase();
    final backupDir = await _getBackupDirectory();

    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final backupFileName = 'hoor_backup_$timestamp.db';
    final backupFile = File(p.join(backupDir.path, backupFileName));

    await dbFile.copy(backupFile.path);

    return backupFile;
  }

  /// استعادة من نسخة احتياطية
  Future<bool> restoreBackup(File backupFile) async {
    try {
      final dbFile = await _database.exportDatabase();

      // إغلاق قاعدة البيانات قبل الاستعادة
      await _database.close();

      // نسخ ملف النسخة الاحتياطية
      await backupFile.copy(dbFile.path);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// مشاركة النسخة الاحتياطية
  Future<void> shareBackup(File backupFile) async {
    await Share.shareXFiles(
      [XFile(backupFile.path)],
      subject: 'Hoor Manager Backup',
      text: 'نسخة احتياطية من تطبيق Hoor Manager',
    );
  }

  /// الحصول على قائمة النسخ الاحتياطية
  Future<List<BackupInfo>> getBackupsList() async {
    final backupDir = await _getBackupDirectory();
    final files = backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.db'))
        .toList();

    final backups = <BackupInfo>[];
    for (final file in files) {
      final stat = await file.stat();
      backups.add(BackupInfo(
        file: file,
        name: p.basename(file.path),
        createdAt: stat.modified,
        size: stat.size,
      ));
    }

    // ترتيب حسب التاريخ (الأحدث أولاً)
    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return backups;
  }

  /// الحصول على آخر نسخة احتياطية
  Future<BackupInfo?> getLastBackup() async {
    final backups = await getBackupsList();
    return backups.isNotEmpty ? backups.first : null;
  }

  /// حذف نسخة احتياطية
  Future<bool> deleteBackup(File backupFile) async {
    try {
      await backupFile.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على مجلد النسخ الاحتياطية
  Future<Directory> _getBackupDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(docsDir.path, AppConfig.backupFolder));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }
}

/// معلومات النسخة الاحتياطية
class BackupInfo {
  final File file;
  final String name;
  final DateTime createdAt;
  final int size;

  BackupInfo({
    required this.file,
    required this.name,
    required this.createdAt,
    required this.size,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
