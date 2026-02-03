import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylight/data/repositories/onboarding_repository.dart';
import 'package:daylight/data/repositories/user_profile_repository.dart';
import 'package:daylight/features/onboarding/viewmodel/onboarding_viewmodel.dart';

void main() {
  test('OnboardingViewModel loads initial state', () async {
    SharedPreferences.setMockInitialValues({});
    final vm = OnboardingViewModel(
      onboardingRepository: OnboardingRepository(),
      userProfileRepository: UserProfileRepository(),
    );

    expect(vm.state.step, 0);
    expect(vm.state.completed, false);
  });

  test('OnboardingViewModel next/previous step persists', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = OnboardingRepository();
    final vm = OnboardingViewModel(
      onboardingRepository: repo,
      userProfileRepository: UserProfileRepository(),
    );

    await vm.nextStep();
    expect(vm.state.step, 1);

    final loaded = await repo.load();
    expect(loaded.step, 1);

    await vm.previousStep();
    expect(vm.state.step, 0);
  });

  test('OnboardingViewModel markCompleted persists', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = OnboardingRepository();
    final vm = OnboardingViewModel(
      onboardingRepository: repo,
      userProfileRepository: UserProfileRepository(),
    );

    await vm.markCompleted();
    expect(vm.state.completed, true);

    final loaded = await repo.load();
    expect(loaded.completed, true);
  });

  test('OnboardingViewModel updates profile basics', () async {
    SharedPreferences.setMockInitialValues({});
    final profileRepo = UserProfileRepository();
    final vm = OnboardingViewModel(
      onboardingRepository: OnboardingRepository(),
      userProfileRepository: profileRepo,
    );

    await vm.updateProfile(
      nickname: 'A',
      language: 'en',
      reminderTimes: ['08:00'],
      preferredModes: ['text'],
      triggers: ['lonely'],
      moodBaseline: 4,
    );

    final loaded = await profileRepo.load();
    expect(loaded.nickname, 'A');
    expect(loaded.language, 'en');
    expect(loaded.reminderTimes, ['08:00']);
    expect(loaded.preferredModes, ['text']);
    expect(loaded.triggers, ['lonely']);
    expect(loaded.moodBaseline, 4);
  });
}
