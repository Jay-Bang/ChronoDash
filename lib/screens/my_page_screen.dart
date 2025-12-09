import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final StorageService _storage = StorageService();
  int _countdownSeconds = 3;
  int _totalRuns = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    int cd = await _storage.getCountdownSeconds();
    List<DateTime> history = await _storage.getHistory();
    setState(() {
      _countdownSeconds = cd;
      _totalRuns = history.length;
      _loading = false;
    });
  }

  void _updateCountdown(double value) {
    setState(() {
      _countdownSeconds = value.toInt();
    });
    _storage.setCountdownSeconds(_countdownSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('COMMAND CENTER', style: GoogleFonts.orbitron()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile / Dashboard Card
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF141420), Colors.cyanAccent.withOpacity(0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.cyanAccent,
                        child: Icon(Icons.person, size: 40, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      Text('PILOT DASHBOARD', style: GoogleFonts.rajdhani(color: Colors.grey, letterSpacing: 2)),
                      const SizedBox(height: 10),
                      Text(
                        '$_totalRuns MISSIONS', 
                        style: GoogleFonts.orbitron(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/history');
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: Text('FLIGHT RECORDS', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Text('SYSTEM SETTINGS', style: GoogleFonts.rajdhani(color: Colors.cyanAccent, fontSize: 16, letterSpacing: 2)),
                const SizedBox(height: 20),
                
                // Countdown Settings
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141420),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('LAUNCH COUNTDOWN', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)),
                          Text('${_countdownSeconds}s', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Slider(
                        value: _countdownSeconds.toDouble(),
                        min: 3,
                        max: 10,
                        divisions: 7,
                        activeColor: Colors.cyanAccent,
                        inactiveColor: Colors.grey.withOpacity(0.3),
                        onChanged: _updateCountdown,
                      ),
                      Text(
                        'Delay before sequence initiation.',
                        style: GoogleFonts.rajdhani(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
