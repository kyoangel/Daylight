import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/user_profile_repository.dart';

class UserProfileViewModel extends StateNotifier<UserProfileModel> {
  UserProfileViewModel({UserProfileRepository? repository})
      : _repository = repository ?? UserProfileRepository(),
        super(UserProfileModel.initial()) {
    _loadProfile();
  }

  final UserProfileRepository _repository;

  Future<void> _loadProfile() async {
    final loaded = await _repository.load();
    state = loaded;
  }

  Future<void> updateNickname(String nickname) async {
    state = state.copyWith(nickname: nickname);
    await _repository.save(state);
  }

  Future<void> updateAvatar(String? avatarUrl) async {
    state = state.copyWith(avatarUrl: avatarUrl);
    await _repository.save(state);
  }

  Future<void> updateThemeColor(String hex) async {
    state = state.copyWith(themeColorHex: hex);
    await _repository.save(state);
  }

  Future<void> updateToneStyle(String toneStyle) async {
    state = state.copyWith(toneStyle: toneStyle);
    await _repository.save(state);
  }

  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _repository.save(state);
  }
}

final userProfileViewModelProvider = StateNotifierProvider<UserProfileViewModel, UserProfileModel>(
  (ref) => UserProfileViewModel(),
);
