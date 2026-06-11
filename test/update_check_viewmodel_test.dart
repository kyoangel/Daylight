import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:daylight/data/models/update_info.dart';
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

  test('checkForUpdate stores the latest update info from the repository', () async {
    const latest = UpdateInfo(
      version: '1.1.0',
      buildNumber: 11,
      url: 'https://drive.google.com/file/d/abc/view',
      notes: '修正已知問題',
    );
    final viewModel = UpdateCheckViewModel(repository: FakeUpdateCheckRepository(latest));
    await Future<void>.delayed(Duration.zero);

    await viewModel.checkForUpdate();

    expect(viewModel.state.latestInfo?.version, '1.1.0');
    expect(viewModel.state.latestInfo?.buildNumber, 11);
    expect(viewModel.state.isChecking, isFalse);
    expect(viewModel.state.hasChecked, isTrue);
  });

  test('checkForUpdate marks checkFailed when the repository returns no data', () async {
    final viewModel = UpdateCheckViewModel(repository: FakeUpdateCheckRepository(null));
    await Future<void>.delayed(Duration.zero);

    await viewModel.checkForUpdate();

    expect(viewModel.state.checkFailed, isTrue);
    expect(viewModel.state.latestInfo, isNull);
    expect(viewModel.state.hasChecked, isTrue);
  });
}
