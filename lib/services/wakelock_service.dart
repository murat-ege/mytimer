import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockService {
  static final WakelockService _instance = WakelockService._internal();
  factory WakelockService() => _instance;
  WakelockService._internal();

  bool wakelockEnabled = true;

  Future<void> enable() async {
    if (!wakelockEnabled) return;
    try {
      await WakelockPlus.enable();
    } catch (_) {}
  }

  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }
}
