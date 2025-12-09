import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String KEY_HISTORY = 'workout_history';
  static const String KEY_COUNTDOWN = 'countdown_seconds';

  // Save a new workout completion timestamp
  Future<void> saveWorkout(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(KEY_HISTORY) ?? [];
    history.add(date.toIso8601String());
    await prefs.setStringList(KEY_HISTORY, history);
  }

  // Get all workout dates
  Future<List<DateTime>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(KEY_HISTORY) ?? [];
    return history.map((e) => DateTime.parse(e)).toList();
  }

  // Save Countdown Preference
  Future<void> setCountdownSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_COUNTDOWN, seconds);
  }

  // Get Countdown Preference (default 3)
  Future<int> getCountdownSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(KEY_COUNTDOWN) ?? 3;
  }
  
  static const String KEY_PROGRAM = 'custom_program';

  // Save Program
  Future<void> saveProgram(List<dynamic> programJson) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(programJson);
    await prefs.setString(KEY_PROGRAM, jsonString);
  }

  // Get Program (returns List of Maps)
  Future<List<dynamic>?> getProgram() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(KEY_PROGRAM);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }
  
  // Clear all data (Debug)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
