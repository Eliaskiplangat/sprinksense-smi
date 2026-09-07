// lib/pages/database_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  static const String _firebaseUrl =
      'https://eliassprinksens-default-rtdb.europe-west1.firebasedatabase.app/';

  final DatabaseReference _sensorRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: _firebaseUrl,
  ).ref("Arduino-Data");

  final DatabaseReference _controlRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: _firebaseUrl,
  ).ref("Control");

  final DatabaseReference _activityRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: _firebaseUrl,
  ).ref("Activity");

  // ---- Sensor data ----
  Stream<DatabaseEvent> getSensorDataStream() => _sensorRef.onValue;

  // ---- Control node (pump state, mode, schedule, threshold) ----
  Stream<DatabaseEvent> getControlStream() => _controlRef.onValue;

  Future<void> updatePumpState(bool isOn) async {
    final value = isOn ? 1 : 0;
    // Keep both nodes in sync, same as HomePage does today.
    await _sensorRef.update({'pumpState': value});
    await _controlRef.update({'pumpState': value});
    await _logActivity(isOn ? "Pump turned ON" : "Pump turned OFF");
  }

  Future<void> setMode(String mode) async {
    await _controlRef.update({'mode': mode});
    await _logActivity(
        mode == "manual" ? "Switched to Manual mode" : "Switched to Automatic mode");
  }

  Future<void> setThreshold(int soilMoisturePercent) async {
    await _controlRef.update({'threshold': soilMoisturePercent});
  }

  Future<void> setSchedule(String scheduleText) async {
    await _controlRef.update({'schedule': scheduleText});
  }

  // ---- Activity log ----
  Stream<DatabaseEvent> getActivityStream() =>
      _activityRef.orderByKey().limitToLast(50).onValue;

  Future<void> _logActivity(String message) async {
    final entry = _activityRef.push();
    await entry.set({
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}