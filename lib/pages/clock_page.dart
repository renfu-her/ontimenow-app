import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  late Timer _timer;
  late DateTime _currentTime;
  final List<Map<String, dynamic>> _worldClocks = [
    {'name': '台北', 'offset': 8},
    {'name': '倫敦', 'offset': 1},
    {'name': '紐約', 'offset': -4},
    {'name': '東京', 'offset': 9},
  ];

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime time) {
    return '${time.year}年${time.month}月${time.day}日';
  }

  DateTime _getWorldTime(int offset) {
    return _currentTime.add(Duration(hours: offset - 8));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('時鐘'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: ClockPainter(_currentTime),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _formatTime(_currentTime),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(_currentTime),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '世界時鐘',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _worldClocks.length,
                    itemBuilder: (context, index) {
                      final clock = _worldClocks[index];
                      final worldTime = _getWorldTime(clock['offset']);
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              clock['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTime(worldTime),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(worldTime),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime datetime;
  ClockPainter(this.datetime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final paintCircle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paintCircle);

    final paintBorder = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paintBorder);

    final hourAngle = (datetime.hour % 12 + datetime.minute / 60) * 30 * pi / 180;
    _drawHand(canvas, center, radius * 0.5, hourAngle, 6, Colors.black);

    final minuteAngle = datetime.minute * 6 * pi / 180;
    _drawHand(canvas, center, radius * 0.7, minuteAngle, 4, Colors.black);

    final secondAngle = datetime.second * 6 * pi / 180;
    _drawHand(canvas, center, radius * 0.9, secondAngle, 2, Colors.red);
  }

  void _drawHand(Canvas canvas, Offset center, double length, double angle, double width, Color color) {
    final handPaint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final offset = Offset(
      center.dx + length * cos(angle - pi / 2),
      center.dy + length * sin(angle - pi / 2),
    );
    canvas.drawLine(center, offset, handPaint);
  }

  @override
  bool shouldRepaint(covariant ClockPainter old) => old.datetime.second != datetime.second;
} 