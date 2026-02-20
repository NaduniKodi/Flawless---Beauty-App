import 'package:flutter/material.dart';
import 'dart:io';
import '../services/skin_analysis_service.dart';

class SkinReportPage extends StatelessWidget {
  final SkinAnalysisResult result;
  final String imagePath;

  const SkinReportPage({
    super.key,
    required this.result,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2ED),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Reports reveals healthy complexion\nwith AI-driven analysis',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // ── Face Photo ──
              _buildPhotoCircle(),

              const SizedBox(height: 20),

              // ── Summary Card ──
              _buildSummaryCard(),

              const SizedBox(height: 16),

              // ── Score Bar ──
              _buildScoreBar(),

              const SizedBox(height: 20),

              // ── Detailed Scores ──
              _buildDetailedScores(),

              const SizedBox(height: 30),

              // ── Buttons ──
              _buildButtons(context),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCircle() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 6),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 2)
            ],
          ),
          child: ClipOval(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: const Icon(Icons.zoom_in, size: 28, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFB5D5B5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryItem('${result.skinAge}', 'Skin Age', fontSize: 32),
          _summaryItem(result.faceShape, 'Face Shape', fontSize: 22),
          _summaryItem('${result.overallScore}', 'Overall Score', fontSize: 32),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label, {double fontSize = 28}) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: '\n$label',
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScoreBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Perfect', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Concerns', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7DC67D),
                    Color(0xFFD4C97A),
                    Color(0xFFE8956A),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Indicator arrow
                  Align(
                    alignment: Alignment(
                      (result.overallScore / 50) - 1.0, // map 0-100 to -1..1
                      0,
                    ),
                    child: Container(
                      width: 3,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(color: Colors.black54)),
              Text('100', style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.summary,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedScores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Detailed Score',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: result.concerns.length,
            itemBuilder: (context, index) {
              final concern = result.concerns[index];
              return _buildConcernCard(concern);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConcernCard(SkinConcern concern) {
    // Color based on score severity
    Color cardColor;
    if (concern.score < 20) {
      cardColor = const Color(0xFFB5D5B5); // light green - good
    } else if (concern.score < 50) {
      cardColor = const Color(0xFFD4E8A8); // yellow-green - mild
    } else if (concern.score < 75) {
      cardColor = const Color(0xFFE8C97A); // orange - moderate
    } else {
      cardColor = const Color(0xFFE88A6A); // red - severe
    }

    return GestureDetector(
      onTap: () {
        // TODO: show detail popup
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${concern.score}',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              concern.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Text('»'),
              label: const Text('Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B5FBF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: navigate to beauty plan page
              },
              icon: const Text('»'),
              label: const Text('Beauty Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B5FBF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}