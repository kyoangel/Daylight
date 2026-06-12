import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/data/data_keys.dart';
import 'package:daylight/data/models/daily_entry.dart';
import 'package:daylight/features/daily/view/daily_page.dart';
import 'package:daylight/common/app_strings.dart';

void main() {
  testWidgets('DailyPage shows soft intervention when mood score is low', (WidgetTester tester) async {
    final now = DateTime.now();
    final entries = [
      DailyEntry(
        date: now,
        moodScore: 3,
        microTaskId: 't1',
        microTaskDone: false,
        affirmationId: 'a1',
        nightReflection: '',
      ),
      DailyEntry(
        date: now.subtract(const Duration(days: 1)),
        moodScore: 2,
        microTaskId: 't2',
        microTaskDone: false,
        affirmationId: 'a2',
        nightReflection: '',
      ),
    ];

    SharedPreferences.setMockInitialValues({
      DataKeys.dailyEntries: jsonEncode(entries.map((e) => e.toJson()).toList()),
      DataKeys.userProfile: jsonEncode({
        'nickname': 'Ava',
        'avatarUrl': null,
        'themeColorHex': '#75C9E0',
        'language': 'zh-TW',
        'reminderTimes': [],
        'preferredModes': [],
        'triggers': [],
        'moodBaseline': 5,
        'toneStyle': 'gentle',
      }),
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DailyPage())),
    );
    await tester.pumpAndSettle();

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.softInterventionTitle), findsOneWidget);
  });

  testWidgets('DailyPage shows soft intervention when emotion labels are negative for 2 days', (WidgetTester tester) async {
    final now = DateTime.now();
    final entries = [
      DailyEntry(
        date: now,
        moodScore: 5,
        microTaskId: '',
        microTaskDone: false,
        affirmationId: '',
        nightReflection: '',
        emotionLabels: ['em_anxious', 'em_tired'],
        emotionIntensity: 4,
      ),
      DailyEntry(
        date: now.subtract(const Duration(days: 1)),
        moodScore: 5,
        microTaskId: '',
        microTaskDone: false,
        affirmationId: '',
        nightReflection: '',
        emotionLabels: ['em_sad'],
        emotionIntensity: 3,
      ),
    ];

    SharedPreferences.setMockInitialValues({
      DataKeys.dailyEntries: jsonEncode(entries.map((e) => e.toJson()).toList()),
      DataKeys.userProfile: jsonEncode({
        'nickname': 'Ava',
        'avatarUrl': null,
        'themeColorHex': '#75C9E0',
        'language': 'zh-TW',
        'reminderTimes': [],
        'preferredModes': [],
        'triggers': [],
        'moodBaseline': 5,
        'toneStyle': 'gentle',
      }),
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DailyPage())),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.softInterventionTitle), findsOneWidget);
  });

  testWidgets('DailyPage does not show soft intervention for positive emotion labels', (WidgetTester tester) async {
    final now = DateTime.now();
    final entries = [
      DailyEntry(
        date: now,
        moodScore: 7,
        microTaskId: '',
        microTaskDone: false,
        affirmationId: '',
        nightReflection: '',
        emotionLabels: ['em_calm'],
        emotionIntensity: 3,
      ),
      DailyEntry(
        date: now.subtract(const Duration(days: 1)),
        moodScore: 8,
        microTaskId: '',
        microTaskDone: false,
        affirmationId: '',
        nightReflection: '',
        emotionLabels: ['em_okay'],
        emotionIntensity: 4,
      ),
    ];

    SharedPreferences.setMockInitialValues({
      DataKeys.dailyEntries: jsonEncode(entries.map((e) => e.toJson()).toList()),
      DataKeys.userProfile: jsonEncode({
        'nickname': 'Ava',
        'avatarUrl': null,
        'themeColorHex': '#75C9E0',
        'language': 'zh-TW',
        'reminderTimes': [],
        'preferredModes': [],
        'triggers': [],
        'moodBaseline': 5,
        'toneStyle': 'gentle',
      }),
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DailyPage())),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.softInterventionTitle), findsNothing);
  });
}
