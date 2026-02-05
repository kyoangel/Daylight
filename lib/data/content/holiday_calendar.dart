class Holiday {
  const Holiday(this.date, this.tag);

  final DateTime date;
  final String tag;
}

List<String> holidayTagsForDate(DateTime date) {
  final target = DateTime(date.year, date.month, date.day);
  return taiwanHolidays
      .where((holiday) => _isSameDay(holiday.date, target))
      .map((holiday) => holiday.tag)
      .toList();
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

final List<Holiday> taiwanHolidays = [
  // 2025
  Holiday(DateTime(2025, 1, 1), 'holiday:new_year'),
  Holiday(DateTime(2025, 1, 28), 'holiday:lunar_new_year'),
  Holiday(DateTime(2025, 1, 29), 'holiday:lunar_new_year'),
  Holiday(DateTime(2025, 1, 30), 'holiday:lunar_new_year'),
  Holiday(DateTime(2025, 1, 31), 'holiday:lunar_new_year'),
  Holiday(DateTime(2025, 2, 28), 'holiday:peace_memorial'),
  Holiday(DateTime(2025, 4, 3), 'holiday:children'),
  Holiday(DateTime(2025, 4, 4), 'holiday:children'),
  Holiday(DateTime(2025, 4, 5), 'holiday:qingming'),
  Holiday(DateTime(2025, 5, 1), 'holiday:labor'),
  Holiday(DateTime(2025, 5, 31), 'holiday:dragon_boat'),
  Holiday(DateTime(2025, 10, 6), 'holiday:mid_autumn'),
  Holiday(DateTime(2025, 10, 10), 'holiday:national_day'),
  Holiday(DateTime(2025, 10, 25), 'holiday:retrocession'),
  Holiday(DateTime(2025, 12, 25), 'holiday:constitution'),
  Holiday(DateTime(2025, 2, 12), 'holiday:lantern'),
  Holiday(DateTime(2025, 9, 28), 'holiday:confucius'),
  Holiday(DateTime(2025, 12, 25), 'holiday:christmas'),

  // 2026
  Holiday(DateTime(2026, 1, 1), 'holiday:new_year'),
  Holiday(DateTime(2026, 2, 16), 'holiday:lunar_new_year'),
  Holiday(DateTime(2026, 2, 17), 'holiday:lunar_new_year'),
  Holiday(DateTime(2026, 2, 18), 'holiday:lunar_new_year'),
  Holiday(DateTime(2026, 2, 19), 'holiday:lunar_new_year'),
  Holiday(DateTime(2026, 2, 20), 'holiday:lunar_new_year'),
  Holiday(DateTime(2026, 2, 28), 'holiday:peace_memorial'),
  Holiday(DateTime(2026, 3, 3), 'holiday:lantern'),
  Holiday(DateTime(2026, 4, 3), 'holiday:children'),
  Holiday(DateTime(2026, 4, 4), 'holiday:children'),
  Holiday(DateTime(2026, 4, 5), 'holiday:qingming'),
  Holiday(DateTime(2026, 4, 6), 'holiday:qingming'),
  Holiday(DateTime(2026, 5, 1), 'holiday:labor'),
  Holiday(DateTime(2026, 6, 19), 'holiday:dragon_boat'),
  Holiday(DateTime(2026, 9, 25), 'holiday:mid_autumn'),
  Holiday(DateTime(2026, 9, 28), 'holiday:confucius'),
  Holiday(DateTime(2026, 10, 9), 'holiday:national_day'),
  Holiday(DateTime(2026, 10, 10), 'holiday:national_day'),
  Holiday(DateTime(2026, 10, 25), 'holiday:retrocession'),
  Holiday(DateTime(2026, 10, 26), 'holiday:retrocession'),
  Holiday(DateTime(2026, 12, 25), 'holiday:constitution'),
  Holiday(DateTime(2026, 12, 25), 'holiday:christmas'),
];
