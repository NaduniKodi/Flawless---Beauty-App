// lib/models/scan_history.dart
// Singleton store for past scan results. 
// In a real app, persist with shared_preferences or a local DB.

import 'package:flutter/material.dart';
import '../services/skin_analysis_service.dart';

class ScanRecord {
  final SkinAnalysisResult result;
  final String imagePath;
  final DateTime scannedAt;

  ScanRecord({
    required this.result,
    required this.imagePath,
    required this.scannedAt,
  });
}

class ScanHistory extends ChangeNotifier {
  static final ScanHistory instance = ScanHistory._();
  ScanHistory._();

  final List<ScanRecord> _records = [];

  List<ScanRecord> get records => List.unmodifiable(
      _records.reversed.toList()); // newest first

  void add(SkinAnalysisResult result, String imagePath) {
    _records.add(ScanRecord(
      result: result,
      imagePath: imagePath,
      scannedAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void remove(int index) {
    // index is into the reversed list
    final realIndex = _records.length - 1 - index;
    if (realIndex >= 0 && realIndex < _records.length) {
      _records.removeAt(realIndex);
      notifyListeners();
    }
  }
}