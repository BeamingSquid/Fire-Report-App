import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/report.dart';

class SyncService {
  static SyncService? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;
  void Function()? onSyncChanged;

  SyncService._();

  static SyncService get instance {
    _instance ??= SyncService._();
    return _instance!;
  }

  Future<void> init() async {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        syncAll();
      }
    });
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  bool get isSyncing => _isSyncing;

  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    onSyncChanged?.call();

    try {
      await _uploadLocalReports();
      await _downloadRemoteReports();
    } finally {
      _isSyncing = false;
      onSyncChanged?.call();
    }
  }

  Future<void> uploadReport(Report report) async {
    try {
      final imageUrls = <String>[];
      for (final path in report.imagePaths) {
        final file = File(path);
        if (await file.exists()) {
          final ref = _storage.ref('images/${report.id}/${file.uri.pathSegments.last}');
          await ref.putFile(file);
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        }
      }

      await _firestore.collection('reports').doc(report.id).set({
        ...report.toJson(),
        'imageUrls': imageUrls,
        'synced': true,
        'syncTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _uploadLocalReports() async {
    await Future.delayed(Duration.zero);
  }

  Future<void> _downloadRemoteReports() async {}

  Future<List<Report>> fetchRemoteReports() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['imageUrls'] is List) {
          data['imagePaths'] = data['imageUrls'];
        }
        return Report.fromJson(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteRemoteReport(String id) async {
    try {
      await _firestore.collection('reports').doc(id).delete();
      await _storage.ref('images/$id').listAll().then((result) async {
        for (final item in result.items) {
          await item.delete();
        }
      });
    } catch (_) {}
  }
}
