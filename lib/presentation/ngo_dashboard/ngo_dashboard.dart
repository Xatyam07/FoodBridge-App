import 'package:flutter/material.dart';

class NgoDashboard extends StatelessWidget {
  const NgoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NGO Dashboard"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Welcome to the NGO Dashboard 🎉",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Example card: Alerts management
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: const Text("Manage Alerts"),
              subtitle: const Text("View and respond to food alerts"),
              onTap: () {
                // TODO: Navigate to NGO Alerts screen
              },
            ),
          ),

          // Example card: Donation history
          Card(
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.green),
              title: const Text("Donation History"),
              subtitle: const Text("Track past donations & received food"),
              onTap: () {
                // TODO: Navigate to donation history
              },
            ),
          ),

          // Example card: Profile
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.orange),
              title: const Text("Profile"),
              subtitle: const Text("View and edit your NGO profile"),
              onTap: () {
                // TODO: Navigate to profile page
              },
            ),
          ),
        ],
      ),
    );
  }
}
