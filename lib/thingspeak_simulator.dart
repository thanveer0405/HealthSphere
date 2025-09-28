import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;

void sendFakeData(String writeApiKey) async {
  // Generate random health data
  double bodyTemp = double.parse((36 + Random().nextDouble() * 2).toStringAsFixed(1));
  double bloodPressure = 80 + Random().nextInt(40).toDouble();
  double oxygen = 95 + Random().nextInt(5).toDouble();
  double pulse = 60 + Random().nextInt(40).toDouble();

  final url = Uri.parse(
    "https://api.thingspeak.com/update?api_key=$writeApiKey&field1=$bodyTemp&field2=$bloodPressure&field3=$oxygen&field4=$pulse",
  );

  try {
    final response = await http.get(url);
    String timestamp = DateTime.now().toString();
    if (response.statusCode == 200) {
      print("$timestamp → Data sent successfully: bodyTemp=$bodyTemp, BP=$bloodPressure, O2=$oxygen, Pulse=$pulse");
    } else {
      print("$timestamp → Failed to send data: ${response.statusCode}");
    }
  } catch (e) {
    print("Error sending data: $e");
  }
}

void main() {
  final writeApiKey = "G5XE6KYHQU7DIQ0G";
  print("Starting ThingSpeak Health Data Simulator...");
  Timer.periodic(Duration(seconds: 15), (timer) {
    sendFakeData(writeApiKey);
  });
}
