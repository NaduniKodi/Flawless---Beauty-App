// lib/services/makeup_analysis_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;

// ── Data Models ───────────────────────────────────────────────────────────────

class FaceFeatures {
  final String faceShape;
  final String noseShape;
  final String eyeShape;
  final String lipShape;
  final String eyebrowShape;
  final String skinUndertone;
  final double faceWidth;
  final double faceHeight;
  final String rawAIAnalysis;

  const FaceFeatures({
    required this.faceShape,
    required this.noseShape,
    required this.eyeShape,
    required this.lipShape,
    required this.eyebrowShape,
    required this.skinUndertone,
    required this.faceWidth,
    required this.faceHeight,
    required this.rawAIAnalysis,
  });

  factory FaceFeatures.fromJson(Map<String, dynamic> json) => FaceFeatures(
        faceShape:    json['face_shape']     ?? 'oval',
        noseShape:    json['nose_shape']     ?? 'button',
        eyeShape:     json['eye_shape']      ?? 'almond',
        lipShape:     json['lip_shape']      ?? 'full',
        eyebrowShape: json['eyebrow_shape']  ?? 'arched',
        skinUndertone:json['skin_undertone'] ?? 'neutral',
        faceWidth:    (json['face_width_ratio']  ?? 1.0).toDouble(),
        faceHeight:   (json['face_height_ratio'] ?? 1.0).toDouble(),
        rawAIAnalysis: json['analysis'] ?? '',
      );
}

class MakeupTutorial {
  final String title;
  final String channel;
  final String description;
  final String targetFeature;
  final String technique;
  final String difficulty;
  final String duration;
  final String searchQuery;
  final List<String> products;

  const MakeupTutorial({
    required this.title,
    required this.channel,
    required this.description,
    required this.targetFeature,
    required this.technique,
    required this.difficulty,
    required this.duration,
    required this.searchQuery,
    required this.products,
  });
}

class MakeupAnalysisResult {
  final FaceFeatures features;
  final List<MakeupTutorial> tutorials;
  final List<MakeupTip> quickTips;
  final String overallStyle;

  const MakeupAnalysisResult({
    required this.features,
    required this.tutorials,
    required this.quickTips,
    required this.overallStyle,
  });
}

class MakeupTip {
  final String emoji;
  final String title;
  final String body;
  final String feature;

  const MakeupTip({
    required this.emoji,
    required this.title,
    required this.body,
    required this.feature,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class MakeupAnalysisService {

  // ── Step 1: Geometric analysis using ML Kit face contours ─────────────────
  static FaceFeatures _deriveFromLandmarks(Face face) {
    final box = face.boundingBox;
    double faceWidth  = box.width;
    double faceHeight = box.height;

    // ── Face Shape using face outline contour ────────────────────────────────
    String faceShape = 'oval';
    final faceContour = face.contours[FaceContourType.face];

    if (faceContour != null && faceContour.points.length >= 20) {
      final pts = faceContour.points;
      final xs  = pts.map((p) => p.x.toDouble()).toList();
      final ys  = pts.map((p) => p.y.toDouble()).toList();

      final maxX = xs.reduce(math.max);
      final minX = xs.reduce(math.min);
      final maxY = ys.reduce(math.max);
      final minY = ys.reduce(math.min);

      faceWidth  = maxX - minX;
      faceHeight = maxY - minY;

      if (faceHeight > 0) {
        // Jaw: bottom 30% of face outline
        final jawThreshold = maxY - faceHeight * 0.30;
        final jawPts = pts.where((p) => p.y > jawThreshold).toList();
        final jawWidth = jawPts.isEmpty
            ? faceWidth * 0.75
            : jawPts.map((p) => p.x.toDouble()).reduce(math.max) -
              jawPts.map((p) => p.x.toDouble()).reduce(math.min);

        // Forehead: top 25% of face outline
        final foreheadThreshold = minY + faceHeight * 0.25;
        final foreheadPts = pts.where((p) => p.y < foreheadThreshold).toList();
        final foreheadWidth = foreheadPts.isEmpty
            ? faceWidth * 0.85
            : foreheadPts.map((p) => p.x.toDouble()).reduce(math.max) -
              foreheadPts.map((p) => p.x.toDouble()).reduce(math.min);

        final ratio         = faceWidth / faceHeight;
        final jawRatio      = jawWidth / faceWidth;
        final foreheadRatio = foreheadWidth / faceWidth;

        debugPrintAI('Face ratio=$ratio jaw=$jawRatio forehead=$foreheadRatio');

        if (ratio < 0.72) {
          faceShape = 'oblong';
        } else if (foreheadRatio > jawRatio + 0.14) {
          faceShape = 'heart';   // wide forehead, narrow jaw
        } else if (jawRatio < 0.62 && foreheadRatio < 0.70) {
          faceShape = 'diamond'; // both forehead & jaw narrow vs cheekbones
        } else if (ratio > 0.90 && jawRatio > 0.75) {
          faceShape = 'square';  // wide jaw, roughly as wide as tall
        } else if (ratio < 0.83 && jawRatio < 0.78) {
          faceShape = 'oval';    // longer than wide, tapered jaw
        } else {
          faceShape = 'round';
        }
      }
    } else {
      // Fallback: bounding box only — better-calibrated thresholds
      final ratio = faceWidth / (faceHeight == 0 ? 1 : faceHeight);
      debugPrintAI('Face contour unavailable, using bbox ratio=$ratio');
      if (ratio < 0.72)      faceShape = 'oblong';
      else if (ratio < 0.80) faceShape = 'oval';
      else if (ratio < 0.88) faceShape = 'heart';
      else if (ratio < 0.98) faceShape = 'round';
      else                   faceShape = 'square';
    }

    // ── Eye Shape ─────────────────────────────────────────────────────────────
    String eyeShape = 'almond';
    final leftEye  = face.contours[FaceContourType.leftEye];
    final rightEye = face.contours[FaceContourType.rightEye];
    final eyeContour = leftEye ?? rightEye;

    if (eyeContour != null && eyeContour.points.length >= 6) {
      final pts = eyeContour.points;
      final xs  = pts.map((p) => p.x.toDouble()).toList();
      final ys  = pts.map((p) => p.y.toDouble()).toList();

      final minX = xs.reduce(math.min);
      final maxX = xs.reduce(math.max);
      final minY = ys.reduce(math.min);
      final maxY = ys.reduce(math.max);

      final eyeW = maxX - minX;
      final eyeH = maxY - minY;

      if (eyeH > 0) {
        final aspect = eyeW / eyeH;

        // Corner tilt: compare Y at leftmost vs rightmost X
        final leftIdx  = xs.indexOf(minX);
        final rightIdx = xs.indexOf(maxX);
        final tilt = (ys[rightIdx] - ys[leftIdx]) / eyeH;

        debugPrintAI('Eye aspect=$aspect tilt=$tilt');

        if (aspect > 4.5) {
          eyeShape = 'hooded';
        } else if (aspect < 2.0) {
          eyeShape = 'round';
        } else if (tilt > 0.38) {
          eyeShape = 'downturned';
        } else if (tilt < -0.38) {
          eyeShape = 'upturned';
        } else {
          eyeShape = 'almond';
        }
      }
    }

    // ── Lip Shape ─────────────────────────────────────────────────────────────
    String lipShape = 'full';
    final upperLip = face.contours[FaceContourType.upperLipTop];
    final lowerLip = face.contours[FaceContourType.lowerLipBottom];

    if (upperLip != null && lowerLip != null &&
        upperLip.points.isNotEmpty && lowerLip.points.isNotEmpty) {
      final upperXs = upperLip.points.map((p) => p.x.toDouble()).toList();
      final lowerXs = lowerLip.points.map((p) => p.x.toDouble()).toList();
      final upperYs = upperLip.points.map((p) => p.y.toDouble()).toList();

      final upperWidth = upperXs.reduce(math.max) - upperXs.reduce(math.min);
      final lowerWidth = lowerXs.reduce(math.max) - lowerXs.reduce(math.min);

      // Cupid's bow: pronounced dip in the centre of the upper lip
      final upperMinY = upperYs.reduce(math.min);
      final upperMaxY = upperYs.reduce(math.max);
      final cupidDepth = upperMaxY - upperMinY;

      final lipRatio   = lowerWidth > 0 ? upperWidth / lowerWidth : 1.0;
      final widthRatio = faceWidth  > 0 ? upperWidth / faceWidth  : 0.35;

      debugPrintAI('Lip ratio=$lipRatio widthRatio=$widthRatio cupidDepth=$cupidDepth');

      if (cupidDepth > faceHeight * 0.024 && lipRatio > 0.92) {
        lipShape = 'cupids-bow';
      } else if (lipRatio > 1.12) {
        lipShape = 'wide';
      } else if (lipRatio < 0.88) {
        lipShape = 'pouty';
      } else if (widthRatio < 0.27) {
        lipShape = 'small';
      } else if (widthRatio > 0.42) {
        lipShape = 'full';
      } else {
        lipShape = 'thin';
      }
    }

    // ── Nose Shape ────────────────────────────────────────────────────────────
    String noseShape = 'button';
    final noseBridge = face.contours[FaceContourType.noseBridge];
    final noseBottom = face.contours[FaceContourType.noseBottom];

    if (noseBridge != null && noseBridge.points.length >= 2) {
      // Prefer noseBottom for width; fall back to bridge extent
      double noseW;
      if (noseBottom != null && noseBottom.points.isNotEmpty) {
        final bXs = noseBottom.points.map((p) => p.x.toDouble()).toList();
        noseW = bXs.reduce(math.max) - bXs.reduce(math.min);
      } else {
        final bXs = noseBridge.points.map((p) => p.x.toDouble()).toList();
        noseW = bXs.reduce(math.max) - bXs.reduce(math.min);
      }

      // Detect bridge bump (roman nose) by deviation from straight line
      double maxDeviation = 0;
      if (noseBridge.points.length >= 4) {
        final first = noseBridge.points.first;
        final last  = noseBridge.points.last;
        final dy    = (last.y - first.y).toDouble();
        for (final pt in noseBridge.points.skip(1).take(noseBridge.points.length - 2)) {
          final t = dy == 0 ? 0.5 : (pt.y - first.y) / dy;
          final expectedX = first.x + (last.x - first.x) * t;
          maxDeviation = math.max(maxDeviation, (pt.x - expectedX).abs().toDouble());
        }
      }

      final noseRatio = faceWidth > 0 ? noseW / faceWidth : 0.18;
      debugPrintAI('Nose ratio=$noseRatio bump=$maxDeviation');

      if (maxDeviation > faceWidth * 0.038) {
        noseShape = 'roman';
      } else if (noseRatio > 0.24) {
        noseShape = 'wide';
      } else if (noseRatio < 0.13) {
        noseShape = 'narrow';
      } else {
        noseShape = 'button';
      }
    }

    // ── Eyebrow Shape ─────────────────────────────────────────────────────────
    final eyebrowShape = _detectBrowShape(face, faceWidth);

    return FaceFeatures(
      faceShape:     faceShape,
      noseShape:     noseShape,
      eyeShape:      eyeShape,
      lipShape:      lipShape,
      eyebrowShape:  eyebrowShape,
      skinUndertone: 'neutral', // requires pixel-level color analysis
      faceWidth:     faceWidth,
      faceHeight:    faceHeight,
      rawAIAnalysis: 'Geometric analysis from ML Kit facial contours.',
    );
  }

  static String _detectBrowShape(Face face, double faceWidth) {
    final brow = face.contours[FaceContourType.leftEyebrowTop]
               ?? face.contours[FaceContourType.rightEyebrowTop];
    if (brow == null || brow.points.length < 4) return 'arched';

    final pts = brow.points;
    final xs  = pts.map((p) => p.x.toDouble()).toList();
    final ys  = pts.map((p) => p.y.toDouble()).toList();

    final minY    = ys.reduce(math.min);
    final maxY    = ys.reduce(math.max);
    final minX    = xs.reduce(math.min);
    final maxX    = xs.reduce(math.max);
    final browW   = maxX - minX;
    final archH   = maxY - minY;
    final peakX   = xs[ys.indexOf(minY)];
    final midX    = (minX + maxX) / 2;
    final peakOff = browW > 0 ? (peakX - midX).abs() / browW : 0;

    debugPrintAI('Brow archH=$archH browW=$browW peakOff=$peakOff');

    if (archH < browW * 0.06) return 'straight';
    if (peakOff < 0.15)       return 'rounded';
    if (archH > browW * 0.14) return 'arched';
    return 'arched';
  }

  // ── Step 2: AI enrichment (only when API key is set) ──────────────────────
  // TODO: Replace the empty string below with your OpenRouter API key.
  // Until you do, the app uses the geometric analysis above, which is already
  // significantly more accurate than the previous version.
  static const String _openRouterKey = ''; // ← paste your key here

  static Future<FaceFeatures> _enrichWithAI(
      String imagePath, FaceFeatures geometric) async {
    // Skip AI call entirely if no key is configured
    if (_openRouterKey.isEmpty) {
      debugPrintAI('AI enrichment skipped: no API key configured.');
      return geometric;
    }

    try {
      final imageBytes  = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openRouterKey',
        },
        body: jsonEncode({
          'model': 'google/gemini-flash-1.5',
          'max_tokens': 600,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                },
                {
                  'type': 'text',
                  'text': '''Analyze this face image and return ONLY a JSON object
(no markdown, no extra text) with these exact keys:
{
  "face_shape": "oval|round|square|heart|oblong|diamond",
  "nose_shape": "button|roman|snub|wide|narrow|aquiline",
  "eye_shape": "almond|round|hooded|monolid|upturned|downturned",
  "lip_shape": "full|thin|cupids-bow|wide|small|pouty",
  "eyebrow_shape": "arched|straight|rounded|s-shaped|bushy",
  "skin_undertone": "warm|cool|neutral",
  "analysis": "2-sentence description of overall features"
}''',
                },
              ],
            }
          ],
        }),
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data   = jsonDecode(response.body);
        final text   = data['choices'][0]['message']['content'] as String? ?? '';
        final clean  = text.replaceAll(RegExp(r'```json|```'), '').trim();
        final parsed = jsonDecode(clean) as Map<String, dynamic>;
        return FaceFeatures.fromJson({
          ...parsed,
          'face_width_ratio':  geometric.faceWidth,
          'face_height_ratio': geometric.faceHeight,
        });
      } else {
        debugPrintAI('AI returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrintAI('AI enrichment failed: $e');
    }
    return geometric;
  }

  // ── Step 3: Tutorial recommendations ──────────────────────────────────────
  static List<MakeupTutorial> buildTutorialsPublic(FaceFeatures f) => [
        _faceShapeTutorial(f.faceShape),
        _eyeTutorial(f.eyeShape),
        _lipTutorial(f.lipShape),
        _noseTutorial(f.noseShape),
        _browTutorial(f.eyebrowShape),
      ];

  static MakeupTutorial _faceShapeTutorial(String shape) {
    const map = {
      'oval': (
        'Oval Face Contouring & Highlighting',
        'Any technique works — focus on enhancing natural symmetry.',
        'oval face makeup contouring glow tutorial',
        ['Bronzer', 'Highlighter', 'Blush'],
      ),
      'round': (
        'Slim & Define a Round Face',
        'Use contouring under cheekbones and a matte bronzer along the hairline.',
        'round face contouring makeup tutorial slim',
        ['Contour powder', 'Matte bronzer', 'Vertical blush'],
      ),
      'square': (
        'Soften a Square Jawline',
        'Focus on softening the jaw and temples with circular blush placement.',
        'square face makeup soften jawline tutorial',
        ['Soft contour', 'Round brush blush', 'Subtle highlight'],
      ),
      'heart': (
        'Balance a Heart-Shaped Face',
        'Widen the forehead temples and define the jaw with contour.',
        'heart face shape makeup balance forehead jaw tutorial',
        ['Temple contour', 'Chin highlight', 'Wide blush'],
      ),
      'oblong': (
        'Shorten & Widen an Oblong Face',
        'Add blush horizontally and contour the hairline and chin.',
        'oblong long face makeup shorten tutorial',
        ['Horizontal blush', 'Hairline bronzer', 'Chin contour'],
      ),
      'diamond': (
        'Highlight a Diamond Face Shape',
        'Highlight forehead and chin; soften sharp cheekbones with blush.',
        'diamond face shape makeup highlight tutorial',
        ['Forehead highlighter', 'Chin highlight', 'Soft blush'],
      ),
    };
    final t = map[shape] ?? map['oval']!;
    return MakeupTutorial(
      title: t.$1, channel: 'NikkieTutorials · Robert Welsh · Hindash',
      description: t.$2, targetFeature: 'Face Shape',
      technique: 'Contouring & Highlighting', difficulty: 'Intermediate',
      duration: '15–20 min', searchQuery: t.$3, products: t.$4,
    );
  }

  static MakeupTutorial _eyeTutorial(String shape) {
    const map = {
      'almond': (
        'Almond Eyes: Classic Smoky & Cut Crease',
        'Play up your natural eye shape — almost any look works beautifully.',
        'almond eyes smoky cut crease eyeshadow tutorial',
        ['Eyeshadow palette', 'Liner', 'Mascara'],
      ),
      'round': (
        'Elongate Round Eyes with a Cat-Eye',
        'Extend liner outward and use darker shades on the outer corner.',
        'round eyes cat eye elongate makeup tutorial',
        ['Gel liner', 'Dark eyeshadow', 'Lengthening mascara'],
      ),
      'hooded': (
        'Open Up Hooded Eyes — No-Fail Technique',
        'Apply eyeshadow above the natural crease line so it shows when eyes are open.',
        'hooded eyes eyeshadow tutorial open up crease',
        ['Matte transition shade', 'Pencil liner', 'Volumizing mascara'],
      ),
      'monolid': (
        'Monolid Eye Makeup: Graphic & Bold Looks',
        'Create dimension with gradient shading from lash line upward.',
        'monolid eyes eyeshadow gradient tutorial',
        ['Eyeshadow', 'Lower lash liner', 'Dramatic lashes'],
      ),
      'upturned': (
        'Balance Upturned Eyes with Soft Shadow',
        'Lower the outer corner visually with darker shadow at the base.',
        'upturned eyes makeup balance tutorial',
        ['Matte shadow', 'Lower liner', 'Natural mascara'],
      ),
      'downturned': (
        'Lift Downturned Eyes with Winged Liner',
        'Create a lifted wing and apply light shades on the outer corner.',
        'downturned eyes lifted wing liner tutorial',
        ['Felt-tip liner', 'Light shimmer', 'Curling mascara'],
      ),
    };
    final t = map[shape] ?? map['almond']!;
    return MakeupTutorial(
      title: t.$1, channel: 'Lisa Eldridge · Wayne Goss · Jackie Aina',
      description: t.$2, targetFeature: 'Eye Shape',
      technique: 'Eyeshadow & Liner', difficulty: 'Beginner',
      duration: '10–15 min', searchQuery: t.$3, products: t.$4,
    );
  }

  static MakeupTutorial _lipTutorial(String shape) {
    const map = {
      'full': (
        'Full Lips: Enhance with Gloss & Ombre',
        'Use a slightly deeper liner to define, then gloss the center for dimension.',
        'full lips ombre gloss makeup tutorial',
        ['Lip liner', 'Gloss', 'Satin lipstick'],
      ),
      'thin': (
        'Make Thin Lips Look Fuller',
        'Over-line slightly above the natural lip, use nude liner and a light gloss.',
        'thin lips fuller overline makeup tutorial',
        ['Nude liner', 'Light gloss', 'Plumping lip balm'],
      ),
      'cupids-bow': (
        "Define a Cupid's Bow for Maximum Impact",
        "Trace the bow precisely, keep the corners soft for a romantic look.",
        "cupids bow lip liner define makeup tutorial",
        ['Matching lip liner', 'Matte lipstick', 'Concealer to clean edges'],
      ),
      'pouty': (
        'Play Up a Pouty Lower Lip',
        'Balance with a stronger upper liner and avoid over-lining the bottom.',
        'pouty lips balance makeup upper lip tutorial',
        ['Upper lip liner', 'Satin finish lipstick', 'Highlighter above bow'],
      ),
      'wide': (
        'Balance Wide Lips with Tonal Looks',
        'Keep liner within the natural line at corners; opt for tonal nudes.',
        'wide lips balance tonal nude makeup tutorial',
        ['Nude lipstick', 'Tonal liner', 'No-gloss finish'],
      ),
      'small': (
        'Build Volume on Small Lips',
        'Overline slightly with a nude liner for natural-looking fullness.',
        'small lips volume overline tutorial',
        ['Nude liner', 'Plumping gloss', 'Matte lipstick'],
      ),
    };
    final t = map[shape] ?? map['full']!;
    return MakeupTutorial(
      title: t.$1, channel: 'Lisa Eldridge · Charlotte Tilbury · Hindash',
      description: t.$2, targetFeature: 'Lip Shape',
      technique: 'Lip Liner & Color', difficulty: 'Beginner',
      duration: '5–10 min', searchQuery: t.$3, products: t.$4,
    );
  }

  static MakeupTutorial _noseTutorial(String shape) {
    return MakeupTutorial(
      title: shape == 'wide'
          ? 'Narrow a Wide Nose with Contour'
          : shape == 'narrow'
              ? 'Widen a Narrow Nose for Balance'
              : 'Nose Contouring for Your Shape',
      channel: 'NikkieTutorials · Hindash · Wayne Goss',
      description: shape == 'wide'
          ? 'Apply a matte contour down each side of the nose bridge and blend inward.'
          : 'Use a slim highlight stripe down the bridge to define without narrowing further.',
      targetFeature: 'Nose Shape', technique: 'Nose Contouring',
      difficulty: 'Intermediate', duration: '8–12 min',
      searchQuery: '$shape nose makeup contouring tutorial',
      products: ['Matte contour', 'Highlight pencil', 'Small blending brush'],
    );
  }

  static MakeupTutorial _browTutorial(String shape) {
    const map = {
      'arched': (
        'Define & Fill Arched Brows',
        'Use light feathery strokes to fill gaps; set with clear brow gel.',
        'arched eyebrows fill define tutorial',
      ),
      'straight': (
        'Add Subtle Arch to Straight Brows',
        'Trim slightly above the centre third and add a soft peak with a pencil.',
        'straight eyebrows add arch tutorial',
      ),
      'bushy': (
        'Tame & Groom Bushy Brows',
        'Brush upward, trim protruding hairs, define the lower edge cleanly.',
        'bushy eyebrows grooming taming tutorial',
      ),
      'rounded': (
        'Rounded Brows: Soft & Romantic Look',
        'Follow the natural curve and fill lightly; avoid sharp angles.',
        'rounded eyebrows soft fill tutorial',
      ),
    };
    final t = map[shape] ?? map['arched']!;
    return MakeupTutorial(
      title: t.$1, channel: 'Benefit · Anastasia Beverly Hills · Wayne Goss',
      description: t.$2, targetFeature: 'Eyebrows',
      technique: 'Brow Filling & Shaping', difficulty: 'Beginner',
      duration: '6–10 min', searchQuery: t.$3,
      products: ['Brow pencil', 'Clear brow gel', 'Spoolie brush'],
    );
  }

  // ── Step 4: Quick tips ─────────────────────────────────────────────────────
  static List<MakeupTip> buildTipsPublic(FaceFeatures f) => [
        MakeupTip(emoji: '✨', feature: 'Face Shape',
            title: '${_cap(f.faceShape)} Face Pro Tip',   body: _faceShapeTip(f.faceShape)),
        MakeupTip(emoji: '👁️', feature: 'Eyes',
            title: '${_cap(f.eyeShape)} Eye Hack',        body: _eyeTip(f.eyeShape)),
        MakeupTip(emoji: '💄', feature: 'Lips',
            title: '${_cap(f.lipShape)} Lip Trick',       body: _lipTip(f.lipShape)),
        MakeupTip(emoji: '🌟', feature: 'Skin',
            title: '${_cap(f.skinUndertone)} Undertone Colors', body: _undertoneTip(f.skinUndertone)),
      ];

  static String _faceShapeTip(String s) => {
        'oval':    'You can rock almost any makeup style — try bold techniques freely.',
        'round':   'Use vertical blush placement to elongate your face naturally.',
        'square':  'Soft rounded blush on the apples of cheeks will soften angular features.',
        'heart':   'Add definition along the jaw with a soft matte bronzer.',
        'oblong':  'Keep blush horizontal across cheeks to add the illusion of width.',
        'diamond': 'Highlight the chin tip to balance strong cheekbones.',
      }[s] ?? 'Enhance your natural symmetry with a balanced highlight and contour.';

  static String _eyeTip(String s) => {
        'almond':    'Smudge liner on the lower lash line for an effortless sultry look.',
        'round':     'A horizontal flick at the outer corner elongates beautifully.',
        'hooded':    'Always do your eye makeup with eyes open — apply above the crease.',
        'monolid':   'Graphic liner on the lash line creates instant definition.',
        'upturned':  'Blend dark shadow downward at the outer corner for balance.',
        'downturned':'Flick your liner upward past the outer corner to lift the eye.',
      }[s] ?? 'Define your crease for added dimension.';

  static String _lipTip(String s) => {
        'full':       'A berry stain with clear gloss at the centre = effortless fullness.',
        'thin':       'Slightly overline in a shade closest to your natural lip tone.',
        'cupids-bow': 'Highlight above the bow with a champagne liner for extra definition.',
        'pouty':      'Balance the lower lip by keeping colour slightly darker on bottom.',
        'wide':       'Nude tones within the natural lip line keep proportions balanced.',
        'small':      'Over-line all around with a nude liner for a fuller appearance.',
      }[s] ?? 'Use a liner one shade deeper than your lipstick for longevity.';

  static String _undertoneTip(String s) => {
        'warm':    'Warm peaches, corals, terracottas and golden highlights suit you best.',
        'cool':    'Berry pinks, mauve, cool reds and silver highlights are your friends.',
        'neutral': 'Lucky you — both warm and cool shades flatter your complexion.',
      }[s] ?? 'Experiment freely — neutral undertones suit a wide palette.';

  static String _overallStyle(FaceFeatures f) {
    if (f.eyeShape == 'almond' && f.lipShape == 'full') return 'Soft Glam';
    if (f.faceShape == 'oval')                          return 'Editorial Freedom';
    if (f.eyeShape == 'hooded')                         return 'Defined Drama';
    if (f.lipShape == 'thin')                           return 'Minimal Chic';
    return 'Natural Glow';
  }

  // ── Public API ─────────────────────────────────────────────────────────────
  static Future<MakeupAnalysisResult> analyze({
    required String imagePath,
    required List<Face> mlKitFaces,
    bool useAI = true,
  }) async {
    FaceFeatures features;

    if (mlKitFaces.isNotEmpty) {
      features = _deriveFromLandmarks(mlKitFaces.first);
      if (useAI) features = await _enrichWithAI(imagePath, features);
    } else {
      features = await _enrichWithAI(
        imagePath,
        const FaceFeatures(
          faceShape: 'oval', noseShape: 'button', eyeShape: 'almond',
          lipShape: 'full', eyebrowShape: 'arched', skinUndertone: 'neutral',
          faceWidth: 0, faceHeight: 0, rawAIAnalysis: '',
        ),
      );
    }

    return MakeupAnalysisResult(
      features:     features,
      tutorials:    buildTutorialsPublic(features),
      quickTips:    buildTipsPublic(features),
      overallStyle: _overallStyle(features),
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

void debugPrintAI(String msg) => debugPrint('[MakeupAI] $msg');