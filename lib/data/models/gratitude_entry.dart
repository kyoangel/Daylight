class GratitudeEntry {
  const GratitudeEntry({
    required this.id,
    required this.createdAt,
    required this.content,
  });

  final String id;
  final DateTime createdAt;
  final String content;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'content': content,
      };

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    return GratitudeEntry(
      id: json['id'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      content: json['content'] as String? ?? '',
    );
  }
}
