import 'dart:math';
import 'models/affirmation.dart';
import 'models/micro_task.dart';
import 'models/mindfulness_guide.dart';
import 'content_loader.dart';
import 'content_history_store.dart';

class ContentRepository {
  ContentRepository({
    ContentLoader? loader,
    ContentHistoryStore? historyStore,
    Random? random,
  })  : _loader = loader ?? const AssetContentLoader(),
        _historyStore = historyStore ?? ContentHistoryStore(),
        _random = random ?? Random();

  final ContentLoader _loader;
  final ContentHistoryStore _historyStore;
  final Random _random;

  Future<List<Affirmation>> loadAffirmations() async {
    final items = await _loader.loadList('assets/content/affirmations.json');
    return items.map(Affirmation.fromJson).toList();
  }

  Future<List<MicroTask>> loadMicroTasks() async {
    final items = await _loader.loadList('assets/content/micro_tasks.json');
    return items.map(MicroTask.fromJson).toList();
  }

  Future<List<MindfulnessGuide>> loadMindfulnessGuides() async {
    final items = await _loader.loadList('assets/content/mindfulness_guides.json');
    return items.map(MindfulnessGuide.fromJson).toList();
  }

  Future<Affirmation?> pickAffirmation({List<String>? tags}) async {
    final items = await loadAffirmations();
    final picked = _pickByTags(items, tags, await _historyStore.readAffirmationId());
    if (picked != null) {
      await _historyStore.writeAffirmationId(picked.id);
    }
    return picked;
  }

  Future<MicroTask?> pickMicroTask({List<String>? tags}) async {
    final items = await loadMicroTasks();
    final picked = _pickByTags(items, tags, await _historyStore.readMicroTaskId());
    if (picked != null) {
      await _historyStore.writeMicroTaskId(picked.id);
    }
    return picked;
  }

  Future<MindfulnessGuide?> pickMindfulnessGuide({List<String>? tags}) async {
    final items = await loadMindfulnessGuides();
    final picked = _pickByTags(items, tags, await _historyStore.readMindfulnessId());
    if (picked != null) {
      await _historyStore.writeMindfulnessId(picked.id);
    }
    return picked;
  }

  T? _pickByTags<T extends Object>(List<T> items, List<String>? tags, String? lastId) {
    if (items.isEmpty) return null;
    final filtered = _filterByTags(items, tags);
    final pool = filtered.isNotEmpty ? filtered : items;
    final withoutLast = _filterWithoutLastId(pool, lastId);
    final finalPool = withoutLast.isNotEmpty ? withoutLast : pool;
    return finalPool[_random.nextInt(finalPool.length)];
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
    return null;
  }

  List<T> _filterWithoutLastId<T extends Object>(List<T> items, String? lastId) {
    if (lastId == null) return items;
    return items.where((item) {
      final id = _extractId(item);
      return id == null || id != lastId;
    }).toList();
  }

  String? _extractId(Object item) {
    if (item is Affirmation) return item.id;
    if (item is MicroTask) return item.id;
    if (item is MindfulnessGuide) return item.id;
    return null;
  }
}
