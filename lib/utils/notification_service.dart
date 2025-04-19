import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _plugin.initialize(initSettings);
  }

  static Future<void> scheduleAlarmNotification({
    required int id,
    required DateTime alarmTime,
    required String label,
    int minutesBefore = 0,
    bool playSound = true,
  }) async {
    final scheduledTime = tz.TZDateTime.from(
      alarmTime.subtract(Duration(minutes: minutesBefore)), 
      tz.local
    );

    await _plugin.zonedSchedule(
      id,
      minutesBefore == 0 ? '鬧鐘提醒' : '鬧鐘即將響起',
      minutesBefore == 0 ? '$label 的時間到了' : '$label 還有 $minutesBefore 分鐘',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          '鬧鐘',
          channelDescription: '鬧鐘提醒通知',
          importance: Importance.max,
          priority: Priority.high,
          playSound: playSound,
          enableVibration: true,
          enableLights: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelAlarm(int id) async {
    await _plugin.cancel(id);
    await _plugin.cancel(id + 5);
    await _plugin.cancel(id + 10);
  }
} 