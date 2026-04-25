// lib/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flawless_beauty_app/auth/create_account_page.dart';
import 'package:flawless_beauty_app/auth/error_handler.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _supabase     = Supabase.instance.client;

  bool _isLoading       = false;
  bool _obscurePassword = true;

  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Email sign-in ─────────────────────────────────────────────────────────────
  Future<void> _signInWithEmail() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _snack("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password);
      if (response.user != null) {
        _goHome();
      } else {
        _snack("Login failed. Please try again.");
      }
    } catch (e) {
      _snack(AuthErrorHandler.message(e));
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ── Google sign-in ────────────────────────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '545145256802-rsu335sc2o6ku7ah1vhc3ej62erf9ria.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken    = googleAuth.idToken;
      if (idToken == null) {
        _snack("Failed: No ID token");
        setState(() => _isLoading = false);
        return;
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken:  idToken,
      );
      if (response.user != null) {
        _goHome();
      } else {
        _snack("Google sign-in failed");
      }
    } catch (e) {
      _snack(AuthErrorHandler.message(e));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // ── Navigation ────────────────────────────────────────────────────────────────
  void _goHome() => Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
        (_) => false,
      );

  // ── Snackbar ──────────────────────────────────────────────────────────────────
  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(msg),
          backgroundColor: _orchidDark,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );

// ── Forgot password ───────────────────────────────────────────────────────────
    Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      _snack("Enter your email first");
      return;
    }

    try {
      await _supabase.auth.resetPasswordForEmail(email);

      _snack("Password reset link sent to your email 📩");
    } catch (e) {
      _snack(AuthErrorHandler.message(e));
    }
  }


  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildGradientHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Email ──────────────────────────────────────────────
                      _fieldLabel("Email Address"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller:   _emailCtrl,
                        hint:         "you@example.com",
                        icon:         Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      // ── Password ───────────────────────────────────────────
                      _fieldLabel("Password"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller:  _passwordCtrl,
                        hint:        "Your password",
                        icon:        Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _textMuted,
                            size:  18,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      // ── Forgot password ────────────────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:_forgotPassword, // TODO: forgot-password flow
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color:      _orchidDark,
                              fontSize:   13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Sign In button ─────────────────────────────────────
                      _buildPrimaryButton(
                        label:     "Sign In",
                        onTap:     _isLoading ? null : _signInWithEmail,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 24),

                      _buildDivider(),
                      const SizedBox(height: 20),

                      // ── Google button ──────────────────────────────────────
                      _buildGoogleButton(),
                      const SizedBox(height: 32),

                      // ── Sign up link ───────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                                fontSize: 14, color: _textMuted),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const CreateAccountPage(),
                                transitionsBuilder: (_, anim, __, child) =>
                                    FadeTransition(
                                        opacity: anim, child: child),
                              ),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize:   14,
                                fontWeight: FontWeight.w700,
                                color:      _rose,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gradient header ───────────────────────────────────────────────────────────
  Widget _buildGradientHeader() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE96A85), _orchid],
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Welcome Back ✨",
              style: TextStyle(
                fontSize:   26,
                fontWeight: FontWeight.w800,
                color:      Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Sign in to continue your beauty journey",
              style: TextStyle(
                  fontSize: 14, color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
      );

  // ── Field label ───────────────────────────────────────────────────────────────
  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize:   13,
          fontWeight: FontWeight.w700,
          color:      _textMuted,
          letterSpacing: 0.4,
        ),
      );

  // ── Text field ────────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String   hint,
    required IconData icon,
    TextInputType     keyboardType = TextInputType.text,
    bool              obscureText  = false,
    Widget?           suffix,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:  Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller:   controller,
          keyboardType: keyboardType,
          obscureText:  obscureText,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            hintText:  hint,
            hintStyle: TextStyle(
                fontSize: 14, color: _textMuted.withOpacity(0.6)),
            prefixIcon: Container(
              margin:  const EdgeInsets.all(12),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color:  _orchid.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: _orchidDark),
            ),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:   BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _orchid, width: 1.5),
            ),
            filled:         true,
            fillColor:      Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 14),
          ),
        ),
      );

  // ── Primary gradient button ───────────────────────────────────────────────────
  Widget _buildPrimaryButton({
    required String        label,
    required VoidCallback? onTap,
    bool                   isLoading = false,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE96A85), _orchid],
              begin:  Alignment.centerLeft,
              end:    Alignment.centerRight,
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
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width:  22,
                    height: 22,
                    child:  CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color:      Colors.white,
                      fontSize:   16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      );

  // ── Divider ───────────────────────────────────────────────────────────────────
  Widget _buildDivider() => Row(
        children: [
          Expanded(
              child: Divider(
                  color: _orchid.withOpacity(0.4), thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text("or",
                style: TextStyle(fontSize: 13, color: _textMuted)),
          ),
          Expanded(
              child: Divider(
                  color: _orchid.withOpacity(0.4), thickness: 1)),
        ],
      );

  // ── Google button ─────────────────────────────────────────────────────────────
  Widget _buildGoogleButton() => GestureDetector(
        onTap: _isLoading ? null : _signInWithGoogle,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: _orchid.withOpacity(0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color:  Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/google.png", height: 22),
              const SizedBox(width: 10),
              const Text(
                "Continue with Google",
                style: TextStyle(
                  fontSize:   15,
                  fontWeight: FontWeight.w600,
                  color:      _textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
}