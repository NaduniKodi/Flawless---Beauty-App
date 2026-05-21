// lib/services/makeup_history.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flawless_beauty_app/services/makeup_analysis_service.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
class MakeupRecord {
  final String id;
  final String imagePath;
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
      debugPrint('✅ MakeupHistory loaded ${_records.length} records');
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
    if (uid == null) {
      debugPrint('⚠️ MakeupHistory.add: no signed-in user');
      return;
    }

    // ── FIX: Read file bytes immediately before any other async work ─────────
    // Camera temp files can be moved/deleted between async gaps. Reading bytes
    // here guarantees we have the data regardless of what happens to the path.
    final localFile = File(localImagePath);
    List<int>? imageBytes;

    try {
      if (await localFile.exists()) {
        imageBytes = await localFile.readAsBytes();
        debugPrint('📁 Read ${imageBytes.length} bytes from: $localImagePath');
      } else {
        debugPrint('⚠️ Local file not found at: $localImagePath');
      }
    } catch (e) {
      debugPrint('❌ Could not read local file: $e');
    }

    String? imageUrl;

    // ── 1. Upload image bytes to Supabase Storage ─────────────────────────────
    if (imageBytes != null && imageBytes.isNotEmpty) {
      final fileName =
          'makeup/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      debugPrint('📤 Uploading ${imageBytes.length} bytes → scan-images/$fileName');

      try {
        // Upload using bytes so the original file path no longer matters
        await _storage.from('scan-images').uploadBinary(
              fileName,
              Uint8List.fromList(imageBytes),
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );
        debugPrint('✅ Upload complete');

        imageUrl = await _storage
            .from('scan-images')
            .createSignedUrl(fileName, 315360000); // ~10 years
        debugPrint('✅ Signed URL: $imageUrl');
      } on StorageException catch (e) {
        // Surface the real reason so it's easy to fix
        debugPrint('❌ Storage upload FAILED');
        debugPrint('   status  : ${e.statusCode}');
        debugPrint('   message : ${e.message}');
        debugPrint('   error   : ${e.error}');
        debugPrint('');
        debugPrint('   Common causes:');
        debugPrint('   • Bucket "scan-images" does not exist in Supabase Storage');
        debugPrint('   • Missing INSERT Storage RLS policy for authenticated users');
        debugPrint('   • Missing SELECT Storage RLS policy for authenticated users');
        debugPrint('');
        debugPrint('   Required SQL policies:');
        debugPrint('   CREATE POLICY "upload own images"');
        debugPrint('   ON storage.objects FOR INSERT TO authenticated');
        debugPrint('   WITH CHECK (');
        debugPrint('     bucket_id = \'scan-images\' AND');
        debugPrint('     (storage.foldername(name))[2] = auth.uid()::text');
        debugPrint('   );');
      } catch (e) {
        debugPrint('❌ Unexpected upload error: $e');
      }
    } else {
      debugPrint('⚠️ Skipping upload: no image bytes available');
    }

    // ── 2. Insert DB row ──────────────────────────────────────────────────────
    try {
      debugPrint('💾 Inserting row — image_url: ${imageUrl ?? "NULL (upload failed)"}');

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
            'image_url'       : imageUrl, // null if upload failed
          })
          .select()
          .single();

      debugPrint('✅ DB insert success, id: ${row['id']}');

      // Show image immediately in this session using the local file path
      // as a fallback even if the upload failed.
      _records.insert(
        0,
        _fromRow(
          row as Map<String, dynamic>,
          localFallback: localImagePath,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ MakeupHistory.add DB error: $e');
      // Keep in memory so the user still sees the result this session
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
            debugPrint('✅ Deleted storage file: $afterBucket');
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

    final imageUrl = row['image_url'] as String?;

    final String imagePath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imagePath = imageUrl;
    } else if (localFallback != null && localFallback.isNotEmpty) {
      imagePath = localFallback;
      debugPrint('⚠️ Record ${row['id']}: no remote URL, using local fallback');
    } else {
      imagePath = '';
      debugPrint('⚠️ Record ${row['id']}: no image available (will show placeholder)');
    }

    return MakeupRecord(
      id        : row['id'] as String,
      imagePath : imagePath,
      result    : fullResult,
      scannedAt : DateTime.parse(row['scanned_at'] as String),
      isRemote  : imageUrl != null && imageUrl.isNotEmpty,
    );
  }
}