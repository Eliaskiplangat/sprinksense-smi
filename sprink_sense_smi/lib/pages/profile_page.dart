// lib/pages/profile_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Information.
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/150'),
                ),
                title: const Text("John Doe"),
                subtitle: const Text("john.doe@example.com"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Edit profile logic.
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Account Settings.
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Account Settings"),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    // Navigate to account settings.
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Security & Support.
            Card(
              child: ListTile(
                leading: const Icon(Icons.security),
                title: const Text("Security & Support"),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    // Navigate to security/support options.
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sign-Out Button.
            ElevatedButton.icon(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
