// lib/services/yoga_progress_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class YogaProgressService extends ChangeNotifier {
  static final YogaProgressService instance = YogaProgressService._();
  YogaProgressService._();

  final _db = Supabase.instance.client;

  // ── In-memory cache ────────────────────────────────────────────────────────
  // Key: '<source>|<routineTitle>|<exerciseName>'
  // routineTitle is '' for AI exercises.
  final Map<String, int> _cache = {};
  bool _loaded = false;

  // ── Public getters ─────────────────────────────────────────────────────────

  int getReps(
    String source,
    String exerciseName, {
    String routineTitle = '',
  }) =>
      _cache[_k(source, routineTitle, exerciseName)] ?? 0;

  bool isDone(
    String source,
    String exerciseName,
    int target, {
    String routineTitle = '',
  }) =>
      getReps(source, exerciseName, routineTitle: routineTitle) >= target;

  /// How many exercises in [exercises] have reached [target] reps
  /// inside the given [routineTitle].
  int completedInRoutine(
    String routineTitle,
    List<String> exercises,
    int target,
  ) {
    int n = 0;
    for (final name in exercises) {
      if (isDone('manual', name, target, routineTitle: routineTitle)) n++;
    }
    return n;
  }

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> load({bool force = false}) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;
    if (_loaded && !force) return;

    try {
      final rows = await _db
          .from('yoga_progress')
          .select('source, routine_title, exercise_name, reps_done')
          .eq('user_id', uid);

      _cache.clear();
      for (final row in rows as List<dynamic>) {
        _cache[_k(
          row['source']        as String,
          row['routine_title'] as String? ?? '',
          row['exercise_name'] as String,
        )] = (row['reps_done'] as num).toInt();
      }
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ YogaProgressService.load: $e');
    }
  }

  // ── Add one rep ────────────────────────────────────────────────────────────

  Future<void> addRep({
    required String source,         // 'manual' | 'ai_recommended'
    required String exerciseName,
    required int    targetReps,
    String  routineTitle = '',
    String? scanId,
    String? targetArea,
  }) async {
    final uid = _db.auth.currentUser?.id;
    final k = _k(source, routineTitle, exerciseName);
    final current = _cache[k] ?? 0;
    if (current >= targetReps) return;

    // Optimistic update — UI reacts instantly.
    _cache[k] = current + 1;
    notifyListeners();

    if (uid == null) return;
    try {
      await _db.from('yoga_progress').upsert(
        {
          'user_id'      : uid,
          'source'       : source,
          'routine_title': routineTitle,
          'exercise_name': exerciseName,
          'reps_done'    : current + 1,
          'target_reps'  : targetReps,
          'target_area'  : targetArea,
          'scan_id'      : scanId,
          'updated_at'   : DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,source,routine_title,exercise_name',
      );
    } catch (e) {
      // Revert on DB failure so the cache stays consistent.
      _cache[k] = current;
      notifyListeners();
      debugPrint('❌ YogaProgressService.addRep: $e');
    }
  }

  // ── Reset a whole routine ──────────────────────────────────────────────────

  Future<void> resetRoutine(String routineTitle) async {
    final uid = _db.auth.currentUser?.id;

    // Remove from cache immediately.
    _cache.removeWhere((k, _) => k.startsWith('manual|$routineTitle|'));
    notifyListeners();

    if (uid == null) return;
    try {
      await _db
          .from('yoga_progress')
          .delete()
          .eq('user_id', uid)
          .eq('source', 'manual')
          .eq('routine_title', routineTitle);
    } catch (e) {
      debugPrint('❌ YogaProgressService.resetRoutine: $e');
    }
  }

  // ── Clear on sign-out ──────────────────────────────────────────────────────

  void clear() {
    _cache.clear();
    _loaded = false;
    notifyListeners();
  }

  // ── Key helper ─────────────────────────────────────────────────────────────

  String _k(String source, String routineTitle, String exerciseName) =>
      '$source|$routineTitle|$exerciseName';
}