import 'package:flutter/material.dart';
import 'dart:ui';

class DrawingPoint {
  Offset offset;
  Paint paint;
  DrawingPoint(this.offset, this.paint);
}

class StickerNode {
  String emoji;
  Offset offset;
  double scale;
  double rotation;
  double initialScale;
  double initialRotation;

  StickerNode({
    required this.emoji,
    required this.offset,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.initialScale = 1.0,
    this.initialRotation = 0.0,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> pointsList;
  DrawingPainter({required this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i]!.offset, pointsList[i + 1]!.offset, pointsList[i]!.paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [pointsList[i]!.offset], pointsList[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
