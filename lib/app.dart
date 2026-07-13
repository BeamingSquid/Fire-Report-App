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
    const accentColor = Color(0xFF1a237e);
    return MaterialApp(
      title: 'Fire Report App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: accentColor,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a237e),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor, width: 2)),
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1a1a2e),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1a1a2e),
          surfaceTintColor: Color(0xFF1a1a2e),
        ),
        dividerColor: Colors.white24,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: accentColor,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a237e),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor, width: 2)),
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1a1a2e),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1a1a2e),
          surfaceTintColor: Color(0xFF1a1a2e),
        ),
        dividerColor: Colors.white24,
      ),
      themeMode: ThemeMode.dark,
      home: const ReportListScreen(),
    );
  }
}
