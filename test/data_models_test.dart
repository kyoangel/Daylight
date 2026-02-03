import 'package:flutter_test/flutter_test.dart';

import 'package:daylight/data/models/user_profile_model.dart';
import 'package:daylight/data/models/onboarding_state.dart';
import 'package:daylight/data/models/daily_entry.dart';
import 'package:daylight/data/models/diary_entry.dart';
import 'package:daylight/data/models/companion_session.dart';
import 'package:daylight/data/models/sos_contact.dart';

void main() {
  test('UserProfileModel json roundtrip', () {
    const profile = UserProfileModel(
      nickname: 'A',
      avatarUrl: 'path',
      themeColorHex: '#000000',
      language: 'en',
      reminderTimes: ['08:00'],
      preferredModes: ['text'],
      triggers: ['lonely'],
      moodBaseline: 4,
    );

    final json = profile.toJson();
    final decoded = UserProfileModel.fromJson(json);

    expect(decoded.nickname, profile.nickname);
    expect(decoded.avatarUrl, profile.avatarUrl);
    expect(decoded.themeColorHex, profile.themeColorHex);
    expect(decoded.language, profile.language);
    expect(decoded.reminderTimes, profile.reminderTimes);
    expect(decoded.preferredModes, profile.preferredModes);
    expect(decoded.triggers, profile.triggers);
    expect(decoded.moodBaseline, profile.moodBaseline);
  });

  test('OnboardingState json roundtrip', () {
    const state = OnboardingState(step: 2, completed: true);
    final json = state.toJson();
    final decoded = OnboardingState.fromJson(json);

    expect(decoded.step, state.step);
    expect(decoded.completed, state.completed);
  });

  test('DailyEntry json roundtrip', () {
    final entry = DailyEntry(
      date: DateTime(2026, 2, 3),
      moodScore: 7,
      microTaskId: 'task_001',
      microTaskDone: true,
      affirmationId: 'aff_001',
      nightReflection: 'ok',
    );

    final json = entry.toJson();
    final decoded = DailyEntry.fromJson(json);

    expect(decoded.date.year, entry.date.year);
    expect(decoded.date.month, entry.date.month);
    expect(decoded.date.day, entry.date.day);
    expect(decoded.moodScore, entry.moodScore);
    expect(decoded.microTaskId, entry.microTaskId);
    expect(decoded.microTaskDone, entry.microTaskDone);
    expect(decoded.affirmationId, entry.affirmationId);
    expect(decoded.nightReflection, entry.nightReflection);
  });

  test('DiaryEntry json roundtrip', () {
    final entry = DiaryEntry(
      id: 'diary_1',
      date: DateTime(2026, 2, 3, 10, 0),
      moodTag: 'calm',
      template: 'gratitude',
      content: 'text',
    );

    final json = entry.toJson();
    final decoded = DiaryEntry.fromJson(json);

    expect(decoded.id, entry.id);
    expect(decoded.date.toIso8601String(), entry.date.toIso8601String());
    expect(decoded.moodTag, entry.moodTag);
    expect(decoded.template, entry.template);
    expect(decoded.content, entry.content);
  });

  test('CompanionSession json roundtrip', () {
    final session = CompanionSession(
      id: 'comp_1',
      mode: 'listen',
      startAt: DateTime(2026, 2, 3, 10, 0),
      endAt: DateTime(2026, 2, 3, 10, 10),
      summary: 'done',
    );

    final json = session.toJson();
    final decoded = CompanionSession.fromJson(json);

    expect(decoded.id, session.id);
    expect(decoded.mode, session.mode);
    expect(decoded.startAt.toIso8601String(), session.startAt.toIso8601String());
    expect(decoded.endAt.toIso8601String(), session.endAt.toIso8601String());
    expect(decoded.summary, session.summary);
  });

  test('SOSContact json roundtrip', () {
    const contact = SOSContact(
      name: 'Friend',
      phone: '+886900000000',
      messageTemplate: 'help',
    );

    final json = contact.toJson();
    final decoded = SOSContact.fromJson(json);

    expect(decoded.name, contact.name);
    expect(decoded.phone, contact.phone);
    expect(decoded.messageTemplate, contact.messageTemplate);
  });
}
