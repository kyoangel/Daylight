import 'models/affirmation.dart';
import 'models/micro_task.dart';
import 'models/mindfulness_guide.dart';
import 'content_loader.dart';

class ContentRepository {
  ContentRepository({ContentLoader? loader}) : _loader = loader ?? const AssetContentLoader();

  final ContentLoader _loader;

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
    return _pickByTags(items, tags);
  }

  Future<MicroTask?> pickMicroTask({List<String>? tags}) async {
    final items = await loadMicroTasks();
    return _pickByTags(items, tags);
  }

  Future<MindfulnessGuide?> pickMindfulnessGuide({List<String>? tags}) async {
    final items = await loadMindfulnessGuides();
    return _pickByTags(items, tags);
  }

  T? _pickByTags<T extends Object>(List<T> items, List<String>? tags) {
    if (items.isEmpty) return null;
    if (tags == null || tags.isEmpty) return items.first;

    T? firstMatch;
    for (final item in items) {
      final itemTags = _extractTags(item);
      if (itemTags != null && itemTags.any(tags.contains)) {
        firstMatch ??= item;
      }
    }

    return firstMatch ?? items.first;
  }

  List<String>? _extractTags(Object item) {
    if (item is Affirmation) return item.tags;
    if (item is MicroTask) return item.tags;
    if (item is MindfulnessGuide) return item.tags;
    return null;
  }
}
