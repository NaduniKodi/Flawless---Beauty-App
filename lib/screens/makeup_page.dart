// lib/screens/makeup_page.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import '../ai/ar_makeup_painter.dart';
import '../interface/makeup_report_page.dart';
import '../services/makeup_analysis_service.dart';
//import 'package:flawless_beauty_app/screens/makeup_page.dart';
import 'package:flawless_beauty_app/services/makeup_history.dart';

const Color _rose       = Color(0xFFE8708A);
const Color _orchid     = Color(0xFFF8AFCB);
const Color _orchidDark = Color.fromARGB(255, 255, 152, 191);
const Color _bg         = Color(0xFF0E0818);

class MakeupPage extends StatefulWidget {
  const MakeupPage({super.key});
  @override
  State<MakeupPage> createState() => _MakeupPageState();
}

class _MakeupPageState extends State<MakeupPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cam;
  FaceDetector? _detector;
  bool _initialized = false;
  bool _isDetecting = false;
  List<Face> _faces = [];
  Size _imageSize = Size.zero;
  DateTime _lastProcessed = DateTime.now();

  ARMakeupLook _activeLook = arMakeupPresets.first;
  double _intensity = 0.75;
  bool _arEnabled = true;

  late AnimationController _btnCtrl;
  late Animation<double> _btnScale;
  bool _capturing = false;
  bool _analyzing = false;

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut));
    _initCamera();
  }

  @override
  void dispose() {
    _cam?.dispose();
    _detector?.close();
    _btnCtrl.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _cam = CameraController(
      front, ResolutionPreset.medium, enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _cam!.initialize();
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    if (mounted) setState(() => _initialized = true);
    _cam!.startImageStream(_onFrame);
  }

  void _onFrame(CameraImage img) {
    final now = DateTime.now();
    if (_isDetecting) return;
    if (now.difference(_lastProcessed).inMilliseconds < 80) return;
    _lastProcessed = now;
    _processFrame(img);
  }

  Future<void> _processFrame(CameraImage img) async {
    if (_isDetecting || _detector == null) return;
    _isDetecting = true;
    try {
      final cam = _cam!.description;
      final rot = InputImageRotationValue.fromRawValue(cam.sensorOrientation)
          ?? InputImageRotation.rotation0deg;
      final fmt = Platform.isAndroid
          ? InputImageFormat.nv21
          : InputImageFormat.bgra8888;

      final buf = WriteBuffer();
      for (final p in img.planes) buf.putUint8List(p.bytes);
      final bytes = buf.done().buffer.asUint8List();
      final bpr = Platform.isAndroid
          ? img.width
          : img.planes.first.bytesPerRow;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(img.width.toDouble(), img.height.toDouble()),
          rotation: rot,
          format: fmt,
          bytesPerRow: bpr,
        ),
      );
      final faces = await _detector!.processImage(inputImage);
      final rotatedSize = (rot == InputImageRotation.rotation90deg ||
              rot == InputImageRotation.rotation270deg)
          ? Size(img.height.toDouble(), img.width.toDouble())
          : Size(img.width.toDouble(), img.height.toDouble());

      if (mounted) setState(() { _faces = faces; _imageSize = rotatedSize; });
    } catch (_) {
    } finally {
      _isDetecting = false;
    }
  }

  // ── Copy temp camera file to a stable documents path ──────────────────────
  // The camera plugin saves to a temp/cache dir that the OS can delete.
  // Copying to getApplicationDocumentsDirectory() gives a stable path that
  // persists for the lifetime of the app install.
  Future<String> _saveToStablePath(String tempPath) async {
    try {
      final docsDir  = await getApplicationDocumentsDirectory();
      final fileName = 'makeup_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final stableFile = File('${docsDir.path}/$fileName');
      await File(tempPath).copy(stableFile.path);
      debugPrint('✅ Image saved to stable path: ${stableFile.path}');
      return stableFile.path;
    } catch (e) {
      debugPrint('⚠️ Could not copy to stable path, using temp: $e');
      return tempPath; // fall back to temp path
    }
  }

  Future<void> _capture() async {
    if (_cam == null || _cam!.value.isTakingPicture || _capturing) return;
    setState(() => _capturing = true);
    _btnCtrl.forward();
    try {
      if (_cam!.value.isStreamingImages) await _cam!.stopImageStream();
      final tempFile = await _cam!.takePicture();
      if (!mounted) return;

      // ✅ Copy to stable path so Image.file always finds it
      final stablePath = await _saveToStablePath(tempFile.path);

      setState(() => _analyzing = true);

      final result = await MakeupAnalysisService.analyze(
        imagePath: stablePath,
        mlKitFaces: _faces,
        useAI: true,
      );

      // Save to Supabase (uploads stable file + stores signed URL in DB)
      await MakeupHistory.instance.add(result, stablePath);

      if (mounted) {
        setState(() => _analyzing = false);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MakeupReportPage(
              imagePath: stablePath, // ✅ stable path, always readable
              result: result,
            ),
          ),
        );
        if (!_cam!.value.isStreamingImages) {
          await _cam!.startImageStream(_onFrame);
        }
      }
    } catch (e) {
      debugPrint('Makeup capture error: $e');
      if (mounted) setState(() => _analyzing = false);
    } finally {
      _btnCtrl.reverse();
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_orchid),
          ),
        ),
      );
    }

    final prev  = _cam!.value.previewSize!;
    final prevW = prev.height;
    final prevH = prev.width;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        Positioned.fill(
          child: Column(children: [
            Expanded(
              child: Stack(fit: StackFit.expand, children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: prevW, height: prevH,
                    child: Stack(fit: StackFit.expand, children: [
                      CameraPreview(_cam!),
                      if (_arEnabled && _faces.isNotEmpty)
                        CustomPaint(
                          painter: ARMakeupPainter(
                            faces: _faces,
                            imageSize: _imageSize.isEmpty
                                ? Size(prevW, prevH)
                                : _imageSize,
                            look: _activeLook,
                            mirrorX: true,
                            intensity: _intensity,
                          ),
                        ),
                    ]),
                  ),
                ),
                _buildHeader(),
                if (_faces.isEmpty)
                  Positioned(
                    bottom: 16, left: 0, right: 0,
                    child: Center(
                      child: _Pill(
                          text: 'Position your face to try on makeup'),
                    ),
                  ),
              ]),
            ),
            _buildBottomPanel(),
          ]),
        ),
        if (_analyzing) _buildAnalyzingOverlay(),
      ]),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.65), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const Expanded(
                child: Text('Makeup Try-On',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ),
              GestureDetector(
                onTap: () =>
                    setState(() => _arEnabled = !_arEnabled),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _arEnabled
                        ? _orchid.withOpacity(0.85)
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      _arEnabled
                          ? Icons.face_retouching_natural
                          : Icons.face_retouching_off,
                      color: Colors.white, size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(_arEnabled ? 'AR On' : 'AR Off',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
      child: Column(children: [
        // Look selector
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: arMakeupPresets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final look   = arMakeupPresets[i];
              final active = look.id == _activeLook.id;
              return GestureDetector(
                onTap: () => setState(() => _activeLook = look),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 62,
                  decoration: BoxDecoration(
                    color: active
                        ? _orchid.withOpacity(0.18)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active
                          ? _orchid
                          : Colors.white.withOpacity(0.1),
                      width: active ? 1.8 : 1.0,
                    ),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(look.emoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(look.label,
                            style: TextStyle(
                              color:
                                  active ? _orchid : Colors.white54,
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            )),
                      ]),
                ),
              );
            },
          ),
        ),

        // Intensity slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(children: [
            const Icon(Icons.invert_colors_off,
                color: Colors.white38, size: 16),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: _orchid,
                  inactiveTrackColor: Colors.white12,
                  thumbColor: _orchid,
                  overlayColor: _orchid.withOpacity(0.2),
                ),
                child: Slider(
                  value: _intensity,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (v) => setState(() => _intensity = v),
                ),
              ),
            ),
            const Icon(Icons.invert_colors, color: _orchid, size: 16),
          ]),
        ),

        const SizedBox(height: 6),

        // Capture button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ScaleTransition(
            scale: _btnScale,
            child: GestureDetector(
              onTapDown: (_) => _btnCtrl.forward(),
              onTapUp: (_) {
                _btnCtrl.reverse();
                _capture();
              },
              onTapCancel: () => _btnCtrl.reverse(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_rose, _orchid],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _orchid.withOpacity(0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _capturing
                            ? Icons.hourglass_bottom_rounded
                            : Icons.auto_fix_high_rounded,
                        color: Colors.white, size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _capturing
                            ? 'Capturing…'
                            : 'Analyze My Features',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.72),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 56, height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_orchid),
                    backgroundColor: _orchid.withOpacity(0.15),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('✨ Analyzing your features…',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Finding your perfect tutorials',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 13)),
              ]),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(color: Colors.white70, fontSize: 13)),
    );
  }
}