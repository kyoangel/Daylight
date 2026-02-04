import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daylight/features/profile/view/profile_page.dart';
import 'package:daylight/common/app_strings.dart';

void main() {
  testWidgets('ProfilePage shows nickname field', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfilePage()),
      ),
    );

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.nicknameLabel), findsOneWidget);
  });
}
