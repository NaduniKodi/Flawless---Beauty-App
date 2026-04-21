import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
// import 'package:url_launcher/url_launcher.dart';

class FaceYogaPage extends StatefulWidget {
  const FaceYogaPage({super.key});

  @override
  State<FaceYogaPage> createState() => _FaceYogaPageState();
}

class _FaceYogaPageState extends State<FaceYogaPage>
    with SingleTickerProviderStateMixin {
  // ── Colour tokens ──────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _card        = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  // ── Page State ─────────────────────────────────────────────────────────────
  int _selectedLevel = 0;
  int? _activeRoutine;
  final List<String> _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  // ── Timer / Stopwatch State ────────────────────────────────────────────────
  // Timer (countdown)
  int _timerTotalSeconds  = 60;
  int _timerRemaining     = 60;
  bool _timerRunning      = false;
  Timer? _countdownTimer;
  int _selectedPreset     = 60; // seconds

  // Stopwatch
  int _stopwatchElapsed   = 0;
  bool _stopwatchRunning  = false;
  Timer? _stopwatchTimer;

  // ── Stats ──────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _stats = [
    {'label': 'Routines', 'value': '12',   'icon': Icons.self_improvement},
    {'label': 'Minutes',  'value': '5–15', 'icon': Icons.timer_outlined},
    {'label': 'Benefits', 'value': '20+',  'icon': Icons.auto_awesome_outlined},
  ];

  // ── Routines ───────────────────────────────────────────────────────────────
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

  // ── Videos ─────────────────────────────────────────────────────────────────
  // Real face yoga videos from YouTube. Thumbnails fetched via YouTube's
  // public thumbnail CDN. Tap opens YouTube via url_launcher.
  final List<Map<String, dynamic>> _videos = [
    {
      'id':       'PKoMEHCyVag',
      'title':    '5-Min Morning Face Yoga',
      'channel':  'Danielle Collins',
      'duration': '5:12',
      'tag':      'Beginner',
      'tagColor': const Color(0xFF7EC4A4),
    },
    {
      'id':       'p_KpSNRNDKs',
      'title':    'Face Yoga for Cheeks & Smile Lines',
      'channel':  'Face Yoga Method',
      'duration': '8:44',
      'tag':      'Intermediate',
      'tagColor': const Color(0xFFE8708A),
    },
    {
      'id':       'tFJPBSv3BSo',
      'title':    'Jawline & Neck Firming Routine',
      'channel':  'Danielle Collins',
      'duration': '10:20',
      'tag':      'Intermediate',
      'tagColor': const Color(0xFFE8708A),
    },
    {
      'id':       'JQyoJOuTBEU',
      'title':    'Reduce Eye Wrinkles Naturally',
      'channel':  'Face Yoga Method',
      'duration': '7:05',
      'tag':      'Beginner',
      'tagColor': const Color(0xFF7EC4A4),
    },
    {
      'id':       'RttlULFT1Qk',
      'title':    'Full Face Lift 15-Min Workout',
      'channel':  'Yoga Face',
      'duration': '14:58',
      'tag':      'Advanced',
      'tagColor': const Color(0xFFE8A870),
    },
  ];

  // ── Tips ───────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _tips = [
    {
      'tip':  'Apply a few drops of facial oil before starting to reduce friction',
      'icon': Icons.opacity,
    },
    {
      'tip':  'Practise in front of a mirror to ensure correct form',
      'icon': Icons.face,
    },
    {
      'tip':  'Consistency beats intensity — 5 min daily beats 1 hour weekly',
      'icon': Icons.calendar_today,
    },
    {
      'tip':  'Always cleanse before your session to prevent pore-clogging',
      'icon': Icons.water_drop,
    },
  ];

  // ── Timer helpers ──────────────────────────────────────────────────────────
  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _timerRunning = true);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timerRemaining <= 1) {
        _countdownTimer?.cancel();
        HapticFeedback.heavyImpact();
        setState(() {
          _timerRunning   = false;
          _timerRemaining = 0;
        });
      } else {
        setState(() => _timerRemaining--);
        if (_timerRemaining <= 3) HapticFeedback.lightImpact();
      }
    });
  }

  void _pauseCountdown() {
    _countdownTimer?.cancel();
    setState(() => _timerRunning = false);
  }

  void _resetCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _timerRunning   = false;
      _timerRemaining = _timerTotalSeconds;
    });
  }

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() => _stopwatchRunning = true);
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _stopwatchElapsed++);
    });
  }

  void _pauseStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() => _stopwatchRunning = false);
  }

  void _resetStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() {
      _stopwatchRunning = false;
      _stopwatchElapsed = 0;
    });
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds  % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _timerProgress =>
      _timerTotalSeconds == 0 ? 1 : _timerRemaining / _timerTotalSeconds;

  // ── URL launcher ───────────────────────────────────────────────────────────
  Future<void> _openYouTube(String videoId) async {
    // Uncomment when url_launcher is added to pubspec.yaml:
    // final uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    // if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    debugPrint('Open YouTube: https://www.youtube.com/watch?v=$videoId');
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      floatingActionButton: _buildTimerFAB(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildLevelFilter()),
          SliverToBoxAdapter(child: _buildSectionHeader('Routines')),
          SliverToBoxAdapter(child: _buildRoutinesList()),
          // ── NEW: Videos section ──────────────────────────────────────────
          SliverToBoxAdapter(child: _buildVideosSection()),
          // ────────────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildTipsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ── FAB: open timer sheet ──────────────────────────────────────────────────
  Widget _buildTimerFAB() {
    return FloatingActionButton.extended(
      onPressed: _showTimerSheet,
      backgroundColor: _rose,
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.timer_rounded, size: 20),
      label: const Text(
        'Timer',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TIMER / STOPWATCH BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════════════
  void _showTimerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TimerStopwatchSheet(
        // Pass state + callbacks so the sheet stays in sync with the page
        timerRemaining:    _timerRemaining,
        timerTotal:        _timerTotalSeconds,
        timerRunning:      _timerRunning,
        selectedPreset:    _selectedPreset,
        stopwatchElapsed:  _stopwatchElapsed,
        stopwatchRunning:  _stopwatchRunning,
        formatTime:        _formatTime,
        timerProgress:     _timerProgress,
        onPresetSelected: (secs) {
          setState(() {
            _selectedPreset    = secs;
            _timerTotalSeconds = secs;
            _timerRemaining    = secs;
            _timerRunning      = false;
          });
          _countdownTimer?.cancel();
        },
        onTimerStart:  _startCountdown,
        onTimerPause:  _pauseCountdown,
        onTimerReset:  _resetCountdown,
        onSwStart:     _startStopwatch,
        onSwPause:     _pauseStopwatch,
        onSwReset:     _resetStopwatch,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SLIVER APP BAR
  // ══════════════════════════════════════════════════════════════════════════
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
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    style: TextStyle(fontSize: 13, color: _textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STATS ROW
  // ══════════════════════════════════════════════════════════════════════════
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
              Text(s['value'] as String,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              Text(s['label'] as String,
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LEVEL FILTER
  // ══════════════════════════════════════════════════════════════════════════
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

  // ══════════════════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: -0.2)),
          Text('See all',
              style: TextStyle(
                  fontSize: 13,
                  color: _orchidDark,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ROUTINES LIST
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRoutinesList() {
    final items = _filteredRoutines;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i       = entry.key;
          final routine = entry.value;
          final isExp   = _activeRoutine == i;
          return GestureDetector(
            onTap: () => setState(() => _activeRoutine = isExp ? null : i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: isExp
                    ? Border.all(
                        color: (routine['accent'] as Color).withOpacity(0.3),
                        width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: isExp ? 16 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
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
                            child: Text(routine['emoji'] as String,
                                style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(routine['title'] as String,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary)),
                              const SizedBox(height: 3),
                              Text(routine['desc'] as String,
                                  style: const TextStyle(
                                      fontSize: 11.5, color: _textMuted),
                                  maxLines: 2),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _pill('⏱ ${routine['duration']}',
                                      routine['accent'] as Color),
                                  const SizedBox(width: 6),
                                  _pill('${routine['moves']} moves', _textMuted),
                                  const SizedBox(width: 6),
                                  _pill(routine['level'] as String,
                                      routine['accent'] as Color),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExp
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: _textMuted,
                        ),
                      ],
                    ),
                  ),
                  if (isExp) ...[
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Exercises',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _textMuted,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 10),
                          ...(routine['exercises'] as List<String>)
                              .asMap()
                              .entries
                              .map((e) => Padding(
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
                                            child: Text('${e.key + 1}',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: routine['accent']
                                                        as Color)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(e.value,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: _textPrimary)),
                                      ],
                                    ),
                                  )),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                routine['accent'] as Color,
                                (routine['accent'] as Color).withOpacity(0.7),
                              ]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('Start Routine →',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
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
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color == _textMuted ? _textMuted : color)),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ▶ VIDEOS SECTION (NEW)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildVideosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Watch & Learn'),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: _videos.length,
            itemBuilder: (context, i) => _buildVideoCard(_videos[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final String videoId  = video['id']   as String;
    final String title    = video['title']   as String;
    final String channel  = video['channel'] as String;
    final String duration = video['duration'] as String;
    final String tag      = video['tag']     as String;
    final Color  tagColor = video['tagColor'] as Color;

    // YouTube HQ thumbnail URL (public CDN — no API key needed)
    final thumbUrl =
        'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return GestureDetector(
      onTap: () => _openYouTube(videoId),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    thumbUrl,
                    width: 200,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 200,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _rose.withOpacity(0.12),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded,
                            size: 40, color: _rose),
                      ),
                    ),
                  ),
                ),
                // Play button overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18)),
                      color: Colors.black.withOpacity(0.18),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_circle_fill_rounded,
                          size: 42, color: Colors.white),
                    ),
                  ),
                ),
                // Duration badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(duration,
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            // ── Info ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(tag,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: tagColor)),
                  ),
                  const SizedBox(height: 5),
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          height: 1.3)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline_rounded,
                          size: 11, color: _textMuted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(channel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: _textMuted)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TIPS SECTION
  // ══════════════════════════════════════════════════════════════════════════
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
                      child: Icon(tip['icon'] as IconData,
                          size: 18, color: _orchidDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(tip['tip'] as String,
                          style: const TextStyle(
                              fontSize: 13, color: _textPrimary, height: 1.4)),
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

// ════════════════════════════════════════════════════════════════════════════
// TIMER & STOPWATCH BOTTOM SHEET (stateful widget so it can rebuild itself)
// ════════════════════════════════════════════════════════════════════════════
class _TimerStopwatchSheet extends StatefulWidget {
  final int    timerRemaining;
  final int    timerTotal;
  final bool   timerRunning;
  final int    selectedPreset;
  final int    stopwatchElapsed;
  final bool   stopwatchRunning;
  final double timerProgress;

  final String Function(int) formatTime;

  final void Function(int) onPresetSelected;
  final VoidCallback onTimerStart;
  final VoidCallback onTimerPause;
  final VoidCallback onTimerReset;
  final VoidCallback onSwStart;
  final VoidCallback onSwPause;
  final VoidCallback onSwReset;

  const _TimerStopwatchSheet({
    required this.timerRemaining,
    required this.timerTotal,
    required this.timerRunning,
    required this.selectedPreset,
    required this.stopwatchElapsed,
    required this.stopwatchRunning,
    required this.timerProgress,
    required this.formatTime,
    required this.onPresetSelected,
    required this.onTimerStart,
    required this.onTimerPause,
    required this.onTimerReset,
    required this.onSwStart,
    required this.onSwPause,
    required this.onSwReset,
  });

  @override
  State<_TimerStopwatchSheet> createState() => _TimerStopwatchSheetState();
}

class _TimerStopwatchSheetState extends State<_TimerStopwatchSheet>
    with SingleTickerProviderStateMixin {
  static const Color _rose       = Color(0xFFE8708A);
  static const Color _surface    = Color(0xFFFDF7FA);
  static const Color _textPrimary= Color(0xFF1C1224);
  static const Color _textMuted  = Color(0xFF9E8DA8);

  late TabController _tab;

  // Local mirror of parent state — rebuilt every second via callbacks
  late int    _timerRemaining;
  late bool   _timerRunning;
  late int    _stopwatchElapsed;
  late bool   _stopwatchRunning;
  late int    _selectedPreset;
  late double _timerProgress;

  // Local timers so the sheet updates itself even while open
  Timer? _localCountdown;
  Timer? _localStopwatch;

  final List<Map<String, dynamic>> _presets = [
    {'label': '30s',  'secs': 30},
    {'label': '1 min','secs': 60},
    {'label': '3 min','secs': 180},
    {'label': '5 min','secs': 300},
    {'label': '8 min','secs': 480},
    {'label': '10 min','secs': 600},
  ];

  @override
  void initState() {
    super.initState();
    _tab              = TabController(length: 2, vsync: this);
    _timerRemaining   = widget.timerRemaining;
    _timerRunning     = widget.timerRunning;
    _stopwatchElapsed = widget.stopwatchElapsed;
    _stopwatchRunning = widget.stopwatchRunning;
    _selectedPreset   = widget.selectedPreset;
    _timerProgress    = widget.timerProgress;

    // Resume local ticking if already running
    if (_timerRunning)    _startLocalCountdown();
    if (_stopwatchRunning) _startLocalStopwatch();
  }

  void _startLocalCountdown() {
    _localCountdown?.cancel();
    _localCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timerRemaining <= 1) {
        _localCountdown?.cancel();
        HapticFeedback.heavyImpact();
        setState(() {
          _timerRunning   = false;
          _timerRemaining = 0;
          _timerProgress  = 0;
        });
        widget.onTimerPause();
      } else {
        setState(() {
          _timerRemaining--;
          _timerProgress = _timerRemaining / _selectedPreset;
        });
        if (_timerRemaining <= 3) HapticFeedback.lightImpact();
      }
    });
  }

  void _startLocalStopwatch() {
    _localStopwatch?.cancel();
    _localStopwatch =
        Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _stopwatchElapsed++);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _localCountdown?.cancel();
    _localStopwatch?.cancel();
    super.dispose();
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: _rose,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: _textMuted,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: '⏱  Timer'),
                Tab(text: '🕐  Stopwatch'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 360,
            child: TabBarView(
              controller: _tab,
              children: [
                _buildTimerTab(),
                _buildStopwatchTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Timer Tab ──────────────────────────────────────────────────────────────
  Widget _buildTimerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Circular progress
          _buildCircularTimer(),
          const SizedBox(height: 20),

          // Presets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _presets.map((p) {
              final active = _selectedPreset == p['secs'];
              return GestureDetector(
                onTap: () {
                  if (_timerRunning) return; // ignore taps while running
                  _localCountdown?.cancel();
                  widget.onPresetSelected(p['secs'] as int);
                  setState(() {
                    _selectedPreset  = p['secs'] as int;
                    _timerRemaining  = p['secs'] as int;
                    _timerRunning    = false;
                    _timerProgress   = 1.0;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? _rose : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: active
                            ? _rose.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(p['label'] as String,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : _textMuted)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset
              _iconBtn(
                icon: Icons.refresh_rounded,
                onTap: () {
                  _localCountdown?.cancel();
                  widget.onTimerReset();
                  setState(() {
                    _timerRunning   = false;
                    _timerRemaining = _selectedPreset;
                    _timerProgress  = 1.0;
                  });
                },
              ),
              const SizedBox(width: 20),
              // Play / Pause
              GestureDetector(
                onTap: () {
                  if (_timerRemaining == 0) return;
                  if (_timerRunning) {
                    _localCountdown?.cancel();
                    widget.onTimerPause();
                    setState(() => _timerRunning = false);
                  } else {
                    widget.onTimerStart();
                    setState(() => _timerRunning = true);
                    _startLocalCountdown();
                  }
                },
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFE96A85), Color(0xFFD44E80)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _rose.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _timerRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularTimer() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: _timerProgress,
              strokeWidth: 8,
              backgroundColor: Colors.grey.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                _timerRemaining > 0 ? _rose : Colors.grey,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _fmt(_timerRemaining),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -1,
                ),
              ),
              Text(
                _timerRunning ? 'Running…' : 'Ready',
                style: const TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stopwatch Tab ──────────────────────────────────────────────────────────
  Widget _buildStopwatchTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Big display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0F5), Color(0xFFFDF7FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _rose.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _fmt(_stopwatchElapsed),
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                    letterSpacing: -2,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _stopwatchRunning ? '● Recording time' : 'Paused',
                  style: TextStyle(
                    fontSize: 12,
                    color: _stopwatchRunning ? _rose : _textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _iconBtn(
                icon: Icons.refresh_rounded,
                onTap: () {
                  _localStopwatch?.cancel();
                  widget.onSwReset();
                  setState(() {
                    _stopwatchRunning = false;
                    _stopwatchElapsed = 0;
                  });
                },
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  if (_stopwatchRunning) {
                    _localStopwatch?.cancel();
                    widget.onSwPause();
                    setState(() => _stopwatchRunning = false);
                  } else {
                    widget.onSwStart();
                    setState(() => _stopwatchRunning = true);
                    _startLocalStopwatch();
                  }
                },
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFE96A85), Color(0xFFD44E80)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _rose.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _stopwatchRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: _textMuted, size: 22),
      ),
    );
  }
}