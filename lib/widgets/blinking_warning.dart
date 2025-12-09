import 'package:flutter/material.dart';

class BlinkingWarning extends StatefulWidget {
  final Widget child;
  final bool active;
  final Duration interval;

  const BlinkingWarning({
    super.key,
    required this.child,
    this.active = false,
    this.interval = const Duration(milliseconds: 500),
  });

  @override
  _BlinkingWarningState createState() => _BlinkingWarningState();
}

class _BlinkingWarningState extends State<BlinkingWarning> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.interval,
    )..repeat(reverse: true);
    
    _opacity = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return widget.child;
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Red alert overlay
        return Stack(
          children: [
            widget.child,
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red.withOpacity(_opacity.value * 0.8),
                    width: 8,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
