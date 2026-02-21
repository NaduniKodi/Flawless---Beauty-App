import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/services/user_data.dart';
import 'package:flawless_beauty_app/interface/profilepage.dart';
import 'package:flawless_beauty_app/interface/settings_page.dart';
import 'package:flawless_beauty_app/screens/aicamera_page.dart ';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _bannerController;
  late Animation<double> _bannerFade;

  // ── Colour tokens ────────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFBF6FD8);
  static const Color _orchidDark  = Color(0xFF9847BE);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _card        = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bannerFade = CurvedAnimation(parent: _bannerController, curve: Curves.easeOut);
    _bannerController.forward();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 1:
        Navigator.push(context,
            _fadeRoute(const AICameraPage()));
        break;
      case 2:
        Navigator.push(context,
            _fadeRoute(const SettingsPage()));
        break;
      case 4:
        Navigator.push(context,
            _slideRoute(const ProfilePage()));
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

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      extendBody: true,

      // ── Bottom nav ──────────────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildBanner(),
              const SizedBox(height: 28),
              _buildScanButton(),
              const SizedBox(height: 32),
              _buildSectionTitle("Browse Categories"),
              const SizedBox(height: 14),
              _buildCategoriesGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom nav bar ───────────────────────────────────────────────────────────
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
              _navItem(icon: Icons.home_rounded,        index: 0),
              _navItem(icon: Icons.auto_awesome_rounded, index: 1),
              _navLogo(),
              _navItem(icon: Icons.notifications_rounded, index: 3),
              _navItem(icon: Icons.person_rounded,       index: 4),
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
        child: Icon(
          icon,
          size: 24,
          color: active ? _orchidDark : _textMuted,
        ),
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
          child: Image.asset(
            "assets/images/logo.png",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: UserData.instance,
      builder: (_, __) {
        final user = UserData.instance;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good Day ✨",
                  style: TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _onNavTap(4),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _rose.withOpacity(0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _rose.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage(
                      user.avatarAsset ?? "assets/images/profile.webp"),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        style: const TextStyle(fontSize: 14, color: _textPrimary),
        decoration: InputDecoration(
          hintText: "Search products, tips…",
          hintStyle: TextStyle(fontSize: 14, color: _textMuted),
          prefixIcon: Icon(Icons.search_rounded, color: _textMuted, size: 20),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_rose, _orchid],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ── Sale banner ─────────────────────────────────────────────────────────────
  Widget _buildBanner() {
    return FadeTransition(
      opacity: _bannerFade,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE96A85), Color(0xFFD44E80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _rose.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "LIMITED OFFER",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Big Sale!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Up to 50% off on trending\nbeauty products",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Shop Now →",
                      style: TextStyle(
                        color: _roseDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                "assets/images/banner.webp",
                width: 100,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Scan button ─────────────────────────────────────────────────────────────
  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, _fadeRoute(const AICameraPage())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_orchid, _orchidDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _orchid.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.face_retouching_natural, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              "Start AI Face Scan",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section title ───────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          "See all",
          style: TextStyle(
            fontSize: 13,
            color: _orchidDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Categories grid ─────────────────────────────────────────────────────────
  static const _categories = [
    ("Make up",   "AI-guided looks for your skin tone",  "assets/images/makeup.webp"),
    ("Cosmetics", "Explore top-rated cosmetics",          "assets/images/cosmetics.jpg"),
    ("Face Yoga", "Tone & lift with daily routines",     "assets/images/faceyoga.jpg"),
    ("Skin Care", "Routines tailored to you",            "assets/images/skincare.jpg"),
    ("Products",  "Curated beauty essentials",           "assets/images/products.png"),
  ];

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, i) {
        final (title, sub, img) = _categories[i];
        return _CategoryCard(title: title, subtitle: sub, imgPath: img);
      },
    );
  }
}

// ── Category Card widget ─────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.imgPath,
  });

  final String title;
  final String subtitle;
  final String imgPath;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 130),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.asset(
                  widget.imgPath,
                  height: 112,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1224),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF9E8DA8),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}