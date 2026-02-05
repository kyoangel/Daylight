import '../data_keys.dart';
import '../models/gratitude_entry.dart';
import '../storage/local_storage.dart';

class GratitudeRepository {
  GratitudeRepository({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  Future<List<GratitudeEntry>> loadAll() async {
    final data = await _storage.readJsonList(DataKeys.gratitudeEntries);
    return data.map(GratitudeEntry.fromJson).toList();
  }

  Future<void> add(GratitudeEntry entry) async {
    final items = await loadAll();
    items.add(entry);
    final encoded = items.map((item) => item.toJson()).toList();
    await _storage.writeJsonList(DataKeys.gratitudeEntries, encoded);
  }
}
