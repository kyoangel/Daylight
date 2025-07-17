import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_model.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<AppTheme> {
  static const _key = 'selected_theme_hex';

  ThemeNotifier() : super(kAppThemes[0]) {
    _loadTheme();
  }

  Future<void> setTheme(AppTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme.hex);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final hex = prefs.getString(_key);
    if (hex != null) {
      final found = kAppThemes.firstWhere((t) => t.hex == hex, orElse: () => kAppThemes[0]);
      state = found;
    }
  }
} 