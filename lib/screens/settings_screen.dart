import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Haptics
import '../providers/timer_provider.dart';
import '../models/interval_step.dart';
import '../widgets/warp_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final program = timerProvider.program;

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: Stack(
        children: [
           // Background: Subtle Warp Effect (Slow)
           const Positioned.fill(
             child: Opacity(
               opacity: 0.3, 
               child: WarpBackground(speedLabel: "2") // Slow drift
             ) 
           ),
           
           SafeArea(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 Padding(
                   padding: const EdgeInsets.all(24.0),
                   child: Column(
                     children: [
                       Text(
                         'FLIGHT PLAN',
                         style: GoogleFonts.rajdhani(
                           fontSize: 16,
                           letterSpacing: 4,
                           color: Colors.cyanAccent,
                         ),
                       ),
                       Text(
                         'SELECT ENTRY POINT',
                         style: GoogleFonts.orbitron(
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                           color: Colors.white,
                         ),
                       ),
                     ],
                   ),
                 ),
                 
                 Expanded(
                   child: ListView.separated(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                     itemCount: program.length,
                     separatorBuilder: (context, index) => const SizedBox(height: 12),
                     itemBuilder: (context, index) {
                       final step = program[index];
                       
                       // Cyberpunk List Card
                       return InkWell(
                         onTap: () => _confirmStart(context, index, step),
                         borderRadius: BorderRadius.circular(12),
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                           decoration: BoxDecoration(
                             color: const Color(0xFF141420),
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(
                               color: Colors.white.withOpacity(0.05),
                             ),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.5),
                                 blurRadius: 10,
                                 offset: const Offset(0, 4),
                               )
                             ]
                           ),
                           child: Row(
                             children: [
                               // Index Badge
                               Container(
                                 width: 40,
                                 height: 40,
                                 alignment: Alignment.center,
                                 decoration: BoxDecoration(
                                   color: Colors.cyanAccent.withOpacity(0.1),
                                   shape: BoxShape.circle,
                                   border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                                 ),
                                 child: Text(
                                   '${index + 1}',
                                   style: GoogleFonts.orbitron(
                                     color: Colors.cyanAccent,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ),
                               const SizedBox(width: 20),
                               
                               // Speed Info
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     'SPEED ${step.speedLabel}',
                                     style: GoogleFonts.orbitron(
                                       fontSize: 18,
                                       fontWeight: FontWeight.bold,
                                       color: Colors.white,
                                     ),
                                   ),
                                   Text(
                                     'DURATION: ${_formatDuration(step.durationSeconds)}',
                                     style: GoogleFonts.rajdhani(
                                       color: Colors.grey,
                                       fontWeight: FontWeight.bold,
                                     ),
                                   ),
                                 ],
                               ),
                               const Spacer(),
                               Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.1)),
                             ],
                           ),
                         ),
                       );
                     },
                   ),
                 ),
                 
                 Padding(
                   padding: const EdgeInsets.all(24.0),
                   child: SizedBox(
                     height: 60,
                     child: ElevatedButton(
                       onPressed: () {
                         HapticFeedback.heavyImpact();
                         timerProvider.reset(); // Start from 0
                         Navigator.pushNamed(context, '/running');
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF00E5FF),
                         foregroundColor: Colors.black,
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(30),
                         ),
                         elevation: 10,
                         shadowColor: Colors.cyanAccent.withOpacity(0.5),
                       ),
                       child: Text(
                         'INITIATE SEQUENCE (0:00)',
                         style: GoogleFonts.orbitron(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                           letterSpacing: 1,
                         ),
                       ),
                     ),
                   ),
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }

  void _confirmStart(BuildContext context, int index, IntervalStep step) {
    HapticFeedback.mediumImpact();
    // Use standard flutter dialog but styled
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141420),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent)),
        title: Text('WARP TO INTERVAL ${index+1}?', style: GoogleFonts.orbitron(color: Colors.white)),
        content: Text(
          'Starting at Speed ${step.speedLabel}',
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
              // Perform Jump
              Provider.of<TimerProvider>(context, listen: false).startFromStep(index);
              Navigator.pushNamed(context, '/running');
            },
            child: Text('ENGAGE', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    if (m > 0 && s == 0) return '$m MIN';
    if (m > 0) return '$m MIN $s SEC';
    return '$s SEC';
  }
}
