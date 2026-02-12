import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;

  FacePainter(this.faces, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final landmarkPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    final contourPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final face in faces) {
      final rect = Rect.fromLTRB(
        face.boundingBox.left * size.width / imageSize.width,
        face.boundingBox.top * size.height / imageSize.height,
        face.boundingBox.right * size.width / imageSize.width,
        face.boundingBox.bottom * size.height / imageSize.height,
      );

      canvas.drawRect(rect, paint);

      for (final landmark in face.landmarks.values) {
        if (landmark == null) continue;
        final position = landmark.position;
        final dx = position.x * size.width / imageSize.width;
        final dy = position.y * size.height / imageSize.height;
        canvas.drawCircle(Offset(dx, dy), 3.0, landmarkPaint);
      }

      for (final contour in face.contours.values) {
        if (contour == null || contour.points.isEmpty) continue;
        final points = contour.points
            .map(
              (p) => Offset(
                p.x * size.width / imageSize.width,
                p.y * size.height / imageSize.height,
              ),
            )
            .toList(growable: false);
        canvas.drawPoints(PointMode.polygon, points, contourPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) =>
      oldDelegate.faces != faces;
}

/// ================= AI CAMERA PAGE =================
class AICameraPage extends StatefulWidget {
  const AICameraPage({super.key});

  @override
  State<AICameraPage> createState() => _AICameraPageState();
}

class _AICameraPageState extends State<AICameraPage> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;

  bool _isDetecting = false;
  bool _initialized = false;
  List<Face> _faces = [];
  DateTime _lastProcessed = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
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

    setState(() => _initialized = true);

    _cameraController.startImageStream((image) {
      if (_isDetecting) return;
      final now = DateTime.now();
      if (now.difference(_lastProcessed).inMilliseconds < 300) return;
      _lastProcessed = now;
      _isDetecting = true;
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final bytes = image.planes[0].bytes;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation270deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (mounted) {
        setState(() => _faces = faces);
      }
    } catch (e) {
      debugPrint("❌ Face detection error: $e");
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController.value.isTakingPicture) return;

    try {
      if (_cameraController.value.isStreamingImages) {
        // Pause the stream to allow a clean still capture.
        await _cameraController.stopImageStream();
      }

      final file = await _cameraController.takePicture();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Photo saved: ${file.path}")));
      }
    } catch (e) {
      debugPrint("❌ Capture error: $e");
    } finally {
      if (mounted && !_cameraController.value.isStreamingImages) {
        _cameraController.startImageStream((image)  {
          if (_isDetecting) return;
          final now = DateTime.now();
          if (now.difference(_lastProcessed).inMilliseconds < 300) return;
          _lastProcessed = now;
          _isDetecting = true;
          _processImage(image);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final previewSize = _cameraController.value.previewSize!;
    final previewWidth = previewSize.height;
    final previewHeight = previewSize.width;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.topLeft,
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
                                Size(previewWidth, previewHeight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: ElevatedButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Capture photo"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }
}
