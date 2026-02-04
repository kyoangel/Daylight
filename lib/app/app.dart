import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_provider.dart';
import '../core/theme/theme_model.dart';
import '../common/app_strings.dart';
import '../common/locale_provider.dart';
import '../features/onboarding/view/onboarding_page.dart';
import '../features/daily/view/daily_page.dart';
import '../features/diary/view/diary_page.dart';
import '../features/sos/view/sos_page.dart';
import '../features/profile/view/profile_page.dart';

class DaylightApp extends ConsumerWidget {
  const DaylightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeNotifierProvider);
    final locale = ref.watch(localeProvider);
    final strings = AppStrings.of(locale);
    return MaterialApp(
      title: strings.appTitle,
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
          elevation: 0,
        ),
      ),
      home: const MainNavigation(),
      routes: {
        '/onboarding': (_) => const OnboardingPage(),
        '/daily': (_) => const DailyPage(),
        '/diary': (_) => const DiaryPage(),
        '/sos': (_) => const SOSPage(),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    DailyPage(),
    DiaryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final strings = AppStrings.of(locale);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.wb_sunny), label: strings.navDaily),
          BottomNavigationBarItem(icon: const Icon(Icons.book), label: strings.navDiary),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: strings.navProfile),
        ],
      ),
    );
  }
}
