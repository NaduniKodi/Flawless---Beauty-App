// lib/services/profile_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  SupabaseClient get _db => Supabase.instance.client;
  String? get _uid => _db.auth.currentUser?.id;

  // ── Fetch ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> fetch() async {
    final uid = _uid;
    if (uid == null) {
      debugPrint('[ProfileService] fetch: no signed-in user');
      return null;
    }
    try {
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
  Future<String?> uploadAvatar(File file) async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final bytes = await file.readAsBytes();
      final path = '$uid/avatar.jpg';
      await _db.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
      final signedUrl = await _db.storage
          .from('avatars')
          .createSignedUrl(path, 315360000);
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

  // ── Delete Account ─────────────────────────────────────────────────────────
  /// Calls the Edge Function which:
  ///   1. Deletes the avatar from storage
  ///   2. Deletes the profile row
  ///   3. Deletes the auth user (prevents re-login)
  /// Then signs out locally.
  Future<bool> deleteAccount() async {
    final uid = _uid;
    if (uid == null) {
      debugPrint('[ProfileService] deleteAccount: no signed-in user');
      return false;
    }

    try {
      // Get the current session JWT to authenticate the Edge Function call
      final session = _db.auth.currentSession;
      if (session == null) {
        debugPrint('[ProfileService] deleteAccount: no active session');
        return false;
      }

      // Call your deployed Edge Function
      final response = await _db.functions.invoke(
        'delete-account',
        method: HttpMethod.post,
      );

      if (response.status != 200) {
        final body = response.data;
        debugPrint('[ProfileService] deleteAccount failed: $body');
        return false;
      }

      // Sign out locally — the auth user is already gone on the server
      await _db.auth.signOut();
      return true;

    } on FunctionException catch (e) {
      debugPrint('[ProfileService] deleteAccount FunctionException: ${e.details}');
      return false;
    } catch (e) {
      debugPrint('[ProfileService] deleteAccount error: $e');
      return false;
    }
  }
}