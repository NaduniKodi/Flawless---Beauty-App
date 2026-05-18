// lib/interface/makeup_report_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/makeup_analysis_service.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
const Color _rose        = Color(0xFFE8708A);
const Color _roseDark    = Color(0xFFC2516B);
const Color _orchid      = Color(0xFFF8AFCB);
const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
const Color _surface     = Color(0xFFFDF7FA);
const Color _card        = Color(0xFFFFFFFF);
const Color _textPrimary = Color(0xFF1C1224);
const Color _textMuted   = Color(0xFF9E8DA8);

// ── Hero image height — single source of truth ────────────────────────────────
const double _heroHeight = 310;

/// ================= MAKEUP REPORT PAGE =================
class MakeupReportPage extends StatefulWidget {
  final String imagePath;
  final MakeupAnalysisResult result;

  const MakeupReportPage({
    super.key,
    required this.imagePath,
    required this.result,
  });

  @override
  State<MakeupReportPage> createState() => _MakeupReportPageState();
}

class _MakeupReportPageState extends State<MakeupReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  MakeupAnalysisResult get r => widget.result;
  FaceFeatures         get f => r.features;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: _heroHeight,
            pinned: true,
            backgroundColor: _surface,
            elevation: 0,
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: _textPrimary, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _HeroHeader(
                imagePath: widget.imagePath,
                overallStyle: r.overallStyle,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                color: _surface,
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    gradient:
                        const LinearGradient(colors: [_rose, _orchidDark]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: -8, vertical: 6),
                  dividerColor: Colors.transparent,
                  labelColor: _rose,
                  unselectedLabelColor: _textMuted,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 13),
                  tabs: const [
                    Tab(text: 'My Features'),
                    Tab(text: 'Tutorials'),
                    Tab(text: 'Quick Tips'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _FeaturesTab(features: f),
            _TutorialsTab(tutorials: r.tutorials),
            _TipsTab(tips: r.quickTips),
          ],
        ),
      ),
    );
  }
}

// ── Hero header extracted to its own StatefulWidget ──────────────────────────
// This ensures the image always has explicit size constraints from its own
// SizedBox parent rather than relying on FlexibleSpaceBar's implicit layout.
class _HeroHeader extends StatelessWidget {
  final String imagePath;
  final String overallStyle;

  const _HeroHeader({
    required this.imagePath,
    required this.overallStyle,
  });

  // ── Decide which image widget to use ────────────────────────────────────
  Widget _image() {
    const placeholder = _ImagePlaceholder();

    if (imagePath.isEmpty) return placeholder;

    // Remote signed URL (loaded from Supabase history)
    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // Show a shimmer-style loader while downloading
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: const Color(0xFFF0E8F0),
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_orchid),
                strokeWidth: 2.5,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    // Local file (just captured in this session)
    final file = File(imagePath);
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: 1080,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Photo ──────────────────────────────────────────────────────
          _image(),

          // ── Gradient overlay ───────────────────────────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.28),
                  Colors.black.withOpacity(0.04),
                  _surface.withOpacity(0.96),
                ],
                stops: const [0.0, 0.44, 1.0],
              ),
            ),
          ),

          // ── Text content ───────────────────────────────────────────────
          Positioned(
            bottom: 64,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Style badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_rose, _orchidDark]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _rose.withOpacity(0.32),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '✨  $overallStyle',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your Feature Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Personalised tutorials curated for you',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder shown when no image is available ──────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF0E8F0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.face_retouching_natural,
              size: 64, color: _orchid.withOpacity(0.6)),
          const SizedBox(height: 8),
          Text(
            'No photo available',
            style: TextStyle(
                color: _textMuted.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1 · MY FEATURES
// ═══════════════════════════════════════════════════════════════════════════════

class _FeaturesTab extends StatelessWidget {
  final FaceFeatures features;
  const _FeaturesTab({required this.features});

  @override
  Widget build(BuildContext context) {
    final items = [
      _FeatureItem('Face Shape',     features.faceShape,    '🫶', _faceShapeDesc(features.faceShape)),
      _FeatureItem('Eye Shape',      features.eyeShape,     '👁️', _eyeDesc(features.eyeShape)),
      _FeatureItem('Lip Shape',      features.lipShape,     '💋', _lipDesc(features.lipShape)),
      _FeatureItem('Nose Shape',     features.noseShape,    '👃', _noseDesc(features.noseShape)),
      _FeatureItem('Eyebrows',       features.eyebrowShape, '〰️', _browDesc(features.eyebrowShape)),
      _FeatureItem('Skin Undertone', features.skinUndertone,'🌟', _undertoneDesc(features.skinUndertone)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _SectionHeader('Detected Facial Features'),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.08,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _FeatureCard(item: items[i]),
        ),
        const SizedBox(height: 24),
        _SectionHeader('About Your Look'),
        const SizedBox(height: 12),
        _AIAnalysisCard(text: features.rawAIAnalysis),
      ],
    );
  }
}

class _FeatureItem {
  final String label, value, emoji, description;
  const _FeatureItem(this.label, this.value, this.emoji, this.description);
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _orchid.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: _rose.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _orchid.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _cap(item.value),
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            item.description,
            style: const TextStyle(
              color: _textMuted, fontSize: 10.5, height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AIAnalysisCard extends StatelessWidget {
  final String text;
  const _AIAnalysisCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orchid.withOpacity(0.12), _rose.withOpacity(0.07)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _orchid.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _rose.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.isEmpty
                  ? 'AI detected your facial features using geometric analysis of landmark points and contour data.'
                  : text,
              style: const TextStyle(
                color: _textPrimary, fontSize: 13.5, height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2 · TUTORIALS
// ═══════════════════════════════════════════════════════════════════════════════

class _TutorialsTab extends StatelessWidget {
  final List<MakeupTutorial> tutorials;
  const _TutorialsTab({required this.tutorials});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _SectionHeader('Tutorials For Your Features'),
        const SizedBox(height: 4),
        const Text(
          'Curated based on your detected face shape, eyes, lips & more',
          style: TextStyle(color: _textMuted, fontSize: 12.5),
        ),
        const SizedBox(height: 16),
        ...tutorials.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TutorialCard(tutorial: t),
            )),
      ],
    );
  }
}

class _TutorialCard extends StatelessWidget {
  final MakeupTutorial tutorial;
  const _TutorialCard({required this.tutorial});

  Color _diffColor(String d) => switch (d.toLowerCase()) {
        'beginner'     => const Color(0xFF5BB87A),
        'intermediate' => const Color(0xFFD4A840),
        'advanced'     => const Color(0xFFE05A5A),
        _              => _orchidDark,
      };

  Future<void> _openYouTube(String query) async {
    final appUri = Uri.parse(
      'youtube://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}',
    );
    final webUri = Uri.parse(
      'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _orchid.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [_rose, _orchidDark]),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _orchid.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _orchid.withOpacity(0.4)),
                  ),
                  child: Text(
                    tutorial.targetFeature,
                    style: const TextStyle(
                      color: _roseDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _diffColor(tutorial.difficulty).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tutorial.difficulty,
                    style: TextStyle(
                      color: _diffColor(tutorial.difficulty),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              tutorial.title,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
              tutorial.description,
              style: const TextStyle(
                  color: _textMuted, fontSize: 13, height: 1.45),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.play_circle_outline_rounded,
                    color: _rose, size: 14),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    tutorial.channel,
                    style:
                        const TextStyle(color: _textMuted, fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.timer_outlined,
                    color: _textMuted, size: 13),
                const SizedBox(width: 4),
                Text(tutorial.duration,
                    style: const TextStyle(
                        color: _textMuted, fontSize: 11.5)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tutorial.products
                  .map((p) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _orchid.withOpacity(0.35)),
                        ),
                        child: Text(p,
                            style: const TextStyle(
                                color: _textMuted, fontSize: 10.5)),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: GestureDetector(
              onTap: () => _openYouTube(tutorial.searchQuery),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF1A1A), Color(0xFFCC0000)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Search on YouTube',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 3 · QUICK TIPS
// ═══════════════════════════════════════════════════════════════════════════════

class _TipsTab extends StatelessWidget {
  final List<MakeupTip> tips;
  const _TipsTab({required this.tips});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _SectionHeader('Quick Pro Tips'),
        const SizedBox(height: 4),
        const Text(
          'Actionable makeup hacks for your specific features',
          style: TextStyle(color: _textMuted, fontSize: 12.5),
        ),
        const SizedBox(height: 16),
        ...tips.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TipCard(tip: e.value, index: e.key),
            )),
        const SizedBox(height: 8),
        const _ProTipBanner(),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final MakeupTip tip;
  final int index;
  const _TipCard({required this.tip, required this.index});

  static const List<Color> _accents = [
    Color(0xFFE8708A),
    Color(0xFFFF98C0),
    Color(0xFFD44E80),
    Color(0xFFC2516B),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[index % _accents.length];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(tip.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tip.feature,
                    style: TextStyle(
                      color: accent,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tip.title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tip.body,
                  style: const TextStyle(
                    color: _textMuted, fontSize: 13, height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProTipBanner extends StatelessWidget {
  const _ProTipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orchid.withOpacity(0.18), _rose.withOpacity(0.10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _orchid.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _rose.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
                child: Text('💡', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Reminder',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Good lighting and clean, moisturized skin are the foundations of any makeup look — no technique or product can replace them.',
                  style: TextStyle(
                      color: _textMuted, fontSize: 12.5, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      );
}

String _cap(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _faceShapeDesc(String s) => {
      'oval':    'Well-balanced proportions',
      'round':   'Soft curves, equal width/height',
      'square':  'Strong jaw & wide forehead',
      'heart':   'Wide forehead, narrow jaw',
      'oblong':  'Face length greater than width',
      'diamond': 'Narrow forehead & jaw, wide cheeks',
    }[s] ?? 'Balanced proportions';

String _eyeDesc(String s) => {
      'almond':     'Tapers at both corners',
      'round':      'Circular, prominent iris',
      'hooded':     'Crease hidden when open',
      'monolid':    'No visible crease',
      'upturned':   'Outer corner tilts up',
      'downturned': 'Outer corner tilts down',
    }[s] ?? 'Classic eye shape';

String _lipDesc(String s) => {
      'full':       'Generous upper & lower volume',
      'thin':       'Delicate, refined lip line',
      'cupids-bow': 'Defined double peak on upper',
      'pouty':      'Prominent lower lip volume',
      'wide':       'Lips extend to outer corners',
      'small':      'Compact, doll-like proportion',
    }[s] ?? 'Natural lip shape';

String _noseDesc(String s) => {
      'button':   'Small, rounded nose tip',
      'roman':    'Slight bridge bump',
      'snub':     'Upturned tip, short bridge',
      'wide':     'Broader nostril width',
      'narrow':   'Slim bridge & nostrils',
      'aquiline': 'Curved, hawk-like bridge',
    }[s] ?? 'Balanced nose shape';

String _browDesc(String s) => {
      'arched':   'Natural lift at the peak',
      'straight': 'Horizontal, no arch',
      'rounded':  'Gentle soft curve',
      's-shaped': 'Unique double curve',
      'bushy':    'Full, thick brow hairs',
    }[s] ?? 'Natural brow shape';

String _undertoneDesc(String s) => {
      'warm':    'Golden, peachy or yellow hues',
      'cool':    'Pink, red or bluish hues',
      'neutral': 'Mix of warm and cool tones',
    }[s] ?? 'Balanced skin tones';