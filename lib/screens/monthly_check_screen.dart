import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

class MonthlyCheckScreen extends StatefulWidget {
  const MonthlyCheckScreen({super.key});

  @override
  State<MonthlyCheckScreen> createState() => _MonthlyCheckScreenState();
}

class _MonthlyCheckScreenState extends State<MonthlyCheckScreen> {
  final StorageService _storage = StorageService();
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

  List<String> _getEventsForDay(DateTime day) {
    // Check if any history date matches this day
    // Simple check: same year, month, day
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
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        title: Text('MISSION LOG', style: GoogleFonts.orbitron(letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
        : Column(
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
                    _buildStat('TOTAL MISSIONS', '${_history.length}'),
                    _buildStat('STREAK', 'ACTIVE'), // Mock logic for now
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
              
              // Back Button
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () {
                       Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.cyanAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'RETURN TO BASE',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
