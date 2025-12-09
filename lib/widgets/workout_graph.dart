import 'package:flutter/material.dart';
import '../models/interval_step.dart';

class WorkoutGraph extends StatelessWidget {
  final List<IntervalStep> program;
  final int currentIndex;
  final double height;
  final Function(int)? onStepTap; // Add callback

  const WorkoutGraph({
    super.key,
    required this.program,
    required this.currentIndex,
    this.height = 80,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(program.length, (index) {
          final step = program[index];
          // Determine height factor based on speed
          double speedVal = _parseSpeed(step.speedLabel);
          double normalizedHeight = (speedVal - 2) / (13 - 2); 
          normalizedHeight = normalizedHeight.clamp(0.2, 1.0);
          
          bool isCurrent = index == currentIndex;
          bool isPast = index < currentIndex;
          
          return Expanded(
            flex: step.durationSeconds, 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: GestureDetector(
                onTap: () {
                  if (onStepTap != null) onStepTap!(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: height * normalizedHeight,
                  decoration: BoxDecoration(
                    color: isCurrent 
                        ? const Color(0xFF00E5FF) // Neon Cyan
                        : isPast 
                            ? Colors.cyanAccent.withOpacity(0.2) // Dimmed
                            : Colors.grey.withOpacity(0.3), // Future
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    boxShadow: isCurrent ? [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.6),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      )
                    ] : [],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  double _parseSpeed(String label) {
    // "10~13" -> 11.5
    String clean = label.replaceAll(RegExp(r'[^0-9\.]'), ' ');
    List<String> parts = clean.trim().split(RegExp(r'\s+'));
    if (parts.isNotEmpty) {
      if (parts.length > 1) {
        double a = double.tryParse(parts[0]) ?? 4.0;
        double b = double.tryParse(parts[1]) ?? 4.0;
        return (a + b) / 2;
      } else {
        return double.tryParse(parts[0]) ?? 4.0;
      }
    }
    return 4.0;
  }
}
