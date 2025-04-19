import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/notification_service.dart';

class Alarm {
  final String id;
  final String label;
  final DateTime time;
  final List<int> repeatDays;
  final String soundFile;
  final bool isEnabled;
  final bool continuous;

  Alarm({
    required this.id,
    required this.label,
    required this.time,
    required this.repeatDays,
    required this.soundFile,
    this.isEnabled = true,
    this.continuous = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'time': time.toIso8601String(),
      'repeatDays': repeatDays,
      'soundFile': soundFile.replaceAll('assets/sounds/', ''),
      'isEnabled': isEnabled,
      'continuous': continuous,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    // 確保 ID 是純數字字串且在 32 位整數範圍內
    String id = json['id']?.toString() ?? '';
    if (id.isEmpty || !RegExp(r'^\d+$').hasMatch(id)) {
      // 使用當前時間的秒數作為 ID
      id = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    }

    return Alarm(
      id: id,
      label: json['label'] ?? '新鬧鐘',
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      repeatDays: json['repeatDays'] != null ? List<int>.from(json['repeatDays']) : [],
      soundFile: json['soundFile'] ?? 'alert.mp3',
      isEnabled: json['isEnabled'] ?? true,
      continuous: json['continuous'] ?? false,
    );
  }
}

class AlarmModel extends ChangeNotifier {
  List<Alarm> _alarms = [];
  final String _storageKey = 'alarms';

  List<Alarm> get alarms => _alarms;

  AlarmModel() {
    _loadAlarms();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString(_storageKey);
    if (alarmsJson != null) {
      final List<dynamic> decoded = json.decode(alarmsJson);
      _alarms = decoded.map((item) => Alarm.fromJson(item)).toList();
      notifyListeners();
      _scheduleAllAlarms();
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_alarms.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> _scheduleAllAlarms() async {
    for (var alarm in _alarms) {
      if (alarm.isEnabled) {
        await _scheduleAlarm(alarm);
      }
    }
  }

  Future<void> _scheduleAlarm(Alarm alarm) async {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    // 如果鬧鐘時間已過，設定為明天
    final scheduledTime = alarmTime.isBefore(now) 
        ? alarmTime.add(const Duration(days: 1))
        : alarmTime;

    // 確保 ID 是有效的數字且在 32 位整數範圍內
    int notificationId;
    try {
      notificationId = int.parse(alarm.id);
      // 如果 ID 超出範圍，使用新的時間戳（秒）
      if (notificationId > 2147483647) {
        notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }
    } catch (e) {
      // 如果解析失敗，使用新的時間戳（秒）
      notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }

    // 設定主要鬧鐘通知
    await NotificationService.scheduleAlarmNotification(
      id: notificationId,
      alarmTime: scheduledTime,
      label: alarm.label,
    );

    // 如果啟用了持續提醒，設定提前通知
    if (alarm.continuous) {
      // 10分鐘提前通知
      await NotificationService.scheduleAlarmNotification(
        id: notificationId + 10,
        alarmTime: scheduledTime,
        label: alarm.label,
        minutesBefore: 10,
      );

      // 5分鐘提前通知
      await NotificationService.scheduleAlarmNotification(
        id: notificationId + 5,
        alarmTime: scheduledTime,
        label: alarm.label,
        minutesBefore: 5,
      );
    }
  }

  Future<void> addAlarm(Alarm alarm) async {
    _alarms.add(alarm);
    await _saveAlarms();
    if (alarm.isEnabled) {
      await _scheduleAlarm(alarm);
    }
    notifyListeners();
  }

  Future<void> updateAlarm(Alarm alarm) async {
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      _alarms[index] = alarm;
      await _saveAlarms();
      if (alarm.isEnabled) {
        await _scheduleAlarm(alarm);
      } else {
        try {
          await NotificationService.cancelAlarm(int.parse(alarm.id));
        } catch (e) {
          // 如果解析失敗，忽略錯誤
        }
      }
      notifyListeners();
    }
  }

  Future<void> deleteAlarm(String id) async {
    _alarms.removeWhere((alarm) => alarm.id == id);
    await _saveAlarms();
    try {
      await NotificationService.cancelAlarm(int.parse(id));
    } catch (e) {
      // 如果解析失敗，忽略錯誤
    }
    notifyListeners();
  }

  Future<void> toggleAlarm(String id) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      final newAlarm = Alarm(
        id: alarm.id,
        label: alarm.label,
        time: alarm.time,
        repeatDays: alarm.repeatDays,
        soundFile: alarm.soundFile,
        isEnabled: !alarm.isEnabled,
        continuous: alarm.continuous,
      );
      _alarms[index] = newAlarm;
      await _saveAlarms();
      if (newAlarm.isEnabled) {
        await _scheduleAlarm(newAlarm);
      } else {
        try {
          await NotificationService.cancelAlarm(int.parse(id));
        } catch (e) {
          // 如果解析失敗，忽略錯誤
        }
      }
      notifyListeners();
    }
  }
} 