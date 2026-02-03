import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/features/onboarding/view/onboarding_page.dart';
import 'package:daylight/common/app_strings.dart';

void main() {
  testWidgets('OnboardingPage shows start button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OnboardingPage()),
      ),
    );

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.onboardingStart), findsOneWidget);
  });
}
