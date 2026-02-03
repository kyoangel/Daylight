import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/data/models/diary_entry.dart';
import 'package:daylight/data/repositories/diary_repository.dart';
import 'package:daylight/features/diary/viewmodel/diary_viewmodel.dart';

void main() {
  test('DiaryViewModel adds entry and reloads', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = DiaryRepository();
    final vm = DiaryViewModel(repository: repo);

    final entry = DiaryEntry(
      id: 'diary_1',
      date: DateTime(2026, 2, 3),
      moodTag: 'calm',
      template: 'gratitude',
      content: 'text',
    );

    await vm.addEntry(entry);

    expect(vm.state.length, 1);
    expect(vm.state.first.id, 'diary_1');
  });
}
