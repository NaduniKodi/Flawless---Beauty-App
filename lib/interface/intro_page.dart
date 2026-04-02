// lib/auth/intro_page.dart
import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/auth/login_page.dart';
import 'package:flawless_beauty_app/auth/create_account_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  // ── Colour tokens ────────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  late final AnimationController _ctrl;
  late final Animation<double>   _logoFade;
  late final Animation<Offset>   _logoSlide;
  late final Animation<double>   _textFade;
  late final Animation<double>   _btnFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 0.75, curve: Curves.easeOut)),
    );
    _btnFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.65, 1.0, curve: Curves.easeOut)),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  PageRoute _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          // ── Decorative blobs ─────────────────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _orchid.withOpacity(0.20),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _rose.withOpacity(0.10),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Animated logo ─────────────────────────────────────────
                  FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: Column(
                        children: [
                          // Glow ring + logo
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [_rose, _orchid],
                                begin: Alignment.topLeft,
                                end:   Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:  _orchid.withOpacity(0.50),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  "assets/images/logo.png",
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // App name
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: "Flawless ",
                                  style: TextStyle(
                                    fontSize:   32,
                                    fontWeight: FontWeight.w800,
                                    color:      _textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: "Beauty",
                                  style: TextStyle(
                                    fontSize:   32,
                                    fontWeight: FontWeight.w800,
                                    color:      _rose,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Tag line chips
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _chip("AI-Powered"),
                              const SizedBox(width: 8),
                              _chip("Personalised"),
                              const SizedBox(width: 8),
                              _chip("Skincare"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // ── Tagline text ──────────────────────────────────────────
                  FadeTransition(
                    opacity: _textFade,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color:  Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Feature rows
                          _featureRow(Icons.face_retouching_natural_rounded,
                              "AI Face Scan", "Analyse your skin in seconds"),
                          const Divider(height: 20, color: Color(0xFFF0E8EE)),
                          _featureRow(Icons.auto_awesome_rounded,
                              "Smart Suggestions", "Products matched to your skin"),
                          const Divider(height: 20, color: Color(0xFFF0E8EE)),
                          _featureRow(Icons.spa_outlined,
                              "Face Yoga & Routines", "Tone naturally, every day"),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Buttons ──────────────────────────────────────────────
                  FadeTransition(
                    opacity: _btnFade,
                    child: Column(
                      children: [
                        // Get Started → Create Account
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context, _fadeRoute(const CreateAccountPage())),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE96A85), _orchid],
                                begin: Alignment.centerLeft,
                                end:   Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color:  _rose.withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Text(
                                  "Get Started",
                                  style: TextStyle(
                                    fontSize:   16,
                                    fontWeight: FontWeight.w700,
                                    color:      Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Already have account → Login
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context, _fadeRoute(const LoginPage())),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: _orchid.withOpacity(0.5), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color:  Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              "I already have an account",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:   15,
                                fontWeight: FontWeight.w600,
                                color:      _roseDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _orchid.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _roseDark,
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String title, String sub) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_rose, _orchid]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
            const SizedBox(height: 1),
            Text(sub,
                style: const TextStyle(fontSize: 12, color: _textMuted)),
          ],
        ),
      ],
    );
  }
}