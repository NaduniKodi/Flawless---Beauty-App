// lib/interface/my_routine_page.dart
//
// A full-screen personalized skin-care routine page.
// Reads from UserData + InterestData via SkinAdvisor and renders:
//   • A rotating daily tip card
//   • The user's skin-profile summary chips
//   • AM / PM toggle with personalized step cards
//   • A "Key Ingredients" section for product shopping

import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/services/user_data.dart';
import 'package:flawless_beauty_app/services/skin_advisor.dart';

class MyRoutinePage extends StatefulWidget {
  const MyRoutinePage({super.key});

  @override
  State<MyRoutinePage> createState() => _MyRoutinePageState();
}

class _MyRoutinePageState extends State<MyRoutinePage>
    with SingleTickerProviderStateMixin {
  // ── Colour tokens ────────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  bool _showAM = true;

  late AnimationController _ctrl;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    // Default to AM in the morning, PM in the evening
    final hour = DateTime.now().hour;
    _showAM = hour < 18;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _switchTab(bool am) {
    if (_showAM == am) return;
    _ctrl.reverse().then((_) {
      setState(() => _showAM = am);
      _ctrl.forward();
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserData.instance,
      builder: (_, __) {
        final u       = UserData.instance;
        final steps   = _showAM ? SkinAdvisor.amRoutine : SkinAdvisor.pmRoutine;
        final tip     = SkinAdvisor.dailyTip;
        final keywords = SkinAdvisor.productKeywords;

        return Scaffold(
          backgroundColor: _surface,
          body: Column(
            children: [
              _buildHeader(u),
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Daily tip
                        _buildTipCard(tip),
                        const SizedBox(height: 20),

                        // Skin profile summary
                        if (SkinAdvisor.hasSkinProfile) ...[
                          _buildSkinProfileSummary(u),
                          const SizedBox(height: 20),
                        ],

                        // AM / PM toggle
                        _buildToggle(),
                        const SizedBox(height: 18),

                        // Routine steps
                        ...steps.asMap().entries.map(
                          (e) => _buildStepCard(e.value, e.key, steps.length),
                        ),

                        // Ingredients section
                        if (keywords.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildIngredients(keywords),
                        ],

                        // Empty-profile CTA
                        if (!SkinAdvisor.hasSkinProfile) ...[
                          const SizedBox(height: 20),
                          _buildNoProfileCard(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader(UserData u) {
    final hour      = DateTime.now().hour;
    final timeLabel = hour < 12 ? 'Morning' : hour < 18 ? 'Afternoon' : 'Evening';
    final firstName = u.name.isEmpty ? 'You' : u.name.split(' ').first;

    // Gradient shifts for AM (warm rose) vs PM (purple-black)
    final colors = _showAM
        ? const [Color(0xFFE96A85), Color(0xFFF8AFCB)]
        : const [Color.fromARGB(255, 23, 1, 51), Color(0xFFE96A85)];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const Spacer(),
              if (u.skinType.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_skinEmoji(u.skinType)} ${u.skinType} Skin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Good $timeLabel, $firstName!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your Personalised\nSkin Routine ✨',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Every step below is tailored to your\n'
            '${u.skinType.isEmpty ? "skin" : "${u.skinType.toLowerCase()} skin"}'
            '${u.skinConcerns.isEmpty ? "." : " and your specific concerns."}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ── Daily Tip Card ───────────────────────────────────────────────────────────
  Widget _buildTipCard(String tip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _orchid.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: _rose.withOpacity(0.08),
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
                    fontSize: 13.5,
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

  // ── Skin Profile Summary ─────────────────────────────────────────────────────
  Widget _buildSkinProfileSummary(UserData u) {
    final chips = <Widget>[
      if (u.skinType.isNotEmpty)
        _chip('${_skinEmoji(u.skinType)} ${u.skinType} Skin', primary: true),
      if (u.age != null)
        _chip('🎂 Age ${u.age}', primary: false),
      ...u.skinConcerns.map((c) => _chip(c, primary: false)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR SKIN PROFILE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  Widget _chip(String label, {required bool primary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: primary
            ? const LinearGradient(colors: [_rose, _orchid])
            : null,
        color: primary ? null : _orchid.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: primary ? null : Border.all(color: _orchid.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primary ? Colors.white : _orchidDark,
        ),
      ),
    );
  }

  // ── AM / PM Toggle ───────────────────────────────────────────────────────────
  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _toggleBtn('☀️  Morning Routine', isAM: true),
          _toggleBtn('🌙  Evening Routine', isAM: false),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, {required bool isAM}) {
    final active = _showAM == isAM;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(isAM),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    colors: isAM
                        ? const [Color(0xFFE96A85), Color(0xFFF8AFCB)]
                        : const [Color.fromARGB(255, 33, 1, 75), Color(0xFFE96A85)],
                  )
                : null,
            borderRadius: BorderRadius.circular(13),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _rose.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : _textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Step Card ────────────────────────────────────────────────────────────────
  Widget _buildStepCard(RoutineStep step, int index, int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + bubble
          Column(
            children: [
              // Step number bubble
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _showAM
                        ? [const Color(0xFFE96A85), const Color(0xFFF8AFCB)]
                        : [const Color.fromARGB(255, 37, 1, 84), const Color(0xFFE96A85)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _rose.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    step.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              // Connector line (not after last step)
              if (index < total - 1)
                Container(
                  width: 2,
                  height: 20,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_orchid.withOpacity(0.6), _orchid.withOpacity(0.1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Step content
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: index < total - 1 ? 0 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _orchid.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step name
                  Text(
                    step.stepName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Product type pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _orchid.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      step.productType,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _orchidDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: _textMuted.withOpacity(0.7),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          step.tip,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textMuted,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Key Ingredients ──────────────────────────────────────────────────────────
  Widget _buildIngredients(List<String> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_rose, _orchid]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'INGREDIENTS TO LOOK FOR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _textMuted,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Based on your skin type and concerns, prioritise these when shopping:',
          style: TextStyle(
            fontSize: 12,
            color: _textMuted.withOpacity(0.8),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.map((k) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _orchid.withOpacity(0.45)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '✓ ',
                    style: TextStyle(
                      color: _rose,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    k,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── No-profile CTA ───────────────────────────────────────────────────────────
  Widget _buildNoProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _orchid.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Text('✨', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          const Text(
            'No skin profile yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your routine is showing generic steps right now.\nGo to Profile → complete your Beauty Profile\nto get fully personalised advice.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Helper ───────────────────────────────────────────────────────────────────
  String _skinEmoji(String type) {
    switch (type) {
      case 'Oily':        return '🫧';
      case 'Dry':         return '🌵';
      case 'Combination': return '🌓';
      case 'Sensitive':   return '🌸';
      case 'Normal':      return '✨';
      default:            return '💆';
    }
  }
}