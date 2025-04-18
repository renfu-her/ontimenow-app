import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'pages/alarm_page.dart';
import 'pages/clock_page.dart';
import 'pages/timer_page.dart';
import 'pages/stopwatch_page.dart';
import 'models/alarm_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AlarmModel(),
      child: MaterialApp(
        title: 'OnTimeNow',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B4B62), // 酒紅色作為基礎色
            brightness: Brightness.light,
            primary: const Color(0xFF8B4B62), // 主要顏色：酒紅色
            secondary: const Color(0xFF2B9FA8), // 次要顏色：青色
            background: const Color(0xFFF5F5F5), // 背景色：淺灰色
            surface: Colors.white,
            error: const Color(0xFFB00020),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF8B4B62),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Color(0xFF8B4B62),
            unselectedItemColor: Colors.grey,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF2B9FA8),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'TW'),
          Locale('en', 'US'),
        ],
        locale: const Locale('zh', 'TW'),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const AlarmPage(),
    const ClockPage(),
    const TimerPage(),
    const StopwatchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '鬧鐘',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: '時鐘',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: '計時器',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: '碼表',
          ),
        ],
      ),
    );
  }
}
