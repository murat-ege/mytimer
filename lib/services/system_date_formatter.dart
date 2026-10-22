import 'dart:io';
import 'package:intl/intl.dart';

class SystemDateFormatter {
  /// Global preference for 24-hour vs 12-hour (AM/PM) format.
  /// Defaults to true (24h) as requested.
  static bool use24HourFormat = true;

  static String get _osLocale {
    try {
      final name = Platform.localeName;
      return name.replaceAll('-', '_');
    } catch (_) {
      return 'en_US';
    }
  }

  /// Formats date and time according to 24h or 12h AM/PM preference and locale
  static String formatDateTime(DateTime dt, {bool? use24Hour}) {
    final is24 = use24Hour ?? use24HourFormat;
    try {
      final base = DateFormat.yMMMd(_osLocale);
      return is24
          ? base.add_Hm().format(dt.toLocal())
          : base.add_jm().format(dt.toLocal());
    } catch (_) {
      final base = DateFormat.yMMMd();
      return is24
          ? base.add_Hm().format(dt.toLocal())
          : base.add_jm().format(dt.toLocal());
    }
  }

  /// Formats date only according to OS locale
  static String formatDate(DateTime dt) {
    try {
      return DateFormat.yMMMd(_osLocale).format(dt.toLocal());
    } catch (_) {
      return DateFormat.yMMMd().format(dt.toLocal());
    }
  }

  /// Formats time only according to 24h or 12h AM/PM preference and locale
  static String formatTime(DateTime dt, {bool? use24Hour}) {
    final is24 = use24Hour ?? use24HourFormat;
    try {
      return is24
          ? DateFormat.Hm(_osLocale).format(dt.toLocal())
          : DateFormat.jm(_osLocale).format(dt.toLocal());
    } catch (_) {
      return is24
          ? DateFormat.Hm().format(dt.toLocal())
          : DateFormat.jm().format(dt.toLocal());
    }
  }
}
