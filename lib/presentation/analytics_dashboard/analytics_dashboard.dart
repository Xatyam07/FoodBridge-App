import 'package:flutter/material.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        children: const [
          Card(child: Center(child: Text("🍲 120 Meals Saved"))),
          Card(child: Center(child: Text("🌍 80kg CO₂ Reduced"))),
          Card(child: Center(child: Text("💳 45 Credits Earned"))),
          Card(child: Center(child: Text("🤝 30 Donations"))),
        ],
      ),
    );
  }
}
