import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Alarm {
  final String id;
  final String label;
  final DateTime time;
  final List<int> repeatDays;
  final String soundFile;
  final bool isEnabled;

  Alarm({
    required this.id,
    required this.label,
    required this.time,
    required this.repeatDays,
    required this.soundFile,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'time': time.toIso8601String(),
      'repeatDays': repeatDays,
      'soundFile': soundFile,
      'isEnabled': isEnabled,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] ?? DateTime.now().toString(),
      label: json['label'] ?? '新鬧鐘',
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      repeatDays: json['repeatDays'] != null ? List<int>.from(json['repeatDays']) : [],
      soundFile: json['soundFile'] ?? 'assets/sounds/alert.mp3',
      isEnabled: json['isEnabled'] ?? true,
    );
  }
}

class AlarmModel extends ChangeNotifier {
  List<Alarm> _alarms = [];
  final String _storageKey = 'alarms';

  List<Alarm> get alarms => _alarms;

  AlarmModel() {
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString(_storageKey);
    if (alarmsJson != null) {
      final List<dynamic> decoded = json.decode(alarmsJson);
      _alarms = decoded.map((item) => Alarm.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_alarms.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addAlarm(Alarm alarm) async {
    _alarms.add(alarm);
    await _saveAlarms();
    notifyListeners();
  }

  Future<void> updateAlarm(Alarm alarm) async {
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      _alarms[index] = alarm;
      await _saveAlarms();
      notifyListeners();
    }
  }

  Future<void> deleteAlarm(String id) async {
    _alarms.removeWhere((alarm) => alarm.id == id);
    await _saveAlarms();
    notifyListeners();
  }

  Future<void> toggleAlarm(String id) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      _alarms[index] = Alarm(
        id: alarm.id,
        label: alarm.label,
        time: alarm.time,
        repeatDays: alarm.repeatDays,
        soundFile: alarm.soundFile,
        isEnabled: !alarm.isEnabled,
      );
      await _saveAlarms();
      notifyListeners();
    }
  }
} 