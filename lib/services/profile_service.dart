// lib/services/profile_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single point of contact with Supabase for all profile data.
/// Call [fetch] to read, [save] to upsert any subset of fields,
/// and [uploadAvatar] to store an image in the 'avatars' bucket.
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  SupabaseClient get _db => Supabase.instance.client;
  String? get _uid      => _db.auth.currentUser?.id;

  // ── Fetch ──────────────────────────────────────────────────────────────────
  /// Returns the current user's profile row, or null on failure / no row yet.
  Future<Map<String, dynamic>?> fetch() async {
    final uid = _uid;
    if (uid == null) {
      debugPrint('[ProfileService] fetch: no signed-in user');
      return null;
    }

    try {
      // maybeSingle() returns null instead of throwing when 0 rows found
      final row = await _db
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      return row;
    } on PostgrestException catch (e) {
      debugPrint('[ProfileService] fetch PostgrestException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[ProfileService] fetch error: $e');
      return null;
    }
  }

  // ── Save (upsert) ──────────────────────────────────────────────────────────
  /// Upserts [fields] into the profiles table for the current user.
  /// Always includes `id` so the upsert knows which row to target.
  Future<void> save(Map<String, dynamic> fields) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _db.from('profiles').upsert(
        {'id': uid, ...fields},
        onConflict: 'id',
      );
    } on PostgrestException catch (e) {
      debugPrint('[ProfileService] save PostgrestException: ${e.message}');
    } catch (e) {
      debugPrint('[ProfileService] save error: $e');
    }
  }

  // ── Avatar upload ──────────────────────────────────────────────────────────
  /// Uploads [file] to `avatars/{uid}/avatar.jpg`, persists the signed URL
  /// in the profile row, and returns that URL. Returns null on failure.
  Future<String?> uploadAvatar(File file) async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final bytes = await file.readAsBytes();
      final path  = '$uid/avatar.jpg';

      await _db.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );

      // Signed URL valid for ~10 years
      final signedUrl = await _db.storage
          .from('avatars')
          .createSignedUrl(path, 315360000);

      // Persist so other devices get it on next load
      await save({'avatar_url': signedUrl});
      return signedUrl;
    } on StorageException catch (e) {
      debugPrint('[ProfileService] uploadAvatar StorageException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[ProfileService] uploadAvatar error: $e');
      return null;
    }
  }
}