import 'package:flutter_test/flutter_test.dart';
import 'package:interval_watch/providers/timer_provider.dart';
import 'package:interval_watch/models/interval_step.dart';
import 'package:interval_watch/services/audio_service.dart';
import 'package:interval_watch/services/storage_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Generate Mocks
// class MockAudioService extends Mock implements AudioService {} // Manual mock easiest for simple methods
// class MockStorageService extends Mock implements StorageService {} 

class MockAudioService extends AudioService {
  @override
  Future<void> speak(String text) async {}
  @override
  Future<void> playCountdown(int number) async {}
}

class MockStorageService extends StorageService {
  @override
  Future<List<dynamic>?> getProgram() async => [];
  @override
  Future<int> getCountdownSeconds() async => 3;
  @override
  Future<void> saveProgram(List<dynamic> programJson) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({}); // Initialize mock prefs

  group('TimerProvider Tests', () {
    late TimerProvider provider;

    setUp(() {
      provider = TimerProvider(
        audioService: MockAudioService(),
        storageService: MockStorageService(),
      );
    });

    test('Initial program should be loaded (default if empty)', () async {
      // Allow async init to complete
      await Future.delayed(const Duration(milliseconds: 100)); 
      expect(provider.program.isNotEmpty, true);
      expect(provider.program.length, 14); // Default length
    });

    test('Add Step increases program length', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      int initialLength = provider.program.length;
      provider.addStep(IntervalStep(durationSeconds: 30, speedLabel: 'Test'));
      expect(provider.program.length, initialLength + 1);
      expect(provider.program.last.speedLabel, 'Test');
    });

    test('Remove Step decreases program length', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      int initialLength = provider.program.length;
      provider.removeStep(0);
      expect(provider.program.length, initialLength - 1);
    });

    test('Current Step Index Calculation', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      // First step is 60s
      // Simulate 30s elapsed
      // Can't easily force _totalElapsedMilliseconds without setter or running timer.
      // But we can use startFromStep to simulate state 
      
      provider.startFromStep(1); // Jump to 2nd step
      // Wait for async countdown start (if any)
      
      // Just verifying startFromStep logic set the time correctly
      // Step 0 is 60s. So startFromStep(1) should set elapsed to 60000ms.
      
      expect(provider.totalElapsedMilliseconds, 60000);
      expect(provider.currentStepIndex, 1);
    });
  });
}
