import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daylight/features/profile/view/profile_page.dart';

void main() {
  testWidgets('ProfilePage shows avatar camera icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfilePage()),
      ),
    );

    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}
