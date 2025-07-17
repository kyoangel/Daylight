class UserProfile {
  final String nickname;
  final DateTime reminderTime;
  final String sosContact;
  final String? avatarUrl;
  final String themeColorHex;

  UserProfile({
    required this.nickname,
    required this.reminderTime,
    required this.sosContact,
    this.avatarUrl,
    required this.themeColorHex,
  });

  UserProfile copyWith({
    String? nickname,
    DateTime? reminderTime,
    String? sosContact,
    String? avatarUrl,
    String? themeColorHex,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      reminderTime: reminderTime ?? this.reminderTime,
      sosContact: sosContact ?? this.sosContact,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themeColorHex: themeColorHex ?? this.themeColorHex,
    );
  }
} 