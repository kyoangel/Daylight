import 'package:shared_preferences/shared_preferences.dart';

class ContentHistoryStore {
  static const _affKey = 'recent_affirmation_ids';
  static const _taskKey = 'recent_micro_task_ids';
  static const _guideKey = 'recent_mindfulness_ids';

  Future<List<String>> readAffirmationIds() async => _readList(_affKey);
  Future<List<String>> readMicroTaskIds() async => _readList(_taskKey);
  Future<List<String>> readMindfulnessIds() async => _readList(_guideKey);

  Future<void> writeAffirmationId(String id) async => _writeList(_affKey, id);
  Future<void> writeMicroTaskId(String id) async => _writeList(_taskKey, id);
  Future<void> writeMindfulnessId(String id) async => _writeList(_guideKey, id);

  Future<List<String>> _readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> _writeList(String key, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(key) ?? [];
    final next = <String>[id, ...current.where((e) => e != id)];
    final trimmed = next.take(3).toList();
    await prefs.setStringList(key, trimmed);
  }
}
