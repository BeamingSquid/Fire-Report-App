import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../models/incident_types.dart';
import '../models/settings.dart';
import '../services/sync_service.dart';
import 'storage_provider.dart';

final reportsProvider = StateNotifierProvider<ReportsNotifier, AsyncValue<List<Report>>>((ref) {
  return ReportsNotifier(ref);
});

final syncStatusProvider = StateProvider<bool>((ref) => false);

class ReportsNotifier extends StateNotifier<AsyncValue<List<Report>>> {
  final Ref _ref;

  ReportsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final storage = await _ref.read(storageServiceProvider.future);
      final reports = await storage.loadReports();
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> syncWithCloud() async {
    final sync = SyncService.instance;
    _ref.read(syncStatusProvider.notifier).state = true;
    try {
      await sync.syncAll();
      final remote = await sync.fetchRemoteReports();
      final storage = await _ref.read(storageServiceProvider.future);
      final local = await storage.loadReports();

      final localIds = local.map((r) => r.id).toSet();
      for (final r in remote) {
        if (!localIds.contains(r.id)) {
          await storage.saveReport(r);
        }
      }
      await _load();
    } finally {
      _ref.read(syncStatusProvider.notifier).state = false;
    }
  }

  Future<Report> createReport(Map<String, dynamic> formData, AppSettings settings) async {
    final storage = await _ref.read(storageServiceProvider.future);
    final uuid = const Uuid().v4();
    final now = DateTime.now();

    final incidentTypePath = formData['incidentType'] as String? ?? '';
    final prefix = incidentTypePath.isEmpty ? 'GEN' : IncidentTypeNode.getPrefix(incidentTypePath);

    final todayStr = DateFormat('ddMMyyyy').format(now);
    final todayCount = state.valueOrNull?.where((r) => r.incidentId.contains(todayStr)).length ?? 0;
    final counter = todayCount + 1;
    final incidentId = '$prefix/$todayStr/${counter.toString().padLeft(4, '0')}';

    final report = Report(
      id: uuid,
      incidentId: incidentId,
      incidentType: incidentTypePath,
      date: now,
      vehicleReg: formData['vehicleReg'] as String? ?? settings.vehicleReg,
      vehicleMake: formData['vehicleMake'] as String? ?? settings.vehicleMake,
      vehicleModel: formData['vehicleModel'] as String? ?? settings.vehicleModel,
      vehicleColor: formData['vehicleColor'] as String? ?? settings.vehicleColor,
      r1Name: formData['r1Name'] as String? ?? settings.r1Name,
      r1Surname: formData['r1Surname'] as String? ?? settings.r1Surname,
      r1CallSign: formData['r1CallSign'] as String? ?? settings.r1CallSign,
      r1Quals: formData['r1Quals'] as String? ?? settings.r1Quals,
      r2Name: formData['r2Name'] as String? ?? settings.r2Name,
      r2Surname: formData['r2Surname'] as String? ?? settings.r2Surname,
      r2CallSign: formData['r2CallSign'] as String? ?? settings.r2CallSign,
      startTime: formData['startTime'] as String? ?? '',
      onSceneTime: formData['onSceneTime'] as String? ?? '',
      endTime: formData['endTime'] as String? ?? '',
      startKm: formData['startKm'] as String? ?? '',
      endKm: formData['endKm'] as String? ?? '',
      address: formData['address'] as String? ?? '',
      additionalResponders: formData['additionalResponders'] as String? ?? '',
      hasVictims: formData['hasVictims'] as bool? ?? false,
      victimCount: formData['victimCount'] as String? ?? '',
      triageP1: formData['triageP1'] as int? ?? 0,
      triageP2: formData['triageP2'] as int? ?? 0,
      triageP3: formData['triageP3'] as int? ?? 0,
      triageP4: formData['triageP4'] as int? ?? 0,
      description: formData['description'] as String? ?? '',
      imagePaths: formData['imagePaths'] as List<String>? ?? [],
      createdAt: now,
      updatedAt: now,
    );

    await storage.saveReport(report);
    SyncService.instance.uploadReport(report);
    await refresh();
    return report;
  }

  Future<void> updateReport(String id, Map<String, dynamic> formData) async {
    final storage = await _ref.read(storageServiceProvider.future);
    final current = state.valueOrNull?.where((r) => r.id == id).firstOrNull;
    if (current == null) return;

    final updated = current.copyWith(
      startTime: formData['startTime'] as String?,
      onSceneTime: formData['onSceneTime'] as String?,
      endTime: formData['endTime'] as String?,
      startKm: formData['startKm'] as String?,
      endKm: formData['endKm'] as String?,
      address: formData['address'] as String?,
      additionalResponders: formData['additionalResponders'] as String?,
      hasVictims: formData['hasVictims'] as bool?,
      victimCount: formData['victimCount'] as String?,
      triageP1: formData['triageP1'] as int?,
      triageP2: formData['triageP2'] as int?,
      triageP3: formData['triageP3'] as int?,
      triageP4: formData['triageP4'] as int?,
      description: formData['description'] as String?,
      imagePaths: formData['imagePaths'] is List ? (formData['imagePaths'] as List).cast<String>() : null,
      updatedAt: DateTime.now(),
    );

    await storage.saveReport(updated);
    SyncService.instance.uploadReport(updated);
    await refresh();
  }

  Future<void> deleteReport(String id) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.deleteReport(id);
    SyncService.instance.deleteRemoteReport(id);
    await refresh();
  }

  Future<void> addImage(String reportId, String sourcePath) async {
    final storage = await _ref.read(storageServiceProvider.future);
    final path = await storage.saveImage(sourcePath, reportId);
    final report = state.valueOrNull?.where((r) => r.id == reportId).firstOrNull;
    if (report == null) return;
    final updated = report.copyWith(
      imagePaths: [...report.imagePaths, path],
      updatedAt: DateTime.now(),
    );
    await storage.saveReport(updated);
    await refresh();
  }
}
