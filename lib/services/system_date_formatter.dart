import 'dart:io';
import 'package:intl/intl.dart';

class SystemDateFormatter {
  static String get _osLocale {
    try {
      final name = Platform.localeName;
      return name.replaceAll('-', '_');
    } catch (_) {
      return 'en_US';
    }
  }

  /// Formats date and time according to the operating system's locale and preferences
  static String formatDateTime(DateTime dt) {
    try {
      return DateFormat.yMMMd(_osLocale).add_jm().format(dt.toLocal());
    } catch (_) {
      return DateFormat.yMMMd().add_jm().format(dt.toLocal());
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

  /// Formats time only according to OS locale
  static String formatTime(DateTime dt) {
    try {
      return DateFormat.jm(_osLocale).format(dt.toLocal());
    } catch (_) {
      return DateFormat.jm().format(dt.toLocal());
    }
  }
}
