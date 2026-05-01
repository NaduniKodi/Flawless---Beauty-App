// lib/services/interest_data.dart
import 'package:flutter/foundation.dart';
import 'profile_service.dart';

class InterestData extends ChangeNotifier {
  InterestData._();
  static final InterestData instance = InterestData._();

  Set<String> _selected = {};
  Set<String> get selected => Set.unmodifiable(_selected);

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> load() async {
    final row = await ProfileService.instance.fetch();
    if (row == null) {
      // Brand-new user: sensible defaults
      _selected = {'Glow Up', 'Hydration', 'Natural', 'K-Beauty', 'AM Routine'};
    } else {
      final saved = row['interests'] as List<dynamic>?;
      _selected = saved != null && saved.isNotEmpty
          ? saved.map((e) => e.toString()).toSet()
          : {'Glow Up', 'Hydration', 'Natural', 'K-Beauty', 'AM Routine'};
    }
    notifyListeners();
  }

  // ── Mutators ───────────────────────────────────────────────────────────────
  void toggle(String label) {
    _selected.contains(label) ? _selected.remove(label) : _selected.add(label);
    _persist();
    notifyListeners();
  }

  void saveAll(Set<String> newSelection) {
    _selected = Set.from(newSelection);
    _persist();
    notifyListeners();
  }

  void _persist() =>
      ProfileService.instance.save({'interests': _selected.toList()});

  // ── Clear (sign-out) ───────────────────────────────────────────────────────
  void clear() {
    _selected = {};
    notifyListeners();
  }
}