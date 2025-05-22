import 'package:http/http.dart' as http;
import 'dart:convert';

class ZenohService {
  final String baseUrl;
  
  ZenohService({required this.baseUrl});
  
  Future<String> getCurrentAutonomyLevel() async {
    final String url = '$baseUrl/Vehicle/1/ADAS/ActiveAutonomyLevel';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonArray = json.decode(response.body);
      if (jsonArray.isNotEmpty && jsonArray[0] is Map<String, dynamic>) {
        final Map<String, dynamic> data = jsonArray[0];
        return data['value'] ?? 'N/A';
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
  
  Future<String> updateAutonomyLevel(String autonomyLevel) async {
    final String url = '$baseUrl/Vehicle/1/ADAS/ActiveAutonomyLevel';
    
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'text/plain'},
      body: autonomyLevel,
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
  
  Future<void> setThrottle(double value) async {
    final String url = '$baseUrl/Vehicle/1/Powertrain/ElectricMotor/Speed';
    
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'text/plain'},
      body: value.toStringAsFixed(2),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
  
  Future<void> setSteering(double value) async {
    final String url = '$baseUrl/Vehicle/1/Chassis/SteeringWheel/Angle';
    
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'text/plain'},
      body: value.toStringAsFixed(2),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
}