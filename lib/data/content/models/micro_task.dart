class MicroTask {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final int weight;

  const MicroTask({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.weight,
  });

  factory MicroTask.fromJson(Map<String, dynamic> json) {
    return MicroTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? const []),
      weight: json['weight'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tags': tags,
      'weight': weight,
    };
  }
}
