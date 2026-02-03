import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/features/diary/view/diary_page.dart';

void main() {
  testWidgets('DiaryPage renders save button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DiaryPage()),
      ),
    );

    expect(find.text('保存日記'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsNWidgets(2));
  });
}
