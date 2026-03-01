// lib/services/makeup_history.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'makeup_analysis_service.dart';
import 'package:flawless_beauty_app/services/makeup_analysis_service.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
class MakeupRecord {
  final String id;
  final String imagePath;
  final MakeupAnalysisResult result;
  final DateTime scannedAt;

  const MakeupRecord({
    required this.id,
    required this.imagePath,
    required this.result,
    required this.scannedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'scannedAt': scannedAt.toIso8601String(),
    'overallStyle': result.overallStyle,
    'faceShape': result.features.faceShape,
    'eyeShape': result.features.eyeShape,
    'lipShape': result.features.lipShape,
    'noseShape': result.features.noseShape,
    'eyebrowShape': result.features.eyebrowShape,
    'skinUndertone': result.features.skinUndertone,
    'rawAIAnalysis': result.features.rawAIAnalysis,
  };

  factory MakeupRecord.fromJson(Map<String, dynamic> j) {
    // Re-build a lightweight MakeupAnalysisResult from stored JSON
    final features = FaceFeatures(
      faceShape: j['faceShape'] ?? 'oval',
      eyeShape: j['eyeShape'] ?? 'almond',
      lipShape: j['lipShape'] ?? 'full',
      noseShape: j['noseShape'] ?? 'button',
      eyebrowShape: j['eyebrowShape'] ?? 'arched',
      skinUndertone: j['skinUndertone'] ?? 'neutral',
      faceWidth: 0,
      faceHeight: 0,
      rawAIAnalysis: j['rawAIAnalysis'] ?? '',
    );
    final result = MakeupAnalysisResult(
      features: features,
      tutorials: [],
      quickTips: [],
      overallStyle: j['overallStyle'] ?? 'Natural Glow',
    );
    return MakeupRecord(
      id: j['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: j['imagePath'] ?? '',
      result: result,
      scannedAt: DateTime.tryParse(j['scannedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// ── Service ───────────────────────────────────────────────────────────────────
class MakeupHistory extends ChangeNotifier {
  MakeupHistory._();
  static final MakeupHistory instance = MakeupHistory._();

  List<MakeupRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  List<MakeupRecord> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  String? get error => _error;

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/makeup_history.json');
  }

  Future<void> load({bool force = false}) async {
    if (_isLoading) return;
    if (_records.isNotEmpty && !force) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final f = await _file();
      if (await f.exists()) {
        final raw = await f.readAsString();
        final list = jsonDecode(raw) as List<dynamic>;
        _records =
            list
                .map((e) => MakeupRecord.fromJson(e as Map<String, dynamic>))
                .toList()
              ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[MakeupHistory] load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(MakeupRecord record) async {
    _records.insert(0, record);
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final f = await _file();
      await f.writeAsString(
        jsonEncode(_records.map((r) => r.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('[MakeupHistory] persist error: $e');
    }
  }
}
