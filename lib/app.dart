import 'package:flutter/material.dart';
import 'services/sync_service.dart';
import 'screens/report_list_screen.dart';

class IncidentReportApp extends StatefulWidget {
  const IncidentReportApp({super.key});

  @override
  State<IncidentReportApp> createState() => _IncidentReportAppState();
}

class _IncidentReportAppState extends State<IncidentReportApp> {
  @override
  void initState() {
    super.initState();
    SyncService.instance.init();
  }

  @override
  void dispose() {
    SyncService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incident Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const ReportListScreen(),
    );
  }
}
