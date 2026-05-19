// lib/interface/homepage.dart
import 'package:flawless_beauty_app/interface/analytics_page.dart';
import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/services/user_data.dart';
import 'package:flawless_beauty_app/interface/profilepage.dart';
import 'package:flawless_beauty_app/interface/settings_page.dart';
import 'package:flawless_beauty_app/screens/aicamera_page.dart';
import 'package:flawless_beauty_app/screens/makeup_page.dart';
import 'package:flawless_beauty_app/interface/cosmetics_page.dart';
import 'package:flawless_beauty_app/interface/skin_care_page.dart';
import 'package:flawless_beauty_app/interface/face_yoga.dart';
import 'package:flawless_beauty_app/interface/products_page.dart';
import 'package:flawless_beauty_app/interface/interests_page.dart';
import 'package:flawless_beauty_app/services/interest_data.dart';
import 'package:flawless_beauty_app/widgets/user_avatar.dart'; 
import 'package:flawless_beauty_app/services/skin_advisor.dart';
import 'package:flawless_beauty_app/interface/my_routine_page.dart';



// ── Colour tokens ─────────────────────────────────────────────────────────────
const Color _rose = Color(0xFFE8708A);
const Color _roseDark = Color(0xFFC2516B);
const Color _orchid = Color(0xFFF8AFCB);
const Color _orchidDark = Color.fromARGB(255, 255, 152, 191);
const Color _surface = Color(0xFFFDF7FA);
const Color _card = Color(0xFFFFFFFF);
const Color _textPrimary = Color(0xFF1C1224);
const Color _textMuted = Color(0xFF9E8DA8);

// ── All searchable items ──────────────────────────────────────────────────────
class _SearchItem {
  final String title;
  final String subtitle;
  final String tag; // filter category
  final String emoji;
  final Widget Function(BuildContext) navigate;

  const _SearchItem({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.emoji,
    required this.navigate,
  });
}

const _allItems = <_SearchItem>[
  _SearchItem(
    title: 'Make Up',
    subtitle: 'AI-guided looks for your skin tone',
    tag: 'Makeup',
    emoji: '💄',
    navigate: _toMakeup,
  ),
  _SearchItem(
    title: 'Cosmetics',
    subtitle: 'Explore top-rated cosmetics',
    tag: 'Cosmetics',
    emoji: '✨',
    navigate: _toCosmetics,
  ),
  _SearchItem(
    title: 'Face Yoga',
    subtitle: 'Tone & lift with daily routines',
    tag: 'Wellness',
    emoji: '🧘',
    navigate: _toFaceYoga,
  ),
  _SearchItem(
    title: 'Skin Care',
    subtitle: 'Routines tailored to you',
    tag: 'Skin Care',
    emoji: '🌿',
    navigate: _toSkinCare,
  ),
  _SearchItem(
    title: 'Products',
    subtitle: 'Curated beauty essentials',
    tag: 'Products',
    emoji: '🛍️',
    navigate: _toProducts,
  ),
  _SearchItem(
    title: 'AI Face Scan',
    subtitle: 'Analyse your skin with AI',
    tag: 'Skin Care',
    emoji: '🤖',
    navigate: _toCamera,
  ),
];

// Static navigate helpers (needed for const constructor)
Widget _toMakeup(BuildContext ctx) => const MakeupPage();
Widget _toCosmetics(BuildContext ctx) => const CosmeticsPage();
Widget _toFaceYoga(BuildContext ctx) => const FaceYogaPage();
Widget _toSkinCare(BuildContext ctx) => const SkinCarePage();
Widget _toProducts(BuildContext ctx) => const ProductsPage();
Widget _toCamera(BuildContext ctx) => const AICameraPage();

const _filterTags = [
  'All',
  'Makeup',
  'Skin Care',
  'Cosmetics',
  'Wellness',
  'Products',
];

// ── HomePage ──────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _bannerController;
  late Animation<double> _bannerFade;

  // ── Search state ──────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  String _activeFilter = 'All';
  bool _isSearching = false;

  List<_SearchItem> get _filtered {
    final q = _query.toLowerCase();
    return _allItems.where((item) {
      final matchesFilter = _activeFilter == 'All' || item.tag == _activeFilter;
      final matchesQuery =
          q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q) ||
          item.tag.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bannerFade = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOut,
    );
    _bannerController.forward();

    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text;
        _isSearching = _query.isNotEmpty;
      });
    });

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus && _query.isEmpty) {
        setState(() => _isSearching = false);
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _searchFocus.unfocus();
    setState(() {
      _query = '';
      _isSearching = false;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        activeFilter: _activeFilter,
        onSelect: (tag) {
          setState(() {
            _activeFilter = tag;
            _isSearching = _query.isNotEmpty || tag != 'All';
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── Nav ───────────────────────────────────────────────────────────────────
  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 1:
        Navigator.push(context, _fadeRoute(const AICameraPage()));
        break;
      case 2:
        Navigator.push(context, _fadeRoute(const ProfilePage()));
        break;
      case 3:
        Navigator.push(context, _fadeRoute(const AnalyticsPage()));
        break;
      case 4:
        Navigator.push(context, _slideRoute(const SettingsPage()));
        break;
    }
  }

  PageRoute _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) =>
        FadeTransition(opacity: a, child: child),
  );

  PageRoute _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );

  // ── Build ─────────────────────────────────────────────────────────────────
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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildSearchBar(),

              // ── Active filter chip row ──────────────────────────────────
              if (_activeFilter != 'All') ...[
                const SizedBox(height: 10),
                _buildActiveFilterRow(),
              ],

              // ── Search results overlay ──────────────────────────────────
              if (_isSearching) ...[
                const SizedBox(height: 14),
                _buildSearchResults(),
              ] else ...[
                
                /*_buildInterestsStrip(),
                const SizedBox(height: 24),
                _buildBanner(),*/
                const SizedBox(height: 20),
                 _buildInterestsStrip(),
                
                const SizedBox(height: 20),
                _buildBanner(),

                const SizedBox(height: 28),
                _buildScanButton(),
                
                const SizedBox(height: 30),
                _buildSectionTitle('Browse Categories'),
                
                const SizedBox(height: 12),
                _buildCategoriesGrid(),
                 const SizedBox(height: 12),

                 if (SkinAdvisor.hasSkinProfile) ...[
                  _buildDailyTipCard(),
                  const SizedBox(height: 14),
                ],

                _buildRoutineCTASection(),
                const SizedBox(height: 12),

              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
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
                  'Good Day ✨',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.name.isEmpty ? 'Beauty lover' : user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            // ✅ UserAvatar handles avatarFile → avatarUrl → asset fallback
            GestureDetector(
              onTap: () => _onNavTap(2),
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
                child: const UserAvatar(radius: 22), // ✅ fixed
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
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
        controller: _searchCtrl,
        focusNode: _searchFocus,
        style: const TextStyle(fontSize: 14, color: _textPrimary),
        decoration: InputDecoration(
          hintText: 'Search makeup, skin care, yoga…',
          hintStyle: TextStyle(fontSize: 14, color: _textMuted),
          prefixIcon: Icon(Icons.search_rounded, color: _textMuted, size: 20),
          // Clear button while typing, filter button otherwise
          suffixIcon: _query.isNotEmpty
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: const Icon(
                    Icons.close_rounded,
                    color: _textMuted,
                    size: 18,
                  ),
                )
              : GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_rose, _orchid]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ── Active filter badge ───────────────────────────────────────────────────
  Widget _buildActiveFilterRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_rose, _orchidDark]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _activeFilter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() {
                  _activeFilter = 'All';
                  _isSearching = _query.isNotEmpty;
                }),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${_filtered.length} result${_filtered.length != 1 ? 's' : ''}',
          style: TextStyle(fontSize: 12, color: _textMuted),
        ),
      ],
    );
  }

  // ── Search results list ───────────────────────────────────────────────────
  Widget _buildSearchResults() {
    if (_filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different term or clear the filter',
              style: TextStyle(fontSize: 13, color: _textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_filtered.length} result${_filtered.length != 1 ? 's' : ''}'
          '${_query.isNotEmpty ? ' for "$_query"' : ''}',
          style: TextStyle(fontSize: 12, color: _textMuted),
        ),
        const SizedBox(height: 10),
        ..._filtered.map(
          (item) => _SearchResultCard(
            item: item,
            query: _query,
            onTap: () {
              _clearSearch();
              Navigator.push(context, _fadeRoute(item.navigate(context)));
            },
          ),
        ),
      ],
    );
  }

  // ── Interests strip ───────────────────────────────────────────────────────
  Widget _buildInterestsStrip() {
    return ListenableBuilder(
      listenable: InterestData.instance,
      builder: (_, __) {
        final interests = InterestData.instance.selected.toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [_rose, _orchid],
                      ).createShader(b),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'My Interests',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    _slideRoute(const InterestsPage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_rose, _orchid],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Edit ✏️',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            interests.isEmpty
                ? _buildEmptyInterestsPrompt()
                : SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: interests.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => _InterestChip(label: interests[i]),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyInterestsPrompt() {
    return GestureDetector(
      onTap: () => Navigator.push(context, _slideRoute(const InterestsPage())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _orchid.withOpacity(0.5), width: 1.2),
        ),
        child: Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tell us what you love — tap to pick your beauty interests!',
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _orchidDark, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────────────────────
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIMITED OFFER',
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
                    'Big Sale!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Up to 50% off on trending\nbeauty products',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductsPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Shop Now →',

                        style: TextStyle(
                          color: _roseDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
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
                'assets/images/banner.webp',
                width: 200,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ── Scan button ───────────────────────────────────────────────────────────
  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context, _fadeRoute(const AICameraPage())),
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face_retouching_natural, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Start AI Face Scan',
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

  // ── Section title ─────────────────────────────────────────────────────────
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
        GestureDetector(
          onTap: _showFilterSheet,
          child: Text(
            'Filter',
            style: TextStyle(
              fontSize: 13,
              color: _orchidDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Categories grid ───────────────────────────────────────────────────────
  static const _categories = [
    (
      'Make up',
      'AI-guided looks for your skin tone',
      'assets/images/makeup.webp',
      'Makeup',
    ),
    (
      'Cosmetics',
      'Explore top-rated cosmetics',
      'assets/images/cosmetics.jpg',
      'Cosmetics',
    ),
    (
      'Face Yoga',
      'Tone & lift with daily routines',
      'assets/images/faceyoga.jpg',
      'Wellness',
    ),
    (
      'Skin Care',
      'Routines tailored to you',
      'assets/images/skincare.jpg',
      'Skin Care',
    ),
    (
      'Products',
      'Curated beauty essentials',
      'assets/images/products.png',
      'Products',
    ),
  ];

   Widget _buildCategoriesGrid() {
    final filtered = _activeFilter == 'All'
        ? _categories.toList()
        : _categories.where((c) => c.$4 == _activeFilter).toList();
 
    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No categories match "$_activeFilter"',
            style: const TextStyle(color: _textMuted, fontSize: 13),
          ),
        ),
      );
    }
 
        final rows = <Widget>[];
 
    for (int i = 0; i < filtered.length; i += 2) {
      final isLastOdd = i + 1 >= filtered.length;
 
      if (isLastOdd) {
        // Single card — natural height, no paired constraint needed
        rows.add(_buildCard(filtered[i]));
      } else {
        // Pair — IntrinsicHeight makes both cards match the taller one
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildCard(filtered[i])),
                const SizedBox(width: 14),
                Expanded(child: _buildCard(filtered[i + 1])),
              ],
            ),
          ),
        );
      }

 
      // Gap between rows, but NOT after the last row
      if (i + 2 < filtered.length) {
        rows.add(const SizedBox(height: 14));
      }
    }
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
 
  // Card height that matches the old childAspectRatio: 0.88 at full width.
  // Screen width ≈ 360 dp minus 2×20 padding = 320 dp.
  // Half width ≈ (320 - 14) / 2 ≈ 153 dp → height = 153 / 0.88 ≈ 174 dp.
  //static const double _gridCardHeight = 180;
 
  Widget _buildCard(
    (String, String, String, String) cat, {
    bool fullWidth = false,
  }) {
    final (title, sub, img, _) = cat;
    VoidCallback? onTap;
    switch (title) {
      case 'Make up':
        onTap = () => Navigator.push(context, _fadeRoute(const MakeupPage()));
      case 'Cosmetics':
        onTap = () => Navigator.push(context, _fadeRoute(const CosmeticsPage()));
      case 'Face Yoga':
        onTap = () => Navigator.push(context, _fadeRoute(const FaceYogaPage()));
      case 'Skin Care':
        onTap = () => Navigator.push(context, _fadeRoute(const SkinCarePage()));
      case 'Products':
        onTap = () => Navigator.push(context, _fadeRoute(const ProductsPage()));
    }
    return _CategoryCard(
      title: title,
      subtitle: sub,
      imgPath: img,
      onTap: onTap,
    );
  }


  
    // ── Personalised section (tip card + routine CTA) ─────────────────────────
    Widget _buildRoutineCTASection() {
    return ListenableBuilder(
      listenable: UserData.instance,
      builder: (_, __) {
        if (SkinAdvisor.hasSkinProfile) {
          return _buildRoutineCTA();
        }
        return _buildProfileNudge();
      },
    );
  }
 
  // ── Daily Tip Card ────────────────────────────────────────────────────────
  Widget _buildDailyTipCard() {
    final tip = SkinAdvisor.dailyTip;
 
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF8AFCB).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8708A).withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE96A85), Color(0xFFF8AFCB)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S SKIN TIP",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tip,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  // ── Routine CTA banner ────────────────────────────────────────────────────
  Widget _buildRoutineCTA() {
    final u        = UserData.instance;
    final skinType = u.skinType;
    final concerns = u.skinConcerns;
    final hour     = DateTime.now().hour;
    final isAM     = hour < 18;
    final label    = isAM ? '☀️  View Morning Routine' : '🌙  View Evening Routine';
 
    return GestureDetector(
      onTap: () => Navigator.push(context, _fadeRoute(const MyRoutinePage())),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAM
                ? [const Color(0xFFE96A85), const Color(0xFFF8AFCB)]
                : [const Color(0xFF7C4DBA), const Color(0xFFE96A85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8708A).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skin type + concerns badges
                  if (skinType.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _routineBadge(skinType),
                        ...concerns.take(2).map(_routineBadge),
                        if (concerns.length > 2)
                          _routineBadge('+${concerns.length - 2} more'),
                      ],
                    ),
                  if (skinType.isNotEmpty) const SizedBox(height: 10),
                  const Text(
                    'Your Personalised\nSkin Routine',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC2516B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(0xFFC2516B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Step count bubble
            Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isAM
                          ? '${SkinAdvisor.amRoutine.length}'
                          : '${SkinAdvisor.pmRoutine.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'steps',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _routineBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
 
  // ── Profile nudge (no skin data yet) ─────────────────────────────────────
  Widget _buildProfileNudge() {
    return GestureDetector(
      onTap: () => Navigator.push(context, _fadeRoute(const MyRoutinePage())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF8AFCB).withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE96A85), Color(0xFFF8AFCB)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.face_retouching_natural_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Your Personalised Routine',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Complete your beauty profile to unlock AM/PM routines, daily skin tips, and ingredient guides tailored to you.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: _orchidDark,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
 
  // ── Interest-ordered categories ───────────────────────────────────────────
  // Reorders the categories grid so the ones most relevant to
  // the user's interests appear first.
  List<(String, String, String, String)> _orderedCategories() {
    final preferredOrder = SkinAdvisor.prioritisedCategories;
 
    // Map label → tuple
    final catMap = {
      for (final c in _categories) c.$1: c,
    };
 
    // Also handle the slight label mismatch ('Make up' vs 'Make up')
    final result = <(String, String, String, String)>[];
 
    for (final name in preferredOrder) {
      // SkinAdvisor returns 'Make up', 'Skin Care', 'Face Yoga', 'Products', 'Cosmetics'
      final match = _categories.where((c) => c.$1 == name || c.$1 == 'Make up' && name == 'Make up').firstOrNull;
      if (match != null && !result.contains(match)) result.add(match);
    }
 
    // Append any not already added
    for (final c in _categories) {
      if (!result.contains(c)) result.add(c);
    }
 
    return result;
  }


  // ── Bottom nav ────────────────────────────────────────────────────────────
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
              _navItem(icon: Icons.home_rounded, index: 0),
              _navItem(icon: Icons.auto_awesome_rounded, index: 1),
              _navLogo(),
              _navItem(icon: Icons.analytics_rounded, index: 3),
              _navItem(icon: Icons.settings_rounded, index: 4),
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
          child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  SEARCH RESULT CARD                                                      ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _SearchResultCard extends StatelessWidget {
  final _SearchItem item;
  final String query;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.item,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _orchid.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji bubble
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _orchid.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: const TextStyle(fontSize: 12, color: _textMuted),
                  ),
                  const SizedBox(height: 5),
                  // Tag pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _rose.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.tag,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _rose,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: _textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  FILTER BOTTOM SHEET                                                     ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _FilterSheet extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onSelect;

  const _FilterSheet({required this.activeFilter, required this.onSelect});

  static const _icons = {
    'All': '✨',
    'Makeup': '💄',
    'Skin Care': '🌿',
    'Cosmetics': '🪞',
    'Wellness': '🧘',
    'Products': '🛍️',
  };

  static const _descriptions = {
    'All': 'Show everything',
    'Makeup': 'AR try-on & tutorials',
    'Skin Care': 'Routines & analysis',
    'Cosmetics': 'Top-rated products',
    'Wellness': 'Face yoga & lifestyle',
    'Products': 'Curated essentials',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _orchid.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Filter by Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _orchid.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: _textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _filterTags.map((tag) {
                final isActive = tag == activeFilter;
                return GestureDetector(
                  onTap: () => onSelect(tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [_rose, _orchidDark],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: isActive ? null : _card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? Colors.transparent
                            : _orchid.withOpacity(0.3),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isActive
                              ? _rose.withOpacity(0.25)
                              : Colors.black.withOpacity(0.03),
                          blurRadius: isActive ? 12 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          _icons[tag] ?? '✨',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? Colors.white : _textPrimary,
                                ),
                              ),
                              Text(
                                _descriptions[tag] ?? '',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isActive ? Colors.white70 : _textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isActive)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  INTEREST CHIP                                                           ║
// ╚══════════════════════════════════════════════════════════════════════════╝
const _interestIcons = <String, String>{
  'Oily': '🫧',
  'Dry': '🌵',
  'Combination': '🌓',
  'Sensitive': '🌸',
  'Normal': '✨',
  'Acne-Prone': '🔴',
  'Anti-Aging': '⏳',
  'Brightening': '☀️',
  'Hydration': '💧',
  'Pore Minimizing': '🔬',
  'Even Tone': '🌟',
  'Glow Up': '💫',
  'Natural': '🌿',
  'Glam': '💎',
  'Bold': '💋',
  'Minimal': '🪞',
  'Editorial': '🎭',
  'Night Out': '🌙',
  'Cruelty-Free': '🐰',
  'Vegan': '🌱',
  'K-Beauty': '🎀',
  'Drugstore': '🛍️',
  'Luxury': '👑',
  'DIY Beauty': '🧪',
  'AM Routine': '☀️',
  'PM Routine': '🌙',
  'Face Masking': '🧖',
  'Facial Massage': '💆',
  'SPF Obsessed': '☂️',
  'Face Yoga': '🧘',
  'Hair Care': '💆',
  'Nail Art': '💅',
  'Body Care': '🧴',
  'Fragrance': '🌸',
  'Brows': '🪮',
  'Lip Looks': '💄',
};

class _InterestChip extends StatelessWidget {
  const _InterestChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final icon = _interestIcons[label] ?? '✨';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _orchid.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _rose.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A3B52),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  CATEGORY CARD                                                           ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.imgPath,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String imgPath;
  final VoidCallback? onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
            border: widget.onTap != null
                ? Border.all(color: _orchid.withOpacity(0.35), width: 1.2)
                : null,
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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.asset(
                      widget.imgPath,
                      height: 112,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (widget.onTap != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_rose, _orchid],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Try Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                ],
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
