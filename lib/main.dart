import 'package:demo/MonitorPage.dart';
import 'package:demo/PatientViewPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
