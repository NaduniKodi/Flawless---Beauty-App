// lib/services/skin_analysis_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ── Core Skin Models ──────────────────────────────────────────────────────────

class SkinAnalysisResult {
  final int skinAge;
  final String faceShape;
  final int overallScore;
  final List<SkinConcern> concerns;
  final String summary;
  final PersonalizedRecommendations recommendations;

  SkinAnalysisResult({
    required this.skinAge,
    required this.faceShape,
    required this.overallScore,
    required this.concerns,
    required this.summary,
    required this.recommendations,
  });

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisResult(
      skinAge: (json['skin_age'] as num?)?.toInt() ?? 25,
      faceShape: json['face_shape']?.toString() ?? 'Oval',
      overallScore: (json['overall_score'] as num?)?.toInt() ?? 50,
      concerns: (json['concerns'] as List? ?? [])
          .map((c) => SkinConcern.fromJson(c as Map<String, dynamic>))
          .toList(),
      summary: json['summary']?.toString() ?? '',
      recommendations: PersonalizedRecommendations.fromJson(
        json['recommendations'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class SkinConcern {
  final String name;
  final int score;
  final String description;

  SkinConcern({
    required this.name,
    required this.score,
    required this.description,
  });

  factory SkinConcern.fromJson(Map<String, dynamic> json) {
    return SkinConcern(
      name: json['name']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
    );
  }

  /// Includes description so round-tripped records keep the full data.
  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
        'description': description,
      };
}

// ── Personalized Recommendation Models ───────────────────────────────────────

class PersonalizedRecommendations {
  final List<SkincareStep> morningRoutine;
  final List<SkincareStep> eveningRoutine;
  final List<FacialYogaExercise> facialYoga;
  final List<String> dietTips;
  final List<String> lifestyleTips;

  PersonalizedRecommendations({
    required this.morningRoutine,
    required this.eveningRoutine,
    required this.facialYoga,
    required this.dietTips,
    required this.lifestyleTips,
  });

  bool get isEmpty =>
      morningRoutine.isEmpty &&
      eveningRoutine.isEmpty &&
      facialYoga.isEmpty &&
      dietTips.isEmpty &&
      lifestyleTips.isEmpty;

  factory PersonalizedRecommendations.fromJson(Map<String, dynamic> json) {
    List<SkincareStep> parseSteps(dynamic raw) {
      if (raw == null || raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(SkincareStep.fromJson)
          .toList();
    }

    List<FacialYogaExercise> parseYoga(dynamic raw) {
      if (raw == null || raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(FacialYogaExercise.fromJson)
          .toList();
    }

    List<String> parseStrings(dynamic raw) {
      if (raw == null || raw is! List) return [];
      return raw.map((e) => e.toString()).toList();
    }

    return PersonalizedRecommendations(
      morningRoutine: parseSteps(json['morning_routine']),
      eveningRoutine: parseSteps(json['evening_routine']),
      facialYoga: parseYoga(json['facial_yoga']),
      dietTips: parseStrings(json['diet_tips']),
      lifestyleTips: parseStrings(json['lifestyle_tips']),
    );
  }

  /// Serializes to a plain Map for storing in a Supabase JSONB column.
  Map<String, dynamic> toJson() => {
        'morning_routine': morningRoutine.map((s) => s.toJson()).toList(),
        'evening_routine': eveningRoutine.map((s) => s.toJson()).toList(),
        'facial_yoga': facialYoga.map((e) => e.toJson()).toList(),
        'diet_tips': dietTips,
        'lifestyle_tips': lifestyleTips,
      };
}

class SkincareStep {
  final int step;
  final String productType;
  final String suggestion;
  final String reason;

  SkincareStep({
    required this.step,
    required this.productType,
    required this.suggestion,
    required this.reason,
  });

  factory SkincareStep.fromJson(Map<String, dynamic> json) {
    return SkincareStep(
      step: (json['step'] as num?)?.toInt() ?? 1,
      productType: json['product_type']?.toString() ?? '',
      suggestion: json['suggestion']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'product_type': productType,
        'suggestion': suggestion,
        'reason': reason,
      };
}

class FacialYogaExercise {
  final String name;
  final String targetArea;
  final String howTo;
  final int durationSeconds;
  final int reps;
  final String benefit;

  FacialYogaExercise({
    required this.name,
    required this.targetArea,
    required this.howTo,
    required this.durationSeconds,
    required this.reps,
    required this.benefit,
  });

  factory FacialYogaExercise.fromJson(Map<String, dynamic> json) {
    return FacialYogaExercise(
      name: json['name']?.toString() ?? '',
      targetArea: json['target_area']?.toString() ?? '',
      howTo: json['how_to']?.toString() ?? '',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 30,
      reps: (json['reps'] as num?)?.toInt() ?? 10,
      benefit: json['benefit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'target_area': targetArea,
        'how_to': howTo,
        'duration_seconds': durationSeconds,
        'reps': reps,
        'benefit': benefit,
      };
}

// ── Service ───────────────────────────────────────────────────────────────────

class SkinAnalysisService {
  static final String _apiKey = dotenv.env['openrouterai'] ?? 'MISSING_API_KEY';
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  static const List<String> _freeModels = [
    'google/gemini-2.0-flash-exp:free',
    'google/gemma-4-31b-it:free',
    'google/gemma-3-27b-it:free',
    'qwen/qwen2.5-vl-32b-instruct:free',
    'qwen/qwen2.5-vl-7b-instruct:free',
    'mistralai/mistral-small-3.1-24b-instruct:free',
    'nvidia/nemotron-nano-12b-v2-vl:free',
    'microsoft/phi-4-multimodal-instruct:free',
    'google/gemini-2.5-flash-preview:free',
    'meta-llama/llama-3.2-11b-vision-instruct:free',
    
    
  ];

  static Future<SkinAnalysisResult> analyzeImage(String imagePath) async {
    for (int i = 0; i < _freeModels.length; i++) {
      final model = _freeModels[i];
      try {
        debugPrint('🔄 Trying model: $model');
        final result = await _tryAnalyze(imagePath, model);
        debugPrint('✅ Success with model: $model');
        return result;
      } catch (e) {
        debugPrint('❌ Failed with $model: $e');
        if (i < _freeModels.length - 1) {
          debugPrint('⏳ Waiting before next attempt...');
          await Future.delayed(const Duration(seconds: 3));
        }
      }
    }
    throw Exception('All models are busy. Please wait 1 minute and try again.');
  }

  static Future<SkinAnalysisResult> _tryAnalyze(
    String imagePath,
    String model,
  ) async {
    final imageBytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(imageBytes);

    const prompt = r'''
You are a professional AI dermatologist and facial wellness expert. Analyze this facial photo thoroughly and return ONLY a valid JSON object — no markdown fences, no explanation, no extra text before or after.

Return EXACTLY this JSON structure:
{
  "skin_age": <estimated skin age as integer>,
  "face_shape": "<Oval|Round|Square|Heart|Diamond|Oblong>",
  "overall_score": <0-100 integer, 0=perfect skin, 100=many concerns>,
  "summary": "<2 sentence overall skin summary>",
  "concerns": [
    { "name": "Acne",            "score": <0-100>, "description": "<1 brief sentence>" },
    { "name": "Dark Circles",    "score": <0-100>, "description": "<1 brief sentence>" },
    { "name": "Uneven Skin-tone","score": <0-100>, "description": "<1 brief sentence>" },
    { "name": "Dehydration",     "score": <0-100>, "description": "<1 brief sentence>" },
    { "name": "Redness",         "score": <0-100>, "description": "<1 brief sentence>" },
    { "name": "Nasolabial Folds","score": <0-100>, "description": "<1 brief sentence>" }
  ],
  "recommendations": {
    "morning_routine": [
      { "step": 1, "product_type": "Cleanser",    "suggestion": "<specific type>", "reason": "<why this suits the detected skin>" },
      { "step": 2, "product_type": "Toner",       "suggestion": "<specific>", "reason": "<why>" },
      { "step": 3, "product_type": "Serum",       "suggestion": "<specific>", "reason": "<why>" },
      { "step": 4, "product_type": "Moisturizer", "suggestion": "<specific>", "reason": "<why>" },
      { "step": 5, "product_type": "Sunscreen",   "suggestion": "<specific SPF type>", "reason": "<why>" }
    ],
    "evening_routine": [
      { "step": 1, "product_type": "Oil Cleanser",  "suggestion": "<specific>", "reason": "<why>" },
      { "step": 2, "product_type": "Cleanser",      "suggestion": "<specific>", "reason": "<why>" },
      { "step": 3, "product_type": "Treatment",     "suggestion": "<targeted treatment>", "reason": "<why this targets their biggest concern>" },
      { "step": 4, "product_type": "Eye Cream",     "suggestion": "<specific>", "reason": "<why>" },
      { "step": 5, "product_type": "Night Cream",   "suggestion": "<specific>", "reason": "<why>" }
    ],
    "facial_yoga": [
      {
        "name": "<exercise name>",
        "target_area": "<specific area>",
        "how_to": "<clear numbered steps>",
        "duration_seconds": <10-60 integer>,
        "reps": <5-20 integer>,
        "benefit": "<specific benefit relating to their detected concerns>"
      },
      { "name": "...", "target_area": "...", "how_to": "...", "duration_seconds": 30, "reps": 10, "benefit": "..." },
      { "name": "...", "target_area": "...", "how_to": "...", "duration_seconds": 30, "reps": 10, "benefit": "..." },
      { "name": "...", "target_area": "...", "how_to": "...", "duration_seconds": 30, "reps": 10, "benefit": "..." },
      { "name": "...", "target_area": "...", "how_to": "...", "duration_seconds": 30, "reps": 10, "benefit": "..." }
    ],
    "diet_tips": [
      "<personalized tip directly linked to a detected concern>",
      "<tip>", "<tip>", "<tip>"
    ],
    "lifestyle_tips": [
      "<personalized lifestyle tip>",
      "<tip>", "<tip>"
    ]
  }
}

PERSONALIZATION RULES — follow all of them:
1. Face shape → choose facial yoga that complements or sculpts that shape specifically.
   - Round: jawline definition, cheekbone lifting
   - Square: temple/forehead softening, cheek slimming
   - Heart: chin/jawline toning, forehead relaxing
   - Oval: general lifting and contouring maintenance
   - Diamond: cheekbone/temple exercises, jaw relaxing
   - Oblong: cheek fullness, horizontal face-widening exercises
2. Concern scores → address the TOP 3 highest-scoring concerns in the routine and yoga.
3. Skin age → if skin_age > 35 use anti-aging products (retinol, peptides, collagen serums);
              if skin_age < 25 use gentle/preventive products.
4. Include EXACTLY 5 facial yoga exercises, 4 diet tips, and 3 lifestyle tips.
5. Make each how_to field contain clear numbered steps a user can follow at home.''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://yourapp.com',
        'X-Title': 'Flawless Beauty App',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
              },
              {'type': 'text', 'text': prompt},
            ],
          },
        ],
        'max_tokens': 3000,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        responseJson['choices'][0]['message']['content'] as String;
    debugPrint('🤖 Raw AI Response: $content');

    // Strip markdown fences and extract the outermost JSON object
    String cleanJson = content
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final jsonStart = cleanJson.indexOf('{');
    final jsonEnd = cleanJson.lastIndexOf('}');
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      cleanJson = cleanJson.substring(jsonStart, jsonEnd + 1);
    }

    return SkinAnalysisResult.fromJson(
        jsonDecode(cleanJson) as Map<String, dynamic>);
  }
}