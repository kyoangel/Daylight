import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user_profile.dart';
import '../service/user_profile_service.dart';

class UserProfileViewModel extends StateNotifier<UserProfile> {
  final UserProfileService _service = UserProfileService();

  UserProfileViewModel()
      : super(UserProfile(
          nickname: '',
          reminderTime: DateTime.now(),
          sosContact: '',
          avatarUrl: null,
          themeColorHex: '#75C9E0',
        )) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final loaded = await _service.loadProfile();
    if (loaded != null) {
      state = loaded;
    }
  }

  Future<void> updateNickname(String nickname) async {
    state = state.copyWith(nickname: nickname);
    await _service.saveProfile(state);
  }

  Future<void> updateAvatar(String? avatarUrl) async {
    state = state.copyWith(avatarUrl: avatarUrl);
    await _service.saveProfile(state);
  }

  Future<void> updateThemeColor(String hex) async {
    state = state.copyWith(themeColorHex: hex);
    await _service.saveProfile(state);
  }
}

final userProfileViewModelProvider = StateNotifierProvider<UserProfileViewModel, UserProfile>(
  (ref) => UserProfileViewModel(),
); 