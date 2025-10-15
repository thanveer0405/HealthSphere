import 'dart:async';
import 'dart:math';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:firebase_dart/implementation/testing.dart';

/// Standalone Firebase Realtime Database updater
/// Run this file using:
/// dart run lib/update_devices.dart

Future<void> main() async {
  // ✅ Initialize the default Firebase implementations (required for non-Flutter)
  FirebaseDart.setup();

  const firebaseConfig = FirebaseOptions(
    apiKey: 'AIzaSyAYV10cK2UK7IRXAjx1C4Wra9QFqJk2K5A',
    appId: '1:900335431865:android:a92f94a6617c12ca57eb68',
    messagingSenderId: '900335431865',
    projectId: 'health-sphere-55222',
    databaseURL:
        'https://health-sphere-55222-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'health-sphere-55222.firebasestorage.app',
  );

  // Initialize Firebase app
  final app = await Firebase.initializeApp(options: firebaseConfig);
  final db = FirebaseDatabase(app: app).reference().child("devices");

  print("🔥 Starting device data updater...");

  // Periodic update
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    try {
      await _updateDevices(db);
    } catch (e) {
      print("❌ Error updating devices: $e");
    }
  });
}

Future<void> _updateDevices(DatabaseReference dbRef) async {
  final random = Random();

  // Simulated device IDs
  final devices = ["ESP32_001", "ESP32_002", "ESP32_003"];

  for (final id in devices) {
    final data = {
      "temperature": 30 + random.nextInt(5) * 2,
      "heartRate": 60 + random.nextInt(40),
      "spo2": 95 + random.nextInt(5),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    await dbRef.child(id).update(data);
    print("✅ Updated $id → $data");
  }
}
