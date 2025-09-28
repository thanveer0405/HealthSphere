import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PatientMonitoringApp());
}

class PatientMonitoringApp extends StatelessWidget {
  const PatientMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient Monitoring',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MonitoringPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  double? temperature;
  double? heartRate;
  double? oxygen;
  bool isLoading = true;
  final String channelId = "3093166";
  final String readApiKey = "EI94PYHP4VP7OJSK";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final url =
        "https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$readApiKey&results=1";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final feeds = data["feeds"];
        if (feeds != null && feeds.isNotEmpty) {
          setState(() {
            temperature =
                double.tryParse(feeds[0]["field1"] ?? "0") ?? 0.0;
            heartRate =
                double.tryParse(feeds[0]["field2"] ?? "0") ?? 0.0;
            oxygen =
                double.tryParse(feeds[0]["field3"] ?? "0") ?? 0.0;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Monitoring Dashboard"),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildCard("Body Temperature", "$temperature °C",
                      Colors.red),
                  const SizedBox(height: 20),
                  buildCard("Heart Rate", "$heartRate BPM", Colors.green),
                  const SizedBox(height: 20),
                  buildCard("Oxygen", "$oxygen O2", Colors.green),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchData,
                    child: const Text("Refresh Data"),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildCard(String title, String value, Color color) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        leading: Icon(Icons.monitor_heart, color: color, size: 40),
        title: Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(value,
            style: TextStyle(
                fontSize: 22, color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
