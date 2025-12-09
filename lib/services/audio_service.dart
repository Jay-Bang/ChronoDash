import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  late FlutterTts _flutterTts;

  AudioService() {
    _flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // Slower, more robotic
    await _flutterTts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> playCountdown(int number) async {
    // Pitch up for countdown?
    await _flutterTts.setPitch(1.2);
    await _flutterTts.speak(number.toString());
    await _flutterTts.setPitch(1.0); // Reset
  }
}
