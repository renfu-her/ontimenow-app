import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('鬧鐘'),
      ),
      body: Consumer<AlarmModel>(
        builder: (context, alarmModel, child) {
          if (alarmModel.alarms.isEmpty) {
            return const Center(
              child: Text('沒有鬧鐘，點擊右下角新增'),
            );
          }
          return ListView.builder(
            itemCount: alarmModel.alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarmModel.alarms[index];
              return AlarmListTile(alarm: alarm);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlarmDialog(context),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddAlarmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddAlarmDialog(),
    );
  }
}

class AlarmListTile extends StatefulWidget {
  final Alarm alarm;

  const AlarmListTile({super.key, required this.alarm});

  @override
  State<AlarmListTile> createState() => _AlarmListTileState();
}

class _AlarmListTileState extends State<AlarmListTile> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.alarm.isEnabled && _shouldCheckAlarm()) {
      _startTimer();
    }
  }

  bool _shouldCheckAlarm() {
    final now = DateTime.now();
    final currentWeekday = now.weekday % 7; // 將週日從 7 改為 0
    
    // 如果鬧鐘沒有設置重複日期，只在當天檢查
    if (widget.alarm.repeatDays.isEmpty) {
      return true;
    }
    
    // 檢查當天是否在重複日期中
    return widget.alarm.repeatDays.contains(currentWeekday);
  }

  bool _isAlarmTimeValid() {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.alarm.time.hour,
      widget.alarm.time.minute,
    );

    // 如果鬧鐘時間已經過了，就不需要再檢查
    return now.isBefore(alarmTime);
  }

  void _startTimer() {
    _timer?.cancel();
    
    // 如果鬧鐘時間已過，不需要啟動計時器
    if (!_isAlarmTimeValid()) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!widget.alarm.isEnabled || !_shouldCheckAlarm()) {
        _stopAlarm();
        return;
      }

      final now = DateTime.now();
      final alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.alarm.time.hour,
        widget.alarm.time.minute,
      );

      // 計算時間差
      final difference = alarmTime.difference(now);
      
      // 如果時間已過，停止計時器
      if (difference.isNegative) {
        _timer?.cancel();
        return;
      }

      // 到達鬧鐘時間
      if (difference.inMinutes == 0 && difference.inSeconds == 0 && !_isPlaying) {
        _showAlarmDialog('${widget.alarm.label}的時間到了');
        _playAlarm();
      } 
      // 提前提醒
      else if (difference.inMinutes == 5 && difference.inSeconds == 0) {
        _showNotificationDialog('還有 5 分鐘');
        _playNotification();
      } else if (difference.inMinutes == 10 && difference.inSeconds == 0) {
        _showNotificationDialog('還有 10 分鐘');
        _playNotification();
      }
    });
  }

  @override
  void didUpdateWidget(AlarmListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 當鬧鐘狀態改變時重新檢查
    if (widget.alarm.isEnabled != oldWidget.alarm.isEnabled ||
        widget.alarm.time != oldWidget.alarm.time ||
        !listEquals(widget.alarm.repeatDays, oldWidget.alarm.repeatDays)) {
      if (widget.alarm.isEnabled && _shouldCheckAlarm()) {
        _startTimer();
      } else {
        _stopAlarm();
      }
    }
  }

  void _stopAlarm() {
    _timer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _isPlaying = false;
  }

  void _showAlarmDialog(String message) {
    _isPlaying = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('鬧鐘提醒'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _playAlarm();
            },
            child: const Text('稍後提醒'),
          ),
          TextButton(
            onPressed: () {
              _stopAlarm();
              Navigator.pop(context);
              context.read<AlarmModel>().toggleAlarm(widget.alarm.id);
            },
            child: const Text('已經出門了'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        // 30 秒後自動關閉對話框
        Future.delayed(const Duration(seconds: 30), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        return AlertDialog(
          title: const Text('提醒'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('確定'),
            ),
          ],
        );
      },
    );

    // 播放提醒音效
    _playNotification().then((_) {
      // 30 秒後停止音效
      Future.delayed(const Duration(seconds: 30), () {
        _audioPlayer.stop();
      });
    });
  }

  Future<void> _playAlarm() async {
    if (!_isPlaying) {
      _isPlaying = true;
      await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (_isPlaying) {
          _playAlarm(); // 重新播放
        }
      });
    }
  }

  Future<void> _playNotification() async {
    await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onLongPress: () => _showEditAlarmDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Switch(
                value: widget.alarm.isEnabled,
                onChanged: (value) {
                  context.read<AlarmModel>().toggleAlarm(widget.alarm.id);
                  if (value) {
                    _startTimer();
                  } else {
                    _timer?.cancel();
                  }
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.alarm.time.hour.toString().padLeft(2, '0')}:${widget.alarm.time.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.alarm.label,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: [
                        for (int i = 0; i < 7; i++)
                          if (widget.alarm.repeatDays.contains(i))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ['日', '一', '二', '三', '四', '五', '六'][i],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('刪除鬧鐘'),
                      content: const Text('確定要刪除這個鬧鐘嗎？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AlarmModel>().deleteAlarm(widget.alarm.id);
                            Navigator.pop(context);
                          },
                          child: const Text('確定'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAlarmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddAlarmDialog(alarm: widget.alarm),
    );
  }
}

class AddAlarmDialog extends StatefulWidget {
  final Alarm? alarm;

  const AddAlarmDialog({super.key, this.alarm});

  @override
  State<AddAlarmDialog> createState() => _AddAlarmDialogState();
}

class _AddAlarmDialogState extends State<AddAlarmDialog> {
  late TimeOfDay _selectedTime;
  late String _label;
  late List<int> _repeatDays;
  late String _soundFile;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> _soundOptions = const [
    {'value': 'alert.mp3', 'label': '預設鈴聲'},
    {'value': 'bell.mp3', 'label': '鐘聲'},
    {'value': 'digital.mp3', 'label': '數位音效'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.alarm != null
        ? TimeOfDay(hour: widget.alarm!.time.hour, minute: widget.alarm!.time.minute)
        : TimeOfDay.now();
    _label = widget.alarm?.label ?? '新鬧鐘';
    _repeatDays = widget.alarm?.repeatDays ?? [];
    
    // 從完整路徑中提取檔案名稱
    String soundFileName = widget.alarm?.soundFile?.split('/').last ?? 'alert.mp3';
    _soundFile = soundFileName;
  }

  String _getFullSoundPath(String fileName) {
    return 'sounds/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.alarm == null ? '新增鬧鐘' : '編輯鬧鐘'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('時間'),
              trailing: TextButton(
                child: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontSize: 20),
                ),
                onPressed: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) {
                    setState(() => _selectedTime = time);
                  }
                },
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: '標籤',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _label),
              onChanged: (value) => _label = value,
            ),
            const SizedBox(height: 16),
            const Text('重複', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i < 7; i++)
                  FilterChip(
                    label: Text(['日', '一', '二', '三', '四', '五', '六'][i]),
                    selected: _repeatDays.contains(i),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _repeatDays.add(i);
                        } else {
                          _repeatDays.remove(i);
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _soundFile,
              decoration: const InputDecoration(
                labelText: '鈴聲',
                border: OutlineInputBorder(),
              ),
              items: _soundOptions.map((option) => DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _soundFile = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await _audioPlayer.play(AssetSource(_getFullSoundPath(_soundFile)));
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('試聽'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            final now = DateTime.now();
            final alarmTime = DateTime(
              now.year,
              now.month,
              now.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );
            
            final alarm = Alarm(
              id: widget.alarm?.id ?? DateTime.now().toString(),
              label: _label,
              time: alarmTime,
              repeatDays: _repeatDays,
              soundFile: _getFullSoundPath(_soundFile),
            );

            if (widget.alarm == null) {
              context.read<AlarmModel>().addAlarm(alarm);
            } else {
              context.read<AlarmModel>().updateAlarm(alarm);
            }
            Navigator.pop(context);
          },
          child: const Text('確定'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
} 