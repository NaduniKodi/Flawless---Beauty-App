// lib/services/makeup_analysis_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;

// ── Data Models ───────────────────────────────────────────────────────────────

class FaceFeatures {
  final String faceShape;        // oval, round, square, heart, oblong, diamond
  final String noseShape;        // button, roman, snub, wide, narrow, aquiline
  final String eyeShape;         // almond, round, hooded, monolid, upturned, downturned
  final String lipShape;         // full, thin, cupids-bow, wide, small, pouty
  final String eyebrowShape;     // arched, straight, rounded, s-shaped, bushy
  final String skinUndertone;    // warm, cool, neutral
  final double faceWidth;        // raw metric for shape calc
  final double faceHeight;       // raw metric
  final String rawAIAnalysis;    // full AI response text

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
        faceShape: json['face_shape'] ?? 'oval',
        noseShape: json['nose_shape'] ?? 'button',
        eyeShape: json['eye_shape'] ?? 'almond',
        lipShape: json['lip_shape'] ?? 'full',
        eyebrowShape: json['eyebrow_shape'] ?? 'arched',
        skinUndertone: json['skin_undertone'] ?? 'neutral',
        faceWidth: (json['face_width_ratio'] ?? 1.0).toDouble(),
        faceHeight: (json['face_height_ratio'] ?? 1.0).toDouble(),
        rawAIAnalysis: json['analysis'] ?? '',
      );
}

class MakeupTutorial {
  final String title;
  final String channel;
  final String description;
  final String targetFeature;   // which feature this targets
  final String technique;       // contouring, highlighting, blending etc.
  final String difficulty;      // Beginner / Intermediate / Advanced
  final String duration;        // "12 min"
  final String searchQuery;     // YouTube search query to find this tutorial
  final List<String> products;  // suggested product types

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
  final String overallStyle;    // e.g. "Soft Glam", "Editorial", "Natural"

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
  // ── Step 1: Use ML Kit landmarks to derive features geometrically ──────────
  static FaceFeatures _deriveFromLandmarks(Face face) {
    final box = face.boundingBox;
    final faceWidth = box.width;
    final faceHeight = box.height;
    final ratio = faceWidth / faceHeight;

    // Face shape from width:height ratio
    String faceShape;
    if (ratio < 0.75) {
      faceShape = 'oblong';
    } else if (ratio < 0.85) {
      faceShape = 'oval';
    } else if (ratio < 0.95) {
      faceShape = 'heart';
    } else if (ratio < 1.05) {
      faceShape = 'round';
    } else {
      faceShape = 'square';
    }

    // Use contour data for nose/eye/lip shape estimation
    final noseContour = face.contours[FaceContourType.noseBridge];
    final upperLipContour = face.contours[FaceContourType.upperLipTop];
    final lowerLipContour = face.contours[FaceContourType.lowerLipBottom];
    final leftEyeContour = face.contours[FaceContourType.leftEye];
    final rightEyeContour = face.contours[FaceContourType.rightEye];

    // Lip shape from upper/lower lip width ratio
    String lipShape = 'full';
    if (upperLipContour != null && lowerLipContour != null &&
        upperLipContour.points.isNotEmpty && lowerLipContour.points.isNotEmpty) {
      final upperWidth = (upperLipContour.points.last.x - upperLipContour.points.first.x).abs();
      final lowerWidth = (lowerLipContour.points.last.x - lowerLipContour.points.first.x).abs();
      final lipRatio = upperWidth / (lowerWidth == 0 ? 1 : lowerWidth);
      if (lipRatio > 1.1) {
        lipShape = 'cupids-bow';
      } else if (lipRatio < 0.9) {
        lipShape = 'pouty';
      } else if (upperWidth / faceWidth > 0.38) {
        lipShape = 'wide';
      } else {
        lipShape = 'thin';
      }
    }

    // Eye shape from contour height/width
    String eyeShape = 'almond';
    if (leftEyeContour != null && leftEyeContour.points.length >= 4) {
      final pts = leftEyeContour.points;
      final eyeW = (pts.last.x - pts.first.x).abs().toDouble();
      final eyeH = pts.map((p) => p.y).reduce((a, b) => a > b ? a : b) -
          pts.map((p) => p.y).reduce((a, b) => a < b ? a : b);
      final eyeAspect = eyeW / (eyeH == 0 ? 1 : eyeH);
      if (eyeAspect > 3.5) eyeShape = 'hooded';
      else if (eyeAspect < 2.0) eyeShape = 'round';
      else eyeShape = 'almond';
    }

    // Nose — use bridge contour length vs face width
    String noseShape = 'button';
    if (noseContour != null && noseContour.points.length >= 2) {
      final noseW = (noseContour.points.last.x - noseContour.points.first.x).abs();
      if (noseW / faceWidth > 0.22) noseShape = 'wide';
      else if (noseW / faceWidth < 0.14) noseShape = 'narrow';
      else noseShape = 'button';
    }

    return FaceFeatures(
      faceShape: faceShape,
      noseShape: noseShape,
      eyeShape: eyeShape,
      lipShape: lipShape,
      eyebrowShape: 'arched',    // can't reliably detect from contours alone
      skinUndertone: 'neutral',  // requires color analysis
      faceWidth: faceWidth,
      faceHeight: faceHeight,
      rawAIAnalysis: 'Geometric analysis from facial contours.',
    );
  }

  // ── Step 2: Optionally enrich with AI (image → base64 → API) ──────────────
  static Future<FaceFeatures> _enrichWithAI(
      String imagePath, FaceFeatures geometric) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Replace with your actual AI endpoint. Pattern matches SkinAnalysisService.
      // Using OpenRouter / any OpenAI-compatible endpoint with vision support.
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '',
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
        final data = jsonDecode(response.body);
        final text =
            data['choices'][0]['message']['content'] as String? ?? '';
        // strip possible markdown fences
        final clean =
            text.replaceAll(RegExp(r'```json|```'), '').trim();
        final parsed = jsonDecode(clean) as Map<String, dynamic>;
        return FaceFeatures.fromJson({
          ...parsed,
          'face_width_ratio': geometric.faceWidth,
          'face_height_ratio': geometric.faceHeight,
        });
      }
    } catch (e) {
      debugPrintAI('AI enrichment skipped: $e');
    }
    return geometric; // fall back to geometric analysis
  }

  // ── Step 3: Build tutorial recommendations from features ──────────────────
  static List<MakeupTutorial> _buildTutorials(FaceFeatures f) {
    final tutorials = <MakeupTutorial>[];

    // ─ Face shape tutorial ──────────────────────────────────────────────────
    tutorials.add(_faceShapeTutorial(f.faceShape));

    // ─ Eye shape tutorial ───────────────────────────────────────────────────
    tutorials.add(_eyeTutorial(f.eyeShape));

    // ─ Lip tutorial ─────────────────────────────────────────────────────────
    tutorials.add(_lipTutorial(f.lipShape));

    // ─ Nose contouring tutorial ─────────────────────────────────────────────
    tutorials.add(_noseTutorial(f.noseShape));

    // ─ Brow tutorial ────────────────────────────────────────────────────────
    tutorials.add(_browTutorial(f.eyebrowShape));

    return tutorials;
  }

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
      title: t.$1,
      channel: 'NikkieTutorials · Robert Welsh · Hindash',
      description: t.$2,
      targetFeature: 'Face Shape',
      technique: 'Contouring & Highlighting',
      difficulty: 'Intermediate',
      duration: '15–20 min',
      searchQuery: t.$3,
      products: t.$4,
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
      title: t.$1,
      channel: 'Lisa Eldridge · Wayne Goss · Jackie Aina',
      description: t.$2,
      targetFeature: 'Eye Shape',
      technique: 'Eyeshadow & Liner',
      difficulty: 'Beginner',
      duration: '10–15 min',
      searchQuery: t.$3,
      products: t.$4,
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
      title: t.$1,
      channel: 'Lisa Eldridge · Charlotte Tilbury · Hindash',
      description: t.$2,
      targetFeature: 'Lip Shape',
      technique: 'Lip Liner & Color',
      difficulty: 'Beginner',
      duration: '5–10 min',
      searchQuery: t.$3,
      products: t.$4,
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
      targetFeature: 'Nose Shape',
      technique: 'Nose Contouring',
      difficulty: 'Intermediate',
      duration: '8–12 min',
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
        'Trim slightly above the center third and add a soft peak with a pencil.',
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
      title: t.$1,
      channel: 'Benefit · Anastasia Beverly Hills · Wayne Goss',
      description: t.$2,
      targetFeature: 'Eyebrows',
      technique: 'Brow Filling & Shaping',
      difficulty: 'Beginner',
      duration: '6–10 min',
      searchQuery: t.$3,
      products: ['Brow pencil', 'Clear brow gel', 'Spoolie brush'],
    );
  }

  // ── Step 4: Quick tips ─────────────────────────────────────────────────────
  static List<MakeupTip> _buildTips(FaceFeatures f) => [
        MakeupTip(
          emoji: '✨',
          feature: 'Face Shape',
          title: '${_capitalise(f.faceShape)} Face Pro Tip',
          body: _faceShapeTip(f.faceShape),
        ),
        MakeupTip(
          emoji: '👁️',
          feature: 'Eyes',
          title: '${_capitalise(f.eyeShape)} Eye Hack',
          body: _eyeTip(f.eyeShape),
        ),
        MakeupTip(
          emoji: '💄',
          feature: 'Lips',
          title: '${_capitalise(f.lipShape)} Lip Trick',
          body: _lipTip(f.lipShape),
        ),
        MakeupTip(
          emoji: '🌟',
          feature: 'Skin',
          title: '${_capitalise(f.skinUndertone)} Undertone Colors',
          body: _undertoneTip(f.skinUndertone),
        ),
      ];

  static String _faceShapeTip(String s) => {
        'oval': 'You can rock almost any makeup style — try bold techniques freely.',
        'round': 'Use vertical blush placement to elongate your face naturally.',
        'square': 'Soft rounded blush on the apples of cheeks will soften angular features.',
        'heart': 'Add definition along the jaw with a soft matte bronzer.',
        'oblong': 'Keep blush horizontal across cheeks to add the illusion of width.',
        'diamond': 'Highlight the chin tip to balance strong cheekbones.',
      }[s] ?? 'Enhance your natural symmetry with a balanced highlight and contour.';

  static String _eyeTip(String s) => {
        'almond': 'Smudge liner on the lower lash line for an effortless sultry look.',
        'round': 'A horizontal flick at the outer corner elongates beautifully.',
        'hooded': 'Always do your eye makeup with eyes open — apply above the crease.',
        'monolid': 'Graphic liner on the lash line creates instant definition.',
        'upturned': 'Blend dark shadow downward at the outer corner for balance.',
        'downturned': 'Flick your liner upward past the outer corner to lift the eye.',
      }[s] ?? 'Define your crease for added dimension.';

  static String _lipTip(String s) => {
        'full': 'A berry stain with clear gloss at the center = effortless fullness.',
        'thin': 'Slightly overline in a shade closest to your natural lip tone.',
        'cupids-bow': "Highlight above the bow with a champagne liner for extra definition.",
        'pouty': 'Balance the lower lip by keeping color slightly darker on bottom.',
        'wide': 'Nude tones within the natural lip line keep proportions balanced.',
        'small': 'Over-line all around with a nude liner for a fuller appearance.',
      }[s] ?? 'Use a liner one shade deeper than your lipstick for longevity.';

  static String _undertoneTip(String s) => {
        'warm': 'Warm peaches, corals, terracottas and golden highlights suit you best.',
        'cool': 'Berry pinks, mauve, cool reds and silver highlights are your friends.',
        'neutral': 'Lucky you — both warm and cool shades flatter your complexion.',
      }[s] ?? 'Experiment freely — neutral undertones suit a wide palette.';

  static String _overallStyle(FaceFeatures f) {
    if (f.eyeShape == 'almond' && f.lipShape == 'full') return 'Soft Glam';
    if (f.faceShape == 'oval') return 'Editorial Freedom';
    if (f.eyeShape == 'hooded') return 'Defined Drama';
    if (f.lipShape == 'thin') return 'Minimal Chic';
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
      if (useAI) {
        features = await _enrichWithAI(imagePath, features);
      }
    } else {
      // No face detected — use AI alone
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
      features: features,
      tutorials: _buildTutorials(features),
      quickTips: _buildTips(features),
      overallStyle: _overallStyle(features),
    );
  }

  static String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

void debugPrintAI(String msg) => debugPrint('[MakeupAI] $msg');