import '../data_keys.dart';
import '../models/sos_contact.dart';
import '../storage/local_storage.dart';

class SOSRepository {
  SOSRepository({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  Future<List<SOSContact>> loadAll() async {
    final items = await _storage.readJsonList(DataKeys.sosContacts);
    return items.map(SOSContact.fromJson).toList();
  }

  Future<void> saveAll(List<SOSContact> contacts) async {
    final data = contacts.map((e) => e.toJson()).toList();
    await _storage.writeJsonList(DataKeys.sosContacts, data);
  }
}
