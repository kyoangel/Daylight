import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daylight/app/app.dart';

void main() {
  testWidgets('DaylightApp basic startup smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DaylightApp()));
    await tester.pump();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('日常'), findsOneWidget);
    expect(find.text('陪伴'), findsOneWidget);
    expect(find.text('日記'), findsOneWidget);
    expect(find.text('我'), findsOneWidget);
  });
}
