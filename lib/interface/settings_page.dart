import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';
import 'package:flawless_beauty_app/main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Custom AppBar
      appBar: AppBar(
        backgroundColor: Color(0xFFF8AFCB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          buildSettingsTile(Icons.person_outline, "Account setting"),
          const SizedBox(height: 20),
          buildSettingsTile(Icons.notifications_none, "Notification"),
          const SizedBox(height: 20),
          buildSettingsTile(Icons.people_alt_outlined, "Interest"),
          const SizedBox(height: 20),
          buildSettingsTile(Icons.description_outlined, "Terms and conditions"),
          const SizedBox(height: 20),
          buildSettingsTile(Icons.privacy_tip_outlined, "Privacy policy"),
          const SizedBox(height: 20),
          buildSettingsTile(Icons.lock_outline, "Security"),
          const SizedBox(height: 20),
          buildSettingsTile(Icons.delete_outline, "Delete account"),
          const SizedBox(height: 20),
          buildSettingsTile(Icons.logout, "Log out"),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromARGB(255, 207, 140, 255),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage("assets/images/logo.png"),
              backgroundColor: Colors.transparent,
            ),
            label: 'Logo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, color: Colors.black),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation logic here
        },
      ),
    );
  }

  // Reusable tile widget
  Widget buildSettingsTile(IconData icon, String title) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(height: 1),
      ],
    );
  }
}
