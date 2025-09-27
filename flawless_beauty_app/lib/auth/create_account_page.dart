import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/auth/login_page.dart';
import 'package:flawless_beauty_app/main.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top pink header
            Container(
              height: 80,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8AFCB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: const Center(
                child: Text(
                  "",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Title
            const Text(
              "Create an account",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Enter your  email adress to sign up",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            // Email field with shadow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF8AFCB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Divider with "or"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("or"),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Google button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Colors.black12),
                ),
                icon: Image.asset(
                  "assets/images/google.png",
                  height: 50,
                  width: 50,
                ),
                label: const Text(
                  "Continue with Google",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 10),

            // Apple button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Colors.black12),
                ),
                icon: const Icon(Icons.apple, color: Colors.black, size: 24),
                label: const Text(
                  "Continue with Apple",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 20),

            // Terms & Privacy
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text.rich(
                TextSpan(
                  text: "By clicking continue, you agree to our ",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  children: [
                    TextSpan(
                      text: "Terms of Service",
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
