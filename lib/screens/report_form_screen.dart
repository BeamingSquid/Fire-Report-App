import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/report.dart';
import '../models/settings.dart';
import '../providers/report_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/incident_type_picker.dart';
import '../widgets/triage_table.dart';

class ReportFormScreen extends ConsumerStatefulWidget {
  final Report? existingReport;

  const ReportFormScreen({super.key, this.existingReport});

  @override
  ConsumerState<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends ConsumerState<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _startTimeCtl;
  late TextEditingController _onSceneTimeCtl;
  late TextEditingController _endTimeCtl;
  late TextEditingController _startKmCtl;
  late TextEditingController _endKmCtl;
  late TextEditingController _addressCtl;
  late TextEditingController _addRespondersCtl;
  late TextEditingController _victimCountCtl;
  late TextEditingController _descriptionCtl;

  String _incidentType = '';
  bool _hasVictims = false;
  int _triageP1 = 0;
  int _triageP2 = 0;
  int _triageP3 = 0;
  int _triageP4 = 0;
  List<String> _imagePaths = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReport;
    _startTimeCtl = TextEditingController(text: r?.startTime ?? '');
    _onSceneTimeCtl = TextEditingController(text: r?.onSceneTime ?? '');
    _endTimeCtl = TextEditingController(text: r?.endTime ?? '');
    _startKmCtl = TextEditingController(text: r?.startKm ?? '');
    _endKmCtl = TextEditingController(text: r?.endKm ?? '');
    _addressCtl = TextEditingController(text: r?.address ?? '');
    _addRespondersCtl = TextEditingController(text: r?.additionalResponders ?? '');
    _victimCountCtl = TextEditingController(text: r?.victimCount ?? '');
    _descriptionCtl = TextEditingController(text: r?.description ?? '');
    _incidentType = r?.incidentType ?? '';
    _hasVictims = r?.hasVictims ?? false;
    _triageP1 = r?.triageP1 ?? 0;
    _triageP2 = r?.triageP2 ?? 0;
    _triageP3 = r?.triageP3 ?? 0;
    _triageP4 = r?.triageP4 ?? 0;
    _imagePaths = r?.imagePaths ?? [];
  }

  @override
  void dispose() {
    _startTimeCtl.dispose();
    _onSceneTimeCtl.dispose();
    _endTimeCtl.dispose();
    _startKmCtl.dispose();
    _endKmCtl.dispose();
    _addressCtl.dispose();
    _addRespondersCtl.dispose();
    _victimCountCtl.dispose();
    _descriptionCtl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (xFile != null) {
      setState(() => _imagePaths.add(xFile.path));
    }
  }

  Future<void> _pickGalleryImage() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (xFile != null) {
      setState(() => _imagePaths.add(xFile.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final settings = ref.read(settingsProvider).valueOrNull ?? const AppSettings();
      final notifier = ref.read(reportsProvider.notifier);

      final formData = {
        'incidentType': _incidentType,
        'startTime': _startTimeCtl.text,
        'onSceneTime': _onSceneTimeCtl.text,
        'endTime': _endTimeCtl.text,
        'startKm': _startKmCtl.text,
        'endKm': _endKmCtl.text,
        'address': _addressCtl.text,
        'additionalResponders': _addRespondersCtl.text,
        'hasVictims': _hasVictims,
        'victimCount': _victimCountCtl.text,
        'triageP1': _triageP1,
        'triageP2': _triageP2,
        'triageP3': _triageP3,
        'triageP4': _triageP4,
        'description': _descriptionCtl.text,
        'imagePaths': _imagePaths,
      };

      if (widget.existingReport != null) {
        await notifier.updateReport(widget.existingReport!.id, formData);
      } else {
        await notifier.createReport(formData, settings);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report saved')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingReport != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Report' : 'New Report'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader('Times'),
            _row(
              _timeField('Start Time', _startTimeCtl),
              _timeField('On Scene', _onSceneTimeCtl),
              _timeField('End Time', _endTimeCtl),
            ),
            const SizedBox(height: 16),
            _sectionHeader('Odometer'),
            _row(
              _textField('Start KM', _startKmCtl, narrow: true),
              _textField('End KM', _endKmCtl, narrow: true),
            ),
            const SizedBox(height: 16),
            _sectionHeader('Emergency Details'),
            _textField('Address of Emergency', _addressCtl, maxLines: 2),
            const SizedBox(height: 8),
            _textField('Additional Responders', _addRespondersCtl),
            const SizedBox(height: 16),
            _sectionHeader('Incident Type'),
            IncidentTypePicker(
              selectedPath: _incidentType.isEmpty ? null : _incidentType,
              onSelected: (s) => setState(() => _incidentType = s),
            ),
            if (_incidentType.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionHeader('Victims'),
              SwitchListTile(
                title: const Text('Victims Present'),
                value: _hasVictims,
                onChanged: (v) => setState(() => _hasVictims = v),
              ),
              if (_hasVictims) ...[
                _textField('Number of Victims', _victimCountCtl, narrow: true),
                const SizedBox(height: 8),
                const Text('Triage', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                TriageTable(
                  p1: _triageP1,
                  p2: _triageP2,
                  p3: _triageP3,
                  p4: _triageP4,
                  onP1Changed: (v) => setState(() => _triageP1 = v),
                  onP2Changed: (v) => setState(() => _triageP2 = v),
                  onP3Changed: (v) => setState(() => _triageP3 = v),
                  onP4Changed: (v) => setState(() => _triageP4 = v),
                ),
              ],
            ],
            const SizedBox(height: 16),
            _sectionHeader('Incident Description'),
            _textField('Description', _descriptionCtl, maxLines: 5),
            const SizedBox(height: 16),
            _sectionHeader('Images'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._imagePaths.map((p) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(p),
                        width: 100, height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100, height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0, right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red, size: 24),
                        onPressed: () => setState(() => _imagePaths.remove(p)),
                      ),
                    ),
                  ],
                )),
                ActionChip(
                  avatar: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Camera'),
                  onPressed: _pickImage,
                ),
                ActionChip(
                  avatar: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery'),
                  onPressed: _pickGalleryImage,
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      )),
    );
  }

  Widget _row(Widget a, Widget b, [Widget? c]) {
    return Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 8),
        Expanded(child: b),
        if (c != null) ...[const SizedBox(width: 8), Expanded(child: c)],
      ],
    );
  }

  Widget _timeField(String label, TextEditingController ctl) {
    return TextFormField(
      controller: ctl,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'HH:MM',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d:]')),
        LengthLimitingTextInputFormatter(5),
      ],
      keyboardType: TextInputType.datetime,
    );
  }

  Widget _textField(String label, TextEditingController ctl, {bool narrow = false, int maxLines = 1}) {
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
        keyboardType: narrow ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}
