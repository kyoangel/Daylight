class Affirmation {
  final String id;
  final String text;
  final List<String> tags;

  const Affirmation({
    required this.id,
    required this.text,
    required this.tags,
  });

  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      tags: List<String>.from(json['tags'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'tags': tags,
    };
  }
}
