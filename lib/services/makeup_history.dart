// lib/services/makeup_history.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flawless_beauty_app/services/makeup_analysis_service.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
class MakeupRecord {
  final String id;
  final String imagePath; // local path OR remote Supabase signed URL
  final MakeupAnalysisResult result;
  final DateTime scannedAt;
  final bool isRemote;

  const MakeupRecord({
    required this.id,
    required this.imagePath,
    required this.result,
    required this.scannedAt,
    this.isRemote = false,
  });
}

// ── Singleton ─────────────────────────────────────────────────────────────────
class MakeupHistory extends ChangeNotifier {
  MakeupHistory._();
  static final MakeupHistory instance = MakeupHistory._();

  final _db      = Supabase.instance.client;
  final _storage = Supabase.instance.client.storage;

  final List<MakeupRecord> _records = [];
  bool _loaded   = false;
  bool isLoading = false;
  String? error;

  List<MakeupRecord> get records => List.unmodifiable(_records);

  // ── Load all records for the signed-in user ────────────────────────────────
  Future<void> load({bool force = false}) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;
    if (_loaded && !force) return;

    isLoading = true;
    error     = null;
    notifyListeners();

    try {
      final rows = await _db
          .from('makeup_reports')
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
      debugPrint('❌ MakeupHistory.load error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Save a new makeup scan ─────────────────────────────────────────────────
  Future<void> add(MakeupAnalysisResult result, String localImagePath) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;

    String? imageUrl;

    // 1. Upload image to Supabase Storage and get a long-lived signed URL
    //    (10 years = 315,360,000 seconds — same pattern as ProfileService)
    try {
      final file     = File(localImagePath);
      final fileName = 'makeup/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _storage.from('scan-images').upload(
            fileName,
            file,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      // ✅ Use createSignedUrl instead of getPublicUrl — works on private buckets
      /*imageUrl = await _storage
          .from('scan-images')
          .createSignedUrl(fileName, 315360000); // 10 years in seconds
      */
      
      imageUrl = _storage.from('scan-images').getPublicUrl(fileName);

      debugPrint('✅ MakeupHistory image uploaded: $imageUrl');
    } catch (e) {
      debugPrint('⚠️ MakeupHistory image upload failed: $e');
      // imageUrl stays null — we fall back to local path for this session
    }

    // 2. Insert DB row
    try {
      final row = await _db
          .from('makeup_reports')
          .insert({
            'user_id'         : uid,
            'face_shape'      : result.features.faceShape,
            'eye_shape'       : result.features.eyeShape,
            'lip_shape'       : result.features.lipShape,
            'nose_shape'      : result.features.noseShape,
            'eyebrow_shape'   : result.features.eyebrowShape,
            'skin_undertone'  : result.features.skinUndertone,
            'overall_style'   : result.overallStyle,
            'raw_ai_analysis' : result.features.rawAIAnalysis,
            'image_url'       : imageUrl, // signed URL stored in DB
          })
          .select()
          .single();

      _records.insert(
        0,
        _fromRow(row as Map<String, dynamic>, localFallback: localImagePath),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ MakeupHistory.add DB error: $e');
      // Keep in memory for this session even if DB write failed
      _records.insert(
        0,
        MakeupRecord(
          id        : 'local_${DateTime.now().millisecondsSinceEpoch}',
          imagePath : localImagePath,
          result    : result,
          scannedAt : DateTime.now(),
          isRemote  : false,
        ),
      );
      notifyListeners();
    }
  }

  // ── Delete a record ────────────────────────────────────────────────────────
  Future<void> remove(String recordId) async {
    final idx = _records.indexWhere((r) => r.id == recordId);
    if (idx == -1) return;

    final record = _records[idx];
    _records.removeAt(idx);
    notifyListeners();

    if (record.id.startsWith('local_')) return;

    try {
      await _db.from('makeup_reports').delete().eq('id', record.id);

      if (record.isRemote) {
        final uid = _db.auth.currentUser?.id;
        if (uid != null) {
          final uri         = Uri.parse(record.imagePath);
          final segments    = uri.pathSegments;
          final afterBucket = segments
              .skipWhile((s) => s != 'scan-images')
              .skip(1)
              .join('/');
          if (afterBucket.isNotEmpty) {
            await _storage.from('scan-images').remove([afterBucket]);
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ MakeupHistory remote delete failed: $e');
    }
  }

  // ── Clear on logout ────────────────────────────────────────────────────────
  void clear() {
    _records.clear();
    _loaded = false;
    error   = null;
    notifyListeners();
  }

  // ── Row → MakeupRecord ─────────────────────────────────────────────────────
  MakeupRecord _fromRow(Map<String, dynamic> row, {String? localFallback}) {
    final features = FaceFeatures(
      faceShape     : row['face_shape']?.toString()     ?? 'oval',
      eyeShape      : row['eye_shape']?.toString()      ?? 'almond',
      lipShape      : row['lip_shape']?.toString()      ?? 'full',
      noseShape     : row['nose_shape']?.toString()     ?? 'button',
      eyebrowShape  : row['eyebrow_shape']?.toString()  ?? 'arched',
      skinUndertone : row['skin_undertone']?.toString() ?? 'neutral',
      faceWidth     : 0,
      faceHeight    : 0,
      rawAIAnalysis : row['raw_ai_analysis']?.toString() ?? '',
    );

    final fullResult = MakeupAnalysisResult(
      features    : features,
      tutorials   : MakeupAnalysisService.buildTutorialsPublic(features),
      quickTips   : MakeupAnalysisService.buildTipsPublic(features),
      overallStyle: row['overall_style']?.toString() ?? 'Natural Glow',
    );

    final imageUrl  = row['image_url'] as String?;
    // Prefer the remote signed URL; fall back to local path if upload failed
    final imagePath = (imageUrl != null && imageUrl.isNotEmpty)
        ? imageUrl
        : (localFallback ?? '');

    return MakeupRecord(
      id        : row['id'] as String,
      imagePath : imagePath,
      result    : fullResult,
      scannedAt : DateTime.parse(row['scanned_at'] as String),
      isRemote  : imageUrl != null && imageUrl.isNotEmpty,
    );
  }
}