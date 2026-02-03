String normalizeLocale(String? locale) {
  if (locale == null || locale.isEmpty) return 'zh-TW';
  final lower = locale.toLowerCase();
  if (lower.startsWith('en')) return 'en';
  if (lower.startsWith('zh')) return 'zh-TW';
  return 'zh-TW';
}
