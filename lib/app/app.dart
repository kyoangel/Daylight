import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_provider.dart';
import '../core/theme/theme_model.dart';
import '../features/onboarding/view/onboarding_page.dart';
import '../features/daily/view/daily_page.dart';
import '../features/companion/view/companion_page.dart';
import '../features/diary/view/diary_page.dart';
import '../features/sos/view/sos_page.dart';
import '../features/profile/view/profile_page.dart';

class DaylightApp extends ConsumerWidget {
  const DaylightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeNotifierProvider);
    return MaterialApp(
      title: '一日之光',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appTheme.color,
          primary: appTheme.color,
          secondary: appTheme.color.withOpacity(0.7),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: appTheme.color,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: appTheme.color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: appTheme.color,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: appTheme.color.withOpacity(0.08),
          selectedItemColor: appTheme.color,
          unselectedItemColor: Colors.grey,
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