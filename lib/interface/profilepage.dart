// lib/interface/profilepage.dart

import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/services/user_data.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';
import 'package:flawless_beauty_app/interface/settings_page.dart';
import 'package:flawless_beauty_app/screens/aicamera_page.dart ';
import 'package:flawless_beauty_app/interface/analytics_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── Colour tokens (mirror HomePage) ────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  int _currentIndex = 2; // profile tab

  // Controllers pre-filled from shared model
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final u = UserData.instance;
    _nameCtrl     = TextEditingController(text: u.name);
    _usernameCtrl = TextEditingController(text: u.username);
    _addressCtrl  = TextEditingController(text: u.address);
    _contactCtrl  = TextEditingController(text: u.contact);
    _emailCtrl    = TextEditingController(text: u.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    UserData.instance.update(
      name:     _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      address:  _addressCtrl.text.trim(),
      contact:  _contactCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Profile saved!"),
        backgroundColor: _orchidDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _discard() => Navigator.pop(context);

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            _fadeRoute(const HomePage()));
        break;
      case 1:
        Navigator.push(context,
            _fadeRoute(const AICameraPage()));
        break;
      case 4:
        Navigator.push(context,
            _fadeRoute(const SettingsPage()));
        break;
        case 3:
        Navigator.push(context,
            _fadeRoute(const AnalyticsPage()));
        break;

    }
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
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile card ────────────────────────────────────────
                    _buildProfileCard(),
                    const SizedBox(height: 28),

                    // ── Section label ────────────────────────────────────────
                    _sectionLabel("Personal Information"),
                    const SizedBox(height: 14),

                    _buildField(
                      controller: _nameCtrl,
                      label: "Full Name",
                      hint: "Enter your name",
                      icon: Icons.person_outline_rounded,
                    ),
                    _buildField(
                      controller: _usernameCtrl,
                      label: "Username",
                      hint: "@username",
                      icon: Icons.alternate_email_rounded,
                    ),

                    const SizedBox(height: 8),
                    _sectionLabel("Contact Details"),
                    const SizedBox(height: 14),

                    _buildField(
                      controller: _addressCtrl,
                      label: "Address",
                      hint: "Your address",
                      icon: Icons.location_on_outlined,
                    ),
                    _buildField(
                      controller: _contactCtrl,
                      label: "Phone",
                      hint: "+63 9XX XXX XXXX",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildField(
                      controller: _emailCtrl,
                      label: "E-mail",
                      hint: "you@example.com",
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 28),

                    // ── Action buttons ───────────────────────────────────────
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top gradient header ──────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE96A85), _orchid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
          const Expanded(
            child: Text(
              "My Profile",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // edit icon placeholder for symmetry
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_outlined,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Profile avatar + name display card ──────────────────────────────────────
  Widget _buildProfileCard() {
    return Center(
      child: Column(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_rose, _orchid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _orchid.withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: CircleAvatar(
                radius: 54,
                backgroundImage: AssetImage(
                    UserData.instance.avatarAsset ?? "assets/images/profile.webp"),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Displayed name (live from controller)
          ListenableBuilder(
            listenable: UserData.instance,
            builder: (_, __) => Column(
              children: [
                Text(
                  UserData.instance.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  UserData.instance.username,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Change photo chip
          GestureDetector(
            onTap: () {
              // TODO: image picker
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: _orchid.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _orchid.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 15, color: _orchidDark),
                  SizedBox(width: 6),
                  Text(
                    "Change Photo",
                    style: TextStyle(
                      fontSize: 12,
                      color: _orchidDark,
                      fontWeight: FontWeight.w600,
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

  // ── Section label ────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _textMuted,
        letterSpacing: 0.8,
      ),
    );
  }

  // ── Styled text field ─────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 13, color: _textMuted),
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: _textMuted.withOpacity(0.5)),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _orchid.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: _orchidDark),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _orchid, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 14),
          ),
        ),
      ),
    );
  }

  // ── Save / Discard buttons ───────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Save
        Expanded(
          child: GestureDetector(
            onTap: _save,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_rose, _orchid],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _orchid.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Discard
        GestureDetector(
          onTap: _discard,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text(
              "Discard",
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom nav (same as HomePage) ───────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _roseDark.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(icon: Icons.home_rounded,           index: 0),
              _navItem(icon: Icons.auto_awesome_rounded,   index: 1),
              _navLogo(),
              _navItem(icon: Icons.analytics_rounded,  index: 3),
              _navItem(icon: Icons.settings_rounded,         index: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required int index}) {
    final bool active = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _orchid.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 24, color: active ? _orchidDark : _textMuted),
      ),
    );
  }

  Widget _navLogo() {
    return GestureDetector(
      onTap: () => _onNavTap(2),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [_rose, _orchid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _orchid.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: ClipOval(
          child: Image.asset("assets/images/logo.png", fit: BoxFit.cover),
        ),
      ),
    );
  }
}