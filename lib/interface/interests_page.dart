import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/services/interest_data.dart'; // adjust import path to match your project

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  // ── Colour tokens (matches HomePage) ────────────────────────────────────────
  static const Color _rose       = Color(0xFFE8708A);
  static const Color _roseDark   = Color(0xFFC2516B);
  static const Color _orchid     = Color(0xFFF8AFCB);
  static const Color _surface    = Color(0xFFFDF7FA);
  static const Color _textMuted  = Color(0xFF9E8DA8);

  final LinearGradient _gradient = const LinearGradient(
    colors: [Color(0xFFE8708A), Color(0xFFF8AFCB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Beauty-focused categories ────────────────────────────────────────────────
  final Map<String, List<Map<String, dynamic>>> _categories = {
    'Skin Type': [
      {'label': 'Oily',        'icon': '🫧'},
      {'label': 'Dry',         'icon': '🌵'},
      {'label': 'Combination', 'icon': '🌓'},
      {'label': 'Sensitive',   'icon': '🌸'},
      {'label': 'Normal',      'icon': '✨'},
      {'label': 'Acne-Prone',  'icon': '🔴'},
    ],
    'Skin Goals': [
      {'label': 'Anti-Aging',      'icon': '⏳'},
      {'label': 'Brightening',     'icon': '☀️'},
      {'label': 'Hydration',       'icon': '💧'},
      {'label': 'Pore Minimizing', 'icon': '🔬'},
      {'label': 'Even Tone',       'icon': '🌟'},
      {'label': 'Glow Up',         'icon': '💫'},
    ],
    'Makeup Vibe': [
      {'label': 'Natural',   'icon': '🌿'},
      {'label': 'Glam',      'icon': '💎'},
      {'label': 'Bold',      'icon': '💋'},
      {'label': 'Minimal',   'icon': '🪞'},
      {'label': 'Editorial', 'icon': '🎭'},
      {'label': 'Night Out', 'icon': '🌙'},
    ],
    'Beauty Lifestyle': [
      {'label': 'Cruelty-Free', 'icon': '🐰'},
      {'label': 'Vegan',        'icon': '🌱'},
      {'label': 'K-Beauty',     'icon': '🎀'},
      {'label': 'Drugstore',    'icon': '🛍️'},
      {'label': 'Luxury',       'icon': '👑'},
      {'label': 'DIY Beauty',   'icon': '🧪'},
    ],
    'Routines & Rituals': [
      {'label': 'AM Routine',      'icon': '☀️'},
      {'label': 'PM Routine',      'icon': '🌙'},
      {'label': 'Face Masking',    'icon': '🧖'},
      {'label': 'Facial Massage',  'icon': '💆'},
      {'label': 'SPF Obsessed',    'icon': '☂️'},
      {'label': 'Face Yoga',       'icon': '🧘'},
    ],
    'Hair & Body': [
      {'label': 'Hair Care',  'icon': '💆'},
      {'label': 'Nail Art',   'icon': '💅'},
      {'label': 'Body Care',  'icon': '🧴'},
      {'label': 'Fragrance',  'icon': '🌸'},
      {'label': 'Brows',      'icon': '🪮'},
      {'label': 'Lip Looks',  'icon': '💄'},
    ],
  };

  // Start with a copy of the current saved selection so the user can cancel
  late Set<String> _draft;

  @override
  void initState() {
    super.initState();
    _draft = Set.from(InterestData.instance.selected);
  }

  void _save() {
    InterestData.instance.saveAll(_draft);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_draft.length} interests saved! ✨'),
        backgroundColor: _roseDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(gradient: _gradient),
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
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'My Beauty Interests',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    // Transparent spacer to balance the back button
                    const SizedBox(width: 38),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hint card ────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _orchid.withOpacity(0.4), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: _rose.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: _gradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Pick what you love — we\'ll personalise your routines, product picks & AI recommendations.',
                            style: TextStyle(
                              color: Color(0xFF9E8DA8),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Selected count ───────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: StatefulBuilder(
                      builder: (_, __) => Text(
                        '${_draft.length} selected',
                        style: TextStyle(
                          color: _roseDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Category sections ────────────────────────────────────────
                  ..._categories.entries.map((entry) => _buildCategory(entry.key, entry.value)),

                  const SizedBox(height: 8),

                  // ── Save button ──────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _rose.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Save My Interests',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String name, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF9E8DA8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final label = item['label'] as String;
            final icon  = item['icon']  as String;

            return StatefulBuilder(
              builder: (_, localSet) {
                final isSelected = _draft.contains(label);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _draft.remove(label);
                      } else {
                        _draft.add(label);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected ? _gradient : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : const Color(0xFFEDD5E1),
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _rose.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF4A3B52),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            fontSize: 13.5,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 22),
      ],
    );
  }
}