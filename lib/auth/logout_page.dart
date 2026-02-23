import 'package:flutter/material.dart';

/// Call this as a bottom sheet or push as a route.
/// Example as a bottom sheet:
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => const LogOutSheet(),
/// );
class LogOutPage extends StatelessWidget {
  const LogOutPage({super.key});

  static const LinearGradient _gradient = LinearGradient(
    colors: [Color(0xFFF48FB1), Color(0xFFF06292)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(gradient: _gradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                      ),
                    ),
                    const Expanded(
                      child: Text('Log Out',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),

                  // Illustration
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFF48FB1).withOpacity(0.15), const Color(0xFFF06292).withOpacity(0.08)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFFF48FB1).withOpacity(0.25), const Color(0xFFF06292).withOpacity(0.2)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout_rounded, size: 60, color: Color(0xFFF06292)),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Log Out of Your Account?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF212121)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You will be signed out of your account on this device. You can always sign back in anytime.',
                    style: TextStyle(color: Color(0xFF757575), fontSize: 15, height: 1.5),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Account preview card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.pink.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFF48FB1).withOpacity(0.2),
                          child: const Icon(Icons.person, color: Color(0xFFF06292), size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jane Doe', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            Text('jane.doe@email.com',
                                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Active',
                              style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF48FB1), Color(0xFFF06292)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF06292).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _handleLogOut(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Yes, Log Me Out',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF06292), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Stay Signed In',
                          style: TextStyle(color: Color(0xFFF06292), fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogOut(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: Color(0xFFF06292)),
            SizedBox(height: 16),
            Text('Signing out...', style: TextStyle(color: Color(0xFF757575))),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close dialog
      // TODO: Navigate to your Login / Splash screen
      // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have been logged out.'),
          backgroundColor: Color(0xFFF06292),
        ),
      );
      Navigator.pop(context);
    });
  }
}