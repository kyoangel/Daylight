import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/features/daily/view/daily_page.dart';
import 'package:daylight/common/app_strings.dart';

void main() {
  testWidgets('DailyPage renders emotion chips', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DailyPage()),
      ),
    );
    await tester.pump();

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.emotionSectionTitle), findsOneWidget);

    // Positive emotion chips
    expect(find.text('開心'), findsOneWidget);
    expect(find.text('感恩'), findsOneWidget);
    expect(find.text('幸福'), findsOneWidget);
    // Negative emotion chips
    expect(find.text('焦慮'), findsOneWidget);
    expect(find.text('疲憊'), findsOneWidget);
    expect(find.text('難過'), findsOneWidget);
  });

  testWidgets('DailyPage renders intensity selector', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DailyPage()),
      ),
    );
    await tester.pump();

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.intensityLabel), findsOneWidget);
    expect(find.byKey(const Key('intensity_dot_1')), findsOneWidget);
    expect(find.byKey(const Key('intensity_dot_3')), findsOneWidget);
    expect(find.byKey(const Key('intensity_dot_5')), findsOneWidget);
  });

  testWidgets('DailyPage renders event note input', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DailyPage()),
      ),
    );
    await tester.pump();

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.saveButtonLabel), findsOneWidget);
  });

  testWidgets('DailyPage does not render old mood icon buttons', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DailyPage()),
      ),
    );
    await tester.pump();

    // Old mood icon buttons should NOT be present
    expect(find.byKey(const Key('mood_low')), findsNothing);
    expect(find.byKey(const Key('mood_mid')), findsNothing);
    expect(find.byKey(const Key('mood_high')), findsNothing);
  });

  testWidgets('DailyPage shows view history link', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DailyPage()),
      ),
    );
    await tester.pump();

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.viewHistory), findsOneWidget);
  });
}
