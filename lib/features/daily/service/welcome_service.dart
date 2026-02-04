import '../../../data/content/content_repository.dart';
import '../../../data/content/models/welcome_message.dart';
import '../../../data/data_keys.dart';
import '../../../data/models/welcome_state.dart';
import '../../../data/storage/local_storage.dart';

class WelcomeService {
  WelcomeService({
    ContentRepository? contentRepository,
    LocalStorage? storage,
  })  : _contentRepository = contentRepository,
        _storage = storage ?? LocalStorage();

  final ContentRepository? _contentRepository;
  final LocalStorage _storage;

  Future<WelcomeMessage?> getTodayMessage({
    required String locale,
    DateTime? now,
  }) async {
    final today = now ?? DateTime.now();
    final dateKey = _formatDate(today);
    final saved = await _loadState();

    final repository = _contentRepository ?? ContentRepository(locale: locale);
    final messages = await repository.loadWelcomeMessages();
    if (messages.isEmpty) return null;

    if (saved != null && saved.date == dateKey && saved.locale == locale) {
      final match = messages.where((m) => m.id == saved.messageId).toList();
      if (match.isNotEmpty) {
        return match.first;
      }
    }

    final picked = _pickByDay(messages, today);
    await _saveState(
      WelcomeState(date: dateKey, messageId: picked.id, locale: locale),
    );
    return picked;
  }

  WelcomeMessage _pickByDay(List<WelcomeMessage> messages, DateTime date) {
    final index = _dayOfYear(date) % messages.length;
    return messages[index];
  }

  int _dayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    return date.difference(start).inDays;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<WelcomeState?> _loadState() async {
    final json = await _storage.readJson(DataKeys.welcomeState);
    if (json == null) return null;
    return WelcomeState.fromJson(json);
  }

  Future<void> _saveState(WelcomeState state) async {
    await _storage.writeJson(DataKeys.welcomeState, state.toJson());
  }
}
