// lib/widgets/ar_makeup_painter.dart

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Represents one selectable AR makeup look.
class ARMakeupLook {
  final String id;
  final String label;
  final String emoji;
  final Color lipColor;
  final Color blushColor;
  final Color eyeColor;
  final double lipOpacity;
  final double blushOpacity;
  final double eyeOpacity;
  final bool showHighlight;

  const ARMakeupLook({
    required this.id,
    required this.label,
    required this.emoji,
    required this.lipColor,
    required this.blushColor,
    required this.eyeColor,
    this.lipOpacity = 0.55,
    this.blushOpacity = 0.30,
    this.eyeOpacity = 0.40,
    this.showHighlight = true,
  });
}

// ── Preset Looks ──────────────────────────────────────────────────────────────
const List<ARMakeupLook> arMakeupPresets = [
  ARMakeupLook(
    id: 'natural',
    label: 'Natural',
    emoji: '🌸',
    lipColor: Color(0xFFD4857A),
    blushColor: Color(0xFFEEA0A0),
    eyeColor: Color(0xFF8B6F5E),
    lipOpacity: 0.40,
    blushOpacity: 0.20,
    eyeOpacity: 0.25,
    showHighlight: true,
  ),
  ARMakeupLook(
    id: 'soft_glam',
    label: 'Soft Glam',
    emoji: '✨',
    lipColor: Color(0xFFB5485A),
    blushColor: Color(0xFFE8A0B4),
    eyeColor: Color(0xFF704060),
    lipOpacity: 0.60,
    blushOpacity: 0.30,
    eyeOpacity: 0.45,
    showHighlight: true,
  ),
  ARMakeupLook(
    id: 'bold_red',
    label: 'Bold Red',
    emoji: '💋',
    lipColor: Color(0xFFCC1A2A),
    blushColor: Color(0xFFE8C0A0),
    eyeColor: Color(0xFF3A2A20),
    lipOpacity: 0.75,
    blushOpacity: 0.25,
    eyeOpacity: 0.35,
    showHighlight: false,
  ),
  ARMakeupLook(
    id: 'smoky',
    label: 'Smoky',
    emoji: '🌑',
    lipColor: Color(0xFF3D1A1A),
    blushColor: Color(0xFF806060),
    eyeColor: Color(0xFF1A1A2E),
    lipOpacity: 0.65,
    blushOpacity: 0.20,
    eyeOpacity: 0.65,
    showHighlight: false,
  ),
  ARMakeupLook(
    id: 'coral',
    label: 'Coral',
    emoji: '🍊',
    lipColor: Color(0xFFE8683A),
    blushColor: Color(0xFFF0A070),
    eyeColor: Color(0xFF7A4530),
    lipOpacity: 0.60,
    blushOpacity: 0.28,
    eyeOpacity: 0.35,
    showHighlight: true,
  ),
  ARMakeupLook(
    id: 'berry',
    label: 'Berry',
    emoji: '🫐',
    lipColor: Color(0xFF7B2D6E),
    blushColor: Color(0xFFB07090),
    eyeColor: Color(0xFF4A1A60),
    lipOpacity: 0.70,
    blushOpacity: 0.28,
    eyeOpacity: 0.50,
    showHighlight: true,
  ),
];

/// ================= AR MAKEUP PAINTER =================
/// Paints virtual makeup on top of the camera preview using face landmarks.
class ARMakeupPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final ARMakeupLook look;
  final bool mirrorX;
  final double intensity; // 0.0 – 1.0 intensity slider

  const ARMakeupPainter({
    required this.faces,
    required this.imageSize,
    required this.look,
    this.mirrorX = true,
    this.intensity = 1.0,
  });

  double _mx(double x, double scaleX) {
    if (mirrorX) return (imageSize.width - x) * scaleX;
    return x * scaleX;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize == Size.zero) return;
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (final face in faces) {
      final box = face.boundingBox;
      final faceW = box.width * scaleX;
      final faceH = box.height * scaleY;
      final centerX = _mx(box.center.dx, scaleX);
      final centerY = box.center.dy * scaleY;

      // ── Lips ────────────────────────────────────────────────────────────
      _paintLips(canvas, face, scaleX, scaleY, faceW, faceH, centerX);

      // ── Blush ───────────────────────────────────────────────────────────
      _paintBlush(canvas, face, scaleX, scaleY, faceW, faceH, centerX, centerY);

      // ── Eye shadow ──────────────────────────────────────────────────────
      _paintEyeShadow(canvas, face, scaleX, scaleY, faceW);

      // ── Highlight (nose bridge + brow bone) ─────────────────────────────
      if (look.showHighlight) {
        _paintHighlight(canvas, face, scaleX, scaleY, faceW, centerX);
      }
    }
  }

  // ── Lips ──────────────────────────────────────────────────────────────────
  void _paintLips(Canvas canvas, Face face, double scaleX, double scaleY,
      double faceW, double faceH, double centerX) {
    final upperTop = face.contours[FaceContourType.upperLipTop];
    final upperBot = face.contours[FaceContourType.upperLipBottom];
    final lowerTop = face.contours[FaceContourType.lowerLipTop];
    final lowerBot = face.contours[FaceContourType.lowerLipBottom];

    // Build lip path from contours when available
    if (upperTop != null && upperTop.points.length >= 4 &&
        lowerBot != null && lowerBot.points.length >= 4) {
      final path = Path();
      final upperPoints = upperTop.points
          .map((p) => Offset(_mx(p.x.toDouble(), scaleX), p.y * scaleY))
          .toList();
      final lowerPoints = lowerBot.points
          .map((p) => Offset(_mx(p.x.toDouble(), scaleX), p.y * scaleY))
          .toList()
          .reversed
          .toList();

      if (upperPoints.isNotEmpty) {
        path.moveTo(upperPoints.first.dx, upperPoints.first.dy);
        for (final pt in upperPoints.skip(1)) {
          path.lineTo(pt.dx, pt.dy);
        }
        for (final pt in lowerPoints) {
          path.lineTo(pt.dx, pt.dy);
        }
        path.close();

        final lipPaint = Paint()
          ..color = look.lipColor.withOpacity(look.lipOpacity * intensity)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, lipPaint);

        // Glossy highlight on center of lower lip
        if (lowerTop != null && lowerTop.points.isNotEmpty) {
          final midIdx = lowerTop.points.length ~/ 2;
          final midPt = lowerTop.points[midIdx];
          final glossX = _mx(midPt.x.toDouble(), scaleX);
          final glossY = midPt.y * scaleY;
          final glossPaint = Paint()
            ..shader = RadialGradient(
              colors: [
                Colors.white.withOpacity(0.35 * intensity),
                Colors.transparent,
              ],
            ).createShader(Rect.fromCenter(
                center: Offset(glossX, glossY),
                width: faceW * 0.15,
                height: faceW * 0.06));
          canvas.drawOval(
            Rect.fromCenter(
                center: Offset(glossX, glossY),
                width: faceW * 0.15,
                height: faceW * 0.06),
            glossPaint,
          );
        }
      }
    } else {
      // Fallback: geometric lip based on face bounding box
      final box = face.boundingBox;
      final lipY = (box.top + box.height * 0.78) * scaleY;
      final lipW = faceW * 0.36;
      final lipH = faceH * 0.055;
      final lx = centerX - lipW / 2;

      final lipPaint = Paint()
        ..color = look.lipColor.withOpacity(look.lipOpacity * intensity)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(lx, lipY, lipW, lipH), Radius.circular(lipH / 2)),
        lipPaint,
      );
    }
  }

  // ── Blush ─────────────────────────────────────────────────────────────────
  void _paintBlush(Canvas canvas, Face face, double scaleX, double scaleY,
      double faceW, double faceH, double centerX, double centerY) {
    final box = face.boundingBox;
    final cheekY = (box.top + box.height * 0.60) * scaleY;
    final cheekOffsetX = faceW * 0.30;
    final blushW = faceW * 0.32;
    final blushH = faceH * 0.18;

    for (final side in [-1.0, 1.0]) {
      final bx = centerX + side * cheekOffsetX;

      final blushPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            look.blushColor.withOpacity(look.blushOpacity * intensity),
            look.blushColor.withOpacity(0),
          ],
        ).createShader(Rect.fromCenter(
            center: Offset(bx, cheekY), width: blushW, height: blushH));

      canvas.drawOval(
        Rect.fromCenter(center: Offset(bx, cheekY), width: blushW, height: blushH),
        blushPaint,
      );
    }
  }

  // ── Eye Shadow ────────────────────────────────────────────────────────────
  void _paintEyeShadow(
      Canvas canvas, Face face, double scaleX, double scaleY, double faceW) {
    for (final contourType in [
      FaceContourType.leftEye,
      FaceContourType.rightEye,
    ]) {
      final contour = face.contours[contourType];
      if (contour == null || contour.points.length < 4) continue;

      final pts = contour.points
          .map((p) => Offset(_mx(p.x.toDouble(), scaleX), p.y * scaleY))
          .toList();

      final minY = pts.map((p) => p.dy).reduce(min);
      final maxY = pts.map((p) => p.dy).reduce(max);
      final minX = pts.map((p) => p.dx).reduce(min);
      final maxX = pts.map((p) => p.dx).reduce(max);
      final eyeH = maxY - minY;
      final eyeW = maxX - minX;
      final eyeCX = (minX + maxX) / 2;
      final eyeCY = (minY + maxY) / 2;

      // Shadow fades from the lash line upward
      final shadowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            look.eyeColor.withOpacity(look.eyeOpacity * intensity),
            look.eyeColor.withOpacity((look.eyeOpacity * intensity) * 0.4),
            look.eyeColor.withOpacity(0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(
            minX, minY - eyeH * 0.8, eyeW, eyeH * 1.8));

      // Draw shadow area above the eye
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(eyeCX, eyeCY - eyeH * 0.3),
          width: eyeW * 1.1,
          height: eyeH * 1.6,
        ),
        shadowPaint,
      );
    }
  }

  // ── Highlight ─────────────────────────────────────────────────────────────
  void _paintHighlight(Canvas canvas, Face face, double scaleX, double scaleY,
      double faceW, double centerX) {
    final box = face.boundingBox;
    final noseBridge = face.contours[FaceContourType.noseBridge];

    // Nose bridge highlight
    if (noseBridge != null && noseBridge.points.length >= 2) {
      final top = noseBridge.points.first;
      final bot = noseBridge.points.last;
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.15 * intensity)
        ..strokeWidth = faceW * 0.025
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(_mx(top.x.toDouble(), scaleX), top.y * scaleY),
        Offset(_mx(bot.x.toDouble(), scaleX), bot.y * scaleY),
        highlightPaint,
      );
    }

    // Cupid's bow / philtrum highlight
    final philtrumY = (box.top + box.height * 0.72) * scaleY;
    final philtrumPaint = Paint()
      ..shader = RadialGradient(colors: [
        Colors.white.withOpacity(0.20 * intensity),
        Colors.transparent,
      ]).createShader(Rect.fromCenter(
          center: Offset(centerX, philtrumY),
          width: faceW * 0.12,
          height: faceW * 0.06));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX, philtrumY),
          width: faceW * 0.12,
          height: faceW * 0.06),
      philtrumPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ARMakeupPainter old) =>
      old.faces != faces || old.look != look || old.intensity != intensity;
}