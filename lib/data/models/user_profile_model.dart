class UserProfileModel {
  final String nickname;
  final String? avatarUrl;
  final String themeColorHex;
  final String language;
  final List<String> reminderTimes;
  final List<String> preferredModes;
  final List<String> triggers;
  final int moodBaseline;
  final String toneStyle;

  const UserProfileModel({
    required this.nickname,
    required this.avatarUrl,
    required this.themeColorHex,
    required this.language,
    required this.reminderTimes,
    required this.preferredModes,
    required this.triggers,
    required this.moodBaseline,
    required this.toneStyle,
  });

  UserProfileModel copyWith({
    String? nickname,
    String? avatarUrl,
    String? themeColorHex,
    String? language,
    List<String>? reminderTimes,
    List<String>? preferredModes,
    List<String>? triggers,
    int? moodBaseline,
    String? toneStyle,
  }) {
    return UserProfileModel(
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themeColorHex: themeColorHex ?? this.themeColorHex,
      language: language ?? this.language,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      preferredModes: preferredModes ?? this.preferredModes,
      triggers: triggers ?? this.triggers,
      moodBaseline: moodBaseline ?? this.moodBaseline,
      toneStyle: toneStyle ?? this.toneStyle,
    );
  }

  factory UserProfileModel.initial() {
    return const UserProfileModel(
      nickname: '',
      avatarUrl: null,
      themeColorHex: '#75C9E0',
      language: 'zh-TW',
      reminderTimes: [],
      preferredModes: [],
      triggers: [],
      moodBaseline: 5,
      toneStyle: 'gentle',
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'],
      themeColorHex: json['themeColorHex'] ?? '#75C9E0',
      language: json['language'] ?? 'zh-TW',
      reminderTimes: List<String>.from(json['reminderTimes'] ?? const []),
      preferredModes: List<String>.from(json['preferredModes'] ?? const []),
      triggers: List<String>.from(json['triggers'] ?? const []),
      moodBaseline: json['moodBaseline'] ?? 5,
      toneStyle: json['toneStyle'] ?? 'gentle',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'themeColorHex': themeColorHex,
      'language': language,
      'reminderTimes': reminderTimes,
      'preferredModes': preferredModes,
      'triggers': triggers,
      'moodBaseline': moodBaseline,
      'toneStyle': toneStyle,
    };
  }
}
