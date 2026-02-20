// lib/services/skin_analysis_service.dart

import 'dart:convert';
import 'dart:io';
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
  final int score; // 0-100, higher = more concern
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
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY'; // 🔑 replace this
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';

  static Future<SkinAnalysisResult> analyzeImage(String imagePath) async {
    final imageBytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(imageBytes);

    const prompt = '''
You are a professional AI skin analysis expert. Analyze this facial photo and return ONLY a valid JSON object with no extra text or markdown.

Return this exact structure:
{
  "skin_age": <estimated skin age as integer>,
  "face_shape": "<Oval|Round|Square|Heart|Diamond|Oblong>",
  "overall_score": <0-100 integer, 0=perfect skin, 100=many concerns>,
  "summary": "<2 sentence overall skin summary>",
  "concerns": [
    {
      "name": "Acne",
      "score": <0-100>,
      "description": "<brief description>"
    },
    {
      "name": "Dark Circles",
      "score": <0-100>,
      "description": "<brief description>"
    },
    {
      "name": "Uneven Skin-tone",
      "score": <0-100>,
      "description": "<brief description>"
    },
    {
      "name": "Dehydration",
      "score": <0-100>,
      "description": "<brief description>"
    },
    {
      "name": "Redness",
      "score": <0-100>,
      "description": "<brief description>"
    },
    {
      "name": "Nasolabial Folds",
      "score": <0-100>,
      "description": "<brief description>"
    }
  ]
}

Analyze based on visible skin texture, tone, pores, under-eye area, symmetry, and overall complexion.
''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-opus-4-6',
        'max_tokens': 1024,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
              {
                'type': 'text',
                'text': prompt,
              }
            ],
          }
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.body}');
    }

    final responseJson = jsonDecode(response.body);
    final content = responseJson['content'][0]['text'] as String;

    // Strip any accidental markdown fences
    final cleanJson = content
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    return SkinAnalysisResult.fromJson(jsonDecode(cleanJson));
  }
}