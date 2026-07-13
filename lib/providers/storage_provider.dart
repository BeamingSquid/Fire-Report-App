import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return StorageService.getInstance();
});
