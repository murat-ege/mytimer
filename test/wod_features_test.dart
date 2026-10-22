import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mytimer/models/timer_settings.dart';
import 'package:mytimer/models/workout_log.dart';
import 'package:mytimer/services/audio_theme_generator.dart';
import 'package:mytimer/services/system_date_formatter.dart';
import 'package:mytimer/services/workout_log_exporter.dart';

void main() {
  group('WorkoutLog Model Tests', () {
    test('Creates and serializes WorkoutLog with notes and photo', () {
      final now = DateTime(2026, 10, 21, 14, 30);
      final log = WorkoutLog(
        id: 'test-123',
        title: 'Fran',
        timerType: 'for_time',
        completedAt: now,
        totalDurationSeconds: 195,
        defaultDefinition: '21-15-9 Thrusters (95/65 lb) & Pull-ups',
        userNote: 'Scaled to 75lb. Felt good.',
        imagePath: '/tmp/whiteboard.jpg',
        completedRounds: 3,
        totalRounds: 3,
      );

      expect(log.formattedDuration, '03:15');
      expect(log.imagePath, '/tmp/whiteboard.jpg');
      expect(log.userNote, 'Scaled to 75lb. Felt good.');

      final copied = log.copyWith(userNote: 'Updated note');
      expect(copied.userNote, 'Updated note');
      expect(copied.id, 'test-123');
      expect(copied.formattedDuration, '03:15');

      final json = log.toJson();
      final fromJson = WorkoutLog.fromJson(json);
      expect(fromJson.id, log.id);
      expect(fromJson.title, log.title);
      expect(fromJson.userNote, log.userNote);
    });

    test('Formatted duration handles hours correctly', () {
      final log = WorkoutLog(
        id: 'murph-1',
        title: 'Murph',
        timerType: 'for_time',
        completedAt: DateTime.now(),
        totalDurationSeconds: 3725, // 1h 2m 5s
        defaultDefinition: '1 Mile Run, 100 Pull-ups, 200 Push-ups, 300 Squats, 1 Mile Run',
      );

      expect(log.formattedDuration, '01:02:05');
    });
  });

  group('WorkoutLogExporter Tests', () {
    test('Builds valid RFC 4180 CSV with escaped commas and quotes', () {
      final logs = [
        WorkoutLog(
          id: 'log-1',
          title: 'Tabata "Hell"',
          timerType: 'tabata',
          completedAt: DateTime(2026, 10, 21, 8, 30),
          totalDurationSeconds: 240,
          defaultDefinition: '20s WORK, 10s REST, 8 ROUNDS',
          userNote: 'Burpees & "KB" Swings, heavy breathing',
          imagePath: '/images/score.jpg',
          completedRounds: 8,
          totalRounds: 8,
        ),
      ];

      final csv = WorkoutLogExporter.generateCsv(logs);
      expect(csv.startsWith('ID,Date & Time,Timer Mode,Workout Title'), true);
      // Double quotes should be escaped
      expect(csv.contains('Tabata ""Hell""'), true);
      expect(csv.contains('YES'), true);
    });
  });

  group('SystemDateFormatter Tests', () {
    test('Formats date and time strings consistently in 24h and 12h formats', () {
      final dt = DateTime(2026, 10, 21, 14, 5, 9);
      final formatted24 = SystemDateFormatter.formatDateTime(dt, use24Hour: true);
      expect(formatted24.isNotEmpty, true);
      expect(formatted24.contains('14:05'), true);

      final formatted12 = SystemDateFormatter.formatDateTime(dt, use24Hour: false);
      expect(formatted12.isNotEmpty, true);
      expect(formatted12.contains('2:05') || formatted12.contains('PM'), true);

      final time24 = SystemDateFormatter.formatTime(dt, use24Hour: true);
      expect(time24, '14:05');

      final time12 = SystemDateFormatter.formatTime(dt, use24Hour: false);
      expect(time12.contains('2:05') || time12.contains('PM'), true);

      final dateOnly = SystemDateFormatter.formatDate(dt);
      expect(dateOnly.isNotEmpty, true);
    });
  });

  group('AudioThemeGenerator Tests', () {
    test('Generates valid 16-bit PCM RIFF WAV headers and audio buffers for all 11 themes', () {
      expect(AudioThemeGenerator.allThemes.length, 11);

      for (final theme in AudioThemeGenerator.allThemes) {
        for (final cue in [SoundType.countdown, SoundType.work, SoundType.rest, SoundType.complete]) {
          final Uint8List bytes = AudioThemeGenerator.getSoundBytes(theme.id, cue);
          expect(bytes.length > 44, true, reason: 'WAV byte length should exceed 44-byte header for ${theme.id} $cue');

          // Check 'RIFF' header
          expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
          // Check 'WAVE' format
          expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
          // Check 'fmt ' subchunk
          expect(String.fromCharCodes(bytes.sublist(12, 16)), 'fmt ');
        }
      }
    });
  });

  group('TimerSettings Tests', () {
    test('Default setup settings match user configuration', () {
      const settings = TimerSettings();
      expect(settings.soundEnabled, isTrue);
      expect(settings.audioThemeId, equals('beep_and_go'));
      expect(settings.voiceCoachEnabled, isFalse);
      expect(settings.vibrationEnabled, isTrue);
      expect(settings.wakelockEnabled, isTrue);
      expect(settings.confirmTimerExit, isFalse);
      expect(settings.autoStartTimer, isFalse);
      expect(settings.use24HourFormat, isTrue); // default is 24h
      expect(settings.autoSaveWorkoutLog, isTrue); // default is true
      expect(settings.languageCode, equals('en'));
      expect(settings.voiceCoachId, equals('male_1'));
    });

    test('Serialization and deserialization preserves audioThemeId and voiceCoachId', () {
      const original = TimerSettings(
        languageCode: 'tr',
        soundEnabled: true,
        vibrationEnabled: false,
        voiceCoachEnabled: true,
        voiceCoachId: 'female_2',
        audioThemeId: 'arena_horn',
        autoSaveWorkoutLog: false,
      );

      final json = original.toJson();
      final restored = TimerSettings.fromJson(json);

      expect(restored.languageCode, 'tr');
      expect(restored.voiceCoachId, 'female_2');
      expect(restored.audioThemeId, 'arena_horn');
      expect(restored.autoSaveWorkoutLog, isFalse);
    });
  });
}
