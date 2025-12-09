import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter/services.dart'; 
import '../providers/timer_provider.dart';
import '../widgets/edge_timer_painter.dart';
import '../widgets/blinking_warning.dart';
import '../widgets/warp_background.dart';
import '../widgets/workout_graph.dart';
import 'home_screen.dart';

class RunningScreen extends StatefulWidget {
  const RunningScreen({super.key});

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<Color?> _bgColorAnim;
  bool _hasNavigatedFinish = false;

  @override
  void initState() {
    super.initState();
    
    // Background pulsing animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _bgColorAnim = ColorTween(
      begin: const Color(0xFF050510),
      end: const Color(0xFF0A0A1F),
    ).animate(_bgController);

    // Auto-start timer (logic moved to provider, but we trigger it here if not running)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TimerProvider>(context, listen: false);
      // Start Countdown if not already running or counting down
      if (!provider.isRunning && !provider.isCountdown && !provider.isFinished) {
        provider.toggleTimer();
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _bgColorAnim.value,
          body: Consumer<TimerProvider>(
            builder: (context, provider, child) {
              // 1. Countdown Mode
              if (provider.isCountdown) {
                return _buildCountdownScreen(provider);
              }

              // 2. Finish Mode
              if (provider.isFinished) {
                if (!_hasNavigatedFinish) {
                  _hasNavigatedFinish = true;
                  Future.delayed(const Duration(seconds: 4), () {
                    if (mounted) {
                      // Navigate to Home, replacing current stack, and pass arguments or just init
                      // To switch tab, simpler to just replace with HomeScreen(index: 1)
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen(initialIndex: 1)), 
                          (route) => false
                      );
                    }
                  });
                }
                return _buildFinishScreen();
              }

              // 3. Running Mode
              bool shouldBlink = provider.millisecondsRemainingInStep < 10000 && 
                                 provider.millisecondsRemainingInStep > 0;
              
              return Stack(
                children: [
                  // 0. Ambient Gradient Background (Base)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                         color: Color(0xFF050510),
                      ),
                    ),
                  ),

                  // 0.5 Warp Speed Effect
                  Positioned.fill(
                    child: WarpBackground(speedLabel: provider.currentStep.speedLabel),
                  ),

                  // 0.6 Gradient Overlay for Readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.2,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF050510).withOpacity(0.8), // Darker edges
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 1. Edge Timer Gauge (Cyberpunk Neon)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0), // Tiny safety padding
                      child: CustomPaint(
                        painter: EdgeTimerPainter(
                          progress: provider.totalProgress,
                          strokeWidth: 6.0,
                          color: shouldBlink ? const Color(0xFFFFEA00) : const Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                  ),
                  
                  // 2. Blinking Alert Overlay (Full Border Flash)
                  if (shouldBlink)
                    Positioned.fill(
                      child: BlinkingWarning(
                        active: true,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFFFEA00).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 3. Main HUD Content
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Bar: Interval Info
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildHudLabel('INTERVAL', '${provider.currentStepIndex + 1} / ${provider.program.length}'),
                              _buildHudLabel('STATUS', provider.isRunning ? 'ACTIVE' : 'PAUSED'),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Center: Speed Display (Hero Widget)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CURRENT SPEED',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 16,
                                  letterSpacing: 4,
                                  color: Colors.cyanAccent.withOpacity(0.7),
                                  shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
                                ),
                              ),
                              const SizedBox(height: 10),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                switchInCurve: Curves.easeOutBack,
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return ScaleTransition(scale: animation, child: child);
                                },
                                child: Text(
                                  provider.currentStep.speedLabel,
                                  key: ValueKey<String>(provider.currentStep.speedLabel),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 120,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    shadows: [
                                      const Shadow(color: Colors.cyanAccent, blurRadius: 20),
                                      const Shadow(color: Colors.black, blurRadius: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Time Display
                        Center(child: _buildTotalTimeDisplay(provider.totalElapsedMilliseconds)),
                        
                        // Workout Graph (Data Viz)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                          child: WorkoutGraph(
                            program: provider.program,
                            currentIndex: provider.currentStepIndex,
                            height: 60,
                            onStepTap: (index) {
                                // Confirm Jump
                                HapticFeedback.selectionClick();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF141420),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent)),
                                    title: Text(
                                      'WARP TO INTERVAL ${index + 1}?', 
                                      style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18)
                                    ),
                                    content: Text(
                                      'Jump to Speed ${provider.program[index].speedLabel}?',
                                      style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 16),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('CANCEL', style: GoogleFonts.orbitron(color: Colors.grey)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          HapticFeedback.heavyImpact();
                                          provider.startFromStep(index);
                                        },
                                        child: Text('ENGAGE', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                            },
                          ),
                        ),

                        // Bottom: Next Interval & Controls
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Next Info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NEXT INCOMING',
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  provider.nextStep != null 
                                    ? Text(
                                        'SPD ${provider.nextStep!.speedLabel}',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 24, 
                                          color: Colors.pinkAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : const Text('FINISH LINE', style: TextStyle(color: Colors.greenAccent)),
                                  if (provider.millisecondsRemainingInStep < 30000)
                                    Text(
                                      'T-MINUS ${(provider.millisecondsRemainingInStep/1000).ceil()}s',
                                      style: TextStyle(
                                        color: shouldBlink ? const Color(0xFFFFEA00) : Colors.white70,
                                        fontFamily: 'Courier', 
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                ],
                              ),
                              
                              // Controls
                              Row(
                                children: [
                                  _buildControlButton(
                                    icon: provider.isRunning ? Icons.pause : Icons.play_arrow,
                                    color: provider.isRunning ? const Color(0xFFFFEA00) : const Color(0xFF00E5FF),
                                    onTap: () {
                                       HapticFeedback.mediumImpact();
                                       provider.toggleTimer();
                                    },
                                  ),
                                  const SizedBox(width: 15),
                                  _buildControlButton(
                                    icon: Icons.stop,
                                    color: Colors.pinkAccent,
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      provider.reset();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCountdownScreen(TimerProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'INITIATING',
            style: GoogleFonts.rajdhani(
              fontSize: 24,
              color: Colors.cyanAccent,
              letterSpacing: 10,
            ),
          ),
          const SizedBox(height: 40),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Text(
              '${provider.countdownValue}',
              key: ValueKey(provider.countdownValue),
              style: GoogleFonts.orbitron(
                fontSize: 150,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                   const Shadow(color: Colors.cyanAccent, blurRadius: 50),
                   const Shadow(color: Colors.blueAccent, blurRadius: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: Colors.greenAccent),
          const SizedBox(height: 20),
          Text(
            'MISSION\nCOMPLETE',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.cyanAccent),
        ],
      ),
    );
  }

  Widget _buildHudLabel(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: Colors.cyanAccent,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }

  Widget _buildTotalTimeDisplay(int totalMs) {
    int hundreds = (totalMs ~/ 10) % 100; 
    int seconds = (totalMs ~/ 1000) % 60;
    int minutes = (totalMs ~/ (1000 * 60)) % 60;
    
    // Tabular figures ensure all numbers have same width
    // preventing jitter.
    TextStyle timeStyle = GoogleFonts.orbitron(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: 4,
      fontFeatures: [const FontFeature.tabularFigures()],
    );
    
    TextStyle msStyle = GoogleFonts.orbitron(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: Colors.cyanAccent.withOpacity(0.8),
      letterSpacing: 2,
      fontFeatures: [const FontFeature.tabularFigures()],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // HH:MM:SS
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: timeStyle,
        ),
        const SizedBox(width: 8),
        // Small MS
        Text(hundreds.toString().padLeft(2, '0'), style: msStyle),
      ],
    );
  }
}
