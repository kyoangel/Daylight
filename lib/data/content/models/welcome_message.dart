class WelcomeMessage {
  final String id;
  final String greeting;
  final String direction;
  final List<String> tags;
  final int weight;

  const WelcomeMessage({
    required this.id,
    required this.greeting,
    required this.direction,
    required this.tags,
    required this.weight,
  });

  factory WelcomeMessage.fromJson(Map<String, dynamic> json) {
    return WelcomeMessage(
      id: json['id'] ?? '',
      greeting: json['greeting'] ?? '',
      direction: json['direction'] ?? '',
      tags: List<String>.from(json['tags'] ?? const []),
      weight: json['weight'] ?? 1,
    );
  }
}
