class MicroTask {
  final String id;
  final String title;
  final String description;
  final List<String> tags;

  const MicroTask({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
  });

  factory MicroTask.fromJson(Map<String, dynamic> json) {
    return MicroTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tags': tags,
    };
  }
}
