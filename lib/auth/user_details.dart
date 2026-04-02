// lib/auth/user_details.dart
import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/services/user_data.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage>
    with SingleTickerProviderStateMixin {
  // ── Colour tokens ────────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  // ── Controllers ──────────────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _ageCtrl  = TextEditingController();

  // ── Skin type options ────────────────────────────────────────────────────────
  static const List<_SkinOption> _skinTypes = [
    _SkinOption("Normal",      Icons.sentiment_satisfied_alt_rounded,  "Balanced, rarely breaks out"),
    _SkinOption("Oily",        Icons.water_drop_rounded,               "Shiny T-zone, enlarged pores"),
    _SkinOption("Dry",         Icons.wb_sunny_outlined,                "Tight feeling, occasional flakes"),
    _SkinOption("Combination", Icons.compare_arrows_rounded,           "Oily T-zone, dry cheeks"),
    _SkinOption("Sensitive",   Icons.favorite_border_rounded,          "Reacts easily, prone to redness"),
  ];

  String _selectedSkinType = "";

  // ── Skin concern chips ───────────────────────────────────────────────────────
  static const List<String> _concernOptions = [
    "Acne",
    "Dark Spots",
    "Wrinkles",
    "Redness",
    "Pores",
    "Dryness",
    "Oiliness",
    "Dark Circles",
    "Uneven Tone",
    "Dullness",
  ];

  final Set<String> _selectedConcerns = {};

  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────────
  void _submit() {
    final name = _nameCtrl.text.trim();
    final age  = int.tryParse(_ageCtrl.text.trim());

    if (name.isEmpty) {
      _snack("Please enter your name");
      return;
    }
    if (_selectedSkinType.isEmpty) {
      _snack("Please select your skin type");
      return;
    }

    setState(() => _isLoading = true);

    UserData.instance.updateDetails(
      name:         name,
      age:          age,
      skinType:     _selectedSkinType,
      skinConcerns: _selectedConcerns.toList(),
    );

    // Simulate a brief save delay for polish
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
        (_) => false,
      );
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _orchidDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildGradientHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Name ────────────────────────────────────────────────
                      _sectionLabel("Your Name"),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _nameCtrl,
                        hint:       "Full Name",
                        icon:       Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),

                      // ── Age ─────────────────────────────────────────────────
                      _sectionLabel("Your Age  ·  optional"),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller:   _ageCtrl,
                        hint:         "e.g. 24",
                        icon:         Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      // ── Skin type ───────────────────────────────────────────
                      _sectionLabel("Skin Type"),
                      const SizedBox(height: 12),
                      ...List.generate(_skinTypes.length, (i) {
                        final opt    = _skinTypes[i];
                        final active = _selectedSkinType == opt.label;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SkinTypeCard(
                            option:   opt,
                            selected: active,
                            rose:     _rose,
                            orchid:   _orchid,
                            orchidDark: _orchidDark,
                            textPrimary: _textPrimary,
                            textMuted:   _textMuted,
                            onTap: () =>
                                setState(() => _selectedSkinType = opt.label),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // ── Concerns ────────────────────────────────────────────
                      _sectionLabel("Skin Concerns  ·  select all that apply"),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _concernOptions.map((c) {
                          final selected = _selectedConcerns.contains(c);
                          return GestureDetector(
                            onTap: () => setState(() {
                              selected
                                  ? _selectedConcerns.remove(c)
                                  : _selectedConcerns.add(c);
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? const LinearGradient(
                                        colors: [_rose, _orchid])
                                    : null,
                                color: selected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : _orchid.withOpacity(0.4),
                                  width: 1.2,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: _orchid.withOpacity(0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : _textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 36),

                      // ── CTA ─────────────────────────────────────────────────
                      GestureDetector(
                        onTap: _isLoading ? null : _submit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 17),
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
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_awesome_rounded,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 10),
                                      Text(
                                        "Let's Get Glowing!",
                                        style: TextStyle(
                                          color:      Colors.white,
                                          fontSize:   16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
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

  // ── Gradient header ──────────────────────────────────────────────────────────
  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 60, 22, 28),
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
          // sparkle icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:  Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(height: 14),
          const Text(
            "Build Your Beauty\nProfile ✨",
            style: TextStyle(
              fontSize:   26,
              fontWeight: FontWeight.w800,
              color:      Colors.white,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tell us about your skin so we can give\nyou personalised recommendations.",
            style: TextStyle(
              fontSize: 13.5,
              color:    Colors.white.withOpacity(0.85),
              height:   1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize:      11,
        fontWeight:    FontWeight.w700,
        color:         _textMuted,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
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
        style: const TextStyle(fontSize: 14, color: _textPrimary),
        decoration: InputDecoration(
          hintText:  hint,
          hintStyle: TextStyle(fontSize: 14, color: _textMuted.withOpacity(0.6)),
          prefixIcon: Container(
            margin:  const EdgeInsets.all(12),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color:  _orchid.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: _orchidDark),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:   BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _orchid, width: 1.5),
          ),
          filled:          true,
          fillColor:       Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        ),
      ),
    );
  }
}

// ── Skin type data model ──────────────────────────────────────────────────────
class _SkinOption {
  final String    label;
  final IconData  icon;
  final String    description;
  const _SkinOption(this.label, this.icon, this.description);
}

// ── Skin type card ────────────────────────────────────────────────────────────
class _SkinTypeCard extends StatelessWidget {
  const _SkinTypeCard({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.rose,
    required this.orchid,
    required this.orchidDark,
    required this.textPrimary,
    required this.textMuted,
  });

  final _SkinOption option;
  final bool        selected;
  final VoidCallback onTap;
  final Color rose, orchid, orchidDark, textPrimary, textMuted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? null : Colors.white,
          gradient: selected
              ? LinearGradient(
                  colors: [rose.withOpacity(0.08), orchid.withOpacity(0.12)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? rose : orchid.withOpacity(0.25),
            width: selected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color:  Colors.black.withOpacity(selected ? 0.07 : 0.04),
              blurRadius: selected ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(colors: [rose, orchid])
                    : null,
                color: selected ? null : orchid.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                size:  20,
                color: selected ? Colors.white : orchidDark,
              ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color:      selected ? rose : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 12,
                      color:    textMuted,
                      height:   1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Check mark
            AnimatedOpacity(
              opacity:  selected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:  rose,
                  shape:  BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}