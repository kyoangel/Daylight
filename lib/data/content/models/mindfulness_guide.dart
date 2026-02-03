class MindfulnessGuide {
  final String id;
  final String title;
  final String duration;
  final List<String> steps;
  final List<String> tags;

  const MindfulnessGuide({
    required this.id,
    required this.title,
    required this.duration,
    required this.steps,
    required this.tags,
  });

  factory MindfulnessGuide.fromJson(Map<String, dynamic> json) {
    return MindfulnessGuide(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      steps: List<String>.from(json['steps'] ?? const []),
      tags: List<String>.from(json['tags'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'steps': steps,
      'tags': tags,
    };
  }
}
