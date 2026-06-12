class EmotionLabel {
  final String id;
  final String label;
  final List<String> tags;
  final String colorHex;
  final int weight;

  const EmotionLabel({
    required this.id,
    required this.label,
    required this.tags,
    required this.colorHex,
    required this.weight,
  });

  factory EmotionLabel.fromJson(Map<String, dynamic> json) {
    return EmotionLabel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      tags: List<String>.from(json['tags'] ?? const []),
      colorHex: json['colorHex'] ?? '#AAAAAA',
      weight: json['weight'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'tags': tags,
      'colorHex': colorHex,
      'weight': weight,
    };
  }
}
