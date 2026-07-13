import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../providers/report_provider.dart';
import 'report_form_screen.dart';
import 'report_detail_screen.dart';
import 'settings_screen.dart';

class ReportListScreen extends ConsumerStatefulWidget {
  const ReportListScreen({super.key});

  @override
  ConsumerState<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends ConsumerState<ReportListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider);
    final isSyncing = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Push Update',
            onPressed: isSyncing
                ? null
                : () => ref.read(reportsProvider.notifier).syncWithCloud(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.cloud_sync),
                tooltip: 'Sync with cloud',
                onPressed: isSyncing
                    ? null
                    : () => ref.read(reportsProvider.notifier).syncWithCloud(),
              ),
              if (isSyncing)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF1a1a2e),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: reportsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (reports) {
                final filtered = reports.where((r) =>
                    r.incidentId.toLowerCase().contains(_searchQuery) ||
                    r.incidentType.toLowerCase().contains(_searchQuery) ||
                    r.address.toLowerCase().contains(_searchQuery) ||
                    r.description.toLowerCase().contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 12),
                        Text(
                          reports.isEmpty
                              ? 'No reports yet. Tap + to create one.'
                              : 'No matching reports',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _reportCard(filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReportFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
      ),
    );
  }

  Widget _reportCard(Report report) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReportDetailScreen(report: report)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            report.incidentId,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        if (report.synced)
                          Icon(Icons.cloud_done, size: 16, color: Colors.green.shade400),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (report.incidentType.isNotEmpty)
                      Text(report.incidentType, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                    if (report.address.isNotEmpty)
                      Text(report.address, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    Text(dateFmt.format(report.createdAt), style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}
