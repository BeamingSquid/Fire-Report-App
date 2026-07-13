import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/report.dart';
import '../models/settings.dart';
import '../providers/report_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/incident_type_picker.dart';
import '../widgets/triage_table.dart';
import '../services/pdf_service.dart';

class _TimeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue incoming) {
    final digits = incoming.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return TextEditingValue.empty;
    final sb = StringBuffer();
    for (var i = 0; i < digits.length && i < 4; i++) {
      if (i == 2 && digits.length > 2) sb.write(':');
      sb.write(digits[i]);
    }
    final formatted = sb.toString();
    final cursor = formatted.length;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}

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
  late TextEditingController _injuryCountCtl;
  late TextEditingController _descriptionCtl;

  final _additionalResponders = <String>[];
  String _incidentType = '';
  bool _hasInjuries = false;
  int _triageP1 = 0;
  int _triageP2 = 0;
  int _triageP3 = 0;
  int _triageP4 = 0;
  List<String> _imagePaths = [];
  bool _saving = false;

  static const _responderOptions = [
    'NHW', 'SAPS', 'Matjhabeng Fire', 'HazQuip', 'EMS', '1Life911',
    'ER24', 'Netcare', 'KAD', 'SOG', 'Shepherd', 'ADT', 'LG', 'MJS', 'Defensor',
  ];

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
    _injuryCountCtl = TextEditingController(text: r?.victimCount ?? '');
    _descriptionCtl = TextEditingController(text: r?.description ?? '');
    _incidentType = r?.incidentType ?? '';
    _hasInjuries = r?.hasVictims ?? false;
    _triageP1 = r?.triageP1 ?? 0;
    _triageP2 = r?.triageP2 ?? 0;
    _triageP3 = r?.triageP3 ?? 0;
    _triageP4 = r?.triageP4 ?? 0;
    _imagePaths = r?.imagePaths ?? [];

    if (r?.additionalResponders != null && r!.additionalResponders.isNotEmpty) {
      for (final opt in _responderOptions) {
        if (r.additionalResponders.contains(opt)) {
          _additionalResponders.add(opt);
        }
      }
      if (r.additionalResponders.split(',').any((s) => !_responderOptions.contains(s.trim()))) {
        final extra = r.additionalResponders.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty && !_responderOptions.contains(e)).join(', ');
        if (extra.isNotEmpty && !_additionalResponders.contains('Other: $extra')) {
          _additionalResponders.add('Other: $extra');
        }
      }
    }
  }

  @override
  void dispose() {
    _startTimeCtl.dispose();
    _onSceneTimeCtl.dispose();
    _endTimeCtl.dispose();
    _startKmCtl.dispose();
    _endKmCtl.dispose();
    _addressCtl.dispose();
    _injuryCountCtl.dispose();
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

      final respondersStr = _additionalResponders
          .map((r) => r.startsWith('Other:') ? r.substring(6) : r)
          .join(', ');

      final formData = {
        'incidentType': _incidentType,
        'startTime': _startTimeCtl.text,
        'onSceneTime': _onSceneTimeCtl.text,
        'endTime': _endTimeCtl.text,
        'startKm': _startKmCtl.text,
        'endKm': _endKmCtl.text,
        'address': _addressCtl.text,
        'additionalResponders': respondersStr,
        'hasVictims': _hasInjuries,
        'victimCount': _injuryCountCtl.text,
        'triageP1': _triageP1,
        'triageP2': _triageP2,
        'triageP3': _triageP3,
        'triageP4': _triageP4,
        'description': _descriptionCtl.text,
        'imagePaths': _imagePaths,
      };

      Report report;
      if (widget.existingReport != null) {
        await notifier.updateReport(widget.existingReport!.id, formData);
        report = widget.existingReport!.copyWith(
          incidentType: _incidentType,
          startTime: _startTimeCtl.text,
          onSceneTime: _onSceneTimeCtl.text,
          endTime: _endTimeCtl.text,
          startKm: _startKmCtl.text,
          endKm: _endKmCtl.text,
          address: _addressCtl.text,
          additionalResponders: respondersStr,
          hasVictims: _hasInjuries,
          victimCount: _injuryCountCtl.text,
          triageP1: _triageP1,
          triageP2: _triageP2,
          triageP3: _triageP3,
          triageP4: _triageP4,
          description: _descriptionCtl.text,
          imagePaths: _imagePaths,
        );
      } else {
        report = await notifier.createReport(formData, settings);
      }

      if (!mounted) return;

      try {
        final templateData = await rootBundle.load('assets/template.png');
        final pdfService = PdfService();
        final pdfBytes = await pdfService.generatePdf(
          report,
          templateImage: templateData.buffer.asUint8List(),
        );
        final pdfPath = await pdfService.savePdf(pdfBytes, report.incidentId);
        await Share.shareXFiles(
          [XFile(pdfPath, mimeType: 'application/pdf')],
          text: 'Incident Report ${report.incidentId}',
        );
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report saved')),
      );
      Navigator.of(context).pop();
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
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
            _sectionHeader('Additional Responders'),
            _respondersPicker(),
            const SizedBox(height: 16),
            _sectionHeader('Incident Type'),
            IncidentTypePicker(
              selectedPath: _incidentType.isEmpty ? null : _incidentType,
              onSelected: (s) => setState(() => _incidentType = s),
            ),
            if (_incidentType.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionHeader('Injuries'),
              SwitchListTile(
                title: const Text('Injuries Present'),
                value: _hasInjuries,
                onChanged: (v) => setState(() => _hasInjuries = v),
              ),
              if (_hasInjuries) ...[
                _textField('Number of Injuries', _injuryCountCtl, narrow: true),
                const SizedBox(height: 8),
                const Text('Triage', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.broken_image, color: Colors.white54),
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

  Widget _respondersPicker() {
    final other = _additionalResponders.firstWhere(
      (r) => r.startsWith('Other:'),
      orElse: () => '',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: _responderOptions.map((opt) {
            final selected = _additionalResponders.contains(opt);
            return FilterChip(
              label: Text(opt, style: const TextStyle(fontSize: 13)),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _additionalResponders.add(opt);
                  } else {
                    _additionalResponders.remove(opt);
                  }
                });
              },
              selectedColor: const Color(0xFF1a237e),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
              side: BorderSide(color: selected ? const Color(0xFF1a237e) : Colors.white24),
            );
          }).toList(),
        ),
        if (other.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Chip(
              label: Text(other.substring(6), style: const TextStyle(fontSize: 13)),
              onDeleted: () => setState(() => _additionalResponders.remove(other)),
              backgroundColor: const Color(0xFF1a237e),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: ctl,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'HH:MM',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        inputFormatters: [_TimeFormatter()],
        keyboardType: TextInputType.datetime,
        style: const TextStyle(fontSize: 15),
      ),
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
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}
