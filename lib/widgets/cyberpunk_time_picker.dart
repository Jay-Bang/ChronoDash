import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberpunkTimePicker extends StatefulWidget {
  final int initialDurationSeconds;
  final ValueChanged<int> onDurationChanged;

  const CyberpunkTimePicker({
    super.key,
    required this.initialDurationSeconds,
    required this.onDurationChanged,
  });

  @override
  State<CyberpunkTimePicker> createState() => _CyberpunkTimePickerState();
}

class _CyberpunkTimePickerState extends State<CyberpunkTimePicker> {
  late FixedExtentScrollController _minController;
  late FixedExtentScrollController _secController;

  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialDurationSeconds ~/ 60;
    _seconds = widget.initialDurationSeconds % 60;
    _minController = FixedExtentScrollController(initialItem: _minutes);
    _secController = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void dispose() {
    _minController.dispose();
    _secController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onDurationChanged(_minutes * 60 + _seconds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF101018),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection Highlight Bar
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
              ),
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minutes Wheel
              _buildWheel(
                controller: _minController,
                itemCount: 61,
                label: 'MIN',
                onChanged: (value) {
                  _minutes = value;
                  _notifyChange();
                },
              ),
              
              // Separator
              Text(
                ':',
                style: GoogleFonts.orbitron(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Seconds Wheel
              _buildWheel(
                controller: _secController,
                itemCount: 60,
                label: 'SEC',
                onChanged: (value) {
                  _seconds = value;
                  _notifyChange();
                },
              ),
            ],
          ),
          
          // Gradient Overlay so text fades out at top/bottom
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF101018).withOpacity(0.9),
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF101018).withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String label,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: 70,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 50,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          HapticFeedback.selectionClick();
          onChanged(index);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Color logic handled by opacity/blur in real 3D engines, but here text style is static. 
                                       // However, the gradient overlay provides the fading effect.
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
