import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Demo notifications — replace with real data later
          ...List.generate(
            6,
                (i) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.notifications),
                title: Text('Notification ${i + 1}'),
                subtitle: const Text('This is a demo notification.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // optionally navigate to details
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
