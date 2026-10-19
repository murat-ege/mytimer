import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

Uint8List createWav({
  required List<ToneSegment> segments,
  int sampleRate = 44100,
}) {
  final List<int> samples = [];

  for (final seg in segments) {
    final totalSamples = (seg.durationMs * sampleRate / 1000).round();
    final attackSamples = (sampleRate * 0.005).round(); // 5ms attack
    final decaySamples = (sampleRate * 0.015).round(); // 15ms release

    for (int i = 0; i < totalSamples; i++) {
      if (seg.frequency <= 0) {
        samples.add(0);
        continue;
      }
      final t = i / sampleRate;
      final wave = sin(2 * pi * seg.frequency * t);

      // Envelope to avoid clicks
      double envelope = 1.0;
      if (i < attackSamples) {
        envelope = i / attackSamples;
      } else if (i > totalSamples - decaySamples) {
        envelope = (totalSamples - i) / decaySamples;
      }

      final sample = (wave * envelope * 0.9 * 32767).clamp(-32767, 32767).toInt();
      samples.add(sample);
    }
  }

  final dataSize = samples.length * 2;
  final buffer = ByteData(44 + dataSize);

  // RIFF header
  buffer.setUint8(0, 0x52); // 'R'
  buffer.setUint8(1, 0x49); // 'I'
  buffer.setUint8(2, 0x46); // 'F'
  buffer.setUint8(3, 0x46); // 'F'
  buffer.setUint32(4, 36 + dataSize, Endian.little);
  buffer.setUint8(8, 0x57);  // 'W'
  buffer.setUint8(9, 0x41);  // 'A'
  buffer.setUint8(10, 0x56); // 'V'
  buffer.setUint8(11, 0x45); // 'E'

  // fmt subchunk
  buffer.setUint8(12, 0x66); // 'f'
  buffer.setUint8(13, 0x6D); // 'm'
  buffer.setUint8(14, 0x74); // 't'
  buffer.setUint8(15, 0x20); // ' '
  buffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
  buffer.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
  buffer.setUint16(22, 1, Endian.little);  // NumChannels (1 = Mono)
  buffer.setUint32(24, sampleRate, Endian.little); // SampleRate
  buffer.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
  buffer.setUint16(32, 2, Endian.little);  // BlockAlign
  buffer.setUint16(34, 16, Endian.little); // BitsPerSample

  // data subchunk
  buffer.setUint8(36, 0x64); // 'd'
  buffer.setUint8(37, 0x61); // 'a'
  buffer.setUint8(38, 0x74); // 't'
  buffer.setUint8(39, 0x61); // 'a'
  buffer.setUint32(40, dataSize, Endian.little);

  var offset = 44;
  for (final s in samples) {
    buffer.setInt16(offset, s, Endian.little);
    offset += 2;
  }

  return buffer.buffer.asUint8List();
}

class ToneSegment {
  final double frequency;
  final int durationMs;
  ToneSegment(this.frequency, this.durationMs);
}

void main() {
  final outDir = Directory('assets/sounds');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  // 1. Countdown Beep (Short 880 Hz beep - 120ms)
  final countdownBytes = createWav(segments: [
    ToneSegment(880, 120),
  ]);
  File('assets/sounds/beep_countdown.wav').writeAsBytesSync(countdownBytes);

  // 2. Work / Start Beep (High intense 1760 Hz beep - 500ms)
  final workBytes = createWav(segments: [
    ToneSegment(1760, 500),
  ]);
  File('assets/sounds/beep_work.wav').writeAsBytesSync(workBytes);

  // 3. Rest Beep (Medium 600 Hz beep - 300ms)
  final restBytes = createWav(segments: [
    ToneSegment(600, 350),
  ]);
  File('assets/sounds/beep_rest.wav').writeAsBytesSync(restBytes);

  // 4. Workout Completed Beep (Victory fanfare/chime: 3 quick ascending tones)
  final completeBytes = createWav(segments: [
    ToneSegment(880, 150),
    ToneSegment(0, 50),
    ToneSegment(1174.66, 150), // D6
    ToneSegment(0, 50),
    ToneSegment(1760, 500), // A6 long
  ]);
  File('assets/sounds/beep_complete.wav').writeAsBytesSync(completeBytes);

  print('Sound assets generated successfully in assets/sounds!');
}
