import 'package:demo/MonitorPage.dart';
import 'package:demo/PatientViewPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    listenDeviceData();
  }
  void listenDeviceData() {
    final dbRef = FirebaseDatabase.instance.ref("devices");

    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return;

      data.forEach((deviceId, deviceData) {
        final hr = deviceData['heartRate'] ?? 0;
        final spo2 = deviceData['spo2'] ?? 100;
        final temp = deviceData['temperature'] ?? 36.5;
        if (hr > 90 || spo2 < 95 || temp > 38) {
          _showLocalNotification(
            title: "Health Alert",
            body:
                "$deviceId: HR=$hr, SpO₂=$spo2%, Temp=${temp.toStringAsFixed(1)}°C",
          );
        }
      });
    });
  }
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'alert_channel',
      'Health Alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(0, title, body, details);
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('authBox');
    final uid = box.get('uid');
    final role = box.get('role');

    Widget startPage;
    if (uid != null && role == 'doctor') {
      startPage = DoctorPage();
    } else if (uid != null && role == 'patient') {
      startPage = PatientPage();
    } else {
      startPage = const LoginPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorSchemeSeed: Colors.teal,
      ),
      home: startPage,
    );
  }
}
