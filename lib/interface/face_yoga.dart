// lib/interface/face_yoga_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flawless_beauty_app/services/yoga_progress_service.dart';
import 'package:flawless_beauty_app/services/scan_history.dart';
import 'package:flawless_beauty_app/services/skin_analysis_service.dart';

// pubspec.yaml dependency needed:  url_launcher: ^2.3.1
// Add YogaProgressService.instance.clear() wherever you call
// UserData.instance.clear() and ScanHistory.instance.clear() on sign-out.

class FaceYogaPage extends StatefulWidget {
  const FaceYogaPage({super.key});
  @override
  State<FaceYogaPage> createState() => _FaceYogaPageState();
}

class _FaceYogaPageState extends State<FaceYogaPage>
    with SingleTickerProviderStateMixin {
  // ── Colours ───────────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _card        = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);
  static const Color _green       = Color(0xFF4A9A7A);
  static const Color _greenBg     = Color(0xFF7EC4A4);

  // Rep target for the 6 built-in manual routines.
  static const int _manualTarget = 14;

  // ── Services ──────────────────────────────────────────────────────────────
  final _progress = YogaProgressService.instance;

  // ── Page state ────────────────────────────────────────────────────────────
  int     _selectedLevel  = 0;
  String? _activeRoutine;     // title-keyed (safe across filter changes)
  String? _expandedAiEx;      // expanded AI exercise name
  bool    _dataLoading    = false;

  final List<String> _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  // ── Timer / stopwatch ─────────────────────────────────────────────────────
  int    _timerTotalSeconds = 60;
  int    _timerRemaining    = 60;
  bool   _timerRunning      = false;
  Timer? _countdownTimer;
  int    _selectedPreset    = 60;
  int    _stopwatchElapsed  = 0;
  bool   _stopwatchRunning  = false;
  Timer? _stopwatchTimer;

  // ── Static data ───────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _stats = [
    {'label': 'Routines', 'value': '12',   'icon': Icons.self_improvement},
    {'label': 'Minutes',  'value': '5-15', 'icon': Icons.timer_outlined},
    {'label': 'Benefits', 'value': '20+',  'icon': Icons.auto_awesome_outlined},
  ];

  final List<Map<String, dynamic>> _routines = [
    {
      'title': 'Morning Glow',
      'desc': 'Energise and depuff your face to start the day',
      'duration': '5 min', 'moves': 4, 'level': 'Beginner',
      'emoji': '🌅', 'color': const Color(0xFFFFF0D6),
      'accent': const Color(0xFFF5C97A),
      'exercises': ['Forehead Smoother', 'Cheek Puffer', 'Jaw Release', 'Eye Opener'],
    },
    {
      'title': 'Cheek Lift',
      'desc': 'Tone and lift sagging cheeks with targeted moves',
      'duration': '8 min', 'moves': 5, 'level': 'Intermediate',
      'emoji': '✨', 'color': const Color(0xFFFFEBF2),
      'accent': const Color(0xFFE8708A),
      'exercises': ['Smiling Fish', 'Puppet Face', 'Chipmunk Puff', 'Upper Lip Lifter', 'Satchmo'],
    },
    {
      'title': 'Neck and Jawline',
      'desc': 'Define your jawline and firm the neck',
      'duration': '10 min', 'moves': 6, 'level': 'Intermediate',
      'emoji': '💪', 'color': const Color(0xFFEEF4FF),
      'accent': const Color(0xFF9EB8D4),
      'exercises': ['Neck Roll', 'Tongue to Ceiling', 'Jaw Jut', 'Platysma Pull', 'Chin Tuck', 'Scoop and Lift'],
    },
    {
      'title': 'Eye Area Refresh',
      'desc': 'Reduce fine lines and brighten under-eyes',
      'duration': '7 min', 'moves': 5, 'level': 'Beginner',
      'emoji': '👁️', 'color': const Color(0xFFEEF4FF),
      'accent': const Color(0xFFB8A0C8),
      'exercises': ['V-Sign Squint', 'Under-Eye Pressure', "Crow's Feet Smoother", 'Brow Lifter', 'Wide Eyes Hold'],
    },
    {
      'title': 'Full Face Sculpt',
      'desc': 'A complete lifting and toning session',
      'duration': '15 min', 'moves': 10, 'level': 'Advanced',
      'emoji': '🏆', 'color': const Color(0xFFFFF7EE),
      'accent': const Color(0xFFE8A870),
      'exercises': [
        'Forehead Smoother', 'Eye Opener', 'Cheek Puffer', 'Smiling Fish',
        'Jaw Release', 'Tongue to Ceiling', 'Platysma Pull', 'Neck Roll',
        'Brow Lifter', 'Full Face Massage',
      ],
    },
    {
      'title': 'Stress Relief',
      'desc': 'Release jaw tension and relax facial muscles',
      'duration': '6 min', 'moves': 4, 'level': 'Beginner',
      'emoji': '🧘', 'color': const Color(0xFFEEFAF4),
      'accent': const Color(0xFF7EC4A4),
      'exercises': ["Lion's Breath", 'Jaw Drops', 'Temple Circles', 'Full Face Relax'],
    },
  ];

  List<Map<String, dynamic>> get _filteredRoutines {
    if (_selectedLevel == 0) return _routines;
    return _routines.where((r) => r['level'] == _levels[_selectedLevel]).toList();
  }

  final List<Map<String, dynamic>> _videos = [
    {'id': 'Nlv-QuY2bl0', 'title': '5-Min Morning Face Yoga',             'channel': 'Danielle Collins', 'duration': '5:02',  'tag': 'Beginner',     'tagColor': const Color(0xFF7EC4A4)},
    {'id': 'EujC5Df5ago', 'title': 'Face Yoga for Cheeks & Smile Lines',  'channel': 'Face Yoga Method', 'duration': '8:44',  'tag': 'Intermediate', 'tagColor': const Color(0xFFE8708A)},
    {'id': 'nnUpOW3yDAQ', 'title': 'Jawline and Neck Firming Routine',    'channel': 'Danielle Collins', 'duration': '9:52',  'tag': 'Intermediate', 'tagColor': const Color(0xFFE8708A)},
    {'id': 'ppAVry7AfyU', 'title': 'Reduce Eye Wrinkles Naturally',       'channel': 'Face Yoga Method', 'duration': '6:58',  'tag': 'Beginner',     'tagColor': const Color(0xFF7EC4A4)},
    {'id': '-3Br7b1mPcs', 'title': 'Full Face Lift 15-Min Workout',       'channel': 'Yoga Face',        'duration': '15:10', 'tag': 'Advanced',     'tagColor': const Color(0xFFE8A870)},
    {'id': 'nN8lFNKpXdY', 'title': 'Face Yoga for Forehead Lines',        'channel': 'Danielle Collins', 'duration': '7:15',  'tag': 'Beginner',     'tagColor': const Color(0xFF7EC4A4)},
    {'id': 'RS19XeBcvHQ', 'title': 'Jowl Lift & Nasolabial Fold Workout', 'channel': 'Face Yoga Method', 'duration': '10:30', 'tag': 'Intermediate', 'tagColor': const Color(0xFFE8708A)},
    {'id': 'Vv7yMUFvV0Y', 'title': 'Double Chin Reduction Exercises',     'channel': 'Fumiko Takatsu',   'duration': '8:05',  'tag': 'Beginner',     'tagColor': const Color(0xFF7EC4A4)},
    {'id': 'WgAtbFDMOfk', 'title': 'Advanced Face Sculpting – 20 Min',    'channel': 'Yoga Face',        'duration': '20:14', 'tag': 'Advanced',     'tagColor': const Color(0xFFE8A870)},
    {'id': '6LiSWJuHEH8', 'title': 'Lip Lines & Mouth Area Toning',       'channel': 'Face Yoga Method', 'duration': '6:22',  'tag': 'Intermediate', 'tagColor': const Color(0xFFE8708A)},
  ];

  final List<Map<String, dynamic>> _tips = [
    {'tip': 'Apply a few drops of facial oil before starting to reduce friction', 'icon': Icons.opacity},
    {'tip': 'Practise in front of a mirror to ensure correct form',               'icon': Icons.face},
    {'tip': 'Consistency beats intensity – 5 min daily beats 1 hour weekly',      'icon': Icons.calendar_today},
    {'tip': 'Always cleanse before your session to prevent pore-clogging',        'icon': Icons.water_drop},
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _progress.addListener(_refresh);
    ScanHistory.instance.addListener(_refresh);
    _loadData();
  }

  void _refresh() { if (mounted) setState(() {}); }

  Future<void> _loadData() async {
    setState(() => _dataLoading = true);
    await Future.wait([
      _progress.load(),
      ScanHistory.instance.load(),
    ]);
    if (mounted) setState(() => _dataLoading = false);
  }

  @override
  void dispose() {
    _progress.removeListener(_refresh);
    ScanHistory.instance.removeListener(_refresh);
    _countdownTimer?.cancel();
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  // ── Rep-tracking helpers (delegate to service) ────────────────────────────

  /// Exercise name at [idx] inside [routineTitle].
  String? _exName(String routineTitle, int idx) {
    final r = _routines.firstWhere(
      (r) => r['title'] == routineTitle,
      orElse: () => <String, dynamic>{},
    );
    final list = r['exercises'] as List<dynamic>? ?? [];
    return idx < list.length ? list[idx] as String : null;
  }

  int _getRepsByIdx(String routineTitle, int idx) {
    final name = _exName(routineTitle, idx);
    if (name == null) return 0;
    return _progress.getReps('manual', name, routineTitle: routineTitle);
  }

  bool _isDoneByIdx(String routineTitle, int idx) {
    final name = _exName(routineTitle, idx);
    if (name == null) return false;
    return _progress.isDone('manual', name, _manualTarget, routineTitle: routineTitle);
  }

  void _addRepByIdx(String routineTitle, int idx) {
    final name = _exName(routineTitle, idx);
    if (name == null) return;
    _progress.addRep(
      source: 'manual',
      exerciseName: name,
      targetReps: _manualTarget,
      routineTitle: routineTitle,
    );
  }

  int _completedInRoutine(String routineTitle) {
    final r = _routines.firstWhere(
      (r) => r['title'] == routineTitle,
      orElse: () => <String, dynamic>{},
    );
    final list = (r['exercises'] as List<dynamic>? ?? []).cast<String>();
    return _progress.completedInRoutine(routineTitle, list, _manualTarget);
  }

  // ── Timer helpers ─────────────────────────────────────────────────────────
  int _parseDuration(String d) => (int.tryParse(d.trim().split(' ')[0]) ?? 1) * 60;

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _timerRunning = true);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timerRemaining <= 1) {
        _countdownTimer?.cancel();
        HapticFeedback.heavyImpact();
        setState(() { _timerRunning = false; _timerRemaining = 0; });
      } else {
        setState(() => _timerRemaining--);
        if (_timerRemaining <= 3) HapticFeedback.lightImpact();
      }
    });
  }

  void _pauseCountdown() { _countdownTimer?.cancel(); setState(() => _timerRunning = false); }
  void _resetCountdown()  { _countdownTimer?.cancel(); setState(() { _timerRunning = false; _timerRemaining = _timerTotalSeconds; }); }

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() => _stopwatchRunning = true);
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _stopwatchElapsed++));
  }
  void _pauseStopwatch() { _stopwatchTimer?.cancel(); setState(() => _stopwatchRunning = false); }
  void _resetStopwatch()  { _stopwatchTimer?.cancel(); setState(() { _stopwatchRunning = false; _stopwatchElapsed = 0; }); }

  double get _timerProgress => _timerTotalSeconds == 0 ? 1 : _timerRemaining / _timerTotalSeconds;

  void _onStartRoutine(Map<String, dynamic> r) {
    final secs = _parseDuration(r['duration'] as String);
    _countdownTimer?.cancel();
    setState(() { _timerTotalSeconds = secs; _timerRemaining = secs; _selectedPreset = secs; _timerRunning = false; });
    _showTimerSheet(autoStart: true);
  }

  Future<void> _openVideo(Map<String, dynamic> video) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=${video['id']}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open YouTube')));
    }
  }

  void _showTimerSheet({bool autoStart = false}) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _TimerStopwatchSheet(
        timerRemaining: _timerRemaining, timerTotal: _timerTotalSeconds,
        timerRunning: _timerRunning, selectedPreset: _selectedPreset,
        stopwatchElapsed: _stopwatchElapsed, stopwatchRunning: _stopwatchRunning,
        timerProgress: _timerProgress, autoStart: autoStart,
        onPresetSelected: (secs) {
          setState(() { _selectedPreset = secs; _timerTotalSeconds = secs; _timerRemaining = secs; _timerRunning = false; });
          _countdownTimer?.cancel();
        },
        onTimerStart: _startCountdown, onTimerPause: _pauseCountdown, onTimerReset: _resetCountdown,
        onSwStart: _startStopwatch,    onSwPause:  _pauseStopwatch,  onSwReset:  _resetStopwatch,
      ),
    );
  }

  // ── See-all: Routines ─────────────────────────────────────────────────────
  // Uses ValueNotifier + ListenableBuilder so both card expansion AND rep
  // updates (from the service) trigger a rebuild correctly.
  void _showAllRoutines() {
    final expandedTitle = ValueNotifier<String?>(null);

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92, maxChildSize: 0.96, minChildSize: 0.5, expand: false,
        builder: (ctx, sc) => Container(
          decoration: const BoxDecoration(color: _surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            const SizedBox(height: 12), _drag(), const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('All Routines', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textPrimary, letterSpacing: -0.3)),
                Text('${_routines.length} routines · all levels', style: const TextStyle(fontSize: 13, color: _textMuted)),
              ])),
              _closeBtn(ctx),
            ])),
            Divider(height: 1, color: Colors.grey.withOpacity(0.12)),
            Expanded(
              child: ListenableBuilder(
                listenable: Listenable.merge([_progress, expandedTitle]),
                builder: (_, __) => ListView.builder(
                  controller: sc,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: _routines.length,
                  itemBuilder: (_, i) {
                    final routine = _routines[i];
                    final title   = routine['title'] as String;
                    return _RoutineCard(
                      routine: routine,
                      isExpanded: expandedTitle.value == title,
                      onToggle: () => expandedTitle.value = expandedTitle.value == title ? null : title,
                      getReps: _getRepsByIdx,
                      isDone:  _isDoneByIdx,
                      onAddRep: _addRepByIdx,
                      onReset: (t) => _progress.resetRoutine(t),
                      completedCount: _completedInRoutine(title),
                      onStart: () { Navigator.pop(ctx); _onStartRoutine(routine); },
                    );
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── See-all: Videos ───────────────────────────────────────────────────────
  void _showAllVideos() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92, maxChildSize: 0.96, minChildSize: 0.5, expand: false,
        builder: (ctx, sc) => Container(
          decoration: const BoxDecoration(color: _surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            const SizedBox(height: 12), _drag(), const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('All Videos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textPrimary, letterSpacing: -0.3)),
                Text('${_videos.length} guided sessions', style: const TextStyle(fontSize: 13, color: _textMuted)),
              ])),
              _closeBtn(ctx),
            ])),
            Divider(height: 1, color: Colors.grey.withOpacity(0.12)),
            Expanded(child: ListView.builder(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: _videos.length,
              itemBuilder: (_, i) => _videoListTile(_videos[i], ctx),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _videoListTile(Map<String, dynamic> video, BuildContext sheetCtx) {
    final id       = video['id']       as String;
    final tag      = video['tag']      as String;
    final tagColor = video['tagColor'] as Color;
    final thumb    = 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    return GestureDetector(
      onTap: () { Navigator.pop(sheetCtx); _openVideo(video); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(children: [
          ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Stack(children: [
              Image.network(thumb, width: 110, height: 80, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 110, height: 80, color: _rose.withOpacity(0.12),
                      child: const Center(child: Icon(Icons.play_circle_fill_rounded, size: 28, color: _rose)))),
              Container(width: 110, height: 80, color: Colors.black.withOpacity(0.18),
                  child: const Center(child: Icon(Icons.play_circle_fill_rounded, size: 30, color: Colors.white))),
              Positioned(bottom: 6, right: 6, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), borderRadius: BorderRadius.circular(4)),
                child: Text(video['duration'] as String, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)))),
              Positioned(top: 6, left: 6, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.85), borderRadius: BorderRadius.circular(4)),
                child: const Text('▶ YouTube', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700)))),
            ])),
          Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 10), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: tagColor.withOpacity(0.13), borderRadius: BorderRadius.circular(5)),
                child: Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: tagColor))),
              const SizedBox(height: 5),
              Text(video['title'] as String, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textPrimary, height: 1.3)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.play_circle_outline_rounded, size: 11, color: _textMuted),
                const SizedBox(width: 3),
                Expanded(child: Text(video['channel'] as String, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: _textMuted))),
              ]),
            ]))),
        ]),
      ),
    );
  }

  Widget _drag() => Container(width: 40, height: 4,
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)));

  Widget _closeBtn(BuildContext ctx) => GestureDetector(
    onTap: () => Navigator.pop(ctx),
    child: Container(padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
      child: const Icon(Icons.close_rounded, size: 18, color: _textPrimary)));

  // ═════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTimerSheet,
        backgroundColor: _rose, foregroundColor: Colors.white, elevation: 6,
        icon: const Icon(Icons.timer_rounded, size: 20),
        label: const Text('Timer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildLevelFilter()),
          SliverToBoxAdapter(child: _buildSectionHeader('Routines', onTap: _showAllRoutines)),
          SliverToBoxAdapter(child: _buildRoutinesList()),
          SliverToBoxAdapter(child: _buildAiSection()),       // below routines
          SliverToBoxAdapter(child: _buildVideosSection()),
          SliverToBoxAdapter(child: _buildTipsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ── Sliver app bar ────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) => SliverAppBar(
    expandedHeight: 220, pinned: true, backgroundColor: _surface,
    leading: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _textPrimary))),
    flexibleSpace: FlexibleSpaceBar(background: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [Color(0xFFF0FFF4), Color(0xFFFDF7FA)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF7EC4A4).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: const Text('🧘 FACE YOGA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4A9A7A), letterSpacing: 1.2))),
          const SizedBox(height: 6),
          const Text('Tone and Lift With\nDaily Routines',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _textPrimary, height: 1.2, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text('Natural facelift through targeted exercises', style: TextStyle(fontSize: 13, color: _textMuted)),
        ]),
      )),
    )),
  );

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() => Container(
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFE96A85), Color(0xFFD44E80)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: _rose.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6))]),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _stats.map((s) => Column(children: [
        Icon(s['icon'] as IconData, color: Colors.white70, size: 20), const SizedBox(height: 4),
        Text(s['value'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(s['label'] as String, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ])).toList()),
  );

  // ── AI plan timer — starts countdown equal to sum of all exercise durations ──
  void _onStartAiPlan(List<FacialYogaExercise> exercises) {
    final totalSecs = exercises.fold(0, (sum, ex) => sum + ex.durationSeconds);
    _countdownTimer?.cancel();
    setState(() {
      _timerTotalSeconds = totalSecs;
      _timerRemaining    = totalSecs;
      _selectedPreset    = totalSecs;
      _timerRunning      = false;
    });
    _showTimerSheet(autoStart: true);
  }

  /// Formats seconds → "5 min", "2m 30s", "45s"
  String _formatAiDuration(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '$m min';
    return '${m}m ${s}s';
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // AI RECOMMENDED SECTION
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildAiSection() {
    // Show spinner only on first load when we have no data yet.
    if (_dataLoading && ScanHistory.instance.records.isEmpty) {
      return _aiLoadingCard();
    }

    final records = ScanHistory.instance.records;

    // No scan taken yet.
    if (records.isEmpty) return _aiEmptyCard();

    final scan      = records.first;
    final exercises = scan.result.recommendations.facialYoga;

    // Scan exists but the AI returned no yoga data.
    if (exercises.isEmpty) return const SizedBox.shrink();

    final totalSecs = exercises.fold(0, (sum, ex) => sum + ex.durationSeconds);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Section header ──────────────────────────────────────────────────
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_rose, _orchid]),
                borderRadius: BorderRadius.circular(6)),
              child: const Text('✨ AI PERSONALISED', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
          ]),
          const SizedBox(height: 4),
          const Text('Your Skin Analysis Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary, letterSpacing: -0.2)),
          const SizedBox(height: 2),
          Text(_scanDateLabel(scan.scannedAt),
              style: const TextStyle(fontSize: 11, color: _textMuted)),
        ])),
      ])),

      // ── Exercise cards + Start button ───────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Column(children: [
          ...exercises.asMap().entries
              .map((e) => _buildAiExerciseCard(e.value, e.key, scan.id)),

          // ── Start Full Plan button (same style as routine cards) ────────
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _onStartAiPlan(exercises),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE96A85), _orchid],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(
                    color: _rose.withOpacity(0.38),
                    blurRadius: 12,
                    offset: const Offset(0, 5))]),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Start Full Plan  •  ${_formatAiDuration(totalSecs)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ])),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    ]);
  }

  Widget _buildAiExerciseCard(FacialYogaExercise ex, int index, String scanId) {
    final isExpanded = _expandedAiEx == ex.name;
    final reps       = _progress.getReps('ai_recommended', ex.name);
    final done       = reps >= ex.reps;

    return GestureDetector(
      onTap: () => setState(() => _expandedAiEx = isExpanded ? null : ex.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card, borderRadius: BorderRadius.circular(18),
          border: isExpanded ? Border.all(color: _orchid.withOpacity(0.4), width: 1.5) : null,
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: isExpanded ? 16 : 10,
              offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          // ── Header row ────────────────────────────────────────────────
          Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            // Numbered badge
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_rose, _orchid],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text('${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)))),
            const SizedBox(width: 12),

            // Name + metadata
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ex.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 11, color: _orchidDark),
                const SizedBox(width: 3),
                Flexible(child: Text(ex.targetArea,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: _orchidDark, fontWeight: FontWeight.w600))),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF0E8F8), borderRadius: BorderRadius.circular(5)),
                  child: Text(_fmtDuration(ex.durationSeconds),
                      style: TextStyle(fontSize: 9, color: _orchidDark, fontWeight: FontWeight.w600))),
              ]),
            ])),

            // Rep counter — tap adds one rep (saved to DB immediately).
            GestureDetector(
              onTap: () {
                if (done) return;
                _progress.addRep(
                  source: 'ai_recommended',
                  exerciseName: ex.name,
                  targetReps: ex.reps,
                  scanId: scanId,
                  targetArea: ex.targetArea,
                );
              },
              // Prevent this tap from bubbling up to the card expansion.
              behavior: HitTestBehavior.opaque,
              child: _RepCounter(count: reps, target: ex.reps, accent: _rose),
            ),
            const SizedBox(width: 4),
            Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: _textMuted),
          ])),

          // ── Expanded detail ───────────────────────────────────────────
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
            Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 16), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Benefit
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F0FF),
                    borderRadius: BorderRadius.circular(12)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('💡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ex.benefit,
                        style: TextStyle(
                            fontSize: 12,
                            color: _textPrimary.withOpacity(0.8),
                            height: 1.5,
                            fontStyle: FontStyle.italic))),
                  ])),
                const SizedBox(height: 12),

                // How-to steps
                const Text('How To:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textPrimary)),
                const SizedBox(height: 8),
                _buildHowToSteps(ex.howTo),

                // Reps goal reminder
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _rose.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _rose.withOpacity(0.15))),
                  child: Row(children: [
                    Icon(Icons.repeat_rounded, size: 14, color: _rose),
                    const SizedBox(width: 8),
                    Text('Target: ${ex.reps} reps  ·  tap the counter to track each one',
                        style: TextStyle(fontSize: 11, color: _rose.withOpacity(0.85), fontWeight: FontWeight.w600)),
                  ])),
              ])),
          ],
        ]),
      ),
    );
  }

  /// Parse the AI's how-to string (numbered or newline-separated) into steps.
  Widget _buildHowToSteps(String howTo) {
    final lines = howTo
        .trim()
        .split(RegExp(r'\n|(?=\d+\.\s)'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.asMap().entries.map((e) {
        final text = e.value.replaceAll(RegExp(r'^\d+\.\s*'), '');
        return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 22, height: 22,
              decoration: BoxDecoration(color: _orchid.withOpacity(0.15), shape: BoxShape.circle),
              child: Center(child: Text('${e.key + 1}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _orchid)))),
            const SizedBox(width: 8),
            Expanded(child: Text(text,
                style: TextStyle(fontSize: 12.5, color: _textPrimary.withOpacity(0.85), height: 1.5))),
          ]));
      }).toList());
  }

  String _scanDateLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'from today\'s scan';
    if (diff.inDays == 1) return 'from yesterday\'s scan';
    return 'from scan on ${dt.day}/${dt.month}/${dt.year}';
  }

  String _fmtDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '${m}m${s > 0 ? ' ${s}s' : ''}';
    return '${s}s';
  }

  Widget _aiLoadingCard() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(children: [
        SizedBox(width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(_rose))),
        const SizedBox(width: 14),
        const Text('Loading your personalised exercises…',
            style: TextStyle(fontSize: 13, color: _textMuted)),
      ]),
    ),
  );

  Widget _aiEmptyCard() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_rose.withOpacity(0.05), _orchid.withOpacity(0.08)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _orchid.withOpacity(0.2))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _orchid.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.face_retouching_natural_rounded, color: _orchidDark, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('No skin scan yet',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textPrimary)),
          const SizedBox(height: 2),
          Text('Take a skin analysis to unlock AI-personalised yoga exercises tailored to your face.',
              style: TextStyle(fontSize: 11.5, color: _textMuted, height: 1.4)),
        ])),
      ]),
    ),
  );

  // ═════════════════════════════════════════════════════════════════════════════
  // LEVEL FILTER  /  SECTION HEADER  /  ROUTINES LIST
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildLevelFilter() => SizedBox(
    height: 50,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: _levels.length,
      itemBuilder: (_, i) {
        final active = _selectedLevel == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedLevel = i),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: active ? const LinearGradient(colors: [_rose, _orchid]) : null,
              color: active ? null : _card, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(
                  color: active ? _rose.withOpacity(0.25) : Colors.black.withOpacity(0.05),
                  blurRadius: 8, offset: const Offset(0, 3))]),
            child: Text(_levels[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: active ? Colors.white : _textMuted))));
      },
    ),
  );

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
          color: _textPrimary, letterSpacing: -0.2)),
      if (onTap != null)
        GestureDetector(onTap: onTap, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: _orchid.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('See all', style: TextStyle(fontSize: 13, color: _orchidDark, fontWeight: FontWeight.w700)),
            const SizedBox(width: 3),
            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: _orchidDark),
          ]),
        )),
    ]),
  );

  Widget _buildRoutinesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: _filteredRoutines.map((routine) {
        final title = routine['title'] as String;
        return _RoutineCard(
          routine: routine,
          isExpanded: _activeRoutine == title,
          onToggle: () => setState(() => _activeRoutine = _activeRoutine == title ? null : title),
          getReps: _getRepsByIdx,
          isDone:  _isDoneByIdx,
          onAddRep: _addRepByIdx,
          onReset: (t) => _progress.resetRoutine(t),
          completedCount: _completedInRoutine(title),
          onStart: () => _onStartRoutine(routine),
        );
      }).toList()),
    );
  }

  Widget _pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
        color: color == _textMuted ? _textMuted : color)));

  // ── Videos section ────────────────────────────────────────────────────────
  Widget _buildVideosSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildSectionHeader('Watch and Learn', onTap: _showAllVideos),
    SizedBox(height: 224, child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      itemCount: _videos.length,
      itemBuilder: (_, i) => _buildVideoCard(_videos[i]),
    )),
  ]);

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final id = video['id'] as String; final tag = video['tag'] as String;
    final tagColor = video['tagColor'] as Color;
    final thumb = 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    return GestureDetector(
      onTap: () => _openVideo(video),
      child: Container(
        width: 200, margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(thumb, width: 200, height: 120, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 200, height: 120,
                    decoration: BoxDecoration(color: _rose.withOpacity(0.12), borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
                    child: const Center(child: Icon(Icons.play_circle_fill_rounded, size: 40, color: _rose))))),
            Positioned.fill(child: Container(
              decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)), color: Colors.black.withOpacity(0.20)),
              child: const Center(child: Icon(Icons.play_circle_fill_rounded, size: 44, color: Colors.white)))),
            Positioned(bottom: 8, right: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), borderRadius: BorderRadius.circular(6)),
              child: Text(video['duration'] as String, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)))),
            Positioned(top: 8, left: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.85), borderRadius: BorderRadius.circular(6)),
              child: const Text('▶ YouTube', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)))),
          ]),
          Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: tagColor.withOpacity(0.13), borderRadius: BorderRadius.circular(5)),
              child: Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: tagColor))),
            const SizedBox(height: 5),
            Text(video['title'] as String, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textPrimary, height: 1.3)),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.play_circle_outline_rounded, size: 11, color: _textMuted), const SizedBox(width: 3),
              Expanded(child: Text(video['channel'] as String, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: _textMuted))),
            ]),
          ])),
        ]),
      ),
    );
  }

  // ── Tips section ──────────────────────────────────────────────────────────
  Widget _buildTipsSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildSectionHeader('Pro Tips'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: _tips.map((tip) =>
      Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _orchid.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(tip['icon'] as IconData, size: 18, color: _orchidDark)),
          const SizedBox(width: 12),
          Expanded(child: Text(tip['tip'] as String, style: const TextStyle(fontSize: 13, color: _textPrimary, height: 1.4))),
        ])),
    ).toList())),
  ]);
}

// ═════════════════════════════════════════════════════════════════════════════
// ROUTINE CARD
// ═════════════════════════════════════════════════════════════════════════════
class _RoutineCard extends StatelessWidget {
  static const Color _card        = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);
  static const Color _green       = Color(0xFF4A9A7A);
  static const Color _greenBg     = Color(0xFF7EC4A4);
  static const int   _target      = 14;

  final Map<String, dynamic> routine;
  final bool isExpanded;
  final int  completedCount;
  final int  Function(String, int)  getReps;
  final bool Function(String, int)  isDone;
  final VoidCallback                onToggle;
  final void Function(String, int)  onAddRep;
  final void Function(String)       onReset;
  final VoidCallback                onStart;

  const _RoutineCard({
    required this.routine, required this.isExpanded, required this.completedCount,
    required this.getReps, required this.isDone,
    required this.onToggle, required this.onAddRep, required this.onReset, required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final title   = routine['title']  as String;
    final exList  = routine['exercises'] as List;
    final accent  = routine['accent'] as Color;
    final total   = exList.length;
    final allDone = completedCount == total && total > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(18),
        border: isExpanded ? Border.all(color: accent.withOpacity(0.3), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: isExpanded ? 16 : 10, offset: const Offset(0, 4))]),
      child: Column(children: [
        // ── Header ──────────────────────────────────────────────────────
        GestureDetector(
          onTap: onToggle,
          child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
            Row(children: [
              Container(width: 52, height: 52,
                decoration: BoxDecoration(color: routine['color'] as Color, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(routine['emoji'] as String, style: const TextStyle(fontSize: 24)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary))),
                  if (allDone)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: _greenBg.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: const Text('✓ Done', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _green))),
                ]),
                const SizedBox(height: 3),
                Text(routine['desc'] as String, style: const TextStyle(fontSize: 11.5, color: _textMuted), maxLines: 2),
                const SizedBox(height: 6),
                Row(children: [
                  _pill('⏱ ${routine['duration']}', accent),
                  const SizedBox(width: 6), _pill('${routine['moves']} moves', _textMuted),
                  const SizedBox(width: 6), _pill(routine['level'] as String, accent),
                ]),
              ])),
              Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: _textMuted),
            ]),
            // Progress bar — visible once at least one rep is logged
            if (completedCount > 0 || _anyStarted(title, total)) ...[
              const SizedBox(height: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : completedCount / total,
                    minHeight: 5,
                    backgroundColor: accent.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(accent))),
                const SizedBox(height: 4),
                Text('$completedCount / $total exercises completed',
                    style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.w600)),
              ]),
            ],
          ])),
        ),

        // ── Expanded exercises ───────────────────────────────────────────
        if (isExpanded) ...[
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('EXERCISES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textMuted, letterSpacing: 0.8)),
                const Spacer(),
                GestureDetector(
                  onTap: () => onReset(title),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Reset all', style: TextStyle(fontSize: 11, color: _textMuted, fontWeight: FontWeight.w600)))),
              ]),
              const SizedBox(height: 12),
              ...exList.asMap().entries.map((e) {
                final idx  = e.key;
                final name = e.value as String;
                final reps = getReps(title, idx);
                final done = isDone(title, idx);
                return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
                  // Status dot
                  Container(width: 8, height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: done ? _green : (reps > 0 ? accent : Colors.grey.withOpacity(0.3)))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(name, style: TextStyle(
                      fontSize: 13,
                      color: done ? _textMuted : _textPrimary,
                      decoration: done ? TextDecoration.lineThrough : null))),
                  const SizedBox(width: 8),
                  // Tap counter
                  GestureDetector(
                    onTap: done ? null : () => onAddRep(title, idx),
                    child: _RepCounter(count: reps, target: _target, accent: accent)),
                ]));
              }),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onStart,
                child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent, accent.withOpacity(0.75)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: accent.withOpacity(0.38), blurRadius: 12, offset: const Offset(0, 5))]),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Start Routine  •  ${routine['duration']}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ]))),
            ])),
        ],
      ]),
    );
  }

  bool _anyStarted(String title, int total) {
    for (int i = 0; i < total; i++) { if (getReps(title, i) > 0) return true; }
    return false;
  }

  static Widget _pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
        color: color == _textMuted ? _textMuted : color)));
}

// ═════════════════════════════════════════════════════════════════════════════
// REP COUNTER  — tap pill to count up, turns green when done
// ═════════════════════════════════════════════════════════════════════════════
class _RepCounter extends StatelessWidget {
  static const Color _green = Color(0xFF4A9A7A);
  final int   count, target;
  final Color accent;

  const _RepCounter({required this.count, required this.target, required this.accent});

  @override
  Widget build(BuildContext context) {
    final done = count >= target;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: done ? _green.withOpacity(0.12) : accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: done ? _green.withOpacity(0.4) : accent.withOpacity(0.3),
            width: 1.2)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (!done) Icon(Icons.add_rounded, size: 13, color: accent),
        if (!done) const SizedBox(width: 3),
        Text(
          done ? '✓ $target' : '$count / $target',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: done ? _green : accent)),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TIMER & STOPWATCH SHEET  (unchanged)
// ═════════════════════════════════════════════════════════════════════════════
class _TimerStopwatchSheet extends StatefulWidget {
  final int timerRemaining, timerTotal, selectedPreset, stopwatchElapsed;
  final bool timerRunning, stopwatchRunning, autoStart;
  final double timerProgress;
  final void Function(int) onPresetSelected;
  final VoidCallback onTimerStart, onTimerPause, onTimerReset, onSwStart, onSwPause, onSwReset;

  const _TimerStopwatchSheet({
    required this.timerRemaining, required this.timerTotal, required this.timerRunning,
    required this.selectedPreset, required this.stopwatchElapsed, required this.stopwatchRunning,
    required this.timerProgress, required this.onPresetSelected, required this.onTimerStart,
    required this.onTimerPause, required this.onTimerReset, required this.onSwStart,
    required this.onSwPause, required this.onSwReset, this.autoStart = false,
  });
  @override State<_TimerStopwatchSheet> createState() => _TimerStopwatchSheetState();
}

class _TimerStopwatchSheetState extends State<_TimerStopwatchSheet>
    with SingleTickerProviderStateMixin {
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  late TabController _tab;
  late int _timerRemaining, _stopwatchElapsed, _selectedPreset;
  late bool _timerRunning, _stopwatchRunning;
  late double _timerProgress;
  Timer? _localCountdown, _localStopwatch;

  final List<Map<String, dynamic>> _presets = [
    {'label': '30 s',  'secs': 30},  {'label': '1 min',  'secs': 60},
    {'label': '3 min', 'secs': 180}, {'label': '5 min',  'secs': 300},
    {'label': '6 min', 'secs': 360}, {'label': '7 min',  'secs': 420},
    {'label': '8 min', 'secs': 480}, {'label': '10 min', 'secs': 600},
    {'label': '15 min','secs': 900},
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _timerRemaining   = widget.timerRemaining;  _timerRunning     = widget.timerRunning;
    _stopwatchElapsed = widget.stopwatchElapsed; _stopwatchRunning = widget.stopwatchRunning;
    _selectedPreset   = widget.selectedPreset;  _timerProgress    = widget.timerProgress;
    if (_timerRunning)     _startLocal();
    if (_stopwatchRunning) _startLocalSw();
    if (widget.autoStart && !_timerRunning && _timerRemaining > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTimerStart(); setState(() => _timerRunning = true); _startLocal();
      });
    }
  }

  void _startLocal() {
    _localCountdown?.cancel();
    _localCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timerRemaining <= 1) {
        _localCountdown?.cancel(); HapticFeedback.heavyImpact();
        setState(() { _timerRunning = false; _timerRemaining = 0; _timerProgress = 0; });
        widget.onTimerPause();
      } else {
        setState(() { _timerRemaining--; _timerProgress = _selectedPreset > 0 ? _timerRemaining / _selectedPreset : 0; });
        if (_timerRemaining <= 3) HapticFeedback.lightImpact();
      }
    });
  }

  void _startLocalSw() {
    _localStopwatch?.cancel();
    _localStopwatch = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _stopwatchElapsed++));
  }

  @override
  void dispose() { _tab.dispose(); _localCountdown?.cancel(); _localStopwatch?.cancel(); super.dispose(); }

  String _fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: _surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 12),
      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 16),
      Container(margin: const EdgeInsets.symmetric(horizontal: 24), padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: TabBar(controller: _tab,
          indicator: BoxDecoration(color: _rose, borderRadius: BorderRadius.circular(10)),
          indicatorSize: TabBarIndicatorSize.tab, dividerColor: Colors.transparent,
          labelColor: Colors.white, unselectedLabelColor: _textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [Tab(text: '⏱  Timer'), Tab(text: '🕐  Stopwatch')])),
      const SizedBox(height: 20),
      SizedBox(height: 400, child: TabBarView(controller: _tab, children: [_timerTab(), _swTab()])),
    ]),
  );

  Widget _timerTab() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(children: [
      SizedBox(width: 160, height: 160, child: Stack(alignment: Alignment.center, children: [
        SizedBox.expand(child: CircularProgressIndicator(value: _timerProgress, strokeWidth: 9,
          backgroundColor: Colors.grey.withOpacity(0.12),
          valueColor: AlwaysStoppedAnimation<Color>(_timerRemaining > 0 ? _rose : Colors.grey),
          strokeCap: StrokeCap.round)),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_fmt(_timerRemaining), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: _textPrimary, letterSpacing: -1)),
          const SizedBox(height: 2),
          AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(
            _timerRunning ? '● Running...' : (_timerRemaining == 0 ? '✓ Done!' : 'Ready'),
            key: ValueKey(_timerRunning),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _timerRunning ? _rose : _textMuted))),
        ]),
      ])),
      const SizedBox(height: 20),
      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: _presets.map((p) {
        final active = _selectedPreset == (p['secs'] as int);
        return GestureDetector(
          onTap: () {
            if (_timerRunning) return;
            _localCountdown?.cancel();
            final secs = p['secs'] as int;
            widget.onPresetSelected(secs);
            setState(() { _selectedPreset = secs; _timerRemaining = secs; _timerRunning = false; _timerProgress = 1.0; });
          },
          child: AnimatedContainer(duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? _rose : Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: active ? _rose.withOpacity(0.3) : Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Text(p['label'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : _textMuted))));
      }).toList()),
      const SizedBox(height: 22),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _iconBtn(Icons.refresh_rounded, () {
          _localCountdown?.cancel(); widget.onTimerReset();
          setState(() { _timerRunning = false; _timerRemaining = _selectedPreset; _timerProgress = 1.0; });
        }),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            if (_timerRemaining == 0) return;
            if (_timerRunning) { _localCountdown?.cancel(); widget.onTimerPause(); setState(() => _timerRunning = false); }
            else { widget.onTimerStart(); setState(() => _timerRunning = true); _startLocal(); }
          },
          child: _bigBtn(_timerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded)),
      ]),
    ]),
  );

  Widget _swTab() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFF0F5), Color(0xFFFDF7FA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: _rose.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))]),
        child: Column(children: [
          Text(_fmt(_stopwatchElapsed), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: _textPrimary, letterSpacing: -2, fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(height: 6),
          AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(
            _stopwatchRunning ? '● Recording time' : 'Paused',
            key: ValueKey(_stopwatchRunning),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _stopwatchRunning ? _rose : _textMuted))),
        ])),
      const SizedBox(height: 30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _iconBtn(Icons.refresh_rounded, () {
          _localStopwatch?.cancel(); widget.onSwReset();
          setState(() { _stopwatchRunning = false; _stopwatchElapsed = 0; });
        }),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            if (_stopwatchRunning) { _localStopwatch?.cancel(); widget.onSwPause(); setState(() => _stopwatchRunning = false); }
            else { widget.onSwStart(); setState(() => _stopwatchRunning = true); _startLocalSw(); }
          },
          child: _bigBtn(_stopwatchRunning ? Icons.pause_rounded : Icons.play_arrow_rounded)),
      ]),
    ]),
  );

  Widget _bigBtn(IconData icon) => Container(width: 68, height: 68,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFE96A85), Color(0xFFD44E80)]), shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: _rose.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
    child: Icon(icon, color: Colors.white, size: 34));

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(width: 50, height: 50,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Icon(icon, color: _textMuted, size: 22)));
}