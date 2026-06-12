class ValidationMessage {
  final String id;
  final String text;
  final List<String> tags;
  final int weight;

  const ValidationMessage({
    required this.id,
    required this.text,
    required this.tags,
    required this.weight,
  });

  factory ValidationMessage.fromJson(Map<String, dynamic> json) {
    return ValidationMessage(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      tags: List<String>.from(json['tags'] ?? const []),
      weight: json['weight'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'tags': tags,
      'weight': weight,
    };
  }
}
