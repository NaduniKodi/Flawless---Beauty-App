import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';


class AICameraPage extends StatefulWidget {
  const AICameraPage({super.key});

  @override
  State<AICameraPage> createState() => _AICameraPageState();
}

class _AICameraPageState extends State<AICameraPage> {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final cameras = await availableCameras();

    _cameraController = CameraController(
      cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      ),
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    setState(() => _isInitialized = true);

    _cameraController!.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    final bytes = Uint8List.fromList(
    image.planes.expand((plane) => plane.bytes).toList(),
    );


    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation270deg,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      debugPrint("Face detected 👤 (${faces.length})");
    }

    _isDetecting = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CameraPreview(_cameraController!),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}
