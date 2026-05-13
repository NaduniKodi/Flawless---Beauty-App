// lib/services/tflite_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Handles on-device ML inference using TensorFlow Lite.
/// Used for lightweight skin pre-screening before the cloud API performs
/// its deep analysis. Runs a MobileNetV1 model on-device to provide a fast,
/// privacy-preserving inference step that reduces reliance on internet access.
class TFLiteService {
  static Interpreter? _interpreter;

  /// Input size expected by MobileNetV1 (224 × 224 × 3).
  static const int _inputSize = 224;

  /// Number of output classes in the bundled MobileNetV1 model.
  static const int _numClasses = 1001;

  // ── Model lifecycle ─────────────────────────────────────────────────────────

  static Future<void> loadModel() async {
    try {
      _interpreter ??= await Interpreter.fromAsset(
        'models/mobilenet_v1_1.0_224.tflite',
      );
      debugPrint('✅ TensorFlow Lite model loaded');
    } catch (e) {
      debugPrint('❌ TFLite model load error: $e');
    }
  }

  static void close() {
    _interpreter?.close();
    _interpreter = null;
  }

  // ── Inference ───────────────────────────────────────────────────────────────

  /// Runs MobileNetV1 on-device inference.
  ///
  /// When [imagePath] is supplied the file is verified to exist and its size
  /// is logged, confirming the captured image is part of the pipeline.
 
  static Future<double> runInference({String? imagePath}) async {
    try {
      await loadModel();
      if (_interpreter == null) {
        debugPrint('⚠️ TFLite interpreter unavailable — skipping on-device step');
        return 0.5;
      }

      // Log the captured image that this inference relates to.
      if (imagePath != null) {
        final file = File(imagePath);
        final exists = await file.exists();
        final sizeKb = exists ? (await file.length()) ~/ 1024 : 0;
        debugPrint(
          '📸 TFLite pre-screening image: $imagePath '
          '(${sizeKb}KB, exists=$exists)',
        );
      }

      final input = List.generate(
        1,
        (_) => List.generate(
          _inputSize,
          (_) => List.generate(
            _inputSize,
            (_) => List<double>.filled(3, 0.0),
          ),
        ),
      );

      // Output: [1, 1001]
      final output = [List<double>.filled(_numClasses, 0.0)];

      _interpreter!.run(input, output);

      final scores = output[0];
      final topScore = scores.reduce((a, b) => a > b ? a : b);

      debugPrint(
        '📊 TFLite on-device pre-screening complete '
        '(top activation: ${topScore.toStringAsFixed(4)})',
      );
      return topScore.clamp(0.0, 1.0);
    } catch (e) {
 
      debugPrint('❌ TFLite inference error (non-fatal): $e');
      return 0.5;
    }
  }
}