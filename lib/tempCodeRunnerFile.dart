import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

void main() => runApp(PatientMonitoringApp());

class PatientMonitoringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient Monitoring',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String temperature = "--";
  String heartRate = "--";

  // ThingSpeak Channel Info
  final String channelID = "3093166";
  final String readAPIKey = "EI94PYHP4VP7OJSK";

  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch immediately
    // Auto-refresh every 15 seconds
    timer = Timer.periodic(Duration(seconds: 15), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final tempResponse = await http.get(Uri.parse(
          'https://api.thingspeak.com/channels/$channelID/fields/1/last.json?api_key=$readAPIKey'));
      final hrResponse = await http.get(Uri.parse(
          'https://api.thingspeak.com/channels/$channelID/fields/2/last.json?api_key=$readAPIKey'));

      if (tempResponse.statusCode == 200 && hrResponse.statusCode == 200) {
        final tempData = json.decode(tempResponse.body);
        final hrData = json.decode(hrResponse.body);

        setState(() {
          temperature = tempData['field1'] ?? "--";
          heartRate = hrData['field2'] ?? "--";
        });
      } else {
        print("Failed to fetch data from ThingSpeak");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patient Monitoring Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DashboardCard(
              title: "Temperature (°C)",
              value: temperature,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            DashboardCard(
              title: "Heart Rate (BPM)",
              value: heartRate,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  DashboardCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
