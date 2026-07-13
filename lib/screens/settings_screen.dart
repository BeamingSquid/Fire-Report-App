import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _vehicleRegCtl;
  late TextEditingController _vehicleMakeCtl;
  late TextEditingController _vehicleModelCtl;
  late TextEditingController _vehicleColorCtl;
  late TextEditingController _r1NameCtl;
  late TextEditingController _r1SurnameCtl;
  late TextEditingController _r1CallSignCtl;
  late TextEditingController _r1QualsCtl;
  late TextEditingController _r2NameCtl;
  late TextEditingController _r2SurnameCtl;
  late TextEditingController _r2CallSignCtl;
  bool _loaded = false;

  @override
  void dispose() {
    _vehicleRegCtl.dispose();
    _vehicleMakeCtl.dispose();
    _vehicleModelCtl.dispose();
    _vehicleColorCtl.dispose();
    _r1NameCtl.dispose();
    _r1SurnameCtl.dispose();
    _r1CallSignCtl.dispose();
    _r1QualsCtl.dispose();
    _r2NameCtl.dispose();
    _r2SurnameCtl.dispose();
    _r2CallSignCtl.dispose();
    super.dispose();
  }

  void _initControllers(AppSettings s) {
    if (_loaded) return;
    _vehicleRegCtl = TextEditingController(text: s.vehicleReg);
    _vehicleMakeCtl = TextEditingController(text: s.vehicleMake);
    _vehicleModelCtl = TextEditingController(text: s.vehicleModel);
    _vehicleColorCtl = TextEditingController(text: s.vehicleColor);
    _r1NameCtl = TextEditingController(text: s.r1Name);
    _r1SurnameCtl = TextEditingController(text: s.r1Surname);
    _r1CallSignCtl = TextEditingController(text: s.r1CallSign);
    _r1QualsCtl = TextEditingController(text: s.r1Quals);
    _r2NameCtl = TextEditingController(text: s.r2Name);
    _r2SurnameCtl = TextEditingController(text: s.r2Surname);
    _r2CallSignCtl = TextEditingController(text: s.r2CallSign);
    _loaded = true;
  }

  Future<void> _save() async {
    final settings = AppSettings(
      vehicleReg: _vehicleRegCtl.text,
      vehicleMake: _vehicleMakeCtl.text,
      vehicleModel: _vehicleModelCtl.text,
      vehicleColor: _vehicleColorCtl.text,
      r1Name: _r1NameCtl.text,
      r1Surname: _r1SurnameCtl.text,
      r1CallSign: _r1CallSignCtl.text,
      r1Quals: _r1QualsCtl.text,
      r2Name: _r2NameCtl.text,
      r2Surname: _r2SurnameCtl.text,
      r2CallSign: _r2CallSignCtl.text,
    );
    await ref.read(settingsProvider.notifier).save(settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) {
          _initControllers(settings);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section('Vehicle', [
                _field('Registration', _vehicleRegCtl),
                _field('Make', _vehicleMakeCtl),
                _field('Model', _vehicleModelCtl),
                _field('Color', _vehicleColorCtl),
              ]),
              const SizedBox(height: 16),
              _section('Responder 1', [
                _field('Name', _r1NameCtl),
                _field('Surname', _r1SurnameCtl),
                _field('Call Sign', _r1CallSignCtl),
                _field('Qualifications', _r1QualsCtl, maxLines: 3),
              ]),
              const SizedBox(height: 16),
              _section('Responder 2', [
                _field('Name', _r2NameCtl),
                _field('Surname', _r2SurnameCtl),
                _field('Call Sign', _r2CallSignCtl),
              ]),
              const SizedBox(height: 32),
              Text(
                'These defaults are automatically filled into new reports.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: ctl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        maxLines: maxLines,
      ),
    );
  }
}
