// lib/screens/skin_report_page.dart

import 'package:flutter/material.dart';
import 'dart:io';
import '../services/skin_analysis_service.dart';
import '../services/scan_history.dart';
import '../interface/homepage.dart';
import '../interface/analytics_page.dart';

class SkinReportPage extends StatefulWidget {
  final SkinAnalysisResult result;
  final String imagePath;

  /// Set to TRUE only when coming directly from the camera capture.
  /// Set to FALSE (default) when re-opening an existing record from Analytics.
  final bool isNewScan;

  const SkinReportPage({
    super.key,
    required this.result,
    required this.imagePath,
    this.isNewScan = true,
  });

  @override
  State<SkinReportPage> createState() => _SkinReportPageState();
}

class _SkinReportPageState extends State<SkinReportPage> {
  // ── Colour tokens ─────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);
  static const Color _cardBg      = Colors.white;

  // ── State ─────────────────────────────────────────────────────────────────
  bool? _feedbackSubmitted;
  int _selectedPlanTab = 0;   // 0 = Skincare, 1 = Facial Yoga, 2 = Wellness
  bool _showMorning = true;   // Skincare tab: AM vs PM toggle
  int? _expandedYogaIndex;    // Which yoga card is expanded

  @override
  void initState() {
    super.initState();
    if (widget.isNewScan) {
      ScanHistory.instance.add(widget.result, widget.imagePath);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _submitFeedback(bool isPositive) {
    setState(() => _feedbackSubmitted = isPositive);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPositive
            ? 'Thank you for your positive feedback!'
            : "Thank you! We'll work to improve our analysis."),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        backgroundColor: isPositive ? const Color(0xFF5BB87A) : _rose,
      ),
    );
  }

  Color _concernColor(int score) {
    if (score < 20) return const Color(0xFFB5D5B5);
    if (score < 50) return const Color(0xFFD4E8A8);
    if (score < 75) return const Color(0xFFE8C97A);
    return const Color(0xFFE88A6A);
  }

  Widget _imageWidget({double? width, double? height, BoxFit fit = BoxFit.cover}) {
  final path = widget.imagePath;

  if (path.isEmpty) {
    return _imageFallback(width, height);
  }

  // Remote URL (Supabase Storage)
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      // Add cache headers so it doesn't re-fetch on every rebuild
      headers: const {'Cache-Control': 'max-age=3600'},
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: _orchid.withOpacity(0.08),
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_orchid),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _imageFallback(width, height),
    );
  }

    final file = File(path);
      return Image.file(
    file,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => _imageFallback(width, height),
  );
}

  Widget _imageFallback(double? width, double? height) => Container(
        width: width, height: height,
        color: _orchid.withOpacity(0.08),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.broken_image_outlined, color: _orchid.withOpacity(0.5), size: 36),
          const SizedBox(height: 6),
          Text("Image unavailable",
              style: TextStyle(fontSize: 11, color: _textMuted)),
        ]),
      );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(children: [
                _buildSubtitle(),
                const SizedBox(height: 20),
                _buildPhotoCircle(),
                const SizedBox(height: 20),
                _buildSummaryCard(),
                const SizedBox(height: 16),
                _buildScoreBar(),
                const SizedBox(height: 20),
                _buildDetailedScores(),
                const SizedBox(height: 28),

                // ── NEW: Personalized Plan ─────────────────────────────────
                if (!widget.result.recommendations.isEmpty) ...[
                  _buildPersonalizedPlan(),
                  const SizedBox(height: 28),
                ],

                _buildButtons(context),
                const SizedBox(height: 16),
                _buildFeedbackWidget(),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
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
      child: Row(children: [
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
          child: Text("Skin Report",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: -0.3)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 14),
            const SizedBox(width: 5),
            Text(widget.isNewScan ? "Saved" : "History",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSubtitle() => Text(
        'AI-driven analysis reveals your skin health',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: _textMuted, height: 1.4),
      );

  // ── Photo circle ──────────────────────────────────────────────────────────
  Widget _buildPhotoCircle() {
    return Stack(alignment: Alignment.bottomRight, children: [
      Container(
        width: 200, height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
              colors: [_rose, _orchid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: _orchid.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          padding: const EdgeInsets.all(3),
          child: ClipOval(child: _imageWidget(fit: BoxFit.cover)),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: const Icon(Icons.zoom_in_rounded, size: 20, color: Color(0xFF1C1224)),
      ),
    ]);
  }

  // ── Summary card ──────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFE96A85), _orchid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: _orchid.withOpacity(0.3), blurRadius: 18,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _summaryItem('${widget.result.skinAge}', 'Skin Age'),
        _vDivider(),
        _summaryItem(widget.result.faceShape, 'Face Shape', small: true),
        _vDivider(),
        _summaryItem('${widget.result.overallScore}', 'Overall Score'),
      ]),
    );
  }

  Widget _vDivider() => Container(
      width: 1, height: 40, color: Colors.white.withOpacity(0.3));

  Widget _summaryItem(String value, String label, {bool small = false}) =>
      Column(children: [
        Text(value,
            style: TextStyle(
                fontSize: small ? 20 : 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500)),
      ]);

  // ── Score bar ─────────────────────────────────────────────────────────────
  Widget _buildScoreBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Perfect',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13,
                  color: Color(0xFF5BB87A))),
          Text('Concerns',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13,
                  color: Color(0xFFE05A5A))),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 44,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xFF5BB87A),
                Color(0xFFD4C97A),
                Color(0xFFE8956A),
              ]),
            ),
            child: Stack(children: [
              Align(
                alignment:
                    Alignment((widget.result.overallScore / 50) - 1.0, 0),
                child: Container(
                  width: 3,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 6),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('0', style: TextStyle(color: Color(0xFF9E8DA8), fontSize: 12)),
          Text('100', style: TextStyle(color: Color(0xFF9E8DA8), fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        Text(widget.result.summary,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF9E8DA8), height: 1.4)),
      ]),
    );
  }

  // ── Detailed concern cards ────────────────────────────────────────────────
  Widget _buildDetailedScores() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Detailed Score',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: Color(0xFF1C1224))),
      const SizedBox(height: 12),
      SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.result.concerns.length,
          itemBuilder: (context, i) =>
              _buildConcernCard(widget.result.concerns[i]),
        ),
      ),
    ]);
  }

  Widget _buildConcernCard(SkinConcern concern) {
    return Container(
      width: 108,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _concernColor(concern.score),
          borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${concern.score}',
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.w800,
                color: Colors.black87)),
        const SizedBox(height: 8),
        Text(concern.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: Colors.black87)),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── PERSONALIZED PLAN SECTION ─────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPersonalizedPlan() {
    final recs = widget.result.recommendations;
    final tabs = ['✨ Skincare', '🧘 Facial Yoga', '🌿 Wellness'];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Section heading
      Row(children: [
        Container(
          width: 4, height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_rose, _orchid], begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        const Text('Your Personalized Plan',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: _textPrimary)),
      ]),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Text(
          'Tailored for your ${widget.result.faceShape} face shape & skin profile',
          style: TextStyle(fontSize: 12, color: _textMuted),
        ),
      ),
      const SizedBox(height: 16),

      // Tab selector
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 12,
                offset: const Offset(0, 3))
          ],
        ),
        padding: const EdgeInsets.all(5),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = _selectedPlanTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedPlanTab = i;
                  _expandedYogaIndex = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFFE96A85), _orchid],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : _textMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      const SizedBox(height: 16),

      // Tab content
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: KeyedSubtree(
          key: ValueKey(_selectedPlanTab),
          child: switch (_selectedPlanTab) {
            0 => _buildSkincareTab(recs),
            1 => _buildFacialYogaTab(recs),
            _ => _buildWellnessTab(recs),
          },
        ),
      ),
    ]);
  }

  // ── SKINCARE TAB ──────────────────────────────────────────────────────────
  Widget _buildSkincareTab(PersonalizedRecommendations recs) {
    final steps = _showMorning ? recs.morningRoutine : recs.eveningRoutine;

    return Column(children: [
      // AM / PM toggle
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0E8F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          _amPmBtn('☀️  Morning', true),
          _amPmBtn('🌙  Evening', false),
        ]),
      ),
      const SizedBox(height: 14),

      if (steps.isEmpty)
        _emptyState('No routine data available')
      else
        ...steps.map((s) => _buildSkincareStepCard(s, steps.indexOf(s))),
    ]);
  }

  Widget _amPmBtn(String label, bool isMorning) {
    final selected = _showMorning == isMorning;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showMorning = isMorning),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? _textPrimary : _textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkincareStepCard(SkincareStep step, int index) {
    final stepColors = [
      const Color(0xFFFFE8F0),
      const Color(0xFFF0E8FF),
      const Color(0xFFE8F4FF),
      const Color(0xFFE8FFF4),
      const Color(0xFFFFF8E8),
    ];
    final dotColors = [_rose, _orchid,
      const Color(0xFF70A8E8), const Color(0xFF5BB87A), const Color(0xFFE8B870)];

    final bg  = stepColors[index % stepColors.length];
    final dot = dotColors[index % dotColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Step number bubble
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(
            child: Text('${step.step}',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: dot)),
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: dot.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(step.productType,
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: dot, letterSpacing: 0.3)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(step.suggestion,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: _textPrimary, height: 1.3)),
            const SizedBox(height: 4),
            Text(step.reason,
                style: TextStyle(
                    fontSize: 12, color: _textMuted, height: 1.4)),
          ]),
        ),
      ]),
    );
  }

  // ── FACIAL YOGA TAB ───────────────────────────────────────────────────────
  Widget _buildFacialYogaTab(PersonalizedRecommendations recs) {
    if (recs.facialYoga.isEmpty) return _emptyState('No facial yoga data available');

    return Column(children: [
      // Intro banner
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [_orchid.withOpacity(0.15), _rose.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _orchid.withOpacity(0.2)),
        ),
        child: Row(children: [
          const Text('🧘', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Personalized for ${widget.result.faceShape} face shape. Do daily for best results.',
              style: TextStyle(fontSize: 12, color: _textPrimary.withOpacity(0.75), height: 1.4),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 14),

      ...recs.facialYoga.asMap().entries.map(
        (e) => _buildYogaCard(e.value, e.key),
      ),
    ]);
  }

  Widget _buildYogaCard(FacialYogaExercise ex, int index) {
    final isExpanded = _expandedYogaIndex == index;

    final mins = ex.durationSeconds ~/ 60;
    final secs = ex.durationSeconds % 60;
    final durationStr = mins > 0
        ? '${mins}m ${secs > 0 ? '${secs}s' : ''}'.trim()
        : '${secs}s';

    return GestureDetector(
      onTap: () => setState(() =>
          _expandedYogaIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isExpanded ? _orchid.withOpacity(0.4) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
                color: isExpanded
                    ? _orchid.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: isExpanded ? 18 : 12,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Index badge
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_rose, _orchid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('${index + 1}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ex.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: _textPrimary)),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 11, color: _orchid),
                  const SizedBox(width: 3),
                  Text(ex.targetArea,
                      style: TextStyle(
                          fontSize: 11, color: _orchid,
                          fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),

            // Chevron
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 280),
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: _textMuted, size: 22),
            ),
          ]),

          // Stats row
          const SizedBox(height: 12),
          Row(children: [
            _yogaStat(Icons.timer_outlined, durationStr),
            const SizedBox(width: 12),
            _yogaStat(Icons.repeat_rounded, '${ex.reps} reps'),
          ]),

          // Expandable content
          if (isExpanded) ...[
            const SizedBox(height: 14),
            Divider(color: _orchid.withOpacity(0.15), height: 1),
            const SizedBox(height: 14),

            // Benefit
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('💡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(ex.benefit,
                      style: TextStyle(
                          fontSize: 12, color: _textPrimary.withOpacity(0.8),
                          height: 1.5, fontStyle: FontStyle.italic)),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // How-to steps
            const Text('How To:',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: _textPrimary)),
            const SizedBox(height: 8),
            _buildHowToSteps(ex.howTo),
          ],
        ]),
      ),
    );
  }

  Widget _yogaStat(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EEF9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(icon, size: 13, color: _orchid),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: _textPrimary.withOpacity(0.8),
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildHowToSteps(String howTo) {
    // Split by numbered pattern or newlines
    final raw = howTo.trim();
    final lines = raw
        .split(RegExp(r'\n|(?=\d+\.\s)'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.asMap().entries.map((e) {
        final text = e.value.replaceAll(RegExp(r'^\d+\.\s*'), '');
        final num  = e.key + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: _orchid.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('$num',
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: _orchid)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 12.5, color: _textPrimary.withOpacity(0.8),
                      height: 1.5)),
            ),
          ]),
        );
      }).toList(),
    );
  }

  // ── WELLNESS TAB ──────────────────────────────────────────────────────────
  Widget _buildWellnessTab(PersonalizedRecommendations recs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (recs.dietTips.isNotEmpty) ...[
        _wellnessSectionTitle('🥗', 'Diet Tips'),
        const SizedBox(height: 10),
        ...recs.dietTips.asMap().entries
            .map((e) => _buildWellnessCard(e.value, e.key, isDiet: true)),
        const SizedBox(height: 20),
      ],
      if (recs.lifestyleTips.isNotEmpty) ...[
        _wellnessSectionTitle('✨', 'Lifestyle Tips'),
        const SizedBox(height: 10),
        ...recs.lifestyleTips.asMap().entries
            .map((e) => _buildWellnessCard(e.value, e.key, isDiet: false)),
      ],
      if (recs.dietTips.isEmpty && recs.lifestyleTips.isEmpty)
        _emptyState('No wellness data available'),
    ]);
  }

  Widget _wellnessSectionTitle(String emoji, String title) {
    return Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: _textPrimary)),
    ]);
  }

  Widget _buildWellnessCard(String tip, int index, {required bool isDiet}) {
    final color = isDiet ? const Color(0xFF5BB87A) : _orchid;
    final bg    = isDiet
        ? const Color(0xFFE8F7EE)
        : const Color(0xFFF5EEF9);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text('${index + 1}',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(tip,
                style: TextStyle(
                    fontSize: 13, color: _textPrimary.withOpacity(0.85),
                    height: 1.5)),
          ),
        ),
      ]),
    );
  }

  Widget _emptyState(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(msg,
              style: TextStyle(color: _textMuted, fontSize: 13)),
        ),
      );

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _buildButtons(BuildContext context) {
    return Row(children: [
      Expanded(
        child: _actionBtn(
          label: "Home",
          icon: Icons.home_rounded,
          onTap: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _actionBtn(
          label: "My Scans",
          icon: Icons.bar_chart_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalyticsPage()),
          ),
        ),
      ),
    ]);
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_rose, _orchid],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: _orchid.withOpacity(0.35), blurRadius: 12,
                offset: const Offset(0, 5))
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
        ]),
      ),
    );
  }

  // ── Feedback ──────────────────────────────────────────────────────────────
  Widget _buildFeedbackWidget() {
    if (_feedbackSubmitted != null) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          _feedbackSubmitted!
              ? Icons.thumb_up_rounded
              : Icons.thumb_down_rounded,
          color: _feedbackSubmitted! ? const Color(0xFF5BB87A) : _rose,
          size: 18,
        ),
        const SizedBox(width: 8),
        const Text('Thanks for your feedback!',
            style: TextStyle(color: Color(0xFF9E8DA8), fontSize: 13)),
      ]);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('Was this analysis accurate?',
            style: TextStyle(
                color: Color(0xFF1C1224),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const Spacer(),
        _feedbackBtn(Icons.thumb_up_outlined,   true,  const Color(0xFF5BB87A)),
        const SizedBox(width: 8),
        _feedbackBtn(Icons.thumb_down_outlined, false, _rose),
      ]),
    );
  }

  Widget _feedbackBtn(IconData icon, bool positive, Color color) {
    return GestureDetector(
      onTap: () => _submitFeedback(positive),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}