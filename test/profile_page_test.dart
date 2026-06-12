import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:daylight/features/profile/view/profile_page.dart';
import 'package:daylight/common/app_strings.dart';
import 'package:daylight/data/models/update_info.dart';
import 'package:daylight/features/profile/viewmodel/update_check_viewmodel.dart';
import 'test_helpers/fake_update_check_repository.dart';

void main() {
  testWidgets('ProfilePage shows nickname field', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pump();

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.nicknameLabel), findsOneWidget);
  });

  testWidgets('ProfilePage shows the App Update card with current version', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'daylight',
      packageName: 'com.kyomistudio.daylight',
      version: '1.0.9',
      buildNumber: '10',
      buildSignature: '',
      installerStore: null,
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    final strings = AppStrings.of('zh-TW');
    expect(find.text(strings.appUpdateTitle), findsOneWidget);
    expect(find.textContaining('1.0.9'), findsOneWidget);
    expect(find.text(strings.appUpdateCheckButton), findsOneWidget);
  });

  testWidgets('ProfilePage shows up-to-date message after checking with no newer version', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'daylight',
      packageName: 'com.kyomistudio.daylight',
      version: '1.0.9',
      buildNumber: '10',
      buildSignature: '',
      installerStore: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          updateCheckViewModelProvider.overrideWith(
            (ref) => UpdateCheckViewModel(
              repository: FakeUpdateCheckRepository(
                const UpdateInfo(version: '1.0.9', buildNumber: 10, url: 'https://example.com', notes: ''),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    final strings = AppStrings.of('zh-TW');
    await tester.ensureVisible(find.text(strings.appUpdateCheckButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.appUpdateCheckButton));
    await tester.pumpAndSettle();

    expect(find.text(strings.appUpdateUpToDate), findsOneWidget);
  });

  testWidgets('ProfilePage shows download button and opens browser when an update is available', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'daylight',
      packageName: 'com.kyomistudio.daylight',
      version: '1.0.9',
      buildNumber: '10',
      buildSignature: '',
      installerStore: null,
    );

    const downloadUrl = 'https://drive.google.com/file/d/abc/view';
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (call) async {
        calls.add(call);
        return true;
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          updateCheckViewModelProvider.overrideWith(
            (ref) => UpdateCheckViewModel(
              repository: FakeUpdateCheckRepository(
                const UpdateInfo(version: '1.1.0', buildNumber: 11, url: downloadUrl, notes: '修正已知問題'),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    final strings = AppStrings.of('zh-TW');
    await tester.ensureVisible(find.text(strings.appUpdateCheckButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.appUpdateCheckButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('1.1.0'), findsOneWidget);
    expect(find.text(strings.appUpdateDownloadButton), findsOneWidget);

    await tester.ensureVisible(find.text(strings.appUpdateDownloadButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.appUpdateDownloadButton));
    await tester.pumpAndSettle();

    expect(
      calls.any((c) => c.arguments is Map && (c.arguments as Map)['url'] == downloadUrl),
      isTrue,
    );
  });

  testWidgets('ProfilePage shows a check-failed message when the update check fails', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'daylight',
      packageName: 'com.kyomistudio.daylight',
      version: '1.0.9',
      buildNumber: '10',
      buildSignature: '',
      installerStore: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          updateCheckViewModelProvider.overrideWith(
            (ref) => UpdateCheckViewModel(repository: FakeUpdateCheckRepository(null)),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    final strings = AppStrings.of('zh-TW');
    await tester.ensureVisible(find.text(strings.appUpdateCheckButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.appUpdateCheckButton));
    await tester.pumpAndSettle();

    expect(find.text(strings.appUpdateCheckFailed), findsOneWidget);
  });
}
