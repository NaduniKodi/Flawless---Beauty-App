// lib/services/scan_history.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flawless_beauty_app/services/skin_analysis_service.dart';

// ── Local model ───────────────────────────────────────────────────────────────
class ScanRecord {
  final String id;           
  final SkinAnalysisResult result;
  final String imagePath;    // local file path OR remote Supabase Storage URL
  final DateTime scannedAt;
  final bool isRemote;       // true = imagePath is a Supabase Storage URL

  ScanRecord({
    required this.id,
    required this.result,
    required this.imagePath,
    required this.scannedAt,
    this.isRemote = false,
  });
}

// ── Singleton store ───────────────────────────────────────────────────────────
class ScanHistory extends ChangeNotifier {
  static final ScanHistory instance = ScanHistory._();
  ScanHistory._();

  final _db      = Supabase.instance.client;
  final _storage = Supabase.instance.client.storage;

  final List<ScanRecord> _records = [];
  bool _loaded   = false;
  bool isLoading = false;
  String? error;

  List<ScanRecord> get records => List.unmodifiable(_records); // newest-first

  // ── Load all records for the current user ─────────────────────────────────
  Future<void> load({bool force = false}) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;
    if (_loaded && !force) return;

    isLoading = true;
    error     = null;
    notifyListeners();

    try {
      final rows = await _db
          .from('scan_reports')
          .select()
          .eq('user_id', uid)
          .order('scanned_at', ascending: false);

      _records.clear();
      for (final row in rows as List<dynamic>) {
        _records.add(_fromRow(row as Map<String, dynamic>));
      }
      _loaded = true;
    } catch (e) {
      error = e.toString();
      debugPrint('❌ ScanHistory.load error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Add a new scan ────────────────────────────────────────────────────────
  Future<void> add(SkinAnalysisResult result, String localImagePath) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;

    String? imageUrl;

    // 1. Upload image to Supabase Storage
    try {
      final file     = File(localImagePath);
      final fileName = '$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _storage.from('scan-images').upload(
            fileName,
            file,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      imageUrl = _storage.from('scan-images').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('⚠️ Image upload failed: $e');
    }

    // 2. Insert DB row — concerns and recommendations are stored as JSONB
    try {
      final row = await _db
          .from('scan_reports')
          .insert({
            'user_id'        : uid,
            'skin_age'       : result.skinAge,
            'face_shape'     : result.faceShape,
            'overall_score'  : result.overallScore,
            'summary'        : result.summary,
            // ✅ Store full concern objects (name + score + description)
            'concerns'       : result.concerns
                .map((c) => c.toJson())
                .toList(),
            // ✅ toJson() now exists on PersonalizedRecommendations
            'recommendations': result.recommendations.toJson(),
            'image_url'      : imageUrl,
          })
          .select()
          .single();

      _records.insert(
        0,
        _fromRow(row as Map<String, dynamic>, localFallback: localImagePath),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to save scan: $e');
      // Keep in memory for this session even if the DB write failed
      _records.insert(
        0,
        ScanRecord(
          id        : 'local_${DateTime.now().millisecondsSinceEpoch}',
          result    : result,
          imagePath : localImagePath,
          scannedAt : DateTime.now(),
          isRemote  : false,
        ),
      );
      notifyListeners();
    }
  }

  // ── Delete a scan ─────────────────────────────────────────────────────────
  Future<void> remove(String recordId) async {
    final idx = _records.indexWhere((r) => r.id == recordId);
    if (idx == -1) return;

    final record = _records[idx];

    // Remove from list immediately for snappy UI
    _records.removeAt(idx);
    notifyListeners();

    // Local-only records have no remote data to delete
    if (record.id.startsWith('local_')) return;

    try {
      await _db.from('scan_reports').delete().eq('id', record.id);

      // Delete image from Storage
      if (record.isRemote) {
        final uid = _db.auth.currentUser?.id;
        if (uid != null) {
          final uri           = Uri.parse(record.imagePath);
          final segments      = uri.pathSegments;
          final afterBucket   = segments
              .skipWhile((s) => s != 'scan-images')
              .skip(1)
              .join('/');
          if (afterBucket.isNotEmpty) {
            await _storage.from('scan-images').remove([afterBucket]);
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Remote delete failed: $e');
    }
  }

  // ── Reset on logout ───────────────────────────────────────────────────────
  void clear() {
    _records.clear();
    _loaded = false;
    error   = null;
    notifyListeners();
  }

  // ── Map DB row → ScanRecord ───────────────────────────────────────────────
  ScanRecord _fromRow(Map<String, dynamic> row, {String? localFallback}) {
    // ── Concerns ─────────────────────────────────────────────────────────────
    // Guard against null or unexpected types coming back from Supabase.
    final rawConcerns = row['concerns'];
    final concerns = (rawConcerns is List ? rawConcerns : <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map((c) => SkinConcern(
              name       : c['name']?.toString() ?? '',
              score      : (c['score'] as num?)?.toInt() ?? 0,
              // description is stored in the DB from the full toJson(),
              // but old rows may not have it — fall back to empty string.
              description: c['description']?.toString() ?? '',
            ))
        .toList();

    // ── Recommendations ───────────────────────────────────────────────────────
    // Supabase returns JSONB columns as already-decoded Dart objects.
    // Guard: treat missing / non-map values as an empty recommendations object.
    final rawRecs = row['recommendations'];
    final recommendations = PersonalizedRecommendations.fromJson(
      rawRecs is Map<String, dynamic> ? rawRecs : const <String, dynamic>{},
    );

    // ── Image path ────────────────────────────────────────────────────────────
    final imageUrl  = row['image_url'] as String?;
    final imagePath = imageUrl ?? localFallback ?? '';

    return ScanRecord(
      id        : row['id'] as String,
      result    : SkinAnalysisResult(
        skinAge     : (row['skin_age']      as num?)?.toInt() ?? 0,
        faceShape   : row['face_shape']?.toString() ?? '',
        overallScore: (row['overall_score'] as num?)?.toInt() ?? 0,
        summary     : row['summary']?.toString() ?? '',
        concerns    : concerns,
        recommendations: recommendations,
      ),
      imagePath : imagePath,
      scannedAt : DateTime.parse(row['scanned_at'] as String),
      isRemote  : imageUrl != null,
    );
  }
}