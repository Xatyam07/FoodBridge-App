import 'package:flutter/material.dart';

class DonationHistory extends StatelessWidget {
  const DonationHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donation History"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // dummy data
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: Text("Donation #${index + 1}"),
              subtitle: const Text("Status: Completed"),
              trailing: const Text("₹500"),
            ),
          );
        },
      ),
    );
  }
}
