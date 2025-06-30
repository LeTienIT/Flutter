import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:focus_punch_in/widget/showExactAlarmPermissionDialog.dart';

class AlarmPermissionHelper {
  static const _channel = MethodChannel('alarm_permission');

  static Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final result = await _channel.invokeMethod<bool>('hasExactAlarm');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> openExactAlarmSettings() async {
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  static Future<bool> checkAlarm() async{
    return await hasExactAlarmPermission();
  }

  static Future<void> checkAndRequestExactAlarmPermission() async {
    final granted = await hasExactAlarmPermission();
    if (!granted) {
      await openExactAlarmSettings();
    }
  }
  static Future<void> checkAndHandleAlarmPermission(BuildContext context) async {
    final hasPermission = await checkAlarm();
    if (!hasPermission) {
      final accept = await ShowExactAlarmPermissionDialog.showExactAlarmPermissionDialog(context);
      if (accept) {
        await checkAndRequestExactAlarmPermission();
      }
    }
  }
}
