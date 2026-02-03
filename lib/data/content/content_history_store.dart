import 'package:shared_preferences/shared_preferences.dart';

class ContentHistoryStore {
  static const _affKey = 'last_affirmation_id';
  static const _taskKey = 'last_micro_task_id';
  static const _guideKey = 'last_mindfulness_id';

  Future<String?> readAffirmationId() async => _read(_affKey);
  Future<String?> readMicroTaskId() async => _read(_taskKey);
  Future<String?> readMindfulnessId() async => _read(_guideKey);

  Future<void> writeAffirmationId(String id) async => _write(_affKey, id);
  Future<void> writeMicroTaskId(String id) async => _write(_taskKey, id);
  Future<void> writeMindfulnessId(String id) async => _write(_guideKey, id);

  Future<String?> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _write(String key, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, id);
  }
}
