import '../data_keys.dart';
import 'local_storage.dart';

class DataMigrator {
  DataMigrator({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  static const int latestVersion = 1;

  final LocalStorage _storage;

  Future<void> migrate() async {
    final currentVersion = await _storage.readInt(DataKeys.dataVersion) ?? 0;
    if (currentVersion >= latestVersion) return;

    var version = currentVersion;
    if (version < 1) {
      await _migrateToV1();
      version = 1;
    }

    await _storage.writeInt(DataKeys.dataVersion, version);
  }

  Future<void> _migrateToV1() async {
    final profile = await _storage.readJson(DataKeys.userProfile);
    if (profile == null) return;

    final updated = Map<String, dynamic>.from(profile);
    updated.putIfAbsent('language', () => 'zh-TW');
    updated.putIfAbsent('themeColorHex', () => '#75C9E0');
    updated.putIfAbsent('moodBaseline', () => 5);
    updated.putIfAbsent('reminderTimes', () => <String>[]);
    updated.putIfAbsent('preferredModes', () => <String>[]);
    updated.putIfAbsent('triggers', () => <String>[]);

    await _storage.writeJson(DataKeys.userProfile, updated);
  }
}
