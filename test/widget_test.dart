import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daylight/app/app.dart';
import 'package:daylight/common/app_strings.dart';

void main() {
  testWidgets('DaylightApp basic startup smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DaylightApp()));
    await tester.pump();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.navDaily), findsOneWidget);
    expect(find.text(strings.navDiary), findsOneWidget);
    expect(find.text(strings.navProfile), findsOneWidget);
  });
}
