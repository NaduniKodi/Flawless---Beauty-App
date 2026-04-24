// lib/auth/logout_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flawless_beauty_app/services/scan_history.dart';
import 'package:flawless_beauty_app/services/makeup_history.dart';

// 👇 Replace with your actual login/splash page import
import 'package:flawless_beauty_app/auth/login_page.dart';

class LogOutPage extends StatefulWidget {
  const LogOutPage({super.key});

  @override
  State<LogOutPage> createState() => _LogOutPageState();
}

class _LogOutPageState extends State<LogOutPage> {
  // ── Colours ────────────────────────────────────────────────────────────────
  static const LinearGradient _gradient = LinearGradient(
    colors: [Color(0xFFF48FB1), Color(0xFFF06292)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isLoggingOut = false;

  // Pull real user info from Supabase auth — no more hardcoded "Jane Doe"
  String get _userEmail =>
      Supabase.instance.client.auth.currentUser?.email ?? 'No email';

  String get _userName {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    return meta?['full_name']?.toString() ??
        meta?['name']?.toString() ??
        _userEmail.split('@').first; // fallback: use part before @
  }

  // ── Sign-out logic ─────────────────────────────────────────────────────────
  Future<void> _handleLogOut() async {
    // Prevent double-taps
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    try {
      // 1. Clear in-memory history caches so the next user starts fresh
      ScanHistory.instance.clear();
      MakeupHistory.instance.clear();

      // 2. Sign out from Supabase (invalidates the session token)
      await Supabase.instance.client.auth.signOut();

      // 3. Navigate to login and remove every page from the stack
      //    so pressing Back doesn't return to a logged-in page
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false, // remove ALL routes behind
        );
      }
    } catch (e) {
      // If Supabase signOut throws (e.g. no network), still clear locally
      // and navigate — the session will expire on its own server-side.
      debugPrint('⚠️ Sign-out error: $e');
      ScanHistory.instance.clear();
      MakeupHistory.instance.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
    // Note: no setState after navigation — widget is gone from tree
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(gradient: _gradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        child: const Icon(Icons.chevron_left,
                            color: Colors.white, size: 22),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Log Out',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
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

                  // ── Icon ───────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        const Color(0xFFF48FB1).withOpacity(0.15),
                        const Color(0xFFF06292).withOpacity(0.08),
                      ]),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xFFF48FB1).withOpacity(0.25),
                          const Color(0xFFF06292).withOpacity(0.20),
                        ]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout_rounded,
                          size: 60, color: Color(0xFFF06292)),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Log Out of Your Account?',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You will be signed out on this device. '
                    'Your scans and data are safely saved to your account.',
                    style: TextStyle(
                        color: Color(0xFF757575), fontSize: 15, height: 1.5),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // ── Real user card ─────────────────────────────────────────
                  // Shows the actual signed-in user instead of hardcoded text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.pink.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              const Color(0xFFF48FB1).withOpacity(0.2),
                          child: Text(
                            // Show first letter of name as avatar
                            _userName.isNotEmpty
                                ? _userName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Color(0xFFF06292),
                                fontSize: 22,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _userEmail,
                                style: const TextStyle(
                                    color: Color(0xFFB0BEC5), fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Active',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Log Out button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _isLoggingOut
                            // Dim the button while logging out
                            ? const LinearGradient(
                                colors: [Color(0xFFD4A0B0), Color(0xFFCC9AAA)])
                            : const LinearGradient(
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
                        // Disable button while the sign-out is in progress
                        onPressed: _isLoggingOut ? null : _handleLogOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isLoggingOut
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Yes, Log Me Out',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Cancel button ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed:
                          _isLoggingOut ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFF06292), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Stay Signed In',
                        style: TextStyle(
                            color: Color(0xFFF06292),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
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
}