import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/onboarding_state.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/onboarding_repository.dart';
import '../../../data/repositories/user_profile_repository.dart';

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  OnboardingViewModel({
    OnboardingRepository? onboardingRepository,
    UserProfileRepository? userProfileRepository,
  })  : _onboardingRepository = onboardingRepository ?? OnboardingRepository(),
        _userProfileRepository = userProfileRepository ?? UserProfileRepository(),
        super(OnboardingState.initial()) {
    _load();
  }

  final OnboardingRepository _onboardingRepository;
  final UserProfileRepository _userProfileRepository;

  Future<void> _load() async {
    final loaded = await _onboardingRepository.load();
    state = loaded;
  }

  Future<void> nextStep() async {
    if (state.step < 3) {
      state = OnboardingState(step: state.step + 1, completed: state.completed);
      await _onboardingRepository.save(state);
    }
  }

  Future<void> previousStep() async {
    if (state.step > 0) {
      state = OnboardingState(step: state.step - 1, completed: state.completed);
      await _onboardingRepository.save(state);
    }
  }

  Future<void> setStep(int step) async {
    state = OnboardingState(step: step, completed: state.completed);
    await _onboardingRepository.save(state);
  }

  Future<void> markCompleted() async {
    state = OnboardingState(step: state.step, completed: true);
    await _onboardingRepository.save(state);
  }

  Future<void> updateProfile({
    String? nickname,
    String? language,
    List<String>? reminderTimes,
    List<String>? preferredModes,
    List<String>? triggers,
    int? moodBaseline,
  }) async {
    final current = await _userProfileRepository.load();
    final updated = current.copyWith(
      nickname: nickname,
      language: language,
      reminderTimes: reminderTimes,
      preferredModes: preferredModes,
      triggers: triggers,
      moodBaseline: moodBaseline,
    );
    await _userProfileRepository.save(updated);
  }
}

final onboardingViewModelProvider = StateNotifierProvider<OnboardingViewModel, OnboardingState>(
  (ref) => OnboardingViewModel(),
);
