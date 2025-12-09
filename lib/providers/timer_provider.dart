import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/interval_step.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  int _totalElapsedMilliseconds = 0;
  bool _isRunning = false;
  
  // Audio & Storage
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();
  
  // Countdown State
  bool _isCountdown = false;
  int _countdownValue = 0;
  Timer? _countdownTimer;

  // Warning State
  int _lastStepIndex = -1;
  bool _hasWarned = false;

  // Program Data (Mutable)
  List<IntervalStep> _program = []; // Initialize empty, load in constructor

  TimerProvider() {
    _init();
  }

  void _init() async {
    // Try load saved program
    final savedJson = await _storage.getProgram();
    if (savedJson != null && savedJson.isNotEmpty) {
      _program = savedJson.map((e) => IntervalStep.fromJson(e)).toList();
    } else {
      // Default Program
      _program = [
        IntervalStep(durationSeconds: 60, speedLabel: '4'),        // 0-1
        IntervalStep(durationSeconds: 60, speedLabel: '5'),        // 1-2
        IntervalStep(durationSeconds: 60, speedLabel: '6'),        // 2-3
        IntervalStep(durationSeconds: 120, speedLabel: '8~9'),     // 3-5
        IntervalStep(durationSeconds: 60, speedLabel: '5~6'),      // 5-6
        IntervalStep(durationSeconds: 120, speedLabel: '10~13'),   // 6-8
        IntervalStep(durationSeconds: 60, speedLabel: '4~5'),      // 8-9
        IntervalStep(durationSeconds: 120, speedLabel: '10~13'),   // 9-11
        IntervalStep(durationSeconds: 60, speedLabel: '4~5'),      // 11-12
        IntervalStep(durationSeconds: 180, speedLabel: '8~9'),     // 12-15
        IntervalStep(durationSeconds: 60, speedLabel: '4~5'),      // 15-16
        IntervalStep(durationSeconds: 120, speedLabel: '10~13'),   // 16-18
        IntervalStep(durationSeconds: 60, speedLabel: '5'),        // 18-19
        IntervalStep(durationSeconds: 60, speedLabel: '4'),        // 19-20
      ];
    }
    notifyListeners();
  }

  // --- CRUD Methods ---

  void addStep(IntervalStep step) {
    _program.add(step);
    _save();
    notifyListeners();
  }

  void updateStep(int index, IntervalStep newStep) {
    if (index >= 0 && index < _program.length) {
      _program[index] = newStep;
      _save();
      notifyListeners();
    }
  }

  void removeStep(int index) {
    if (index >= 0 && index < _program.length) {
      _program.removeAt(index);
      _save();
      notifyListeners();
    }
  }

  void reorderSteps(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final IntervalStep item = _program.removeAt(oldIndex);
    _program.insert(newIndex, item);
    _save();
    notifyListeners();
  }

  void resetProgramToDefault() {
    _storage.clearAll(); // Clears everything? No maybe just program key.
    // For now manual default reset
    _program = [
        IntervalStep(durationSeconds: 60, speedLabel: '4'),
        IntervalStep(durationSeconds: 60, speedLabel: '5'),
        IntervalStep(durationSeconds: 60, speedLabel: '6'),
        IntervalStep(durationSeconds: 120, speedLabel: '8~9'),
        IntervalStep(durationSeconds: 60, speedLabel: '5~6'),
        IntervalStep(durationSeconds: 120, speedLabel: '10~13'),
        IntervalStep(durationSeconds: 60, speedLabel: '4~5'),
        IntervalStep(durationSeconds: 120, speedLabel: '10~13'),
        IntervalStep(durationSeconds: 60, speedLabel: '4~5'),
        IntervalStep(durationSeconds: 180, speedLabel: '8~9'),
        IntervalStep(durationSeconds: 60, speedLabel: '4~5'),
        IntervalStep(durationSeconds: 120, speedLabel: '10~13'),
        IntervalStep(durationSeconds: 60, speedLabel: '5'),
        IntervalStep(durationSeconds: 60, speedLabel: '4'),
    ];
    _save();
    notifyListeners();
  }

  void _save() {
    List<Map<String, dynamic>> jsonList = _program.map((e) => e.toJson()).toList();
    _storage.saveProgram(jsonList);
  }

  // --- Getters ---
  bool get isRunning => _isRunning;
  bool get isCountdown => _isCountdown;
  int get countdownValue => _countdownValue;
  int get totalElapsedMilliseconds => _totalElapsedMilliseconds;
  List<IntervalStep> get program => _program;
  bool get isFinished => totalProgress >= 1.0;

  int get currentStepIndex {
    if (_program.isEmpty) return 0;
    int accumulatedSeconds = 0;
    int currentSeconds = (_totalElapsedMilliseconds / 1000).floor();
    
    for (int i = 0; i < _program.length; i++) {
      accumulatedSeconds += _program[i].durationSeconds;
      if (currentSeconds < accumulatedSeconds) {
        return i;
      }
    }
    return _program.length - 1; 
  }

  IntervalStep get currentStep => _program.isNotEmpty ? _program[currentStepIndex] : IntervalStep(durationSeconds: 1, speedLabel: '0');

  IntervalStep? get nextStep {
    int nextIndex = currentStepIndex + 1;
    if (nextIndex < _program.length) {
      return _program[nextIndex];
    }
    return null;
  }

  int get millisecondsInCurrentStep {
    if (_program.isEmpty) return 0;
    int accumulatedSeconds = 0;
    // Calculate accumulated seconds for previous steps
    for (int i = 0; i < currentStepIndex; i++) {
      accumulatedSeconds += _program[i].durationSeconds;
    }
    return _totalElapsedMilliseconds - (accumulatedSeconds * 1000);
  }

  int get millisecondsRemainingInStep {
     if (_program.isEmpty) return 0;
    int stepDurationMs = currentStep.durationSeconds * 1000;
    return stepDurationMs - millisecondsInCurrentStep;
  }
  
  double get totalProgress {
    if (_program.isEmpty) return 0.0;
    int totalProgramSeconds = _program.fold(0, (sum, item) => sum + item.durationSeconds);
    if (totalProgramSeconds == 0) return 0.0;
    double progress = _totalElapsedMilliseconds / (totalProgramSeconds * 1000);
    return progress.clamp(0.0, 1.0);
  }

  // --- Logic ---

  void startFromStep(int stepIndex) {
    if (stepIndex < 0 || stepIndex >= _program.length) return;
    
    // Calculate start time
    int accumulatedSeconds = 0;
    for (int i = 0; i < stepIndex; i++) {
        accumulatedSeconds += _program[i].durationSeconds;
    }
    
    _totalElapsedMilliseconds = accumulatedSeconds * 1000;
    _startCountdown();
  }

  void toggleTimer() {
    if (_program.isEmpty) return; // Guard clause
    if (_isRunning || _isCountdown) {
      _stopAll();
    } else {
      if (isFinished) {
         _totalElapsedMilliseconds = 0;
         _hasWarned = false;
         _lastStepIndex = -1;
      }
      _startCountdown();
    }
  }

  Future<void> _startCountdown() async {
    _stopAll(); // Ensure clean slate
    int count = await _storage.getCountdownSeconds();
    _countdownValue = count;
    _isCountdown = true;
    notifyListeners();

    // Speak initial number
    _audio.playCountdown(_countdownValue);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownValue--;
      if (_countdownValue > 0) {
        _audio.playCountdown(_countdownValue);
        notifyListeners();
      } else {
        // Countdown finished
        _countdownTimer?.cancel();
        _isCountdown = false;
        _audio.speak("Go");
        notifyListeners();
        _startRunning();
      }
    });
  }

  void _startRunning() {
    _isRunning = true;
    WakelockPlus.enable();
    
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) { // 50ms is enough
      _totalElapsedMilliseconds += 50;
      
      _checkAudioTriggers();

      if (isFinished) {
        _finishWorkout();
      }
      notifyListeners();
    });
    
    notifyListeners();
  }

  void _checkAudioTriggers() {
    // 1. Step Change Detection
    int currentIndex = currentStepIndex;
    if (currentIndex != _lastStepIndex) {
      _lastStepIndex = currentIndex;
      _hasWarned = false;
      // Announce new speed? Optional.
    }

    // 2. 10s Warning
    int remaining = millisecondsRemainingInStep;
    if (remaining <= 10000 && remaining > 9000 && !_hasWarned && nextStep != null) {
      // Trigger warning
      _hasWarned = true;
      _audio.speak("10 seconds check"); // Futuristic warning
    }
  }

  void _finishWorkout() {
    _stopAll();
    _audio.speak("Mission Complete");
    _storage.saveWorkout(DateTime.now());
    notifyListeners();
  }

  void _stopAll() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _isRunning = false;
    _isCountdown = false;
    WakelockPlus.disable();
    notifyListeners();
  }

  void reset() {
    _stopAll();
    _totalElapsedMilliseconds = 0;
    _hasWarned = false;
    _lastStepIndex = -1;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _stopAll();
    super.dispose();
  }
}
