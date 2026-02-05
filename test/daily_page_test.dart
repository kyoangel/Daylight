import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/features/daily/view/daily_page.dart';
import 'package:daylight/common/app_strings.dart';

void main() {
  testWidgets('DailyPage renders save button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DailyPage()),
      ),
    );

    final strings = AppStrings.of('zh-TW');
    expect(find.byKey(const Key('mood_low')), findsOneWidget);
    expect(find.byKey(const Key('mood_mid')), findsOneWidget);
    expect(find.byKey(const Key('mood_high')), findsOneWidget);
    expect(find.text(strings.gratitudeTitle), findsOneWidget);
  });
}
