import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';
import 'package:flawless_beauty_app/main.dart';
import 'package:flawless_beauty_app/screens/aicamera_page.dart';
import 'package:flawless_beauty_app/interface/profilepage.dart'; 


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
            icon: Icon(Icons.home, color: Color.fromARGB(255, 174, 92, 144)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, color: Color.fromARGB(255, 174, 92, 144)),
            label: 'AI Scan',
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
            icon: Icon(Icons.notifications, color: Color.fromARGB(255, 174, 92, 144)),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color.fromARGB(255, 174, 92, 144)),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // navigation logic 
          if (index == 2) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const SettingsPage(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          } 
           else if (index == 1) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AICameraPage(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
            } 
           else if (index == 0) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomePage(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
            
          } else if (index == 3) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ProfilePage(),
                transitionsBuilder: (_, anim, __, child) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
            );
          }
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
