import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sprink_sense_smi/components/constant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String firebaseUrl =
      'https://eliassprinksens-default-rtdb.europe-west1.firebasedatabase.app/';

  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: firebaseUrl,
  ).ref("Arduino-Data");

  final DatabaseReference _controlRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: firebaseUrl,
  ).ref("Control");

  double _temperature = 0.0;
  int _soilMoisture = 0;
  int _waterLevel = 0;
  bool _pumpState = false;
  bool _isManualMode = false;

  @override
  void initState() {
    super.initState();
    _listenToSensorData();
    _listenToControlData();
  }

  void _listenToSensorData() {
    _database.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        setState(() {
          _temperature = (data['temperature'] as num?)?.toDouble() ?? 0.0;
          _soilMoisture = (data['soilMoisture'] as num?)?.toInt() ?? 0;
          _waterLevel = (data['waterLevel'] as num?)?.toInt() ?? 0;
          _pumpState = (data['pumpState'] == 1);
        });
      }
    });
  }

  void _listenToControlData() {
    _controlRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        setState(() {
          _isManualMode = (data['mode'] == "manual");
        });
      }
    });
  }

  void _turnPumpOn() {
    // Update both Arduino-Data and Control pumpState
    _database.update({'pumpState': 1}).then((_) {
      _controlRef.update({'pumpState': 1}).then((_) {
        print("Pump turned ON in both Arduino-Data and Control");
      });
    });
    setState(() => _pumpState = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Pump turned ON!"), duration: Duration(seconds: 2)),
    );
  }

  void _turnPumpOff() {
    // Update both Arduino-Data and Control pumpState
    _database.update({'pumpState': 0}).then((_) {
      _controlRef.update({'pumpState': 0}).then((_) {
        print("Pump turned OFF in both Arduino-Data and Control");
      });
    });
    setState(() => _pumpState = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Pump turned OFF!"), duration: Duration(seconds: 2)),
    );
  }

  void _toggleMode() {
    String newMode = _isManualMode ? "automatic" : "manual";
    _controlRef.update({'mode': newMode}).then((_) {
      setState(() {
        _isManualMode = !_isManualMode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_isManualMode
                ? "Manual Mode Activated"
                : "Automatic Mode Activated")),
      );
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KTetxt,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Hello, Elias!',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const CircleAvatar(
              radius: 20,
              backgroundImage:
                  NetworkImage('https://via.placeholder.com/150/09f/fff.png'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 5),
            _buildSmartModeCard(),
            const SizedBox(height: 10),
            _buildSensorData(),
            const SizedBox(height: 20),
            _buildModeToggleButton(),
            const SizedBox(height: 10),
            _buildPumpButtons(),
            const SizedBox(height: 30),
            Text('Recent Activity',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(child: _buildRecentActivity()),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartModeCard() {
    return Card(
      color: Colors.grey.shade100,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Mode: ${_isManualMode ? "Manual" : "Automatic"}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isManualMode
                  ? 'Manual Mode\nControl the pump manually.'
                  : 'Smart Mode on\n"Irrigate every 15 mins continuously" unless pump is turned off.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorData() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sensor Readings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSensorCard(
                  Icons.thermostat, "$_temperature°C", "Temperature"),
              _buildSensorCard(
                  Icons.water_drop, "$_soilMoisture%", "Soil Moisture"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSensorCard(Icons.opacity, "$_waterLevel%", "Water Level"),
              _buildSensorCard(
                _pumpState ? Icons.check_circle : Icons.cancel,
                _pumpState ? "Pump ON" : "Pump OFF",
                "Pump Status",
                isPumpState: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(IconData icon, String value, String label,
      {bool isPumpState = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isPumpState
              ? (_pumpState ? Colors.green.shade50 : Colors.red.shade50)
              : Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 30,
                color: isPumpState
                    ? (_pumpState ? Colors.green : Colors.red)
                    : Colors.teal),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggleButton() {
    return ElevatedButton(
      onPressed: _toggleMode,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        _isManualMode ? "Switch to Automatic Mode" : "Switch to Manual Mode",
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildPumpButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isManualMode ? _turnPumpOff : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Kerror,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Pump OFF",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: KTetxt)),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _isManualMode ? _turnPumpOn : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: KAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Pump ON",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: KTetxt)),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return ListView(
      children: [
        _buildIrrigationCard(
            title: 'Garden Lawn',
            description: 'The garden was irrigated yesterday @ 5000hrs'),
        _buildIrrigationCard(
            title: 'Vegetable Patch',
            description: 'The garden was irrigated yesterday @ 5300hrs'),
      ],
    );
  }

  Widget _buildIrrigationCard(
      {required String title, required String description}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
          title: Text(title),
          subtitle: Text(description),
          leading: const Icon(Icons.water_drop, color: Colors.green)),
    );
  }
}
