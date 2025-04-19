import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  String _getWeekdayText() {
    final weekdays = ['日', '一', '二', '三', '四', '五', '六'];
    final now = DateTime.now();
    return '星期${weekdays[now.weekday % 7]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('鬧鐘'),
            const SizedBox(width: 16),
            Text(
              _getWeekdayText(),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
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
        child: const Icon(Icons.add),
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
    if (widget.alarm.isEnabled) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AlarmListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alarm != oldWidget.alarm) {
      if (widget.alarm.isEnabled) {
        _startTimer();
      } else {
        _stopAlarm();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!widget.alarm.isEnabled) {
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

      // 如果時間已過，停止計時器
      if (now.isAfter(alarmTime) && !_isPlaying) {
        _timer?.cancel();
        return;
      }
    });
  }

  void _stopAlarm() {
    _timer?.cancel();
    _audioPlayer.stop();
    _isPlaying = false;
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
                    _stopAlarm();
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
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
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
    ).then((_) {
      // 對話框關閉後重新檢查鬧鐘狀態
      if (widget.alarm.isEnabled) {
        _startTimer();
      } else {
        _stopAlarm();
      }
    });
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
  late TextEditingController _labelController;
  late List<int> _repeatDays;
  late String _soundFile;
  bool _continuous = false;
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
    _labelController = TextEditingController(text: widget.alarm?.label ?? '新鬧鐘');
    _repeatDays = List.from(widget.alarm?.repeatDays ?? []);
    _continuous = widget.alarm?.continuous ?? false;
    
    // 從完整路徑中提取檔案名稱
    String soundFileName = widget.alarm?.soundFile != null 
        ? widget.alarm!.soundFile.split('/').last 
        : 'alert.mp3';
    _soundFile = soundFileName;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getFullSoundPath(String fileName) {
    return 'assets/sounds/$fileName';
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
              controller: _labelController,
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
                          _repeatDays.sort();
                        } else {
                          _repeatDays.remove(i);
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _continuous,
                  onChanged: (v) => setState(() => _continuous = v ?? false),
                ),
                const SizedBox(width: 8),
                const Text('持續提醒'),
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
              id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              label: _labelController.text,
              time: alarmTime,
              repeatDays: _repeatDays,
              soundFile: _getFullSoundPath(_soundFile),
              continuous: _continuous,
              isEnabled: widget.alarm?.isEnabled ?? true,
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
} 