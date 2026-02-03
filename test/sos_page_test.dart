import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/features/sos/view/sos_page.dart';

void main() {
  testWidgets('SOSPage renders contact form', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SOSPage()),
      ),
    );

    expect(find.text('保存聯絡人'), findsOneWidget);
    expect(find.text('一鍵求助'), findsOneWidget);
  });
}
