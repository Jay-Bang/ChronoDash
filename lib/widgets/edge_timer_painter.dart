import 'dart:ui';
import 'package:flutter/material.dart';

class EdgeTimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final double strokeWidth;
  final Color color;

  EdgeTimerPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6.0); // Neon light glow

    final Paint corePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.3
      ..strokeCap = StrokeCap.round;

    // We need to trace the screen border starting from TOP-CENTER (12 o'clock)
    // and moving CLOCKWISE.
    
    // Inset to avoid clipping
    final double inset = strokeWidth * 2.0; 
    final Rect rect = Rect.fromLTWH(
      inset, 
      inset, 
      size.width - (inset * 2), 
      size.height - (inset * 2)
    );
    
    double r = 35.0; // Corner radius
    
    // Manual Path Construction for Top-Center Start
    Path path = Path();
    
    // 1. Start at Top Center
    path.moveTo(rect.center.dx, rect.top);
    
    // 2. Line to Top Right Corner Start
    path.lineTo(rect.right - r, rect.top);
    
    // 3. Arc Top Right
    path.arcToPoint(Offset(rect.right, rect.top + r), radius: Radius.circular(r));
    
    // 4. Line to Bottom Right Corner Start
    path.lineTo(rect.right, rect.bottom - r);
    
    // 5. Arc Bottom Right
    path.arcToPoint(Offset(rect.right - r, rect.bottom), radius: Radius.circular(r));
    
    // 6. Line to Bottom Left Corner Start
    path.lineTo(rect.left + r, rect.bottom);
    
    // 7. Arc Bottom Left
    path.arcToPoint(Offset(rect.left, rect.bottom - r), radius: Radius.circular(r));
    
    // 8. Line to Top Left Corner Start
    path.lineTo(rect.left, rect.top + r);
    
    // 9. Arc Top Left
    path.arcToPoint(Offset(rect.left + r, rect.top), radius: Radius.circular(r));
    
    // 10. Close back to Top Center
    path.lineTo(rect.center.dx, rect.top);

    // Extract sub-path based on progress
    PathMetrics metrics = path.computeMetrics();
    for (PathMetric metric in metrics) {
      double length = metric.length * progress;
      Path extract = metric.extractPath(0.0, length, startWithMoveTo: true);
      canvas.drawPath(extract, paint);
      canvas.drawPath(extract, corePaint);
    }
  }

  @override
  bool shouldRepaint(EdgeTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
