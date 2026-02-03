import '../data_keys.dart';
import '../models/diary_entry.dart';
import '../storage/local_storage.dart';

class DiaryRepository {
  DiaryRepository({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  Future<List<DiaryEntry>> loadAll() async {
    final items = await _storage.readJsonList(DataKeys.diaryEntries);
    return items.map(DiaryEntry.fromJson).toList();
  }

  Future<void> saveAll(List<DiaryEntry> entries) async {
    final data = entries.map((e) => e.toJson()).toList();
    await _storage.writeJsonList(DataKeys.diaryEntries, data);
  }

  Future<void> add(DiaryEntry entry) async {
    final entries = await loadAll();
    entries.add(entry);
    await saveAll(entries);
  }
}
