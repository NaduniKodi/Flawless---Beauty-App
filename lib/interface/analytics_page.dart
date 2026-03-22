// lib/interface/analytics_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/services/scan_history.dart';
import 'package:flawless_beauty_app/services/makeup_history.dart';
import 'package:flawless_beauty_app/interface/homepage.dart';
import 'package:flawless_beauty_app/interface/profilepage.dart';
import 'package:flawless_beauty_app/interface/settings_page.dart';
import 'package:flawless_beauty_app/screens/aicamera_page.dart';
import 'package:flawless_beauty_app/screens/makeup_page.dart';
import 'package:flawless_beauty_app/interface/skin_report_page.dart';
import 'package:flawless_beauty_app/interface/makeup_report_page.dart';

// ── Colour tokens (matches HomePage) ─────────────────────────────────────────
const Color _rose        = Color(0xFFE8708A);
const Color _roseDark    = Color(0xFFC2516B);
const Color _orchid      = Color(0xFFF8AFCB);
const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
const Color _surface     = Color(0xFFFDF7FA);
const Color _card        = Color(0xFFFFFFFF);
const Color _textPrimary = Color(0xFF1C1224);
const Color _textMuted   = Color(0xFF9E8DA8);

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 3;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this); // ← now 3 tabs
    ScanHistory.instance.load();
    MakeupHistory.instance.load();
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
      case 4:
        Navigator.push(context, _fadeRoute(const SettingsPage()));
        break;
      case 2:
        Navigator.push(context, _slideRoute(const ProfilePage()));
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
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
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
                children: const [
                  _HistoryTab(),
                  _TrendsTab(),
                  _MakeupTab(),   // ← new
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gradient header ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_rose, _orchidDark],
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
              'Scan Analytics',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Combined scan count badge
          ListenableBuilder(
            listenable: ScanHistory.instance,
            builder: (_, __) {
              final count = ScanHistory.instance.records.length;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count scan${count != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Pill tab bar ─────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      height: 44,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          gradient: const LinearGradient(colors: [_rose, _orchidDark]),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: _textMuted,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        tabs: const [
          Tab(text: 'Skin Scans'),
          Tab(text: 'Trends'),
          Tab(text: 'Makeup'),
        ],
      ),
    );
  }

  // ── Bottom nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
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
              _navItem(icon: Icons.home_rounded,          index: 0),
              _navItem(icon: Icons.auto_awesome_rounded,  index: 1),
              _navLogo(),
              _navItem(icon: Icons.bar_chart_rounded,     index: 3),
              _navItem(icon: Icons.settings_rounded,      index: 4),
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
          color:
              active ? _orchid.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon,
            size: 24, color: active ? _orchidDark : _textMuted),
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

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  TAB 1 · SKIN SCAN HISTORY                                                  ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScanHistory.instance,
      builder: (context, _) {
        final history = ScanHistory.instance;

        if (history.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_orchidDark),
            ),
          );
        }

        if (history.error != null) {
          return _CenteredMessage(
            icon: Icons.cloud_off_rounded,
            iconColor: const Color(0xFFE05A5A),
            title: "Couldn't load scans",
            subtitle: "Check your connection and try again",
            action: _PillButton(
              label: 'Retry',
              onTap: () => ScanHistory.instance.load(force: true),
            ),
          );
        }

        if (history.records.isEmpty) {
          return _CenteredMessage(
            icon: Icons.face_retouching_natural,
            iconColor: _orchidDark,
            title: 'No scans yet',
            subtitle:
                'Run your first AI face scan\nto see results here',
            action: _PillButton(
              label: '✨ Start a Scan',
              gradient: true,
              onTap: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AICameraPage(),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: _orchidDark,
          onRefresh: () => ScanHistory.instance.load(force: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            itemCount: history.records.length,
            itemBuilder: (context, i) => _ScanCard(
              record: history.records[i],
              scanNumber: history.records.length - i,
            ),
          ),
        );
      },
    );
  }
}

// ── Skin scan card ────────────────────────────────────────────────────────────
class _ScanCard extends StatefulWidget {
  const _ScanCard({required this.record, required this.scanNumber});
  final ScanRecord record;
  final int scanNumber;

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
    if (score >= 75) return 'Excellent';
    if (score >= 50) return 'Good';
    if (score >= 25) return 'Fair';
    return 'Needs Care';
  }

  Widget _thumbnail() {
    final path = widget.record.imagePath;
    if (path.isEmpty) return _thumbFallback();
    final isRemote = widget.record.isRemote;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: isRemote
          ? Image.network(path,
              width: 66, height: 66, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _thumbFallback())
          : Image.file(File(path),
              width: 66, height: 66, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _thumbFallback()),
    );
  }

  Widget _thumbFallback() => Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: _orchid.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.face_outlined, color: _orchidDark, size: 30),
      );

  Future<void> _confirmDelete(BuildContext ctx) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => _DeleteDialog(),
    );
    if (ok == true) await ScanHistory.instance.remove(widget.record.id);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final color = _scoreColor(r.result.overallScore);
    final dateStr =
        '${r.scannedAt.day.toString().padLeft(2, '0')}/${r.scannedAt.month.toString().padLeft(2, '0')}/${r.scannedAt.year}';
    final timeStr =
        '${r.scannedAt.hour.toString().padLeft(2, '0')}:${r.scannedAt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                SkinReportPage(result: r.result, imagePath: r.imagePath),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Dismissible(
          key: Key(r.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                context: context, builder: (_) => _DeleteDialog());
          },
          onDismissed: (_) => ScanHistory.instance.remove(r.id),
          background: _SwipeDeleteBg(),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _orchid.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _thumbnail(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Scan #${widget.scanNumber}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          const Spacer(),
                          _Badge(
                              label: _scoreLabel(r.result.overallScore),
                              color: color),
                          GestureDetector(
                            onTap: () => _confirmDelete(context),
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE05A5A)
                                    .withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 15,
                                  color: Color(0xFFE05A5A)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('$dateStr · $timeStr',
                          style: const TextStyle(
                              fontSize: 12, color: _textMuted)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _MiniStat('Score',
                              '${r.result.overallScore}', color),
                          const SizedBox(width: 14),
                          _MiniStat('Skin Age',
                              '${r.result.skinAge}', _orchidDark),
                          const SizedBox(width: 14),
                          _MiniStat('Shape',
                              r.result.faceShape, _rose),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: _textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  TAB 2 · TRENDS                                                              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
class _TrendsTab extends StatelessWidget {
  const _TrendsTab();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ScanHistory.instance,
      builder: (context, _) {
        final history = ScanHistory.instance;

        if (history.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_orchidDark),
            ),
          );
        }

        final records = history.records;

        if (records.length < 2) {
          return _CenteredMessage(
            icon: Icons.show_chart_rounded,
            iconColor: _orchidDark,
            title: 'Not enough data yet',
            subtitle:
                'Complete at least 2 scans\nto see your skin trends',
          );
        }

        final avg = records
                .map((r) => r.result.overallScore)
                .reduce((a, b) => a + b) /
            records.length;
        final best = records
            .map((r) => r.result.overallScore)
            .reduce((a, b) => a > b ? a : b);
        final latest = records.first.result.overallScore;
        final prev   = records[1].result.overallScore;
        final trend  = latest - prev;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat chips row
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      label: 'Latest',
                      value: '$latest',
                      color: _orchidDark,
                      sub: trend >= 0
                          ? '▲ +$trend vs prev'
                          : '▼ $trend vs prev',
                      subColor: trend >= 0
                          ? const Color(0xFF5BB87A)
                          : const Color(0xFFE05A5A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatChip(
                      label: 'Average',
                      value: avg.toStringAsFixed(1),
                      color: _rose,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatChip(
                      label: 'Best',
                      value: '$best',
                      color: const Color(0xFF5BB87A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Overall Score Over Time'),
              const SizedBox(height: 14),
              _LineChartCard(
                scores: records.reversed
                    .map((r) => r.result.overallScore.toDouble())
                    .toList(),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Latest Concern Breakdown'),
              const SizedBox(height: 14),
              _ConcernBarsCard(record: records.first),
            ],
          ),
        );
      },
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  TAB 3 · MAKEUP HISTORY                                                      ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
class _MakeupTab extends StatelessWidget {
  const _MakeupTab();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MakeupHistory.instance,
      builder: (context, _) {
        final history = MakeupHistory.instance;

        if (history.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_orchidDark),
            ),
          );
        }

        if (history.records.isEmpty) {
          return _CenteredMessage(
            icon: Icons.face_retouching_natural,
            iconColor: _orchidDark,
            title: 'No makeup scans yet',
            subtitle:
                'Use the Makeup Try-On camera\nto get personalized tutorials',
            action: _PillButton(
              label: '💄 Try Makeup AR',
              gradient: true,
              onTap: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const MakeupPage(),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: _orchidDark,
          onRefresh: () => MakeupHistory.instance.load(force: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            itemCount: history.records.length,
            itemBuilder: (context, i) => _MakeupCard(
              record: history.records[i],
              sessionNumber: history.records.length - i,
            ),
          ),
        );
      },
    );
  }
}

// ── Makeup history card ───────────────────────────────────────────────────────
class _MakeupCard extends StatefulWidget {
  const _MakeupCard(
      {required this.record, required this.sessionNumber});
  final MakeupRecord record;
  final int sessionNumber;

  @override
  State<_MakeupCard> createState() => _MakeupCardState();
}

class _MakeupCardState extends State<_MakeupCard> {
  bool _pressed = false;

  Widget _thumbnail() {
    final path = widget.record.imagePath;
    if (path.isEmpty) return _thumbFallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.file(
        File(path),
        width: 66,
        height: 66,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _thumbFallback(),
      ),
    );
  }

  Widget _thumbFallback() => Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_rose.withOpacity(0.15), _orchid.withOpacity(0.20)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child:
            const Icon(Icons.face_retouching_natural, color: _rose, size: 30),
      );

  Future<void> _confirmDelete(BuildContext ctx) async {
    final ok = await showDialog<bool>(
        context: ctx, builder: (_) => _DeleteDialog());
    if (ok == true) {
      await MakeupHistory.instance.remove(widget.record.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final f = r.result.features;
    final dateStr =
        '${r.scannedAt.day.toString().padLeft(2, '0')}/${r.scannedAt.month.toString().padLeft(2, '0')}/${r.scannedAt.year}';
    final timeStr =
        '${r.scannedAt.hour.toString().padLeft(2, '0')}:${r.scannedAt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => MakeupReportPage(
              imagePath: r.imagePath,
              result: r.result,
            ),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Dismissible(
          key: Key(r.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async => await showDialog<bool>(
              context: context, builder: (_) => _DeleteDialog()),
          onDismissed: (_) => MakeupHistory.instance.remove(r.id),
          background: _SwipeDeleteBg(),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _orchid.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: _rose.withOpacity(0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Top row ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      _thumbnail(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Session #${widget.sessionNumber}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                // Style badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [_rose, _orchidDark]),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    r.result.overallStyle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                // Delete button
                                GestureDetector(
                                  onTap: () => _confirmDelete(context),
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE05A5A)
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 15,
                                        color: Color(0xFFE05A5A)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('$dateStr · $timeStr',
                                style: const TextStyle(
                                    fontSize: 12, color: _textMuted)),
                            const SizedBox(height: 10),
                            // Feature chips row
                            Row(
                              children: [
                                _MiniStat('Face', _cap(f.faceShape), _rose),
                                const SizedBox(width: 14),
                                _MiniStat(
                                    'Eyes', _cap(f.eyeShape), _orchidDark),
                                const SizedBox(width: 14),
                                _MiniStat(
                                    'Lips', _cap(f.lipShape), _roseDark),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Feature tag strip ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: Row(
                    children: [
                      _FeaturePill('👁️ ${_cap(f.eyeShape)}'),
                      const SizedBox(width: 6),
                      _FeaturePill('💋 ${_cap(f.lipShape)}'),
                      const SizedBox(width: 6),
                      _FeaturePill('🌟 ${_cap(f.skinUndertone)}'),
                      const Spacer(),
                      Row(
                        children: [
                          Text('View Report',
                              style: TextStyle(
                                color: _orchidDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(width: 3),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 11, color: _orchidDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  SHARED SMALL WIDGETS                                                        ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? action;

  const _CenteredMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
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
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: _textMuted, height: 1.5)),
            if (action != null) ...[
              const SizedBox(height: 28),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool gradient;

  const _PillButton({
    required this.label,
    required this.onTap,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient
              ? const LinearGradient(colors: [_rose, _orchidDark])
              : null,
          color: gradient ? null : _orchid.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          boxShadow: gradient
              ? [
                  BoxShadow(
                    color: _orchid.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: gradient ? Colors.white : _orchidDark,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: _textMuted,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      );
}

class _FeaturePill extends StatelessWidget {
  final String label;
  const _FeaturePill(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _orchid.withOpacity(0.3)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10.5,
                color: _textMuted,
                fontWeight: FontWeight.w500)),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _textPrimary));
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? sub;
  final Color? subColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    this.sub,
    this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: subColor ?? _textMuted)),
          ],
        ],
      ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  final List<double> scores;
  const _LineChartCard({required this.scores});

  @override
  Widget build(BuildContext context) => Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _LineChartPainter(scores: scores),
          child: const SizedBox.expand(),
        ),
      );
}

class _ConcernBarsCard extends StatelessWidget {
  final ScanRecord record;
  const _ConcernBarsCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: record.result.concerns.map((c) {
          Color barColor;
          if (c.score < 20) barColor = const Color(0xFF5BB87A);
          else if (c.score < 50) barColor = const Color(0xFFD4B84A);
          else if (c.score < 75) barColor = const Color(0xFFE8956A);
          else barColor = const Color(0xFFE05A5A);

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
                    Text('${c.score}',
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
                    value: c.score / 100.0,
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

class _SwipeDeleteBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE05A5A).withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded,
                color: Color(0xFFE05A5A), size: 26),
            SizedBox(height: 4),
            Text('Delete',
                style: TextStyle(
                    color: Color(0xFFE05A5A),
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ],
        ),
      );
}

class _DeleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'This record will be permanently removed. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: _textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Color(0xFFE05A5A),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      );
}

// ── Line chart painter (rose → orchid palette) ────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<double> scores;
  const _LineChartPainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.length < 2) return;

    final linePaint = Paint()
      ..shader = const LinearGradient(colors: [_rose, _orchidDark])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          _orchid.withOpacity(0.25),
          _orchid.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final stepX = size.width / (scores.length - 1);
    Offset pt(int i) => Offset(
        i * stepX, size.height - (scores[i] / 100.0) * size.height);

    // Fill
    final fill = Path()..moveTo(0, size.height);
    for (int i = 0; i < scores.length; i++) {
      fill.lineTo(pt(i).dx, pt(i).dy);
    }
    fill.lineTo(size.width, size.height);
    fill.close();
    canvas.drawPath(fill, fillPaint);

    // Line with cubic bezier
    final line = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (int i = 1; i < scores.length; i++) {
      final prev = pt(i - 1);
      final curr = pt(i);
      final cp1 = Offset((prev.dx + curr.dx) / 2, prev.dy);
      final cp2 = Offset((prev.dx + curr.dx) / 2, curr.dy);
      line.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(line, linePaint);

    // Dots
    final dotPaint = Paint()..color = _orchidDark..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < scores.length; i++) {
      canvas.drawCircle(pt(i), 5, dotPaint);
      canvas.drawCircle(pt(i), 5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.scores != scores;
}

// ── Helper ────────────────────────────────────────────────────────────────────
String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);