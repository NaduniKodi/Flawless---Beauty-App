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
    this.isNewScan = true, // ← safe default: never duplicates
  });

  @override
  State<SkinReportPage> createState() => _SkinReportPageState();
}

class _SkinReportPageState extends State<SkinReportPage> {
  // ── Colour tokens ────────────────────────────────────────────────────────────
  static const Color _rose       = Color(0xFFE8708A);
  static const Color _roseDark   = Color(0xFFC2516B);
  static const Color _orchid     = Color(0xFFBF6FD8);
  static const Color _orchidDark = Color(0xFF9847BE);
  static const Color _surface    = Color(0xFFFDF7FA);
  static const Color _textPrimary= Color(0xFF1C1224);
  static const Color _textMuted  = Color(0xFF9E8DA8);

  bool? _feedbackSubmitted;

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Only save when this is a brand-new scan from the camera.
    // Re-opening an existing record from Analytics will NOT save again.
    if (widget.isNewScan) {
      ScanHistory.instance.add(widget.result, widget.imagePath);
    }
  }

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

  // ✅ FIX: Smart image widget — handles local file OR remote URL
  Widget _imageWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final path = widget.imagePath;

    if (path.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: _orchid.withOpacity(0.1),
        child: const Icon(Icons.face_outlined, color: _orchid, size: 48),
      );
    }

    // Remote URL (loaded from Supabase Storage)
    final isRemote = path.startsWith('http://') || path.startsWith('https://');

    if (isRemote) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
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

    // Local file (just captured, not yet uploaded / upload failed)
    final file = File(path);
    if (!file.existsSync()) return _imageFallback(width, height);

    return Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _imageFallback(width, height),
    );
  }

  Widget _imageFallback(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: _orchid.withOpacity(0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: _orchid.withOpacity(0.5), size: 36),
          const SizedBox(height: 6),
          Text("Image unavailable",
              style: TextStyle(fontSize: 11, color: _textMuted)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
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
                    _buildButtons(context),
                    const SizedBox(height: 16),
                    _buildFeedbackWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gradient header ──────────────────────────────────────────────────────────
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
              "Skin Report",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white, size: 14),
                const SizedBox(width: 5),
                Text(
                  widget.isNewScan ? "Saved" : "History",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'AI-driven analysis reveals your skin health',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, color: _textMuted, height: 1.4),
    );
  }

  // ── Photo circle ─────────────────────────────────────────────────────────────
  Widget _buildPhotoCircle() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_rose, _orchid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _orchid.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(3),
            child: ClipOval(child: _imageWidget(fit: BoxFit.cover)),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 6, bottom: 6),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 6)
            ],
          ),
          child: const Icon(Icons.zoom_in_rounded,
              size: 20, color: Color(0xFF1C1224)),
        ),
      ],
    );
  }

  // ── Summary card ──────────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE96A85), _orchid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _orchid.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('${widget.result.skinAge}', 'Skin Age'),
          _vDivider(),
          _summaryItem(widget.result.faceShape, 'Face Shape', small: true),
          _vDivider(),
          _summaryItem('${widget.result.overallScore}', 'Overall Score'),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1, height: 40,
        color: Colors.white.withOpacity(0.3),
      );

  Widget _summaryItem(String value, String label, {bool small = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: small ? 20 : 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Score bar ─────────────────────────────────────────────────────────────────
  Widget _buildScoreBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Perfect',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF5BB87A))),
              Text('Concerns',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFFE05A5A))),
            ],
          ),
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
                  alignment: Alignment(
                      (widget.result.overallScore / 50) - 1.0, 0),
                  child: Container(
                    width: 3,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0',
                  style: TextStyle(color: Color(0xFF9E8DA8), fontSize: 12)),
              Text('100',
                  style: TextStyle(color: Color(0xFF9E8DA8), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.result.summary,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF9E8DA8), height: 1.4),
          ),
        ],
      ),
    );
  }

  // ── Detailed concern cards ────────────────────────────────────────────────────
  Widget _buildDetailedScores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Score',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1224)),
        ),
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
      ],
    );
  }

  Widget _buildConcernCard(SkinConcern concern) {
    return Container(
      width: 108,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _concernColor(concern.score),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${concern.score}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            concern.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ── Buttons ───────────────────────────────────────────────────────────────────
  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
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
      ],
    );
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
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _orchid.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ── Feedback ──────────────────────────────────────────────────────────────────
  Widget _buildFeedbackWidget() {
    if (_feedbackSubmitted != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _feedbackSubmitted! ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
            color: _feedbackSubmitted! ? const Color(0xFF5BB87A) : _rose,
            size: 18,
          ),
          const SizedBox(width: 8),
          const Text('Thanks for your feedback!',
              style: TextStyle(color: Color(0xFF9E8DA8), fontSize: 13)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Was this analysis accurate?',
              style: TextStyle(
                  color: Color(0xFF1C1224),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          _feedbackBtn(Icons.thumb_up_outlined,   true,  const Color(0xFF5BB87A)),
          const SizedBox(width: 8),
          _feedbackBtn(Icons.thumb_down_outlined, false, _rose),
        ],
      ),
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