import 'package:flutter/material.dart';

class FaceYogaPage extends StatefulWidget {
  const FaceYogaPage({super.key});

  @override
  State<FaceYogaPage> createState() => _FaceYogaPageState();
}

class _FaceYogaPageState extends State<FaceYogaPage>
    with SingleTickerProviderStateMixin {
  // ── Colour tokens ─────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _card        = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  int _selectedLevel = 0;
  int? _activeRoutine;

  final List<String> _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  final List<Map<String, dynamic>> _stats = [
    {'label': 'Routines', 'value': '12', 'icon': Icons.self_improvement},
    {'label': 'Minutes', 'value': '5–15', 'icon': Icons.timer_outlined},
    {'label': 'Benefits', 'value': '20+', 'icon': Icons.auto_awesome_outlined},
  ];

  final List<Map<String, dynamic>> _routines = [
    {
      'title': 'Morning Glow',
      'desc': 'Energise & depuff your face to start the day',
      'duration': '5 min',
      'moves': 4,
      'level': 'Beginner',
      'emoji': '🌅',
      'color': const Color(0xFFFFF0D6),
      'accent': const Color(0xFFF5C97A),
      'exercises': [
        'Forehead Smoother – 10 reps',
        'Cheek Puffer – hold 5 sec × 5',
        'Jaw Release – 8 reps',
        'Eye Opener – 10 reps',
      ],
    },
    {
      'title': 'Cheek Lift',
      'desc': 'Tone & lift sagging cheeks with targeted moves',
      'duration': '8 min',
      'moves': 5,
      'level': 'Intermediate',
      'emoji': '✨',
      'color': const Color(0xFFFFEBF2),
      'accent': const Color(0xFFE8708A),
      'exercises': [
        'Smiling Fish – 10 reps',
        'Puppet Face – 8 reps',
        'Chipmunk Puff – hold 10 sec × 4',
        'Upper Lip Lifter – 10 reps',
        'Satchmo – 8 reps each side',
      ],
    },
    {
      'title': 'Neck & Jawline',
      'desc': 'Define your jawline and firm the neck',
      'duration': '10 min',
      'moves': 6,
      'level': 'Intermediate',
      'emoji': '💪',
      'color': const Color(0xFFEEF4FF),
      'accent': const Color(0xFF9EB8D4),
      'exercises': [
        'Neck Roll – 5 reps each direction',
        'Tongue to Ceiling – hold 5 sec × 8',
        'Jaw Jut – 10 reps',
        'Platysma Pull – 10 reps',
        'Chin Tuck – 12 reps',
        'Scoop & Lift – 8 reps',
      ],
    },
    {
      'title': 'Eye Area Refresh',
      'desc': 'Reduce fine lines and brighten under-eyes',
      'duration': '7 min',
      'moves': 5,
      'level': 'Beginner',
      'emoji': '👁️',
      'color': const Color(0xFFEEF4FF),
      'accent': const Color(0xFFB8A0C8),
      'exercises': [
        'V-Sign Squint – 10 reps',
        'Under-Eye Pressure – hold 5 sec × 6',
        'Crow\'s Feet Smoother – 10 reps',
        'Brow Lifter – 10 reps',
        'Wide Eyes Hold – 5 sec × 8',
      ],
    },
    {
      'title': 'Full Face Sculpt',
      'desc': 'A complete lifting & toning session',
      'duration': '15 min',
      'moves': 10,
      'level': 'Advanced',
      'emoji': '🏆',
      'color': const Color(0xFFFFF7EE),
      'accent': const Color(0xFFE8A870),
      'exercises': [
        'Forehead Smoother – 10 reps',
        'Eye Opener – 10 reps',
        'Cheek Puffer – 5 reps',
        'Smiling Fish – 10 reps',
        'Jaw Release – 8 reps',
        'Tongue to Ceiling – 8 reps',
        'Platysma Pull – 10 reps',
        'Neck Roll – 5 each side',
        'Brow Lifter – 10 reps',
        'Full Face Massage – 2 min',
      ],
    },
    {
      'title': 'Stress Relief',
      'desc': 'Release jaw tension & relax facial muscles',
      'duration': '6 min',
      'moves': 4,
      'level': 'Beginner',
      'emoji': '🧘',
      'color': const Color(0xFFEEFAF4),
      'accent': const Color(0xFF7EC4A4),
      'exercises': [
        'Lion\'s Breath – 5 reps',
        'Jaw Drops – hold 5 sec × 6',
        'Temple Circles – 30 sec',
        'Full Face Relax & Reset – 1 min',
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredRoutines {
    if (_selectedLevel == 0) return _routines;
    final label = _levels[_selectedLevel];
    return _routines.where((r) => r['level'] == label).toList();
  }

  final List<Map<String, dynamic>> _tips = [
    {
      'tip': 'Apply a few drops of facial oil before starting to reduce friction',
      'icon': Icons.opacity,
    },
    {
      'tip': 'Practise in front of a mirror to ensure correct form',
      'icon': Icons.face,
    },
    {
      'tip': 'Consistency beats intensity — 5 min daily beats 1 hour weekly',
      'icon': Icons.calendar_today,
    },
    {
      'tip': 'Always cleanse before your session to prevent pore-clogging',
      'icon': Icons.water_drop,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildLevelFilter()),
          SliverToBoxAdapter(child: _buildSectionHeader('Routines')),
          SliverToBoxAdapter(child: _buildRoutinesList()),
          SliverToBoxAdapter(child: _buildTipsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _surface,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: _textPrimary),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF0FFF4), Color(0xFFFDF7FA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7EC4A4).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🧘 FACE YOGA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A9A7A),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tone & Lift With\nDaily Routines',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Natural facelift through targeted exercises',
                    style: TextStyle(
                      fontSize: 13,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Stats Row ───────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE96A85), Color(0xFFD44E80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _rose.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _stats.map((s) {
          return Column(
            children: [
              Icon(s['icon'] as IconData, color: Colors.white70, size: 20),
              const SizedBox(height: 4),
              Text(
                s['value'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                s['label'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Level Filter ────────────────────────────────────────────────────────────
  Widget _buildLevelFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _levels.length,
        itemBuilder: (context, i) {
          final active = _selectedLevel == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedLevel = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(colors: [_rose, _orchid])
                    : null,
                color: active ? null : _card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: active
                        ? _rose.withOpacity(0.25)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                _levels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : _textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
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
            'See all',
            style: TextStyle(
              fontSize: 13,
              color: _orchidDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Routines List ───────────────────────────────────────────────────────────
  Widget _buildRoutinesList() {
    final items = _filteredRoutines;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final routine = entry.value;
          final isExpanded = _activeRoutine == i;
          return GestureDetector(
            onTap: () =>
                setState(() => _activeRoutine = isExpanded ? null : i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: isExpanded
                    ? Border.all(
                        color: (routine['accent'] as Color).withOpacity(0.3),
                        width: 1.5,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: isExpanded ? 16 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header row
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: routine['color'] as Color,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              routine['emoji'] as String,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                routine['title'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                routine['desc'] as String,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: _textMuted,
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _pill(
                                    '⏱ ${routine['duration']}',
                                    routine['accent'] as Color,
                                  ),
                                  const SizedBox(width: 6),
                                  _pill(
                                    '${routine['moves']} moves',
                                    _textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  _pill(
                                    routine['level'] as String,
                                    routine['accent'] as Color,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: _textMuted,
                        ),
                      ],
                    ),
                  ),

                  // Expanded exercises
                  if (isExpanded) ...[
                    Divider(
                      height: 1,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Exercises',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...(routine['exercises'] as List<String>)
                              .asMap()
                              .entries
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: (routine['accent'] as Color)
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${e.key + 1}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  routine['accent'] as Color,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        e.value,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: _textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  routine['accent'] as Color,
                                  (routine['accent'] as Color)
                                      .withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Start Routine →',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color == _textMuted ? _textMuted : color,
        ),
      ),
    );
  }

  // ── Tips Section ────────────────────────────────────────────────────────────
  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Pro Tips'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _tips.map((tip) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _orchid.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        tip['icon'] as IconData,
                        size: 18,
                        color: _orchidDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip['tip'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}