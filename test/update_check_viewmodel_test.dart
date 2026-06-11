import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:daylight/features/profile/viewmodel/update_check_viewmodel.dart';
import 'test_helpers/fake_update_check_repository.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'daylight',
      packageName: 'com.kyomistudio.daylight',
      version: '1.0.9',
      buildNumber: '10',
      buildSignature: '',
      installerStore: null,
    );
  });

  test('UpdateCheckViewModel loads the current version and build number on creation', () async {
    final viewModel = UpdateCheckViewModel(repository: FakeUpdateCheckRepository(null));

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.currentVersion, '1.0.9');
    expect(viewModel.state.currentBuildNumber, 10);
  });
}
