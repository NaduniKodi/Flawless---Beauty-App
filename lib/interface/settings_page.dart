// lib/interface/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';
import 'package:flawless_beauty_app/interface/profilepage.dart';
import 'package:flawless_beauty_app/screens/aicamera_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ── Colour tokens ────────────────────────────────────────────────────────────
  static const Color _rose       = Color(0xFFE8708A);
  static const Color _roseDark   = Color(0xFFC2516B);
  static const Color _orchid     = Color(0xFFBF6FD8);
  static const Color _orchidDark = Color(0xFF9847BE);
  static const Color _surface    = Color(0xFFFDF7FA);
  static const Color _textPrimary= Color(0xFF1C1224);
  static const Color _textMuted  = Color(0xFF9E8DA8);

  int _currentIndex = 2; // Settings = logo tap (index 2)

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, _fadeRoute(const HomePage()));
        break;
      case 1:
        Navigator.push(context, _fadeRoute(const AICameraPage()));
        break;
      case 4:
        Navigator.push(context, _slideRoute(const ProfilePage()));
        break;
    }
  }

  PageRoute _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      );

  PageRoute _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );

  // ── Settings data ────────────────────────────────────────────────────────────
  static const _generalTiles = [
    (Icons.person_outline_rounded,      "Account Settings",      _orchid),
    (Icons.notifications_outlined,      "Notifications",         Color(0xFF58C4DC)),
    (Icons.people_alt_outlined,         "Interests",             Color(0xFF78C97A)),
  ];

  static const _legalTiles = [
    (Icons.description_outlined,        "Terms & Conditions",    Color(0xFFE8A25A)),
    (Icons.privacy_tip_outlined,        "Privacy Policy",        Color(0xFF9E8DA8)),
    (Icons.lock_outline_rounded,        "Security",              Color(0xFF5A8AE8)),
  ];

  static const _dangerTiles = [
    (Icons.delete_outline_rounded,      "Delete Account",        Color(0xFFE05A5A)),
    (Icons.logout_rounded,              "Log Out",               Color(0xFFE8708A)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                children: [
                  _sectionLabel("General"),
                  const SizedBox(height: 10),
                  _buildTileGroup(_generalTiles),
                  const SizedBox(height: 22),

                  _sectionLabel("Legal"),
                  const SizedBox(height: 10),
                  _buildTileGroup(_legalTiles),
                  const SizedBox(height: 22),

                  _sectionLabel("Account"),
                  const SizedBox(height: 10),
                  _buildTileGroup(_dangerTiles, isDanger: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gradient header ──────────────────────────────────────────────────────────
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
              "Settings",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Spacer for symmetry
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _textMuted,
          letterSpacing: 1.1,
        ),
      );

  // ── Tile group card ───────────────────────────────────────────────────────────
  Widget _buildTileGroup(
    List<(IconData, String, Color)> tiles, {
    bool isDanger = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final i = entry.key;
          final (icon, title, color) = entry.value;
          final isLast = i == tiles.length - 1;
          return _buildTile(icon, title, color, isLast: isLast, isDanger: isDanger);
        }).toList(),
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    Color color, {
    bool isLast = false,
    bool isDanger = false,
  }) {
    return _SettingsTile(
      icon: icon,
      title: title,
      color: color,
      isLast: isLast,
      isDanger: isDanger,
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────────────────────
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
              _navItem(icon: Icons.home_rounded,            index: 0),
              _navItem(icon: Icons.auto_awesome_rounded,    index: 1),
              _navLogo(),
              _navItem(icon: Icons.notifications_rounded,   index: 3),
              _navItem(icon: Icons.person_rounded,          index: 4),
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
    final bool active = _currentIndex == 2;
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
              color: _orchid.withOpacity(active ? 0.5 : 0.3),
              blurRadius: active ? 14 : 10,
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

// ── Individual animated tile ─────────────────────────────────────────────────
class _SettingsTile extends StatefulWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.isLast,
    required this.isDanger,
  });

  final IconData icon;
  final String title;
  final Color color;
  final bool isLast;
  final bool isDanger;

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _pressed ? widget.color.withOpacity(0.05) : Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, size: 19,
                      color: widget.isDanger ? widget.color : widget.color),
                ),
                title: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: widget.isDanger
                        ? widget.color
                        : const Color(0xFF1C1224),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: widget.isDanger
                      ? widget.color.withOpacity(0.6)
                      : const Color(0xFF9E8DA8),
                ),
              ),
            ),
            if (!widget.isLast)
              Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
                color: Colors.black.withOpacity(0.06),
              ),
          ],
        ),
      ),
    );
  }
}