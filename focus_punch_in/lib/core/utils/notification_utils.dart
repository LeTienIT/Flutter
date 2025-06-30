import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:focus_punch_in/services/SharedPrefService.dart';
import 'dart:io';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class NotificationUtil {
  static final FlutterLocalNotificationsPlugin _notifiPlugin =
  FlutterLocalNotificationsPlugin();
  bool _isInit = false;
  bool _isChannelCreated = false;
  Future<void> initNoti() async {
    if (_isInit) return;
    try {
      tz.initializeTimeZones();
      final String currentTime = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTime));

      const initSettingAnd = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettingIos = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initSetting = InitializationSettings(
        android: initSettingAnd,
        iOS: initSettingIos,
      );

      await _notifiPlugin.initialize(
        initSetting,
        onDidReceiveNotificationResponse: (details) {
          // Xử lý khi nhấn vào thông báo
        },
      );
      if (Platform.isAndroid) {
        await requestNotificationPermission();
      }
      _isInit = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) {
        debugPrint('Người dùng không cấp quyền thông báo');
        return false;
      }
      return true;
    }
    return true;
  }

  Future<void> openExactAlarmPermissionSettings() async {
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }
  Future<void> _createNotificationChannel() async {
    if (_isChannelCreated) return;
    try {
      const androidChannel = AndroidNotificationChannel(
        'daily', 'Daily notification',
        description: 'Check',
        importance: Importance.max,
        playSound: true,
      );
      await _notifiPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
      _isChannelCreated = true;
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }

  NotificationDetails notifiDetail() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily', 'Daily notification',
        channelDescription: 'Check',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({int id = 0, String? title, String? body}) async {
    try {
      if (!_isInit) {
        await initNoti();
      }
      await _createNotificationChannel();
      await _notifiPlugin.show(
        id,
        title ?? 'No Title',
        body ?? 'No Body',
        notifiDetail(),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
      rethrow;
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> showNotificationDaily(int id, String title, String body, int hour, int minute) async {
    try {
      if (!_isInit) {
        await initNoti();
      }
      await _createNotificationChannel();
      final nextScheduledTime = _nextInstanceOfTime(hour, minute);
      await _notifiPlugin.zonedSchedule(
        id, title, body,
        nextScheduledTime,
        notifiDetail(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> registerNotificationDefault() async {
    try {
      final isRegister = SharedPrefService.instance.getValue<bool>('isRegister_notification') ?? false;

      if (!isRegister) {
        await showNotificationDaily(111, "Check in", "Bạn đã chấm công sáng chưa?", 08, 25);
        await showNotificationDaily(222, "Check out", "Bạn đã chấm công về chưa?", 17, 35);
        SharedPrefService.instance.setValue<bool>('isRegister_notification', true);
        SharedPrefService.instance.setValue<int>('h_in', 08);
        SharedPrefService.instance.setValue<int>('m_i', 25);
        SharedPrefService.instance.setValue<int>('h_o', 17);
        SharedPrefService.instance.setValue<int>('m_o', 35);
      }
    } catch (e) {
      print('Error registering notifications: $e');
    }
  }

  Future<void> registerNotificationCustomize({required int h_in, required int m_in, required int h_o, required int m_o}) async {
    try {
      await showNotificationDaily(111, "Check in", "Hôm nay bạn đã chấm công chưa? Đừng quên nhé!", h_in, m_in);
      await showNotificationDaily(222, "Check out", "Đừng quên chấm công khi ra về. Cho tôi biết bạn đã chấm chưa?", h_o, m_o);
      SharedPrefService.instance.setValue<int>('h_in', h_in);
      SharedPrefService.instance.setValue<int>('m_in', m_in);
      SharedPrefService.instance.setValue<int>('h_o', h_o);
      SharedPrefService.instance.setValue<int>('m_o', m_o);
    } catch (e) {
      print('Error registering notifications: $e');
    }
  }

  Future<void> testScheduleNotificationSoon() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(Duration(seconds: 30));
    debugPrint('Scheduling test notification at $scheduled');

    await _notifiPlugin.zonedSchedule(
      999, // ID test
      '🔔 Test Gấp',
      'Thông báo test sau 30 giây',
      scheduled,
      notifiDetail(),

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    debugPrintPendingNotifications('test 30s');
  }

  Future<void> debugPrintPendingNotifications(String title) async {
    final pending = await _notifiPlugin.pendingNotificationRequests();
    if (pending.isEmpty) {
      debugPrint('No scheduled notifications.');
    } else {
      debugPrint(title);
      for (final p in pending) {
        debugPrint('🔔 ID: ${p.id}, Title: ${p.title}, Body: ${p.body}');
      }
    }
  }


}