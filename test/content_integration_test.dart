import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/features/daily/view/daily_page.dart';
import 'package:daylight/features/diary/view/diary_page.dart';
import 'package:daylight/features/companion/view/companion_page.dart';

void main() {
  testWidgets('DailyPage shows content placeholders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DailyPage()),
      ),
    );

    expect(find.text('今日小任務'), findsOneWidget);
    expect(find.text('今日肯定語'), findsOneWidget);
  });

  testWidgets('DiaryPage shows mindfulness section', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DiaryPage()),
      ),
    );

    expect(find.text('正念引導'), findsOneWidget);
  });

  testWidgets('CompanionPage shows affirmation section', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CompanionPage()),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsWidgets);
  });
}
