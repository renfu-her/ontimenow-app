import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('鬧鐘'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAlarmDialog(context),
          ),
        ],
      ),
      body: Consumer<AlarmModel>(
        builder: (context, alarmModel, child) {
          if (alarmModel.alarms.isEmpty) {
            return const Center(
              child: Text('沒有鬧鐘，點擊右上角新增'),
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
  String _timeRemaining = '';
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.alarm.time.hour,
        widget.alarm.time.minute,
      );

      if (alarmTime.isBefore(now)) {
        alarmTime.add(const Duration(days: 1));
      }

      final difference = alarmTime.difference(now);
      final minutes = difference.inMinutes;

      setState(() {
        if (minutes <= 0) {
          _timeRemaining = '${widget.alarm.label}的時間到了';
          _playAlarm();
        } else if (minutes == 5) {
          _timeRemaining = '還有 5 分鐘';
          _playNotification();
        } else if (minutes == 10) {
          _timeRemaining = '還有 10 分鐘';
          _playNotification();
        } else {
          _timeRemaining = '';
        }
      });
    });
  }

  Future<void> _playAlarm() async {
    await _audioPlayer.play(AssetSource(widget.alarm.soundFile));
  }

  Future<void> _playNotification() async {
    await _audioPlayer.play(AssetSource('assets/sounds/alert.mp3'));
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
                    setState(() {
                      _timeRemaining = '';
                    });
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
                    if (_timeRemaining.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _timeRemaining,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.alarm != null
        ? TimeOfDay(hour: widget.alarm!.time.hour, minute: widget.alarm!.time.minute)
        : TimeOfDay.now();
    _label = widget.alarm?.label ?? '新鬧鐘';
    _repeatDays = widget.alarm?.repeatDays ?? [];
    _soundFile = widget.alarm?.soundFile ?? 'assets/sounds/alert.mp3';
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
              items: const [
                DropdownMenuItem(
                  value: 'assets/sounds/alert.mp3',
                  child: Text('預設鈴聲'),
                ),
                DropdownMenuItem(
                  value: 'assets/sounds/bell.mp3',
                  child: Text('鐘聲'),
                ),
                DropdownMenuItem(
                  value: 'assets/sounds/digital.mp3',
                  child: Text('數位音效'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _soundFile = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await _audioPlayer.play(AssetSource(_soundFile));
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
              soundFile: _soundFile,
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