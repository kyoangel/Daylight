import 'package:flutter/material.dart';
import '../features/onboarding/view/onboarding_page.dart';
import '../features/daily/view/daily_page.dart';
import '../features/companion/view/companion_page.dart';
import '../features/diary/view/diary_page.dart';
import '../features/sos/view/sos_page.dart';
import '../features/profile/view/profile_page.dart';

class DaylightApp extends StatelessWidget {
  const DaylightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '一日之光',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFF7C6AE6), // 柔和紫
          onPrimary: Colors.white,
          secondary: const Color(0xFFF6C7B6), // 溫暖米杏
          onSecondary: Colors.black87,
          error: Colors.red.shade400,
          onError: Colors.white,
          background: const Color(0xFFF8F6F1), // 米白
          onBackground: Colors.black87,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F6F1),
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFEDE7F6), // 淡紫灰
          selectedItemColor: Color(0xFF7C6AE6),
          unselectedItemColor: Color(0xFFB0AFC6),
          selectedIconTheme: IconThemeData(color: Color(0xFF7C6AE6)),
          unselectedIconTheme: IconThemeData(color: Color(0xFFB0AFC6)),
          showUnselectedLabels: true,
        ),
      ),
      home: const MainNavigation(),
      routes: {
        '/onboarding': (_) => const OnboardingPage(),
        '/daily': (_) => const DailyPage(),
        '/companion': (_) => const CompanionPage(),
        '/diary': (_) => const DiaryPage(),
        '/sos': (_) => const SOSPage(),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    DailyPage(),
    CompanionPage(),
    DiaryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny), label: '日常'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: '陪伴'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '日記'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我'),
        ],
      ),
    );
  }
} 