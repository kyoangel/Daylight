import 'dart:math';
import '../../../data/content/content_repository.dart';
import '../../../data/content/models/welcome_message.dart';
import '../../../data/data_keys.dart';
import '../../../data/models/welcome_state.dart';
import '../../../data/storage/local_storage.dart';

class WelcomeService {
  WelcomeService({
    ContentRepository? contentRepository,
    LocalStorage? storage,
    Random? random,
  })  : _contentRepository = contentRepository,
        _storage = storage ?? LocalStorage(),
        _random = random ?? Random();

  final ContentRepository? _contentRepository;
  final LocalStorage _storage;
  final Random _random;

  Future<WelcomeMessage?> getTodayMessage({
    required String locale,
    DateTime? now,
  }) async {
    final today = now ?? DateTime.now();
    final dateKey = _formatDate(today);

    final repository = _contentRepository ?? ContentRepository(locale: locale);
    final messages = await repository.loadWelcomeMessages();
    if (messages.isEmpty) return null;

    final recentIds = await _storage.readStringList(DataKeys.welcomeRecent);
    final picked = _pickWithHistory(messages, recentIds);
    await _saveState(
      WelcomeState(date: dateKey, messageId: picked.id, locale: locale),
    );
    await _saveRecent(picked.id, recentIds);
    return picked;
  }

  WelcomeMessage _pickWithHistory(List<WelcomeMessage> messages, List<String> recentIds) {
    if (messages.length <= 1) return messages.first;
    final filtered = messages.where((m) => !recentIds.contains(m.id)).toList();
    final pool = filtered.isNotEmpty ? filtered : messages;
    return pool[_random.nextInt(pool.length)];
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _saveState(WelcomeState state) async {
    await _storage.writeJson(DataKeys.welcomeState, state.toJson());
  }

  Future<void> _saveRecent(String id, List<String> recentIds) async {
    final next = <String>[id, ...recentIds.where((e) => e != id)];
    await _storage.writeStringList(DataKeys.welcomeRecent, next.take(5).toList());
  }
}
