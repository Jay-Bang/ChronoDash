import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/rendering.dart';
import '../services/storage_service.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final StorageService _storage = StorageService();
  final GlobalKey _globalKey = GlobalKey(); // For RepaintBoundary

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final data = await _storage.getHistory();
    setState(() {
      _history = data;
      _isLoading = false;
    });
  }
  
  Future<void> _shareStats() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/chronodash_stats.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'My ChronoDash Mission Log 🚀');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share failed: $e')));
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    int count = _history.where((d) => 
      d.year == day.year && 
      d.month == day.month && 
      d.day == day.day
    ).length;
    if (count > 0) return List.filled(count, 'Run');
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
      : RepaintBoundary( // Wrap content to capture
          key: _globalKey,
          child: Container(
             color: const Color(0xFF050510), // Ensure background is captured
             child: Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141420),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(l10n.totalMissions, '${_history.length}'),
                      _buildStat(l10n.streak, 'ACTIVE'),
                    ],
                  ),
                ),
                
                // Calendar
                TableCalendar(
                  firstDay: DateTime.utc(2020, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  theme: CalendarThemeData(
                    selectedDecoration: const BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFF00E5FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: GoogleFonts.rajdhani(color: Colors.white),
                    weekendTextStyle: GoogleFonts.rajdhani(color: Colors.white70),
                    outsideTextStyle: GoogleFonts.rajdhani(color: Colors.grey),
                    todayTextStyle: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
                    leftChevronIcon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
                    rightChevronIcon: const Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent),
                  ),
                  eventLoader: _getEventsForDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                
                const Spacer(),
                
                // Share Button (Only visible on screen, might want to exclude from capture if desired, but included here for context)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton.icon(
                    onPressed: _shareStats,
                    icon: const Icon(Icons.share, color: Colors.black),
                    label: Text(l10n.share, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.orbitron(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.grey, letterSpacing: 1.5)),
      ],
    );
  }
}