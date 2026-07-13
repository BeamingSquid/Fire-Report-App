import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/report.dart';
import '../models/settings.dart';

class StorageService {
  static StorageService? _instance;
  late final String _appDir;
  late final String _reportsDir;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    _appDir = p.join(appDocDir.path, 'IncidentReportApp');
    _reportsDir = p.join(_appDir, 'reports');
    await Directory(_reportsDir).create(recursive: true);
  }

  Future<List<Report>> loadReports() async {
    try {
      final dir = Directory(_reportsDir);
      if (!await dir.exists()) return [];
      final files = dir.listSync().whereType<File>().toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      final reports = <Report>[];
      for (final file in files) {
        try {
          final content = await file.readAsString();
          reports.add(Report.fromJsonString(content));
        } catch (_) {}
      }
      return reports;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReport(Report report) async {
    final path = p.join(_reportsDir, '${report.id}.json');
    final file = File(path);
    await file.writeAsString(report.toJsonString());
  }

  Future<void> deleteReport(String id) async {
    final path = p.join(_reportsDir, '$id.json');
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final path = p.join(_appDir, 'settings.json');
    final file = File(path);
    await file.writeAsString(jsonEncode(settings.toJson()));
  }

  Future<AppSettings> loadSettings() async {
    try {
      final path = p.join(_appDir, 'settings.json');
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        return AppSettings.fromJson(jsonDecode(content) as Map<String, dynamic>);
      }
    } catch (_) {}
    return const AppSettings();
  }

  Future<String> getImageDir() async {
    final dir = p.join(_appDir, 'images');
    await Directory(dir).create(recursive: true);
    return dir;
  }

  Future<String> saveImage(String sourcePath, String reportId) async {
    final imgDir = await getImageDir();
    final ext = p.extension(sourcePath);
    final name = '${reportId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final dest = p.join(imgDir, name);
    await File(sourcePath).copy(dest);
    return dest;
  }
}
