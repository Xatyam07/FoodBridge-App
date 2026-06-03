import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  // Dummy data for now
  final String userName = "John Doe";
  final String userEmail = "johndoe@example.com";
  final String profilePic = "https://via.placeholder.com/150";

  const ProfilePage({super.key}); // ✅ cleaner const constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(profilePic),
            ),
            const SizedBox(height: 20),

            // User name
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Email
            Text(
              userEmail,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Edit button
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Edit Profile coming soon..."),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
