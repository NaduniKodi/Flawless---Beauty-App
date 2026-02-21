// lib/interface/analytics_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/services/scan_history.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';
import 'package:flawless_beauty_app/interface/profilepage.dart';
import 'package:flawless_beauty_app/interface/settings_page.dart';
import 'package:flawless_beauty_app/screens/aicamera_page.dart';
import 'package:flawless_beauty_app/interface/skin_report_page.dart';
import 'package:flawless_beauty_app/services/skin_analysis_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  // ── Colour tokens ────────────────────────────────────────────────────────────
  static const Color _rose       = Color(0xFFE8708A);
  static const Color _roseDark   = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface    = Color(0xFFFDF7FA);
  static const Color _textPrimary= Color(0xFF1C1224);
  static const Color _textMuted  = Color(0xFF9E8DA8);

  int _currentIndex = 3; // notifications tab = analytics

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, _fadeRoute(const HomePage()));
        break;
      case 1:
        Navigator.push(context, _fadeRoute(const AICameraPage()));
        break;
      case 2:
        Navigator.push(context, _fadeRoute(const ProfilePage()));
        break;
      case 4:
        Navigator.push(context, _slideRoute(const SettingsPage()));
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
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _HistoryTab(),
                  _TrendsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gradient header ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
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
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const Expanded(
            child: Text(
              "Scan Analytics",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Total count badge
          ListenableBuilder(
            listenable: ScanHistory.instance,
            builder: (_, __) {
              final count = ScanHistory.instance.records.length;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$count scan${count != 1 ? 's' : ''}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Tab bar ──────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          gradient: const LinearGradient(colors: [_rose, _orchid]),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: _textMuted,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(text: "Scan History"),
          Tab(text: "Trends"),
        ],
      ),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────────────────────
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
              _navItem(icon: Icons.home_rounded,           index: 0),
              _navItem(icon: Icons.auto_awesome_rounded,   index: 1),
              _navLogo(),
              _navItem(icon: Icons.analytics_rounded,      index: 3),
              _navItem(icon: Icons.settings,         index: 4),
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
        child:
            Icon(icon, size: 24, color: active ? _orchidDark : _textMuted),
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
          child: Image.asset("assets/images/logo.png", fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  HISTORY TAB                                                                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
class _HistoryTab extends StatelessWidget {
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _rose       = Color(0xFFE8708A);
  static const Color _textMuted  = Color(0xFF9E8DA8);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScanHistory.instance,
      builder: (context, _) {
        final records = ScanHistory.instance.records;

        if (records.isEmpty) return _buildEmpty(context);

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          itemCount: records.length,
          itemBuilder: (context, i) =>
              _ScanCard(record: records[i], index: i),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Color(0xFFF8AFCB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.face_retouching_natural,
                size: 44, color: Color(0xFFF8AFCB)),
          ),
          const SizedBox(height: 20),
          const Text(
            "No scans yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1224),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Run your first AI face scan\nto see results here",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AICameraPage(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_rose, _orchid]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _orchid.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Start a Scan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual scan card ─────────────────────────────────────────────────────
class _ScanCard extends StatefulWidget {
  const _ScanCard({required this.record, required this.index});
  final ScanRecord record;
  final int index;

  @override
  State<_ScanCard> createState() => _ScanCardState();
}

class _ScanCardState extends State<_ScanCard> {
  bool _pressed = false;

  Color _scoreColor(int score) {
    if (score >= 75) return const Color(0xFF5BB87A);
    if (score >= 50) return const Color(0xFFD4B84A);
    if (score >= 25) return const Color(0xFFE8956A);
    return const Color(0xFFE05A5A);
  }

  String _scoreLabel(int score) {
    if (score >= 75) return "Excellent";
    if (score >= 50) return "Good";
    if (score >= 25) return "Fair";
    return "Needs Care";
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final color = _scoreColor(r.result.overallScore);
    final dateStr =
        "${r.scannedAt.day}/${r.scannedAt.month}/${r.scannedAt.year}";
    final timeStr =
        "${r.scannedAt.hour.toString().padLeft(2, '0')}:${r.scannedAt.minute.toString().padLeft(2, '0')}";

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => SkinReportPage(
              result: r.result,
              imagePath: r.imagePath,
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Dismissible(
          key: Key("scan_${widget.index}_${r.scannedAt.millisecondsSinceEpoch}"),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE05A5A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFE05A5A), size: 26),
                SizedBox(height: 4),
                Text("Delete",
                    style: TextStyle(
                        color: Color(0xFFE05A5A),
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ],
            ),
          ),
          onDismissed: (_) => ScanHistory.instance.remove(widget.index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(r.imagePath),
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Scan #${ScanHistory.instance.records.length - widget.index}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1224),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _scoreLabel(r.result.overallScore),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$dateStr · $timeStr",
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9E8DA8)),
                      ),
                      const SizedBox(height: 10),

                      // Mini stat row
                      Row(
                        children: [
                          _miniStat("Score", "${r.result.overallScore}", color),
                          const SizedBox(width: 10),
                          _miniStat("Skin Age", "${r.result.skinAge}", const Color(0xFFBF6FD8)),
                          const SizedBox(width: 10),
                          _miniStat("Shape", r.result.faceShape, const Color(0xFFE8708A)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Color(0xFF9E8DA8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF9E8DA8),
                fontWeight: FontWeight.w500)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  TRENDS TAB                                                                  ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
class _TrendsTab extends StatelessWidget {
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _rose       = Color(0xFFE8708A);
  static const Color _textPrimary= Color(0xFF1C1224);
  static const Color _textMuted  = Color(0xFF9E8DA8);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScanHistory.instance,
      builder: (context, _) {
        final records = ScanHistory.instance.records;

        if (records.length < 2) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: _orchid.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.show_chart_rounded,
                        size: 44, color: _orchid),
                  ),
                  const SizedBox(height: 20),
                  const Text("Not enough data yet",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    "Complete at least 2 scans\nto see your skin trends",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: _textMuted, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        }

        // Compute averages
        final avg = records
                .map((r) => r.result.overallScore)
                .reduce((a, b) => a + b) /
            records.length;
        final best = records
            .map((r) => r.result.overallScore)
            .reduce((a, b) => a > b ? a : b);
        final latest = records.first.result.overallScore;
        final previous = records.length > 1 ? records[1].result.overallScore : latest;
        final trend = latest - previous;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary chips ─────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _statChip("Latest", "$latest", _orchid,
                      sub: trend >= 0
                          ? "▲ +$trend vs prev"
                          : "▼ $trend vs prev",
                      subColor: trend >= 0
                          ? const Color(0xFF5BB87A)
                          : const Color(0xFFE05A5A))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statChip(
                          "Average", avg.toStringAsFixed(1), _rose)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statChip("Best", "$best",
                          const Color(0xFF5BB87A))),
                ],
              ),
              const SizedBox(height: 24),

              // ── Score over time chart ──────────────────────────────────────
              const Text("Overall Score Over Time",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary)),
              const SizedBox(height: 14),
              _buildLineChart(records),
              const SizedBox(height: 24),

              // ── Concern breakdown ─────────────────────────────────────────
              const Text("Latest Concern Breakdown",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary)),
              const SizedBox(height: 14),
              _buildConcernBars(records.first),
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(String label, String value, Color color,
      {String? sub, Color? subColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: _textMuted,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: subColor ?? _textMuted)),
          ],
        ],
      ),
    );
  }

  // ── Simple custom line chart ─────────────────────────────────────────────────
  Widget _buildLineChart(List<ScanRecord> records) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: CustomPaint(
        painter: _LineChartPainter(
          scores: records.reversed
              .map((r) => r.result.overallScore.toDouble())
              .toList(),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ── Concern progress bars ─────────────────────────────────────────────────────
  Widget _buildConcernBars(ScanRecord record) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: record.result.concerns.map((c) {
          final pct = c.score / 100.0;
          Color barColor;
          if (c.score < 20)
            barColor = const Color(0xFF5BB87A);
          else if (c.score < 50)
            barColor = const Color(0xFFD4B84A);
          else if (c.score < 75)
            barColor = const Color(0xFFE8956A);
          else
            barColor = const Color(0xFFE05A5A);

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary)),
                    Text("${c.score}",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: barColor)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: barColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Line chart painter ────────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<double> scores;
  _LineChartPainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.length < 2) return;

   const Color _orchid      = Color(0xFFF8AFCB);
   const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  const Color _rose   = Color(0xFFE8708A);

    final linePaint = Paint()
      ..shader = LinearGradient(colors: [_rose, _orchid])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [_orchid.withOpacity(0.25), _orchid.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = _orchid
      ..style = PaintingStyle.fill;

    final dotBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final double stepX = size.width / (scores.length - 1);

    Offset _point(int i) {
      final x = i * stepX;
      final y = size.height - (scores[i] / 100.0) * size.height;
      return Offset(x, y);
    }

    // Fill path
    final fillPath = Path();
    fillPath.moveTo(0, size.height);
    for (int i = 0; i < scores.length; i++) {
      fillPath.lineTo(_point(i).dx, _point(i).dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Line path
    final linePath = Path();
    linePath.moveTo(_point(0).dx, _point(0).dy);
    for (int i = 1; i < scores.length; i++) {
      final prev = _point(i - 1);
      final curr = _point(i);
      final cp1 = Offset((prev.dx + curr.dx) / 2, prev.dy);
      final cp2 = Offset((prev.dx + curr.dx) / 2, curr.dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    for (int i = 0; i < scores.length; i++) {
      canvas.drawCircle(_point(i), 5, dotPaint);
      canvas.drawCircle(_point(i), 5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.scores != scores;
}