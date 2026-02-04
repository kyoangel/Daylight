import 'dart:math';
import 'models/affirmation.dart';
import 'models/micro_task.dart';
import 'models/mindfulness_guide.dart';
import 'models/welcome_message.dart';
import 'content_loader.dart';
import 'content_history_store.dart';
import 'content_paths.dart';

class ContentRepository {
  ContentRepository({
    ContentLoader? loader,
    ContentHistoryStore? historyStore,
    Random? random,
    String? locale,
  })  : _loader = loader ?? const AssetContentLoader(),
        _historyStore = historyStore ?? ContentHistoryStore(),
        _random = random ?? Random(),
        _locale = locale ?? 'zh-TW';

  final ContentLoader _loader;
  final ContentHistoryStore _historyStore;
  final Random _random;
  final String _locale;

  Future<List<Affirmation>> loadAffirmations() async {
    final items = await _loader.loadList(ContentPaths.affirmations(_locale));
    return items.map(Affirmation.fromJson).toList();
  }

  Future<List<MicroTask>> loadMicroTasks() async {
    final items = await _loader.loadList(ContentPaths.microTasks(_locale));
    return items.map(MicroTask.fromJson).toList();
  }

  Future<List<MindfulnessGuide>> loadMindfulnessGuides() async {
    final items = await _loader.loadList(ContentPaths.mindfulnessGuides(_locale));
    return items.map(MindfulnessGuide.fromJson).toList();
  }

  Future<List<WelcomeMessage>> loadWelcomeMessages() async {
    final items = await _loader.loadList(ContentPaths.welcomeMessages(_locale));
    return items.map(WelcomeMessage.fromJson).toList();
  }

  Future<Affirmation?> pickAffirmation({List<String>? tags}) async {
    final items = await loadAffirmations();
    final recent = await _historyStore.readAffirmationIds();
    final picked = _pickByTags(items, tags, recent);
    if (picked != null) {
      await _historyStore.writeAffirmationId(picked.id);
    }
    return picked;
  }

  Future<MicroTask?> pickMicroTask({List<String>? tags}) async {
    final items = await loadMicroTasks();
    final recent = await _historyStore.readMicroTaskIds();
    final picked = _pickByTags(items, tags, recent);
    if (picked != null) {
      await _historyStore.writeMicroTaskId(picked.id);
    }
    return picked;
  }

  Future<MindfulnessGuide?> pickMindfulnessGuide({List<String>? tags}) async {
    final items = await loadMindfulnessGuides();
    final recent = await _historyStore.readMindfulnessIds();
    final picked = _pickByTags(items, tags, recent);
    if (picked != null) {
      await _historyStore.writeMindfulnessId(picked.id);
    }
    return picked;
  }

  T? _pickByTags<T extends Object>(List<T> items, List<String>? tags, List<String> recentIds) {
    if (items.isEmpty) return null;
    final filtered = _filterByTags(items, tags);
    final pool = filtered.isNotEmpty ? filtered : items;
    final withoutRecent = _filterWithoutRecentIds(pool, recentIds);
    final finalPool = withoutRecent.isNotEmpty ? withoutRecent : pool;
    return _pickWeighted(finalPool);
  }

  List<T> _filterByTags<T extends Object>(List<T> items, List<String>? tags) {
    if (tags == null || tags.isEmpty) return items;
    final matches = <T>[];
    for (final item in items) {
      final itemTags = _extractTags(item);
      if (itemTags != null && itemTags.any(tags.contains)) {
        matches.add(item);
      }
    }
    return matches;
  }

  List<String>? _extractTags(Object item) {
    if (item is Affirmation) return item.tags;
    if (item is MicroTask) return item.tags;
    if (item is MindfulnessGuide) return item.tags;
    if (item is WelcomeMessage) return item.tags;
    return null;
  }

  List<T> _filterWithoutRecentIds<T extends Object>(List<T> items, List<String> recentIds) {
    if (recentIds.isEmpty) return items;
    return items.where((item) {
      final id = _extractId(item);
      return id == null || !recentIds.contains(id);
    }).toList();
  }

  String? _extractId(Object item) {
    if (item is Affirmation) return item.id;
    if (item is MicroTask) return item.id;
    if (item is MindfulnessGuide) return item.id;
    if (item is WelcomeMessage) return item.id;
    return null;
  }

  int _extractWeight(Object item) {
    if (item is Affirmation) return item.weight;
    if (item is MicroTask) return item.weight;
    if (item is MindfulnessGuide) return item.weight;
    if (item is WelcomeMessage) return item.weight;
    return 1;
  }

  T _pickWeighted<T extends Object>(List<T> items) {
    final weights = items.map((item) => _extractWeight(item)).toList();
    final total = weights.fold<int>(0, (sum, w) => sum + (w <= 0 ? 1 : w));
    final target = _random.nextInt(total);
    var cumulative = 0;
    for (var i = 0; i < items.length; i++) {
      cumulative += (weights[i] <= 0 ? 1 : weights[i]);
      if (target < cumulative) return items[i];
    }
    return items.first;
  }
}
