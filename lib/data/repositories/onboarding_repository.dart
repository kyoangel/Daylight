import '../data_keys.dart';
import '../models/onboarding_state.dart';
import '../storage/local_storage.dart';

class OnboardingRepository {
  OnboardingRepository({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  Future<OnboardingState> load() async {
    final json = await _storage.readJson(DataKeys.onboardingState);
    if (json == null) return OnboardingState.initial();
    return OnboardingState.fromJson(json);
  }

  Future<void> save(OnboardingState state) async {
    await _storage.writeJson(DataKeys.onboardingState, state.toJson());
  }
}
