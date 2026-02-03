import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/data/storage/local_storage.dart';

void main() {
  test('LocalStorage writes and reads json', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorage();

    await storage.writeJson('k', {'a': 1});
    final result = await storage.readJson('k');

    expect(result?['a'], 1);
  });

  test('LocalStorage writes and reads json list', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorage();

    await storage.writeJsonList('k', [
      {'a': 1},
      {'a': 2},
    ]);
    final result = await storage.readJsonList('k');

    expect(result.length, 2);
    expect(result[0]['a'], 1);
    expect(result[1]['a'], 2);
  });
}
