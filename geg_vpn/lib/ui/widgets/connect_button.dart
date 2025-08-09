import 'package:flutter/material.dart';

class ConnectButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onPressed;
  const ConnectButton({super.key, required this.isConnected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFF8A2BE2), Color(0xFF9B59B6)]),
          boxShadow: [
            BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 24, spreadRadius: 8),
          ],
        ),
        child: Center(
          child: Icon(
            isConnected ? Icons.check_rounded : Icons.power_settings_new,
            color: Colors.white,
            size: 64,
          ),
        ),
      ),
    );
  }
}