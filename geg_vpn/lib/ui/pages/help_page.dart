import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(title: Text('FAQs')),
          ListTile(title: Text('Q: How do I get free access?'), subtitle: Text('A: Watch a rewarded ad once per day to unlock 1 hour of access.')),
          ListTile(title: Text('Q: How do I subscribe?'), subtitle: Text('A: Go to the Plans tab and choose a plan.')),
          ListTile(title: Text('Q: How do I contact support?'), subtitle: Text('A: Use the Support link in Settings.')),
        ],
      ),
    );
  }
}