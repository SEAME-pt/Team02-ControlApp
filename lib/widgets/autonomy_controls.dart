import 'package:flutter/material.dart';

class AutonomyControls extends StatelessWidget {
  final String status;
  final String currentValue;
  final Function(String) onAutonomyLevelChanged;
  
  const AutonomyControls({
    super.key,
    required this.status,
    required this.currentValue,
    required this.onAutonomyLevelChanged,
  });
  
  Widget _buildControlButton(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => onAutonomyLevelChanged(value),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Autonomy Controls', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Status: $status'),
            SizedBox(height: 5),
            Text('Current Autonomy Level: $currentValue', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildControlButton('SAE_1 LKAS', 'SAE_1_LKAS')),
                SizedBox(width: 8),
                Expanded(child: _buildControlButton('SAE_1 ACC', 'SAE_1_ACC')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildControlButton('SAE_2', 'SAE_2')),
                SizedBox(width: 8),
                Expanded(child: _buildControlButton('SAE_3', 'SAE_3')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}