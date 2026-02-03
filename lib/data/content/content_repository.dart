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
}
