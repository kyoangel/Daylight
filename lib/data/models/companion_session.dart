class CompanionSession {
  final String id;
  final String mode;
  final DateTime startAt;
  final DateTime endAt;
  final String summary;

  const CompanionSession({
    required this.id,
    required this.mode,
    required this.startAt,
    required this.endAt,
    required this.summary,
  });

  factory CompanionSession.fromJson(Map<String, dynamic> json) {
    return CompanionSession(
      id: json['id'] ?? '',
      mode: json['mode'] ?? '',
      startAt: DateTime.parse(json['startAt']),
      endAt: DateTime.parse(json['endAt']),
      summary: json['summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'summary': summary,
    };
  }
}
