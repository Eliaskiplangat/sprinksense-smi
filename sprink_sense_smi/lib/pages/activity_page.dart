// lib/pages/activity_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sprink_sense_smi/pages/database_service.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final DatabaseService _db = DatabaseService();

  List<_ActivityEntry> _activity = [];
  final List<double> _moistureHistory = [];
  static const int _maxPoints = 30;

  @override
  void initState() {
    super.initState();
    _db.getActivityStream().listen((event) {
      if (event.snapshot.value == null) return;
      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      final entries = raw.entries.map((e) {
        final data = Map<String, dynamic>.from(e.value as Map);
        return _ActivityEntry(
          message: data['message'] ?? '',
          timestamp: DateTime.tryParse(data['timestamp'] ?? '') ??
              DateTime.now(),
        );
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      setState(() => _activity = entries);
    });

    _db.getSensorDataStream().listen((event) {
      if (event.snapshot.value == null) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final moisture = (data['soilMoisture'] as num?)?.toDouble();
      if (moisture == null) return;
      setState(() {
        _moistureHistory.add(moisture);
        if (_moistureHistory.length > _maxPoints) {
          _moistureHistory.removeAt(0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Soil Moisture Trend',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: _moistureHistory.length < 2
                  ? const Center(
                      child: Text(
                        "Collecting readings…",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (int i = 0; i < _moistureHistory.length; i++)
                                FlSpot(i.toDouble(), _moistureHistory[i]),
                            ],
                            isCurved: true,
                            color: Colors.teal,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.teal.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Trend resets when you leave this screen — see note below to persist it.",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text('Recent Activity',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _activity.isEmpty
                  ? const Center(
                      child: Text("No activity yet",
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _activity.length,
                      itemBuilder: (context, i) {
                        final entry = _activity[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.history,
                                color: Colors.teal),
                            title: Text(entry.message),
                            subtitle: Text(_formatTime(entry.timestamp)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    return "${t.day}/${t.month}/${t.year} ${t.hour}:${t.minute.toString().padLeft(2, '0')}";
  }
}

class _ActivityEntry {
  final String message;
  final DateTime timestamp;
  _ActivityEntry({required this.message, required this.timestamp});
}