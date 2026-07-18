import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/report.dart';

class PdfService {
  Future<Uint8List> generatePdf(Report report, {Uint8List? templateImage}) async {
    final doc = pw.Document();
    final fmt = DateFormat('EEEE, dd/MM/yyyy');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        build: (pw.Context context) {
          final sections = <pw.Widget>[];

          if (templateImage != null) {
            sections.add(
              pw.Image(pw.MemoryImage(templateImage), fit: pw.BoxFit.contain),
            );
            sections.add(pw.SizedBox(height: 12));
          }

          sections.addAll(_buildSections(report, fmt));
          return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: sections);
        },
      ),
    );

    return doc.save();
  }

  List<pw.Widget> _buildSections(Report report, DateFormat fmt) {
    return [
      // HEADER
      _headerRow('Incident ID', report.incidentId, fmt.format(report.date)),
      pw.SizedBox(height: 4),
      pw.Divider(thickness: 1),
      pw.SizedBox(height: 6),

      // INCIDENT TYPE
      _label('INCIDENT TYPE'),
      _value(report.incidentType),
      pw.SizedBox(height: 8),

      // TIMES
      _label('TIMES'),
      _row3('Start', report.startTime, 'On Scene', report.onSceneTime, 'End', report.endTime),
      pw.SizedBox(height: 8),

      // ADDRESS
      _label('ADDRESS'),
      _value(report.address),
      pw.SizedBox(height: 8),

      // ADDITIONAL RESPONDERS
      _label('ADDITIONAL RESPONDERS'),
      _value(report.additionalResponders),
      pw.SizedBox(height: 8),

      // VEHICLE
      _label('VEHICLE'),
      _value('${report.vehicleReg}  |  ${report.vehicleMake} ${report.vehicleModel}  |  ${report.vehicleColor}'),
      pw.SizedBox(height: 8),

      // RESPONDERS
      _label('RESPONDERS'),
      _row2(
        '${report.r1Name} ${report.r1Surname} (${report.r1CallSign})',
        '${report.r2Name} ${report.r2Surname} (${report.r2CallSign})',
      ),
      if (report.r1Quals.isNotEmpty) ...[
        pw.SizedBox(height: 2),
        _value(report.r1Quals, fontSize: 8),
      ],
      pw.SizedBox(height: 8),

      // ODOMETER
      _label('ODOMETER'),
      _value('Start: ${report.startKm}   |   End: ${report.endKm}'),
      pw.SizedBox(height: 8),

      // INJURIES / TRIAGE
      if (report.hasVictims) ...[
        _label('INJURIES'),
        _value('Count: ${report.victimCount}'),
        pw.SizedBox(height: 4),
        _row4('P1 (Red): ${report.triageP1}', 'P2 (Yellow): ${report.triageP2}',
              'P3 (Green): ${report.triageP3}', 'P4 (Blue): ${report.triageP4}'),
        pw.SizedBox(height: 8),
      ],

      // DESCRIPTION
      _label('DESCRIPTION'),
      if (report.description.isNotEmpty)
        _value(report.description, maxLines: 20)
      else
        _value('\u2014'),
    ];
  }

  pw.Widget _headerRow(String idLabel, String id, String date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(idLabel, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          pw.Text(id, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.Text(date, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }

  pw.Widget _label(String text) {
    return pw.Text(text, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold));
  }

  pw.Widget _value(String text, {double fontSize = 10, int maxLines = 1}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Text(text, style: pw.TextStyle(fontSize: fontSize), maxLines: maxLines, overflow: pw.TextOverflow.clip),
    );
  }

  pw.Widget _row2(String left, String right) {
    return pw.Row(children: [
      pw.Expanded(child: _value(left)),
      pw.SizedBox(width: 12),
      pw.Expanded(child: _value(right)),
    ]);
  }

  pw.Widget _row3(String l1, String v1, String l2, String v2, String l3, String v3) {
    return pw.Row(children: [
      pw.Expanded(child: _labeledValue(l1, v1)),
      pw.SizedBox(width: 8),
      pw.Expanded(child: _labeledValue(l2, v2)),
      pw.SizedBox(width: 8),
      pw.Expanded(child: _labeledValue(l3, v3)),
    ]);
  }

  pw.Widget _row4(String a, String b, String c, String d) {
    return pw.Row(children: [
      pw.Expanded(child: _value(a)),
      pw.SizedBox(width: 8),
      pw.Expanded(child: _value(b)),
      pw.SizedBox(width: 8),
      pw.Expanded(child: _value(c)),
      pw.SizedBox(width: 8),
      pw.Expanded(child: _value(d)),
    ]);
  }

  pw.Widget _labeledValue(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  Future<String> savePdf(Uint8List data, String incidentId) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/IncidentReportApp/pdf/${incidentId.replaceAll('/', '_')}.pdf');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data);
    return file.path;
  }
}
