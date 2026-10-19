import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(settings: initSettings);
      _isInitialized = true;
    } catch (_) {}
  }

  Future<void> showWorkoutProgress({
    required String phaseTitle,
    required String timeRemainingText,
    required String roundInfo,
  }) async {
    if (!_isInitialized) return;

    final androidDetails = AndroidNotificationDetails(
      'mytimer_channel',
      'MyTimer Workout Active',
      channelDescription: 'Active workout timer progress',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      showWhen: false,
      visibility: NotificationVisibility.public, // Visible on Lock Screen
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        id: 1001,
        title: '$phaseTitle • $timeRemainingText',
        body: roundInfo,
        notificationDetails: details,
      );
    } catch (_) {}
  }

  Future<void> cancelWorkoutNotification() async {
    if (!_isInitialized) return;
    try {
      await _notificationsPlugin.cancel(id: 1001);
    } catch (_) {}
  }
}
