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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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