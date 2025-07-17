import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user_profile.dart';

class UserProfileViewModel extends StateNotifier<UserProfile> {
  UserProfileViewModel()
      : super(UserProfile(
          nickname: '',
          reminderTime: DateTime.now(),
          sosContact: '',
          avatarUrl: null,
          themeColorHex: '#A8DADC', // 預設柔藍
        ));

  void updateNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  void updateAvatar(String? avatarUrl) {
    state = state.copyWith(avatarUrl: avatarUrl);
  }

  void updateThemeColor(String hex) {
    state = state.copyWith(themeColorHex: hex);
  }
}

final userProfileViewModelProvider = StateNotifierProvider<UserProfileViewModel, UserProfile>(
  (ref) => UserProfileViewModel(),
); 