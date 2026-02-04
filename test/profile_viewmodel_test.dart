import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/data/models/user_profile_model.dart';
import 'package:daylight/data/repositories/user_profile_repository.dart';
import 'package:daylight/features/profile/viewmodel/profile_viewmodel.dart';

void main() {
  test('UserProfileViewModel loads and updates nickname', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = UserProfileRepository();
    final viewModel = UserProfileViewModel(repository: repository);

    await viewModel.updateNickname('NewName');
    expect(viewModel.state.nickname, 'NewName');

    final loaded = await repository.load();
    expect(loaded.nickname, 'NewName');
  });

  test('UserProfileViewModel updates avatar', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = UserProfileRepository();
    final viewModel = UserProfileViewModel(repository: repository);

    await viewModel.updateAvatar('path');
    expect(viewModel.state.avatarUrl, 'path');

    final loaded = await repository.load();
    expect(loaded.avatarUrl, 'path');
  });

  test('UserProfileViewModel updates theme color', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = UserProfileRepository();
    final viewModel = UserProfileViewModel(repository: repository);

    await viewModel.updateThemeColor('#FFFFFF');
    expect(viewModel.state.themeColorHex, '#FFFFFF');

    final loaded = await repository.load();
    expect(loaded.themeColorHex, '#FFFFFF');
  });

  test('UserProfileViewModel updates tone style', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = UserProfileRepository();
    final viewModel = UserProfileViewModel(repository: repository);

    await viewModel.updateToneStyle('encourage');
    expect(viewModel.state.toneStyle, 'encourage');

    final loaded = await repository.load();
    expect(loaded.toneStyle, 'encourage');
  });

  test('UserProfileViewModel updates language', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = UserProfileRepository();
    final viewModel = UserProfileViewModel(repository: repository);

    await viewModel.updateLanguage('en');
    expect(viewModel.state.language, 'en');

    final loaded = await repository.load();
    expect(loaded.language, 'en');
  });

  test('UserProfileModel initial defaults', () {
    final profile = UserProfileModel.initial();
    expect(profile.nickname, '');
    expect(profile.language, 'zh-TW');
    expect(profile.themeColorHex, '#75C9E0');
    expect(profile.toneStyle, 'gentle');
  });
}
