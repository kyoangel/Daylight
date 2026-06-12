import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/features/history/view/history_page.dart';
import 'package:daylight/data/data_keys.dart';
import 'package:daylight/data/models/daily_entry.dart';
import 'package:daylight/common/app_strings.dart';

void main() {
  testWidgets('HistoryPage shows empty state when no entries', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HistoryPage())),
    );
    await tester.pump();
    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.historyEmpty), findsOneWidget);
  });

  testWidgets('HistoryPage shows eventNote for entries with emotion labels', (tester) async {
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
        emotionIntensity: 3,
        eventNote: '今天壓力很大',
      ),
    ];
    SharedPreferences.setMockInitialValues({
      DataKeys.dailyEntries: jsonEncode(entries.map((e) => e.toJson()).toList()),
    });
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HistoryPage())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('「今天壓力很大」'), findsOneWidget);
  });

  testWidgets('HistoryPage shows moodScore fallback when no emotionLabels', (tester) async {
    final now = DateTime.now();
    final entries = [
      DailyEntry(
        date: now,
        moodScore: 7,
        microTaskId: '',
        microTaskDone: false,
        affirmationId: '',
        nightReflection: '',
      ),
    ];
    SharedPreferences.setMockInitialValues({
      DataKeys.dailyEntries: jsonEncode(entries.map((e) => e.toJson()).toList()),
    });
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HistoryPage())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final strings = AppStrings.of('zh-TW');
    expect(find.text('${strings.historyMoodFallback} 7 / 10'), findsOneWidget);
  });
}
