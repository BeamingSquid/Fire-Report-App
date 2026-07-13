import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/report.dart';

class PdfService {
  final _fieldCoords = <String, PtRect>{
    // HEADER (y=0-73): logos left, title center, date/ID right
    'incidentId':   PtRect(420, 44, 135, 14),
    'date':         PtRect(420, 60, 135, 12),

    // ROW 1 (y=105-186): 2 columns — Address + Additional Responders
    'address':      PtRect(23, 130, 250, 55),
    'addResponders':PtRect(298, 130, 272, 55),

    // ROW 2 (y=198-280): 3 columns — Start/OnScene/End Times
    'startTime':    PtRect(23, 223, 172, 55),
    'onSceneTime':  PtRect(212, 223, 172, 55),
    'endTime':      PtRect(401, 223, 170, 55),

    // BOTTOM LEFT (y=311-703): large description area
    'description':  PtRect(23, 315, 360, 385),

    // BOTTOM RIGHT (y=313-557): triage section
    'triageP1':     PtRect(405, 355, 160, 30),
    'triageP2':     PtRect(405, 392, 160, 30),
    'triageP3':     PtRect(405, 429, 160, 30),
    'triageP4':     PtRect(405, 466, 160, 30),

    // BOTTOM RIGHT (y=570-703): victim count
    'victimCount':  PtRect(402, 595, 168, 105),
  };

  Future<Uint8List> generatePdf(Report report, {required Uint8List templateImage}) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(pw.MemoryImage(templateImage), fit: pw.BoxFit.fill),
              ),
              ..._buildTextFields(report),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  List<pw.Widget> _buildTextFields(Report report) {
    final fields = <pw.Widget>[];
    final fmt = DateFormat('EEEE, dd/MM/yyyy');

    void addField(String key, String value, {double fontSize = 9, bool bold = false, bool wordWrap = false}) {
      final rect = _fieldCoords[key];
      if (rect == null || value.isEmpty) return;
      fields.add(
        pw.Positioned(
          left: rect.x,
          top: rect.y,
          child: pw.SizedBox(
            width: rect.w,
            height: rect.h,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              maxLines: wordWrap ? null : 1,
            ),
          ),
        ),
      );
    }

    // Header info (auto-filled)
    addField('incidentId', report.incidentId, fontSize: 10, bold: true);
    addField('date', fmt.format(report.date), fontSize: 8);

    // Row 1
    addField('address', report.address, wordWrap: true);
    addField('addResponders', report.additionalResponders, wordWrap: true);

    // Row 2
    addField('startTime', report.startTime, fontSize: 11, bold: true);
    addField('onSceneTime', report.onSceneTime, fontSize: 11, bold: true);
    addField('endTime', report.endTime, fontSize: 11, bold: true);

    // Bottom left - Description
    addField('description', report.description, fontSize: 8, wordWrap: true);

    // Bottom right - Triage
    if (report.hasVictims) {
      addField('triageP1', '${report.triageP1}', fontSize: 10, bold: true);
      addField('triageP2', '${report.triageP2}', fontSize: 10, bold: true);
      addField('triageP3', '${report.triageP3}', fontSize: 10, bold: true);
      addField('triageP4', '${report.triageP4}', fontSize: 10, bold: true);
      addField('victimCount', report.victimCount, fontSize: 10, bold: true);
    }

    // Incident type overlay
    if (report.incidentType.isNotEmpty) {
      fields.add(
        pw.Positioned(
          left: 23,
          top: 293,
          child: pw.Container(
            width: 360,
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: pw.Text(
              report.incidentType,
              style: pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey700),
            ),
          ),
        ),
      );
    }

    return fields;
  }

  Future<String> savePdf(Uint8List data, String incidentId) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/IncidentReportApp/pdf/${incidentId.replaceAll('/', '_')}.pdf');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data);
    return file.path;
  }

  Future<void> sharePdf(Uint8List data, String incidentId) async {
    await Printing.sharePdf(
      bytes: data,
      filename: '${incidentId.replaceAll('/', '_')}.pdf',
    );
  }
}

class PtRect {
  final double x, y, w, h;
  const PtRect(this.x, this.y, this.w, this.h);
}
