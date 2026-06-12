class DailyEntry {
  final DateTime date;
  final int moodScore;
  final String microTaskId;
  final bool microTaskDone;
  final String affirmationId;
  final String nightReflection;
  final List<String> emotionLabels;
  final int? emotionIntensity;
  final String? eventNote;

  const DailyEntry({
    required this.date,
    required this.moodScore,
    required this.microTaskId,
    required this.microTaskDone,
    required this.affirmationId,
    required this.nightReflection,
    this.emotionLabels = const [],
    this.emotionIntensity,
    this.eventNote,
  });

  static const Set<String> _positiveEmotionIds = {
    'em_calm', 'em_okay', // legacy backward compat
    'em_happy', 'em_grateful', 'em_fulfilled', 'em_excited', 'em_blissful',
  };

  // Returns -5..+5: positive emotion → +intensity, negative → -intensity,
  // mixed → intensity-3 (-2..+2), no emotions → legacy moodScore mapped to -5..+5.
  int get derivedMoodScore {
    if (emotionLabels.isEmpty) return (moodScore - 5).clamp(-5, 5);
    final intensity = emotionIntensity ?? 3;
    final hasPositive = emotionLabels.any(_positiveEmotionIds.contains);
    final hasNegative = emotionLabels.any((id) => !_positiveEmotionIds.contains(id));
    if (hasPositive && !hasNegative) return intensity.clamp(1, 5);
    if (!hasPositive && hasNegative) return (-intensity).clamp(-5, -1);
    return (intensity - 3).clamp(-2, 2);
  }

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      date: DateTime.parse(json['date']),
      moodScore: json['moodScore'] ?? 0,
      microTaskId: json['microTaskId'] ?? '',
      microTaskDone: json['microTaskDone'] ?? false,
      affirmationId: json['affirmationId'] ?? '',
      nightReflection: json['nightReflection'] ?? '',
      emotionLabels: List<String>.from(json['emotionLabels'] ?? const []),
      emotionIntensity: json['emotionIntensity'] as int?,
      eventNote: json['eventNote'] as String?,
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
      'emotionLabels': emotionLabels,
      if (emotionIntensity != null) 'emotionIntensity': emotionIntensity,
      if (eventNote != null) 'eventNote': eventNote,
    };
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
