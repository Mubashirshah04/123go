import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.shield, size: 72, color: Colors.green),
        SizedBox(height: 8),
        Text('GEG VPN', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}