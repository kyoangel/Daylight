import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/data/models/daily_entry.dart';
import 'package:daylight/data/models/diary_entry.dart';
import 'package:daylight/data/models/onboarding_state.dart';
import 'package:daylight/data/models/sos_contact.dart';
import 'package:daylight/data/models/user_profile_model.dart';
import 'package:daylight/data/repositories/daily_repository.dart';
import 'package:daylight/data/repositories/diary_repository.dart';
import 'package:daylight/data/repositories/onboarding_repository.dart';
import 'package:daylight/data/repositories/sos_repository.dart';
import 'package:daylight/data/repositories/user_profile_repository.dart';

void main() {
  test('UserProfileRepository save/load', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = UserProfileRepository();

    const profile = UserProfileModel(
      nickname: 'A',
      avatarUrl: null,
      themeColorHex: '#111111',
      language: 'zh-TW',
      reminderTimes: ['08:00'],
      preferredModes: ['text'],
      triggers: ['lonely'],
      moodBaseline: 3,
    );

    await repo.save(profile);
    final loaded = await repo.load();

    expect(loaded.nickname, 'A');
    expect(loaded.themeColorHex, '#111111');
  });

  test('OnboardingRepository save/load', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = OnboardingRepository();

    const state = OnboardingState(step: 1, completed: true);
    await repo.save(state);

    final loaded = await repo.load();
    expect(loaded.step, 1);
    expect(loaded.completed, true);
  });

  test('DailyRepository upsert', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = DailyRepository();

    final entry = DailyEntry(
      date: DateTime(2026, 2, 3),
      moodScore: 6,
      microTaskId: 'task',
      microTaskDone: true,
      affirmationId: 'aff',
      nightReflection: 'ok',
    );

    await repo.upsert(entry);
    final loaded = await repo.loadAll();

    expect(loaded.length, 1);
    expect(loaded.first.moodScore, 6);
  });

  test('DiaryRepository add', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = DiaryRepository();

    final entry = DiaryEntry(
      id: 'diary_1',
      date: DateTime(2026, 2, 3),
      moodTag: 'calm',
      template: 'gratitude',
      content: 'text',
    );

    await repo.add(entry);
    final loaded = await repo.loadAll();

    expect(loaded.length, 1);
    expect(loaded.first.id, 'diary_1');
  });

  test('SOSRepository save/load', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SOSRepository();

    const contacts = [
      SOSContact(name: 'A', phone: '1', messageTemplate: 'help'),
      SOSContact(name: 'B', phone: '2', messageTemplate: 'help'),
    ];

    await repo.saveAll(contacts);
    final loaded = await repo.loadAll();

    expect(loaded.length, 2);
    expect(loaded.first.name, 'A');
  });
}
