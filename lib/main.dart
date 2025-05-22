import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
//import 'package:flutter_joystick/flutter_joystick.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Controller App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ZenohRestPage(),
    );
  }
}

class ZenohRestPage extends StatefulWidget {
  @override
  State<ZenohRestPage> createState() => _ZenohRestPageState();
}

class _ZenohRestPageState extends State<ZenohRestPage> {
  String _status = 'Idle';
  String _currentValue = 'Unknown';

  // Zenoh router REST endpoint base URL.
  final String baseUrl = 'http://10.21.221.71:8000';
  
  // The key expression for the stored info
  final String keyExpr = 'Vehicle/1/ADAS/ActiveAutonomyLevel';

  Timer? _statusTimer;
  // double _throttle = 0.0;  // -100 to 100
  // double _steering = 90.0;  // 0 to 180

  @override
  void initState() {
    super.initState();
    // Fetch the current status when the widget initializes
    getCurrentStatus();

    _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      getCurrentStatus();
    });
  }

  @override
  void dispose() {
    // Cancel timer when widget is disposed
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> getCurrentStatus() async {
    setState(() {
      _status = 'Fetching current status...';
    });
    
    final String url = '$baseUrl/$keyExpr';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> jsonArray = json.decode(response.body);
        if (jsonArray.isNotEmpty && jsonArray[0] is Map<String, dynamic>) {
          final Map<String, dynamic> data = jsonArray[0];
          final String value = data['value'] ?? 'N/A';
          
          setState(() {
            _currentValue = value;
            _status = 'Current status retrieved successfully';
          });
        } else {
          setState(() {
            _status = 'Invalid response format';
          });
        }
      } else {
        setState(() {
          _status = 'Failed to get status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error fetching status: $e';
      });
    }
  }

  Future<void> updateZenohState(String autonomyLevel) async {
    setState(() {
      _status = 'Updating...';
    });
    
    final String url = '$baseUrl/$keyExpr';
    
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'text/plain', // Change if a different content type is needed.
        },
        body: autonomyLevel,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _status = 'Update successful: ${response.body}';
        });

        // Get the current status after successful update
        await getCurrentStatus();
      } else {
        setState(() {
          _status = 'Failed with status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

    Widget _buildControlButton(String label, String value) {
      return Container(
        width: 200, // fixed width
        margin: EdgeInsets.only(bottom: 10), // bottom margin for spacing
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => updateZenohState(value),
          child: Text(label),
        ),
      );
    }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text('Car Controller App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Status: $_status'),
              SizedBox(height: 10),
              Text('Current Autonomy Level: $_currentValue', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 20),
              _buildControlButton('SAE_1 LKAS', 'SAE_1_LKAS'),
              _buildControlButton('SAE_1 ACC', 'SAE_1_ACC'),
              _buildControlButton('SAE_2', 'SAE_2'),
              _buildControlButton('SAE_3', 'SAE_3'),
            ],
          ),
        ),
      ),
    );
  }
}
