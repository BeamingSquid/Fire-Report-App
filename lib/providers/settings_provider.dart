import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import 'storage_provider.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final storage = await _ref.read(storageServiceProvider.future);
      final settings = await storage.loadSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(AppSettings settings) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.saveSettings(settings);
    state = AsyncValue.data(settings);
  }
}
