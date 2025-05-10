import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:focus_punch_in/services/SharedPrefService.dart';
import 'dart:io';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationUtil {
  static final FlutterLocalNotificationsPlugin _notifiPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInit = false;
  bool _isChannelCreated = false;

  Future<void> initNoti() async {
    if (_isInit) return;

    try {
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

      // Xin quyền trên Android 13+
      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      }

      _isInit = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _requestAndroidPermissions() async {
    try {
      final androidPlugin = _notifiPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    if (_isChannelCreated) return;

    try {
      const androidChannel = AndroidNotificationChannel(
        'daily',
        'Daily notification',
        description: 'Check',
        importance: Importance.max,
        playSound: true,
      );

      await _notifiPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      _isChannelCreated = true;
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }

  NotificationDetails notifiDetail() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily',
        'Daily notification',
        channelDescription: 'Check',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        // sound: RawResourceAndroidNotificationSound('notification'),
      ),
      iOS: DarwinNotificationDetails(
        // sound: 'default',
      ),
    );
  }

  Future<void> showNotification({int id = 0, String? title, String? body}) async {
    try {
      if (!_isInit) {
        await initNoti();
      }

      await _createNotificationChannel(); // Đảm bảo channel đã được tạo

      await _notifiPlugin.show(
        id,
        title ?? 'No Title',
        body ?? 'No Body',
        notifiDetail(), // Sử dụng notifiDetail() thay vì const NotificationDetails()
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
      debugPrint('Scheduling notification at: $nextScheduledTime');

      await _notifiPlugin.zonedSchedule(
        id,
        title,
        body,
        nextScheduledTime,
        notifiDetail(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> registerNotificationDefault() async {
    try {
      // final prefs = SharedPrefService.instance;
      final isRegister = SharedPrefService.instance.getValue<bool>('isRegister_notification') ?? false;

      if (!isRegister) {
        await showNotificationDaily(111, "Check in", "Bạn đã chấm công sáng chưa?", 08, 25);
        await showNotificationDaily(222, "Check out", "Bạn đã chấm công về chưa?", 17, 35);
        SharedPrefService.instance.setValue<bool>('isRegister_notification', true);
        // print("Đã đăng ký thông báo hàng ngày");
      }
    } catch (e) {
      print('Error registering notifications: $e');
    }
  }

}