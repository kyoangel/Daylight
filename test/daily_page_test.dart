import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/features/daily/view/daily_page.dart';

void main() {
  testWidgets('DailyPage renders save button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DailyPage()),
      ),
    );

    expect(find.text('保存今日'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });
}
