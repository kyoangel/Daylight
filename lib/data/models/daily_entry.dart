class DailyEntry {
  final DateTime date;
  final int moodScore;
  final String microTaskId;
  final bool microTaskDone;
  final String affirmationId;
  final String nightReflection;

  const DailyEntry({
    required this.date,
    required this.moodScore,
    required this.microTaskId,
    required this.microTaskDone,
    required this.affirmationId,
    required this.nightReflection,
  });

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      date: DateTime.parse(json['date']),
      moodScore: json['moodScore'] ?? 0,
      microTaskId: json['microTaskId'] ?? '',
      microTaskDone: json['microTaskDone'] ?? false,
      affirmationId: json['affirmationId'] ?? '',
      nightReflection: json['nightReflection'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': _formatDate(date),
      'moodScore': moodScore,
      'microTaskId': microTaskId,
      'microTaskDone': microTaskDone,
      'affirmationId': affirmationId,
      'nightReflection': nightReflection,
    };
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
