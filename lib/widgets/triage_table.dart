import 'package:flutter/material.dart';

class TriageTable extends StatelessWidget {
  final int p1;
  final int p2;
  final int p3;
  final int p4;
  final ValueChanged<int> onP1Changed;
  final ValueChanged<int> onP2Changed;
  final ValueChanged<int> onP3Changed;
  final ValueChanged<int> onP4Changed;

  const TriageTable({
    super.key,
    required this.p1,
    required this.p2,
    required this.p3,
    required this.p4,
    required this.onP1Changed,
    required this.onP2Changed,
    required this.onP3Changed,
    required this.onP4Changed,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        _row(context, 'P1 - Red', p1, onP1Changed, Colors.red.shade100),
        _row(context, 'P2 - Yellow', p2, onP2Changed, Colors.yellow.shade100),
        _row(context, 'P3 - Green', p3, onP3Changed, Colors.green.shade100),
        _row(context, 'P4 - Blue', p4, onP4Changed, Colors.blue.shade100),
      ],
    );
  }

  TableRow _row(BuildContext context, String label, int value, ValueChanged<int> onChanged, Color bg) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: bg,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextFormField(
            initialValue: value > 0 ? value.toString() : '',
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            onChanged: (s) => onChanged(int.tryParse(s) ?? 0),
          ),
        ),
      ],
    );
  }
}
