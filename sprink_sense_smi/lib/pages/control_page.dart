// lib/pages/control_page.dart
import 'package:flutter/material.dart';
import 'package:sprink_sense_smi/pages/database_service.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({Key? key}) : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final DatabaseService _db = DatabaseService();

  bool _pumpState = false;
  bool _isManualMode = false;
  int _threshold = 30;

  @override
  void initState() {
    super.initState();
    _db.getControlStream().listen((event) {
      if (event.snapshot.value == null) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        _pumpState = (data['pumpState'] == 1);
        _isManualMode = (data['mode'] == "manual");
        _threshold = (data['threshold'] as num?)?.toInt() ?? _threshold;
      });
    });
  }

  Future<void> _showThresholdEditor() async {
    final controller = TextEditingController(text: _threshold.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Soil Moisture Threshold"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: "%"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text("Save"),
          ),
        ],
      ),
    );
    if (result != null) {
      await _db.setThreshold(result);
      setState(() => _threshold = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Control"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Pump Control", style: TextStyle(fontSize: 18)),
                Switch(
                  value: _pumpState,
                  onChanged: _isManualMode
                      ? (val) => _db.updatePumpState(val)
                      : null, // disabled unless in manual mode
                ),
              ],
            ),
            if (!_isManualMode)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "Switch to Manual mode on Home to control the pump directly.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.water_drop),
                title: const Text("Soil Moisture Threshold"),
                subtitle: Text("Irrigate automatically below $_threshold%"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showThresholdEditor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}