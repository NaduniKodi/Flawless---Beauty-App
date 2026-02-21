// lib/screens/aicamera_page.dart

import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../interface/skin_report_page.dart';
import 'package:flawless_beauty_app/services/skin_analysis_service.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const Color _rose       = Color(0xFFE8708A);
const Color _orchid      = Color(0xFFF8AFCB);
const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);

/// ================= FACE PAINTER =================
class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final bool mirrorX;

  FacePainter(this.faces, this.imageSize, {this.mirrorX = true});

  double _mirrorX(double x, double scaleX) {
    if (mirrorX) return (imageSize.width - x) * scaleX;
    return x * scaleX;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    // ── Bounding box ──────────────────────────────────────────────────────────
    final boxPaint = Paint()
      ..color = _orchid.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // ── Landmarks ─────────────────────────────────────────────────────────────
    final landmarkPaint = Paint()
      ..color = _rose.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    // ── Contours ──────────────────────────────────────────────────────────────
    final contourPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final face in faces) {
      final left   = _mirrorX(face.boundingBox.right, scaleX);
      final right  = _mirrorX(face.boundingBox.left, scaleX);
      final top    = face.boundingBox.top * scaleY;
      final bottom = face.boundingBox.bottom * scaleY;

      // Rounded rectangle instead of plain rect
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(left, top, right, bottom), const Radius.circular(12)),
        boxPaint,
      );

      // Corner accent marks
      final accentPaint = Paint()
        ..color = _orchid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      const len = 18.0;
      // TL
      canvas.drawLine(Offset(left, top + len), Offset(left, top), accentPaint);
      canvas.drawLine(Offset(left, top), Offset(left + len, top), accentPaint);
      // TR
      canvas.drawLine(Offset(right - len, top), Offset(right, top), accentPaint);
      canvas.drawLine(Offset(right, top), Offset(right, top + len), accentPaint);
      // BL
      canvas.drawLine(Offset(left, bottom - len), Offset(left, bottom), accentPaint);
      canvas.drawLine(Offset(left, bottom), Offset(left + len, bottom), accentPaint);
      // BR
      canvas.drawLine(Offset(right - len, bottom), Offset(right, bottom), accentPaint);
      canvas.drawLine(Offset(right, bottom), Offset(right, bottom - len), accentPaint);

      // Landmarks
      for (final landmark in face.landmarks.values) {
        if (landmark == null) continue;
        final dx = _mirrorX(landmark.position.x.toDouble(), scaleX);
        final dy = landmark.position.y * scaleY;
        canvas.drawCircle(Offset(dx, dy), 3.5, landmarkPaint);
      }

      // Contours
      for (final contour in face.contours.values) {
        if (contour == null || contour.points.isEmpty) continue;
        final points = contour.points
            .map((p) =>
                Offset(_mirrorX(p.x.toDouble(), scaleX), p.y * scaleY))
            .toList();
        canvas.drawPoints(PointMode.polygon, points, contourPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) => true;
}

/// ================= ANALYZING SCREEN =================
class _AnalyzingScreen extends StatefulWidget {
  final String imagePath;
  const _AnalyzingScreen({required this.imagePath});

  @override
  State<_AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<_AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  String _statusMessage = 'Analyzing your skin…';
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _analyze();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    try {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => _statusMessage = 'Finding available AI model…');
      });
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted) setState(() => _statusMessage = 'Almost done, please wait…');
      });

      final result = await SkinAnalysisService.analyzeImage(widget.imagePath);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SkinReportPage(
              result: result,
              imagePath: widget.imagePath,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Analysis Failed',
                style: TextStyle(fontWeight: FontWeight.w700)),
            content: const Text(
              'All free AI models are currently busy.\nPlease wait 1 minute and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _analyze();
                },
                child: Text('Retry',
                    style: TextStyle(color: _orchidDark)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0818),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Pulsing image preview ─────────────────────────────────────
                ScaleTransition(
                  scale: _pulse,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: _orchid.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.file(
                        File(widget.imagePath),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ── Gradient progress indicator ───────────────────────────────
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(_orchid),
                    backgroundColor: _orchid.withOpacity(0.15),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Status text ───────────────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _statusMessage,
                    key: ValueKey(_statusMessage),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take up to 30 seconds',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ================= AI CAMERA PAGE =================
class AICameraPage extends StatefulWidget {
  const AICameraPage({super.key});

  @override
  State<AICameraPage> createState() => _AICameraPageState();
}

class _AICameraPageState extends State<AICameraPage>
    with SingleTickerProviderStateMixin {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;

  bool _isDetecting = false;
  bool _initialized = false;
  List<Face> _faces = [];
  DateTime _lastProcessed = DateTime.now();
  Size _imageSize = Size.zero;

  // Capture button animation
  late AnimationController _btnCtrl;
  late Animation<double> _btnScale;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut));
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    _btnCtrl.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _cameraController.initialize();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    if (mounted) setState(() => _initialized = true);
    _cameraController.startImageStream(_onImageAvailable);
  }

  void _onImageAvailable(CameraImage image) {
    final now = DateTime.now();
    if (_isDetecting) return;
    if (now.difference(_lastProcessed).inMilliseconds < 250) return;
    _lastProcessed = now;
    _processImage(image);
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;
    try {
      final camera   = _cameraController.description;
      final rotation = InputImageRotationValue.fromRawValue(
              camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;
      final format = Platform.isAndroid
          ? InputImageFormat.nv21
          : InputImageFormat.bgra8888;

      final WriteBuffer allBytes = WriteBuffer();
      for (final plane in image.planes) allBytes.putUint8List(plane.bytes);
      final bytes       = allBytes.done().buffer.asUint8List();
      final bytesPerRow = Platform.isAndroid
          ? image.width
          : image.planes.first.bytesPerRow;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);

      final rotatedSize =
          (rotation == InputImageRotation.rotation90deg ||
                  rotation == InputImageRotation.rotation270deg)
              ? Size(image.height.toDouble(), image.width.toDouble())
              : Size(image.width.toDouble(), image.height.toDouble());

      if (mounted) setState(() {
        _faces     = faces;
        _imageSize = rotatedSize;
      });
    } catch (e) {
      debugPrint("❌ Face detection error: $e");
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController.value.isTakingPicture || _capturing) return;
    setState(() => _capturing = true);
    _btnCtrl.forward();

    try {
      if (_cameraController.value.isStreamingImages) {
        await _cameraController.stopImageStream();
      }
      final file = await _cameraController.takePicture();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => _AnalyzingScreen(imagePath: file.path)),
        );
      }
    } catch (e) {
      debugPrint("Capture error: $e");
    } finally {
      _btnCtrl.reverse();
      if (mounted) setState(() => _capturing = false);
      if (!_cameraController.value.isStreamingImages) {
        await _cameraController.startImageStream(_onImageAvailable);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF0E0818),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(_orchid),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Initializing camera…",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final previewSize   = _cameraController.value.previewSize!;
    final previewWidth  = previewSize.height;
    final previewHeight = previewSize.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0818),
      body: Column(
        children: [
          // ── Camera preview ─────────────────────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: previewWidth,
                    height: previewHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_cameraController),
                        CustomPaint(
                          painter: FacePainter(
                            _faces,
                            _imageSize.isEmpty
                                ? Size(previewSize.height, previewSize.width)
                                : _imageSize,
                            mirrorX: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top gradient + back button
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18),
                              ),
                            ),
                            const Expanded(
                              child: Text(
                                "AI Face Scan",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            // Face count badge
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _faces.isNotEmpty
                                    ? _orchid.withOpacity(0.85)
                                    : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _faces.isEmpty
                                    ? "No face"
                                    : "${_faces.length} face${_faces.length > 1 ? 's' : ''} ✓",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Hint text overlay
                if (_faces.isEmpty)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Position your face in the frame",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Bottom control panel ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0818),
              boxShadow: [
                BoxShadow(
                  color: _orchid.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Face detected status
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: _faces.isNotEmpty
                        ? _orchid.withOpacity(0.12)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _faces.isNotEmpty
                          ? _orchid.withOpacity(0.4)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _faces.isNotEmpty
                            ? Icons.face_retouching_natural
                            : Icons.face_outlined,
                        color: _faces.isNotEmpty ? _orchid : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _faces.isNotEmpty
                            ? "Face detected — ready to scan!"
                            : "Waiting for face detection…",
                        style: TextStyle(
                          color:
                              _faces.isNotEmpty ? _orchid : Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Capture button
                ScaleTransition(
                  scale: _btnScale,
                  child: GestureDetector(
                    onTapDown: (_) => _btnCtrl.forward(),
                    onTapUp: (_) {
                      _btnCtrl.reverse();
                      _capturePhoto();
                    },
                    onTapCancel: () => _btnCtrl.reverse(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _faces.isNotEmpty
                              ? [_rose, _orchid]
                              : [Colors.white12, Colors.white12],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _faces.isNotEmpty
                            ? [
                                BoxShadow(
                                  color: _orchid.withOpacity(0.45),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _capturing
                                ? Icons.hourglass_bottom_rounded
                                : Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _capturing ? "Capturing…" : "Capture & Analyze",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}