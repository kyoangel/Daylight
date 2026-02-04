class WelcomeState {
  final String date;
  final String messageId;
  final String locale;

  const WelcomeState({
    required this.date,
    required this.messageId,
    required this.locale,
  });

  factory WelcomeState.fromJson(Map<String, dynamic> json) {
    return WelcomeState(
      date: json['date'] ?? '',
      messageId: json['messageId'] ?? '',
      locale: json['locale'] ?? 'zh-TW',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'messageId': messageId,
      'locale': locale,
    };
  }
}
