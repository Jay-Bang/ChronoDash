import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/timer_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/running_screen.dart';
import 'screens/home_screen.dart';
import 'screens/program_editor_screen.dart';

void main() {
  runApp(const IntervalWatchApp());
}

class IntervalWatchApp extends StatelessWidget {
  const IntervalWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: MaterialApp(
        title: 'Interval Watch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF050510), // Deep Indigo/Black
          primaryColor: const Color(0xFF00E5FF), // Neon Cyan
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            secondary: Color(0xFFFF4081), // Neon Pink
            surface: Color(0xFF12121A),
            error: Color(0xFFFFEA00), // Bright Yellow
          ),
          textTheme: GoogleFonts.orbitronTextTheme(
            Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/running': (context) => const RunningScreen(),
          '/editor': (context) => const ProgramEditorScreen(),
        },
      ),
    );
  }
}
