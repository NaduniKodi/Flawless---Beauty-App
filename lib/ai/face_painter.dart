import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;

  FacePainter(this.faces, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purpleAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dotPaint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.fill;

    for (Face face in faces) {
      // Draw face bounding box
      canvas.drawRect(_scaleRect(face.boundingBox, size), paint);

      // Draw landmarks
      face.landmarks.forEach((type, landmark) {
        if (landmark != null) {
          final point = _scalePoint(
            Offset(
              landmark.position.x.toDouble(),
              landmark.position.y.toDouble(),
            ),
            size,
          );
          canvas.drawCircle(point, 4, dotPaint);
        }
      });
    }
  }

  Rect _scaleRect(Rect rect, Size widgetSize) {
    return Rect.fromLTRB(
      rect.left * widgetSize.width / imageSize.width,
      rect.top * widgetSize.height / imageSize.height,
      rect.right * widgetSize.width / imageSize.width,
      rect.bottom * widgetSize.height / imageSize.height,
    );
  }

  Offset _scalePoint(Offset point, Size widgetSize) {
    return Offset(
      point.dx * widgetSize.width / imageSize.width,
      point.dy * widgetSize.height / imageSize.height,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
