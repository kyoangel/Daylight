import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/data/data_keys.dart';
import 'package:daylight/data/storage/data_migrator.dart';
import 'package:daylight/data/storage/local_storage.dart';

void main() {
  test('DataMigrator sets data version', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorage();
    final migrator = DataMigrator(storage: storage);

    await migrator.migrate();

    final version = await storage.readInt(DataKeys.dataVersion);
    expect(version, DataMigrator.latestVersion);
  });

  test('DataMigrator backfills profile defaults', () async {
    SharedPreferences.setMockInitialValues({
      DataKeys.userProfile: '{"nickname":"Ava"}',
    });
    final storage = LocalStorage();
    final migrator = DataMigrator(storage: storage);

    await migrator.migrate();

    final profile = await storage.readJson(DataKeys.userProfile);
    expect(profile?['language'], 'zh-TW');
    expect(profile?['themeColorHex'], '#75C9E0');
    expect(profile?['moodBaseline'], 5);
    expect(profile?['toneStyle'], 'gentle');
  });
}
