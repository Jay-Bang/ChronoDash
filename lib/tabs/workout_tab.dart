import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/timer_provider.dart';
import '../models/interval_step.dart';
import '../widgets/warp_background.dart';

class WorkoutTab extends StatelessWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: true);
    final program = timerProvider.program;
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
         // Background: Subtle Warp Effect (Slow)
         const Positioned.fill(
           child: Opacity(
             opacity: 0.3, 
             child: WarpBackground(speedLabel: "2") // Slow drift
           ) 
         ),
         
         Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(
                         l10n.flightPlan,
                         style: GoogleFonts.rajdhani(
                           fontSize: 16,
                           letterSpacing: 4,
                           color: Colors.cyanAccent,
                         ),
                   ),
                   IconButton(
                     icon: const Icon(Icons.edit, color: Colors.white70),
                     onPressed: () {
                        Navigator.pushNamed(context, '/editor');
                     },
                   )
                 ],
               ),
             ),
             Expanded(
               child: ListView.separated(
                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                 itemCount: program.length,
                 separatorBuilder: (context, index) => const SizedBox(height: 12),
                 itemBuilder: (context, index) {
                   final step = program[index];
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
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 '${l10n.speed} ${step.speedLabel}',
                                 style: GoogleFonts.orbitron(
                                   fontSize: 18,
                                   fontWeight: FontWeight.bold,
                                   color: Colors.white,
                                 ),
                               ),
                               Text(
                                 '${l10n.duration}: ${_formatDuration(step.durationSeconds)}',
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
                     '${l10n.initiateSequence} (0:00)',
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
      ],
    );
  }

  void _confirmStart(BuildContext context, int index, IntervalStep step) {
    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141420),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent)),
        title: Text('${l10n.warpToInterval} ${index+1}?', style: GoogleFonts.orbitron(color: Colors.white)),
        content: Text(
          '${l10n.startingAtSpeed} ${step.speedLabel}',
          style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: GoogleFonts.orbitron(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform Jump
              Provider.of<TimerProvider>(context, listen: false).startFromStep(index);
              Navigator.pushNamed(context, '/running');
            },
            child: Text(l10n.engage, style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
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
