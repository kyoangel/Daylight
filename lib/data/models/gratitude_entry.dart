class GratitudeEntry {
  const GratitudeEntry({
    required this.id,
    required this.createdAt,
    required this.content,
    required this.moodScore,
  });

  final String id;
  final DateTime createdAt;
  final String content;
  final int moodScore;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'content': content,
        'moodScore': moodScore,
      };

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    return GratitudeEntry(
      id: json['id'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      content: json['content'] as String? ?? '',
      moodScore: json['moodScore'] as int? ?? 6,
    );
  }
}
