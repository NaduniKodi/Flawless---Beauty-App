// lib/services/skin_analysis_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SkinAnalysisResult {
  final int skinAge;
  final String faceShape;
  final int overallScore;
  final List<SkinConcern> concerns;
  final String summary;

  SkinAnalysisResult({
    required this.skinAge,
    required this.faceShape,
    required this.overallScore,
    required this.concerns,
    required this.summary,
  });

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisResult(
      skinAge: json['skin_age'],
      faceShape: json['face_shape'],
      overallScore: json['overall_score'],
      concerns: (json['concerns'] as List)
          .map((c) => SkinConcern.fromJson(c))
          .toList(),
      summary: json['summary'],
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
      name: json['name'],
      score: json['score'],
      description: json['description'],
    );
  }
}

class SkinAnalysisService {
  static const String _apiKey =
      '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';
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

 static const List<String> _freeModels = [
  'google/gemma-3-27b-it:free',
  'qwen/qwen2.5-vl-7b-instruct:free',
  'microsoft/phi-4-multimodal-instruct:free',
  'google/gemini-2.0-flash-exp:free',
  'meta-llama/llama-3.2-11b-vision-instruct:free',
  'bytedance-research/ui-tars-7b:free',
  'qwen/qwen2.5-vl-72b-instruct:free',
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

      // ✅ Wait 3 seconds before trying next model
      if (i < _freeModels.length - 1) {
        debugPrint('⏳ Waiting before next attempt...');
        await Future.delayed(const Duration(seconds: 3));
      }
      continue;
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

    const prompt = '''
You are a professional AI skin analysis expert. Analyze this facial photo and return ONLY a valid JSON object with no extra text or markdown fences.

Return this exact structure:
{
  "skin_age": <estimated skin age as integer>,
  "face_shape": "<Oval|Round|Square|Heart|Diamond|Oblong>",
  "overall_score": <0-100 integer, 0=perfect skin, 100=many concerns>,
  "summary": "<2 sentence overall skin summary>",
  "concerns": [
    { "name": "Acne", "score": <0-100>, "description": "<brief>" },
    { "name": "Dark Circles", "score": <0-100>, "description": "<brief>" },
    { "name": "Uneven Skin-tone", "score": <0-100>, "description": "<brief>" },
    { "name": "Dehydration", "score": <0-100>, "description": "<brief>" },
    { "name": "Redness", "score": <0-100>, "description": "<brief>" },
    { "name": "Nasolabial Folds", "score": <0-100>, "description": "<brief>" }
  ]
}''';

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
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.body}');
    }

    final responseJson = jsonDecode(response.body);
    final content = responseJson['choices'][0]['message']['content'] as String;

    final cleanJson = content
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    return SkinAnalysisResult.fromJson(jsonDecode(cleanJson));
  }
}
