import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:interval_watch/l10n/app_localizations.dart';
import '../providers/timer_provider.dart';
import '../models/interval_step.dart';
import '../widgets/cyberpunk_time_picker.dart';

class ProgramEditorScreen extends StatelessWidget {
  const ProgramEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        title: Text(l10n.editFlightPlan,
            style: GoogleFonts.orbitron(letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
              onPressed: () {
                // Reset to default
                Provider.of<TimerProvider>(context, listen: false)
                    .resetProgramToDefault();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${l10n.reset} Completed")));
              },
              child: Text(l10n.reset,
                  style: GoogleFonts.rajdhani(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)))
        ],
      ),
      body: Consumer<TimerProvider>(
        builder: (context, provider, child) {
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: provider.program.length,
            onReorder: (oldIndex, newIndex) {
              provider.reorderSteps(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final step = provider.program[index];
              return Dismissible(
                key: ValueKey(
                    '${step.speedLabel}_${step.durationSeconds}_$index'), // Unique key
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  provider.removeStep(index);
                },
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  key: ValueKey(
                      '${step.speedLabel}_${step.durationSeconds}_$index'),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  tileColor: const Color(0xFF141420),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.cyanAccent.withOpacity(0.5))),
                    child: Text('${index + 1}',
                        style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
                  ),
                  title: Text(
                    '${l10n.speed}: ${step.speedLabel}',
                    style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    '${l10n.duration}: ${step.durationSeconds}s',
                    style: GoogleFonts.rajdhani(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () =>
                            _showEditDialog(context, provider, index, step),
                      ),
                      const Icon(Icons.drag_handle, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00E5FF),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          _showAddDialog(context);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, TimerProvider provider, int index,
      IntervalStep step) {
    final speedController = TextEditingController(text: step.speedLabel);
    int currentDuration = step.durationSeconds;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.cyanAccent)),
        title: Text(l10n.editSegment,
            style: GoogleFonts.orbitron(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: speedController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n.speed,
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.duration,
                style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            CyberpunkTimePicker(
              initialDurationSeconds: step.durationSeconds,
              onDurationChanged: (val) {
                currentDuration = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final newSpeed = speedController.text;
              if (currentDuration == 0) currentDuration = 60; // Validation
              provider.updateStep(
                  index,
                  IntervalStep(
                      durationSeconds: currentDuration, speedLabel: newSpeed));
              Navigator.pop(context);
            },
            child: Text(l10n.save,
                style: const TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final speedController = TextEditingController(text: '6.0');
    int currentDuration = 60;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.cyanAccent)),
        title: Text(l10n.newSegment,
            style: GoogleFonts.orbitron(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: speedController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n.speed,
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.duration,
                style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            CyberpunkTimePicker(
              initialDurationSeconds: 60,
              onDurationChanged: (val) {
                currentDuration = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final provider =
                  Provider.of<TimerProvider>(context, listen: false);
              final newSpeed = speedController.text;
              if (currentDuration == 0) currentDuration = 60; // Validation
              provider.addStep(IntervalStep(
                  durationSeconds: currentDuration, speedLabel: newSpeed));
              Navigator.pop(context);
            },
            child: Text(l10n.add,
                style: const TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }
}
