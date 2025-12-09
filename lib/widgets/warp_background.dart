import 'dart:math';
import 'package:flutter/material.dart';

class WarpBackground extends StatefulWidget {
  final String speedLabel; // e.g. "4", "10~13"

  const WarpBackground({super.key, required this.speedLabel});

  @override
  State<WarpBackground> createState() => _WarpBackgroundState();
}

class _WarpBackgroundState extends State<WarpBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final Random _random = Random();
  double _currentSpeedMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Tick driver
    )..repeat();
    
    // Initialize stars
    for (int i = 0; i < 100; i++) {
      _stars.add(_generateStar());
    }
  }

  @override
  void didUpdateWidget(WarpBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speedLabel != widget.speedLabel) {
      _updateSpeedMultiplier();
    }
  }

  void _updateSpeedMultiplier() {
    // Parse speed label to get a numeric factor
    // "10~13" -> take average or max? Let's take approx 11.5
    // "4" -> 4
    double val = 4.0;
    String clean = widget.speedLabel.replaceAll(RegExp(r'[^0-9\.]'), ' ');
    List<String> parts = clean.trim().split(RegExp(r'\s+'));
    if (parts.isNotEmpty) {
      if (parts.length > 1) {
        double a = double.tryParse(parts[0]) ?? 4.0;
        double b = double.tryParse(parts[1]) ?? 4.0;
        val = (a + b) / 2;
      } else {
        val = double.tryParse(parts[0]) ?? 4.0;
      }
    }
    
    // speed 4 -> multiplier 1.0
    // speed 12 -> multiplier 3.0
    _currentSpeedMultiplier = val / 4.0; 
  }

  Star _generateStar() {
    return Star(
      x: _random.nextDouble() * 2 - 1,   // -1 to 1
      y: _random.nextDouble() * 2 - 1,   // -1 to 1
      z: _random.nextDouble(),           // 0 to 1 (depth)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WarpPainter(
            stars: _stars,
            speedMultiplier: _currentSpeedMultiplier,
            random: _random,
          ),
          child: Container(),
        );
      },
    );
  }
}

class Star {
  double x;
  double y;
  double z;
  double pz; // previous z

  Star({required this.x, required this.y, required this.z}) : pz = z;
}

class WarpPainter extends CustomPainter {
  final List<Star> stars;
  final double speedMultiplier;
  final Random random;

  WarpPainter({required this.stars, required this.speedMultiplier, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2;
    double cy = size.height / 2;
    
    // Base speed factor
    double speed = 0.02 * speedMultiplier;

    Paint paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < stars.length; i++) {
      var star = stars[i];

      // Update star position
      star.z = star.z - speed;
      
      // Reset if it passes screen
      if (star.z < 0.01) {
        star.z = 1.0;
        star.x = random.nextDouble() * 2 - 1;
        star.y = random.nextDouble() * 2 - 1;
        star.pz = star.z;
      }

      // Map 3D to 2D
      // x' = x / z
      double sx = (star.x / star.z) * cx + cx;
      double sy = (star.y / star.z) * cy + cy;

      double r = (1.0 - star.z) * 4.0 * speedMultiplier; // Size grows as it gets closer
      
      // Previous position for trail effect (warp lines)
      double px = (star.x / (star.z + speed)) * cx + cx;
      double py = (star.y / (star.z + speed)) * cy + cy;
      
      paint.strokeWidth = r;
      // Opacity based on depth
      paint.color = Colors.white.withOpacity((1.0 - star.z).clamp(0.0, 1.0));

      if (speedMultiplier > 1.5) {
        // Draw line for warp effect
        canvas.drawLine(Offset(px, py), Offset(sx, sy), paint);
      } else {
        // Draw dot for slow speed
        canvas.drawCircle(Offset(sx, sy), r/2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(WarpPainter oldDelegate) {
    return true; // Always animate
  }
}
