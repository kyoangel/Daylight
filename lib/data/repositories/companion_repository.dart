import '../data_keys.dart';
import '../models/companion_session.dart';
import '../storage/local_storage.dart';

class CompanionRepository {
  CompanionRepository({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  Future<List<CompanionSession>> loadAll() async {
    final items = await _storage.readJsonList(DataKeys.companionSessions);
    return items.map(CompanionSession.fromJson).toList();
  }

  Future<void> add(CompanionSession session) async {
    final sessions = await loadAll();
    sessions.add(session);
    final data = sessions.map((e) => e.toJson()).toList();
    await _storage.writeJsonList(DataKeys.companionSessions, data);
  }
}
