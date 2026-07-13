import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/report.dart';
import '../providers/report_provider.dart';
import '../services/pdf_service.dart';
import 'report_form_screen.dart';

class ReportDetailScreen extends ConsumerWidget {
  final Report report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFmt = DateFormat('EEEE, dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(report.incidentId),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate PDF',
            onPressed: () => _generatePdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ReportFormScreen(existingReport: report)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteReport(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Incident Info', [
            _row('Incident ID', report.incidentId),
            _row('Date', dateFmt.format(report.date)),
            _row('Type', report.incidentType),
          ]),
          const SizedBox(height: 12),
          _section('Vehicle', [
            _row('Registration', report.vehicleReg),
            _row('Make', report.vehicleMake),
            _row('Model', report.vehicleModel),
            _row('Color', report.vehicleColor),
          ]),
          const SizedBox(height: 12),
          _section('Responders', [
            _row('Responder 1', '${report.r1Name} ${report.r1Surname} (${report.r1CallSign})'),
            _row('Qualifications', report.r1Quals),
            _row('Responder 2', '${report.r2Name} ${report.r2Surname} (${report.r2CallSign})'),
          ]),
          const SizedBox(height: 12),
          _section('Times', [
            _row('Start Time', report.startTime),
            _row('On Scene', report.onSceneTime),
            _row('End Time', report.endTime),
          ]),
          const SizedBox(height: 12),
          _section('Odometer', [
            _row('Start KM', report.startKm),
            _row('End KM', report.endKm),
          ]),
          const SizedBox(height: 12),
          _section('Emergency', [
            _row('Address', report.address),
            _row('Additional Responders', report.additionalResponders),
          ]),
          const SizedBox(height: 12),
          _section('Injuries', [
            _row('Injuries', report.hasVictims ? 'Yes' : 'No'),
            if (report.hasVictims) ...[
              _row('Count', report.victimCount),
              _row('P1 Red', '${report.triageP1}'),
              _row('P2 Yellow', '${report.triageP2}'),
              _row('P3 Green', '${report.triageP3}'),
              _row('P4 Blue', '${report.triageP4}'),
            ],
          ]),
          const SizedBox(height: 12),
          _section('Description', [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(report.description.isEmpty ? '\u2014' : report.description),
            ),
          ]),
          if (report.imagePaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            _section('Images', [
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: report.imagePaths.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(p),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120, height: 120,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ]),
          ],
        ],
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
            const Divider(color: Colors.white24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value.isEmpty ? '\u2014' : value)),
        ],
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    try {
      final templateData = await rootBundle.load('assets/template.png');
      final pdfService = PdfService();
      final pdfBytes = await pdfService.generatePdf(
        report,
        templateImage: templateData.buffer.asUint8List(),
      );
      final pdfPath = await pdfService.savePdf(pdfBytes, report.incidentId);

      if (!context.mounted) return;

      await Share.shareXFiles(
        [XFile(pdfPath, mimeType: 'application/pdf')],
        text: 'Incident Report ${report.incidentId}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteReport(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Delete ${report.incidentId}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(reportsProvider.notifier).deleteReport(report.id);
      Navigator.of(context).pop();
    }
  }
}
