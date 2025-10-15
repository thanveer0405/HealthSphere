import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PatientDetailPage extends StatelessWidget {
  final String deviceId;
  const PatientDetailPage({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('devices/$deviceId');
    return Scaffold(
      appBar: AppBar(
        title: Text('Vitals - $deviceId'),
        backgroundColor: Colors.teal.shade600,
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(child: CircularProgressIndicator());
          }

          final data = Map<String, dynamic>.from(
            (snapshot.data! as DatabaseEvent).snapshot.value as Map,
          );

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade100, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                margin: EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Heart Rate: ${data['heartRate']} bpm',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('SpO₂: ${data['spo2']}%',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Temperature: ${data['temperature']}°C',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
