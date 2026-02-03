class DiaryEntry {
  final String id;
  final DateTime date;
  final String moodTag;
  final String template;
  final String content;

  const DiaryEntry({
    required this.id,
    required this.date,
    required this.moodTag,
    required this.template,
    required this.content,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      moodTag: json['moodTag'] ?? '',
      template: json['template'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodTag': moodTag,
      'template': template,
      'content': content,
    };
  }
}
