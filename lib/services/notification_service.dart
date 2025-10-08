import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:yks_mentor/providers/timer_provider.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _timerChannelId = 'timer_channel';
  static const String _timerChannelName = 'Zamanlayıcı';
  static const String _timerChannelDesc = 'Çalışma zamanlayıcısı bildirimleri';
  static const int _timerNotificationId = 1;
  static const int TIMER_NOTIFICATION_ID = 1001;
  bool _isServiceRunning = false;
  bool _isTimerPaused = false;

  Function? onPauseTimer;
  Function? onResumeTimer;

  String? _currentSubject;
  String? _currentTopic;
  Duration? _currentElapsed;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    final androidChannel = AndroidNotificationChannel(
      _timerChannelId,
      _timerChannelName,
      description: _timerChannelDesc,
      importance: Importance.max,
      playSound: false,
      enableVibration: false,
      showBadge: false,
      enableLights: false,
    );

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
      await androidPlugin.requestNotificationsPermission();
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) async {
        print('Bildirim aksiyonu: ${details.actionId}');
        if (details.actionId == 'stop_timer') {
          print('Durdur butonuna tıklandı');
          _isTimerPaused = true;
          await onPauseTimer?.call();
          await showTimerNotification(
            subject: _currentSubject ?? '',
            topic: _currentTopic ?? '',
            elapsed: _currentElapsed ?? Duration.zero,
          );
        } else if (details.actionId == 'resume_timer') {
          print('Devam Et butonuna tıklandı');
          _isTimerPaused = false;
          await onResumeTimer?.call();
          await showTimerNotification(
            subject: _currentSubject ?? '',
            topic: _currentTopic ?? '',
            elapsed: _currentElapsed ?? Duration.zero,
          );
        }
      },
    );
  }

  Future<void> showTimerNotification({
    required String subject,
    required String topic,
    required Duration elapsed,
  }) async {
    try {
      print('showTimerNotification çağrıldı');
      print('Durum: ${_isTimerPaused ? "Duraklatıldı" : "Çalışıyor"}');

      _currentSubject = subject;
      _currentTopic = topic;
      _currentElapsed = elapsed;

      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final hours = elapsed.inHours;
        final minutes = (elapsed.inMinutes % 60);
        final seconds = (elapsed.inSeconds % 60);
        final timeText = hours > 0
            ? '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
            : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        final androidDetails = AndroidNotificationDetails(
          _timerChannelId,
          _timerChannelName,
          channelDescription: _timerChannelDesc,
          importance: Importance.max,
          priority: Priority.max,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          enableVibration: false,
          playSound: false,
          channelShowBadge: false,
          onlyAlertOnce: true,
          fullScreenIntent: false,
          visibility: NotificationVisibility.public,
        );

        final title = '$subject - $topic';
        final body =
            'Çalışma Süresi: $timeText ${_isTimerPaused ? "(Duraklatıldı)" : ""}';
        final notificationDetails =
            NotificationDetails(android: androidDetails);

        if (!_isServiceRunning) {
          await _notificationsPlugin.show(
            _timerNotificationId,
            title,
            body,
            notificationDetails,
          );
          _isServiceRunning = true;
        } else {
          await _notificationsPlugin.show(
            _timerNotificationId,
            title,
            body,
            notificationDetails,
          );
        }
      }
    } catch (e) {
      print('Bildirim gösterme hatası: $e');
      _isServiceRunning = false;
    }
  }

  Future<void> showTimerRunningNotification() async {
    await _showNotification(
      id: TIMER_NOTIFICATION_ID,
      title: 'Zamanlayıcı Çalışıyor',
      body: 'Çalışmanız devam ediyor',
      ongoing: true,
      importance: Importance.low,
      priority: Priority.low,
    );
  }

  Future<void> cancelTimerNotification() async {
    await _notificationsPlugin.cancel(TIMER_NOTIFICATION_ID);
  }

  Future<void> requestPermissions() async {
    try {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      final iosPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      print('İzin isteme hatası: $e');
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required bool ongoing,
    required Importance importance,
    required Priority priority,
  }) async {
    try {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final androidDetails = AndroidNotificationDetails(
          _timerChannelId,
          _timerChannelName,
          channelDescription: _timerChannelDesc,
          importance: importance,
          priority: priority,
          ongoing: ongoing,
          autoCancel: false,
          showWhen: false,
          enableVibration: false,
          playSound: false,
          channelShowBadge: false,
          onlyAlertOnce: true,
          fullScreenIntent: false,
          visibility: NotificationVisibility.public,
        );

        final notificationDetails =
            NotificationDetails(android: androidDetails);

        if (!_isServiceRunning) {
          await _notificationsPlugin.show(
            id,
            title,
            body,
            notificationDetails,
          );
          _isServiceRunning = true;
        } else {
          await _notificationsPlugin.show(
            id,
            title,
            body,
            notificationDetails,
          );
        }
      }
    } catch (e) {
      print('Bildirim gösterme hatası: $e');
      _isServiceRunning = false;
    }
  }

  Future<void> showMockExamNotification(
      String subject, String publisher) async {
    await _showNotification(
      id: TIMER_NOTIFICATION_ID,
      title: '$subject Denemesi',
      body: '$publisher denemesi devam ediyor',
      ongoing: true,
      importance: Importance.high,
      priority: Priority.high,
    );
  }
}
