import 'package:flutter_test/flutter_test.dart';
import 'package:mytimer/data/hyrox_data.dart';

void main() {
  group('HYROX Data & Standards Tests', () {
    test('Official 8 HYROX stations are defined in correct order', () {
      expect(HyroxData.stations.length, equals(8));
      expect(HyroxData.stations[0].name, equals('SkiErg'));
      expect(HyroxData.stations[1].name, equals('Sled Push'));
      expect(HyroxData.stations[2].name, equals('Sled Pull'));
      expect(HyroxData.stations[3].name, equals('Burpee Broad Jumps'));
      expect(HyroxData.stations[4].name, equals('Rowing'));
      expect(HyroxData.stations[5].name, equals('Farmers Carry'));
      expect(HyroxData.stations[6].name, equals('Sandbag Lunges'));
      expect(HyroxData.stations[7].name, equals('Wall Balls'));
    });

    test('All divisions have valid weights for stations', () {
      for (final station in HyroxData.stations) {
        expect(station.getWeightFor(HyroxDivision.menOpen), isNotEmpty);
        expect(station.getWeightFor(HyroxDivision.womenOpen), isNotEmpty);
        expect(station.getWeightFor(HyroxDivision.menPro), isNotEmpty);
        expect(station.getWeightFor(HyroxDivision.womenPro), isNotEmpty);
      }
    });

    test('HYROX Presets are configured properly', () {
      final presets = HyroxData.getHyroxPresets();
      expect(presets.length, greaterThanOrEqualTo(4));
      for (final p in presets) {
        expect(p.category, equals('HYROX'));
        expect(p.intervals, isNotEmpty);
        expect(p.totalDurationSeconds, greaterThan(0));
      }
    });
  });
}
