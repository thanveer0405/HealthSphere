import 'package:demo/MonitorPage.dart';
import 'package:demo/PatientViewPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  String errorMsg = '';

  Future<void> loginUser() async {
    setState(() => loading = true);

    try {
      final auth = FirebaseAuth.instance;
      final userCred = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCred.user!.uid;
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!snapshot.exists) {
        setState(() {
          errorMsg = 'User record not found.';
          loading = false;
        });
        return;
      }

      final data = snapshot.data()!;
      final role = data['role'];
      final deviceId = data['deviceId'];

      final box = Hive.box('authBox');
      await box.put('uid', uid);
      await box.put('role', role);
      await box.put('deviceId', deviceId);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => role == 'doctor' ? DoctorPage() : PatientPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMsg = e.message ?? 'Login failed.');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            color: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.health_and_safety, size: 60, color: Colors.teal)
                      .animate().fadeIn(duration: 800.ms).scale(),
                  const SizedBox(height: 12),
                  const Text(
                    "Smart Health Monitor",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 30),
                  loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: loginUser,
                          icon: const Icon(Icons.login),
                          label: const Text("LOGIN"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                  if (errorMsg.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(errorMsg, style: const TextStyle(color: Colors.red)),
                  ]
                ],
              ),
            ),
          ).animate().slideY(begin: 0.4, duration: 600.ms).fadeIn(),
        ),
      ),
    );
  }
}
