import '../data_keys.dart';
import '../models/daily_entry.dart';
import '../storage/local_storage.dart';

class DailyRepository {
  DailyRepository({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  Future<List<DailyEntry>> loadAll() async {
    final items = await _storage.readJsonList(DataKeys.dailyEntries);
    return items.map(DailyEntry.fromJson).toList();
  }

  Future<void> saveAll(List<DailyEntry> entries) async {
    final data = entries.map((e) => e.toJson()).toList();
    await _storage.writeJsonList(DataKeys.dailyEntries, data);
  }

  Future<void> upsert(DailyEntry entry) async {
    final entries = await loadAll();
    final index = entries.indexWhere((e) => _sameDate(e.date, entry.date));
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.add(entry);
    }
    await saveAll(entries);
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
