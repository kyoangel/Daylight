import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/user_profile.dart';

class UserProfileService {
  static const _key = 'user_profile';

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return null;
    final map = jsonDecode(jsonStr);
    return UserProfile.fromJson(map);
  }
} 