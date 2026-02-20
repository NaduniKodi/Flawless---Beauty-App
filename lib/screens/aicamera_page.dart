import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// ================= FACE PAINTER =================
class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final bool mirrorX;

  FacePainter(this.faces, this.imageSize, {this.mirrorX = true});

  double _mirrorX(double x, double scaleX) {
    if (mirrorX) {
      return (imageSize.width - x) * scaleX;
    }
    return x * scaleX;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final boxPaint = Paint()
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
      // ✅ FIX Bug 2: Mirror bounding box X for front camera
      final left = _mirrorX(face.boundingBox.right, scaleX); // note: left/right swap when mirroring
      final right = _mirrorX(face.boundingBox.left, scaleX);
      final top = face.boundingBox.top * scaleY;
      final bottom = face.boundingBox.bottom * scaleY;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), boxPaint);

      // Landmarks
      for (final landmark in face.landmarks.values) {
        if (landmark == null) continue;
        final dx = _mirrorX(landmark.position.x.toDouble(), scaleX);
        final dy = landmark.position.y * scaleY;
        canvas.drawCircle(Offset(dx, dy), 4, landmarkPaint);
      }

      // Contours
      for (final contour in face.contours.values) {
        if (contour == null || contour.points.isEmpty) continue;
        final points = contour.points
            .map((p) => Offset(_mirrorX(p.x.toDouble(), scaleX), p.y * scaleY))
            .toList();
        canvas.drawPoints(PointMode.polygon, points, contourPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) => true;
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
  Size _imageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _initCamera();
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
      ? ImageFormatGroup.nv21      // ✅ Android → NV21
      : ImageFormatGroup.bgra8888, // ✅ iOS → BGRA
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
    // ✅ FIX Bug 1: Don't set _isDetecting here — let _processImage own the flag
    _processImage(image);
  }

  /// ================= FIXED IMAGE PROCESSING =================
  Future<void> _processImage(CameraImage image) async {
    // ✅ FIX Bug 1: Guard is set HERE, not in the caller
   
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final camera = _cameraController.description;
      final rotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final format = Platform.isAndroid
                  ? InputImageFormat.nv21
                  : InputImageFormat.bgra8888;
                  
      // ✅ FIX Bug 3: Use WriteBuffer to correctly concatenate plane bytes
      final WriteBuffer allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      final bytesPerRow = Platform.isAndroid
        ? image.width
        : image.planes.first.bytesPerRow;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: bytesPerRow, //image.planes.first.bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);
      debugPrint("✅ Detected faces: ${faces.length}");

      final rotatedSize = (rotation == InputImageRotation.rotation90deg ||
                     rotation == InputImageRotation.rotation270deg)
    ? Size(image.height.toDouble(), image.width.toDouble()) // ✅ swap for portrait
    : Size(image.width.toDouble(), image.height.toDouble());


      if (mounted) {
        setState((){
    _faces = faces;
    _imageSize = rotatedSize; // ✅ store rotated size
  });
      }
    } catch (e) {
      debugPrint("❌ Face detection error: $e");
    } finally {
      _isDetecting = false; // ✅ Always released here
    }
  }

  /// ================= CAPTURE =================
  Future<void> _capturePhoto() async {
    if (_cameraController.value.isTakingPicture) return;

    try {
      if (_cameraController.value.isStreamingImages) {
        await _cameraController.stopImageStream();
      }

      final file = await _cameraController.takePicture();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Photo saved: ${file.path}")),
        );
      }
    } catch (e) {
      debugPrint("Capture error: $e");
    } finally {
      // Restart stream after capture
      if (!_cameraController.value.isStreamingImages) {
        await _cameraController.startImageStream(_onImageAvailable);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final previewSize = _cameraController.value.previewSize!;
    // previewSize is in sensor orientation (landscape), so swap for portrait display
    final previewWidth = previewSize.height;
    final previewHeight = previewSize.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: FittedBox(
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
                            ? Size(previewSize.height, previewSize.width) // fallback
                            : _imageSize,                                  // ✅ use rotated size
                        mirrorX: true,
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.white,
            child: ElevatedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture Photo"),
            ),
          ),
        ],
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