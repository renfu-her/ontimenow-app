import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  final List<String> _laps = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _startStop() {
    setState(() {
      if (_isRunning) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
      }
      _isRunning = !_isRunning;
    });
  }

  void _reset() {
    setState(() {
      _stopwatch.reset();
      _laps.clear();
      _isRunning = false;
    });
  }

  void _lap() {
    if (_isRunning) {
      setState(() {
        _laps.insert(0, _formatDuration(_stopwatch.elapsed));
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return '$minutes:$seconds.$milliseconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('碼表'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                _formatDuration(_stopwatch.elapsed),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text('重設'),
                ),
                ElevatedButton(
                  onPressed: _startStop,
                  child: Text(_isRunning ? '停止' : '開始'),
                ),
                ElevatedButton(
                  onPressed: _lap,
                  child: const Text('圈數'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    '#${_laps.length - index}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  title: Text(
                    _laps[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 