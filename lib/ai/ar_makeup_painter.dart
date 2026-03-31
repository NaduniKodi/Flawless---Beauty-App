// lib/widgets/ar_makeup_painter.dart
// v4 — Realistic false-lash strip effect

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════════════════
enum BlushStyle  { cheekApple, draping, sunKissed, editorial }
enum LinerStyle  { none, tightline, classic, winged, dramatic }
enum LashStyle   { none, natural, voluminous, cat, doll }
enum BrowStyle   { natural, defined, bold, feathery }

// ═══════════════════════════════════════════════════════════════════════════════
// LOOK MODEL
// ═══════════════════════════════════════════════════════════════════════════════
class ARMakeupLook {
  final String id, label, emoji;
  final Color  lipColor;
  final double lipOpacity;
  final bool   lipGloss;
  final Color  blushColor;
  final double blushOpacity;
  final BlushStyle blushStyle;
  final Color  eyeLidColor, eyeCreaseColor, eyeInnerColor;
  final double eyeOpacity;
  final Color  linerColor;
  final double linerWidth;
  final LinerStyle linerStyle;
  final bool      showLashes;
  final LashStyle  lashStyle;
  final Color  contourColor;
  final double contourOpacity;
  final Color  highlightColor;
  final double highlightOpacity;
  final bool   showNoseContour, showBrowBone;
  final Color  browColor;
  final double browOpacity;
  final BrowStyle browStyle;

  const ARMakeupLook({
    required this.id, required this.label, required this.emoji,
    required this.lipColor,
    this.lipOpacity = 0.65, this.lipGloss = false,
    required this.blushColor,
    this.blushOpacity = 0.28, this.blushStyle = BlushStyle.cheekApple,
    required this.eyeLidColor, required this.eyeCreaseColor,
    this.eyeInnerColor = const Color(0xFFFFE8D6),
    this.eyeOpacity = 0.42,
    this.linerColor = const Color(0xFF1A0A0A), this.linerWidth = 0.007,
    this.linerStyle = LinerStyle.classic,
    this.showLashes = true, this.lashStyle = LashStyle.natural,
    this.contourColor = const Color(0xFF8B6352), this.contourOpacity = 0.22,
    this.highlightColor = const Color(0xFFFFF5E0), this.highlightOpacity = 0.40,
    this.showNoseContour = true, this.showBrowBone = true,
    this.browColor = const Color(0xFF4A3728),
    this.browOpacity = 0.45, this.browStyle = BrowStyle.natural,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRESETS
// ═══════════════════════════════════════════════════════════════════════════════
const List<ARMakeupLook> arMakeupPresets = [

  ARMakeupLook(
    id: 'natural', label: 'Natural', emoji: '🌸',
    lipColor: Color(0xFFCB7B72), lipOpacity: 0.55, lipGloss: true,
    blushColor: Color(0xFFEA9080), blushOpacity: 0.22, blushStyle: BlushStyle.cheekApple,
    eyeLidColor: Color(0xFFB8936A), eyeCreaseColor: Color(0xFF8B5F3C),
    eyeInnerColor: Color(0xFFFFF0E0), eyeOpacity: 0.35,
    linerColor: Color(0xFF1C0C06), linerWidth: 0.005, linerStyle: LinerStyle.tightline,
    showLashes: true, lashStyle: LashStyle.natural,
    contourColor: Color(0xFF9B7060), contourOpacity: 0.18,
    highlightColor: Color(0xFFFFF8F0), highlightOpacity: 0.32,
    showNoseContour: true, showBrowBone: true,
    browColor: Color(0xFF5A4030), browOpacity: 0.42, browStyle: BrowStyle.natural,
  ),

  ARMakeupLook(
    id: 'soft_glam', label: 'Soft Glam', emoji: '✨',
    lipColor: Color(0xFFAD3E5E), lipOpacity: 0.68, lipGloss: true,
    blushColor: Color(0xFFE488AC), blushOpacity: 0.28, blushStyle: BlushStyle.cheekApple,
    eyeLidColor: Color(0xFF906080), eyeCreaseColor: Color(0xFF5A2848),
    eyeInnerColor: Color(0xFFFFE8F0), eyeOpacity: 0.45,
    linerColor: Color(0xFF0E0410), linerWidth: 0.007, linerStyle: LinerStyle.winged,
    showLashes: true, lashStyle: LashStyle.voluminous,
    contourColor: Color(0xFF8A5848), contourOpacity: 0.24,
    highlightColor: Color(0xFFFFF0C8), highlightOpacity: 0.42,
    showNoseContour: true, showBrowBone: true,
    browColor: Color(0xFF3A2030), browOpacity: 0.50, browStyle: BrowStyle.defined,
  ),

  ARMakeupLook(
    id: 'bold_red', label: 'Bold Red', emoji: '💋',
    lipColor: Color(0xFFC81020), lipOpacity: 0.80, lipGloss: false,
    blushColor: Color(0xFFCC6858), blushOpacity: 0.22, blushStyle: BlushStyle.cheekApple,
    eyeLidColor: Color(0xFF2A1808), eyeCreaseColor: Color(0xFF0A0506),
    eyeInnerColor: Color(0xFFFFF0E0), eyeOpacity: 0.50,
    linerColor: Color(0xFF060000), linerWidth: 0.009, linerStyle: LinerStyle.dramatic,
    showLashes: true, lashStyle: LashStyle.voluminous,
    contourColor: Color(0xFF7A4838), contourOpacity: 0.28,
    highlightColor: Color(0xFFFFF8E0), highlightOpacity: 0.38,
    showNoseContour: true, showBrowBone: false,
    browColor: Color(0xFF160606), browOpacity: 0.55, browStyle: BrowStyle.bold,
  ),

  ARMakeupLook(
    id: 'smoky', label: 'Smoky', emoji: '🌑',
    lipColor: Color(0xFF3D1820), lipOpacity: 0.72, lipGloss: false,
    blushColor: Color(0xFF806068), blushOpacity: 0.20, blushStyle: BlushStyle.editorial,
    eyeLidColor: Color(0xFF1A1A2A), eyeCreaseColor: Color(0xFF060610),
    eyeInnerColor: Color(0xFF3C3C58), eyeOpacity: 0.68,
    linerColor: Color(0xFF020208), linerWidth: 0.011, linerStyle: LinerStyle.dramatic,
    showLashes: true, lashStyle: LashStyle.cat,
    contourColor: Color(0xFF504050), contourOpacity: 0.32,
    highlightColor: Color(0xFFE8E0FF), highlightOpacity: 0.38,
    showNoseContour: true, showBrowBone: true,
    browColor: Color(0xFF080816), browOpacity: 0.62, browStyle: BrowStyle.bold,
  ),

  ARMakeupLook(
    id: 'coral', label: 'Coral', emoji: '🍊',
    lipColor: Color(0xFFDA5628), lipOpacity: 0.72, lipGloss: true,
    blushColor: Color(0xFFEE8858), blushOpacity: 0.26, blushStyle: BlushStyle.sunKissed,
    eyeLidColor: Color(0xFF9A5530), eyeCreaseColor: Color(0xFF6A300E),
    eyeInnerColor: Color(0xFFFFE8C0), eyeOpacity: 0.42,
    linerColor: Color(0xFF140800), linerWidth: 0.006, linerStyle: LinerStyle.winged,
    showLashes: true, lashStyle: LashStyle.natural,
    contourColor: Color(0xFF8A5830), contourOpacity: 0.22,
    highlightColor: Color(0xFFFFF0C0), highlightOpacity: 0.40,
    showNoseContour: true, showBrowBone: true,
    browColor: Color(0xFF3C2008), browOpacity: 0.46, browStyle: BrowStyle.feathery,
  ),

  ARMakeupLook(
    id: 'berry', label: 'Berry', emoji: '🫐',
    lipColor: Color(0xFF681858), lipOpacity: 0.76, lipGloss: false,
    blushColor: Color(0xFFAC6490), blushOpacity: 0.26, blushStyle: BlushStyle.draping,
    eyeLidColor: Color(0xFF481060), eyeCreaseColor: Color(0xFF1C082E),
    eyeInnerColor: Color(0xFFE8C8FF), eyeOpacity: 0.55,
    linerColor: Color(0xFF0C0012), linerWidth: 0.008, linerStyle: LinerStyle.winged,
    showLashes: true, lashStyle: LashStyle.doll,
    contourColor: Color(0xFF683858), contourOpacity: 0.26,
    highlightColor: Color(0xFFF8E8FF), highlightOpacity: 0.44,
    showNoseContour: true, showBrowBone: true,
    browColor: Color(0xFF220630), browOpacity: 0.55, browStyle: BrowStyle.defined,
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// PAINTER
// ═══════════════════════════════════════════════════════════════════════════════
class ARMakeupPainter extends CustomPainter {
  final List<Face>   faces;
  final Size         imageSize;
  final ARMakeupLook look;
  final bool         mirrorX;
  final double       intensity;

  const ARMakeupPainter({
    required this.faces,
    required this.imageSize,
    required this.look,
    this.mirrorX  = true,
    this.intensity = 1.0,
  });

  double  _mx(double x, double sx) =>
      mirrorX ? (imageSize.width - x) * sx : x * sx;
  Offset  _map(double x, double y, double sx, double sy) =>
      Offset(_mx(x, sx), y * sy);
  Offset  _mapPt(Point<int> p, double sx, double sy) =>
      _map(p.x.toDouble(), p.y.toDouble(), sx, sy);
  double  _alpha(double base) => (base * intensity).clamp(0.0, 1.0);

  Paint _fillPaint(Color c, double a) => Paint()
    ..color = c.withOpacity(_alpha(a))
    ..style = PaintingStyle.fill;

  Paint _strokePaint(Color c, double a, double w,
      {StrokeCap cap = StrokeCap.round}) =>
      Paint()
        ..color      = c.withOpacity(_alpha(a))
        ..style      = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap  = cap
        ..strokeJoin = StrokeJoin.round;

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize == Size.zero || faces.isEmpty) return;
    final sx = size.width  / imageSize.width;
    final sy = size.height / imageSize.height;

    for (final face in faces) {
      final box  = face.boundingBox;
      final fW   = box.width  * sx;
      final fH   = box.height * sy;
      final cx   = _mx(box.center.dx, sx);
      final topY = box.top * sy;

      _drawCheekContour(canvas, face, sx, sy, fW, fH, cx, topY);
      _drawNoseContour (canvas, face, sx, sy, fW, fH, cx, topY);
      _drawBlush       (canvas, face, sx, sy, fW, fH, cx, topY);
      _drawEyeShadow   (canvas, face, sx, sy, fW, fH);
      _drawHighlight   (canvas, face, sx, sy, fW, fH, cx, topY);
      _drawBrows       (canvas, face, sx, sy, fW, fH);
      _drawEyeliner    (canvas, face, sx, sy, fW);
      _drawLashes      (canvas, face, sx, sy, fW, fH);
      _drawLips        (canvas, face, sx, sy, fW, fH, cx, topY);
    }
  }

  // ── 1. Cheek contour ──────────────────────────────────────────────────────
  void _drawCheekContour(Canvas canvas, Face face,
      double sx, double sy, double fW, double fH, double cx, double topY) {
    if (look.contourOpacity < 0.01) return;
    final cheekY = topY + fH * 0.61;
    final offX   = fW  * 0.27;
    final w = fW * 0.28; final h = fH * 0.09;
    for (final s in [-1.0, 1.0]) {
      final bx = cx + s * offX;
      canvas.save();
      canvas.translate(bx, cheekY);
      canvas.rotate(s * 0.20);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        Paint()..shader = RadialGradient(colors: [
          look.contourColor.withOpacity(_alpha(look.contourOpacity)),
          look.contourColor.withOpacity(0),
        ]).createShader(
            Rect.fromCenter(center: Offset.zero, width: w, height: h)),
      );
      canvas.restore();
    }
  }

  // ── 2. Nose contour ───────────────────────────────────────────────────────
  void _drawNoseContour(Canvas canvas, Face face,
      double sx, double sy, double fW, double fH, double cx, double topY) {
    if (!look.showNoseContour || look.contourOpacity < 0.01) return;
    final op      = _alpha(look.contourOpacity * 0.70).clamp(0.0, 0.25);
    final sideOff = fW * 0.052;
    final sideW   = fW * 0.028;

    final bridge = face.contours[FaceContourType.noseBridge];
    double startY = topY + fH * 0.37;
    double endY   = topY + fH * 0.66;
    double baseCX = cx;
    if (bridge != null && bridge.points.length >= 2) {
      final bTop = _mapPt(bridge.points.first, sx, sy);
      final bBot = _mapPt(bridge.points.last,  sx, sy);
      startY = bTop.dy; endY = bBot.dy; baseCX = bTop.dx;
    }
    for (final s in [-1.0, 1.0]) {
      final x  = baseCX + s * sideOff;
      final h  = (endY - startY).abs().clamp(fH * 0.10, fH * 0.32);
      final rc = Rect.fromCenter(
          center: Offset(x, startY + h / 2), width: sideW, height: h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rc, Radius.circular(sideW / 2)),
        Paint()..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            look.contourColor.withOpacity(0),
            look.contourColor.withOpacity(op),
            look.contourColor.withOpacity(op * 0.5),
            look.contourColor.withOpacity(0),
          ],
          stops: const [0.0, 0.35, 0.75, 1.0],
        ).createShader(rc),
      );
    }
  }

  // ── 3. Blush ──────────────────────────────────────────────────────────────
  void _drawBlush(Canvas canvas, Face face,
      double sx, double sy, double fW, double fH, double cx, double topY) {
    final op = look.blushOpacity;
    if (op < 0.01) return;
    final c = look.blushColor;
    switch (look.blushStyle) {
      case BlushStyle.cheekApple:
        final y = topY + fH * 0.565; final offX = fW * 0.275;
        final w = fW * 0.26; final h = fH * 0.15;
        for (final s in [-1.0, 1.0]) {
          final bx = cx + s * offX;
          canvas.drawOval(Rect.fromCenter(center: Offset(bx, y), width: w, height: h),
            Paint()..shader = RadialGradient(colors: [
              c.withOpacity(_alpha(op)), c.withOpacity(_alpha(op * 0.35)), c.withOpacity(0),
            ], stops: const [0.0, 0.55, 1.0]).createShader(
                Rect.fromCenter(center: Offset(bx, y), width: w, height: h)));
        }
      case BlushStyle.draping:
        for (final s in [-1.0, 1.0]) {
          final bx = cx + s * fW * 0.38; final by = topY + fH * 0.40;
          canvas.save(); canvas.translate(bx, by); canvas.rotate(s * -0.28);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: fW * 0.18, height: fH * 0.34),
            Paint()..shader = RadialGradient(colors: [
              c.withOpacity(_alpha(op)), c.withOpacity(0),
            ]).createShader(Rect.fromCenter(center: Offset.zero, width: fW * 0.18, height: fH * 0.34)));
          canvas.restore();
        }
      case BlushStyle.sunKissed:
        final y = topY + fH * 0.52; final w = fW * 0.68; final h = fH * 0.075;
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, y), width: w, height: h),
          Paint()..shader = LinearGradient(colors: [
            c.withOpacity(0), c.withOpacity(_alpha(op * 0.55)),
            c.withOpacity(_alpha(op * 0.80)), c.withOpacity(_alpha(op * 0.55)), c.withOpacity(0),
          ], stops: const [0.0, 0.15, 0.5, 0.85, 1.0]).createShader(
              Rect.fromCenter(center: Offset(cx, y), width: w, height: h)));
      case BlushStyle.editorial:
        for (final s in [-1.0, 1.0]) {
          final bx = cx + s * fW * 0.28; final by = topY + fH * 0.47;
          canvas.save(); canvas.translate(bx, by); canvas.rotate(s * 0.32);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: fW * 0.20, height: fH * 0.09),
            Paint()..shader = RadialGradient(colors: [
              c.withOpacity(_alpha(op)), c.withOpacity(0),
            ]).createShader(Rect.fromCenter(center: Offset.zero, width: fW * 0.20, height: fH * 0.09)));
          canvas.restore();
        }
    }
  }

  // ── 4. Eye shadow ─────────────────────────────────────────────────────────
  void _drawEyeShadow(Canvas canvas, Face face,
      double sx, double sy, double fW, double fH) {
    final op = look.eyeOpacity;
    if (op < 0.01) return;
    for (final type in [FaceContourType.leftEye, FaceContourType.rightEye]) {
      final c = face.contours[type];
      if (c == null || c.points.length < 6) continue;
      final pts  = c.points.map((p) => _mapPt(p, sx, sy)).toList();
      final minX = pts.map((p) => p.dx).reduce(min);
      final maxX = pts.map((p) => p.dx).reduce(max);
      final minY = pts.map((p) => p.dy).reduce(min);
      final maxY = pts.map((p) => p.dy).reduce(max);
      final eW = maxX - minX; final eH = maxY - minY;
      final eCX = (minX + maxX) / 2; final eCY = (minY + maxY) / 2;

      // Lid
      canvas.drawOval(
        Rect.fromCenter(center: Offset(eCX, eCY + eH * 0.15), width: eW * 1.05, height: eH * 1.15),
        Paint()
          ..shader = LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors: [look.eyeLidColor.withOpacity(_alpha(op)),
              look.eyeLidColor.withOpacity(_alpha(op * 0.45)), look.eyeLidColor.withOpacity(0)],
            stops: const [0.0, 0.55, 1.0]).createShader(Rect.fromLTWH(minX, eCY, eW, eH * 1.15))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
      // Crease
      final cY = minY - eH * 0.45;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(eCX, cY + eH * 0.35), width: eW * 0.80, height: eH * 0.80),
        Paint()
          ..shader = LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors: [look.eyeCreaseColor.withOpacity(_alpha(op * 0.75)),
              look.eyeCreaseColor.withOpacity(0)]).createShader(Rect.fromLTWH(minX, cY, eW, eH * 0.80))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
      );
      // Inner corner
      final innerX = type == FaceContourType.leftEye ? maxX : minX;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(innerX, eCY), width: eW * 0.22, height: eH * 0.55),
        Paint()..shader = RadialGradient(colors: [
          look.eyeInnerColor.withOpacity(_alpha(op * 0.45)), look.eyeInnerColor.withOpacity(0),
        ]).createShader(Rect.fromCenter(
            center: Offset(innerX, eCY), width: eW * 0.22, height: eH * 0.55)),
      );
    }
  }

  // ── 5. Highlight ──────────────────────────────────────────────────────────
  void _drawHighlight(Canvas canvas, Face face,
      double sx, double sy, double fW, double fH, double cx, double topY) {
    final op = look.highlightOpacity;
    if (op < 0.01) return;
    final hc = look.highlightColor;
    if (look.showBrowBone) {
      for (final t in [FaceContourType.leftEyebrowTop, FaceContourType.rightEyebrowTop]) {
        final brow = face.contours[t];
        if (brow == null || brow.points.isEmpty) continue;
        final bpts = brow.points.map((p) => _mapPt(p, sx, sy)).toList();
        final bMinX = bpts.map((e) => e.dx).reduce(min);
        final bMaxX = bpts.map((e) => e.dx).reduce(max);
        final avgY  = bpts.map((e) => e.dy).reduce((a, b) => a + b) / bpts.length;
        final bW    = (bMaxX - bMinX) * 0.75;
        canvas.drawOval(
          Rect.fromCenter(center: Offset((bMinX + bMaxX) / 2, avgY - fH * 0.018),
              width: bW, height: fH * 0.036),
          Paint()..shader = RadialGradient(colors: [
            hc.withOpacity(_alpha(op * 0.50)), hc.withOpacity(0),
          ]).createShader(Rect.fromCenter(
              center: Offset((bMinX + bMaxX) / 2, avgY - fH * 0.018),
              width: bW, height: fH * 0.036)),
        );
      }
    }
    // Cheekbone
    final chkY = topY + fH * 0.50; final offX = fW * 0.305;
    final chkW = fW * 0.17; final chkH = fH * 0.055;
    for (final s in [-1.0, 1.0]) {
      final bx = cx + s * offX;
      canvas.save(); canvas.translate(bx, chkY); canvas.rotate(s * 0.16);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: chkW, height: chkH),
        Paint()..shader = RadialGradient(colors: [
          hc.withOpacity(_alpha(op * 0.60)), hc.withOpacity(0),
        ]).createShader(Rect.fromCenter(center: Offset.zero, width: chkW, height: chkH)));
      canvas.restore();
    }
    // Cupid's bow
    final philY = topY + fH * 0.712;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, philY), width: fW * 0.10, height: fH * 0.035),
      Paint()..shader = RadialGradient(colors: [
        hc.withOpacity(_alpha(op * 0.45)), hc.withOpacity(0),
      ]).createShader(Rect.fromCenter(center: Offset(cx, philY), width: fW * 0.10, height: fH * 0.035)));
  }

  // ── 6. Brows ──────────────────────────────────────────────────────────────
  void _drawBrows(Canvas canvas, Face face,
      double sx, double sy, double fW, double fH) {
    final op = look.browOpacity;
    if (op < 0.01) return;
    for (final pair in [
      [FaceContourType.leftEyebrowTop,  FaceContourType.leftEyebrowBottom],
      [FaceContourType.rightEyebrowTop, FaceContourType.rightEyebrowBottom],
    ]) {
      final topC = face.contours[pair[0]];
      final botC = face.contours[pair[1]];
      if (topC == null || botC == null) continue;
      if (topC.points.isEmpty || botC.points.isEmpty) continue;
      final tPts = topC.points.map((p) => _mapPt(p, sx, sy)).toList();
      final bPts = botC.points.map((p) => _mapPt(p, sx, sy)).toList();

      final path = Path()..moveTo(tPts.first.dx, tPts.first.dy);
      for (final p in tPts.skip(1)) path.lineTo(p.dx, p.dy);
      for (final p in bPts.reversed) path.lineTo(p.dx, p.dy);
      path.close();

      final all  = [...tPts, ...bPts];
      final minX = all.map((e) => e.dx).reduce(min);
      final maxX = all.map((e) => e.dx).reduce(max);
      final minY = all.map((e) => e.dy).reduce(min);
      final maxY = all.map((e) => e.dy).reduce(max);

      canvas.drawPath(path, Paint()
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [look.browColor.withOpacity(_alpha(op * 0.60)),
            look.browColor.withOpacity(_alpha(op)), look.browColor.withOpacity(_alpha(op * 0.65))],
        ).createShader(Rect.fromLTRB(minX, minY, maxX, maxY))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal,
            look.browStyle == BrowStyle.bold ? 0.8 : 1.2));

      if (look.browStyle == BrowStyle.feathery || look.browStyle == BrowStyle.natural) {
        _addBrowStrokes(canvas, tPts, bPts, op);
      }
    }
  }

  void _addBrowStrokes(Canvas canvas, List<Offset> tPts, List<Offset> bPts, double op) {
    final rng = Random(99); final count = tPts.length + 4;
    for (int i = 0; i < count; i++) {
      final t    = i / count;
      final tIdx = (t * (tPts.length - 1)).round().clamp(0, tPts.length - 1);
      final bIdx = (t * (bPts.length - 1)).round().clamp(0, bPts.length - 1);
      final jit  = Offset(rng.nextDouble() * 1.2 - 0.6, rng.nextDouble() * 0.8 - 0.4);
      canvas.drawLine(bPts[bIdx] + jit, tPts[tIdx] + jit, Paint()
        ..color = look.browColor.withOpacity(_alpha(op * 0.35))
        ..strokeWidth = 0.7 ..style = PaintingStyle.stroke ..strokeCap = StrokeCap.round);
    }
  }

  // ── 7. Eyeliner ───────────────────────────────────────────────────────────
  void _drawEyeliner(Canvas canvas, Face face,
      double sx, double sy, double fW) {
    if (look.linerStyle == LinerStyle.none) return;
    final lw = fW * look.linerWidth;
    final op = intensity.clamp(0.0, 1.0);

    for (final type in [FaceContourType.leftEye, FaceContourType.rightEye]) {
      final c = face.contours[type];
      if (c == null || c.points.length < 6) continue;
      final pts   = c.points.map((p) => _mapPt(p, sx, sy)).toList();
      final upper = pts.sublist(0, (pts.length / 2).ceil());

      final path = Path()..moveTo(upper.first.dx, upper.first.dy);
      for (final p in upper.skip(1)) path.lineTo(p.dx, p.dy);
      canvas.drawPath(path, _strokePaint(look.linerColor, op, lw));

      if (look.linerStyle == LinerStyle.tightline) {
        final mid = upper.sublist(
            (upper.length * 0.25).round(), (upper.length * 0.75).round());
        if (mid.length >= 2) {
          final mp = Path()..moveTo(mid.first.dx, mid.first.dy);
          for (final p in mid.skip(1)) mp.lineTo(p.dx, p.dy);
          canvas.drawPath(mp, _strokePaint(look.linerColor, op * 0.50, lw * 1.5));
        }
      }
      if (look.linerStyle == LinerStyle.winged || look.linerStyle == LinerStyle.dramatic) {
        _paintWing(canvas, type, upper, fW, lw, op);
      }
      if (look.linerStyle == LinerStyle.dramatic) {
        final lower = pts.sublist((pts.length / 2).ceil());
        if (lower.isNotEmpty) {
          final lp = Path()..moveTo(lower.first.dx, lower.first.dy);
          for (final p in lower.skip(1)) lp.lineTo(p.dx, p.dy);
          canvas.drawPath(lp, _strokePaint(look.linerColor, op * 0.45, lw * 0.60));
        }
      }
    }
  }

  void _paintWing(Canvas canvas, FaceContourType type,
      List<Offset> upper, double fW, double lw, double op) {
    if (upper.length < 3) return;
    final isLeft = type == FaceContourType.leftEye;
    final corner = isLeft ? upper.last  : upper.first;
    final ref    = isLeft ? upper[max(0, upper.length - 3)] : upper[min(2, upper.length - 1)];
    final dir    = _normalize(corner - ref);
    final len    = fW * (look.linerStyle == LinerStyle.dramatic ? 0.048 : 0.032);
    final ang    = isLeft ? -0.42 : 0.42;
    final rot    = Offset(dir.dx * cos(ang) - dir.dy * sin(ang),
                          dir.dx * sin(ang) + dir.dy * cos(ang));
    final tip    = corner + rot * len;
    canvas.drawLine(corner, tip, _strokePaint(look.linerColor, op, lw));
    if (look.linerStyle == LinerStyle.dramatic && upper.length >= 5) {
      final inner = isLeft ? upper[upper.length - 4] : upper[3];
      canvas.drawPath(
        Path()..moveTo(corner.dx, corner.dy)..lineTo(tip.dx, tip.dy)
              ..lineTo(inner.dx, inner.dy - lw * 0.5)..close(),
        _fillPaint(look.linerColor, op));
    }
  }

  // ── 8. LASHES — false-lash strip + fanned fibres ─────────────────────────
  void _drawLashes(Canvas canvas, Face face,
      double sx, double sy, double fW, double fH) {
    if (!look.showLashes || look.lashStyle == LashStyle.none) return;
    final op = intensity.clamp(0.0, 1.0);

    for (final type in [FaceContourType.leftEye, FaceContourType.rightEye]) {
      final c = face.contours[type];
      if (c == null || c.points.length < 6) continue;
      final pts   = c.points.map((p) => _mapPt(p, sx, sy)).toList();
      final upper = pts.sublist(0, (pts.length / 2).ceil());
      _paintLashBand   (canvas, upper, type, fW, fH, op);
      _paintLashFibres (canvas, upper, type, fW, fH, op);
    }
  }

  /// Thin solid band glued to the lash line — the false-lash band.
  void _paintLashBand(Canvas canvas, List<Offset> upper,
      FaceContourType type, double fW, double fH, double op) {
    if (upper.length < 2) return;
    final bandH = fH * 0.010;
    final outer = upper;
    final inner = upper.map((p) => p.translate(0, -bandH)).toList();

    final path = Path()..moveTo(outer.first.dx, outer.first.dy);
    for (final p in outer.skip(1)) path.lineTo(p.dx, p.dy);
    for (final p in inner.reversed) path.lineTo(p.dx, p.dy);
    path.close();

    canvas.drawPath(path, Paint()
      ..color       = look.linerColor.withOpacity((_alpha(op) * 0.90).clamp(0, 1))
      ..style       = PaintingStyle.fill
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.5));
  }

  /// Individual bezier lash fibres — always pointing upward, fan profile.
  void _paintLashFibres(Canvas canvas, List<Offset> upper,
      FaceContourType type, double fW, double fH, double op) {
    if (upper.length < 2) return;
    final isLeft = type == FaceContourType.leftEye;
    final rng    = Random(isLeft ? 3 : 17);
    final count  = _lashCount();
    final maxLen = fH * 0.055; // absolute cap — prevents huge spikes
    final baseLen = min(fW * _lashLengthRatio(), maxLen);

    for (int i = 0; i < count; i++) {
      final t   = i / max(count - 1, 1);
      final idx = (t * (upper.length - 1)).round().clamp(0, upper.length - 1);
      final base = upper[idx];

      // Tangent along lash line
      Offset tan = const Offset(1, 0);
      if (idx > 0 && idx < upper.length - 1) {
        tan = _normalize(upper[idx + 1] - upper[idx - 1]);
      }
      // Normal perpendicular to lash line — force upward
      Offset norm = Offset(-tan.dy, tan.dx);
      if (norm.dy > 0) norm = -norm;

      // Style-driven length profile & curl
      final outerT = isLeft ? t : (1.0 - t);
      final lenMul  = _lashLengthProfile(outerT);
      final lashLen = baseLen * lenMul * (0.75 + rng.nextDouble() * 0.40);
      final curl    = _lashCurlAngle(outerT);

      final tipDir = Offset(
        norm.dx * cos(curl) - norm.dy * sin(curl),
        norm.dx * sin(curl) + norm.dy * cos(curl),
      );
      // Safety — if curl tilted it downward, revert to norm
      final dir = tipDir.dy <= 0 ? tipDir : norm;

      final tip  = base + dir * lashLen;
      // Control point gives natural upward arc
      final ctrl = base + dir * lashLen * 0.48 + Offset(0, -lashLen * 0.12);

      canvas.drawPath(
        Path()..moveTo(base.dx, base.dy)
              ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy),
        Paint()
          ..color       = look.linerColor.withOpacity(
              (op * (0.80 + rng.nextDouble() * 0.20)).clamp(0, 1))
          ..style       = PaintingStyle.stroke
          ..strokeWidth = fW * 0.0028 * (0.55 + rng.nextDouble() * 0.60)
          ..strokeCap   = StrokeCap.round,
      );
    }
  }

  int _lashCount() => switch (look.lashStyle) {
    LashStyle.none       => 0,
    LashStyle.natural    => 20,
    LashStyle.voluminous => 28,
    LashStyle.cat        => 24,
    LashStyle.doll       => 26,
  };

  double _lashLengthRatio() => switch (look.lashStyle) {
    LashStyle.none       => 0,
    LashStyle.natural    => 0.036,
    LashStyle.voluminous => 0.044,
    LashStyle.cat        => 0.042,
    LashStyle.doll       => 0.040,
  };

  /// Length multiplier across the lash line (outerT=1 = outer corner).
  double _lashLengthProfile(double outerT) => switch (look.lashStyle) {
    LashStyle.cat        => 0.55 + outerT * 0.72,  // short inner → long outer
    LashStyle.doll       => 0.65 + sin(outerT * pi) * 0.52, // peak in center
    LashStyle.voluminous => 0.85 + outerT * 0.22,  // uniformly long
    _                    => 0.60 + outerT * 0.42,  // natural ramp
  };

  /// Curl angle in radians — small values only.
  double _lashCurlAngle(double outerT) => switch (look.lashStyle) {
    LashStyle.cat        => 0.08 + outerT * 0.22, // outer lashes tilt out gently
    LashStyle.doll       => 0.10 + sin(outerT * pi) * 0.14,
    LashStyle.voluminous => 0.12,
    _                    => 0.08,
  };

  // ── 9. Lips ───────────────────────────────────────────────────────────────
  void _drawLips(Canvas canvas, Face face,
      double sx, double sy, double fW, double fH, double cx, double topY) {
    final op = look.lipOpacity;
    if (op < 0.01) return;
    final uTop = face.contours[FaceContourType.upperLipTop];
    final lBot = face.contours[FaceContourType.lowerLipBottom];
    final lTop = face.contours[FaceContourType.lowerLipTop];
    final uBot = face.contours[FaceContourType.upperLipBottom];

    if (uTop != null && uTop.points.length >= 4 &&
        lBot != null && lBot.points.length >= 4) {
      final upPts  = uTop.points.map((p) => _mapPt(p, sx, sy)).toList();
      final lowPts = lBot.points.map((p) => _mapPt(p, sx, sy)).toList().reversed.toList();
      final path   = Path()..moveTo(upPts.first.dx, upPts.first.dy);
      for (final p in upPts.skip(1)) path.lineTo(p.dx, p.dy);
      for (final p in lowPts)        path.lineTo(p.dx, p.dy);
      path.close();

      canvas.drawPath(path, _fillPaint(look.lipColor, op));
      canvas.drawPath(path, _strokePaint(look.lipColor._darken(0.12), op * 0.75, fW * 0.005));

      if (look.lipGloss && lTop != null && lTop.points.isNotEmpty) {
        final mid = _mapPt(lTop.points[lTop.points.length ~/ 2], sx, sy);
        final gW = fW * 0.14; final gH = fH * 0.024;
        canvas.drawOval(Rect.fromCenter(center: mid, width: gW, height: gH),
          Paint()..shader = RadialGradient(colors: [
            Colors.white.withOpacity(_alpha(0.50)), Colors.white.withOpacity(_alpha(0.14)), Colors.transparent,
          ], stops: const [0.0, 0.45, 1.0]).createShader(
              Rect.fromCenter(center: mid, width: gW, height: gH)));
        if (uBot != null && uBot.points.isNotEmpty) {
          final uMid = _mapPt(uBot.points[uBot.points.length ~/ 2], sx, sy);
          canvas.drawOval(Rect.fromCenter(center: uMid, width: gW * 0.52, height: gH * 0.65),
            Paint()..shader = RadialGradient(colors: [
              Colors.white.withOpacity(_alpha(0.26)), Colors.transparent,
            ]).createShader(Rect.fromCenter(center: uMid, width: gW * 0.52, height: gH * 0.65)));
        }
      }
    } else {
      final lipY = topY + fH * 0.775 + fH * 0.030;
      final rr   = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, lipY), width: fW * 0.36, height: fH * 0.055),
          Radius.circular(fH * 0.028));
      canvas.drawRRect(rr, _fillPaint(look.lipColor, op));
      canvas.drawRRect(rr, _strokePaint(look.lipColor._darken(0.12), op * 0.75, fW * 0.005));
    }
  }

  @override
  bool shouldRepaint(covariant ARMakeupPainter old) =>
      old.faces != faces || old.look != look || old.intensity != intensity;

  static Offset _normalize(Offset o) {
    final d = o.distance;
    return d == 0 ? o : o / d;
  }
}

extension _ColorDarken on Color {
  Color _darken(double amt) {
    final h = HSLColor.fromColor(this);
    return h.withLightness((h.lightness - amt).clamp(0.0, 1.0)).toColor();
  }
}