import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interval_watch/l10n/app_localizations.dart';
import '../tabs/workout_tab.dart';
import '../tabs/history_tab.dart';
import '../tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _tabs = [
    const WorkoutTab(),
    const HistoryTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> _titles = [
      l10n.flightPlan,
      l10n.missionLog,
      l10n.commandCenter,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: GoogleFonts.orbitron(letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: _currentIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.cyanAccent),
                  tooltip: 'Edit Program',
                  onPressed: () {
                    Navigator.pushNamed(context, '/editor');
                  },
                ),
                const SizedBox(width: 8),
              ]
            : [],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF050510),
          selectedItemColor: const Color(0xFF00E5FF), // Neon Cyan
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.flash_on),
              label: l10n.tabRun,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month),
              label: l10n.tabHistory,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
