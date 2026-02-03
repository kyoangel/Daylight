import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/data/models/daily_entry.dart';
import 'package:daylight/data/repositories/daily_repository.dart';
import 'package:daylight/features/daily/viewmodel/daily_viewmodel.dart';

void main() {
  test('DailyViewModel upserts entry and reloads', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = DailyRepository();
    final vm = DailyViewModel(repository: repo);

    final entry = DailyEntry(
      date: DateTime(2026, 2, 3),
      moodScore: 6,
      microTaskId: 'task',
      microTaskDone: true,
      affirmationId: 'aff',
      nightReflection: 'ok',
    );

    await vm.upsertEntry(entry);

    expect(vm.state.length, 1);
    expect(vm.state.first.moodScore, 6);
  });
}
